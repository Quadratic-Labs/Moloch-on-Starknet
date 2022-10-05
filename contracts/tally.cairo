%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_caller_address, get_block_number

from starkware.cairo.common.math import assert_lt

from proposals.library import Proposal, ProposalInfo, proposalsVotes
from members import Member, membersLength, membersAddresses


namespace Tally{
    func _get_total_votes{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(currentIndex: felt, proposalId: felt, voteType: felt, currentTotal: felt) -> (count: felt) {
        let (member_list_length: felt) = membersLength.read();
        if (currentIndex == member_list_length){
            return (currentTotal,);
        }
        let (current_address: felt) = membersAddresses.read(currentIndex);
        let (vote: felt) = proposalsVotes.read(proposalId, current_address);
        if (vote == voteType){
            let (member_info) = Member.get_info(current_address);
            let new_total: felt = currentTotal + member_info.shares;
            return _get_total_votes(currentIndex+1, proposalId, voteType, new_total);
        }else{
            return _get_total_votes(currentIndex+1, proposalId, voteType,currentTotal);
        }
    }

    func get_total_votes{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(proposalId: felt, voteType: felt) -> (count: felt) {
        return _get_total_votes(0, proposalId, voteType, 0);
    }

    


    // should accept returns if a proposal should be accepted or rejected based
    // on current votes by applying the DAO's acceptance rules
    func did_pass{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(proposalId: felt) -> (accepted: felt) {
        alloc_locals;

        // get proposal's info if it exists, fails otherwise
        let (local info: ProposalInfo) = Proposal.get_info(proposalId);
        let (local params) = Proposal.get_params(info.type);

        // check quorum
        let (local yesVotes) = Tally.get_total_votes(proposalId, Proposal.YESVOTE);
        let (local noVotes) = Tally.get_total_votes(proposalId, Proposal.NOVOTE);
        local numVotes = noVotes + yesVotes;
        // TODO: must get total weight of eligible votes from proposalTypes to roles
        // mapping
        let (eligible) = Member.get_total_shares();

        let quorum = is_le(params.quorum * eligible, numVotes * 100);
        if (quorum == 0) {
            return (FALSE,);
        }

        // check majority
        let majority = is_le(params.majority * numVotes, yesVotes * 100);

        if (majority == 0) {
            return (FALSE,);
        }
        return (TRUE,);
    }

    // apply will check if the proposal's grace period has ended, and move the
    // proposal to the next state, ACCEPTED/REJECTED.
    func _tally{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(proposalId: felt) -> (accepted: felt) {
        // Apply voting rules to determine if proposal is accepted or rejected
        // Requires voting and grace period have ended
        // Modify Proposal status which is used by the front
        alloc_locals;
        let (local info: ProposalInfo) = Proposal.get_info(proposalId);
        let (local params) = Proposal.get_params(info.type);
        let (local caller) = get_caller_address();

        // assert proposal status is submitted
        with_attr error_message("Tally needs a proposal with SUBMITTED as status") {
            assert info.status = Proposal.SUBMITTED;
        }


        // assert the caller is member
        with_attr error_message("AccessControl: user {caller} is not a member.") {
            Member.assert_is_member(caller);
        }

        let (local today_timestamp) = get_block_number();

        // assert the voting period ended
        with_attr error_message("The proposal has not ended voting period.") {
            assert_lt(
                info.submittedAt + params.votingDuration, today_timestamp
            );
        }

        let (accepted: felt) = did_pass(proposalId);
        if (accepted == FALSE) {
            Proposal.update_status(info.id, Proposal.REJECTED);
            return (FALSE,);
        }

        Proposal.update_status(info.id, Proposal.ACCEPTED);

        return (TRUE,);
    }
}
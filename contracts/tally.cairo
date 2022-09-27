%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp

from starkware.cairo.common.math import assert_lt

from proposals.library import Proposal, ProposalInfo
from members import Member


// should accept returns if a proposal should be accepted or rejected based
// on current votes by applying the DAO's acceptance rules
// TODO did_pass
func should_accept{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(proposalId: felt) -> (accepted: felt) {
    alloc_locals;

    // get proposal's info if it exists, fails otherwise
    let (local info: ProposalInfo) = Proposal.get_info(proposalId);
    let (local params) = Proposal.get_params(info.type);

    // check quorum
    local numVotes = info.yesVotes + info.noVotes;

    // TODO: must get total weight of eligible votes from proposalTypes to roles
    // mapping
    let eligible = 10;

    let quorum = is_le(params.quorum * eligible, numVotes * 100);
    if (quorum == 0) {
        return (FALSE,);
    }

    // check majority
    let majority = is_le(params.majority * numVotes, info.yesVotes * 100);
    if (majority == 0) {
        return (FALSE,);
    }
    return (TRUE,);
}

// apply will check if the proposal's grace period has ended, and move the
// proposal to the next state, ACCEPTED/REJECTED.
// TODO change to tally
@external
func launch_tally{
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

    let (local today_timestamp) = get_block_timestamp();

    // assert the voting period ended
    with_attr error_message("The proposal has not ended voting period.") {
        assert_lt(
            info.submittedAt + params.votingDuration, today_timestamp
        );
    }

    let (accepted: felt) = should_accept(proposalId);
    if (accepted == FALSE) {
        Proposal.update_status(info.id, Proposal.REJECTED);
        return (FALSE,);
    }

    Proposal.update_status(info.id, Proposal.ACCEPTED);
    return (TRUE,);
}

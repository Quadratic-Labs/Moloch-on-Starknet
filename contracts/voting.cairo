%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.math import assert_lt
from members import Member
from proposals.library import Proposal, ProposalInfo, ProposalParams

@external
func submitVote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposalId: felt, vote: felt
) -> (success: felt) {
    alloc_locals;
    // assert the caller is member
    let (local caller) = get_caller_address();
    with_attr error_message("AccessControl: user {caller} is not a member.") {
        Member.assert_is_member(caller);
    }

    // check if the proposal exists and get its info
    let (local proposal: ProposalInfo) = Proposal.get_proposal_by_id(proposalId);
    let (local params: ProposalParams) = Proposal.get_params(proposal.type);

    let (local today_timestamp) = get_block_timestamp();

    // assert the votingPeriod has not ended
    with_attr error_message("The voting period has ended.") {
        assert_lt(today_timestamp, proposal.submittedAt + params.votingDuration);
    }


    // assert the caller has not voted
    let (has_voted) = Proposal.get_has_voted(proposalId, caller);
    with_attr error_message("The caller has already voted.") {
        assert has_voted = FALSE;
    }

    %{
        print("has_voted=",ids.has_voted)
        print("has_voted=",ids.proposalId)
        print("has_voted=",ids.caller)
    %}
    // Set vote
    Proposal.set_vote(id=proposalId, address=caller, vote=vote);


    // Set has voted
    Proposal.set_has_voted(proposalId, caller);

    return (TRUE,);
}

@external
func submitVoteWithSig{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposalId: felt, vote: felt, signature: felt
) -> (success: felt) {
    return (0,);
}

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address
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

    local today_timestamp;
    %{
        from datetime import datetime
        dt = datetime.now()
        ids.today_timestamp = int(datetime.timestamp(dt))
    %}

    // assert the votingPeriod has not ended
    with_attr error_message("The voting period has ended.") {
        assert_lt(today_timestamp, proposal.submittedAt + params.votingDuration);
    }

    // Set vote
    Proposal.set_vote(id=proposalId, address=caller, vote=vote);

    return (TRUE,);
}

@external
func submitVoteWithSig{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposalId: felt, vote: felt, signature: felt
) -> (success: felt) {
    return (0,);
}

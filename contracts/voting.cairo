%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_number
from starkware.cairo.common.math import assert_lt
from members import Member
from proposals.library import Proposal, ProposalInfo, ProposalParams

@external
func submitVote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposalId: felt, vote: felt, onBehalf: felt
) -> (success: felt) {
    alloc_locals;
    // assert the caller is member
    let (local caller) = get_caller_address();
    Member.assert_is_member(caller);

    // assert the caller is authorized to vote on behalf of "behalf"
    Member.assert_is_delegate(onBehalf);

    // check if the proposal exists and get its info
    let (local proposal: ProposalInfo) = Proposal.get_proposal_by_id(proposalId);
    let (local params: ProposalParams) = Proposal.get_params(proposal.type);

    let (local today_timestamp) = get_block_number();

    // assert the votingPeriod has not ended
    with_attr error_message("The voting period has ended.") {
        assert_lt(today_timestamp, proposal.submittedAt + params.votingDuration);
    }


    // assert behalf has not voted
    let (current_vote) = Proposal.get_vote(proposalId, onBehalf);
    with_attr error_message("The member {onBehalf} has already voted.") {
        assert current_vote = 0;
    }

    // Set vote
    Proposal.set_vote(id=proposalId, address=onBehalf, vote=vote);

    // TODO update member info by puting the id of the last proposal he voted yes (useful later for ragequits)
    // TODO check wether the user is jailed or no
    // TODO check if the vote is one of the allowed value
    // TODO dans MOLOCH V2, le vote est mis à jour avec le nombre de shares du user et non pas en augmentant de 1

    return (TRUE,);
}

@external
func submitVoteWithSig{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposalId: felt, vote: felt, signature: felt
) -> (success: felt) {
    return (0,);
}

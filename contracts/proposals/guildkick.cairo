%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from members import Member
from roles import Roles
from proposals.library import Proposal, ProposalInfo


@external
func submitGuildKick{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    memberAddress: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is govern
    Roles.require_role('govern');
    // assert the submitted user is not a memeber
    Member.assert_is_member(memberAddress);
    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'GuildKick';
    let submittedBy = caller;
    let (submittedAt) = get_block_timestamp();
    let yesVotes = 0;
    let noVotes = 0;
    let status = 1;
    let description = 0;
    let proposal: ProposalInfo = ProposalInfo(
        id=id,
        type=type,
        submittedBy=submittedBy,
        submittedAt=submittedAt,
        yesVotes=yesVotes,
        noVotes=noVotes,
        status=status,
        description=description,
    );

    Proposal.add_proposal(proposal);
    return (TRUE,);
}

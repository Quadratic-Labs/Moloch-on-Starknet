%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from members import Member
from roles import Roles
from proposals.library import Proposal, ProposalInfo

@external
func submitSignaling{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(title: felt,description: felt) -> (
    success: felt
) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller has correct roles
    Roles.require_role('govern');
    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'Signaling';
    let submittedBy = caller;
    let (submittedAt) = get_block_timestamp();
    let status = 1;
    let proposal: ProposalInfo = ProposalInfo(
        id=id,
        title=title,
        type=type,
        submittedBy=submittedBy,
        submittedAt=submittedAt,
        status=status,
        description=description,
    );

    Proposal.add_proposal(proposal);
    return (TRUE,);
}

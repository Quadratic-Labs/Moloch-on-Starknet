%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.uint256 import Uint256
from members import Member
from roles import Roles
from proposals.library import Proposal, ProposalInfo



struct OrderParams {
    tributeOffered: Uint256,
    tributeAddress: felt,
    paymentRequested: Uint256,
    paymentAddress: felt,
}

@storage_var
func orderParams(proposalId: felt) -> (params: OrderParams) {
}

namespace Order{
    func get_orderParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (params: OrderParams) {
        let (params: OrderParams) = orderParams.read(id);
        return (params,);
    }

    func set_orderParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, params: OrderParams
    ) -> () {
        orderParams.write(id, params);
        return ();
    }
}


@external
func submitOrder{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tributeOffered: Uint256, tributeAddress: felt, paymentRequested: Uint256, paymentAddress: felt,description: felt) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is admin
    Roles.require_role('govern');
    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'Order';
    // TODO assert the token is whitelisted
    // TODO assert enough tokens in the bank
    let submittedBy = caller;
    let (submittedAt) = get_block_timestamp();
    let yesVotes = 0;
    let noVotes = 0;
    let status = 1;
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
    // register params
    let params: OrderParams= OrderParams(tributeOffered=tributeOffered,
                                        tributeAddress=tributeAddress,
                                        paymentRequested=paymentRequested,
                                        paymentAddress=paymentAddress,);
    Order.set_orderParams(id, params);
    return (TRUE,);
}

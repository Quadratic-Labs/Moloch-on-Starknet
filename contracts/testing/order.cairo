%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_number
from starkware.cairo.common.uint256 import Uint256
from members import Member
from roles import Roles
from proposals.library import Proposal, ProposalInfo
from bank import Bank
from proposals.order import Order, OrderParams
// duplicate of submit order without bank transfer
@external
func Order_submitOrder_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tributeOffered: Uint256, tributeAddress: felt, paymentRequested: Uint256, paymentAddress: felt,title: felt,description: felt) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is admin
    Roles.require_role('govern');
    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'Order';
    let submittedBy = caller;
    let (submittedAt) = get_block_number();
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
    // register params
    let params: OrderParams= OrderParams(tributeOffered=tributeOffered,
                                        tributeAddress=tributeAddress,
                                        paymentRequested=paymentRequested,
                                        paymentAddress=paymentAddress,);
    Order.set_orderParams(id, params);

    // collect tribute from proposer and store it in the Escrow until the proposal is processed
    // Bank.bank_deposit(tokenAddress = tributeAddress, amount = tributeOffered);
    // update bank accounting 
    Bank.increase_userTokenBalances(userAddress= Bank.ESCROW, tokenAddress=tributeAddress, amount=tributeOffered);
    Bank.increase_userTokenBalances(userAddress= Bank.TOTAL, tokenAddress=tributeAddress, amount=tributeOffered);
    return (TRUE,);
}

@external
func Order_set_orderParams_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt, params: OrderParams
) -> () {
    return Order.set_orderParams(id,params);
}
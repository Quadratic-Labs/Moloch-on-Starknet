%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_number
from starkware.cairo.common.uint256 import Uint256
from members import Member
from roles import Roles
from proposals.library import Proposal, ProposalInfo
from bank import Bank

@event
func SwapProposalAdded(
    id: felt,
    tributeAddress: felt,
    tributeOffered: Uint256,
    paymentAddress: felt,
    paymentRequested: Uint256,
) {
}

struct SwapParams {
    tributeOffered: Uint256,
    tributeAddress: felt,
    paymentRequested: Uint256,
    paymentAddress: felt,
}

@storage_var
func swapParams(proposalId: felt) -> (params: SwapParams) {
}

namespace Swap {
    func get_swapParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (params: SwapParams) {
        let (params: SwapParams) = swapParams.read(id);
        return (params,);
    }

    func set_swapParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, params: SwapParams
    ) -> () {
        swapParams.write(id, params);
        return ();
    }
}

@external
func submitSwap{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tributeOffered: Uint256,
    tributeAddress: felt,
    paymentRequested: Uint256,
    paymentAddress: felt,
    title: felt,
    link: felt,
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is not jailed
    Member.assert_not_jailed(caller);
    // assert the caller is admin
    Roles.require_role('govern');
    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'Swap';
    // assert the token is whitelisted
    with_attr error_message("Tribute token must be whitelisted") {
        Bank.assert_token_whitelisted(tributeAddress);
    }

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
        link=link,
    );

    Proposal.add_proposal(proposal);
    // register params
    let params: SwapParams = SwapParams(
        tributeOffered=tributeOffered,
        tributeAddress=tributeAddress,
        paymentRequested=paymentRequested,
        paymentAddress=paymentAddress,
    );
    Swap.set_swapParams(id, params);
    SwapProposalAdded.emit(
        id=id,
        tributeAddress=tributeAddress,
        tributeOffered=tributeOffered,
        paymentAddress=paymentAddress,
        paymentRequested=paymentRequested,
    );
    // collect tribute from proposer and store it in the Escrow until the proposal is processed
    Bank.bank_deposit(tokenAddress=tributeAddress, amount=tributeOffered);
    // update bank accounting
    Bank.increase_userTokenBalances(
        userAddress=Bank.ESCROW, tokenAddress=tributeAddress, amount=tributeOffered
    );
    Bank.increase_userTokenBalances(
        userAddress=Bank.TOTAL, tokenAddress=tributeAddress, amount=tributeOffered
    );
    return (TRUE,);
}

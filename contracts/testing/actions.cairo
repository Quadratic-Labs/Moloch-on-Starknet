%lang starknet

from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_number
from starkware.cairo.common.math import assert_lt
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.uint256 import Uint256
from proposals.swap import Swap, SwapParams
from proposals.library import Proposal, ProposalInfo
from bank import Bank
from tally import Tally

// same as execute swap without the actual bank payment
func Actions_execute_swap_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposalId: felt
) -> (success: felt) {
    alloc_locals;
    let (local params: SwapParams) = Swap.get_swapParams(proposalId);
    let (local info: ProposalInfo) = Proposal.get_info(proposalId);
    let (local bank_address: felt) = get_contract_address();
    // assert enough payment token in the bank
    Bank.assert_sufficient_balance(
        userAddress=Bank.GUILD, tokenAddress=params.paymentAddress, amount=params.paymentRequested
    );

    // update the accounting for the payment
    Bank.decrease_userTokenBalances(
        userAddress=Bank.GUILD, tokenAddress=params.paymentAddress, amount=params.paymentRequested
    );
    Bank.decrease_userTokenBalances(
        userAddress=Bank.TOTAL, tokenAddress=params.paymentAddress, amount=params.paymentRequested
    );

    // update the accounting for the tribute
    Bank.decrease_userTokenBalances(
        userAddress=Bank.ESCROW, tokenAddress=params.tributeAddress, amount=params.tributeOffered
    );
    Bank.increase_userTokenBalances(
        userAddress=Bank.GUILD, tokenAddress=params.tributeAddress, amount=params.tributeOffered
    );
    return (TRUE,);
}

@external
func Actions_executeProposal_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposalId: felt
) -> (success: felt) {
    // Requires proposal to be accepted
    // Executes the proposal's actions if preconditions are satisfied
    // Modify Proposal status which is used by the front
    alloc_locals;
    // launch the tally
    Tally._tally(proposalId);
    let (local proposal: ProposalInfo) = Proposal.get_info(proposalId);
    let (local params) = Proposal.get_params(proposal.type);

    // if the proposal status is REJECTED refund the submitter and change status to EXECUTED
    if (proposal.status == Proposal.REJECTED) {
        Proposal.update_status(proposalId, Proposal.EXECUTED);
        if (proposal.type == 'Swap') {
            let (local swap_params: SwapParams) = Swap.get_swapParams(proposalId);
            // refund the submitter
            Bank.bank_payment(
                recipient=proposal.submittedBy,
                tokenAddress=swap_params.tributeAddress,
                amount=swap_params.tributeOffered,
            );
            // update bank accounting
            Bank.decrease_userTokenBalances(
                userAddress=Bank.ESCROW,
                tokenAddress=swap_params.tributeAddress,
                amount=swap_params.tributeOffered,
            );
            Bank.decrease_userTokenBalances(
                userAddress=Bank.TOTAL,
                tokenAddress=swap_params.tributeAddress,
                amount=swap_params.tributeOffered,
            );
            return (TRUE,);
        }
        return (TRUE,);
    }
    // if the proposal status is ACCEPTED or FORCED, the below expression is equal to zero
    let should_pass = (proposal.status - Proposal.ACCEPTED) * (proposal.status - Proposal.FORCED);
    with_attr error_message("The proposal status should be ACCEPTED or FORCED.") {
        assert should_pass = 0;
    }

    // assert the grace period ended
    let (local today_timestamp) = get_block_number();
    with_attr error_message("The proposal has not ended grace period.") {
        if (proposal.status == Proposal.ACCEPTED) {
            assert_lt(
                proposal.submittedAt + params.votingDuration + params.graceDuration, today_timestamp
            );
        } else {
            // if the proposal status is FORCED, ignore voting duration
            assert_lt(proposal.submittedAt + params.graceDuration, today_timestamp);
        }
    }
    // execute action
    if (proposal.type == 'Swap') {
        Actions_execute_swap_proxy(proposalId);
        Proposal.update_status(proposalId, Proposal.EXECUTED);
        return (TRUE,);
    }

    return (TRUE,);
}

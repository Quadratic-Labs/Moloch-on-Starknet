%lang starknet
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_number
from starkware.cairo.common.math import assert_lt
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import Uint256
from proposals.guildkick import Guildkick, GuildKickParams
from proposals.onboard import Onboard, OnboardParams
from members import Member, MemberInfo
from proposals.swap import Swap, SwapParams
from proposals.tokens import Tokens, TokenParams
from proposals.library import Proposal, ProposalInfo
from bank import Bank
from tally import Tally

namespace Actions {

    func execute_onboard{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        alloc_locals;
        let (local params: OnboardParams) = Onboard.get_onBoardParams(proposalId);

        let (onBoarddedAt) = get_block_number();
        let member_: MemberInfo = MemberInfo(address=params.address,
                                            delegatedKey=params.address,
                                            shares=params.shares,
                                            loot=params.loot,
                                            jailed=0,
                                            lastProposalYesVote=0,
                                            onBoarddedAt=onBoarddedAt);
        Member.add_member(member_);
        // update the accounting for the tribute
        Bank.decrease_userTokenBalances(userAddress= Bank.ESCROW, tokenAddress=params.tributeAddress, amount=params.tributeOffered);
        Bank.increase_userTokenBalances(userAddress= Bank.GUILD, tokenAddress=params.tributeAddress, amount=params.tributeOffered);
        return (TRUE,);
    }

    func execute_guildkick{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        alloc_locals;
        let (params: GuildKickParams) = Guildkick.get_guildKickParams(proposalId);
        let (local member_: MemberInfo) = Member.get_info(params.memberAddress);
        // move member's shares to loot and jail the member 
        let updated_member: MemberInfo = MemberInfo(address=member_.address,
                                                    delegatedKey=member_.delegatedKey,
                                                    shares=0,
                                                    loot=member_.loot+member_.shares,
                                                    jailed=TRUE,
                                                    lastProposalYesVote=member_.lastProposalYesVote,
                                                    onBoarddedAt=member_.onBoarddedAt);
        Member.update_member(updated_member);
        return (TRUE,);
    }
    
    func execute_approve_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        let (params: TokenParams) = Tokens.get_tokenParams(proposalId);
        Bank.add_token(params.tokenAddress);
        return (TRUE,);
    }

    func execute_remove_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        let (params: TokenParams) = Tokens.get_tokenParams(proposalId);
        Bank.remove_token(params.tokenAddress);
        return (TRUE,);
    }

    func execute_signaling{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        return (TRUE,);
    }

    func execute_swap{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        alloc_locals;
        let (local params: SwapParams) = Swap.get_swapParams(proposalId);
        let (local info: ProposalInfo) = Proposal.get_info(proposalId);
        let (local bank_address: felt) = get_contract_address();
        // assert enough payment token in the bank
        Bank.assert_sufficient_balance(userAddress=Bank.GUILD, tokenAddress=params.paymentAddress, amount=params.paymentRequested);


        // execute the payment
        Bank.bank_payment(recipient=info.submittedBy, tokenAddress=params.paymentAddress, amount=params.paymentRequested);
        // update the accounting for the payment
        Bank.decrease_userTokenBalances(userAddress= Bank.GUILD, tokenAddress=params.paymentAddress, amount=params.paymentRequested);
        Bank.decrease_userTokenBalances(userAddress= Bank.TOTAL, tokenAddress=params.paymentAddress, amount=params.paymentRequested);
        
        // update the accounting for the tribute
        Bank.decrease_userTokenBalances(userAddress= Bank.ESCROW, tokenAddress=params.tributeAddress, amount=params.tributeOffered);
        Bank.increase_userTokenBalances(userAddress= Bank.GUILD, tokenAddress=params.tributeAddress, amount=params.tributeOffered);
        return (TRUE,);
    }
}

@external
func executeProposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt) {
    // Requires proposal to be accepted
    // Executes the proposal's actions if preconditions are satisfied
    // Modify Proposal status which is used by the front
    alloc_locals;
    // launch the tally if the proposal status is SUBMITTED
    let (local proposal_before_tally: ProposalInfo) = Proposal.get_info(proposalId);
    if (proposal_before_tally.status == Proposal.SUBMITTED){
        Tally._tally(proposalId);
        // tempvar to avoid revoked references
        tempvar syscall_ptr = syscall_ptr;
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar range_check_ptr = range_check_ptr;
    }else{
        tempvar syscall_ptr = syscall_ptr;
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar range_check_ptr = range_check_ptr;
    }
    let (local proposal: ProposalInfo) = Proposal.get_info(proposalId);
    let (local params) = Proposal.get_params(proposal.type);
    
    // assert the caller is member
    let (local caller) = get_caller_address();
    Member.assert_is_member(caller);

    // assert the caller is not jailed
    Member.assert_not_jailed(caller);

    // if the proposal status is REJECTED refund the submitter and change status to EXECUTED
    if (proposal.status == Proposal.REJECTED){
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        if (proposal.type == 'Onboard'){
            let (local onboard_params: OnboardParams) = Onboard.get_onBoardParams(proposalId);
            // refund the submitter 
            Bank.bank_payment(recipient = proposal.submittedBy, tokenAddress = onboard_params.tributeAddress, amount = onboard_params.tributeOffered);
            // update bank accounting 
            Bank.decrease_userTokenBalances(userAddress= Bank.ESCROW, tokenAddress=onboard_params.tributeAddress, amount=onboard_params.tributeOffered);
            Bank.decrease_userTokenBalances(userAddress= Bank.TOTAL, tokenAddress=onboard_params.tributeAddress, amount=onboard_params.tributeOffered);
            return (TRUE,);
        }
        if (proposal.type == 'Swap'){
            let (local swap_params: SwapParams) = Swap.get_swapParams(proposalId);
            // refund the submitter 
            Bank.bank_payment(recipient = proposal.submittedBy, tokenAddress = swap_params.tributeAddress, amount = swap_params.tributeOffered);
            // update bank accounting 
            Bank.decrease_userTokenBalances(userAddress= Bank.ESCROW, tokenAddress=swap_params.tributeAddress, amount=swap_params.tributeOffered);
            Bank.decrease_userTokenBalances(userAddress= Bank.TOTAL, tokenAddress=swap_params.tributeAddress, amount=swap_params.tributeOffered);
            return (TRUE,);
        }
        return (TRUE,);
    }
    // if the proposal status is ACCEPTED or FORCED, the below expression is equal to zero
    let should_pass = (proposal.status - Proposal.ACCEPTED) * (proposal.status - Proposal.FORCED);
    with_attr error_message("The proposal status should be ACCEPTED or FORCED.") {
        assert should_pass = 0;
    }
    
    // TODO monter cette partie plus haut
    // assert the grace period ended
    let (local today_timestamp) = get_block_number();
    with_attr error_message("The proposal has not ended grace period.") {
        if (proposal.status == Proposal.ACCEPTED){
        assert_lt(
            proposal.submittedAt + params.votingDuration + params.graceDuration, today_timestamp
        );
        } else{
        // if the proposal status is FORCED, ignore voting duration
        assert_lt(
            proposal.submittedAt + params.graceDuration, today_timestamp
        );
        }
    }
    // execute action
    if (proposal.type == 'Onboard'){
        Actions.execute_onboard(proposalId);
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        return (TRUE,);
    }
    if (proposal.type == 'GuildKick'){
        Actions.execute_guildkick(proposalId);
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        return (TRUE,);
    }
    if (proposal.type == 'ApproveToken'){
        Actions.execute_approve_token(proposalId);
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        return (TRUE,);
    }
    if (proposal.type == 'RemoveToken'){
        Actions.execute_remove_token(proposalId);
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        return (TRUE,);
    }
    if (proposal.type == 'Swap'){
        Actions.execute_swap(proposalId);
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        return (TRUE,);
    }
    if (proposal.type == 'Signaling'){
        Actions.execute_signaling(proposalId);
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        return (TRUE,);
    }

    return (TRUE,);
}
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
from tally import Tally, tally

namespace Actions {

    func execute_onboard{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        alloc_locals;
        let (local params: OnboardParams) = Onboard.get_onBoardParams(proposalId);

        let (onboardedAt) = get_block_number();
        let member_: MemberInfo = MemberInfo(address=params.address,
                                            delegateAddress=params.address,
                                            shares=params.shares,
                                            loot=params.loot,
                                            jailed=0,
                                            lastProposalYesVote=0,
                                            onboardedAt=onboardedAt);
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
                                                    delegateAddress=member_.delegateAddress,
                                                    shares=0,
                                                    loot=member_.loot+member_.shares,
                                                    jailed=TRUE,
                                                    lastProposalYesVote=member_.lastProposalYesVote,
                                                    onboardedAt=member_.onboardedAt);
        Member.update_member(updated_member);
        return (TRUE,);
    }
    
    func execute_whitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        let (params: TokenParams) = Tokens.get_tokenParams(proposalId);
        Bank.add_token(params.tokenAddress);
        return (TRUE,);
    }

    func execute_unwhitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
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

    // assert the caller is member
    let (local caller) = get_caller_address();
    Member.assert_is_member(caller);

    // assert the caller is not jailed
    Member.assert_not_jailed(caller);

    // launch the tally if the proposal status is SUBMITTED
    let (local status) = tally(proposalId);
    let (local proposal: ProposalInfo) = Proposal.get_info(proposalId);
    let (local params) = Proposal.get_params(proposal.type);
    

    // if the status is REJECTED refund the submitter and change proposal status to REJECTED
    if (status == Proposal.REJECTED){
        Proposal.update_status(proposalId,Proposal.REJECTED);
        if (proposal.type == 'Onboard'){
            let (local onboard_params: OnboardParams) = Onboard.get_onBoardParams(proposalId);
            // refund the submitter 
            Bank.bank_payment(recipient = proposal.submittedBy, tokenAddress = onboard_params.tributeAddress, amount = onboard_params.tributeOffered);
            // update bank accounting 
            Bank.decrease_userTokenBalances(userAddress=Bank.ESCROW, tokenAddress=onboard_params.tributeAddress, amount=onboard_params.tributeOffered);
            Bank.decrease_userTokenBalances(userAddress=Bank.TOTAL, tokenAddress=onboard_params.tributeAddress, amount=onboard_params.tributeOffered);
            return (TRUE,);
        }
        if (proposal.type == 'Swap'){
            let (local swap_params: SwapParams) = Swap.get_swapParams(proposalId);
            // refund the submitter 
            Bank.bank_payment(recipient = proposal.submittedBy, tokenAddress = swap_params.tributeAddress, amount = swap_params.tributeOffered);
            // update bank accounting 
            Bank.decrease_userTokenBalances(userAddress=Bank.ESCROW, tokenAddress=swap_params.tributeAddress, amount=swap_params.tributeOffered);
            Bank.decrease_userTokenBalances(userAddress=Bank.TOTAL, tokenAddress=swap_params.tributeAddress, amount=swap_params.tributeOffered);
            return (TRUE,);
        }
        return (TRUE,);
    }
    // assert the grace period ended
    let (local today_timestamp) = get_block_number();
    with_attr error_message("The proposal has not ended grace period.") {
        if (status == Proposal.ACCEPTED){
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
        Proposal.update_status(proposalId,Proposal.ACCEPTED);
        return (TRUE,);
    }
    if (proposal.type == 'GuildKick'){
        Actions.execute_guildkick(proposalId);
        Proposal.update_status(proposalId,Proposal.ACCEPTED);
        return (TRUE,);
    }
    if (proposal.type == 'Whitelist'){
        Actions.execute_whitelist(proposalId);
        Proposal.update_status(proposalId,Proposal.ACCEPTED);
        return (TRUE,);
    }
    if (proposal.type == 'UnWhitelist'){
        Actions.execute_unwhitelist(proposalId);
        Proposal.update_status(proposalId,Proposal.ACCEPTED);
        return (TRUE,);
    }
    if (proposal.type == 'Swap'){
        Actions.execute_swap(proposalId);
        Proposal.update_status(proposalId,Proposal.ACCEPTED);
        return (TRUE,);
    }
    if (proposal.type == 'Signaling'){
        Actions.execute_signaling(proposalId);
        Proposal.update_status(proposalId,Proposal.ACCEPTED);
        return (TRUE,);
    }

    return (TRUE,);
}
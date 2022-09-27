%lang starknet
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.math import assert_lt
from proposals.guildkick import Guildkick, GuildKickParams
from proposals.onboard import Onboard
from members import Member, MemberInfo
from proposals.order import Order, OrderParams
from proposals.tokens import Tokens, TokenParams
from proposals.library import Proposal, ProposalInfo
from bank import Bank, TotalSupply
// TODO later: Automate actions.
// Might need to call other contracts
// Might need its subdirectory

namespace Actions {

    func execute_onboard{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        let (params: MemberInfo) = Onboard.get_onBoardParams(proposalId);
        Member.add_member(params);
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
                                                    lastProposalYesVote=member_.lastProposalYesVote);
        Member.update(updated_member);

        // update the bank 
        let (guild_balance: TotalSupply) = Bank.get_totalSupply();
        let new_supply : TotalSupply = TotalSupply(shares=guild_balance.shares-member_.shares, 
                                                     loot=guild_balance.loot+member_.shares);
        Bank.set_totalSupply(new_supply);
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

    func execute_order{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        let (params: OrderParams) = Order.get_orderParams(proposalId);
        let (old_amount_tribute: felt) = Bank.get_tokenBalance(params.tributeAddress);
        let (old_amount_payment: felt) = Bank.get_tokenBalance(params.paymentAddress);
        Bank.set_tokenBalance(params.tributeAddress, params.tributeOffered + old_amount_tribute);
        Bank.set_tokenBalance(params.paymentAddress, params.paymentRequested + old_amount_payment);
        return (TRUE,);
    }
}

@external
func executeProposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt) {
    // Requires proposal to be accepted
    // Executes the proposal's actions if preconditions are satisfied
    // Modify Proposal status which is used by the front
    alloc_locals;
    let (local proposal: ProposalInfo) = Proposal.get_proposal_by_id(proposalId);
    let (local params) = Proposal.get_params(proposal.type);

    // assert the proposal is accepted
    with_attr error_message("The proposal should be accepted first.") {
        assert proposal.status = Proposal.ACCEPTED;
    }


    // assert the grace period ended
    let (local today_timestamp) = get_block_timestamp();
    with_attr error_message("The proposal has not ended grace period.") {
        assert_lt(
            proposal.submittedAt + params.votingDuration + params.graceDuration, today_timestamp
        );
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
    if (proposal.type == 'Order'){
        Actions.execute_order(proposalId);
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        return (TRUE,);
    }
    if (proposal.type == 'Signaling'){
        Actions.execute_signaling(proposalId);
        Proposal.update_status(proposalId,Proposal.EXECUTED);
        return (TRUE,);
    }

    // update proposal status
    return (TRUE,);
}
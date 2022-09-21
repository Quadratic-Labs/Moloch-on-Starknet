%lang starknet
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from proposals.guildkick import Guildkick, GuildKickParams
from proposals.onboard import Onboard
from members import Member, MemberInfo
from proposals.order import Order, OrderParams
from proposals.tokens import Tokens, TokenParams
from proposals.library import Proposal
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
        let (params: GuildKickParams) = Guildkick.get_guildKickParams(proposalId);
        let (member_: MemberInfo) = Member.get_info(params.memberAddress);
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
        let (new_supply : TotalSupply) = TotalSupply(shares=guild_balance.shares-member_.shares, 
                                                     loot=guild_balance.loot+member_.shares);
        Bank.set_get_totalSupply(new_supply);
        return (TRUE,);
    }
    
    func execute_approve_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        return (TRUE,);
    }

    func execute_remove_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        return (TRUE,);
    }

    func execute_signaling{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        return (TRUE,);
    }

    func execute_order{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(proposalId: felt) -> (success: felt){
        return (TRUE,);
    }
}

@external
func executeProposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
    // Requires proposal to be accepted
    // Executes the proposal's actions if preconditions are satisfied
    // Modify Proposal status which is used by the front
    return ();
}
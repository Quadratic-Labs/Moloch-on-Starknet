%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_le
from starkware.starknet.common.syscalls import get_caller_address

from members import Member, MemberInfo
from bank import Bank

@external
func ragequit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // check if the user is a member
    Member.assert_is_member(caller);
    
    // get the total shares and loot before udpating the member
    let (totalShares: felt) = Member.get_total_shares();
    let (totalLoot: felt) = Member.get_total_loot();
    let totalSharesAndLoot = totalShares + totalLoot;


    let (member_: MemberInfo) = Member.get_info(caller);
    let member_updated: MemberInfo = MemberInfo(
        address=caller,
        delegatedKey=member_.delegatedKey,
        shares=0,
        loot=0,
        jailed=member_.jailed,
        lastProposalYesVote=member_.lastProposalYesVote,
        onBoarddedAt = member_.onBoarddedAt

    );
    // execute the transaction
    Member.update_member(member_updated);
    
    // update the bank
    let memberSharesAndLoot = member_.shares + member_.loot;
    Bank.update_guild_quit(memberAddress=caller, memberSharesAndLoot=memberSharesAndLoot, totalSharesAndLoot=totalSharesAndLoot);
    return (TRUE,);
}

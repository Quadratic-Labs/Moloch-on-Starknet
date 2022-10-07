%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_le
from starkware.starknet.common.syscalls import get_caller_address

from members import Member, MemberInfo
from bank import Bank

@external
func ragequit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    shares: felt, loot: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // check if the user is a member
    Member.assert_is_member(caller);
    let (member_: MemberInfo) = Member.get_info(caller);

    // assert enough shares
    with_attr error_message("Not enough shares") {
        assert_le(shares, member_.shares);
    }

    // assert enough loot
    with_attr error_message("Not enough loot") {
        assert_le(loot, member_.loot);
    }

    let member_updated: MemberInfo = MemberInfo(
        address=caller,
        delegatedKey=member_.delegatedKey,
        shares=member_.shares - shares,
        loot=member_.loot - loot,
        jailed=member_.jailed,
        lastProposalYesVote=member_.lastProposalYesVote,
    );
    // execute the transaction
    Member.update_member(member_updated);

    //TODO update the bank
    return (TRUE,);
}

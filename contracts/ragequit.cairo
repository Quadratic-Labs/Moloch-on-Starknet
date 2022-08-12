%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_le
from starkware.starknet.common.syscalls import get_caller_address
from contracts.members import Member, membersInfo

@external
func ragequit{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(user: felt, shares: felt, loot: felt) -> (success: felt):
    # check if the user is a member
    Member.assert_is_member(user)
    let (member_: Member.InfoMember) = Member.get_info_members(user)
    
    # assert the caller is the ragequitter
    #TODO determine if we keep this part
    let (caller) = get_caller_address()
    with_attr error_message("Can not call a ragequit for another member"):
            assert user = caller
    end

    # assert enough shares
    with_attr error_message("Not enough shares"):
            assert_le(shares, member_.shares)
    end

    # assert enough loot
    with_attr error_message("Not enough loot"):
            assert_le(loot, member_.loot)
    end

    let member_updated: Member.InfoMember = Member.InfoMember(
                                                                address=member_.address,
                                                                accountKey=member_.accountKey,
                                                                shares=member_.shares - shares,
                                                                loot=member_.loot - loot,
                                                                jailed=member_.jailed,
                                                                lastProposalYesVote=member_.lastProposalYesVote
                                                                )
    # execute the transaction
    membersInfo.write(user,member_updated)
    return (TRUE)
end

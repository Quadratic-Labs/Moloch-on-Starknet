%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from members import Member, MemberInfo

@view
func Member_is_member_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (success: felt) {
    return Member.is_member(address);
}

@view
func Member_assert_is_member_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> () {
    return Member.assert_is_member(address);
}

@view
func Member_assert_is_not_member_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) -> () {
    return Member.assert_is_not_member(address);
}

@view
func Member_assert_within_bounds_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt) -> () {
    return Member.assert_within_bounds(id);
}

@view
func Member_is_jailed_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (res: felt) {
    return Member.is_jailed(address);
}

@view
func Member_assert_not_jailed_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) -> () {
    return Member.assert_not_jailed(address);
}

@view
func Member_get_info_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (member_: MemberInfo) {
    return Member.get_info(address);
}

@view
func Member_total_count_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) -> (length: felt) {
    return Member.total_count();
}

@external
func Member_add_member_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    info: MemberInfo
) -> () {
    return Member.add_member(info);
}

@external
func Member_update_member_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    info: MemberInfo
) -> () {
    return Member.update_member(info);
}

@view
func Member_get_total_shares_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(until_this_block_number : felt
    ) -> (count: felt) {
    return Member.get_total_shares(until_this_block_number);
}

@view
func Member_get_total_loot_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) -> (count: felt) {
    return Member.get_total_loot();
}

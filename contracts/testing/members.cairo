%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from members import Member


@external
func Member_is_member_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) -> (success: felt) {
    return Member.is_member(address);
}

@external
func Member_assert_is_member_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) -> () {
    return Member.assert_is_member(address);
}

@external
func Member_assert_is_not_member_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) -> () {
    return Member.assert_is_not_member(address);
}

@external
func Member_assert_within_bounds_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt) -> () {
    return Member.assert_within_bounds(id);
}

@external
func Member_is_jailed_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) -> (res: felt) {
    return Member.is_jailed(address);
}

@external
func Member_assert_not_jailed_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) -> () {
    return Member.assert_not_jailed(address);
}

@external
func Member_get_address_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt) -> (address: felt) {
    return Member.get_address(id);
}

@external
func Member_get_info_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) -> (member_: Member.Info) {
    return Member.get_info(address);
}

@external
func Member_total_count_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() -> (length: felt) {
    return Member.total_count();
}

@external
func Member_add_new_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(info: Member.Info) -> () {
    return Member.add_new(info);
}

@external
func Member_update_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(info: Member.Info) -> () {
    return Member.update(info);
}

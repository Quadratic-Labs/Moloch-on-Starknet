%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

from roles import Roles

@external
func Roles__grant_role_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user: felt, role: felt
) {
    return Roles._grant_role(user, role);
}

@external
func Roles__revoke_role_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user: felt, role: felt
) {
    return Roles._revoke_role(user, role);
}

@view
func Roles_has_role_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user: felt, role: felt
) -> (has_role: felt) {
    return Roles.has_role(user, role);
}

@view
func Roles_require_role_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    role: felt
) {
    return Roles.require_role(role);
}

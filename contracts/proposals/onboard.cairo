%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from roles import Roles


@external
func submitOnboard{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(user: felt, shares: felt, loot: felt) -> ():
    Roles.require_role('admin')
    return ()
end

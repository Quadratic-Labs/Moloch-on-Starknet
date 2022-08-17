%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
# from contracts.roles import Roles
from roles import Roles

@external
func submitApproveToken{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(tokenAddress: felt) -> (success: felt):
    # Requires Admin
    # Roles.require_role('admin')
    return (FALSE)
end

@external
func submitRemoveToken{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(tokenAddress: felt) -> (success: felt):
    # Requires Admin
    return (FALSE)
end

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin


@external
func submitApproveToken{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(tokenAddress: felt) -> (success: felt):
    # Requires Admin
    return (1)
end

@external
func submitRemoveToken{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(tokenAddress: felt) -> (success: felt):
    # Requires Admin
    return (1)
end

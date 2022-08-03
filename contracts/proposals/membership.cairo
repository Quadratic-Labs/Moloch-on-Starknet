%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin


@external
func submitOnboard{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(memberAddress: felt, shares: felt, loot: felt) -> ():
    # Requires Admin
    return ()
end

@external
func submitGuildKick{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(memberAddress: felt) -> ():
    # requires governor
    return ()
end

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin


@external
func submitGuildKick{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(memberAddress: felt) -> ():
    # requires governor
    return ()
end

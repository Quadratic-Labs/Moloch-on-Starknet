%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin


@external
func submitOrder{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}() -> ():
    # requires governor
    return ()
end

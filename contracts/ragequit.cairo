%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin


@external
func ragequit{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}() -> ():
    return ()
end

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address

from roles import Roles


@external
func submitOnboard{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(address: felt, accountKey: felt, shares: felt, loot: felt) -> (success : felt):
    Roles.require_role('admin')
    # add_proposal(info: Info)
    # let (caller) = get_caller_address()
    return (FALSE)
end

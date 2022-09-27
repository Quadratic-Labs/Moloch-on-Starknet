%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from bank import Bank

@external
func Bank_assert_token_whitelisted_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) {
        return Bank.assert_token_whitelisted(tokenAddress);
    }

@external
func Bank_assert_token_not_whitelisted_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(tokenAddress: felt) {
    return Bank.assert_token_not_whitelisted(tokenAddress);
}
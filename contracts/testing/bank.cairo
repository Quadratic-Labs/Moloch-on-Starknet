%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

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

@external
func Bank_bank_deposit_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt, amount: Uint256
    )-> (success: felt){   
    return Bank.bank_deposit(tokenAddress,amount);
}
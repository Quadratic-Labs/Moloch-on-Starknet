%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from bank import Bank

@view
func Bank_get_userTokenBalances_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(userAddress: felt, tokenAddress: felt) -> (amount: Uint256) {
    return Bank.get_userTokenBalances(userAddress, tokenAddress);
}

@external
func Bank_set_userTokenBalances_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(userAddress: felt, tokenAddress: felt, amount: Uint256) -> () {
    return Bank.set_userTokenBalances(userAddress, tokenAddress, amount);
}

@view
func Bank_assert_token_whitelisted_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(tokenAddress: felt) {
    return Bank.assert_token_whitelisted(tokenAddress);
}

@view
func Bank_assert_token_not_whitelisted_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(tokenAddress: felt) {
    return Bank.assert_token_not_whitelisted(tokenAddress);
}

@external
func Bank_bank_deposit_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt, amount: Uint256
) -> (success: felt) {
    return Bank.bank_deposit(tokenAddress, amount);
}

@view
func Bank_is_token_whitelisted_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(tokenAddress: felt) -> (res: felt) {
    return Bank.is_token_whitelisted(tokenAddress);
}

@external
func Bank_increase_userTokenBalances_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(userAddress: felt, tokenAddress: felt, amount: Uint256) -> () {
    return Bank.increase_userTokenBalances(userAddress, tokenAddress, amount);
}

@external
func Bank_decrease_userTokenBalances_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(userAddress: felt, tokenAddress: felt, amount: Uint256) -> () {
    return Bank.decrease_userTokenBalances(userAddress, tokenAddress, amount);
}

@external
func Bank_add_token_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt
) {
    return Bank.add_token(tokenAddress);
}

@external
func Bank_remove_token_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt
) {
    return Bank.remove_token(tokenAddress);
}

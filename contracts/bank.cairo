%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_lt
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.security.safemath.library import SafeUint256
from roles import Roles
// TODO transform this to functions
struct TotalSupply{
    shares: felt,
    loot: felt,
}

@storage_var
func totalSupply() -> (supply: TotalSupply) {
}


@storage_var
func userTokenBalances(userAddress: felt, tokenAddress: felt) -> (amount: Uint256) {
}



@storage_var
func whitelistedTokens(tokenAddress: felt) -> (whitelisted: felt) {
}

@external
func adminDeposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt, amount: Uint256
)->(success: felt) {
    //assert the caller has admin role
    Roles.require_role('admin');

    Bank.bank_deposit(tokenAddress, amount);
    return (TRUE,);
}

namespace Bank{

    func get_totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) -> (supply: TotalSupply) {
        let (supply: TotalSupply) = totalSupply.read();
        return (supply,);
    }

    func set_totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        supply: TotalSupply    
    ) -> () {
        totalSupply.write(supply);
        return ();
    }

    func bank_deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt, amount: Uint256
    ) -> (success: felt){   
        alloc_locals;
        // transfert token
        let (local bank_address: felt) = get_contract_address();
        let (local caller: felt) = get_caller_address();
        //TODO double check with Thomas if the below line is correct
        IERC20.transferFrom(contract_address=tokenAddress,sender=caller, recipient=bank_address, amount=amount);
        // update guild balance
        let (current_balance: Uint256) = get_userTokenBalances(userAddress=bank_address, tokenAddress=tokenAddress);
        let (new_balance: Uint256) = SafeUint256.add(current_balance, amount);
        set_userTokenBalances(userAddress=bank_address, tokenAddress=tokenAddress, amount=new_balance);
        return (TRUE,);
    }


    func get_userTokenBalances{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        userAddress: felt, tokenAddress: felt
    ) -> (amount: Uint256) {
        let (amount: Uint256) = userTokenBalances.read(userAddress, tokenAddress);
        return (amount,);
    }

    func set_userTokenBalances{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        userAddress: felt, tokenAddress: felt, amount: Uint256    
    ) -> () {
        userTokenBalances.write(userAddress, tokenAddress, amount);
        return ();
    }

    func assert_sufficient_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt, amount: felt
    ) -> () {
        let (balance: amount) = get_userTokenBalances(tokenAddress);
        with_attr error_message("Requesting more tokens as payment than the available guild bank balance") {
            assert_lt(amount, balance);
        }
        return ();
    }
    func assert_token_whitelisted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) {
        with_attr error_message("Token {tokenAddress} is not whitelisted") {
            let (res) = whitelistedTokens.read(tokenAddress);
            assert res = TRUE;
        }
        return ();
    }

    func assert_token_not_whitelisted{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(tokenAddress: felt) {
        with_attr error_message("Token {tokenAddress} is already whitelisted") {
            let (res) = whitelistedTokens.read(tokenAddress);
            assert res = FALSE;
        }
        return ();
    }

    func add_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) {
        assert_token_not_whitelisted(tokenAddress);
        whitelistedTokens.write(tokenAddress, TRUE);
        return ();
    }

    func remove_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) {
        assert_token_whitelisted(tokenAddress);
        whitelistedTokens.write(tokenAddress, FALSE);
        return ();
    }
}
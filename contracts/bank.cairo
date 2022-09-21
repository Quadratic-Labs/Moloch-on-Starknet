%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_lt

struct TotalSupply{
    shares: felt,
    loot: felt,
}

@storage_var
func totalSupply() -> (supply: TotalSupply) {
}


@storage_var
func tokenBalance(tokenAddress: felt) -> (amount: felt) {
}



@storage_var
func whitelistedTokens(tokenAddress: felt) -> (whitelisted: felt) {
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


    func get_tokenBalance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) -> (amount: felt) {
        let (amount: felt) = tokenBalance.read(tokenAddress);
        return (amount);
    }

    func set_tokenBalance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt, amount: felt    
    ) -> () {
        tokenBalance.write(tokenAddress, amount);
        return ();
    }

    func assert_sufficient_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt, amount: felt
    ) -> () {
        let (balance: felt) = get_tokenBalance(tokenAddress);
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
        with_attr error_message("Token {tokenAddress} is not whitelisted") {
            let (res) = whitelistedTokens.read(tokenAddress);
            assert res = FALSE;
        }
        return ();
    }

    func add_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) {
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
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_lt
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_le
from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.security.safemath.library import SafeUint256


from roles import Roles


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
    //whitelist token if not already whitelisted
    let (whitelisted: felt) = Bank.is_token_whitelisted(tokenAddress);
    if (whitelisted == FALSE){
        Bank.add_token(tokenAddress);
        // tempvar to avoid revoked references
        tempvar syscall_ptr = syscall_ptr;
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar range_check_ptr = range_check_ptr;
    }else{
        tempvar syscall_ptr = syscall_ptr;
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar range_check_ptr = range_check_ptr;
    }
    Bank.bank_deposit(tokenAddress, amount);
    return (TRUE,);
}

namespace Bank{
    const GUILD = 0xaaa;
    const ESCROW = 0xbbb;
    const TOTAL = 0xccc;
    const LOOTADRESS = 0xddd;


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

    func increase_userTokenBalances{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        userAddress: felt, tokenAddress: felt, amount: Uint256    
    ) -> () {

        let (current_balance: Uint256) = get_userTokenBalances(userAddress=userAddress, tokenAddress=tokenAddress);
        let (new_balance: Uint256) = SafeUint256.add(current_balance, amount);
        set_userTokenBalances(userAddress=userAddress, tokenAddress=tokenAddress, amount=new_balance);
        return ();
    }    
    
    func decrease_userTokenBalances{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        userAddress: felt, tokenAddress: felt, amount: Uint256    
    ) -> () {
            let (current_balance: Uint256) = get_userTokenBalances(userAddress=userAddress, tokenAddress=tokenAddress);
        let (new_balance: Uint256) = SafeUint256.sub_le(current_balance, amount);
        set_userTokenBalances(userAddress=userAddress, tokenAddress=tokenAddress, amount=new_balance);
        return ();
    }

    func bank_deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt, amount: Uint256
    ) -> (success: felt){   
        alloc_locals;
        // assert token is whitelisted
        assert_token_whitelisted(tokenAddress);
        // transfert token
        let (local bank_address: felt) = get_contract_address();
        let (local caller: felt) = get_caller_address();
        //TODO double check with Thomas if the below line is correct
        IERC20.transferFrom(contract_address=tokenAddress,sender=caller, recipient=bank_address, amount=amount);
        return (TRUE,);
    }

    func bank_payment{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        recipient: felt, tokenAddress: felt, amount: Uint256
    ) -> (success: felt){   
        alloc_locals;
        // transfert token
        let (local bank_address: felt) = get_contract_address();
        //TODO double check with Thomas if the below line is correct
        IERC20.transferFrom(contract_address=tokenAddress, sender=bank_address, recipient=recipient, amount=amount);
        return (TRUE,);
    }

    func assert_sufficient_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt, amount: Uint256
    ) -> () {
        let (bank_address: felt) = get_contract_address();

        let (balance: Uint256) = get_userTokenBalances(userAddress=bank_address, tokenAddress=tokenAddress);
        let (is_le) = uint256_le(amount, balance);
        with_attr error_message("Requesting more tokens as payment than the available guild bank balance") {
            assert is_le = TRUE;
        }
        return ();
    }

    func is_token_whitelisted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) -> (res: felt){
        let (whitelisted) = whitelistedTokens.read(tokenAddress);
        if (whitelisted == TRUE){
            return (TRUE,);
        }
        return (FALSE,);
    }


    func assert_token_whitelisted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) {
        with_attr error_message("Token {tokenAddress} is not whitelisted") {
            let (res) = is_token_whitelisted(tokenAddress);
            assert res = TRUE;
        }
        return ();
    }

    func assert_token_not_whitelisted{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(tokenAddress: felt) {
        with_attr error_message("Token {tokenAddress} is already whitelisted") {
            let (res) = is_token_whitelisted(tokenAddress);
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
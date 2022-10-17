%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_lt
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_le, uint256_eq
from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.security.safemath.library import SafeUint256
from starkware.cairo.common.math import split_felt
from roles import Roles
from members import Member
@event
func IncreaseUserTokenBalance(memberAddress: felt, tokenAddress: felt, amount : Uint256) {
}

@event
func DecreaseUserTokenBalance(memberAddress: felt, tokenAddress: felt, amount : Uint256) {
}

@event
func TokenWhitelisted(tokenAddress: felt) {
}

@event
func TokenUnWhitelisted(tokenAddress: felt) {
}



@storage_var
func userTokenBalances(userAddress: felt, tokenAddress: felt) -> (amount: Uint256) {
}

@storage_var
func whitelistedTokens(tokenAddress: felt) -> (whitelisted: felt) {
}

@storage_var
func whitelistedTokensIndexes(index: felt) -> (tokenAddress: felt) {
}

@storage_var
func whitelistedTokensLength() -> (lenght: felt) {
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

@external
func withdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt, amount: Uint256
)->(success: felt) {
    alloc_locals;
    let (local caller: felt) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert enough balance
    Bank.assert_sufficient_balance(userAddress=caller, tokenAddress=tokenAddress, amount=amount);
    // transfer money
    let (bank_address: felt) = get_contract_address();
    IERC20.transferFrom(contract_address=tokenAddress,sender=bank_address, recipient=caller, amount=amount);
    // update accounting
    Bank.decrease_userTokenBalances(userAddress=caller, tokenAddress=tokenAddress, amount=amount);
    return (TRUE,);
}

namespace Bank{
    const GUILD = 0xAAA;
    const ESCROW = 0xBBB;
    const TOTAL = 0xCCC;


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
        IncreaseUserTokenBalance.emit(memberAddress=userAddress, tokenAddress=tokenAddress, amount=amount);
        return ();
    }    
    
    func decrease_userTokenBalances{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        userAddress: felt, tokenAddress: felt, amount: Uint256    
    ) -> () {
        let (current_balance: Uint256) = get_userTokenBalances(userAddress=userAddress, tokenAddress=tokenAddress);
        let (new_balance: Uint256) = SafeUint256.sub_le(current_balance, amount);
        set_userTokenBalances(userAddress=userAddress, tokenAddress=tokenAddress, amount=new_balance);
        DecreaseUserTokenBalance.emit(memberAddress=userAddress, tokenAddress=tokenAddress, amount=amount);
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
        IERC20.transferFrom(contract_address=tokenAddress,sender=caller, recipient=bank_address, amount=amount);
        return (TRUE,);
    }

    func bank_payment{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        recipient: felt, tokenAddress: felt, amount: Uint256
    ) -> (success: felt){   
        alloc_locals;
        // transfert token
        let (local bank_address: felt) = get_contract_address();
        IERC20.transferFrom(contract_address=tokenAddress, sender=bank_address, recipient=recipient, amount=amount);
        return (TRUE,);
    }

    func assert_sufficient_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        userAddress: felt, tokenAddress: felt, amount: Uint256
    ) -> () {

        let (balance: Uint256) = get_userTokenBalances(userAddress=userAddress, tokenAddress=tokenAddress);
        let (is_le) = uint256_le(amount, balance);
        with_attr error_message("Requesting more tokens available") {
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
        alloc_locals;
        assert_token_not_whitelisted(tokenAddress);
        let (local length) = whitelistedTokensLength.read();
        whitelistedTokensIndexes.write(length,tokenAddress); 
        whitelistedTokens.write(tokenAddress, TRUE);
        whitelistedTokensLength.write(length+1); 
        TokenWhitelisted.emit(tokenAddress=tokenAddress);
        return ();
    }

    func remove_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenAddress: felt
    ) {
        assert_token_whitelisted(tokenAddress);
        whitelistedTokens.write(tokenAddress, FALSE);
        TokenUnWhitelisted.emit(tokenAddress=tokenAddress);

        return ();
    }

    func _prorata{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        balance: Uint256 , memberSharesAndLoot: felt, totalSharesAndLoot: felt
    ) -> (amount: Uint256) {
        alloc_locals;
        let (local memberSharesAndLoot_high, local memberSharesAndLoot_low) = split_felt(memberSharesAndLoot);
        local memberSharesAndLoot_uint256: Uint256 = Uint256(memberSharesAndLoot_low, memberSharesAndLoot_high);
        let (local totalSharesAndLoot_high, local totalSharesAndLoot_low) = split_felt(totalSharesAndLoot);
        local totalSharesAndLoot_uint256: Uint256 = Uint256(totalSharesAndLoot_low, totalSharesAndLoot_high);
        let (are_equals:felt) = uint256_eq(balance, Uint256(0, 0));
        if (are_equals == 1){ 
            return (Uint256(0, 0),); 
        }
        let (local prod: Uint256) = SafeUint256.mul(balance, memberSharesAndLoot_uint256);
        let (local quotient: Uint256, remainder: Uint256) = SafeUint256.div_rem(prod, totalSharesAndLoot_uint256); 
        return (quotient,);
    }


    func _update_guild_quit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        memberAddress: felt, memberSharesAndLoot: felt, totalSharesAndLoot: felt, current_position: felt
    ) ->() {
        alloc_locals;
        let (length: felt) = whitelistedTokensLength.read();
        if (current_position == length){
            return ();
        }
        let (current_token: felt) = whitelistedTokensIndexes.read(current_position);
        // get the balance of the current token in the guild
        let (balance: Uint256) = get_userTokenBalances(userAddress=GUILD, tokenAddress=current_token);
        
        let (prorata: Uint256) = _prorata(balance=balance, memberSharesAndLoot=memberSharesAndLoot, totalSharesAndLoot=totalSharesAndLoot);

        increase_userTokenBalances(userAddress=memberAddress, tokenAddress=current_token, amount=prorata);
        decrease_userTokenBalances(userAddress=GUILD, tokenAddress=current_token, amount=prorata);
        decrease_userTokenBalances(userAddress=TOTAL, tokenAddress=current_token, amount=prorata);
        return _update_guild_quit(memberAddress, memberSharesAndLoot, totalSharesAndLoot, current_position+1);
    }

    func update_guild_quit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        memberAddress: felt, memberSharesAndLoot: felt, totalSharesAndLoot: felt
    ){
        return _update_guild_quit(memberAddress, memberSharesAndLoot, totalSharesAndLoot, current_position=0);
    }
}
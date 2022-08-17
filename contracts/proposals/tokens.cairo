%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address
from roles import Roles
from members import Member
from proposals.library import Proposal
# from roles import Roles



@external
func submitApproveToken{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(tokenAddress: felt) -> (success: felt):

    alloc_locals
    let (local caller) = get_caller_address()
    # assert the caller is member
    Member.assert_is_member(caller)
    # assert the caller is admin
    Roles.require_role('admin')
    # assert the token is not already whitelisted
    Token.assert_token_whitelisted(tokenAddress)

    # record the proposal
    let (id) = Proposal.get_proposals_length()
    let type = 'approveToken'
    # TODO update with the appropriate information
    let submittedBy = caller
    let submittedAt = 0 
    let votingEndsAt = 0 
    let graceEndsAt = 0
    let expiresAt = 0
    let quorum = 0
    let majority = 0 
    let yesVotes = 0
    let noVotes = 0
    let status = 1
    let description = 0
    let proposal: Proposal.Info = Proposal.Info(
                                                id=id,
                                                type=type,
                                                submittedBy=submittedBy,
                                                submittedAt=submittedAt,
                                                votingEndsAt=votingEndsAt,
                                                graceEndsAt=graceEndsAt,
                                                expiresAt=expiresAt,
                                                quorum=quorum,
                                                majority=majority,
                                                yesVotes=yesVotes,
                                                noVotes=noVotes,
                                                status=status,
                                                description=description
                                                )
    
    Proposal.add_proposal(proposal)
    return (TRUE)
end

@external
func submitRemoveToken{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(tokenAddress: felt) -> (success: felt):
    alloc_locals
    let (local caller) = get_caller_address()
    # assert the caller is member
    Member.assert_is_member(caller)
    # assert the caller is admin
    Roles.require_role('admin')
    # assert the token is whitelisted
    Token.assert_token_not_whitelisted(tokenAddress)
    # check the token is ERC20 or ERC721.
    # TODO to complete

    # record the proposal
    let (id) = Proposal.get_proposals_length()
    let type = 'removeToken'
    # TODO update with the appropriate information
    let submittedBy = caller
    let submittedAt = 0 
    let votingEndsAt = 0 
    let graceEndsAt = 0
    let expiresAt = 0
    let quorum = 0
    let majority = 0 
    let yesVotes = 0
    let noVotes = 0
    let status = 1
    let description = 0
    let proposal: Proposal.Info = Proposal.Info(
                                                id=id,
                                                type=type,
                                                submittedBy=submittedBy,
                                                submittedAt=submittedAt,
                                                votingEndsAt=votingEndsAt,
                                                graceEndsAt=graceEndsAt,
                                                expiresAt=expiresAt,
                                                quorum=quorum,
                                                majority=majority,
                                                yesVotes=yesVotes,
                                                noVotes=noVotes,
                                                status=status,
                                                description=description
                                                )
    
    Proposal.add_proposal(proposal)
    return (TRUE)
end


namespace Token:

    func assert_token_whitelisted{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(tokenAddress: felt):
        with_attr error_message("Token {tokenAddress} is not whitelisted"):
                let (res) = whitelistedTokens.read(tokenAddress)
                assert res = TRUE
        end
        return ()

    end    
    func assert_token_not_whitelisted{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(tokenAddress: felt):
        with_attr error_message("Token {tokenAddress} is not whitelisted"):
                let (res) = whitelistedTokens.read(tokenAddress)
                assert res = FALSE
        end
        return ()

    end

    func add_token{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
        }(tokenAddress : felt):
        whitelistedTokens.write(tokenAddress, TRUE)
        let (len) = whitelistedTokensLenght.read()
        whitelistedTokensLenght.write(len+1)
        return ()
    end


    func remove_token{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
        }(tokenAddress : felt):
        assert_token_whitelisted(tokenAddress)
        whitelistedTokens.write(tokenAddress, FALSE)
        return ()
    end


    func get_tokensLength{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
        }() -> (length: felt):
            let (length) = whitelistedTokensLenght.read()
            return (length)
    end

end

@storage_var
func whitelistedTokens(tokenAddress : felt) -> (whitelisted: felt):
end

@storage_var
func whitelistedTokensLenght() -> (length: felt):
end
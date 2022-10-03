%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_number
from roles import Roles
from members import Member
from proposals.library import Proposal, ProposalInfo
from bank import Bank
struct TokenParams {
    tokenAddress: felt,
    tokenName:felt,
}

@storage_var
func tokenParams(proposalId: felt) -> (params: TokenParams) {
}
namespace Tokens{
    func get_tokenParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (params: TokenParams) {
        let (params: TokenParams) = tokenParams.read(id);
        return (params,);
    }

    func set_tokenParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, params: TokenParams
    ) -> () {
        tokenParams.write(id, params);
        return ();
    }
}



@external
func submitApproveToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt,tokenName: felt, title:felt, description: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the token is not already whitelisted
    Bank.assert_token_not_whitelisted(tokenAddress);

    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'approveToken';
    let submittedBy = caller;
    let (submittedAt) = get_block_number();
    let status = 1;
    let proposal: ProposalInfo = ProposalInfo(
        id=id,
        title=title,
        type=type,
        submittedBy=submittedBy,
        submittedAt=submittedAt,
        status=status,
        description=description,
    );

    Proposal.add_proposal(proposal);
    // register params
    let params: TokenParams= TokenParams(tokenAddress=tokenAddress, tokenName=tokenName);
    Tokens.set_tokenParams(id, params);
    return (TRUE,);
}

@external
func adminApproveToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the token is not already whitelisted
    Bank.assert_token_not_whitelisted(tokenAddress);
    // add token
    Bank.add_token(tokenAddress);
    return (TRUE,);
}

@external
func submitRemoveToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt, tokenName: felt,title:felt, description: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the token is whitelisted
    Bank.assert_token_whitelisted(tokenAddress);
    // check the token is ERC20 or ERC721.
    // TODO to complete

    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'removeToken';
    let submittedBy = caller;
    let (submittedAt) = get_block_number();
    let status = 1;
    let proposal: ProposalInfo = ProposalInfo(
        id=id,
        title=title,
        type=type,
        submittedBy=submittedBy,
        submittedAt=submittedAt,
        status=status,
        description=description,
    );

    Proposal.add_proposal(proposal);
    // register params
    let params: TokenParams= TokenParams(tokenAddress=tokenAddress, tokenName=tokenName);
    Tokens.set_tokenParams(id, params);
    return (TRUE,);
}

@external
func adminRemoveToken{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the token is whitelisted
    Bank.assert_token_whitelisted(tokenAddress);
    // check the token is ERC20 or ERC721.
    // TODO to complete

    // remove token
    Bank.remove_token(tokenAddress);
    return (TRUE,);
}



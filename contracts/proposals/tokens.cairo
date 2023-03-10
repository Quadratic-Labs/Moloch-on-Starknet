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
    tokenName: felt,
}

@event
func WhitelistProposalAdded(id: felt, tokenName: felt, tokenAddress: felt) {
}

@event
func UnWhitelistProposalAdded(id: felt, tokenName: felt, tokenAddress: felt) {
}

@storage_var
func tokenParams(proposalId: felt) -> (params: TokenParams) {
}
namespace Tokens {
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
func submitWhitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt, tokenName: felt, title: felt, link: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is not jailed
    Member.assert_not_jailed(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the token is not already whitelisted
    Bank.assert_token_not_whitelisted(tokenAddress);

    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'Whitelist';
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
        link=link,
    );

    Proposal.add_proposal(proposal);
    // register params
    let params: TokenParams = TokenParams(tokenAddress=tokenAddress, tokenName=tokenName);
    Tokens.set_tokenParams(id, params);
    WhitelistProposalAdded.emit(id=id, tokenName=tokenName, tokenAddress=tokenAddress);
    return (TRUE,);
}

@external
func adminWhitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenName: felt, tokenAddress: felt
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
    Bank.add_token(tokenName, tokenAddress);
    return (TRUE,);
}

@external
func submitUnWhitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenAddress: felt, tokenName: felt, title: felt, link: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is not jailed
    Member.assert_not_jailed(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the token is whitelisted
    Bank.assert_token_whitelisted(tokenAddress);

    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'UnWhitelist';
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
        link=link,
    );

    Proposal.add_proposal(proposal);
    // register params
    let params: TokenParams = TokenParams(tokenAddress=tokenAddress, tokenName=tokenName);
    Tokens.set_tokenParams(id, params);
    UnWhitelistProposalAdded.emit(id=id, tokenName=tokenName, tokenAddress=tokenAddress);
    return (TRUE,);
}

@external
func adminUnWhitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenName: felt, tokenAddress: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the token is whitelisted
    Bank.assert_token_whitelisted(tokenAddress);

    // remove token
    Bank.remove_token(tokenName, tokenAddress);
    return (TRUE,);
}

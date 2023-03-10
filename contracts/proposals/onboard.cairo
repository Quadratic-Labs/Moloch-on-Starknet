%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_number

from roles import Roles
from members import Member, MemberInfo
from proposals.library import Proposal, ProposalInfo
from starkware.cairo.common.uint256 import Uint256
from bank import Bank

@event
func OnboardProposalAdded(
    id: felt,
    applicantAddress: felt,
    shares: felt,
    loot: felt,
    tributeOffered: Uint256,
    tributeAddress: felt,
) {
}

struct OnboardParams {
    address: felt,
    shares: felt,
    loot: felt,
    tributeOffered: Uint256,
    tributeAddress: felt,
}

@storage_var
func onBoardParams(proposalId: felt) -> (params: OnboardParams) {
}
namespace Onboard {
    func get_onBoardParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (params: OnboardParams) {
        let (params: OnboardParams) = onBoardParams.read(id);
        return (params,);
    }

    func set_onBoardParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, params: OnboardParams
    ) -> () {
        onBoardParams.write(id, params);
        return ();
    }
}

@external
func submitOnboard{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt,
    shares: felt,
    loot: felt,
    tributeOffered: Uint256,
    tributeAddress: felt,
    title: felt,
    link: felt,
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is not jailed
    Member.assert_not_jailed(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the submitted user is not a memeber
    Member.assert_is_not_member(address);
    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'Onboard';
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
    let params: OnboardParams = OnboardParams(
        address=address,
        shares=shares,
        loot=loot,
        tributeOffered=tributeOffered,
        tributeAddress=tributeAddress,
    );
    Onboard.set_onBoardParams(id, params);
    OnboardProposalAdded.emit(
        id=id,
        applicantAddress=address,
        shares=shares,
        loot=loot,
        tributeOffered=tributeOffered,
        tributeAddress=tributeAddress,
    );

    // veto the proposal,
    // TODO in future version make sure to execute the below line only if the caller is admin
    // Proposal.force_proposal(id);

    // collect tribute from proposer and store it in the Escrow until the proposal is processed
    Bank.bank_deposit(tokenAddress=tributeAddress, amount=tributeOffered);
    // update bank accounting
    Bank.increase_userTokenBalances(
        userAddress=Bank.ESCROW, tokenAddress=tributeAddress, amount=tributeOffered
    );
    Bank.increase_userTokenBalances(
        userAddress=Bank.TOTAL, tokenAddress=tributeAddress, amount=tributeOffered
    );
    return (TRUE,);
}

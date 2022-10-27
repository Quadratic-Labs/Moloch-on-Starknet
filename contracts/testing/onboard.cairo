%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_number

from roles import Roles
from members import Member, MemberInfo
from proposals.library import Proposal, ProposalInfo
from starkware.cairo.common.uint256 import Uint256
from bank import Bank
from proposals.onboard import OnboardParams, Onboard
// duplicate of submit onboard without bank transfer
@external
func Onboard_submitOnboard_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt,
    shares: felt,
    loot: felt,
    tributeOffered: Uint256,
    tributeAddress: felt,
    title: felt,
    description: felt,
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
        description=description,
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

    // veto the proposal,
    // TODO in future version make sure to execute the below line only if the caller is admin
    Proposal.force_proposal(id);

    // collect tribute from proposer and store it in the Escrow until the proposal is processed
    // update bank accounting
    Bank.increase_userTokenBalances(
        userAddress=Bank.ESCROW, tokenAddress=tributeAddress, amount=tributeOffered
    );
    Bank.increase_userTokenBalances(
        userAddress=Bank.TOTAL, tokenAddress=tributeAddress, amount=tributeOffered
    );
    return (TRUE,);
}

@external
func Onboard_set_onBoardParams_proxy{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt, params: OnboardParams) -> () {
    return Onboard.set_onBoardParams(id, params);
}

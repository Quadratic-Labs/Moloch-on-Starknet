%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp

from roles import Roles
from members import Member, MemberInfo
from proposals.library import Proposal, ProposalInfo




@storage_var
func onBoardParams(proposalId: felt) -> (params: MemberInfo) {
}

func get_onBoardParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt
) -> (params: MemberInfo) {
    let (params: MemberInfo) = onBoardParams.read(id);
    return (params,);
}

func set_onBoardParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt, params: MemberInfo
) -> () {
    onBoardParams.write(id, params);
    return ();
}

@external
func submitOnboard{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt, delegatedKey: felt, shares: felt, loot: felt, description: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is admin
    Roles.require_role('admin');
    // assert the submitted user is not a memeber
    Member.assert_is_not_member(address);
    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'Onboard';
    let submittedBy = caller;
    let (submittedAt) = get_block_timestamp();
    let yesVotes = 0;
    let noVotes = 0;
    let status = 1;
    let proposal: ProposalInfo = ProposalInfo(
        id=id,
        type=type,
        submittedBy=submittedBy,
        submittedAt=submittedAt,
        yesVotes=yesVotes,
        noVotes=noVotes,
        status=status,
        description=description,
    );

    Proposal.add_proposal(proposal);
    // register params
    let params: MemberInfo= MemberInfo(address=address, 
                                        delegatedKey=delegatedKey, 
                                        shares=shares, 
                                        loot=loot, 
                                        jailed=0, 
                                        lastProposalYesVote=0
                                        );
    set_onBoardParams(id, params);
    return (TRUE,);
}

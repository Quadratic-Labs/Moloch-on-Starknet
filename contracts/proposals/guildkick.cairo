%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_block_number
from members import Member
from roles import Roles
from proposals.library import Proposal, ProposalInfo


@event
func GuildKickProposalAdded(id:felt,memberAddress:felt) {
}



struct GuildKickParams {
    memberAddress: felt,
}

@storage_var
func guildKickParams(proposalId: felt) -> (params: GuildKickParams) {
}

namespace Guildkick{
    func get_guildKickParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (params: GuildKickParams) {
        let (params: GuildKickParams) = guildKickParams.read(id);
        return (params,);
    }

    func set_guildKickParams{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, params: GuildKickParams
    ) -> () {
        guildKickParams.write(id, params);
        return ();
    }
}



@external
func submitGuildKick{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(memberAddress: felt, title: felt,description: felt
) -> (success: felt) {
    alloc_locals;
    let (local caller) = get_caller_address();
    // assert the caller is member
    Member.assert_is_member(caller);
    // assert the caller is govern
    Roles.require_role('govern');
    // assert the submitted user is not a memeber
    Member.assert_is_member(memberAddress);
    // record the proposal
    let (id) = Proposal.get_proposals_length();
    let type = 'GuildKick';
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
    let params: GuildKickParams= GuildKickParams(memberAddress=memberAddress);
    Guildkick.set_guildKickParams(id, params);
    GuildKickProposalAdded.emit(id=id, memberAddress=memberAddress);

    return (TRUE,);
}

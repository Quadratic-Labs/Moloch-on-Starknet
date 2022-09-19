%lang starknet

from testing.members import (
    Member_is_member_proxy,
    Member_assert_is_member_proxy,
    Member_assert_is_not_member_proxy,
    Member_assert_within_bounds_proxy,
    Member_is_jailed_proxy,
    Member_assert_not_jailed_proxy,
    Member_get_info_proxy,
    Member_total_count_proxy,
    Member_add_new_proxy,
    Member_update_proxy
)

from testing.proposals import (
    Proposal_get_params_proxy,
    Proposal_set_params_proxy,
    Proposal_assert_within_bounds_proxy,
    Proposal_get_info_proxy,
    Proposal_search_position_by_id_proxy,
    Proposal_add_proposal_proxy,
    Proposal_update_status_proxy,
    Proposal_get_proposal_by_id_proxy,
    Proposal_update_proposal_proxy,
    Proposal_get_proposals_length_proxy,
    Proposal_get_vote_proxy,
    Proposal_set_vote_proxy
)

from testing.roles import (
    Roles__grant_role_proxy,
    Roles__revoke_role_proxy,
    Roles_has_role_proxy,
    Roles_require_role_proxy
)

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from actions import Actions
from members import Member
from proposals.library import Proposal, proposalParams, proposals
from proposals.onboard import submitOnboard
from proposals.guildkick import submitGuildKick
from proposals.order import submitOrder
from proposals.tokens import submitApproveToken, submitRemoveToken, Token
from ragequit import ragequit
from roles import Roles, grant_role, revoke_role, delegate_admin_role, adminRoles, membersRoles
from tally import launch_tally
from voting import Voting


@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    majority: felt, quorum: felt, votingDuration: felt, graceDuration: felt
) {
    alloc_locals;

    local params: Proposal.Params = Proposal.Params(majority, quorum, votingDuration, graceDuration);
    proposalParams.write('Onboard', params);
    proposalParams.write('GuildKick', params);
    proposalParams.write('ApproveToken', params);
    proposalParams.write('RemoveToken', params);
    proposalParams.write('Order', params);

    // add roles setup
    adminRoles.write('admin', 'admin');
    adminRoles.write('govern', 'admin');

    // Add deployer as a member
    local deployer: Member.Info = Member.Info(address=42, delegatedKey=42, shares=1, loot=50, jailed=0, lastProposalYesVote=0);
    Member.add_new(deployer);
    // Grant deployer admin privileges
    membersRoles.write(deployer.address, 'admin', TRUE);

    // add a whitelisted token
    Token.add_token(123);
    return ();
}

// SPX-Licence Proprietary
//
// DAO ....blah

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from actions import Actions
from members import Member, MemberInfo
from proposals.library import Proposal, proposalParams, proposals, ProposalParams
from proposals.onboard import submitOnboard
from proposals.guildkick import submitGuildKick
from proposals.order import submitOrder
from proposals.tokens import submitApproveToken, submitRemoveToken, Token
from ragequit import ragequit
from roles import Roles, grant_role, revoke_role, delegate_admin_role, adminRoles, membersRoles
from tally import launch_tally
from voting import submitVote


@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    majority: felt, quorum: felt, votingDuration: felt, graceDuration: felt
) {
    alloc_locals;

    local params: ProposalParams = ProposalParams(majority, quorum, votingDuration, graceDuration);
    proposalParams.write('Onboard', params);
    proposalParams.write('GuildKick', params);
    proposalParams.write('ApproveToken', params);
    proposalParams.write('RemoveToken', params);
    proposalParams.write('Order', params);

    // add roles setup
    adminRoles.write('admin', 'admin');
    adminRoles.write('govern', 'admin');

    // Add deployer as a member
    local deployer: MemberInfo = MemberInfo(address=42, delegatedKey=42, shares=1, loot=50, jailed=0, lastProposalYesVote=0);
    Member.add_new(deployer);
    // Grant deployer admin privileges
    membersRoles.write(deployer.address, 'admin', TRUE);

    // add a whitelisted token
    Token.add_token(123);
    return ();
}

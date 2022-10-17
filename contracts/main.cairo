// SPX-Licence Proprietary
//
// DAO ....blah

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from actions import Actions
from members import Member, MemberInfo, delegateVote, revokeDelegate
from proposals.library import Proposal, ProposalParams
from proposals.onboard import submitOnboard
from proposals.signaling import submitSignaling
from proposals.guildkick import submitGuildKick
from proposals.order import submitOrder
from proposals.tokens import submitApproveToken, submitRemoveToken, adminApproveToken, adminRemoveToken
from ragequit import ragequit
from roles import Roles, grant_role, revoke_role, delegate_admin_role, adminRoles, membersRoles, get_admin_role
from voting import submitVote
from bank import Bank, adminDeposit, withdraw
from actions import executeProposal

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    majority: felt, quorum: felt, votingDuration: felt, graceDuration: felt
) {
    alloc_locals;

    local params: ProposalParams = ProposalParams(majority, quorum, votingDuration, graceDuration);
    Proposal.set_params('Onboard', params);
    Proposal.set_params('GuildKick', params);
    Proposal.set_params('ApproveToken', params);
    Proposal.set_params('RemoveToken', params);
    Proposal.set_params('Order', params);
    local signaling_params: ProposalParams = ProposalParams(majority=50, quorum=80, votingDuration=0, graceDuration=5);
    Proposal.set_params('Signaling', signaling_params);

    // add roles setup
    adminRoles.write('admin', 'admin');
    adminRoles.write('govern', 'admin');

    // Add deployer as a member
    local deployer: MemberInfo = MemberInfo(address=42, delegatedKey=42, shares=1, loot=50, jailed=0, lastProposalYesVote=0);
    Member.add_member(deployer);
    // Grant deployer admin privileges
    membersRoles.write(deployer.address, 'admin', TRUE);

    // add a whitelisted token
    Bank.add_token(123);
    return ();
}

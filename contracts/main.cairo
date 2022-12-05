// SPX-Licence Proprietary
//
// DAO ....blah

%lang starknet

from starkware.starknet.common.syscalls import get_block_number
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from actions import Actions
from members import Member, MemberInfo, delegateVote, revokeDelegate
from proposals.library import Proposal, ProposalParams
from proposals.onboard import submitOnboard
from proposals.signaling import submitSignaling
from proposals.guildkick import submitGuildKick
from proposals.swap import submitSwap
from proposals.tokens import submitWhitelist, submitUnWhitelist, adminWhitelist, adminUnWhitelist
from ragequit import ragequit
from roles import Roles, grant_role, revoke_role, delegate_admin_role, adminRoles, membersRoles, get_admin_role
from voting import submitVote
from bank import Bank, adminDeposit, withdraw
from actions import executeProposal
from tally import tally

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    majority: felt, quorum: felt, votingDuration: felt, graceDuration: felt
) {
    alloc_locals;

    local params: ProposalParams = ProposalParams(majority, quorum, votingDuration, graceDuration);
    Proposal.set_params('Onboard', params);
    Proposal.set_params('GuildKick', params);
    Proposal.set_params('Whitelist', params);
    Proposal.set_params('UnWhitelist', params);
    Proposal.set_params('Swap', params);
    local signaling_params: ProposalParams = ProposalParams(majority=50, quorum=80, votingDuration=0, graceDuration=5);
    Proposal.set_params('Signaling', signaling_params);

    // add roles setup
    adminRoles.write('admin', 'admin');
    adminRoles.write('govern', 'admin');

    // Add deployer as a member
    let address = 42;
    let (onboardedAt) = get_block_number();
    local deployer: MemberInfo = MemberInfo(address=address, delegateAddress=address, shares=1, loot=50, jailed=0, lastProposalYesVote=0, onboardedAt=onboardedAt);
    Member.add_member(deployer);
    // Grant deployer admin privileges
    membersRoles.write(deployer.address, 'admin', TRUE);
    membersRoles.write(deployer.address, 'govern', TRUE);

    

    // add a whitelisted token
    Bank.add_token(123,123);
    return ();
}

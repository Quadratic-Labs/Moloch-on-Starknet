// SPX-Licence Proprietary
//
// DAO ....blah

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
    Member_add_member_proxy,
    Member_update_member_proxy,
    Member_get_total_shares_proxy,
    Member_get_total_loot_proxy,
)

from testing.proposals import (
    Proposal_get_params_proxy,
    Proposal_set_params_proxy,
    Proposal_get_info_proxy,
    Proposal_add_proposal_proxy,
    Proposal_update_status_proxy,
    Proposal_update_proposal_proxy,
    Proposal_get_proposals_length_proxy,
    Proposal_get_vote_proxy,
    Proposal_set_vote_proxy,
    Proposal_force_proposal_proxy,
    Proposal_get_proposal_status_proxy,
)

from testing.roles import (
    Roles__grant_role_proxy,
    Roles__revoke_role_proxy,
    Roles_has_role_proxy,
    Roles_require_role_proxy,
)
from testing.bank import (
    Bank_assert_token_not_whitelisted_proxy,
    Bank_assert_token_whitelisted_proxy,
    Bank_bank_deposit_proxy,
    Bank_is_token_whitelisted_proxy,
    Bank_increase_userTokenBalances_proxy,
    Bank_decrease_userTokenBalances_proxy,
    Bank_get_userTokenBalances_proxy,
    Bank_set_userTokenBalances_proxy,
    Bank_add_token_proxy,
    Bank_remove_token_proxy,
)
from testing.onboard import Onboard_submitOnboard_proxy, Onboard_set_onBoardParams_proxy
from testing.swap import Swap_submitSwap_proxy, Swap_set_swapParams_proxy
from testing.tally import Tally_get_total_votes_proxy, Tally__tally_proxy
from testing.tokens import Tokens_set_tokenParams_proxy
from testing.guildkick import Guildkick_set_guildKickParams_proxy
from testing.actions import Actions_executeProposal_proxy



from starkware.starknet.common.syscalls import get_block_number, get_caller_address
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
    local signaling_params: ProposalParams = ProposalParams(majority=50, quorum=80, votingDuration=5, graceDuration=5);
    Proposal.set_params('Signaling', signaling_params);

    // add roles setup
    adminRoles.write('admin', 'admin');
    adminRoles.write('govern', 'admin');

    // Add deployer as a member
    let address = 0x363B71D002935E7822EC0B1BAF02EE90D64F3458939B470E3E629390436510B;
    // let address = 42;
    let (onboardedAt) = get_block_number();
    local deployer: MemberInfo = MemberInfo(address=address, delegateAddress=address, shares=1, loot=50, jailed=0, lastProposalYesVote=0, onboardedAt=onboardedAt);
    Member.add_member(deployer);

    // Grant deployer admin privileges
    membersRoles.write(deployer.address, 'admin', TRUE);
    membersRoles.write(deployer.address, 'govern', TRUE);

    // add a whitelisted token
    let token = 0x62230EA046A9A5FBC261AC77D03C8D41E5D442DB2284587570AB46455FD2488;
    Bank.add_token('Fee Token', token);
    return ();
}

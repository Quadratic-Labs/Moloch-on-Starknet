%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE

from actions import Actions
from members import Member
from proposals.library import Proposal, proposalParams, proposals
from proposals.onboard import submitOnboard
from proposals.guildkick import submitGuildKick
from proposals.order import submitOrder
from proposals.tokens import submitApproveToken, submitRemoveToken,Token
from ragequit import ragequit
from roles import Roles, adminRoles, membersRoles
from tally import Tally
from voting import Voting

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
}(majority: felt, quorum: felt, votingDuration: felt, graceDuration: felt):
    alloc_locals
    
    local params: Proposal.Params = Proposal.Params(majority, quorum, votingDuration, graceDuration)
    proposalParams.write('Onboard', params)
    proposalParams.write('GuildKick', params)
    proposalParams.write('ApproveToken', params)
    proposalParams.write('RemoveToken', params)
    proposalParams.write('Order', params)

    # add roles setup
    adminRoles.write('admin','admin')
    adminRoles.write('govern','admin')

    # Add deployer as a member
    local deployer: Member.InfoMember = Member.InfoMember(address = 42, delegatedKey = 42, shares = 1, loot = 50, jailed = 0, lastProposalYesVote = 0 )
    Member.add_member(deployer)
    # Grant deployer admin privileges
    membersRoles.write(deployer.address, 'admin', TRUE)

    # add a whitelisted token
    Token.add_token(123)
    return ()
end

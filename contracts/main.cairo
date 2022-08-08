%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from actions import Actions
from members import Member
from proposals.library import Proposal, proposalParams, proposals
from proposals.onboard import submitOnboard
from proposals.guildkick import submitGuildKick
from proposals.order import submitOrder
from proposals.tokens import submitApproveToken, submitRemoveToken
from ragequit import ragequit
from roles import Roles
from rules import Rules
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
    return ()
end

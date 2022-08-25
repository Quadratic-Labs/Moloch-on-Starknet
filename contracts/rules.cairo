%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_caller_address

from starkware.cairo.common.math import  assert_lt

from proposals.library import Proposal, proposals
from members import Member

namespace Rules:
    # should accept returns if a proposal should be accepted or rejected based
    # on current votes by applying the DAO's acceptance rules
    func should_accept{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
    }(proposalId: felt) -> (accepted: felt):
        alloc_locals

        # get proposal's info if it exists, fails otherwise
        let (local info: Proposal.Info) = Proposal.get_info(proposalId)
        # check quorum
        let (quorum) = is_le(info.yesVotes+info.noVotes, info.quorum-1)
        if  quorum == 1:
            return (FALSE)
        end
        # check majority
        let (majority) = is_le(info.yesVotes, info.majority-1)
        if majority == 1:
            return (FALSE)
        end
        # check votes
        let (votes) = is_le(info.yesVotes,info.noVotes)
        if votes == 1:
            return (FALSE)
        end
        return (TRUE)
    end
        
    # apply will check if the proposal's grace period has ended, and move the
    # proposal to the next state, ACCEPTED/REJECTED.
    # TODO later: trigger actions.
    func apply{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
    }(proposalId: felt) -> (accepted: felt):
        # Apply voting rules to determine if proposal is accepted or rejected
        # Requires voting and grace period have ended
        # Modify Proposal status which is used by the front
        alloc_locals
        let (local info: Proposal.Info) = Proposal.get_info(proposalId)
        let (local caller) = get_caller_address()
        # assert the caller is member
        Member.assert_is_member(caller)
        local today_timestamp
        %{
            from datetime import datetime
            dt = datetime.now()
            ids.today_timestamp = int(datetime.timestamp(dt))
        %}
        assert_lt(info.graceEndsAt,today_timestamp)
        let (accepted: felt) = should_accept(proposalId)
        # TODO change the status of the proposal 
        return (accepted)
    end
end

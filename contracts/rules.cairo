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
        with_attr error_message("AccessControl: user {caller} is not a member."):
             Member.assert_is_member(caller)
        end
        
        local today_timestamp
        %{
            from datetime import datetime
            dt = datetime.now()
            ids.today_timestamp = int(datetime.timestamp(dt))
        %}
       
        # assert the gracePeriod ended 
        with_attr error_message("The proposal has not ended grace period."):
             assert_lt(info.graceEndsAt,today_timestamp)
        end

        # assert the votingEndsAt ended 
        with_attr error_message("The proposal has not ended voring period."):
             assert_lt(info.votingEndsAt,today_timestamp)
        end

        let (accepted: felt) = should_accept(proposalId)
        if accepted == FALSE:
            let proposal: Proposal.Info = Proposal.Info(
                                                    id=info.id,
                                                    type=info.type,
                                                    submittedBy=info.submittedBy,
                                                    submittedAt=info.submittedAt,
                                                    votingEndsAt=info.votingEndsAt,
                                                    graceEndsAt=info.graceEndsAt,
                                                    expiresAt=info.expiresAt,
                                                    quorum=info.quorum,
                                                    majority=info.majority,
                                                    yesVotes=info.yesVotes,
                                                    noVotes=info.noVotes,
                                                    status=Proposal.REJECTED,
                                                    description=info.description
                                                    )
            Proposal.update_proposal(info.id,proposal)
            return(accepted)
        end
        
        let proposal: Proposal.Info = Proposal.Info(
                                                    id=info.id,
                                                    type=info.type,
                                                    submittedBy=info.submittedBy,
                                                    submittedAt=info.submittedAt,
                                                    votingEndsAt=info.votingEndsAt,
                                                    graceEndsAt=info.graceEndsAt,
                                                    expiresAt=info.expiresAt,
                                                    quorum=info.quorum,
                                                    majority=info.majority,
                                                    yesVotes=info.yesVotes,
                                                    noVotes=info.noVotes,
                                                    status=Proposal.ACCEPTED,
                                                    description=info.description
                                                    )
        Proposal.update_proposal(info.id,proposal)


        return (accepted)
    end
end

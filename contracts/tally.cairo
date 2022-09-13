%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import get_caller_address

from starkware.cairo.common.math import assert_lt

from proposals.library import Proposal, proposals
from members import Member

namespace Tally {
    // should accept returns if a proposal should be accepted or rejected based
    // on current votes by applying the DAO's acceptance rules
    func should_accept{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        proposalId: felt
    ) -> (accepted: felt) {
        alloc_locals;

        // get proposal's info if it exists, fails otherwise
        let (local info: Proposal.Info) = Proposal.get_info(proposalId);
        let (local params) = Proposal.get_params(info.type);

        // check quorum
        local numVotes = info.yesVotes + info.noVotes;

        // TODO: must get total weight of eligible votes from proposalTypes to roles
        // mapping
        let eligible = 10;

        let quorum = is_le(params.quorum * eligible, numVotes * 100);
        if (quorum == 0) {
            return (FALSE,);
        }

        // check majority
        let majority = is_le(params.majority * numVotes, info.yesVotes * 100);
        if (majority == 0) {
            return (FALSE,);
        }

        return (TRUE,);
    }

    // apply will check if the proposal's grace period has ended, and move the
    // proposal to the next state, ACCEPTED/REJECTED.
    // TODO later: trigger actions.
    func apply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        proposalId: felt
    ) -> (accepted: felt) {
        // Apply voting rules to determine if proposal is accepted or rejected
        // Requires voting and grace period have ended
        // Modify Proposal status which is used by the front
        alloc_locals;
        let (local info: Proposal.Info) = Proposal.get_info(proposalId);
        let (local params) = Proposal.get_params(info.type);
        let (local caller) = get_caller_address();

        // assert the caller is member
        with_attr error_message("AccessControl: user {caller} is not a member.") {
            Member.assert_is_member(caller);
        }

        local today_timestamp;
        %{
            from datetime import datetime
            dt = datetime.now()
            ids.today_timestamp = int(datetime.timestamp(dt))
        %}

        // assert the gracePeriod ended
        with_attr error_message("The proposal has not ended grace period.") {
            assert_lt(
                info.submittedAt + params.graceDuration + params.votingDuration, today_timestamp
            );
        }

        let (accepted: felt) = should_accept(proposalId);
        if (accepted == FALSE) {
            Proposal.update_status(info.id, Proposal.REJECTED);
            return (FALSE,);
        }

        Proposal.update_status(info.id, Proposal.ACCEPTED);
        return (TRUE,);
    }
}

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE


namespace Rules:
    # should accept returns if a proposal should be accepted or rejected based
    # on current votes by applying the DAO's acceptance rules
    func should_accept{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
    }(proposalId: felt) -> (accepted: felt):
        let accepted: felt = FALSE
        return (accepted)
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
        let (accepted: felt) = should_accept(proposalId)
        return (accepted)
    end
end

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin


namespace Rules:
    func applyAcceptanceRules{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
    }(proposalId: felt) -> (accepted: felt):
        # Apply voting rules to determine if proposal is accepted or rejected
        # Requires voting and grace period have ended
        # Modify Proposal status which is used by the front
        return (1)
    end
end

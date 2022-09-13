%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

// TODO later: Automate actions.
// Might need to call other contracts
// Might need its subdirectory

namespace Actions {
    func executeProposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
        // Requires proposal to be accepted
        // Executes the proposal's actions if preconditions are satisfied
        // Modify Proposal status which is used by the front
        return ();
    }
}

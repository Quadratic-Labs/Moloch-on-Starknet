%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_nn, assert_lt
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address
from roles import Roles

struct ProposalInfo {
    id: felt,
    title: felt,
    type: felt,
    submittedBy: felt,
    submittedAt: felt,
    status: felt,
    description: felt,
}

// params apply to all proposals of the same kind
struct ProposalParams {
    majority: felt,
    quorum: felt,
    votingDuration: felt,
    graceDuration: felt,
}
namespace Proposal {
    const SUBMITTED = 1;
    const ACCEPTED = 2;  // Can proceed to execution if any actions
    const REJECTED = 3;
    const FORCED = 7; // Sent directly to grace period by admin
    // The remaining states are final
    const ABORTED = 4;  // Did not go completely through voting
    const EXECUTED = 5;  // Execution is finalised and successful
    const FAILED = 6;  // Execution failed
    const NOTFOUND = -1;

    const YESVOTE = 'yes';
    const NOVOTE = 'no';

    func get_params{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        kind: felt
    ) -> (params: ProposalParams) {
        let (params: ProposalParams) = proposalParams.read(kind);
        return (params,);
    }

    func set_params{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        kind: felt, params: ProposalParams
    ) -> () {
        proposalParams.write(kind, params);
        return ();
    }

    func assert_within_bounds{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> () {
        let (len: felt) = proposalsLength.read();
        with_attr error_message("Proposal {id} does not exist") {
            assert_nn(id);
            assert_lt(id, len);
        }
        return ();
    }

    func get_info{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(id: felt) -> (
        proposal: ProposalInfo
    ) {
        assert_within_bounds(id);
        let (proposal: ProposalInfo) = proposals.read(id);
        return (proposal,);
    }

    func search_position_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, current_position: felt, length: felt
    ) -> (position: felt) {
        alloc_locals;
        if (length == 0) {
            return (NOTFOUND,);
        }

        if (length == current_position) {
            return (NOTFOUND,);
        }
        let (info) = get_info(current_position);
        if (info.id == id) {
            return (current_position,);
        }
        let (local res) = search_position_by_id(id, current_position + 1, length);
        return (res,);
    }

    func add_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        info: ProposalInfo
    ) -> () {
        alloc_locals;
        let (local len: felt) = proposalsLength.read();
        proposals.write(len, info);
        proposalsLength.write(len + 1);
        return ();
    }

    func update_status{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, status: felt
    ) -> () {
        let (info: ProposalInfo) = get_info(id);
        let proposal: ProposalInfo = ProposalInfo(
            id=info.id,
            title=info.title,
            type=info.type,
            submittedBy=info.submittedBy,
            submittedAt=info.submittedAt,
            status=status,
            description=info.description,
        );
        Proposal.update_proposal(info.id, proposal);
        return ();
    }

    func get_proposal_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (proposal: ProposalInfo) {
        let (length) = proposalsLength.read();
        let (position) = search_position_by_id(id, 0, length);
        let (info: ProposalInfo) = get_info(position);
        return (info,);
    }

    func update_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, info: ProposalInfo
    ) -> () {
        let (length) = proposalsLength.read();
        let (position) = search_position_by_id(id, 0, length);
        // assert the proposal exists
        with_attr error_message("The proposal with id={id} not found.") {
            assert_nn(position);
        }
        proposals.write(position, info);
        return ();
    }

    func get_proposals_length{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> (length: felt) {
        let (length: felt) = proposalsLength.read();
        return (length,);
    }

    func get_vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, address: felt
    ) -> (vote: felt) {
        assert_within_bounds(id);
        let (vote: felt) = proposalsVotes.read(id, address);
        return (vote,);
    }

    func set_vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, address: felt, vote: felt
    ) -> () {
        proposalsVotes.write(id, address, vote);
        return ();
    }

    func force_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        proposalId: felt
    ) -> () {
        Roles.require_role('admin');
        update_status(proposalId, Proposal.ACCEPTED);
        return ();
    }

}

@storage_var
func proposalParams(proposalKind: felt) -> (params: ProposalParams) {
}

// List of proposals
@storage_var
func proposalsLength() -> (length: felt) {
}

@storage_var
func proposals(id: felt) -> (proposal: ProposalInfo) {
}
// End list of proposals

@storage_var
func proposalsVotes(proposalId: felt, memberAddress: felt) -> (vote: felt) {
}



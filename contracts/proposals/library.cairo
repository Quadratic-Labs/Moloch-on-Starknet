%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_nn, assert_lt
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address
from roles import Roles

@event
func ProposalAdded(
    id: felt, title: felt, link: felt, type: felt, submittedBy: felt, submittedAt: felt
) {
}

@event
func ProposalStatusUpdated(id: felt, status: felt) {
}

@event
func ProposalParamsUpdated(
    type: felt, majority: felt, quorum: felt, votingDuration: felt, graceDuration: felt
) {
}

struct ProposalInfo {
    id: felt,
    title: felt,
    type: felt,
    submittedBy: felt,
    submittedAt: felt,
    status: felt,
    link: felt,
}

// params apply to all proposals of the same kind
struct ProposalParams {
    majority: felt,
    quorum: felt,
    votingDuration: felt,
    graceDuration: felt,
}
namespace Proposal {
    const SUBMITTED = 'submitted';
    const APPROVED = 'approved';  
    const REJECTED = 'rejected';
    const FORCED = 'forced';  // Sent directly to grace period by admin
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
        ProposalParamsUpdated.emit(
            type=kind,
            majority=params.majority,
            quorum=params.quorum,
            votingDuration=params.votingDuration,
            graceDuration=params.graceDuration,
        );
        return ();
    }

    func assert_proposal_exists{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> () {
        let (proposal: ProposalInfo) = proposals.read(id);
        with_attr error_message("Proposal {id} does not exist") {
            assert proposal.id = id;
        }
        return ();
    }

    func get_info{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(id: felt) -> (
        proposal: ProposalInfo
    ) {
        let (proposal: ProposalInfo) = proposals.read(id);
        return (proposal,);
    }

    func get_proposal_status{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (status: felt) {
        let (proposal: ProposalInfo) = proposals.read(id);
        return (proposal.status,);
    }

    func add_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        info: ProposalInfo
    ) -> () {
        alloc_locals;
        let (local len: felt) = proposalsLength.read();
        proposals.write(info.id, info);
        proposalsLength.write(len + 1);
        ProposalAdded.emit(
            id=info.id,
            title=info.title,
            link=info.link,
            type=info.type,
            submittedBy=info.submittedBy,
            submittedAt=info.submittedAt,
        );
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
            link=info.link,
        );
        Proposal.update_proposal(info.id, proposal);
        ProposalStatusUpdated.emit(id=id, status=status);
        return ();
    }

    func update_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, info: ProposalInfo
    ) -> () {
        // assert the proposal exists
        with_attr error_message("The proposal with id={id} not found.") {
            assert_nn(id);
        }
        proposals.write(id, info);

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
        assert_proposal_exists(id);
        let (vote: felt) = proposalsVotes.read(id, address);
        return (vote,);
    }

    func set_vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, address: felt, vote: felt
    ) -> () {
        assert_proposal_exists(id);
        proposalsVotes.write(id, address, vote);
        return ();
    }

    func force_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        proposalId: felt
    ) -> () {
        Roles.require_role('admin');
        update_status(proposalId, Proposal.FORCED);
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

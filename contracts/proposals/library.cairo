%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_nn, assert_lt

namespace Proposal:
    const SUBMITTED = 1
    const ACCEPTED = 2  # Can proceed to execution if any actions
    # The remaining states are final
    const REJECTED = 3
    const ABORTED = 4  # Did not go completely through voting
    const EXECUTED = 5  # Execution is finalised and successful
    const FAILED = 6  # Execution failed

    struct Info:
        #TODO define the meaning of each element
        member id: felt
        member type: felt
        member submittedBy: felt
        member submittedAt: felt
        member votingEndsAt: felt
        member graceEndsAt: felt
        member expiresAt: felt
        member quorum: felt
        member majority: felt
        member yesVotes: felt
        member noVotes: felt
        member status: felt
        member description: felt
    end

    # params apply to all proposals of the same kind
    struct Params:
        member majority: felt
        member quorum: felt
        member votingDuration: felt
        member graceDuration: felt
    end

    func get_params{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(kind: felt) -> (params: Params):
        let (params: Params) = proposalParams.read(kind)
        return (params)
    end

    func set_params{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(kind: felt, params: Params) -> ():
        proposalParams.write(kind, params)
        return ()
    end

    func assert_within_bounds{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt) -> ():
        let (len: felt) = proposalsLength.read()
        with_attr error_message("Proposal {id} does not exist"):
            assert_nn(id)
            assert_lt(id, len)
        end
        return ()
    end

    func get_info{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt) -> (proposal: Info):
        assert_within_bounds(id)
        let (proposal: Info) = proposals.read(id)
        return (proposal)
    end

    func add_proposal{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(info: Info) -> ():
        alloc_locals
        let (local len: felt) = proposalsLength.read()
        proposals.write(len, info)
        proposalsLength.write(len+1)
        return ()
    end


    func get_proposals_length{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }() -> (length : felt):
        let (length: felt) = proposalsLength.read()
        return (length)
    end

    func get_vote{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt, address: felt) -> (vote: felt):
        assert_within_bounds(id)
        let (vote: felt) = proposalsVotes.read(id, address)
        return (vote)
    end

    func set_vote{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt, address: felt, vote: felt) -> ():
        assert_within_bounds(id)
        if vote == 0:
            proposalsVotes.write(id, address, 0)
        else:
            proposalsVotes.write(id, address, 1)
        end
        return ()
    end

end




@storage_var
func proposalParams(proposalKind: felt) -> (params: Proposal.Params):
end

# List of proposals
@storage_var
func proposalsLength() -> (length: felt):
end

@storage_var
func proposals(id: felt) -> (proposal: Proposal.Info):
end
# End list of proposals

@storage_var
func proposalsVotes(proposalId: felt, memberAddress: felt) -> (vote: felt):
end

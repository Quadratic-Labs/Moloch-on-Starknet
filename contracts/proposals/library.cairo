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

    const NOTFOUND = -1


    struct Info:
        #TODO define the meaning of each element
        member id: felt
        member type: felt
        member submittedBy: felt
        member submittedAt: felt
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


    func search_position_by_id{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id : felt, current_position : felt, length : felt) -> (position : felt):
        alloc_locals
        if length == 0:
            return (NOTFOUND)
        end

        if length == current_position :
            return (NOTFOUND)
        end
        let (info) = get_info(current_position)
        if  info.id == id :
            return (current_position)
        end
        let (local res) = search_position_by_id(id, current_position + 1, length)
        return (res)
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

    func update_status{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt, status: felt) -> ():
        let (info: Info) = get_info(id)
        let proposal: Proposal.Info = Proposal.Info(
            id=info.id,
            type=info.type,
            submittedBy=info.submittedBy,
            submittedAt=info.submittedAt,
            yesVotes=info.yesVotes,
            noVotes=info.noVotes,
            status=status,
            description=info.description
        )
        Proposal.update_proposal(info.id, proposal)
        return ()
    end

    

    func get_proposal_by_id{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt) -> (proposal: Info):
        let (length) = proposalsLength.read()
        let (position) = search_position_by_id(id, 0, length)
        let (info : Info) = get_info(position)
        return (info)
    end

    func update_proposal{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt, info: Info) -> ():
        let (length) = proposalsLength.read()
        let (position) = search_position_by_id(id, 0, length)
        # assert the proposal exists
        with_attr error_message("The proposal with id={id} not found."):
             assert_nn(position)
        end
        proposals.write(position, info)
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

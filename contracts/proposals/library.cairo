%lang starknet


namespace Proposal:
    const SUBMITTED = 1
    const ACCEPTED = 2  # Can proceed to execution if any actions
    # The remaining states are final
    const REJECTED = 3
    const ABORTED = 4  # Did not go completely through voting
    const EXECUTED = 5  # Execution is finalised and successful
    const FAILED = 6  # Execution failed

    struct Info:
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
end


@storage_var
func proposalParams(proposalKind: felt) -> (params: Proposal.Params):
end


@storage_var
func proposals(id: felt) -> (proposal: Proposal.Info):
end

@storage_var
func proposalsLength() -> (length: felt):
end

@storage_var
func proposalsVotes(proposalId: felt, memberAddress: felt) -> (vote: felt):
end

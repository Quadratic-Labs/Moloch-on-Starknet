%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin


namespace Voting:
    @external
    func submitVote{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
    }(proposalId: felt, vote: felt) -> (success: felt):
        return (0)
    end
    
    @external
    func submitVoteWithSig{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr,
    }(proposalId: felt, vote: felt, signature: felt) -> (success: felt):
        return (0)
    end
end

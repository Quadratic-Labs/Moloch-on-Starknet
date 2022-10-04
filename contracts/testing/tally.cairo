%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from tally import Tally

@external
func Tally_get_total_votes_proxy{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(proposalId: felt, voteType: felt) -> (count: felt) {
        return Tally.get_total_votes(proposalId, voteType);
    }
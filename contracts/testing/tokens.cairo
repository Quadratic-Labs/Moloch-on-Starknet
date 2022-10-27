%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from proposals.tokens import Tokens, TokenParams

@external
func Tokens_set_tokenParams_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt, params: TokenParams
) -> () {
    return Tokens.set_tokenParams(id, params);
}

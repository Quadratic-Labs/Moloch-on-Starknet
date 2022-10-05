%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from proposals.guildkick import Guildkick, GuildKickParams

@external
func Guildkick_set_guildKickParams_proxy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt, params: GuildKickParams
) -> () {
    return Guildkick.set_guildKickParams(id, params);
}
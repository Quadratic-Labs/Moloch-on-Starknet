%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from proposals.library import Proposal, ProposalInfo, ProposalParams

@external
func Proposal_get_params_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(kind: felt) -> (params: ProposalParams) {
    return Proposal.get_params(kind);
}

@external
func Proposal_set_params_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(kind: felt, params: ProposalParams) -> () {
    return Proposal.set_params(kind,params);
}

@external
func Proposal_assert_within_bounds_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt) -> () {
    return Proposal.assert_within_bounds(id);
}

@external
func Proposal_get_info_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt) -> (proposal: ProposalInfo) {
    return Proposal.get_info(id);
}

@external
func Proposal_search_position_by_id_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt, current_position: felt, length: felt) -> (position: felt) {
    return Proposal.search_position_by_id(id, current_position, length);
}

@external
func Proposal_add_proposal_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(info: ProposalInfo) -> () {
    return Proposal.add_proposal(info);
}

@external
func Proposal_update_status_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt, status: felt) -> () {
    return Proposal.update_status(id,status);
}

@external
func Proposal_get_proposal_by_id_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt) -> (proposal: ProposalInfo) {
    return Proposal.get_proposal_by_id(id);
}

@external
func Proposal_update_proposal_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt, info: ProposalInfo) -> () {
    return Proposal.update_proposal(id,info);
}

@external
func Proposal_get_proposals_length_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() -> (length: felt) {
    return Proposal.get_proposals_length();
}

@external
func Proposal_get_vote_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt, address: felt) -> (vote: felt) {
    return Proposal.get_vote(id,address);
}

@external
func Proposal_set_vote_proxy{
syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(id: felt, address: felt, vote: felt) -> () {
    return Proposal.set_vote(id, address, vote);
}
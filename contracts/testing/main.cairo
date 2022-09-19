%lang starknet

from testing.members import (
    Member_is_member_proxy,
    Member_assert_is_member_proxy,
    Member_assert_is_not_member_proxy,
    Member_assert_within_bounds_proxy,
    Member_is_jailed_proxy,
    Member_assert_not_jailed_proxy,
    Member_get_info_proxy,
    Member_total_count_proxy,
    Member_add_new_proxy,
    Member_update_proxy
)

from testing.proposals import (
    Proposal_get_params_proxy,
    Proposal_set_params_proxy,
    Proposal_assert_within_bounds_proxy,
    Proposal_get_info_proxy,
    Proposal_search_position_by_id_proxy,
    Proposal_add_proposal_proxy,
    Proposal_update_status_proxy,
    Proposal_get_proposal_by_id_proxy,
    Proposal_update_proposal_proxy,
    Proposal_get_proposals_length_proxy,
    Proposal_get_vote_proxy,
    Proposal_set_vote_proxy
)

from testing.roles import (
    Roles__grant_role_proxy,
    Roles__revoke_role_proxy,
    Roles_has_role_proxy,
    Roles_require_role_proxy
)
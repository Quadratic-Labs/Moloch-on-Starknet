import pytest
from . import utils


@pytest.mark.asyncio
async def test_get_total_shares_and_loot(empty_contract):
    # give random sahres to members
    total_members = 15
    shares = 879  # random shares to yes voters
    loot = 423

    # check if total is 1 at init, 1 due to the admin 1 share given in the main
    return_value = await empty_contract.Member_get_total_shares_proxy().execute()
    assert return_value.result.count == 1

    # check if total is 50 at init, 50 due to the admin 50 share given in the main
    return_value = await empty_contract.Member_get_total_loot_proxy().execute()
    assert return_value.result.count == 50

    # create members and votes for the tests
    for i in range(total_members):
        # voting 1 on an existing proposal should succeed
        caller_address = i
        # create the member
        await empty_contract.Member_add_member_proxy(
            (
                caller_address,  # address
                caller_address,  # delegatedKey
                shares,  # shares
                loot,  # loot
                0,  # jailed
                1,  # lastProposalYesVote
            )
        ).execute()

    # check if the new totals are correct
    return_value = await empty_contract.Member_get_total_shares_proxy().execute()
    assert return_value.result.count == (total_members * shares) + 1

    return_value = await empty_contract.Member_get_total_loot_proxy().execute()
    assert return_value.result.count == (total_members * loot) + 50

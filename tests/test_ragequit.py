import pytest


@pytest.mark.asyncio
async def test_caller_not_member(contract):
    shares = 5
    loot = 5
    caller_address = 404  # not existing member
    with pytest.raises(Exception):
        await contract.ragequit(shares=shares, loot=loot).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_caller_not_enough_shares_loot(contract):
    caller_address = 3  # has 10 shares and 5 loot
    # not enough shares
    shares = 50
    loot = 2
    with pytest.raises(Exception):
        await contract.ragequit(shares=shares, loot=loot).execute(
            caller_address=caller_address
        )
    # not enough loot
    shares = 5
    loot = 20
    with pytest.raises(Exception):
        await contract.ragequit(shares=shares, loot=loot).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_ragequit(contract):
    shares = 5
    loot = 5
    caller_address = 3  # has 10 shares and 5 loot
    return_value = await contract.ragequit(shares=shares, loot=loot).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    return_value = await contract.Member_get_info_proxy(address=caller_address).execute(
        caller_address=caller_address
    )
    assert (
        return_value.result.member_[2] == 10 - 5
    )  # check if number of shares is updated
    assert return_value.result.member_[3] == 5 - 5  # check if number of loot is updated

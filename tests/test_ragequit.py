import pytest


@pytest.mark.asyncio
async def test_caller_not_member(contract):
    caller_address = 404  # not existing member
    with pytest.raises(Exception):
        await contract.ragequit().execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_ragequit(contract):
    caller_address = 3  # has 10 shares and 5 loot
    return_value = await contract.ragequit().execute(caller_address=caller_address)
    assert return_value.result.success == 1

    return_value = await contract.Member_get_info_proxy(address=caller_address).execute(
        caller_address=caller_address
    )
    assert return_value.result.member_[2] == 0  # check if number of shares is updated
    assert return_value.result.member_[3] == 0  # check if number of loot is updated

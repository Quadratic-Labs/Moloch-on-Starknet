import pytest



@pytest.mark.asyncio
async def test_caller_not_member(contract):
    user = 404 # not existing member
    shares = 5
    loot = 5
    caller_address = 404 # not existing member
    with pytest.raises(Exception):
        await contract.ragequit(user=user, shares=shares, loot=loot).invoke(caller_address=caller_address)

@pytest.mark.asyncio
async def test_caller_not_ragequitter_member(contract):
    # TODO determine if we keep this test, I think if a user call for a ragequit, he should be able to do it only for himself otherwise it should be a guildkick
    user = 3
    shares = 5
    loot = 5
    caller_address = 1
    with pytest.raises(Exception):
        await contract.ragequit(user=user, shares=shares, loot=loot).invoke(caller_address=caller_address)

@pytest.mark.asyncio
async def test_caller_not_enough_shares_loot(contract):
    user = 3 # has 10 shares and 5 loot
    caller_address = 3
    # not enough shares
    shares = 50
    loot = 2
    with pytest.raises(Exception):
        await contract.ragequit(user=user, shares=shares, loot=loot).invoke(caller_address=caller_address)
    # not enough loot
    shares = 5
    loot = 20
    with pytest.raises(Exception):
        await contract.ragequit(user=user, shares=shares, loot=loot).invoke(caller_address=caller_address)
        

@pytest.mark.asyncio
async def test_ragequit(contract):
    user = 3 # has 10 shares and 5 loot
    shares = 5
    loot = 5
    caller_address = 3
    return_value = await contract.ragequit(user=user, shares=shares, loot=loot).invoke(caller_address=caller_address)
    assert return_value.result.success == 1

    return_value = await contract.get_info_members(address=user).invoke(caller_address=caller_address)
    assert return_value.result.member_[2] == 10 - 5 # check if number of shares is updated
    assert return_value.result.member_[3] == 5 - 5 # check if number of loot is updated
    
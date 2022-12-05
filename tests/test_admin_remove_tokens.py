import pytest


@pytest.mark.asyncio
async def test_not_member(contract):
    # given the caller is not a member, when invoking adminUnWhitelist for any token address, should fail
    caller_address = 404  # not a member
    token_address = 123
    with pytest.raises(Exception):
        await contract.adminUnWhitelist(
            tokenName=123, tokenAddress=token_address
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_not_admin(contract):
    # given the caller is not admin, when invoking adminUnWhitelist for any token address, should fail
    caller_address = 3  # not admin
    token_address = 123
    with pytest.raises(Exception):
        await contract.adminUnWhitelist(
            tokenName=123, tokenAddress=token_address
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_not_whitelisted(contract):
    # given token is not whitelisted, when invoking adminUnWhitelist for that token, should fail
    caller_address = 42  # admin
    token_address = 404  # a non whitelisted token
    with pytest.raises(Exception):
        await contract.adminUnWhitelist(
            tokenName=123, tokenAddress=token_address
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_submit_token(contract):
    # given the above passed, when invoking adminUnWhitelist, should succeed
    caller_address = 42  # admin
    token_address = 123  # a whitelisted token
    # assert the token is whitelisted, if not the test fails
    await contract.Bank_assert_token_whitelisted_proxy(token_address).execute(
        caller_address=caller_address
    )

    return_value = await contract.adminUnWhitelist(
        tokenName=123, tokenAddress=token_address
    ).execute(caller_address=caller_address)
    assert return_value.result.success == 1

    # assert the token is not anymore whitelisted, if not the test fails
    await contract.Bank_assert_token_not_whitelisted_proxy(token_address).execute(
        caller_address=caller_address
    )

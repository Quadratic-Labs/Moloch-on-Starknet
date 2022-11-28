import pytest
from . import utils


@pytest.mark.asyncio
async def test_not_member(contract):
    # given the caller is not a member, when invoking submitUnWhitelist for any token address, should fail
    caller_address = 404  # not a member
    token_address = 123
    title = utils.str_to_felt("Token to approve")
    tokenName = utils.str_to_felt("Quadratic-Token")
    with pytest.raises(Exception):
        await contract.submitUnWhitelist(
            tokenAddress=token_address,
            title=title,
            tokenName=tokenName,
            link=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_not_admin(contract):
    # given the caller is not admin, when invoking submitUnWhitelist for any token address, should fail
    caller_address = 3  # not admin
    token_address = 123
    title = utils.str_to_felt("Token to approve")
    tokenName = utils.str_to_felt("Quadratic-Token")
    with pytest.raises(Exception):
        await contract.submitUnWhitelist(
            tokenAddress=token_address,
            title=title,
            tokenName=tokenName,
            link=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_not_whitelisted(contract):
    # given token is not whitelisted, when invoking submitUnWhitelist for that token, should fail
    caller_address = 42  # admin
    token_address = 404  # a non whitelisted token
    title = utils.str_to_felt("Token to approve")
    tokenName = utils.str_to_felt("Quadratic-Token")
    with pytest.raises(Exception):
        await contract.submitUnWhitelist(
            tokenAddress=token_address,
            title=title,
            tokenName=tokenName,
            link=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_submit_token(contract):
    # given the above passed, when invoking submitUnWhitelist, should add proposal and succeed
    caller_address = 42  # admin
    token_address = 123  # a whitelisted token
    title = utils.str_to_felt("Token to approve")
    tokenName = utils.str_to_felt("Quadratic-Token")
    number_before_submit = (
        await contract.Proposal_get_proposals_length_proxy().call(
            caller_address=caller_address
        )
    ).result.length
    return_value = await contract.submitUnWhitelist(
        tokenAddress=token_address,
        title=title,
        tokenName=tokenName,
        link=123456789,
    ).execute(caller_address=caller_address)
    assert return_value.result.success == 1

    number_after_submit = (
        await contract.Proposal_get_proposals_length_proxy().call(
            caller_address=caller_address
        )
    ).result.length

    # Check if the proposal was taken into account
    assert number_after_submit == number_before_submit + 1

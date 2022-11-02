import pytest
from dataclasses import dataclass, astuple
from . import utils


@pytest.mark.asyncio
async def test_not_admin(contract):
    # given caller is not admin, after submitting any user, should fail
    caller_address = 3  # not admin
    address = 123
    shares = 10
    loot = 10
    tributeOffered = utils.to_uint(10)
    tributeAddress = 123
    title = utils.str_to_felt("Token to approve")

    with pytest.raises(Exception):
        await contract.Onboard_submitOnboard_proxy(
            address=address,
            shares=shares,
            loot=loot,
            tributeOffered=tributeOffered,
            tributeAddress=tributeAddress,
            title=title,
            link=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_already_member(contract):
    # given the user is already a member, after submitting the user, should fail
    caller_address = 42  # admin
    address = 3
    shares = 10
    loot = 10
    tributeOffered = utils.to_uint(10)
    tributeAddress = 123
    title = utils.str_to_felt("Token to approve")
    with pytest.raises(Exception):
        await contract.Onboard_submitOnboard_proxy(
            address=address,
            shares=shares,
            loot=loot,
            tributeOffered=tributeOffered,
            tributeAddress=tributeAddress,
            title=title,
            link=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_submit_onboard(contract):
    # given the user is not a member and the caller is admin, should record the proposal accordingly
    caller_address = 42  # admin
    address = 123
    shares = 10
    loot = 10
    tributeOffered = utils.to_uint(10)
    tributeAddress = 123
    title = utils.str_to_felt("Token to approve")

    number_before_submit = (
        await contract.Proposal_get_proposals_length_proxy().call(
            caller_address=caller_address
        )
    ).result.length
    return_value = await contract.Onboard_submitOnboard_proxy(
        address=address,
        shares=shares,
        loot=loot,
        tributeOffered=tributeOffered,
        tributeAddress=tributeAddress,
        title=title,
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

import pytest
import utils


@pytest.mark.asyncio
async def test_caller_not_member(contract):
    member_address = 4  # existing member
    caller_address = 404  # not existing member
    title = utils.str_to_felt("Guild Kick")

    with pytest.raises(Exception):
        await contract.submitGuildKick(
            member_address, title=title, link=123456789
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_caller_not_govern(contract):
    member_address = 4  # existing member
    caller_address = 1  # existing but not govern member
    title = utils.str_to_felt("Guild Kick")

    with pytest.raises(Exception):
        await contract.submitGuildKick(
            member_address, title=title, link=123456789
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_submitted_not_member(contract):
    member_address = 404  # not existing member
    caller_address = 3  # existing and govern member
    title = utils.str_to_felt("Guild Kick")

    with pytest.raises(Exception):
        await contract.submitGuildKick(
            member_address, title=title, link=123456789
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_submitGuildKick(contract):
    member_address = 4  # existing member
    caller_address = 3  # existing and govern member
    title = utils.str_to_felt("Guild Kick")

    number_before_submit = (
        await contract.Proposal_get_proposals_length_proxy().call(
            caller_address=caller_address
        )
    ).result.length

    return_value = await contract.submitGuildKick(
        member_address, title=title, link=123456789
    ).execute(caller_address=caller_address)
    assert return_value.result.success == 1

    number_after_submit = (
        await contract.Proposal_get_proposals_length_proxy().call(
            caller_address=caller_address
        )
    ).result.length

    # Check if the proposal was taken into account
    assert number_after_submit == number_before_submit + 1

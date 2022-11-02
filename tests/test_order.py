import pytest
from . import utils


@pytest.mark.asyncio
async def test_caller_not_member(contract):
    caller_address = 404  # not existing member
    tributeOffered = utils.to_uint(5)
    tributeAddress = 123
    paymentRequested = utils.to_uint(5)
    paymentAddress = 123
    title = utils.str_to_felt("Swap order")

    with pytest.raises(Exception):
        await contract.Swap_submitSwap_proxy(
            tributeOffered=tributeOffered,
            tributeAddress=tributeAddress,
            paymentRequested=paymentRequested,
            paymentAddress=paymentAddress,
            title=title,
            link=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_caller_not_govern(contract):
    caller_address = 1  # existing but not govern member
    tributeOffered = utils.to_uint(5)
    tributeAddress = 123
    paymentRequested = utils.to_uint(5)
    paymentAddress = 123
    title = utils.str_to_felt("Swap order")

    with pytest.raises(Exception):
        await contract.Swap_submitSwap_proxy(
            tributeOffered=tributeOffered,
            tributeAddress=tributeAddress,
            paymentRequested=paymentRequested,
            paymentAddress=paymentAddress,
            title=title,
            link=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_Swap_submitSwap_proxy(contract):
    caller_address = 3  # existing and govern member
    tributeOffered = utils.to_uint(5)
    tributeAddress = 123
    paymentRequested = utils.to_uint(5)
    paymentAddress = 123
    title = utils.str_to_felt("Swap order")

    number_before_submit = (
        await contract.Proposal_get_proposals_length_proxy().call(
            caller_address=caller_address
        )
    ).result.length

    return_value = await contract.Swap_submitSwap_proxy(
        tributeOffered=tributeOffered,
        tributeAddress=tributeAddress,
        paymentRequested=paymentRequested,
        paymentAddress=paymentAddress,
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

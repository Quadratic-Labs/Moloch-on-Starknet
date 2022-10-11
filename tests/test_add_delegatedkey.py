import pytest


@pytest.mark.asyncio
async def test_caller_not_member(contract):
    delegated_key = 323
    caller_address = 404  # not existing member
    with pytest.raises(Exception):
        await contract.delegateVote(delegated_key).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_add_delegate_key(contract):
    delegated_key = 4
    caller_address = 3
    # check that the delegated key is not assigned
    delegated_key_before_call = await contract.Member_get_info_proxy(
        caller_address
    ).execute()
    assert delegated_key_before_call.result.member_[1] == caller_address

    # add the delegated key
    return_value = await contract.delegateVote(delegated_key).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # check that the delegated key is now assigned
    delegated_key_before_call = await contract.Member_get_info_proxy(
        caller_address
    ).execute()
    assert delegated_key_before_call.result.member_[1] == delegated_key

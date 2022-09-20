import pytest


@pytest.mark.asyncio
async def test_caller_not_member(contract):
    delegated_key = 323
    caller_address = 404  # not existing member
    with pytest.raises(Exception):
        await contract.revokeDelegatedKey(delegated_key).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_revoke_delegate_key(contract):
    caller_address = 2  # user with a delagated key to user 5
    delegated_key = 5
    # check that the delegated key is not assigned
    delegated_key_before_call = await contract.Member_get_info_proxy(
        caller_address
    ).execute()
    assert delegated_key_before_call.result.member_[1] == delegated_key

    # add the delegated key
    return_value = await contract.revokeDelegatedKey().execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # check that the delegated key is now assigned
    delegated_key_before_call = await contract.Member_get_info_proxy(
        caller_address
    ).execute()
    assert delegated_key_before_call.result.member_[1] == caller_address

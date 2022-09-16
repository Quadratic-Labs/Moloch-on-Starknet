import pytest
# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.



@pytest.mark.asyncio
async def test_is_member(contract):
    """Test test_Member_is_member_proxy method."""

    # Member_is_member_proxy on an empty list should return False
    return_value = await contract.Member_is_member_proxy(404).execute()
    assert return_value.result.success == 0

    # adding two fake members
    await contract.Member_add_new_proxy((6, 6, 1, 1, 1, 1)).execute()
    await contract.Member_add_new_proxy((7, 7, 2, 2, 2, 2)).execute()

    # Member_is_member_proxy on any of the 2 members should return True
    return_value = await contract.Member_is_member_proxy(1).execute()
    assert return_value.result.success == 1

    return_value = await contract.Member_is_member_proxy(2).execute()
    assert return_value.result.success == 1

    # Member_is_member_proxy on a non-existing member should return False
    return_value = await contract.Member_is_member_proxy(8).execute()
    assert return_value.result.success == 0

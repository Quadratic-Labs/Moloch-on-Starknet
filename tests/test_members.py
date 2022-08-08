import pytest
# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.



@pytest.mark.asyncio
async def test_is_member(contract):
    """Test test_is_member method."""

    # is_member on an empty list should return False
    return_value = await contract.is_member(0).invoke()
    assert return_value.result.success == 0

    # adding two fake members
    await contract.add((1,1,1,1,1,1)).invoke()
    await contract.add((2,2,2,2,2,2)).invoke()

    # is_member on any of the 2 members should return True
    return_value = await contract.is_member(1).invoke()
    assert return_value.result.success == 1

    return_value = await contract.is_member(2).invoke()
    assert return_value.result.success == 1

    # is_member on a non-existing member should return False
    return_value = await contract.is_member(3).invoke()
    assert return_value.result.success == 0

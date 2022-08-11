import pytest


@pytest.mark.asyncio
async def test_role(contract):
    """Test submitVote method."""
    admin = (await contract.roles(0).call()).result.role
    # govern = (await contract.roles(1).call()).result.role
    return_value = await contract.add_role(user=1, role=admin).invoke()
    return_value = await contract.has_role(user=1, role=admin).invoke()
    assert return_value.result.has_role == 1

import pytest

from uti import to_cairo_felt


@pytest.mark.asyncio
async def test_role(contract):
    """Test submitVote method."""
    admin = to_cairo_felt("admin")  # admin in felt

    # govern = (await contract.roles(1).call()).result.role
    return_value = await contract.grant_role(role=admin, user=1).invoke(
        caller_address=42
    )
    return_value = await contract.has_role(user=1, role=admin).invoke()
    assert return_value.result.has_role == 1

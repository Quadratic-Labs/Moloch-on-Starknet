import pytest

import utils


@pytest.mark.asyncio
async def test_role(contract):
    """Test submitVote method."""
    admin = utils.str_to_felt("admin")  # admin in felt

    # govern = (await contract.roles(1).call()).result.role
    return_value = await contract.grant_role(role=admin, user=1).execute(
        caller_address=42
    )
    return_value = await contract.Roles_has_role_proxy(user=1, role=admin).execute()
    assert return_value.result.has_role == 1

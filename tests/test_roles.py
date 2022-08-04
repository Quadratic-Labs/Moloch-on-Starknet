import pytest


@pytest.mark.asyncio
async def test_submitVote(contract):
    """Test submitVote method."""
    return_value = await contract.submitVote(proposalId=1, vote=True).invoke()
    assert return_value.result.success == 1

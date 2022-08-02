"""contract.cairo test file."""
import os

import pytest

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_submitVote(contract):
    """Test submitVote method."""
    return_value = await contract.submitVote(id=1, vote=True).invoke()
    assert return_value.result.success == 1

import os
import pytest

from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "core.cairo")


@pytest.fixture
async def starknet():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    return await Starknet.empty()


@pytest.fixture
async def contract(starknet):
    # Deploy the contract.
    return await starknet.deploy(
        source=CONTRACT_FILE,
    )

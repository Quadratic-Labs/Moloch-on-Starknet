from pathlib import Path
import pytest
import sys
import typing

# from starkware.starknet.testing.starknet import Starknet
import starknet_devnet.state
import starknet_devnet.server


# L'init fait l'équivalent de run la commande
# starknet-devnet --host localhost --port 5050 --seed 42 --accounts 5
# in another process to launch a local test network
#
# Account #0
# Address: 0x347be35996a21f6bf0623e75dbce52baba918ad5ae8d83b6f416045ab22961a
# Public key: 0x674efe292c3c1125108916d6128bd6d1db4528db07322a84177551067aa2bef
# Private key: 0xbdd640fb06671ad11c80317fa3b1799d
# 
# Account #1
# Address: 0x7aac39162d91acf2c4f0d539f4b81e23832619ac0c3df9fce22e4a8d505632a
# Public key: 0xf67d9dd00db22ccd01a9ee347a47457eaa7899c4cf0e0e9570e4dca56bbf85
# Private key: 0x23b8c1e9392456de3eb13b9046685257
# 
# Account #2
# Address: 0x9c4ba7b103329632f6bf5035f1e440b341e7477c4231a47b15545b19d23f76
# Public key: 0x11d2bf0b223050b347fa84ac0f1746b602c211bc2745662d39c20e8336965ba
# Private key: 0xbd9c66b3ad3c2d6d1a3d1fa7bc8960a9
# 
# Account #3
# Address: 0x6477babd13e8688eecf8852b9b9e083e0a5eca7aa65c5f71f703714380b7bf1
# Public key: 0xc545c7d52e492a606053ac32ca1a31436a0b8bddff54631ec61d225e899887
# Private key: 0x972a846916419f828b9d2434e465e150
# 
# Account #4
# Address: 0x732d89082a55402168e474f0374dfd6b784c5d10abc724e7317cbc54899f90f
# Public key: 0x56d12b0ac2d5a82d424d7edca142225c51f236cdc28f6ab480bcba24749766d
# Private key: 0x17fc695a07a0ca6e0822e8f36c031199
# 

# The path to the contract source code.
CONTRACTS_DIR = Path().parent.joinpath("contracts").absolute()
CONTRACT_FILE = CONTRACTS_DIR / "main.cairo"


@pytest.fixture
async def starknet():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    # return await Starknet.empty()
    sys.argv =  "starknet_devnet --host localhost --port 5050 --seed 42 --accounts 5".split()
    args = starknet_devnet.util.parse_args()
    await starknet_devnet.state.state.starknet_wrapper.initialize()
    starknet_devnet.server.generate_accounts(args)
    starknet_devnet.server.enable_lite_mode(args)
    starknet_devnet.server.set_start_time(args)
    starknet_devnet.server.set_gas_price(args)
    yield await starknet_devnet.state.state.starknet_wrapper._StarknetWrapper__get_starknet()
    starknet_devnet.state.state = starknet_devnet.state.State()


@pytest.fixture
async def contract(starknet):
    # Deploy the contract.
    return await starknet.deploy(
        source=str(CONTRACT_FILE),
        cairo_path=[CONTRACTS_DIR],
        constructor_calldata=[50, 60, 10, 10],
    )

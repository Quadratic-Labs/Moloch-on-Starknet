import pytest
import asyncio

from dataclasses import dataclass, astuple
import os
from pathlib import Path

# from starkware.starknet.testing.starknet import Starknet
import starknet_devnet.devnet_config
import starknet_devnet.state
import starknet_devnet.server
from starknet_devnet.starknet_wrapper import StarknetWrapper
from starknet_devnet.devnet_config import DevnetConfig
from starknet_py.compile.compiler import Compiler
from starkware.starknet.testing.starknet import get_contract_class

import utils


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

# We have to override the default event_loop to be able to write async fixtures with a session scope
# TODO: think about using a different event_loop instead of overriding as suggested by the asyncio-pytest docs
@pytest.fixture(scope="session")
def event_loop():
    policy = asyncio.get_event_loop_policy()
    loop = policy.new_event_loop()
    yield loop
    loop.close()


# The path to the contract source code.
@pytest.fixture(scope="session")
def test_contract_file():
    rootdir = Path(__file__).parent.parent
    source_file = rootdir / "contracts" / "main.cairo"
    import_file = rootdir / "contracts" / "testing" / "main_test.cairo"
    output_file = rootdir / "tests" / "main.cairo"

    # Decorate internal functions with @external to be able to test them
    utils.create_main_test(
        source_file.absolute(),
        import_file.absolute(),
        output_file.absolute(),
    )
    yield output_file
    os.remove(output_file.absolute())


@pytest.fixture(scope="session")
async def starknet():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    # return await Starknet.empty()
    args = starknet_devnet.devnet_config.parse_args(
        "--host localhost --port 5050 --seed 42 --accounts 5".split()
    )
    state = starknet_devnet.state.State()
    state.set_starknet_wrapper(StarknetWrapper(DevnetConfig(args)))
    await state.starknet_wrapper.initialize()
    # starknet_devnet.server.generate_accounts(args)
    # starknet_devnet.server.enable_lite_mode(args)
    # starknet_devnet.server.set_start_time(args)
    # starknet_devnet.server.set_gas_price(args)
    yield state.starknet_wrapper.starknet
    # yield await starknet_devnet.state.state.starknet_wrapper._StarknetWrapper__get_starknet()
    # starknet_devnet.state.state = starknet_devnet.state.State()


@dataclass
class Member:
    address: int
    delegateAddress: int
    shares: int
    loot: int
    jailed: int
    lastProposalYesVote: int
    onboardedAt: int


@dataclass
class Proposal:
    id: int
    title: int
    type: int
    submittedBy: int
    submittedAt: int
    status: int
    link: int


MEMBERS: list[Member] = [
    Member(
        address=1,
        delegateAddress=1,
        shares=5,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
        onboardedAt=0,
    ),
    Member(
        address=2,
        delegateAddress=5,
        shares=5,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
        onboardedAt=0,
    ),
    Member(
        address=3,
        delegateAddress=3,
        shares=10,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
        onboardedAt=0,
    ),
    Member(
        address=4,
        delegateAddress=4,
        shares=50,
        loot=0,
        jailed=1,
        lastProposalYesVote=1,
        onboardedAt=0,
    ),
    Member(
        address=5,
        delegateAddress=5,
        shares=5,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
        onboardedAt=0,
    ),
    Member(
        address=6,
        delegateAddress=6,
        shares=5,
        loot=5,
        jailed=1,
        lastProposalYesVote=1,
        onboardedAt=0,
    ),
]


PROPOSALS: list[Proposal] = [
    Proposal(  # Submitted and vote + grace open
        id=0,
        title=utils.str_to_felt("titre"),
        type=utils.str_to_felt("Signaling"),  # Onboard
        submittedBy=1,
        submittedAt=1,
        status=1,  # SUBMITTED
        link=1,
    ),
    Proposal(  # ACCEPTED and vote closed
        id=1,
        title=utils.str_to_felt("titre"),
        type=utils.str_to_felt("Signaling"),  # Onboard
        submittedBy=3,
        submittedAt=1,
        status=2,  # ACCEPTED
        link=1,
    ),
    Proposal(  # Rejected and vote closed
        id=2,
        title=utils.str_to_felt("titre"),
        type=utils.str_to_felt("Signaling"),  # Onboard
        submittedBy=1,
        submittedAt=1,
        status=3,  # REJECTED
        link=1,
    ),
    Proposal(  # Submitted and vote open + grace closed
        id=3,
        title=utils.str_to_felt("titre"),
        type=utils.str_to_felt("Signaling"),  # Onboard
        submittedBy=3,
        submittedAt=1,
        status=1,  # SUBMITTED
        link=1,
    ),
    Proposal(  # Submitted and didn't reach majority
        id=4,
        title=utils.str_to_felt("titre"),
        type=utils.str_to_felt("Signaling"),  # Onboard
        submittedBy=3,
        submittedAt=-20,  # put submitted at to -20 to make the test on voting a grace period pass
        status=1,  # SUBMITTED
        link=1,
    ),
    Proposal(  # Submitted and didn't reach quorom
        id=5,
        title=utils.str_to_felt("titre"),
        type=utils.str_to_felt("Signaling"),  # Onboard
        submittedBy=3,
        submittedAt=1,
        status=1,  # SUBMITTED
        link=1,
    ),
    Proposal(  # Submitted and reached qurom and majority
        id=6,
        title=utils.str_to_felt("titre"),
        type=utils.str_to_felt("Signaling"),  # Onboard
        submittedBy=3,
        submittedAt=1,
        status=1,  # SUBMITTED
        link=1,
    ),
    Proposal(  # Submitted and reached qurom and majority
        id=7,
        title=utils.str_to_felt("titre"),
        type=utils.str_to_felt("Signaling"),  # Onboard
        submittedBy=3,
        submittedAt=1,
        status=1,  # SUBMITTED
        link=1,
    ),
]


@pytest.fixture(scope="session")
async def test_contract_class(test_contract_file: Path):
    contracts_path = Path(__file__).parent.parent / "contracts"
    return get_contract_class(
        source=str(test_contract_file.absolute()),
        # cairo_path=[str(test_contract_file.parent.absolute())],
        cairo_path=[str(contracts_path.absolute())],
        disable_hint_validation=True,
    )


@pytest.fixture
async def empty_contract(starknet, test_contract_class):
    return await starknet.deploy(
        contract_class=test_contract_class,
        constructor_calldata=[50, 60, 10, 10],
        disable_hint_validation=True,
    )


@pytest.fixture
async def contract(starknet, test_contract_class):
    majority = 50
    quorum = 60
    grace_duration = 10
    voting_duration = 10

    contract = await starknet.deploy(
        contract_class=test_contract_class,
        constructor_calldata=[majority, quorum, grace_duration, voting_duration],
        disable_hint_validation=True,
    )
    govern = utils.str_to_felt("govern")  # govern in felt
    admin = utils.str_to_felt("admin")  # admin in felt
    MEMBER_ROLES = {
        1: [admin],
        2: [admin, govern],
        3: [govern],
        4: [govern],
        5: [],
        6: [govern],
    }
    for member in MEMBERS:
        await contract.Member_add_member_proxy(astuple(member)).execute()
        for role in MEMBER_ROLES[member.address]:
            await contract.grant_role(role, member.address).execute(caller_address=42)

    for proposal in PROPOSALS:
        await contract.Proposal_add_proposal_proxy(astuple(proposal)).execute()

    return contract

import pytest
from dataclasses import dataclass, astuple
from . import utils

YESVOTE = utils.str_to_felt("yes")
NOVOTE = utils.str_to_felt("no")
GUILD = 0xAAA
ESCROW = 0xBBB
TOTAL = 0xCCC


async def create_votes(
    empty_contract,
    proposalId,
    proposalType,
    caller_address,
    total_yes_votes,
):
    proposal = (
        proposalId,  # id
        utils.str_to_felt("titre"),
        utils.str_to_felt(proposalType),  # type
        3,  # submittedBy
        -200,  # submittedAt
        1,  # status # 1 = SUBMITTED
        1,  # link
    )
    await empty_contract.Proposal_add_proposal_proxy(proposal).execute()
    # create members that votes and votes for the tests
    for i in range(total_yes_votes):
        caller_address = i + 5555  # add 5555 to avoid already used adress for members
        # create the member
        await empty_contract.Member_add_member_proxy(
            (
                caller_address,  # address
                caller_address,  # delegatedKey
                1,  # shares
                1,  # loot
                1,  # jailed
                1,  # lastProposalYesVote
                0,  # onBoarddedAt
            )
        ).execute()
        # vote yes for the proposal
        await empty_contract.Proposal_set_vote_proxy(
            id=proposalId, address=caller_address, vote=YESVOTE
        ).execute(caller_address=caller_address)


async def increase_guild_balance(empty_contract):
    await empty_contract.Bank_add_token_proxy(tokenAddress=100).execute()
    await empty_contract.Bank_add_token_proxy(tokenAddress=200).execute()
    await empty_contract.Bank_add_token_proxy(tokenAddress=300).execute()
    await empty_contract.Bank_add_token_proxy(tokenAddress=400).execute()
    await empty_contract.Bank_set_userTokenBalances_proxy(
        userAddress=GUILD, tokenAddress=100, amount=utils.to_uint(21)
    ).execute()
    await empty_contract.Bank_set_userTokenBalances_proxy(
        userAddress=GUILD, tokenAddress=200, amount=utils.to_uint(27)
    ).execute()
    await empty_contract.Bank_set_userTokenBalances_proxy(
        userAddress=GUILD, tokenAddress=300, amount=utils.to_uint(42)
    ).execute()
    await empty_contract.Bank_set_userTokenBalances_proxy(
        userAddress=GUILD, tokenAddress=400, amount=utils.to_uint(333)
    ).execute()
    await empty_contract.Bank_set_userTokenBalances_proxy(
        userAddress=TOTAL, tokenAddress=100, amount=utils.to_uint(21)
    ).execute()
    await empty_contract.Bank_set_userTokenBalances_proxy(
        userAddress=TOTAL, tokenAddress=200, amount=utils.to_uint(27)
    ).execute()
    await empty_contract.Bank_set_userTokenBalances_proxy(
        userAddress=TOTAL, tokenAddress=300, amount=utils.to_uint(42)
    ).execute()
    await empty_contract.Bank_set_userTokenBalances_proxy(
        userAddress=TOTAL, tokenAddress=400, amount=utils.to_uint(333)
    ).execute()


@pytest.mark.asyncio
async def test_accounting_when_onboard(empty_contract):

    # set the bank balance to preset amounts for different tokens
    await increase_guild_balance(empty_contract)
    # store the amount before the execute
    amount_token_100_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=100
        ).execute()
    ).result.amount
    amount_token_200_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=200
        ).execute()
    ).result.amount
    amount_token_300_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=300
        ).execute()
    ).result.amount
    amount_token_400_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=400
        ).execute()
    ).result.amount

    caller_address = 42
    proposalId = 16546
    total_yes_votes = 10
    await create_votes(
        empty_contract,
        proposalId,
        "Onboard",
        caller_address,
        total_yes_votes,
    )
    # add additional params depending on the proposal type
    tributeOffered = utils.to_uint(10)
    tributeAddress = 100

    address = 100
    shares = 10
    loot = 10
    params = (address, shares, loot, tributeOffered, tributeAddress)
    await empty_contract.Onboard_set_onBoardParams_proxy(proposalId, params).execute()

    # in order the execute onboard, the ESCROW needs to be increased by at least the tribute offered
    await empty_contract.Bank_increase_userTokenBalances_proxy(
        0xBBB, tributeAddress, tributeOffered
    ).execute()

    return_value = await empty_contract.executeProposal(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # check the new balance
    amount_token_100_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=100
        ).execute()
    ).result.amount
    amount_token_200_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=200
        ).execute()
    ).result.amount
    amount_token_300_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=300
        ).execute()
    ).result.amount
    amount_token_400_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=400
        ).execute()
    ).result.amount

    assert (
        utils.from_uint(amount_token_100_after)
        == utils.from_uint(amount_token_100_before) + 10
    )
    assert utils.from_uint(amount_token_200_after) == utils.from_uint(
        amount_token_200_before
    )
    assert utils.from_uint(amount_token_300_after) == utils.from_uint(
        amount_token_300_before
    )
    assert utils.from_uint(amount_token_400_after) == utils.from_uint(
        amount_token_400_before
    )


@pytest.mark.asyncio
async def test_accounting_when_ragequit(empty_contract):
    # set the bank balance to preset amounts for different tokens
    await increase_guild_balance(empty_contract)
    # store the amount before the execute
    amount_token_100_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=100
        ).execute()
    ).result.amount
    amount_token_200_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=200
        ).execute()
    ).result.amount
    amount_token_300_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=300
        ).execute()
    ).result.amount
    amount_token_400_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=400
        ).execute()
    ).result.amount
    # create a member with 2/3 of the total sahres and loot
    caller_address = 52
    await empty_contract.Member_add_member_proxy(
        (
            caller_address,  # address
            caller_address,  # delegatedKey
            2,  # shares (1 share already in the total due to the admin from main)
            100,  # loot (50 loot already in the total due to the admin from main)
            0,  # jailed
            1,  # lastProposalYesVote
            0,  # onBoarddedAt
        )
    ).execute()
    return_value = await empty_contract.ragequit().execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # check the new balance
    amount_token_100_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=100
        ).execute()
    ).result.amount
    amount_token_200_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=200
        ).execute()
    ).result.amount
    amount_token_300_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=300
        ).execute()
    ).result.amount
    amount_token_400_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=400
        ).execute()
    ).result.amount

    assert (
        utils.from_uint(amount_token_100_after)
        == utils.from_uint(amount_token_100_before) // 3
    )
    assert (
        utils.from_uint(amount_token_200_after)
        == utils.from_uint(amount_token_200_before) // 3
    )
    assert (
        utils.from_uint(amount_token_300_after)
        == utils.from_uint(amount_token_300_before) // 3
    )
    assert (
        utils.from_uint(amount_token_400_after)
        == utils.from_uint(amount_token_400_before) // 3
    )


@pytest.mark.asyncio
async def test_accounting_when_swap(empty_contract):
    # set the bank balance to preset amounts for different tokens
    await increase_guild_balance(empty_contract)
    # store the amount before the execute
    amount_token_100_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=100
        ).execute()
    ).result.amount
    amount_token_200_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=200
        ).execute()
    ).result.amount
    amount_token_300_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=300
        ).execute()
    ).result.amount
    amount_token_400_before = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=400
        ).execute()
    ).result.amount
    caller_address = 42
    proposalId = 156
    total_yes_votes = 10
    await create_votes(
        empty_contract,
        proposalId,
        "Swap",
        caller_address,
        total_yes_votes,
    )
    # add additional params depending on the proposal type
    tributeOffered = utils.to_uint(100)
    tributeAddress = 100
    paymentRequested = utils.to_uint(10)
    paymentAddress = 200
    params = (tributeOffered, tributeAddress, paymentRequested, paymentAddress)
    await empty_contract.Swap_set_swapParams_proxy(proposalId, params).execute()

    # in order the execute swap, the ESCROW needs to be increased by at least the tributeOffered
    # and the GUILD and TOTAL need to be increased by paymentRequested
    await empty_contract.Bank_increase_userTokenBalances_proxy(
        ESCROW, tributeAddress, tributeOffered
    ).execute()

    return_value = await empty_contract.Actions_executeProposal_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    assert return_value.result.success == 1

    # check the new balance
    amount_token_100_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=100
        ).execute()
    ).result.amount
    amount_token_200_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=200
        ).execute()
    ).result.amount
    amount_token_300_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=300
        ).execute()
    ).result.amount
    amount_token_400_after = (
        await empty_contract.Bank_get_userTokenBalances_proxy(
            userAddress=GUILD, tokenAddress=400
        ).execute()
    ).result.amount

    assert utils.from_uint(amount_token_100_after) == utils.from_uint(
        amount_token_100_before
    ) + utils.from_uint(tributeOffered)
    assert utils.from_uint(amount_token_200_after) == utils.from_uint(
        amount_token_200_before
    ) - utils.from_uint(paymentRequested)
    assert utils.from_uint(amount_token_300_after) == utils.from_uint(
        amount_token_300_before
    )
    assert utils.from_uint(amount_token_400_after) == utils.from_uint(
        amount_token_400_before
    )

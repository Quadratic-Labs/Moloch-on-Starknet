import pytest
from dataclasses import dataclass, astuple
from . import utils

YESVOTE = utils.str_to_felt("yes")
NOVOTE = utils.str_to_felt("no")


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
        1,  # description
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
            )
        ).execute()
        # vote yes for the proposal
        await empty_contract.Proposal_set_vote_proxy(
            id=proposalId, address=caller_address, vote=YESVOTE
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_grace_period_not_ended(empty_contract):
    # create a proposal for the purpose of the tests

    proposalId = 456
    proposal = (
        proposalId,  # id
        utils.str_to_felt("title"),  # title
        utils.str_to_felt("Signaling"),  # type
        3,  # submittedBy
        -1,  # submittedAt put to -1 to bypass votingperiod guards
        1,  # status # 1 = SUBMITTED
        1,  # description
    )
    await empty_contract.Proposal_add_proposal_proxy(proposal).execute()
    # vote yes on the proposal to make it pass
    for i in range(10):
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
            )
        ).execute()
        # vote yes for the proposal
        await empty_contract.Proposal_set_vote_proxy(
            id=proposalId, address=caller_address, vote=YESVOTE
        ).execute(caller_address=caller_address)
    # given proposal has not ended grace period, when invoking executeProposal, should fail
    caller_address = 42
    with pytest.raises(Exception):
        await empty_contract.executeProposal(proposalId=proposalId).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_execute_signaling_proposal(empty_contract):

    caller_address = 42
    proposalId = 2446
    total_yes_votes = 10
    await create_votes(
        empty_contract,
        proposalId,
        "Signaling",
        caller_address,
        total_yes_votes,
    )

    return_value = await empty_contract.executeProposal(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # check if the status of the proposal changed to EXECUTED (=5)
    return_value = await empty_contract.Proposal_get_proposal_status_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    assert return_value.result.status == 5


@pytest.mark.asyncio
async def test_execute_ApproveToken_proposal(empty_contract):

    caller_address = 42
    proposalId = 565
    total_yes_votes = 10
    await create_votes(
        empty_contract,
        proposalId,
        "ApproveToken",
        caller_address,
        total_yes_votes,
    )
    # add additional params depending on the proposal type
    @dataclass
    class Params:
        tokenAddress: int
        tokenName: int

    params = Params(tokenAddress=50, tokenName=123)

    await empty_contract.Tokens_set_tokenParams_proxy(
        proposalId, astuple(params)
    ).execute()

    return_value = await empty_contract.executeProposal(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # check if the status of the proposal changed to EXECUTED (=5)
    return_value = await empty_contract.Proposal_get_proposal_status_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    assert return_value.result.status == 5


@pytest.mark.asyncio
async def test_execute_RemoveToken_proposal(empty_contract):

    caller_address = 42
    proposalId = 565
    total_yes_votes = 10
    await create_votes(
        empty_contract,
        proposalId,
        "RemoveToken",
        caller_address,
        total_yes_votes,
    )
    # add additional params depending on the proposal type
    @dataclass
    class Params:
        tokenAddress: int
        tokenName: int

    params = Params(tokenAddress=123, tokenName=123)

    await empty_contract.Tokens_set_tokenParams_proxy(
        proposalId, astuple(params)
    ).execute()

    return_value = await empty_contract.executeProposal(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # check if the status of the proposal changed to EXECUTED (=5)
    return_value = await empty_contract.Proposal_get_proposal_status_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    assert return_value.result.status == 5


@pytest.mark.asyncio
async def test_execute_GuildKick_proposal(empty_contract):
    caller_address = 42
    proposalId = 565
    total_yes_votes = 10
    await create_votes(
        empty_contract,
        proposalId,
        "GuildKick",
        caller_address,
        total_yes_votes,
    )
    # add additional params depending on the proposal type
    @dataclass
    class Params:
        memberAddress: int

    params = Params(memberAddress=42)

    await empty_contract.Guildkick_set_guildKickParams_proxy(
        proposalId, astuple(params)
    ).execute()

    # verifie that the member is not jailed before the execute
    return_value = await empty_contract.Member_is_jailed_proxy(
        params.memberAddress
    ).execute()
    assert return_value.result.res == 0

    return_value = await empty_contract.executeProposal(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # check if the status of the proposal changed to EXECUTED (=5)
    return_value = await empty_contract.Proposal_get_proposal_status_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    assert return_value.result.status == 5

    # verifie that the member is jailed after the execute
    return_value = await empty_contract.Member_is_jailed_proxy(
        params.memberAddress
    ).execute()
    assert return_value.result.res == 1

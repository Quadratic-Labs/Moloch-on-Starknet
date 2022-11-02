import pytest
from datetime import datetime
from . import utils

YESVOTE = utils.str_to_felt("yes")
NOVOTE = utils.str_to_felt("no")


@pytest.mark.asyncio
async def test_non_member(contract):
    # voting as a non-member should fail
    caller_address = 404  # not a member
    proposalId = 1
    onBehalf = 1
    with pytest.raises(Exception):
        await contract.submitVote(
            proposalId=proposalId, vote=YESVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_non_existing_proposal(contract):
    # voting on a non-existing proposal should fail
    caller_address = 42
    proposalId = 404
    onBehalf = 1

    with pytest.raises(Exception):
        await contract.submitVote(
            proposalId=proposalId, vote=YESVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_outside_voting_period(contract):
    # voting outside the voting period should fail
    caller_address = 42
    proposalId = 3  # voting period ended in Aug 01 2022 00:00:00
    onBehalf = 1

    with pytest.raises(Exception):
        await contract.submitVote(
            proposalId=proposalId, vote=YESVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_vote_for_yourself(contract):
    # create a proposal for the purpose of the tests

    proposal = (
        8,  # id
        utils.str_to_felt("titre"),  # type # 22357892214649444 = Onboard
        utils.str_to_felt("Signaling"),  # type
        3,  # submittedBy
        50,  # submittedAt
        1,  # status # 1 = SUBMITTED
        1,  # link
    )
    await contract.Proposal_add_proposal_proxy(proposal).execute()

    # voting 1 on an existing proposal should succeed
    caller_address = 42
    proposalId = 8
    onBehalf = 42

    return_value = await contract.submitVote(
        proposalId=proposalId, vote=YESVOTE, onBehalf=onBehalf
    ).execute(caller_address=caller_address)
    assert return_value.result.success == 1
    # checking the vote is 1
    check_vote = await contract.Proposal_get_vote_proxy(
        id=proposalId, address=caller_address
    ).execute(caller_address=caller_address)
    assert check_vote.result.vote == YESVOTE

    # vote again on the same proposal, should fail
    with pytest.raises(Exception):
        await contract.submitVote(
            proposalId=proposalId, vote=NOVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_vote_for_yourself_when_delegated(contract):
    # create a proposal for the purpose of the tests

    proposal = (
        8,  # id
        utils.str_to_felt("titre"),  # type # 22357892214649444 = Onboard
        utils.str_to_felt("Signaling"),  # type
        3,  # submittedBy
        50,  # submittedAt
        1,  # status # 1 = SUBMITTED
        1,  # link
    )
    await contract.Proposal_add_proposal_proxy(proposal).execute()

    # voting 1 on an existing proposal should succeed
    caller_address = 42
    proposalId = 8
    onBehalf = 42
    # add delegate key
    delegated_key = 1
    await contract.delegateVote(delegated_key).execute(caller_address=caller_address)
    # vote for yourself when having a delegate key should fail
    with pytest.raises(Exception):
        await contract.submitVote(
            proposalId=proposalId, vote=NOVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_vote_on_behalf(contract):
    # create a proposal for the purpose of the tests
    proposal = (
        8,  # id
        utils.str_to_felt("titre"),  # type # 22357892214649444 = Onboard
        utils.str_to_felt("Signaling"),  # type
        3,  # submittedBy
        50,  # submittedAt
        1,  # status # 1 = SUBMITTED
        1,  # link
    )
    await contract.Proposal_add_proposal_proxy(proposal).execute()

    # voting 1 on an existing proposal should succeed
    caller_address = 42
    proposalId = 8
    onBehalf = 1

    # adding delegate key
    # add delegate key
    delegated_key = 42
    await contract.delegateVote(delegated_key).execute(caller_address=1)

    return_value = await contract.submitVote(
        proposalId=proposalId, vote=YESVOTE, onBehalf=onBehalf
    ).execute(caller_address=caller_address)
    assert return_value.result.success == 1
    # checking the vote is 1
    check_vote = await contract.Proposal_get_vote_proxy(
        id=proposalId, address=onBehalf
    ).execute(caller_address=caller_address)
    assert check_vote.result.vote == YESVOTE

    # vote again on the same proposal, should fail
    with pytest.raises(Exception):
        await contract.submitVote(
            proposalId=proposalId, vote=NOVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_vote_on_behalf_when_not_delegated(contract):
    # create a proposal for the purpose of the tests
    proposal = (
        8,  # id
        utils.str_to_felt("titre"),  # type # 22357892214649444 = Onboard
        utils.str_to_felt("Signaling"),  # type
        3,  # submittedBy
        50,  # submittedAt
        1,  # status # 1 = SUBMITTED
        1,  # link
    )
    await contract.Proposal_add_proposal_proxy(proposal).execute()

    caller_address = 42
    proposalId = 8
    onBehalf = 1

    # vote  should fail
    with pytest.raises(Exception):
        await contract.submitVote(
            proposalId=proposalId, vote=NOVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)

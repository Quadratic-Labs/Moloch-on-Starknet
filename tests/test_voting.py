import pytest
from datetime import datetime
from . import utils


@pytest.mark.asyncio
async def test_non_member(contract):
    # voting as a non-member should fail
    caller_address = 404  # not a member
    proposalId = 1
    with pytest.raises(Exception):
        await contract.submitVote(proposalId=proposalId, vote=True).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_non_existing_proposal(contract):
    # voting on a non-existing proposal should fail
    caller_address = 42
    proposalId = 404
    with pytest.raises(Exception):
        await contract.submitVote(proposalId=proposalId, vote=True).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_outside_voting_period(contract):
    # voting outside the voting period should fail
    caller_address = 42
    proposalId = 3  # voting period ended in Aug 01 2022 00:00:00
    with pytest.raises(Exception):
        await contract.submitVote(proposalId=proposalId, vote=True).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_vote(contract):
    # create a proposal for the purpose of the tests

    proposal = (
        8,  # id
        utils.str_to_felt("Onboard"),  # type # 22357892214649444 = Onboard
        3,  # submittedBy
        int(datetime.timestamp(datetime.now())),  # submittedAt
        3,  # yesVotes
        4,  # noVotes
        1,  # status # 1 = SUBMITTED
        1,  # description
    )
    await contract.Proposal_add_proposal_proxy(proposal).execute()

    # voting 1 on an existing proposal should succeed
    caller_address = 42
    proposalId = 8
    return_value = await contract.submitVote(proposalId=proposalId, vote=True).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1
    # checking the vote is 1
    check_vote = await contract.Proposal_get_vote_proxy(
        id=proposalId, address=caller_address
    ).execute(caller_address=caller_address)
    assert check_vote.result.vote == 1

    # vote again on the same proposal, 0 this time

    return_value = await contract.submitVote(proposalId=proposalId, vote=False).execute(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # checking the vote is now 0
    check_vote = await contract.Proposal_get_vote_proxy(
        id=proposalId, address=caller_address
    ).execute(caller_address=caller_address)
    assert check_vote.result.vote == 0

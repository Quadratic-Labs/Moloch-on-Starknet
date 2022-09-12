import pytest


@pytest.mark.asyncio
async def test_non_member(contract):
    # voting as a non-member should fail
    caller_address = 404  # not a member
    proposalId = 1
    with pytest.raises(Exception):
        await contract.submitVote(proposalId=proposalId, vote=True).invoke(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_non_existing_proposal(contract):
    # voting on a non-existing proposal should fail
    caller_address = 42
    proposalId = 404
    with pytest.raises(Exception):
        await contract.submitVote(proposalId=proposalId, vote=True).invoke(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_outside_voting_period(contract):
    # voting outside the voting period should fail
    caller_address = 42
    proposalId = 3  # voting period ended in Aug 01 2022 00:00:00
    with pytest.raises(Exception):
        await contract.submitVote(proposalId=proposalId, vote=True).invoke(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_vote(contract):
    # voting 1 on an existing proposal should succeed
    caller_address = 42
    proposalId = 1
    return_value = await contract.submitVote(proposalId=proposalId, vote=True).invoke(
        caller_address=caller_address
    )
    assert return_value.result.success == 1
    # checking the vote is 1
    check_vote = await contract.get_vote(id=proposalId, address=caller_address).invoke(
        caller_address=caller_address
    )
    assert check_vote.result.vote == 1

    # vote again on the same proposal, 0 this time

    return_value = await contract.submitVote(proposalId=proposalId, vote=False).invoke(
        caller_address=caller_address
    )
    assert return_value.result.success == 1

    # checking the vote is now 0
    check_vote = await contract.get_vote(id=proposalId, address=caller_address).invoke(
        caller_address=caller_address
    )
    assert check_vote.result.vote == 0

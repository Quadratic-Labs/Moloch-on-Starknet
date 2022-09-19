import pytest
from datetime import datetime
from . import utils


@pytest.mark.asyncio
async def test_not_member(contract):
    # given caller is not a member, when invoking launch_tally, should fail
    caller_address = 404  # not a member
    proposalId = 0
    with pytest.raises(Exception):
        await contract.launch_tally(proposalId=proposalId).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_non_existing_proposal(contract):
    # given proposal does not exists, when invoking launch_tally or should_accept, should fail
    caller_address = 42
    proposalId = 404  # non existing proposal
    with pytest.raises(Exception):
        await contract.launch_tally(proposalId=proposalId).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_grace_period_not_ended(contract):
    # create a proposal for the purpose of the tests

    proposal = (
        9,  # id
        utils.str_to_felt("Onboard"),  # type # 22357892214649444 = Onboard
        3,  # submittedBy
        int(datetime.timestamp(datetime.now())),  # submittedAt
        3,  # yesVotes
        4,  # noVotes
        1,  # status # 1 = SUBMITTED
        1,  # description
    )
    await contract.Proposal_add_proposal_proxy(proposal).execute()

    # given proposal has not ended grace period, when invoking launch_tally, should fail
    caller_address = 42
    proposalId = 9  # proposal with grace period not ended ends on Sep 01 2022 00:00:00
    with pytest.raises(Exception):
        await contract.launch_tally(proposalId=proposalId).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_did_not_reach_majority(contract):
    # given votes has not reached majority, when invoking should_accept or launch_tally, should return False
    caller_address = 42  # admin
    proposalId = 4  # Submitted and didn't reach majority
    return_value = await contract.launch_tally(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    assert return_value.result.accepted == 0


@pytest.mark.asyncio
async def test_did_not_reach_quorum(contract):
    # given votes has not reached quorum, when invoking should_accept or launch_tally, should return False
    caller_address = 42  # admin
    proposalId = 5  # Submitted and didn't reach quorom
    return_value = await contract.launch_tally(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    assert return_value.result.accepted == 0


@pytest.mark.asyncio
async def test_accepted(contract):
    # given votes has both majority and quorum, when invoking should_accept or launch_tally, should return True
    caller_address = 42  # admin
    proposalId = 6  # Submitted and reached quorom and majority

    proposal_before_apply = await contract.Proposal_get_proposal_by_id_proxy(
        id=proposalId
    ).execute()
    # check if the status of the proposal is indeed "submitted"
    assert proposal_before_apply.result.proposal.status == 1

    return_value = await contract.launch_tally(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    # check if the proposal was accepted
    assert return_value.result.accepted == 1

    proposal_after_apply = await contract.Proposal_get_proposal_by_id_proxy(
        id=proposalId
    ).execute()
    # check if the status of the proposal changed to "accepted"
    assert proposal_after_apply.result.proposal.status == 2


@pytest.mark.asyncio
async def test_rejected(contract):
    # given votes has both majority and quorum, when invoking should_accept or launch_tally, should return True
    caller_address = 42  # admin
    proposalId = 7  # Submitted and reached quorom and majority

    proposal_before_apply = await contract.Proposal_get_proposal_by_id_proxy(
        id=proposalId
    ).execute()
    # check if the status of the proposal is indeed "submitted"
    assert proposal_before_apply.result.proposal.status == 1

    return_value = await contract.launch_tally(proposalId=proposalId).execute(
        caller_address=caller_address
    )
    # check if the proposal was accepted
    assert return_value.result.accepted == 0

    proposal_after_apply = await contract.Proposal_get_proposal_by_id_proxy(
        id=proposalId
    ).execute()
    # check if the status of the proposal changed to "rejected"
    assert proposal_after_apply.result.proposal.status == 3

import pytest
from datetime import datetime
from . import utils

YESVOTE = utils.str_to_felt("yes")
NOVOTE = utils.str_to_felt("no")


async def create_votes(
    empty_contract,
    proposalId,
    caller_address,
    total_yes_votes,
    total_no_votes,
    total_non_voting_members,
):
    proposal = (
        proposalId,  # id
        utils.str_to_felt("titre"),  # type # 22357892214649444 = Onboard
        utils.str_to_felt("Signaling"),  # type
        3,  # submittedBy
        -20,  # submittedAt
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

    for i in range(total_no_votes):
        caller_address = i + 6666  # add 6666 to avoid already used adress for members
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
        # vote no for the proposal
        await empty_contract.Proposal_set_vote_proxy(
            id=proposalId, address=caller_address, vote=NOVOTE
        ).execute(caller_address=caller_address)

    for i in range(total_non_voting_members):
        # voting 1 on an existing proposal should succeed
        caller_address = i + 7777  # add 7777 to avoid already used adress for members
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


@pytest.mark.asyncio
async def test_not_member(empty_contract):
    # given caller is not a member, when invoking Tally__tally_proxy, should fail
    caller_address = 404  # not a member
    proposalId = 0
    with pytest.raises(Exception):
        await empty_contract.Tally__tally_proxy(proposalId=proposalId).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_non_existing_proposal(empty_contract):
    # given proposal does not exists, when invoking Tally__tally_proxy or should_accept, should fail
    caller_address = 42
    proposalId = 404  # non existing proposal
    with pytest.raises(Exception):
        await empty_contract.Tally__tally_proxy(proposalId=proposalId).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_grace_period_not_ended(empty_contract):
    # create a proposal for the purpose of the tests

    proposal = (
        9,  # id
        utils.str_to_felt("title"),  # title
        utils.str_to_felt("Signaling"),  # type
        3,  # submittedBy
        50,  # submittedAt
        1,  # status # 1 = SUBMITTED
        1,  # description
    )
    await empty_contract.Proposal_add_proposal_proxy(proposal).execute()

    # given proposal has not ended grace period, when invoking Tally__tally_proxy, should fail
    caller_address = 42
    proposalId = 9  # proposal with grace period not ended ends on Sep 01 2022 00:00:00
    with pytest.raises(Exception):
        await empty_contract.Tally__tally_proxy(proposalId=proposalId).execute(
            caller_address=caller_address
        )


@pytest.mark.asyncio
async def test_did_not_reach_majority(empty_contract):
    # given votes has not reached majority, when invoking should_accept or Tally__tally_proxy, should return False
    caller_address = 42  # admin
    proposalId = 45  # Submitted and didn't reach majority

    # create a proposal that reached quorom but not majority
    await create_votes(
        empty_contract=empty_contract,
        proposalId=proposalId,
        caller_address=caller_address,
        total_yes_votes=4,
        total_no_votes=5,
        total_non_voting_members=0,
    )

    return_value = await empty_contract.Tally__tally_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    assert return_value.result.accepted == 0


@pytest.mark.asyncio
async def test_did_not_reach_quorum(empty_contract):
    # given votes has not reached quorum, when invoking should_accept or Tally__tally_proxy, should return False
    caller_address = 42  # admin
    proposalId = 98  # Submitted and didn't reach majority

    await create_votes(
        empty_contract=empty_contract,
        proposalId=proposalId,
        caller_address=caller_address,
        total_yes_votes=2,
        total_no_votes=2,
        total_non_voting_members=5,
    )
    return_value = await empty_contract.Tally__tally_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    assert return_value.result.accepted == 0


@pytest.mark.asyncio
async def test_accepted(empty_contract):
    # given votes has both majority and quorum, when invoking should_accept or Tally__tally_proxy, should return True
    caller_address = 42  # admin
    proposalId = 454  # Submitted and didn't reach majority

    await create_votes(
        empty_contract=empty_contract,
        proposalId=proposalId,
        caller_address=caller_address,
        total_yes_votes=5,
        total_no_votes=2,
        total_non_voting_members=0,
    )
    proposal_before_apply = await empty_contract.Proposal_get_info_proxy(
        id=proposalId
    ).execute()
    # check if the status of the proposal is indeed "submitted"
    assert proposal_before_apply.result.proposal.status == 1

    return_value = await empty_contract.Tally__tally_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    # check if the proposal was accepted
    assert return_value.result.accepted == 1

    proposal_after_apply = await empty_contract.Proposal_get_info_proxy(
        id=proposalId
    ).execute()
    # check if the status of the proposal changed to "accepted"
    assert proposal_after_apply.result.proposal.status == 2


@pytest.mark.asyncio
async def test_rejected(empty_contract):
    # given votes has both majority and quorum, when invoking should_accept or Tally__tally_proxy, should return True
    caller_address = 42  # admin
    proposalId = 454  # Submitted and didn't reach majority

    await create_votes(
        empty_contract=empty_contract,
        proposalId=proposalId,
        caller_address=caller_address,
        total_yes_votes=2,
        total_no_votes=5,
        total_non_voting_members=0,
    )

    proposal_before_apply = await empty_contract.Proposal_get_info_proxy(
        id=proposalId
    ).execute()
    # check if the status of the proposal is indeed "submitted"
    assert proposal_before_apply.result.proposal.status == 1

    return_value = await empty_contract.Tally__tally_proxy(
        proposalId=proposalId
    ).execute(caller_address=caller_address)
    # check if the proposal was accepted
    assert return_value.result.accepted == 0

    proposal_after_apply = await empty_contract.Proposal_get_info_proxy(
        id=proposalId
    ).execute()
    # check if the status of the proposal changed to "rejected"
    assert proposal_after_apply.result.proposal.status == 3

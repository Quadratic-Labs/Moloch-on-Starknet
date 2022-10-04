import pytest
from . import utils

YESVOTE = utils.str_to_felt("yes")
NOVOTE = utils.str_to_felt("no")


@pytest.mark.asyncio
async def test_get_total_votes(contract):
    total_yes_votes = 10
    total_no_votes = 42
    proposalId = 8

    # create a proposal for the purpose of tests
    proposal = (
        proposalId,  # id
        utils.str_to_felt("titre"),  # type # 22357892214649444 = Onboard
        utils.str_to_felt("Signaling"),  # type
        3,  # submittedBy
        50,  # submittedAt
        1,  # status # 1 = SUBMITTED
        1,  # description
    )
    await contract.Proposal_add_proposal_proxy(proposal).execute()

    # check if the total votes are equal to 0 at init
    return_value = await contract.Tally_get_total_votes_proxy(
        proposalId=proposalId, voteType=YESVOTE
    ).execute()
    assert return_value.result.count == 0

    return_value = await contract.Tally_get_total_votes_proxy(
        proposalId=proposalId, voteType=NOVOTE
    ).execute()
    assert return_value.result.count == 0

    # create members and votes for the tests
    for i in range(total_yes_votes):
        # voting 1 on an existing proposal should succeed
        caller_address = i + 5555  # add 5555 to avoid already used adress for members
        onBehalf = caller_address
        # create the member
        await contract.Member_add_member_proxy(
            (caller_address, caller_address, 1, 1, 1, 1)
        ).execute()
        # vote yes for the proposal
        await contract.submitVote(
            proposalId=proposalId, vote=YESVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)

    for i in range(total_no_votes):
        # voting 1 on an existing proposal should succeed
        caller_address = i + 6666  # add 6666 to avoid already used adress for members
        onBehalf = caller_address
        # create the member
        await contract.Member_add_member_proxy(
            (caller_address, caller_address, 1, 1, 1, 1)
        ).execute()
        # vote no for the proposal
        await contract.submitVote(
            proposalId=proposalId, vote=NOVOTE, onBehalf=onBehalf
        ).execute(caller_address=caller_address)

    # check if the new totals are correct
    return_value = await contract.Tally_get_total_votes_proxy(
        proposalId=proposalId, voteType=YESVOTE
    ).execute()
    assert return_value.result.count == total_yes_votes

    return_value = await contract.Tally_get_total_votes_proxy(
        proposalId=proposalId, voteType=NOVOTE
    ).execute()
    assert return_value.result.count == total_no_votes

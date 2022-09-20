import pytest
from dataclasses import dataclass, astuple

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.


@dataclass
class Member:
    address: int
    accountKey: int
    shares: int
    loot: int
    # jailed: int not needed for now
    # lastProposalYesVote: int not needed for now


@pytest.mark.asyncio
async def test_not_admin(contract):
    # given caller is not admin, after submitting any user, should fail
    caller_address = 3  # not admin
    member = Member(
        address=123,
        accountKey=123,
        shares=10,
        loot=10,
    )

    with pytest.raises(Exception):
        await contract.submitOnboard(
            address=member.address,
            accountKey=member.accountKey,
            shares=member.shares,
            loot=member.loot,
            description=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_already_member(contract):
    # given the user is already a member, after submitting the user, should fail
    caller_address = 42  # admin

    member = Member(address=3, accountKey=3, shares=10, loot=10)  # existing member
    with pytest.raises(Exception):
        await contract.submitOnboard(
            address=member.address,
            accountKey=member.accountKey,
            shares=member.shares,
            loot=member.loot,
            description=123456789,
        ).execute(caller_address=caller_address)


@pytest.mark.asyncio
async def test_submit_onboard(contract):
    # given the user is not a member and the caller is admin, should record the proposal accordingly
    caller_address = 42  # admin

    member = Member(  # non existing member
        address=123,
        accountKey=123,
        shares=10,
        loot=10,
    )

    number_before_submit = (
        await contract.Proposal_get_proposals_length_proxy().call(
            caller_address=caller_address
        )
    ).result.length
    return_value = await contract.submitOnboard(
        address=member.address,
        accountKey=member.accountKey,
        shares=member.shares,
        loot=member.loot,
        description=123456789,
    ).execute(caller_address=caller_address)
    assert return_value.result.success == 1

    number_after_submit = (
        await contract.Proposal_get_proposals_length_proxy().call(
            caller_address=caller_address
        )
    ).result.length

    # Check if the proposal was taken into account
    assert number_after_submit == number_before_submit + 1

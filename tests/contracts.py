from dataclasses import dataclass, astuple
import enum


@dataclass
class Member:
    address: int
    accountKey: int
    shares: int
    loot: int
    jailed: int
    lastProposalYesVote: int


# @enum.Enum
# class PrpoposalStatus:
#     SUBMITTED = 1
#     ACCEPTED = 2  # Can proceed to execution if any actions
#     # The remaining states are final
#     REJECTED = 3
#     ABORTED = 4  # Did not go completely through voting
#     EXECUTED = 5  # Execution is finalised and successful
#     FAILED = 6  # Execution failed


@dataclass
class Proposal:
    id: int
    type: int
    submittedBy: int
    submittedAt: int
    votingEndsAt: int
    graceEndsAt: int
    expiresAt: int
    quorum: int
    majority: int
    yesVotes: int
    noVotes: int
    status: int
    description: int


MEMBERS: list[Member] = [
    Member(
        address=1,
        accountKey=1,
        shares=5,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
    ),
    Member(
        address=2,
        accountKey=1,
        shares=5,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
    ),
    Member(
        address=3,
        accountKey=1,
        shares=10,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
    ),
    Member(
        address=4,
        accountKey=1,
        shares=50,
        loot=0,
        jailed=1,
        lastProposalYesVote=1,
    ),
    Member(
        address=5,
        accountKey=1,
        shares=5,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
    ),
]

govern = 1
admin = 0

MEMBER_ROLES = {
    1: [admin],
    2: [admin, govern],
    3: [govern],
    4: [govern],
    5: [],
}

PROPOSALS: list[Proposal] = [
    Proposal(
        id=1,
        type=1,
        submittedBy=1,
        submittedAt=1,
        votingEndsAt=1,
        graceEndsAt=1,
        expiresAt=1,
        quorum=1,
        majority=1,
        yesVotes=1,
        noVotes=1,
        status=1,
        description=1,
    ),
    Proposal(
        id=2,
        type=1,
        submittedBy=1,
        submittedAt=1,
        votingEndsAt=1,
        graceEndsAt=1,
        expiresAt=1,
        quorum=1,
        majority=1,
        yesVotes=1,
        noVotes=1,
        status=1,
        description=1,
    ),
]


# TODO: default values for list and dicts is discouraged
def populate_contract(
    contract,
    members: list[Member] = [],
    member_roles: dict[int, list[int]] = {},
    proposals: list[Proposal] = [],
):
    for member in members:
        contract.add_member(astuple(member)).invoke()

        for role in member_roles[member.address]:
            contract.add_role(role, member.address).invoke()

    for proposal in proposals:
        contract.add_proposal(astuple(proposal)).invoke()

    return contract


def populate_generic_contract(contract):
    return populate_contract(
        contract=contract,
        members=MEMBERS,
        member_roles=MEMBER_ROLES,
        proposals=PROPOSALS,
    )

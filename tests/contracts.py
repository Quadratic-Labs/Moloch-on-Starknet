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
        accountKey=2,
        shares=5,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
    ),
    Member(
        address=3,
        accountKey=3,
        shares=10,
        loot=5,
        jailed=0,
        lastProposalYesVote=1,
    ),
    Member(
        address=4,
        accountKey=4,
        shares=50,
        loot=0,
        jailed=1,
        lastProposalYesVote=1,
    ),
    Member(
        address=5,
        accountKey=5,
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
    Proposal( # Submitted and vote + grace open
        id=1,
        type=1,
        submittedBy=1,
        submittedAt=1,
        votingEndsAt=1664575200, #Oct 01 2022 00:00:00
        graceEndsAt=1661983200, #Sep 01 2022 00:00:00
        expiresAt=1,
        quorum=3,
        majority=3,
        yesVotes=0,
        noVotes=0,
        status=1, # SUBMITTED
        description=1,
    ),
    Proposal(# ACCEPTED and vote closed
        id=2,
        type=1,
        submittedBy=3,
        submittedAt=1,
        votingEndsAt=1659304800, #Aug 01 2022 00:00:00
        graceEndsAt=1656626400,  #Jul 01 2022 00:00:00
        expiresAt=1,
        quorum=2,
        majority=3,
        yesVotes=3,
        noVotes=2,
        status=2, #ACCEPTED
        description=1,
    ),    
    Proposal(# Rejected and vote closed
        id=3,
        type=1,
        submittedBy=1,
        submittedAt=1,
        votingEndsAt=1659304800, #Aug 01 2022 00:00:00
        graceEndsAt=1656626400,  #Jul 01 2022 00:00:00
        expiresAt=1,
        quorum=3,
        majority=3,
        yesVotes=2,
        noVotes=3,
        status=3, #REJECTED
        description=1,
    ),
    Proposal( # Submitted and vote open + grace closed
        id=4,
        type=1,
        submittedBy=3,
        submittedAt=1,
        votingEndsAt=1664575200, #Oct 01 2022 00:00:00
        graceEndsAt=1659304800, #Aug 01 2022 00:00:00
        expiresAt=1,
        quorum=3,
        majority=3,
        yesVotes=0,
        noVotes=0,
        status=1, # SUBMITTED
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

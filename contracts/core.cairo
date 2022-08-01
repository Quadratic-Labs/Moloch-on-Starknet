%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin


# CONSTANTS AND ENUMS
# -------------------

# ProposalStates
const SUBMITTED = 1
const ACCEPTED = 2
const REJECTED = 3
const ABORTED = 4
const VETOED = 5
# ActionStates
const PROCESSED = 6
const FAILED = 7


# Roles
# Binary repr of a list: e.g. ADMIN and MANAGE is stored as 3 (1+2)
const GOVERN = 1 
const MANAGE = 2
const ADMIN = 4


# TYPES
# -----

# Proposal's General Type
struct Proposal:
	member id: felt
	member type: felt
	member submittedBy: felt
	member submittedAt: felt
	member votingEndsAt: felt
	member graceEndsAt: felt
	member expiresAt: felt
	member quorum: felt
	member majority: felt
	member yesVotes: felt
	member noVotes: felt
	member status: felt
	member description: felt
end


# Member's General Type
struct Member:
    member address: felt
    member accountKey: felt  # aka deleguatedKey
	member roles: felt
	member shares: felt
	member loot: felt
	member jailed: felt
	member lastProposalYesVote: felt  # may be needed, we will see
end


# PARAMETERS
# ----------

@storage_var
func minMajority(proposalType: felt) -> (minMajority: felt):
end

@storage_var
func minQuorum(proposalType: felt) -> (minQuorum: felt):
end

@storage_var
func minVotingDuration(proposalType: felt) -> (duration: felt):
	# Duration should be in hours
end

@storage_var
func minGraceDuration(proposalType: felt) -> (duration: felt):
	# Duration should be in hours
end


# MEMBERS MAPPINGS
# ----------------
# Members are kept as a mapping with keys form address to member.
# So we need three components: the length, the list of keys, and the mapping


@storage_var
func membersLength() -> (length: felt):
end

@storage_var
func membersAddresses(index: felt) -> (address: felt):
end

@storage_var
func members(address: felt) -> (member_: Member):
end

# Members are declined also by roles in the same way

# Admin
@storage_var
func administratorsLength() -> (length: felt):
end

@storage_var
func administratorsAddresses(index: felt) -> (address: felt):
end

@storage_var
func administrators(address: felt) -> (member_: Member):
end

# Manage
@storage_var
func managersLength() -> (length: felt):
end

@storage_var
func managersAddresses(index: felt) -> (address: felt):
end

@storage_var
func managers(address: felt) -> (member_: Member):
end

# Govern
@storage_var
func governorsLength() -> (length: felt):
end

@storage_var
func governorsAddresses() -> (address: felt):
end

@storage_var
func governors(address: felt) -> (member_: Member):
end


# PROPOSALS
# ---------

# Governor
@external
func submitOrder() -> ():
	return ()
end

# Governor
@external
func submitGuildKick() -> ():
	return ()
end

# Manager
@external
func submitOnboard() -> ():
	return ()
end

# Manager
@external
func submitApproveToken() -> ():
	return ()
end

# Manager
@external
func submitRemoveToken() -> ():
	return ()
end


# VOTING
# ------
@external
func submitVote() -> ():
	return ()
end

@external
func submitVoteWithSig() -> ():
	return ()
end

func votesCounting() -> ():
	return ()
end

func processProposal() -> ():
	return ()
end

# RAGEQUIT
# --------
@external
func ragequit() -> ():
	return ()
end

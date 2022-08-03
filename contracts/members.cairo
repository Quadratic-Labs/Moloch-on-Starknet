%lang starknet


struct Member:
    member address: felt
    member accountKey: felt  # aka deleguatedKey
    member shares: felt
    member loot: felt
    member jailed: felt
    member lastProposalYesVote: felt  # may be needed, we will see
end


@storage_var
func membersLength() -> (length: felt):
end

@storage_var
func membersAddresses(index: felt) -> (address: felt):
end

@storage_var
func members(address: felt) -> (member_: Member):
end

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE


namespace Member:
    # No pointers in Info please
    struct Info:
        member address: felt
        member accountKey: felt  # aka deleguatedKey
        member shares: felt
        member loot: felt
        member jailed: felt
        member lastProposalYesVote: felt  # may be needed, we will see
    end

    func get_info{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> (member_: Info):
        let (user: Info) = membersInfo.read(address)
        return (user)
    end

    func is_member{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> (res: felt):
        # Modify using recursion so it compiles
        # for (i in range(membersLength.read()):
        #     if membersAddresses.read(i) == address:
        #         return (TRUE)
        #     end
        # end
        if membersAddresses.read(0) == address:
            return (TRUE)
        end
        return (FALSE)
    end

    # Implementer les getter, setter, contains, blah blah de members
end


@storage_var
func membersLength() -> (length: felt):
end

@storage_var
func membersAddresses(index: felt) -> (address: felt):
end

@storage_var
func membersInfo(address: felt) -> (member_: Member.Info):
end

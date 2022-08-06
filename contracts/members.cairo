%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_nn, assert_lt


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

    func is_member{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> ():
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

    func assert_is_member{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> ():
        with_attr error_message("Address {address} is not a member"):
            assert is_member(address) = TRUE
        end
        return ()
    end

    func assert_within_bounds{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt) -> ():
        let (len: felt) = membersLength.read()
        with_attr error_message("Member's key index {id} out of bounds"):
            assert_nn(id)
            assert_lt(id, len)
        end
    end

    func get_address{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt) -> (address: felt):
        assert_within_bounds(id)
        let (address: felt) = membersAddresses.read(id)
        return (address)
    end

    func get_info{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> (member_: Info):
        assert_is_member(address)
        let (user: Info) = membersInfo.read(address)
        return (user)
    end

    func add{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(info: Info) -> ():
        let (is_in: felt) = is_member(info.address)
        with_attr error_message("Cannot add {address}: already in DAO"):
            assert is_in = FALSE
        end
        let (len: felt) = membersLength.read()
        membersInfo.write(info.address, info)
        membersAddresses.write(len, info.address)
        membersLength.write(len+1)
        return ()
    end

    func is_jailed{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> (res: felt):
    end

    func assert_not_jailed{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> ():
        with_attr error_message("Member {address} has been jailed"):
            assert is_jailed = FALSE
        end
        return ()
    end

    func jail{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> ():
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

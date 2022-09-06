%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_nn, assert_lt


namespace Member:
    # No pointers in InfoMember please
    struct InfoMember:
        member address: felt
        member delegatedKey: felt
        member shares: felt
        member loot: felt
        member jailed: felt
        member lastProposalYesVote: felt  # may be needed, we will see
    end


    func is_member{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> (success : felt):
        let current_number = 0
        let (length) = membersLength.read()
        return contains(address, current_number, length)
    end

    func contains{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(value : felt, current_number : felt, length : felt) -> (success : felt):
        alloc_locals
        if length == 0:
            return (FALSE)
        end

        if length == current_number :
            return (FALSE)
        end
        let  (current_adress) = membersAddresses.read(current_number)
        if  current_adress == value :
            return (TRUE)
        end
        let (local res) = contains(value, current_number + 1, length)
        return (res)
    end

    func assert_is_member{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> ():
        with_attr error_message("Address {address} is not a member"):
            let (res) = is_member(address)
            assert res = TRUE
        end
        return ()
    end

    func assert_within_bounds_members{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt) -> ():
        let (len: felt) = membersLength.read()
        with_attr error_message("Member's key index {id} out of bounds"):
            assert_nn(id)
            assert_lt(id, len)
        end

        return ()
    end

    func get_address{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(id: felt) -> (address: felt):
        assert_within_bounds_members(id)
        let (address: felt) = membersAddresses.read(id)
        return (address)
    end

    func get_info_members{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> (member_: InfoMember):
        assert_is_member(address)
        let (user: InfoMember) = membersInfo.read(address)
        return (user)
    end

    func add_member{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(info: InfoMember) -> ():
        alloc_locals
        let (is_in: felt) = is_member(info.address)
        with_attr error_message("Cannot add {info.address}: already in DAO"):
            assert is_in = FALSE
        end
        let (local len: felt) = membersLength.read()
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
        return (0)
    end

    func assert_not_jailed{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> ():
        with_attr error_message("Member {address} has been jailed"):
            let (res) = is_jailed(address)
            assert res = FALSE
        end
        return ()
    end

    func jail{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(address: felt) -> ():
        return ()
    end

    func get_membersLength{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }() -> (length: felt):
        let (length) = membersLength.read()
        return (length)
    end


end


@storage_var
func membersLength() -> (length: felt):
end

@storage_var
func membersAddresses(index: felt) -> (address: felt):
end

@storage_var
func membersInfo(address: felt) -> (member_: Member.InfoMember):
end

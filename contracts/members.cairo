%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_nn, assert_lt
from starkware.starknet.common.syscalls import get_caller_address


// member's Info must be felt-like (no pointer) as it is put in storage
struct MemberInfo {
    address: felt,
    delegatedKey: felt,
    shares: felt,
    loot: felt,
    jailed: felt,
    lastProposalYesVote: felt,
}

namespace Member {

    // Guards

    func is_member{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> (success: felt) {
        let (len: felt) = total_count();
        return _contains(address, 0, len);
    }

    func _contains{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(value: felt, iter: felt, length: felt) -> (success: felt) {
        alloc_locals;
        if (length == 0) {
            return (FALSE,);
        }
        let (current_address) = membersAddresses.read(iter);
        if (current_address == value) {
            return (TRUE,);
        }
        let (local res) = _contains(value, iter + 1, length - 1);
        return (res,);
    }

    func assert_is_member{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> () {
        with_attr error_message("Address {address} is not a member") {
            let (res) = is_member(address);
            assert res = TRUE;
        }
        return ();
    }

    func assert_is_not_member{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> () {
        with_attr error_message("Address {address} is not a member") {
            let (res) = is_member(address);
            assert res = FALSE;
        }
        return ();
    }

    func assert_within_bounds{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(id: felt) -> () {
        let (len: felt) = membersLength.read();
        with_attr error_message("Member's key index {id} out of bounds") {
            assert_nn(id);
            assert_lt(id, len);
        }
        return ();
    }

    func is_jailed{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> (res: felt) {
        return (0,);
    }

    func assert_not_jailed{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> () {
        with_attr error_message("Member {address} has been jailed") {
            let (res) = is_jailed(address);
            assert res = FALSE;
        }
        return ();
    }

    // Getters-Setters

    func get_address{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(id: felt) -> (address: felt) {
        assert_within_bounds(id);
        let (address: felt) = membersAddresses.read(id);
        return (address,);
    }

    func get_info{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> (member_: MemberInfo) {
        assert_is_member(address);
        let (user: MemberInfo) = membersInfo.read(address);
        return (user,);
    }

    func total_count{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }() -> (length: felt) {
        let (length) = membersLength.read();
        return (length,);
    }

    func add_new{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(info: MemberInfo) -> () {
        alloc_locals;
        let (is_in: felt) = is_member(info.address);
        with_attr error_message("Cannot add {info.address}: already in DAO") {
            assert is_in = FALSE;
        }
        let (local len: felt) = membersLength.read();
        membersLength.write(len + 1);
        membersAddresses.write(len + 1, info.address);
        membersInfo.write(info.address, info);
        return ();
    }

    func update{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(info: MemberInfo) -> () {
        alloc_locals;
        let (is_in: felt) = is_member(info.address);
        with_attr error_message("Cannot update {info.address}: not a member") {
            assert is_in = TRUE;
        }
        membersInfo.write(info.address, info);
        return ();
    }
}


@external
func addDelegatedKey{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(delegatedKey: felt) -> (success: felt) {
    alloc_locals;
    // assert the caller is member
    let (local caller) = get_caller_address();
    Member.assert_is_member(caller);
    // get member's info
    let (local member_) = Member.get_info(caller);
    // create updated member
    let updated_member: MemberInfo = MemberInfo(
        address = caller,
        delegatedKey = delegatedKey,
        shares = member_.shares,
        loot = member_.loot,
        jailed = member_.jailed,
        lastProposalYesVote = member_.lastProposalYesVote
    );
    // update member's info
    Member.update(updated_member);
    return (TRUE,);

}
@external
func revokeDelegatedKey{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }() -> (success: felt) {
    alloc_locals;
     // assert the caller is member
    let (local caller) = get_caller_address();
    Member.assert_is_member(caller);
    // get member's info
    let (local member_) = Member.get_info(caller);
    // create updated member
    let updated_member : MemberInfo = MemberInfo(
        address = caller,
        delegatedKey = caller,
        shares = member_.shares,
        loot = member_.loot,
        jailed = member_.jailed,
        lastProposalYesVote = member_.lastProposalYesVote
    );
    // update member's info
    Member.update(updated_member);
    return (TRUE,);

}
// Mapping address -> members, keeping keys array
@storage_var
func membersLength() -> (length: felt) {
}

@storage_var
func membersAddresses(index: felt) -> (address: felt) {
}

@storage_var
func membersInfo(address: felt) -> (member_: MemberInfo) {
}

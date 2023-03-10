%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_nn, assert_lt
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math_cmp import is_le

@event
func MemberAdded(memberAddress: felt, shares: felt, loot : felt, onboardedAt: felt) {
}

@event
func MemberUpdated(memberAddress: felt, delegateAddress: felt, shares: felt, loot : felt, jailed: felt, lastProposalYesVote: felt, onboardedAt: felt) {
}


// member's Info must be felt-like (no pointer) as it is put in storage
struct MemberInfo {
    address: felt,
    delegateAddress: felt,
    shares: felt,
    loot: felt,
    jailed: felt,
    lastProposalYesVote: felt,
    onboardedAt: felt,
}

namespace Member {

    // Guards

    func is_member{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> (success: felt) {
        
        return _contains(address, 0);
    }

    func _contains{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(value: felt, iter: felt) -> (success: felt) {
        alloc_locals;
        let (local length: felt) = total_count();
        if (length == iter) {
            return (FALSE,);
        }
        let (current_address) = membersAddresses.read(iter);
        if (current_address == value) {
            return (TRUE,);
        }
        let (local res) = _contains(value, iter + 1);
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
        with_attr error_message("Address {address} is already a member") {
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
        let (info) = get_info(address);
        return (info.jailed,);
    }

    func assert_not_jailed{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> () {
        with_attr error_message("Member {address} is already jailed") {
            let (res) = is_jailed(address);
            assert res = FALSE;
        }
        return ();
    }

    // Getters-Setters

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

    func add_member{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(info: MemberInfo) -> () {
        alloc_locals;
        let (is_in: felt) = is_member(info.address);
        with_attr error_message("Cannot add {info.address}: already in DAO") {
            assert is_in = FALSE;
        }
        let (local len: felt) = membersLength.read();
        membersLength.write(len + 1);
        membersAddresses.write(len, info.address);
        membersInfo.write(info.address, info);
        //emit event
        MemberAdded.emit(memberAddress=info.address, shares=info.shares, loot=info.loot, onboardedAt=info.onboardedAt);
        return ();
    }
    func jail_member{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(address: felt) -> () {

        let (member_: MemberInfo) = membersInfo.read(address);
        let updated_member: MemberInfo = MemberInfo(address=member_.address,
                                                    delegateAddress=member_.delegateAddress,
                                                    shares=member_.shares,
                                                    loot=member_.loot,
                                                    jailed=TRUE,
                                                    lastProposalYesVote=member_.lastProposalYesVote);
        update_member(updated_member);
    }

    func update_member{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(info: MemberInfo) -> () {
        alloc_locals;
        let (is_in: felt) = is_member(info.address);
        with_attr error_message("Cannot update {info.address}: not a member") {
            assert is_in = TRUE;
        }
        membersInfo.write(info.address, info);
        MemberUpdated.emit(memberAddress=info.address, delegateAddress=info.delegateAddress, shares=info.shares, loot=info.loot, jailed=info.jailed, lastProposalYesVote=info.lastProposalYesVote, onboardedAt=info.onboardedAt);
        return ();
    }

    func update_last_proposal_yes_vote{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(memberAddress: felt, proposal_id: felt){
        let (member_) = get_info(memberAddress);
        let updated_member: MemberInfo = MemberInfo(
        address = memberAddress,
        delegateAddress = member_.delegateAddress,
        shares = member_.shares,
        loot = member_.loot,
        jailed = member_.jailed,
        lastProposalYesVote = proposal_id,
        onboardedAt = member_.onboardedAt
            );

        update_member(updated_member); 
        return();
    }
    func assert_is_delegate{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(memberAddress: felt) -> (key: felt) {
        alloc_locals;
        let (local caller) = get_caller_address();
        let (local member_) = Member.get_info(memberAddress);
        with_attr error_message("Access: user {caller} is not delagate of {member_.delegateAddress}.") {
            assert caller = member_.delegateAddress;
        }
        return (member_.delegateAddress,);
    }


    func _get_total_shares{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(until_this_block_number : felt, currentIndex: felt, currentTotal: felt) -> (count: felt) {
        // TODO add argument timeblock to retrieve only eligible share before a certain timeblock
        let (member_list_length: felt) = membersLength.read();
        if (currentIndex == member_list_length){
            return (currentTotal,);
        }
        let (current_address: felt) = membersAddresses.read(currentIndex);
        let (member_info) = Member.get_info(current_address);
        let is_eligible = is_le(member_info.onboardedAt, until_this_block_number);
        if (is_eligible == 1){
            let new_total: felt = currentTotal + member_info.shares;
            return _get_total_shares(until_this_block_number, currentIndex+1, new_total);
        }else{
            return _get_total_shares(until_this_block_number, currentIndex+1, currentTotal);
        }
        
    }

    func get_total_shares{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(until_this_block_number: felt) -> (count: felt) {
        return _get_total_shares(until_this_block_number, 0, 0);
    }


    func _get_total_loot{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(currentIndex: felt, currentTotal: felt) -> (count: felt) {
        let (member_list_length: felt) = membersLength.read();
        if (currentIndex == member_list_length){
            return (currentTotal,);
        }
        let (current_address: felt) = membersAddresses.read(currentIndex);
        let (member_info) = Member.get_info(current_address);
        let new_total: felt = currentTotal + member_info.loot;
        return _get_total_loot(currentIndex+1, new_total);
    }

    func get_total_loot{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }() -> (count: felt) {
        return _get_total_loot(0, 0);
    }


}


@external
func delegateVote{
            syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(delegateAddress: felt) -> (success: felt) {
    alloc_locals;
    // assert the caller is member
    let (local caller) = get_caller_address();
    Member.assert_is_member(caller);
    // assert the delegateAddress belong to a member
    Member.assert_is_member(delegateAddress);
    // get member's info
    let (local member_) = Member.get_info(caller);
    // create updated member
    let updated_member: MemberInfo = MemberInfo(
        address = caller,
        delegateAddress = delegateAddress,
        shares = member_.shares,
        loot = member_.loot,
        jailed = member_.jailed,
        lastProposalYesVote = member_.lastProposalYesVote,
        onboardedAt = member_.onboardedAt
    );
    // update member's info
    Member.update_member(updated_member);
    return (TRUE,);

}
@external
func revokeDelegate{
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
        delegateAddress = caller,
        shares = member_.shares,
        loot = member_.loot,
        jailed = member_.jailed,
        lastProposalYesVote = member_.lastProposalYesVote,
        onboardedAt = member_.onboardedAt

    );
    // update member's info
    Member.update_member(updated_member);
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

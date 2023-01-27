// Based on OpenZeppelin Contracts for Cairo v0.2.1 (access/accesscontrol/library.cairo)

%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE

// Events
// ------

@event
func RoleGranted(account: felt, role: felt, sender: felt) {
}

@event
func RoleRevoked(account: felt, role: felt, sender: felt) {
}

@event
func RoleAdminChanged(role: felt, previousAdminRole: felt, newAdminRole: felt) {
}

// Storage
// -------

// For a given role, specifies the role that can administor it
@storage_var
func adminRoles(role: felt) -> (admin: felt) {
}

// Roles assigned to members
@storage_var
func membersRoles(user: felt, role: felt) -> (has_role: felt) {
}

namespace Roles {
    func _grant_role{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user: felt, role: felt
    ) {
        let (caller: felt) = get_caller_address();
        membersRoles.write(user, role, TRUE);
        RoleGranted.emit(user, role, caller);
        return ();
    }

    func _revoke_role{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user: felt, role: felt
    ) {

        let (caller: felt) = get_caller_address();
        membersRoles.write(user, role, FALSE);
        RoleRevoked.emit(user, role, caller);
        return ();
    }

    func has_role{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        user: felt, role: felt
    ) -> (has_role: felt) {
        let (authorized: felt) = membersRoles.read(user, role);
        return (authorized,);
    }

    func require_role{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(role: felt) {
        alloc_locals;
        let (caller) = get_caller_address();
        let (authorized) = has_role(caller, role);
        with_attr error_message("AccessControl: caller is missing role {role}") {
            assert authorized = TRUE;
        }
        return ();
    }
}


@external
func grant_role{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(role: felt, user: felt) -> () {
    let (admin: felt) = adminRoles.read(role);
    Roles.require_role(admin);
    let (user_has_role: felt) = Roles.has_role(user, role);
    if (user_has_role == FALSE) {
        Roles._grant_role(user, role);
        return ();
    }
    return ();
}

@external
func revoke_role{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(role: felt, user: felt) -> () {
    let (admin: felt) = adminRoles.read(role);
    Roles.require_role(admin);
    let (user_has_role: felt) = Roles.has_role(user, role);
    if (user_has_role == TRUE) {
        Roles._revoke_role(role, user);
        return ();
    }
    return ();
}

@external
func delegate_admin_role{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(role: felt, admin_role: felt) -> () {
    alloc_locals;
    let (local previous_admin_role: felt) = adminRoles.read(role);
    Roles.require_role(previous_admin_role);
    adminRoles.write(role, admin_role);
    RoleAdminChanged.emit(role, previous_admin_role, admin_role);
    return ();
}

@view
func get_admin_role{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(role: felt) -> (admin: felt) {
    let (admin: felt) = adminRoles.read(role);
    return (admin,);
}

# Based on OpenZeppelin Contracts for Cairo v0.2.1 (access/accesscontrol/library.cairo)

%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE


# Events
# ------

@event
func RoleGranted(role: felt, account: felt, sender: felt):
end

@event
func RoleRevoked(role: felt, account: felt, sender: felt):
end

@event
func RoleAdminChanged(role: felt, previousAdminRole: felt, newAdminRole: felt):
end


# Storage
# -------

# For a given role, specifies the role that can administor it
@storage_var
func adminRoles(role: felt) -> (admin: felt):
end

# Roles assigned to members
@storage_var
func mebmersRolesSize() -> (size: felt):
end

@storage_var
func membersRoles(address: felt, role: felt) -> (has_role: felt):
end


namespace Roles:
    func require_role{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
    }(role: felt):
        alloc_locals
        let (caller) = get_caller_address()
        let (authorized) = has_role(role, caller)
        with_attr error_message("AccessControl: caller is missing role {role}"):
            assert authorized = TRUE
        end
        return ()
    end
    
    func has_role{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
    }(role: felt, user: felt) -> (has_role: felt):
        let (authorized: felt) = membersRoles.read(user, role)
        return (authorized)
    end
    
    @external
    func grant_role{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
    }(role: felt, user: felt):
        let (admin: felt) = adminRoles.read(role)
        require_role(admin)
        let (user_has_role: felt) = has_role(role, user)
        if user_has_role == FALSE:
            let (caller: felt) = get_caller_address()
            membersRoles.write(role, user, TRUE)
            RoleGranted.emit(role, user, caller)
            return ()
        end
        return ()
    end
    
    @external
    func revoke_role{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
    }(role: felt, user: felt):
        let (admin: felt) = adminRoles.read(role)
        require_role(admin)
        let (user_has_role: felt) = has_role(role, user)
        if user_has_role == TRUE:
            let (caller: felt) = get_caller_address()
            membersRoles.write(role, user, FALSE)
            RoleRevoked.emit(role, user, caller)
            return ()
        end
        return ()
    end
    
    @external
    func delegate_admin_role{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
    }(role: felt, admin_role: felt):
        alloc_locals
        let (local previous_admin_role: felt) = adminRoles.read(role)
        require_role(previous_admin_role)
        adminRoles.write(role, admin_role)
        RoleAdminChanged.emit(role, previous_admin_role, admin_role)
        return ()
    end
end
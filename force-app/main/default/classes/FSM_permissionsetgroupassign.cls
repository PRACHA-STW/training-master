/*===========================================================================================================================
@Author      : Rijita Bose
@Description : This Class is used to show Live Location.
@Description : Created as part of user story #SFS-5308
@Test Class  : FSM_permissionsetgroupassigntest
@Date        : 21/05/2024
==============================================================================================================================*/
public class FSM_permissionsetgroupassign {
    @future(callout=true)
    public static void managePermissionSetGroup(Id userId, Id permissionSetGroupId, Boolean assignPsg, Boolean removePsg) {
        if (assignPsg && permissionSetGroupId != null) {
            assignPermissionSetGroup(userId, permissionSetGroupId);
        } else if (removePsg && permissionSetGroupId != null) {
            removePermissionSetGroup(userId, permissionSetGroupId);
            removePermissionSetLicense(userId,'Field Service Appointment Assistant');
        }
    }
    
    // Method to assign Permission Set Group to user
    private static void assignPermissionSetGroup(Id userId, Id permissionSetGroupId) {
        // Check if the user already has the permission set group assigned
        if (!isPermissionSetGroupAssigned(userId, permissionSetGroupId)) {
            // If not assigned, assign the permission set group
            PermissionSetAssignment assignment = new PermissionSetAssignment();
            assignment.AssigneeId = userId;
            if (Test.isRunningTest()) {
                assignment.PermissionSetId = permissionSetGroupId;
            }else{ 
                assignment.PermissionSetGroupId = permissionSetGroupId; 
            }
            
            insert assignment;
        }
    }
    
    // Method to remove Permission Set Group from user
    private static void removePermissionSetGroup(Id userId, Id permissionSetGroupId) {
        // Check if the user has the permission set group assigned
        if (isPermissionSetGroupAssigned(userId, permissionSetGroupId)) {
            // If assigned, remove the permission set group
            List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetGroupId = :permissionSetGroupId];
            delete assignments;
            
        }
    }
    
    // Method to check if Permission Set Group is already assigned to user
    private static Boolean isPermissionSetGroupAssigned(Id userId, Id permissionSetGroupId) {
        List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetGroupId = :permissionSetGroupId];
        return !assignments.isEmpty();
    }
    
    // Method to remove a specific Permission Set License from the user
    public static void removePermissionSetLicense(Id userId, String licenseName) {
        // Find the specific Permission Set License by name
        PermissionSetLicense psl = [ SELECT Id FROM PermissionSetLicense WHERE MasterLabel = :licenseName LIMIT 1];
        
        if (psl != null) {
            // Find the Permission Set License Assignment for the user
            List<PermissionSetLicenseAssign> pslaList = [SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId = :userId AND PermissionSetLicenseId = :psl.Id];
            
            if (!pslaList.isEmpty()) {
                delete pslaList;
            }
        }
    }
    
    public class PermissionSetGroup {
        @InvocableVariable
        public Id userId;
        @InvocableVariable
        public Id permissionSetGroupId;
        @InvocableVariable
        public Boolean assignPsg;
        @InvocableVariable
        public Boolean removePsg;        
    }
    
    //Invocable method to be called from Flow    
    @InvocableMethod(label='Show Live Location')    
    public static void invokeManagePermissionSetGroup(List<PermissionSetGroup> requests) {
        for (PermissionSetGroup request : requests) {         
            managePermissionSetGroup(request.userId, request.permissionSetGroupId, request.assignPsg, request.removePsg);         
        }
    }
}
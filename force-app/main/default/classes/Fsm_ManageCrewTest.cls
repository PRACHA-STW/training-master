/**********************************************************************************************************
@Author 	 : Subir Maji
@Description : This class is used to test FSM_ManageCrew.
@description : Created as part of user story #SFL-886.
@Main Class  : FSM_ManageCrew
@Date        : 11-July-2025
********************************************************************************************************/
@isTest(SeeAllData = false)
private class Fsm_ManageCrewTest {
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @description : This method is used to create test data setup.
    ********************************************************************************************************/
    @testSetup
    static void setupTestData() {
        // Get the ID of the 'Standard User' profile
        String profileId = [SELECT Id FROM Profile where Name='Standard User' LIMIT 1].Id;
        // Get the current user's ID
        Id currentUserId = UserInfo.getUserId();
        // Initialize lists to hold new users and service resources
        List<User> newUser = new List<User>();
        List<ServiceResource> allSR = new List<ServiceResource>();
        // Create test users using a custom test data factory
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user','manageCrew1@fsm.co.uk','test',profileId).returnWithoutCreate());
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user2','manageCrew2@fsm.co.uk','test2',profileId).returnWithoutCreate());
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user3','manageCrew3@fsm.co.uk','test3',profileId).returnWithoutCreate());
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user4','manageCrew4@fsm.co.uk','test4',profileId).returnWithoutCreate());
        Insert newUser;  // Insert the created users into the database
        
        // Create service resources,service territory and service territory members
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME).setIsActive(true)
            .setRelatedRecordId(newUser[0].Id).setExternalId('1234').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME+'2').setIsActive(true)
            .setRelatedRecordId(newUser[1].Id).setExternalId('12345').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME+'3').setIsActive(true)
            .setRelatedRecordId(newUser[2].Id).setExternalId('12346').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        Insert allSR; // Insert the created service resources into the database
    }
    /********************************************************************************************************
    @Author      : Subir Maji
    @description : This test method verifies that a user can successfully retrieve their active 
                   ServiceResource ID and a list of active resources using Fsm_ManageCrew methods.
    ********************************************************************************************************/
    @isTest
    static void testGetActiveResourcesSuccessCheck() {
        // Retrieve a test user by username and assign them the required permission
        User standardUser = [SELECT Id FROM User WHERE Username = 'manageCrew1@fsm.co.uk' LIMIT 1];
        PermissionSet ps = [select Id from PermissionSet where Name='FSM_SystemAdminPermissions'];
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = standardUser.Id);
        // Run the test logic as the specified user
        System.runAs(standardUser) {
            Test.StartTest();
            // Call method to get all active service resources in the same business unit
            List<ServiceResource> resources = Fsm_ManageCrew.getActiveResources();
            // Call method to get the current user's associated service resource ID
            ID resourcesID = Fsm_ManageCrew.getCurrentUserServiceResourceId();
            Test.StopTest();
        	// Assert that a valid resource ID is returned
            System.assertEquals(resourcesID != null, true, 'Fetched Resource ID successfully');
            // Assert that two active resources are returned (including another user in the same BU)
            System.assertEquals(2, resources.size(), 'Should return 2 active resource (other user in same BU)');
            // Assert that the name of the first resource matches the expected format
            System.assertEquals(FSM_Constants.RESOURCE_NAME+'2', resources[0].Name,'Resource Name Did not Matched');
        }
	}
    /********************************************************************************************************
    @Author      : Subir Maji
    @description : This test method verifies that when no active ServiceResource is associated with the user, 
the Fsm_ManageCrew methods return null or empty results as expected.
    ********************************************************************************************************/
    @isTest
    static void testGetActiveResourcesFailureCheck() {
        // Retrieve a test user by username
        User standardUser = [SELECT Id FROM User WHERE Username = 'manageCrew4@fsm.co.uk' LIMIT 1];
        PermissionSet ps = [select Id from PermissionSet where Name='FSM_SystemAdminPermissions'];
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = standardUser.Id);    
        // Run the test logic as the specified user
        System.runAs(standardUser) {
            Test.StartTest();
            // Call method to get active service resources
            List<ServiceResource> resources = Fsm_ManageCrew.getActiveResources();
            // Call method to get current user's service resource ID
            ID resourcesID = Fsm_ManageCrew.getCurrentUserServiceResourceId();
            Test.StopTest();
            // Assert that no resource ID is returned
            System.assertEquals(resourcesID == null, true, 'No Resource Found');
            // Assert that the resource list is empty
            System.assertEquals(resources.isEmpty(), true, 'No resource returned');
        }
	}
}
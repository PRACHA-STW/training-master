/********************************************************************************************************
@Author 	 : Manish & srikanth
@description : This class is used to test FSM_TimeSheetEntryGenerator.
@description : Created as part of user story #SFI-1557
@Main Class  : FSM_TimeSheetEntryGenerator
@Date        : 5th-March-2024
@History   : The test class is updated by Vishesh for SFL-889 on 08-July-2025
********************************************************************************************************/
@istest(SeeAllData = False)
public class FSM_TimeSheetEntryGeneratorTest {
    static Integer numberOfRecordsToCreate = 2;
    @TestSetup
    static void makeData(){
    // Create test data for users, service resources, service territory, work order, service appointment, assigned resources, time sheet and time sheet entries
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Completed');
        String profileId = [SELECT Id FROM Profile where Name='Standard User' LIMIT 1].Id;
    //Lists to store the created records for Usersservice resources, assigned resources, service territory members and time sheet entries to be used in the test methods
    //Created as part of SFL-889                       
        List<User> newUser = new List<User>();      
        List<ServiceResource> allSR = new List<ServiceResource>();
        List<AssignedResource> allSRAssign = new List<AssignedResource>();
        List<ServiceTerritoryMember> allMember = new List<ServiceTerritoryMember>();
        List<TimeSheetEntry> allTSE = new List<TimeSheetEntry>();
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user','TestTSEuser346@gmail.com','test',profileId).returnWithoutCreate());
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user2','TestTSEuser357@gmail.com','test1',profileId).returnWithoutCreate());
        Insert newUser;  // Insert the created users into the database
        // Create a scheduling policy and operating hours for the service territory
        FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName(FSM_Constants.DCF_SCHEDULING_POLICY).create();      
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName(FSM_Constants.OH_AM_PM).setSlotType(FSM_Constants.DURATION)
            .setBusinessUnit(FSM_Constants.BUSINESS_UNIT).create();
        // Create service resources,service territory and service territory members
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME).setIsActive(true)
            .setRelatedRecordId(newUser[0].Id).setExternalId('1234').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME+'2').setIsActive(true)
            .setRelatedRecordId(newUser[1].Id).setExternalId('12345').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        Insert allSR; // Insert the created service resources into the database
        ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory').setIsActive(true)
            .setExtenalId('888999').setOpreratingHours(op.Id).setSchedulingPolicy(schedulingPolicy.Id).setTerritoryLevel(5).create();
        allMember.add(new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(allSR[0].id).setServiceTerritory(st.Id).
                     setTerritoryType('P').setStartDate(DateTime.Now().AddDays(-5)).setCountry('abcd').setPostalCode('1234d').
                     setLatitude(24).setLongitude(86).returnWithoutCreate());
        allMember.add(new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(allSR[1].id).setServiceTerritory(st.Id).
                     setTerritoryType('P').setStartDate(DateTime.Now().AddDays(-5)).setCountry('abcd').setPostalCode('1234d').
                     setLatitude(24).setLongitude(86).returnWithoutCreate());
        Insert allMember; // Insert the created service territory members into the database
        //Create a work order, service appointment, assigned resources.
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(st.Id)
            .setBusinessUnit('Waste Infra').setOpenDate(DateTime.Now()).setSlaDate(DateTime.Now()).create();
        ServiceAppointment sa = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New').setServiceTerritory(st.id)
            .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now().AddDays(1)).setServiceResource(allSR[0].id).setLatitude(24).setLongitude(86).
            setScheduledStart(DateTime.Now().addHours(1)).setScheduledEnd(DateTime.Now().addHours(2)).create();
        allSRAssign.add(new FSM_TestDataFactory.AssignedResourceCreator().setServiceResource(allSR[0].id).setServiceAppointment(sa.id).
                       returnWithoutCreate());
        allSRAssign.add(new FSM_TestDataFactory.AssignedResourceCreator().setServiceResource(allSR[1].id).setServiceAppointment(sa.id).
                       returnWithoutCreate());
        Insert allSRAssign; // Insert the created assigned resources into the database
        // Update the service appointment status to Scheduled and set non-productive time
        sa.Status='Scheduled';
        sa.FSM_TimeEventType__c='Non Productive Time';
        sa.FSM_NonProductiveStartTime__c=DateTime.Now();
        update sa; // Update the service appointment with the new status and non-productive time
        // Create a time sheet and time sheet entries       
        TimeSheet timeSheet=new FSM_TestDataFactory.TimeSheetCreator().setStartDate(System.today()).setEndDate(System.today())
            .setServiceResourceId(allSR[0].Id).create(); 
        allTSE.add(new FSM_TestDataFactory.TimeSheetEntryCreator().setFinalConfirmation(true).setType('Direct')
            .setTimeSheetId(timeSheet.Id).setsaId(sa.Id).returnWithoutCreate());
        allTSE.add(new FSM_TestDataFactory.TimeSheetEntryCreator().setFinalConfirmation(false).setType('Direct')
            .setTimeSheetId(timeSheet.Id).setsaId(sa.Id).returnWithoutCreate());
        insert allTSE; // Insert the created time sheet entries into the database
    }
    /********************************************************************************************************
    @Author      : Manish jagnani
    @description : method to test SA status Completed 
    @description : Created as part of user story #SFI-1557
    @Date        : 06-March-2024
	********************************************************************************************************/
    @isTest
    static void testSAstatusComplete() {
        //fetching the user with FSM_ExternalId__c
        User fw = [Select id, FirstName, LastName, Username, FSM_ExternalId__c From User Where FSM_ExternalId__c = 'TestTSEuser346@gmail.com'];
        // Fetching the service appointments
        List<ServiceAppointment> sa=[Select id,status From ServiceAppointment];
        //Fetching the permission set and assigning it to the user
        PermissionSet ps = [select Id from PermissionSet where Name='FSM_SystemAdminPermissions'];
    	insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = fw.Id); //Insert the permission set assignment to the user
        
        System.runas(fw){						//14/01/2025 Asutosh	Updated as a part of SFL-189
            Test.startTest(); 
            for(ServiceAppointment sap : sa){
                //setting the status of service appointment to Completed
               sap.status='Completed';    
            }      
            update sa; // Update the service appointments with the new status
            Test.stopTest();
            // Fetching the integration logs.
            List<FSM_IntegrationLog__c> allLog = [Select ID from FSM_IntegrationLog__c];
            // Asserting that the integration log is created and the number of records matches the expected count
            System.assertEquals(allLog != null, true, 'Integration Log Created');
            System.assertEquals(numberOfRecordsToCreate, allLog.size(), 'All Integration Log Created');
        }
    }
}
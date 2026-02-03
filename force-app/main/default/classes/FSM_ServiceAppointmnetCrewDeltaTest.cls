/**********************************************************************************************************
@Author 	 : Asutosh Singh
@Description : This class is used to test FSM_ServiceAppointmnetCrewDelta.
@description : Created as part of user story #SFL-885.
@Main Class  : FSM_ServiceAppointmnetCrewDelta
@Date        : 07-July-2025
********************************************************************************************************/
@isTest(SeeAllData = False)
private class FSM_ServiceAppointmnetCrewDeltaTest {
    //Fetching the permission set and assigning it to the user
    Static PermissionSet ps = [select Id from PermissionSet where Name='FSM_SystemAdminPermissions'];
    
    /********************************************************************************************************
    @Author      : Asutosh Singh
    @description : This method is used to create test data setup.
    ********************************************************************************************************/
    @TestSetup
    static void testData(){
        //To allow appointment status transition from New to Scheduled
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Dispatched');
        FSL.GlobalAPIS.addStatusTransition('New', 'Dispatched');
        //Fetch Profile Id to create User
        Id techProfileId = [select Id from Profile where Name = 'Standard User'].Id;
        
        List<User> newUser = new List<User>();      
        List<ServiceResource> allSR = new List<ServiceResource>();
        List<AssignedResource> allSRAssign = new List<AssignedResource>();
        List<ServiceTerritoryMember> allMember = new List<ServiceTerritoryMember>();
        List<ServiceCrewMember> allCrewMember = new List<ServiceCrewMember>();
        List<ServiceAppointment> sa = new List<ServiceAppointment>();
        
        //Create user for a field technician resource
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user','Testcrewdelta34@gmail.com','test',techProfileId).returnWithoutCreate());
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user2','Testcrewdelta35@gmail.com','test1',techProfileId).returnWithoutCreate());
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user3','Testcrewdelta36@gmail.com','test2',techProfileId).returnWithoutCreate());
        newUser.add (new FSM_TestDataFactory.CretaeUserCustom('user4','Testcrewdelta37@gmail.com','test3',techProfileId).returnWithoutCreate());
        Insert newUser;  // Insert the created users into the database
        
        //Create Scheduling Policy
        FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName(FSM_Constants.DCF_SCHEDULING_POLICY).create();      
        //Create Operating Hour
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName(FSM_Constants.OH_AM_PM).setSlotType(FSM_Constants.DURATION).setBusinessUnit(FSM_Constants.BUSINESS_UNIT).create();
        
        //Create Service Territory
        ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory').setIsActive(true).setExtenalId('888999').setOpreratingHours(op.Id).setSchedulingPolicy(schedulingPolicy.Id).setTerritoryLevel(5).create();
        //Create Service Crew
        ServiceCrew testCrew = new FSM_TestDataFactory.ServiceCrewCreator().setName('Test Crew').setCrewSize(4).setServiceTerritory(st.Id).create();
        
        //Service Resource Creation
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME).setIsActive(true).setResourceType('T')
            .setRelatedRecordId(newUser[0].Id).setExternalId('1234').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME+'2').setIsActive(true).setResourceType('T')
            .setRelatedRecordId(newUser[1].Id).setExternalId('4321').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME+'3').setIsActive(true).setResourceType('T')
            .setRelatedRecordId(newUser[2].Id).setExternalId('4521').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        allSR.add(new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME+'4').setIsActive(true).setResourceType('T')
            .setRelatedRecordId(newUser[3].Id).setExternalId('4721').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).returnWithoutCreate());
        Insert allSR; // Insert the created service resources into the database
                
        //Create SCM record for crew member 1
        allCrewMember.add(new FSM_TestDataFactory.ServiceCrewMemberCreator().setServiceCrew(testCrew.Id).setServiceResource(allSR[0].Id)
                          .setStartDate(DateTime.now().addDays(-3)).setEndDate(DateTime.Now().addDays(5)).returnWithoutCreate());
        //Create SCM record for crew member 2
        allCrewMember.add(new FSM_TestDataFactory.ServiceCrewMemberCreator().setServiceCrew(testCrew.Id).setServiceResource(allSR[1].Id)
                          .setStartDate(DateTime.now().addDays(-3)).setEndDate(DateTime.Now().addHours(4)).returnWithoutCreate());
        Insert allCrewMember;
        
        //Service Crew Resource Creation
        Serviceresource sr = new FSM_TestDataFactory.ServiceResourceCreator().setName('Testing Crew Resource').setIsActive(true)
                              .setResourceType('C').setServiceCrewId(testCrew.Id).setExternalId('Crew1')
                              .setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).Create();
        
        //Create Service Territory Member for crew service resource
        allMember.add(new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(sr.Id).setServiceTerritory(st.Id).setTerritoryType('P').setStartDate(DateTime.Now().AddDays(-5)).setCountry('abcd').setPostalCode('1234d').setLatitude(24).setLongitude(86).returnWithoutCreate());
        //Create Service Territory Member
        allMember.add(new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(allSR[0].Id).setServiceTerritory(st.Id).setTerritoryType('P').setStartDate(DateTime.Now().AddDays(-5)).setCountry('abcd').setPostalCode('1234d').setLatitude(24).setLongitude(86).returnWithoutCreate());
        allMember.add(new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(allSR[1].Id).setServiceTerritory(st.Id).setTerritoryType('P').setStartDate(DateTime.Now().AddDays(-5)).setCountry('abcd').setPostalCode('1234d').setLatitude(24).setLongitude(86).returnWithoutCreate());
        allMember.add(new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(allSR[2].Id).setServiceTerritory(st.Id).setTerritoryType('P').setStartDate(DateTime.Now().AddDays(-5)).setCountry('abcd').setPostalCode('1234d').setLatitude(24).setLongitude(86).returnWithoutCreate());
        allMember.add(new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(allSR[3].Id).setServiceTerritory(st.Id).setTerritoryType('P').setStartDate(DateTime.Now().AddDays(-5)).setCountry('abcd').setPostalCode('1234d').setLatitude(24).setLongitude(86).returnWithoutCreate());
        Insert allMember;
        
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(st.Id).setBusinessUnit('Waste Infra').setOpenDate(DateTime.Now()).setSlaDate(DateTime.Now()).create();
        // Create a test ServiceAppointment data
        sa.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New')
            .setServiceTerritory(st.id).setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now().AddDays(5))
            .setServiceResource(sr.Id).setLatitude(24).setLongitude(86).setScheduledStart(DateTime.Now().addHours(1))
            .setScheduledEnd(DateTime.Now().addHours(2)).returnWithoutCreate());
        sa.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New')
            .setServiceTerritory(st.id).setEarliestStartTime(DateTime.Now().AddDays(-3)).setDueDate(DateTime.Now().AddDays(6))
            .setServiceResource(sr.Id).setLatitude(25).setLongitude(86).setScheduledStart(DateTime.Now().addHours(25))
            .setScheduledEnd(DateTime.Now().addHours(26)).returnWithoutCreate());
        sa.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New')
            .setServiceTerritory(st.id).setEarliestStartTime(DateTime.Now().AddDays(-4)).setDueDate(DateTime.Now().AddDays(7))
            .setServiceResource(sr.Id).setLatitude(26).setLongitude(86).setScheduledStart(DateTime.Now().addHours(-26))
            .setScheduledEnd(DateTime.Now().addHours(-25)).returnWithoutCreate());
        Insert sa;
        
        // Create Assigned Resources for crew service resource
        allSRAssign.add(new FSM_TestDataFactory.AssignedResourceCreator().setServiceResource(sr.Id).setServiceAppointment(sa[0].id).returnWithoutCreate());
        allSRAssign.add(new FSM_TestDataFactory.AssignedResourceCreator().setServiceResource(sr.Id).setServiceAppointment(sa[1].id).returnWithoutCreate());
        allSRAssign.add(new FSM_TestDataFactory.AssignedResourceCreator().setServiceResource(sr.Id).setServiceAppointment(sa[2].id).returnWithoutCreate());
        Insert allSRAssign;
        
        // Update SA to Scheduled status
        /*sa[0].Status='Scheduled';
        sa[1].Status='Scheduled';
        sa[2].Status='Scheduled';
        Update sa;*/
        
        // Update SA to Dispatched status
        sa[0].Status='Dispatched';
        sa[1].Status='Dispatched';
        sa[2].Status='Dispatched';
        Update sa;
    }
    
    /********************************************************************************************************
    @Author      : Asutosh Singh
    @description : This method is used to create Assigned Resource when End Date of crew membership 
                   gets updated to include SA's Scheduled End date.
    ********************************************************************************************************/
   /* @isTest
    static void testSCMCreateAR() {
        List<String> extId = new List<String>();
        extId.add('4521');
        extId.add('4721');
        //fetching the user with Username
        User fw = [Select id, FirstName, LastName, Username, FSM_ExternalId__c From User Where Username = 'Testcrewdelta34@gmail.com'];
        //Query ServiceCrew record
        ServiceCrew src = [Select ID from ServiceCrew Limit 1];
        //Query Service resource
        List<ServiceResource> allSR = [Select id from ServiceResource where FSM_ExternalID__c IN: extId];
        //service crew member record
        List<ServiceCrewMember> allCrewMember = new List<ServiceCrewMember>();
        //Insert the permission set assignment to the user
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = fw.Id);
        System.runas(fw){
            Test.startTest();
            //Create SCM record for crew member 1
            allCrewMember.add(new FSM_TestDataFactory.ServiceCrewMemberCreator().setServiceCrew(src.Id).setServiceResource(allSR[0].Id)
                              .setStartDate(DateTime.now().addHours(-5)).setEndDate(DateTime.Now().addHours(10)).returnWithoutCreate());
            //Create SCM record for crew member 2
            allCrewMember.add(new FSM_TestDataFactory.ServiceCrewMemberCreator().setServiceCrew(src.Id).setServiceResource(allSR[1].Id)
                              .setStartDate(DateTime.now().addHours(-5)).setEndDate(DateTime.Now().addHours(10)).returnWithoutCreate());
            Insert allCrewMember;
            Test.stopTest();
         }
        //fetch all assigned resource records related to the service resource
        Integer count = [SELECT COUNT() FROM AssignedResource Where ServiceResource.FSM_ExternalId__c In: extId];
        //assert statement to check if Assigned Resource is created
        System.Assert(count == 2, 'Assigned resource created on creation of Service Crew member');
    }*/
    
    /********************************************************************************************************
    @Author      : Asutosh Singh
    @description : This method is used to create Assigned Resource when End Date of crew membership 
                   gets updated to include SA's Scheduled End date.
    ********************************************************************************************************/
    /*@isTest
    static void testSCMDeleteAR() {
        //fetching the user with Username
        User fw = [Select id From User Where Username = 'Testcrewdelta34@gmail.com'];
        //fetch service appointment record
        ServiceAppointment sa = [Select Id from ServiceAppointment Where Latitude = 24 limit 1];
        //service crew member record
        ServiceCrewMember serviceCrewMember = [Select ID, StartDate, EndDate from ServiceCrewMember Limit 1];
        //Insert the permission set assignment to the user
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = fw.Id);
        System.runas(fw){
            Test.startTest();
            //Create SCM record for crew member 1
            Delete serviceCrewMember;
            Test.stopTest();
            //fetch all assigned resource records related to the appointment
            Integer count = [Select Count() from AssignedResource where ServiceAppointmentId =: sa.Id];
            //assert statement to check if Assigned Resource is created
            System.Assert(count == 2, 'Assigned resource updated on creation of Service Crew member');
        }
    }*/
    
    /********************************************************************************************************
    @Author      : Asutosh Singh
    @description : This method is used to delete Assigned Resource when Start Date of crew membership 
                   gets updated to exclude SA's Scheduled End date.
    ********************************************************************************************************/
    @isTest
    static void testSCMUpdateAR() {
        //fetching the user with Username
        User fw = [Select id, FirstName, LastName, Username, FSM_ExternalId__c From User Where Username = 'Testcrewdelta34@gmail.com'];
        //service crew member record
        List<ServiceCrewMember> allCrewMember = [Select ID, StartDate, EndDate, ServiceResource.FSM_ExternalId__c from ServiceCrewMember order by EndDate desc];
        //Insert the permission set assignment to the user
        insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = fw.Id);
        System.runas(fw){
            Test.startTest();
            //to delete assigned resource from 2 sa and add to 1 sa
            allCrewMember[0].StartDate = DateTime.now().addDays(-30);
            allCrewMember[0].EndDate = DateTime.Now().addDays(-20);
            //to add assigned resource to 2 sa and remove from 1 sa
            allCrewMember[1].EndDate = DateTime.Now().addHours(30);
            Update allCrewMember;
            Test.stopTest();
        }
        //fetch all assigned resource records related to the appointment
        Integer count = [Select Count() from AssignedResource where ServiceResource.FSM_ExternalId__c = '1234'];
        //assert statement to check if Assigned Resource is created
        System.Assert(count == 0, 'Assigned resource removed');
        
        //fetch all assigned resource records related to the appointment
        Integer count1 = [Select Count() from AssignedResource where ServiceResource.FSM_ExternalId__c = '4321'];
        //assert statement to check if Assigned Resource is created
        System.Assert(count1 == 3, 'Assigned resource added');
    }
}
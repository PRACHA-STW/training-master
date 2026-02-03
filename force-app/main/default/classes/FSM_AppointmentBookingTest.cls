/********************************************************************************************************
@Author 	 : Srikanth Palla
@description : This class is used to test FSM_AppointmentBooking.
@description : Created as part of user story #SFI-261,Updated as part of SFI-2213
@Main Class  : FSM_AppointmentBooking
@Date        : 20-July-2023
@Date		 : Updated as part of SFI-2566 by Subir Maji 30th July 24
********************************************************************************************************/
@isTest (SeeAlldata = false)
public class FSM_AppointmentBookingTest {
    //Created for test data setup
    @testsetup 
    static void makeData(){
         // Create Admin user for RunAs purposes to create users and assign permission sets
        Id adminProfileId = [select Id from Profile where Name = 'System Administrator'].Id;
    	User adminUser = new FSM_TestDataFactory.CretaeUserCustom('admUsr12','johndoe@exampleAdmin.com', 'johndoe2', adminProfileId).create();
        
        // Add FSL Admin Permissions if not already to running user (assuming admin)
    	System.runAs(adminUser){
            // Lookup the Field Service Admin Permissions permission set
            PermissionSet psSFSAdmin = [select Id from PermissionSet where Name ='FSL_Admin_Permissions'];
    
            // Associate it to the current user
            try {
                insert new PermissionSetAssignment(
                    PermissionSetId = psSFSAdmin.Id,
                    AssigneeId = UserInfo.getUserId()
                );
            } catch (Exception e) {
                // Perm set already assigned, continue
            }
        	
            //Create Scheduling Policy
            FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName('Test Policy').create();
            
            //Create Operating Hours
            List<OperatingHours> listOp = new List<OperatingHours>();
            OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setTimeZone(UserInfo.getTimeZone().getID()).setName('AM/Pm Operating Hours').setSlotType('AMPM').setBusinessUnit('Developer Services').returnWithoutCreate();
            listOp.add(op);
            op = new FSM_TestDataFactory.OperatingHoursCreator().setTimeZone(UserInfo.getTimeZone().getID()).setName('2 hours Operating Hours').setSlotType('2HRS').setBusinessUnit('Developer Services').returnWithoutCreate();
            listOp.add(op);
            insert listOp;
            
            //Create Timeslots
            List<TimeSlot> listTimeSlots = new List<TimeSlot>();
            TimeSlot ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Monday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(11, 2, 3, 4)).setOperatingHoursId(listOp[0].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Tuesday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(13, 2, 3, 4)).setOperatingHoursId(listOp[0].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Wednesday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(14, 2, 3, 4)).setOperatingHoursId(listOp[0].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Thursday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(15, 2, 3, 4)).setOperatingHoursId(listOp[1].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Friday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(16, 2, 3, 4)).setOperatingHoursId(listOp[1].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            insert listTimeSlots; 
            
            //Create Service Territory
            ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory').setIsActive(true).setExtenalId('888999').setOpreratingHours2HourSlot(listOp[1].Id).setOpreratingHours(listOp[0].Id).setSchedulingPolicy(schedulingPolicy.Id).create();
            // Create user for a field technician resource with the right permission sets
            Id techProfileId = [select Id from Profile where Name = 'FSM Standard Desktop User'].Id;
            User tech = new FSM_TestDataFactory.CretaeUserCustom('techUsr1','johndoe@exampleTech.com','johndoe1', techProfileId).create();
            
            List<PermissionSet> sfsPermSets = [select Id from PermissionSet where Name = 'FSL_Resource_Permissions' OR Name ='FSL_Resource_License'];
            
            List<PermissionSetAssignment> permSetAssigns = new List<PermissionSetAssignment>();
            for (PermissionSet sfsPermSet : sfsPermSets){
                permSetAssigns.Add(
                    new PermissionSetAssignment(
                        PermissionSetId = sfsPermSet.Id,
                        AssigneeId = tech.Id
                    )
                );
            }
            insert permSetAssigns;
            
            //Service Resource Creation
            ServiceResource serRes = new FSM_TestDataFactory.ServiceResourceCreator().setName('Testing Resource').setIsActive(true).setRelatedRecordId(tech.Id).setExternalId('Tech1324').create();
          
           //Create STM
            new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(serRes.Id).setServiceTerritory(st.Id).setTerritoryType('S')
                .setStartDate(System.now().addDays(-3)).create(); //14/01/2025 Rijita	Updated as a part of SFL-141
            
            //Get WO record type
            Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
            // Create a test WorkOrder data
            WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Water Infra').setRecordType(recTypeId).create();
            
            //Create Service Appointment
             new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('NEW')
                .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now().AddDays(18)).create();
           
        }    
   }
    //Testing Positive Request
    @isTest
    static void testCreateDataPositiveCase(){
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/FSM_AppointmentBooking';
        request.httpMethod = 'POST';
        FSM_AppointmentRequest reqBody= new FSM_AppointmentRequest();
        reqBody.earlyStart = '2023-10-31T08:00:00Z';
        reqBody.dueDate = '2023-11-04T06:00:00Z';
        reqBody.priority = '1';
        reqBody.serviceTerritoryId = '888999';
        reqBody.postcode = 'E1 1DF';
        reqBody.latitude = '39.234553';
        reqBody.longitude = '5.34533';
        reqBody.taskType = 'Blockage';
        reqBody.duration = '30';
        reqBody.businessArea = 'Developer Services';
        reqBody.standardTextKey = '1234';
        reqBody.slotType = 'AMPM';
        reqBody.preferredResource = new String[]{'Tech1324'};
        reqBody.requiredSkills = new String[]{'Abrasive Wheels - Portable (Q00001260)','Articulated (40t plus) (P000000000003000000)'};
        reqBody.durationType='Hours';
        reqBody.minimumCrewSize='3';
        String reqString = JSON.serialize(reqBody);
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        FSM_CreateCustomerAppointmentWOSA.createData();
        Test.stopTest();
        System.assert(response.statusCode == 200, 'Request Success');
    }
    //testing negative secnario which will cause error
    ////Added by Subir Maji 16th July 2024 as part of SFI-2479
    @isTest
    static void testCreateDataNegitiveCase(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/FSM_AppointmentBooking';
        request.httpMethod = 'POST';
        FSM_AppointmentRequest reqBody= new FSM_AppointmentRequest();
        reqBody.earlyStart = '2023-10-31T08:00:00Z';
        reqBody.dueDate = '2023-11-04T06:00:00Z';
        reqBody.priority = '1';
        reqBody.serviceTerritoryId = '88899';
        reqBody.postcode = 'E1 1DF';
        reqBody.latitude = '';
        reqBody.longitude = '';
        reqBody.taskType = 'Blockage';
        reqBody.duration = '30';
        reqBody.businessArea = 'Developer Services';
        reqBody.standardTextKey = '1234';
        reqBody.slotType = 'AMPMN';
        reqBody.preferredResource = new String[]{'TechWrongRes1', 'Tech1324'};
        reqBody.requiredSkills = new String[]{'Test Wrong Skill','Articulated (40t plus) (P000000000003000000)'};
        String reqString = JSON.serialize(reqBody);
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        FSM_CreateCustomerAppointmentWOSA.createData();
        Test.stopTest();
        System.assert(response.statusCode == 400, 'Request failed!');
    }
    //testing negative secnario which will cause error with blank data 
    @isTest
    static void testCreateDataNegitiveCaseWithBlank(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/FSM_AppointmentBooking';
        request.httpMethod = 'POST';
        FSM_AppointmentRequest reqBody= new FSM_AppointmentRequest();
        reqBody.earlyStart = '2023-10-31T08:00:00Z';
        reqBody.dueDate = '2023-11-04T06:00:00Z';
        reqBody.priority = '1';
        reqBody.serviceTerritoryId = '';
        reqBody.postcode = 'E1 1DF';
        reqBody.latitude = '39.234553';
        reqBody.longitude = '5.34533';
        reqBody.taskType = 'Blockage';
        reqBody.duration = '30';
        reqBody.businessArea = 'Developer Services';
        reqBody.standardTextKey = '1234';
        reqBody.slotType = '';
        reqBody.preferredResource = new String[]{'TechWrongRes1'};
        reqBody.requiredSkills = new String[]{'Test Wrong Skill'};
        String reqString = JSON.serialize(reqBody);
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        FSM_CreateCustomerAppointmentWOSA.createData();
        Test.stopTest();
        System.assert(response.statusCode == 400, 'Request failed!');
    }
    //test positive secnario with diferent set of data
    @isTest
    static void testGetSlotsPositiveCase(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/FSM_AppointmentBooking';
        request.httpMethod = 'POST';
        FSM_AppointmentRequest1 reqBody= new FSM_AppointmentRequest1();
        reqBody.RecordDetails=getRecordDetails();
        String reqString = JSON.serialize(reqBody);
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        FSM_AppointmentBooking.getAppointmentBookingSlots();
        Test.stopTest();
        System.assert(response.statusCode == 200, 'Request Success!');
    }
     //test negative secnario with diferent set of data
    @isTest
    static void testGetSlotsNegativeCase(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/FSM_AppointmentBooking';
        request.httpMethod = 'POST';
        FSM_AppointmentRequest reqBody= new FSM_AppointmentRequest();
        reqBody.earlyStart = '2023-10-31T08:00:00Z';
        reqBody.dueDate = '2023-11-04T06:00:00Z';
        reqBody.priority = '1';
        reqBody.postcode = 'E1 1DF';
        reqBody.latitude = '39.234553';
        reqBody.longitude = '5.34533';
        reqBody.taskType = 'Blockage';
        reqBody.duration = '30';
        reqBody.businessArea = 'Waste Infra';
        reqBody.standardTextKey = '1234';
        reqBody.slotType = 'AMPM';
        reqBody.preferredResource = new String[]{'Tech1324'};
        reqBody.requiredSkills = new String[]{'Electrician','Teacher'};
        String reqString = JSON.serialize(reqBody);
        request.requestBody = Blob.valueOf(reqString);
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        FSM_AppointmentBooking.getAppointmentBookingSlots();
        Test.stopTest();
        System.assert(response.statusCode == 400, 'Response is 400!');
    }
    //For getting record details
    @istest
    public static FSM_AppointmentBookingTest.RecordDetail getRecordDetails(){
        FSM_AppointmentBookingTest.RecordDetail recordDetails=new FSM_AppointmentBookingTest.RecordDetail();
        
        WorkOrder wo=[select id from WorkOrder Limit 1];
        FSL__Scheduling_Policy__c sc=[select id,Name from FSL__Scheduling_Policy__c Limit 1];
        OperatingHours oh=[select id from OperatingHours Limit 1];
        ServiceAppointment sa=[select id from ServiceAppointment Limit 1];
        Timezone tz =userInfo.getTimeZone();
        recordDetails.OperatingHoursId=oh.id;
        recordDetails.SchedulingPolicyId=sc.id; 
        recordDetails.ServiceAppointmentId=sa.id;
        recordDetails.WorkorderId=wo.id;
        recordDetails.TimeZone=tz.toString();
        System.assert(wo != null, 'Putting Dummy Assert as this is helper method!');
        return recordDetails;
    }
    /**
     * @description : Wrapper class for request body
     */
    public class FSM_AppointmentRequest{
        public string earlyStart;
        public string dueDate;
        public string priority;
        public string serviceTerritoryId;
        public string postcode;
        public string latitude;
        public string longitude;
        public string[] preferredResource;
        public string taskType;
        public string duration;
        public string[] requiredSkills;
        public string businessArea;
        public string standardTextKey;
        public string slotType;
        public string durationType;
        public string minimumCrewSize;
    }
    /**
     * @description :Wrapper class for request body
     */
    public class FSM_AppointmentRequest1{
        public RecordDetail recordDetails;
    }
    /**
     * @description : wrapper class for sending record details 
     */
    public class RecordDetail{
        public string workorderId;
        public string serviceAppointmentId;
        public string schedulingPolicyId;
        public string operatingHoursId;
        public string timeZone;
    }
}
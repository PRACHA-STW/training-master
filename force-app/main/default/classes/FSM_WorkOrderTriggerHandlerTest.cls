/********************************************************************************************************
@Author 	 : Arnob Dey
@Description : This class is used to check Case update when WorkOrder is created.
@description : Created as part of user story #SFS-318
@Main Class  : FSM_WorkOrderTriggerHandler and FSM_WorkOrderTriggerHelper
@Date        : 07-July-2023
               03-12-2024 Rijita Bose Updated as part of SFL-137
********************************************************************************************************/
@IsTest(SeeAllData=false)
public class FSM_WorkOrderTriggerHandlerTest {
/********************************************************************************************************
@Author      : Arnob Dey
@description : This method is used to create test data setup.
********************************************************************************************************/
	@TestSetup
    static void testDataSetup(){
        // Create a Test Case
        new FSM_TestDataFactory.CaseCreator().setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').create(); 
        List<OperatingHours> listOp = new List<OperatingHours>();
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('AM/Pm Operating Hours').setSlotType(FSM_Constants.DURATION).setBusinessUnit('Developer Services').returnWithoutCreate();
        listOp.add(op);
        op = new FSM_TestDataFactory.OperatingHoursCreator().setName('2 hours Operating Hours').setSlotType('2HRS').setBusinessUnit('Developer Services').returnWithoutCreate();
        listOp.add(op);
        insert listOp;
        
        //Create Account
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        //Create Contact
        new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
                        .setEmail('no-reply@defaultemail.com').create();
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName('Test Policy').create();
        ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory').setIsActive(true).setExtenalId('4105WP3').setOpreratingHours2HourSlot(listOp[1].Id).setOpreratingHours(listOp[0].Id).setSchedulingPolicy(schedulingPolicy.Id).setGISLayerId('nw1').setWorkingSubAreaRequired(true).create();
        
        Case testCase = new FSM_TestDataFactory.CaseCreator().setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').setDescription('Long text info').create();        
        
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setServiceTerritory(st.Id).
            setEsating(40.0).setNorthing(50.4).standardTextKey('83773848743').setCaseId(testCase.ID).setBusinessUnit('Developer Services').create();
            
        ID saRecordTypeID= Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
        //ServiceAppointment sa = 
        new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('NEW').setRecordType(saRecordTypeID)
                .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now().AddDays(18)).
                setServiceTerritory(st.ID).create();
    }
    
    /********************************************************************************************************
    @Author      : Arnob Dey
    @description : This method is used to test whether Customer Information is copied from Case to WorkOrder 
                   when WorkOrder is created.
    ********************************************************************************************************/
    @IsTest
    static void testCustomerInformationUpdate(){                                        
        Case caseRec = [SELECT Id, FSM_ContactName__c, FSM_ContactEmail__c,Description FROM Case LIMIT 1]; 
        
        Test.startTest();
        //Get RecordType Id
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        // Create a Test WorkOrder associated with the Case
        new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setBusinessUnit('Water Infra').setCaseId(caseRec.Id).create();
        WorkOrder woRec = [SELECT Id, FSM_ContactName__c, FSM_ContactEmail__c,FSM_NotificationLongText__c FROM WorkOrder LIMIT 1];        
        Test.stopTest();
        
        // Assert the custom field value on the WorkOrder
        System.assertEquals(caseRec.FSM_ContactName__c, woRec.FSM_ContactName__c, 'ContactName information copied successfully');
        System.assertEquals(caseRec.FSM_ContactEmail__c, woRec.FSM_ContactEmail__c, 'ContactEmail information copied successfully');
        System.assertEquals(woRec.FSM_NotificationLongText__c,'Long text info', 'Description information copied successfully');
        
    }
    
    //This method is to test WorkOrder reason fields Update, Added as part of SFI-36, Srikanth palla, 17th Aug 2023
    @istest
    static void testReasonWOUpdate(){
       // WorkOrder wo = [Select id,FSM_SuspendReason__c from WorkOrder limit 1];
        ServiceAppointment sa = [Select id, FSM_SuspendReason__c from ServiceAppointment limit 1];
        test.StartTest();
            sa.FSM_SuspendCategory__c = 'Availability';
            sa.FSM_SuspendReason__c='ITES';
            update sa;
        test.StopTest();
        
        WorkOrder wo1 = [Select id,FSM_SuspendReason__c from WorkOrder];
        ServiceAppointment updatedsa = [Select id, FSM_SuspendReason__c from ServiceAppointment];
        System.assertEquals(updatedsa.FSM_SuspendReason__c,wo1.FSM_SuspendReason__c,'SA And WO reason fields should be same');
    }
     @istest
    static void testgeneratepdf(){
            Test.startTest();
        //Get RecordType Id
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        // Create a Test WorkOrder associated with the Case
        new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setBusinessUnit('Water Infra').setgeneratepdf(false).setpdfFilename('testpdffile').setdeviceType('Desktop').create();
        WorkOrder woRec = [SELECT Id, FSM_GeneratePDF__c FROM WorkOrder LIMIT 1]; 
        woRec.FSM_GeneratePDF__c=true;
        update woRec;
        Test.stopTest();
        
    }
    //This method is to test case updated in parend bundle WO, Added as part of SFL-132, 11th Dec 2024
    @IsTest
    static void testCasePopulationForParentBundle() {
        // Fetch WO
        WorkOrder wo = [SELECT Id, CaseId  FROM WorkOrder LIMIT 1];
        
        // Create ServiceAppointment records
        ServiceAppointment sa1 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New').setEarliestStartTime(DateTime.Now().AddDays(-12)).setDueDate(DateTime.Now().AddDays(-5)).create();
        ServiceAppointment sa2 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New').setEarliestStartTime(DateTime.Now().AddDays(-12)).setDueDate(DateTime.Now().AddDays(-5)).create();
        ServiceAppointment sa3 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New').setIsBundle(true).create();
        
        Test.startTest();
    
        // Link sa1 and sa2 to sa3 (bundle)
        sa1.RelatedBundleId = sa3.Id;
        sa1.IsBundleMember = true;
        update sa1;
    
        sa2.RelatedBundleId = sa3.Id;
        sa2.IsBundleMember = true;
        update sa2;

        Test.stopTest();
        
        // Retrieve the WorkOrder record to check if the CaseId is updated as expected
        WorkOrder updatedWO = [SELECT Id, CaseId FROM WorkOrder WHERE Id = :wo.Id];
        // Assert: Check if the WorkOrder's CaseId remains unchanged
        System.assertEquals(updatedWo.CaseId, wo.CaseId, 'CaseId should remain the same');
    }
    
    @istest
    static void testmailJetFieldsReset(){
        ServiceAppointment sa = [Select id, FSM_SuspendReason__c from ServiceAppointment limit 1];
        test.StartTest();
            sa.FSM_MailJetFieldsToBeBlanked__c='FSM_FWRole__c//FSM_CustCoordinatorNumber__c//FSM_OperativeContactNumber__c//FSM_FieldworkerVynUrl__c//FSM_CustCoordinatorNumber__c//FSM_Flow__c//FSM_Pressure__c//';
            sa.FSM_MailjetFieldUpdateDateAndTime__c  = System.now().addMinutes(5);
            update sa;
        test.StopTest();
        
        
        ServiceAppointment updatedsa = [Select id, FSM_CustCoordinatorNumber__c from ServiceAppointment];
        System.assertEquals(updatedsa.FSM_CustCoordinatorNumber__c,null);
    }
}
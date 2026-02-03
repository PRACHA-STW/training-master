/********************************************************************************************************
@Author      : Himanshu Dobriyal
@Description : This test class is to test FSM_CaseBatchDeletion and FSM_CaseBatchDeletionScheduler class.
@description : Created as part of user story #SFI-468
@Test Class  : FSM_CaseBatchDeletionTest
@Date        : 25-July-2023
********************************************************************************************************/
@isTest(SeeAllData = False)
public class FSM_CaseBatchDeletionTest {
    @TestSetUp
    static void testDataSetUp(){
        //Get RecordType Id 
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        // Create a Test permit
        FSM_TMAPermit__c testPermit = new FSM_TestDataFactory.TMAPermitCreator().create();
        // Create a Test permitcondition
        //FSM_TMAPermitConditions__c testPermitCondition = 
        new FSM_TestDataFactory.TMAPermitConditionsCreator().setTMAPermit(testPermit.id).create();
        // Create a Test Case
        List<Case> allcase = new List<Case>();
        allcase.add(new FSM_TestDataFactory.CaseCreator().setTMA(testPermit.Id).setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').returnWithoutCreate());
        allcase.add(new FSM_TestDataFactory.CaseCreator().setTMA(testPermit.Id).setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').returnWithoutCreate());
        Insert allcase;
        //Create Account
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        //Create Contact
        new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
                        .setEmail('no-reply@defaultemail.com').create();
        
        //Create workorder associated with case and permit 
        List<WorkOrder> allWO = new List<WorkOrder>();
        allWO.add(new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Developer Services').setRecordType(recTypeId).setPermit(testPermit.Id).setCaseId(allcase[0].Id).returnWithoutCreate());
        allWO.add(new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Developer Services').setRecordType(recTypeId).setPermit(testPermit.Id).setCaseId(allcase[1].Id).returnWithoutCreate());
        Insert allWO;
        
        // Create Test ServiceApointment associated with the workorder
        List<ServiceAppointment> allApp = new List<ServiceAppointment>();
        allApp.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(allWO[0].Id).setStatus('new').returnWithoutCreate());
        allApp.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(allWO[0].Id).setStatus('new').returnWithoutCreate());
        allApp.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(allWO[0].Id).setStatus('new').setIsBundle(true).returnWithoutCreate());
        Insert allApp;
        
        new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(allWO[1].Id).setStatus('new').setIsBundleMember(true).setRelatedBundleId(allApp[2].id).Create();
        
        //FSL__Time_Dependency__c creation 
        new FSM_TestDataFactory.AppointmentDependencyCreator().setServiceAppointment1(allApp[0].Id).setServiceAppointment2(allApp[1].Id).create();
        //FSM_DataCaptureFormInfra__c creation
        new FSM_TestDataFactory.DataCaptureFormInfraCreator().setWorkorder(allWO[0].Id).create();
        //FSM_DataCaptureFormNonInfra__c creation
        new FSM_TestDataFactory.DataCaptureFormNonInfraCreator().setWorkorder(allWO[0].Id).create();
    }
    @isTest
    static void testBatchDeletion() {
        list<case> casehd = [select id,status from case limit 1];
        // Start the batch process
        Test.startTest();
        casehd[0].status = 'closed';
        update casehd;
        FSM_CaseBatchDeletion batchDeletion = new FSM_CaseBatchDeletion();
        Database.executeBatch(batchDeletion);
        Test.stopTest();
         // list<case> excase = [select id from case];        
        // Verify that the cases have been deleted        
        System.assertEquals(0, [SELECT COUNT() FROM Case WHERE Status = 'Closed'],'all case should be deleted');
        System.assertEquals(0, [SELECT COUNT() FROM FSM_TMAPermitConditions__c],'all related child record should be deleted');
        
       
    }
    // To check scheduler class
    @isTest
    static void testSchedulerBatchDeletion() {
        Test.startTest();
        String jobId = System.schedule('Test FSM_CaseBatchDeletionScheduler', '0 0 0 * * ?', new FSM_CaseBatchDeletionScheduler());
        Test.stopTest();
        
        // Verify that the batch job has been scheduled
        System.assertEquals(1, [SELECT count() FROM CronTrigger WHERE Id = :jobId],'One job should be schedule at midnight daily');
        
    }
}
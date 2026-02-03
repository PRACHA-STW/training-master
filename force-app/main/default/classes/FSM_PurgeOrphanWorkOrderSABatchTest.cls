/********************************************************************************************************
@Author      : Srikanth Palla
@Description : This test class is to test FSM_PurgeOrphanWorkOrderSABatch and FSM_PurgeOrphanWorkOrderSASchedule class.
@description : Created as part of user story #SFI-1783
@Test Class  : FSM_PurgeOrphanWorkOrderSABatchTest
@Date        : 24-April-2024
********************************************************************************************************/
@isTest(SeeAllData = False)
private class FSM_PurgeOrphanWorkOrderSABatchTest {
    @TestSetUp
    static void testDataSetUp(){
        //Get RecordType Id 
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        // Create a Test permit
        FSM_TMAPermit__c testPermit = new FSM_TestDataFactory.TMAPermitCreator().create();
        // Create a Test permitcondition
        new FSM_TestDataFactory.TMAPermitConditionsCreator().setTMAPermit(testPermit.id).create();
        // Create a Test Case
        Case testCase = new FSM_TestDataFactory.CaseCreator().setTMA(testPermit.Id).setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').create();
        
        //Create Account
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        //Create Contact
        new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
                        .setEmail('no-reply@defaultemail.com').create();
        
        //Create workorder associated with case and permit 
        WorkOrder testWorkOrder = new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Developer Services').setRecordType(recTypeId).setPermit(testPermit.Id).setTemporaryRecord(true).setCaseId(testCase.Id).create();
        // Create a Two Test ServiceApointment associated with the workorder
        serviceAppointment testserviceAppointment = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(testWorkOrder.Id).setStatus('new').create();
        serviceAppointment testserviceAppointment2 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(testWorkOrder.Id).setStatus('new').create();
    }
    @isTest
    static void testBatchDeletionSuccess() {
        list<workorder> wo = [select id from workorder limit 1];
       
        Test.startTest();
        FSM_PurgeOrphanWorkOrderSABatch batchDeletion = new FSM_PurgeOrphanWorkOrderSABatch();
        Database.executeBatch(batchDeletion,20);
        Test.stopTest();   
        System.assertEquals(0, [SELECT COUNT() FROM workorder],'all case should be deleted');
        System.assertEquals(0, [SELECT COUNT() FROM serviceAppointment],'all related child record should be deleted');
    }
}
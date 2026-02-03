/********************************************************************************************************
@Author      : Subir Maji
@Description : This is test class to cover FSM_WorkHistoryTriggerHelper and FSM_WorkHistoryTriggerHandler.
@Description : Created as part of user story #SFI-2152
@Main Class  : FSM_WorkOrderTriggerHandler and FSM_WorkOrderTriggerHelper
@Date        : 30-May-2024
********************************************************************************************************/
@IsTest(SeeAllData=false)
public class FSM_WorkHistoryTriggerHandlerTest {
    /********************************************************************************************************
    @Author      : Subir Maji
    @description : This method is used to create test data setup.
    @Description : Created as part of user story #SFI-2152 
    @Date        : 30-May-2024
    ********************************************************************************************************/
	@TestSetup
    static void testDataSetup(){
        //Create Account
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        //Create Contact
        new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
                        .setEmail('no-reply@defaultemail.com').create();
        
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).create();
            
        //Create Work History
        List<FSM_WorkHistory__c> allwoHistory = new List<FSM_WorkHistory__c>();
        FSM_WorkHistory__c woHistory = new FSM_TestDataFactory.WorkHistoryCreator().setExternalID('Test1236').setWorkOrder(wo.ID).returnWithoutCreate();
        allwoHistory.add(woHistory);
        woHistory = new FSM_TestDataFactory.WorkHistoryCreator().setExternalID('Test1237').setWorkOrder(wo.ID).returnWithoutCreate();
        allwoHistory.add(woHistory);
        Insert allwoHistory;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @description : This method is used to Test the deletion of old record successfully.
    @Description : Created as part of user story #SFI-2152 
    @Date        : 30-May-2024
    ********************************************************************************************************/
    @IsTest
    static void testWorkHistoryDeletionSuccess(){                                        
        WorkOrder existingWO = [Select ID from WorkOrder Limit 1]; 
        FSM_WorkHistory__c newWoHistory;
        
        Test.startTest();
        	newWoHistory = new FSM_TestDataFactory.WorkHistoryCreator().setExternalID('Test1238').setWorkOrder(existingWO.Id).create();       
        Test.stopTest();
        
        List<FSM_WorkHistory__c> checkExistingWOHIS = [Select ID, FSM_WorkOrder__c from FSM_WorkHistory__c Where ID !=: newWoHistory.ID ];
        System.assertEquals(checkExistingWOHIS.isEmpty(),true, 'Old record got deleted');
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @description : This method is used to Test the deletion of old record Failure.
    @Description : Created as part of user story #SFI-2152 
    @Date        : 30-May-2024
    ********************************************************************************************************/
    @istest
    static void testWorkHistoryDeletionUpdate(){
        WorkOrder wo = [Select id from WorkOrder limit 1];
        FSM_WorkHistory__c exWOHis = [Select ID, FSM_JobNumber__c from FSM_WorkHistory__c where FSM_ExternalId__c Like: 'Test1236%' limit 1];
        test.StartTest();
        	exWOHis.FSM_JobNumber__c = '1234';
        	exWOHis.ID = exWOHis.ID;
        	Update exWOHis;
        test.StopTest();
        
        List<FSM_WorkHistory__c> checkExistingWOHIS = [Select ID, FSM_WorkOrder__c from FSM_WorkHistory__c Where FSM_ExternalId__c !=: 'Test1236'];
        System.assertEquals(checkExistingWOHIS.isEmpty(),false, 'Old record did not deleted in update senario');
    }
}
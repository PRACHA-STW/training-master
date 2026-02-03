/********************************************************************************************************
@Author 	 : Arnob Dey
@Description : This class is used to test WorkOrder update when Case is updated.
@description : Created as part of user story #SFS-318
@Main Class  : FSM_CaseTriggerHandler and FSM_CaseTriggerHelper
@Date        : 07-July-2023
			   02-12-2024  Aishwarya Bhosale Updated as part of SFS-8045
********************************************************************************************************/
@IsTest
public class FSM_CaseTriggerHandlerTest {   
/********************************************************************************************************
@Author      : Arnob Dey
@description : This method is used to create test data setup.
********************************************************************************************************/
    @TestSetup
    static void testDataSetup(){
        //Get RecordType Id
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        // Create a Test Case
        Case testCase = new FSM_TestDataFactory.CaseCreator().setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').setDescription('Long text info').create();
        // Create a Test WorkOrder associated with the Case
        new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setCaseId(testCase.Id).create();
        
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        
        new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
            			.setEmail('no-reply@defaultemail.com').create();
    }
    
/********************************************************************************************************
@Author      : Arnob Dey
@description : This method is used to test whether Customer Information is copied from Case to WorkOrder 
			   when Case is updated.
********************************************************************************************************/
    @IsTest
    static void testCustomerInformationUpdate(){                           
        Case caseRec = [SELECT Id, FSM_ContactName__c, FSM_ContactEmail__c,Description FROM Case LIMIT 1];     
       // System.debug('Contact name failed =='+caseRec);
        Test.startTest();
        // Update the customer information on the Case
        caseRec.FSM_ContactName__c = 'Mike Charles';
        caseRec.FSM_ContactEmail__c = 'mike.charles@gmail.com';
        caseRec.FSM_MSN__c = 'ABCD1234'; //Added by Manish Kumar Jagnani SFI-1469
        caseRec.Description='updated notification long txt';// Added as part of SFS-8045
        update caseRec; 
        //System.debug('Contact name failed 2 =='+caseRec);

        // Retrieve the updated WorkOrder record
        WorkOrder updatedWorkOrder = [SELECT Id, FSM_ContactName__c, FSM_ContactEmail__c,FSM_NotificationLongText__c FROM WorkOrder WHERE CaseId = :caseRec.Id];       
       // System.debug('updated workorder failed =='+updatedWorkOrder);

        Test.stopTest();
        
        // Assert the custom field value on the WorkOrder
        System.assertEquals(caseRec.FSM_ContactName__c, updatedWorkOrder.FSM_ContactName__c, 'ContactName information copied successfully');
        System.assertEquals(caseRec.FSM_ContactEmail__c, updatedWorkOrder.FSM_ContactEmail__c, 'ContactEmail information copied successfully');        
        System.assertEquals(updatedWorkOrder.FSM_NotificationLongText__c,'updated notification long txt', 'Notification long text information updated successfully');
    }
}
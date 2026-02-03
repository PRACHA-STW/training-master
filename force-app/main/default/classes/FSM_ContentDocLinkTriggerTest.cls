/********************************************************************************************************
@Author      : Srikanth Palla
@Description : This class is created to cover FSM_ContentDocumentLinkTrigger, FSM_ContentDocumentLinkTriggerHandler, FSM_ContentDocumentLinkTriggerHelper
@description  Created as part of user story #SFI-1213
@Date        : 22-April-2024
********************************************************************************************************/
@isTest(SeeAllData = False)
public class FSM_ContentDocLinkTriggerTest {
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description This method is used to create test data setup.
    *********************************************************************************************************/
    @testsetup
    static void testSetup(){
        // Fetching a single record of FSM_WorkPlanTemplateMapping__mdt for test data setup
        FSM_WorkPlanTemplateMapping__mdt workPlanTemplateMapping = [Select MasterLabel,FSM_RecordTypeDeveloperName__c,FSM_WorkPlanTemplateName__c from FSM_WorkPlanTemplateMapping__mdt limit 1];
        // Creating a WorkPlanTemplate using the data fetched from FSM_WorkPlanTemplateMapping__mdt
        WorkPlanTemplate workPlanTemplate = new FSM_TestDataFactory.WorkPlanTemplateCreator().setName(workPlanTemplateMapping.FSM_WorkPlanTemplateName__c).setIsActive(true).create();
        // Creating a WorkStepTemplate for testing purposes
        WorkStepTemplate workStepTemplate = new FSM_TestDataFactory.WorkStepTemplateCreator().setName('Test workStep').setIsActive(true).create();
        // Creating a WorkPlanTemplateEntry and associating it with the previously created WorkPlanTemplate and WorkStepTemplate
        WorkPlanTemplateEntry workPlanTemplateEntry = new FSM_TestDataFactory.WorkPlanTemplateEntryCreator().setWorkPlanTemplateId(workPlanTemplate.Id).setWorkStepTemplateId(workStepTemplate.Id).create();
        // Creating a new WorkOrder for testing purposes
        WorkOrder newWorkOrder = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus('New').setBusinessUnit('Waste Infra').create();
        // Defining dates for the ServiceAppointment
        DateTime earliestDate = datetime.newInstance(2023, 11, 15, 12, 30, 0);
        DateTime dueDate = datetime.newInstance(2023, 11, 15, 13, 30, 0);
        // Fetching RecordTypeId for ServiceAppointment
        id recordTypeId=Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_WASTEINFRA).getRecordTypeId();
        // Creating a new ServiceAppointment and associating it with the previously created WorkOrder
        ServiceAppointment newServiceAppointment= new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(recordTypeId).setParentRecordId(newWorkOrder.id).setStatus('New').setEarliestStartTime(earliestDate).setDueDate(dueDate).create();
        // Creating a new ContentVersion for testing purposes
        ContentVersion newContentVersion = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('test.pdf').setTitle('test title').setVersionData(Blob.valueOf( 'Testing content version')).create();    
    }

    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This test method verifies the successful creation of attachment upload when ContentDocumentLink is created using FSM_AttachmentUploadCalloutMock class.
    ******************************************************************************************************/
    @isTest
    static void testCreateContentdocumentlinkSuccess(){

        // Obtain the Id of a ContentVersion record.
        id contentVersionId=[Select id from ContentVersion limit 1].id;
        // Retrieve the ContentDocumentId associated with the ContentVersion record.
        id contentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        // Obtain the Id of a ServiceAppointment record.
        id serviceAppointmentId=[Select id from ServiceAppointment limit 1].id;
        // Obtain the Id of a WorkOrder record.
        id workOrderId=[Select id from WorkOrder limit 1].id;
        // Start the test execution.
        Test.startTest();
        // Set up a mock HTTP callout for attachment upload using FSM_AttachmentUploadCalloutMock class.
        Test.setMock(HttpCalloutMock.class, new FSM_AttachmentUploadCalloutMock());
        // Create a ContentDocumentLink record linking the ContentVersion to the ServiceAppointment.
        ContentDocumentLink cdl = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(serviceAppointmentId).create();
        // Create another ContentDocumentLink record linking the ContentVersion to the WorkOrder.
        ContentDocumentLink cdl1 = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(workOrderId).create();
        // Stop the test execution.
        Test.stopTest();
        FSM_IntegrationLog__c log = new FSM_IntegrationLog__c();
        log = [Select ID from FSM_IntegrationLog__c Limit 1];
        // Assert that both ContentDocumentLink records are successfully inserted.
        System.Assert(cdl.Id != null && cdl1.Id !=null, 'Content document link insertion Successfull'); 
        System.Assert(log != null, 'Integration Log created');  
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   Test method to verify the failure scenario of attachment upload when ContentDocumentLink is created without using a mock HTTP callout.
    ******************************************************************************************************/
    @isTest
    static void testCreateContentdocumentlinkFailure(){
        // Obtain the Id of a ContentVersion record.
        id contentVersionId=[Select id from ContentVersion limit 1].id;
        // Retrieve the ContentDocumentId associated with the ContentVersion record.
        id contentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        // Obtain the Id of a ServiceAppointment record.
        id serviceAppointmentId=[Select id from ServiceAppointment limit 1].id;
        // Obtain the Id of a WorkOrder record.
        id workOrderId=[Select id from WorkOrder limit 1].id;
        // Start the test execution.
        Test.startTest();
        // Create a ContentDocumentLink record linking the ContentVersion to the ServiceAppointment.
        ContentDocumentLink cdl = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(serviceAppointmentId).create();
        // Create another ContentDocumentLink record linking the ContentVersion to the WorkOrder.
        ContentDocumentLink cdl1 = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(workOrderId).create();
        // Stop the test execution.
        Test.stopTest();
        // Verifying if an error log is created
        FSM_ErrorLog__c errLog = [Select id from FSM_ErrorLog__c Limit 1];
        System.Assert(errLog != null, 'Error log created');        
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   Test method to verify the failure scenario of attachment upload when ContentDocumentLink is created using FSM_AttachmentUploadCalloutMock2 class.
    ******************************************************************************************************/
     @isTest
    static void testCreateContentdocumentlinkFailure1(){
        // Obtain the Id of a ContentVersion record.
        id contentVersionId=[Select id from ContentVersion limit 1].id;
        // Retrieve the ContentDocumentId associated with the ContentVersion record.
        id contentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        // Obtain the Id of a ServiceAppointment record.
        id serviceAppointmentId=[Select id from ServiceAppointment limit 1].id;
        // Start the test execution.
        Test.startTest();
        // Set up a mock HTTP callout for attachment upload using FSM_AttachmentUploadCalloutMock2 class.
        Test.setMock(HttpCalloutMock.class, new FSM_AttachmentUploadCalloutMock2());
        // Create a ContentDocumentLink record linking the ContentVersion to the ServiceAppointment.
        ContentDocumentLink cdl = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(serviceAppointmentId).create();
        // Stop the test execution.
        Test.stopTest();
        // Verifying if an error log is created
        FSM_ErrorLog__c errLog = [Select id from FSM_ErrorLog__c Limit 1];
        System.Assert(errLog != null, 'Error log created');                
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   Test method to Increase coverage for Contant document trigger handler for update secnario
    ******************************************************************************************************/
     @isTest
    static void testCreateContentdocumentlinkUpdate(){
        // Obtain the Id of a ContentVersion record.
        id contentVersionId=[Select id from ContentVersion limit 1].id;
        // Retrieve the ContentDocumentId associated with the ContentVersion record.
        id contentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        // Obtain the Id of a ServiceAppointment record.
        id serviceAppointmentId=[Select id from ServiceAppointment limit 1].id;
        // Start the test execution.
        Test.startTest();
        // Create a ContentDocumentLink record linking the ContentVersion to the ServiceAppointment.
        ContentDocumentLink cdl = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(serviceAppointmentId).create();
        update cdl;
        // Stop the test execution.
        Test.stopTest();
        // Verifying if an error log is created
        System.Assert(cdl != null, 'Content Documnet link Updated');                
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This test method verifies the successful creation of attachment upload when ContentDocumentLink is created using FSM_AttachmentUploadCalloutMock class.
    ******************************************************************************************************/
    @isTest
    static void testContVersionFailForNotSentSAP(){
		// Creating a new ContentVersion for testing purposes
        ContentVersion newContentVersion = new FSM_TestDataFactory.ContentVersionCreator().setDoNotSendToSAP(true).setPathOnClient('test1.pdf').setTitle('test title1').setVersionData(Blob.valueOf( 'Testing content version1')).create();
        // Retrieve the ContentDocumentId associated with the ContentVersion record.
        id contentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: newContentVersion.ID].ContentDocumentId;
        // Obtain the Id of a ServiceAppointment record.
        id serviceAppointmentId=[Select id from ServiceAppointment limit 1].id;
        // Obtain the Id of a WorkOrder record.
        id workOrderId=[Select id from WorkOrder limit 1].id;
        // Start the test execution.
        Test.startTest();
        // Set up a mock HTTP callout for attachment upload using FSM_AttachmentUploadCalloutMock class.
        Test.setMock(HttpCalloutMock.class, new FSM_AttachmentUploadCalloutMock());
        // Create a ContentDocumentLink record linking the ContentVersion to the ServiceAppointment.
        ContentDocumentLink cdl = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(serviceAppointmentId).create();
        // Create another ContentDocumentLink record linking the ContentVersion to the WorkOrder.
        ContentDocumentLink cdl1 = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(workOrderId).create();
        // Stop the test execution.
        Test.stopTest();
        List<FSM_IntegrationLog__c> log = [Select ID from FSM_IntegrationLog__c Limit 1];
        // Assert that both ContentDocumentLink records are successfully inserted.
        System.Assert(cdl.Id != null && cdl1.Id !=null, 'Content document link insertion Successfull'); 
        System.Assert(log.IsEmpty() == true, 'Integration Log not created');  
    }
    /******************************************************************************************************
    @Author       : Asutosh Singh
    @description   This test method verifies the successful call of FSM_ManualRetry class and it's method.
    ******************************************************************************************************/
    @isTest
    static void testCreateManualRetry(){
        // Obtain the Id of a ContentVersion record.
        id contentVersionId=[Select id from ContentVersion limit 1].id;
        // Retrieve the ContentDocumentId associated with the ContentVersion record.
        id contentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        // Obtain the Id of a ServiceAppointment record.
        id serviceAppointmentId=[Select id from ServiceAppointment limit 1].id;
        // Start the test execution.
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FSM_AttachmentUploadCalloutMock());
        // Create a ContentDocumentLink record linking the ContentVersion to the ServiceAppointment.
        ContentDocumentLink cdl = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(serviceAppointmentId).create();
        // Create a RetryInputParam object with the ContentDocumentLink record
        FSM_ManualRetry.RetryInputParam inputParam = new FSM_ManualRetry.RetryInputParam();
        inputParam.cdlRecord = cdl;
        // Prepare a list of RetryInputParam objects
        List<FSM_ManualRetry.RetryInputParam> inputParams = new List<FSM_ManualRetry.RetryInputParam>();
        inputParams.add(inputParam);
        // Call the manualRetry method
        FSM_ManualRetry.manualRetry(inputParams);
        // Stop the test execution.
        Test.stopTest();
        FSM_IntegrationLog__c log = new FSM_IntegrationLog__c();
        log = [Select ID from FSM_IntegrationLog__c Limit 1];
        System.Assert(log != null, 'Integration Log created');
    }
    /******************************************************************************************************
    @Author       : Asutosh Singh
    @description   This test method verifies the successful call of FSM_RetryRequestForInterface14 class and it's method.
    ******************************************************************************************************/
    @isTest
    static void testCreateRetryRequestForInterface14(){
        // Obtain the Id of a ContentVersion record.
        id contentVersionId=[Select id from ContentVersion limit 1].id;
        // Retrieve the ContentDocumentId associated with the ContentVersion record.
        id contentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        // Obtain the Id of a ServiceAppointment record.
        id serviceAppointmentId=[Select id from ServiceAppointment limit 1].id;
        // Start the test execution.
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FSM_AttachmentUploadCalloutMock());
        // Create a ContentDocumentLink record linking the ContentVersion to the ServiceAppointment.
        ContentDocumentLink cdl = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(serviceAppointmentId).create();
        // Create error log
        new FSM_Utility.ErrorLogCreator().setClassName('FSM_SendUploadAttachmentsQueueable').setMethodName('sendUploadAttachments').setErrorMessage('Test Message').setLineNumber(cdl.Id).setType('Integration').setRetryFlag(true).setInterface('INT-014').create();
        // Create a FSM_RetryRequestForInterface14 objects
        FSM_RetryRequestForInterface14 retryObject = new FSM_RetryRequestForInterface14();
        retryObject.execute(null);
        // Stop the test execution.
        Test.stopTest();
        FSM_IntegrationLog__c log = new FSM_IntegrationLog__c();
        log = [Select ID from FSM_IntegrationLog__c Limit 1];
        System.Assert(log != null, 'Integration Log created');
    }
    /******************************************************************************************************
    @Author       : Asutosh Singh
    @description   This test method verifies the failure call of FSM_RetryRequestForInterface14 class and it's method.
    ******************************************************************************************************/
    @isTest
    static void testFailureRetryRequestForInterface14(){
        // Start the test execution.
        Test.startTest();
        new FSM_Utility.ErrorLogCreator().setClassName('FSM_SendUploadAttachmentsQueueable').setMethodName('sendUploadAttachments').setErrorMessage('Test Message').setLineNumber('test').setType('Integration').setRetryFlag(true).setInterface('INT-014').create();
        // Create a FSM_RetryRequestForInterface14 objects
        FSM_RetryRequestForInterface14 retryObject = new FSM_RetryRequestForInterface14();
        retryObject.execute(null);
        // Stop the test execution.
        Test.stopTest();
        FSM_ErrorLog__c log = new FSM_ErrorLog__c();
        log = [Select ID from FSM_ErrorLog__c Limit 1];
        System.Assert(log != null, 'Error Log created');
    }
}
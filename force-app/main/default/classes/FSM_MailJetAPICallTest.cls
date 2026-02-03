/********************************************************************************************************
@Author 	 : Asutosh Singh
@Description : This class is used to test FSM_MailJetAPICall.
@description : Created as part of user story #SFI-1821
@Main Class  : FSM_MailJetAPICall
@Date        : 30-May-2024
********************************************************************************************************/
@isTest(SeeAllData = False)
public class FSM_MailJetAPICallTest {
    /********************************************************************************************************
    @Author      : Asutosh Singh
    @description : This method is used to create test data setup.
    *********************************************************************************************************/
    @testsetup
    static void testSetup(){
        // Creating a new WorkOrder for testing purposes
        WorkOrder newWorkOrder = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus('New').setBusinessUnit('Waste Infra').create();
        // Defining dates for the ServiceAppointment
        DateTime earliestDate = datetime.newInstance(2023, 11, 15, 12, 30, 0);
        DateTime dueDate = datetime.newInstance(2023, 11, 15, 13, 30, 0);
        // Fetching RecordTypeId for ServiceAppointment
        Id recordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_WASTEINFRA).getRecordTypeId();
        // Creating a new ServiceAppointment and associating it with the previously created WorkOrder
        ServiceAppointment newServiceAppointment = new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(recordTypeId)
            .setParentRecordId(newWorkOrder.id).setStatus('New').setEarliestStartTime(earliestDate).setDueDate(dueDate)
            .setBusinessAreaMailjet('Waste').setCustomerEmail('test@abc.com').setCustomerName('test name')
            .setListOfTemplates('Net Tech').setCustomerEmail1('test@t1.com').setCustomerEmail2('test@t2.com')
            .setCustomerEmail3('test@t3.com').setCustomerEmail4('test@t4.com').setCustomerEmail5('test@t5.com').
            setDuringVisitWeFound('No problems - the drains are flowing as they should').create();
        // Creating a new ContentVersion for testing purposes
        ContentVersion newContentVersion = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('test.pdf').setTitle('test title').setVersionData(Blob.valueOf( 'Testing content version')).create();
    }
    
    /******************************************************************************************************
    @Author       : Asutosh Singh
    @description  : This test method verifies the successful creation of MailJet API Call when Task is created using FSM_MailJetAPIMock class.
    ******************************************************************************************************/
    @IsTest
    static void testSuccessMailJetApiCall() {
        // Obtain the Id of a ServiceAppointment record.
        Id serviceAppointmentId = [Select id from ServiceAppointment limit 1].id;

        // Start the test execution.
        Test.startTest();
        // Set up a mock HTTP callout for MailJet API Call using FSM_MailJetAPIMock class.
        Test.setMock(HttpCalloutMock.class, new FSM_MailJetAPIMock());
        // Create a Task record with type Leaflets.
        Task tsk1 = new FSM_TestDataFactory.TaskCreator().setWhatId(serviceAppointmentId).setType('Leaflets').setStatus('Open').create();
        // Create another Task record with type Proforma.
        Task tsk2 = new FSM_TestDataFactory.TaskCreator().setWhatId(serviceAppointmentId).setType('Proforma').setStatus('Open').create();
        // Stop the test execution.
        Test.stopTest();
        
        List<FSM_IntegrationLog__c> log = [Select Id from FSM_IntegrationLog__c Limit 1];
        // Assert that both Task records are successfully inserted.
        System.assert(tsk1.Id != null && tsk2.Id != null, 'Task insertion Successful');
        System.Assert(log != null, 'Integration Log created');
    }
    
    /******************************************************************************************************
    @Author       : Asutosh Singh
    @description  : Test method to verify the failure scenario of MailJet API Call when Task is created using FSM_MailJetAPIMock2 class.
    ******************************************************************************************************/
    @isTest
    static void testFailureMailJetApiCall(){
        // Obtain the Id of a ServiceAppointment record.
        Id serviceAppointmentId = [Select id from ServiceAppointment limit 1].id;

        // Start the test execution.
        Test.startTest();
        // Set up a mock HTTP callout for MailJet API Call using FSM_MailJetAPIMock class.
        Test.setMock(HttpCalloutMock.class, new FSM_MailJetAPIMock2());
        // Create a Task record with type Leaflets.
        Task tsk1 = new FSM_TestDataFactory.TaskCreator().setWhatId(serviceAppointmentId).setType('Leaflets').setStatus('Open').create();
        // Stop the test execution.
        Test.stopTest();
        // Verifying if an error log is created
        FSM_ErrorLog__c errLog = [Select id from FSM_ErrorLog__c Limit 1];
        System.Assert(errLog != null, 'Error log created');
    }

    /******************************************************************************************************
    @Author       : Asutosh Singh
    @description  : Test method to verify the failure scenario of MailJet API Call when Task is created using FSM_MailJetAPIMock2 class.
    ******************************************************************************************************/
    @isTest
    static void testMailJetApiCallException(){
        // Obtain the Id of a ContentVersion record.
        id contentVersionId=[Select id from ContentVersion limit 1].id;
        // Retrieve the ContentDocumentId associated with the ContentVersion record.
        id contentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        // Obtain the Id of a ServiceAppointment record.
        Id serviceAppointmentId = [Select id from ServiceAppointment limit 1].id;

        // Start the test execution.
        Test.startTest();
        // Set up a mock HTTP callout for MailJet API Call using FSM_MailJetAPIMock class.
        Test.setMock(HttpCalloutMock.class, new FSM_MailJetAPIMock2());
        // Create a Task record with type Leaflets.
        Task tsk1 = new FSM_TestDataFactory.TaskCreator().setWhatId(serviceAppointmentId).setType('Proforma').setStatus('Not Started').create();
        ContentDocumentLink cdl = new FSM_TestDataFactory.ContentDocumentLinkCreator().setContentDocId(contentDocumentId).setLinkedEntityId(tsk1.Id).create();
        tsk1.Status = 'Open';
        update tsk1;
        // Stop the test execution.
        Test.stopTest();
        // Verifying if an error log is created
        FSM_ErrorLog__c errLog = [Select id from FSM_ErrorLog__c Limit 1];
        System.Assert(errLog != null, 'Error log created');
    }
}
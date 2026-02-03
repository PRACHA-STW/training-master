/********************************************************************************************************
@Author      : Deepak
@description : This Class is a test class for FSM_Utility
@description : Created as part of user story #SFI-
@Date        : 1-July-2023
********************************************************************************************************/
@isTest(SeeAllData = False)
public class FSM_UtilityTest {
    
    //Setting up test data
    @testsetup
    static void testSetup(){
        FSM_WorkPlanTemplateMapping__mdt woMdt = [Select MasterLabel,FSM_RecordTypeDeveloperName__c,FSM_WorkPlanTemplateName__c from FSM_WorkPlanTemplateMapping__mdt limit 1];
        
        WorkPlanTemplate woTemp = new FSM_TestDataFactory.WorkPlanTemplateCreator().setName(woMdt.FSM_WorkPlanTemplateName__c).setIsActive(true).create();
        WorkStepTemplate woStep = new FSM_TestDataFactory.WorkStepTemplateCreator().setName('Test workStep').setIsActive(true).create();
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setStatus('New').setExternalId('123uh').setBusinessUnit('Waste Infra').create();
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        Contact con = new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
            			.setEmail('no-reply@defaultemail.com').create();
    }
    
    @isTest
    static void testCreateErrorAndIntegrationLog(){
        WorkOrder woData = [select id from WorkOrder limit 1];
       
        FSM_ErrorLog__c testerrorlog;
        FSM_IntegrationLog__c intLog;
        
        Test.startTest();
        woData.status = 'In Progress';
        update woData;
        testerrorlog = new FSM_Utility.ErrorLogCreator().setClassName('TestClass')
            .setErrorMessage('Test Error').setLineNumber('2').setMethodName('testmethod').setStackTrace('test').setType('Field Service')
            .setExternalID('TestExtId').setRetryFlag(false).setInterface('INT-014').create();
        intLog = new FSM_Utility.IntegrationLogCreator().setRecordId('1234')
            .setReqPayload('Test PayLoad').setResPayload('200').setServiceName('testmethod').setExternalId('test123').create();
        Test.stopTest();
        
        List<FSM_IntegrationLog__c> logRec = [select id,FSM_RecordId__c from FSM_IntegrationLog__c where FSM_RecordId__c = :woData.Id];
        System.Assert(logRec.size()==1 , 'Platform Event is not invoked!');
        System.Assert(testerrorlog.FSM_ClassFlowName__c == 'TestClass' , 'Error Log created');
        System.Assert(intLog.FSM_ExternalId__c == 'test123' , 'Integration Log created');
    }
    
    @isTest
    static void testRandomNumber()
    {
        Test.startTest();
        String randomValue = FSM_Utility.generateRandomNumber();
        Test.stopTest();
        System.assert(randomValue!=null, 'Random value is not generated!');
    }
}
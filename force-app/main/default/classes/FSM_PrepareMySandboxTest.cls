/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class is used to test batch job to support data masking / anonymization of data 
@description : Created as part of user story #SFS-4144
@Main Class  : FSM_PrepareMySandboxBatchUpdate and FSM_PrepareMySandbox 
@Date        : 07-February-2024
********************************************************************************************************/
@isTest
class FSM_PrepareMySandboxTest {
    /*******************************************************************************************************
@Author      : Brajesh Kumar
@Description : This method is used to create test data setup.
********************************************************************************************************/
    /* Created for test data setup */
    @testsetup 
    static void makeData(){
        Case c = new FSM_TestDataFactory.CaseCreator().setContactId('23424567').setContactName('Alex').setContactEmail('alex@stw.co.uk').setContactPhoneNumber('987654321').setSpecialCondition('Apex Class Test').setMSN('565657').create();
		WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setContactId(c.FSM_ContactID__c).setContactName(c.FSM_ContactName__c).setContactEmail(c.FSM_ContactEmail__c).setContactPhone(c.FSM_ContactPhoneNumber__c).setSpecialCondition(c.FSM_SpecialCondition__c).setMSN(c.FSM_MSN__c).create();
    }
    
    @isTest
    static void testMySandboxPrep() {  
        Test.startTest();
        //Execute test script with RunAsAutoProcUser set to true
        Test.testSandboxPostCopyScript(
            new FSM_PrepareMySandbox(), UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(), UserInfo.getOrganizationName(), true);
        Test.stopTest();
        // Perform queries to retrieve the updated Case and Work Order
        Case cse = [SELECT id,FSM_ContactID__c,FSM_ContactName__c,FSM_ContactEmail__c,FSM_ContactPhoneNumber__c,FSM_SpecialCondition__c,FSM_MSN__c,FSM_isRefreshed__C FROM Case];
        WorkOrder wos = [SELECT id,FSM_ContactID__c,FSM_ContactName__c,FSM_ContactEmail__c,FSM_ContactPhoneNumber__c,FSM_SpecialCondition__c,
                         FSM_ManufacturersSerialNumber__c,FSM_isRefreshed__c FROM WorkOrder];
        
        // Assert the expected results to verify that the Case Record is Masked and FSM_isRefreshed__c = True
        System.assertEquals(True, cse.FSM_isRefreshed__c, 'Successfully Masked Case Record Data');
        // Assert the expected results to verify that the Work Order Record is Masked and FSM_isRefreshed__c = True
        System.assertEquals(True, wos.FSM_isRefreshed__c, 'Successfully Masked Work Order Record Data');
    }
}
/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class is used to test batch job to support data masking / anonymization of data.This test class does not refer any other class for data creation
@description : Created as part of user story #SFS-4144
@Main Class  : FSM_PrepareMySandboxBatchUpdate and FSM_PrepareMySandbox 
@Date        : 09-February-2024
********************************************************************************************************/
@isTest
public class FSM_PrepareMySandboxTestProd {
    /*******************************************************************************************************
@Author      : Brajesh Kumar
@Description : This method is used to create test data setup.
********************************************************************************************************/
    //Created for test data setup
    @testsetup 
    static void makeData(){
        Case c = new Case();
        c.FSM_ContactID__c ='23424567';
        c.FSM_ContactName__c ='Alex';
        c.FSM_ContactEmail__c='alex@stw.co.uk';
        c.FSM_ContactPhoneNumber__c='987654321';
        c.FSM_SpecialCondition__c='Apex Class Test';
        c.FSM_MSN__c='565657';
        insert c; 
        
        // Creating Work Order
        WorkOrder wo = new WorkOrder();
        wo.FSM_ContactID__c='12121';
        wo.FSM_ContactName__c='Alex';
        wo.FSM_ContactEmail__c='alex@gmail.com';
        wo.FSM_ContactPhoneNumber__c='7878232323';
        wo.FSM_SpecialCondition__c='STW test data';
        wo.FSM_ManufacturersSerialNumber__c='12334456';
        insert wo;
        
    }
    
    @isTest
    static void testMySandboxPrepProd() {  
        Test.startTest();
        //Execute test script with RunAsAutoProcUser set to true
        Test.testSandboxPostCopyScript(
            new FSM_PrepareMySandbox(), UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(), UserInfo.getOrganizationName(), true);
        Test.stopTest();
        // Perform queries to retrieve the updated Case and Work Order
        Case cse = [SELECT id,FSM_ContactID__c,FSM_ContactName__c,FSM_ContactEmail__c,FSM_ContactPhoneNumber__c,FSM_SpecialCondition__c,FSM_MSN__c,FSM_isRefreshed__C FROM Case];
        WorkOrder wos = [SELECT id,FSM_ContactID__c,FSM_ContactName__c,FSM_ContactEmail__c,FSM_ContactPhoneNumber__c,FSM_SpecialCondition__c,
                         FSM_ManufacturersSerialNumber__c,FSM_isRefreshed__c FROM WorkOrder WHERE FSM_isRefreshed__c=True];        
        // Assert the expected results to verify that the Case Record is Masked and FSM_isRefreshed__c = True
        System.assertEquals(True, cse.FSM_isRefreshed__c, 'Successfully Masked Case Record Data');
        // Assert the expected results to verify that the Work Order Record is Masked and FSM_isRefreshed__c = True
        System.assertEquals(True, wos.FSM_isRefreshed__c, 'Successfully Masked Work Order Record Data');   
    }
    
}
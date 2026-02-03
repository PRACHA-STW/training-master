/**************************************************************************************
    - Description  : Created for DCF Distribution Feedback Form
    - Created By   : Aishwarya Bhosale
    - Created Date : 12 Nov, 2023
    - Modified By  : 6th Dec, 2023 by Brajesh Kumar & Arnob Dey - SFS-3778
                   : 28th Dec, 2023 by Leena - SFS-3010
                   : 4th Jan, 2024 by Arnob - SFS-3007
				   : 16th Sept,2024 by Aishwarya Bhosale SFS-7045
****************************************************************************************/
@isTest
public class FSM_DependantPicklistclsTest {
    @testsetup
    static void makedata(){
        List<FSM_DCFDependantPicklist__c> listdp = new List<FSM_DCFDependantPicklist__c>();
        FSM_DCFDependantPicklist__c dp = new FSM_TestDataFactory.DCFDependantPicklistCreator().setAsset('D 2').setTask('D 2').setTechnique('3').setMaterial('2').setSize('25').returnWithoutCreate();
        listdp.add(dp);
        FSM_DCFDependantPicklist__c dp1 = new FSM_TestDataFactory.DCFDependantPicklistCreator().setAsset('D 2').setTask('D 2').setTechnique('3').setMaterial('2').setSize('28').returnWithoutCreate();
        listdp.add(dp1);
        insert listdp;
        
        //Sewerage Dependant Picklist data
        List<FSM_DCFDependantPicklist__c> swrPicklist = new List<FSM_DCFDependantPicklist__c>();
        FSM_DCFDependantPicklist__c swrDp = new FSM_TestDataFactory.DCFDependantPicklistCreator().setSWRTask('8').setSWRAsset('57').setSWRJobScope('9').setSWRTransferredAsset('N').setSWRJobRecepient('1').setType('Sewerage Further Work').returnWithoutCreate();
        swrPicklist.add(swrDp);
        FSM_DCFDependantPicklist__c swrDp1 = new FSM_TestDataFactory.DCFDependantPicklistCreator().setSWRTask('4').setSWRAsset('49').setSWRJobScope('1').setSWRTransferredAsset('N').setSWRJobRecepient('1').setType('Sewerage Further Work').returnWithoutCreate();
        swrPicklist.add(swrDp1);
        insert swrPicklist;
        
        //Sewerage Job Feedback Picklist data
         
        List<FSM_DCFDependantPicklist__c> swrjobPicklist = new List<FSM_DCFDependantPicklist__c>();
        FSM_DCFDependantPicklist__c swrjobfbDp = new FSM_TestDataFactory.DCFDependantPicklistCreator().setSWRJobFeedbackAsset('S 20').setSWRJobFeedbackTask('S 04').setSWRJobFeedbackRecepient('1').setType('Sewerage Job Feedback').returnWithoutCreate();
        swrjobPicklist.add(swrjobfbDp);
        FSM_DCFDependantPicklist__c swrjobfbDp1 = new FSM_TestDataFactory.DCFDependantPicklistCreator().setSWRJobFeedbackAsset('S 20').setSWRJobFeedbackTask('S 04').setSWRJobFeedbackRecepient('2').setType('Sewerage Job Feedback').returnWithoutCreate();
        swrjobPicklist.add(swrjobfbDp1);
        insert swrjobPicklist;
        
        // Create users
        User testUser = new FSM_TestDataFactory.CretaeUser().create();
        
        //Create WO
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus('New').setBusinessUnit('Waste Infra').create();                    
    }
    
    @isTest
    static void testCreateDataPositiveCase(){
        Test.startTest();
        List<FSM_DCFDependantPicklist__c> pickvalues=FSM_DependantPicklistcls.getDependentPicklistrecord();        
        Test.stopTest();
        
        System.assert(pickvalues.size()>0,'Records retreived successfully');
    }
    
    /* Arnob added - SFS-3778 - Start */
    @isTest
    static void testGetAllRecords() {
        // Start the test
        Test.startTest();
        List<FSM_DCFDependantPicklist__c> allRecords = FSM_DependantPicklistcls.getAllRecords();
        // Stop the test
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, allRecords, 'List of all records is null');
        System.assertNotEquals(0, allRecords.size(), 'No records found');
    }
    
    @isTest
    static void testGetAssetList() {
        // Start the test
        Test.startTest();
        
        FSM_DependantPicklistcls.WrapperCls wrapper = FSM_DependantPicklistcls.getAssetList();
        
        // Stop the test
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, wrapper, 'Wrapper class instance is null');
        
        // Ensure each picklist in the wrapper is not null
        System.assertNotEquals(null, wrapper.assetList, 'Asset picklist is null');
        System.assertNotEquals(null, wrapper.taskList, 'Task picklist is null');
        System.assertNotEquals(null, wrapper.techniqueList, 'Technique picklist is null');
        System.assertNotEquals(null, wrapper.sizeList, 'Size picklist is null');
        System.assertNotEquals(null, wrapper.materialList, 'Material picklist is null');
    }
    /* Arnob added - SFS-3778 - End */
 
    /*Leena added - SFS-3010 - Start */
    @isTest
    static void testGetAllSWRRecords() {
        // Start the test
        Test.startTest();
        List<FSM_DCFDependantPicklist__c> allSWRRecords = FSM_DependantPicklistcls.getAllSWRRecords();
        // Stop the test
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, allSWRRecords, 'List of all records is null');
        System.assertNotEquals(0, allSWRRecords.size(), 'No records found');
    }
    
    @isTest
    static void testGetSWRTaskList() {
        // Start the test
        Test.startTest();
        
        FSM_DependantPicklistcls.swrWrapperCls swrWrapper = FSM_DependantPicklistcls.getSWRTaskList();
        
        // Stop the test
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, swrWrapper, 'Wrapper class instance is null');
        
        // Ensure each picklist in the swrWrapper is not null
        System.assertNotEquals(null, swrWrapper.assetList, 'Asset picklist is null');
        System.assertNotEquals(null, swrWrapper.taskList, 'Task picklist is null');
        System.assertNotEquals(null, swrWrapper.jobScopeList, 'Job Scope picklist is null');
        System.assertNotEquals(null, swrWrapper.transferredAssetList, 'Transferred Asset is null');
        System.assertNotEquals(null, swrWrapper.jobRecepientList, 'Job Recepient is null');
    }
    /*Leena added - SFS-3010 - End */
    
    /*Arnob added - SFS-3007 - Start */ 
    @isTest
    static void testGetSWRAssetList() {
        // Start the test
        Test.startTest();
        
        FSM_DependantPicklistcls.SWRFeedbackWrapperCls swrWrapper = FSM_DependantPicklistcls.getSWRAssetList();
        
        // Stop the test
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, swrWrapper, 'Wrapper class instance is null');
        
        // Ensure each picklist in the swrWrapper is not null
        System.assertNotEquals(null, swrWrapper.assetList, 'SWR Asset picklist is null');
        System.assertNotEquals(null, swrWrapper.taskList, 'SWR Task picklist is null');
        System.assertNotEquals(null, swrWrapper.recipientList, 'SWR Job Recipient picklist is null');        
    }
    /*Arnob added - SFS-3007 - End */
    
     /*Aishwarya added - SFS-7045 - Start */
    @isTest
    static void testgetAllSWRJobRecords() {
        // Start the test
        Test.startTest();
        List<FSM_DCFDependantPicklist__c> allSWRJobRecords = FSM_DependantPicklistcls.getAllSWRJobRecords();
        // Stop the test
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, allSWRJobRecords, 'List of all records is null');
        System.assertNotEquals(0, allSWRJobRecords.size(), 'No records found');
    }
      @isTest
    static void testgetSWRJobAssetList() {
        // Start the test
        Test.startTest();
        
        FSM_DependantPicklistcls.SWRJobFeedbackWrapperCls swrjobfbWrapper = FSM_DependantPicklistcls.getSWRJobAssetList();
        
        // Stop the test
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, swrjobfbWrapper, 'Wrapper class instance is null');
        
        // Ensure each picklist in the swrWrapper is not null
        System.assertNotEquals(null, swrjobfbWrapper.assetList, 'Asset picklist is null');
        System.assertNotEquals(null, swrjobfbWrapper.taskList, 'Task picklist is null');
        System.assertNotEquals(null, swrjobfbWrapper.recipientList, 'Job Recipient picklist is null');
        
    }
     /*Aishwarya added - SFS-7045 - End */
}
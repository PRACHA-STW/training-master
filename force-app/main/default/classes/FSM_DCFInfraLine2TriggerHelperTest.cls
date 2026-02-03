/********************************************************************************************************
@Author 	 : Subir Maji
@Description : This class is used to test FSM_DCFInfraLine1TriggerHelper.
@description : Created as part of user story #SFI-2041
@Main Class  : FSM_DCFInfraLine1TriggerHelper
@Date        : 01-Aug-2024
********************************************************************************************************/
@istest(SeeAllData = False)
public class FSM_DCFInfraLine2TriggerHelperTest {
    static Integer numberOfRecordsToCreate = 1;
    
    //This method is for test Data set-up in bulk
    @TestSetup
    static void makeData(){
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName(FSM_Constants.DCF_SCHEDULING_POLICY).create();
        
        User newUser = new FSM_TestDataFactory.CretaeUser().create();
        
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName(FSM_Constants.OH_AM_PM).setSlotType(FSM_Constants.DURATION)
                             .setBusinessUnit(FSM_Constants.BUSINESS_UNIT).create();
        
        ServiceResource sr = new FSM_TestDataFactory.ServiceResourceCreator().setName(FSM_Constants.RESOURCE_NAME).setIsActive(true)
                             .setRelatedRecordId(newUser.Id).setExternalId('1234').setBusinessUnit(FSM_Constants.WO_BUSINESS_UNIT).create();
        
        ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory').setIsActive(true)
                             .setExtenalId('888999').setOpreratingHours(op.Id).setSchedulingPolicy(schedulingPolicy.Id).setTerritoryLevel(5).create();
        
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(st.Id)
                       .setBusinessUnit('Waste Infra').setOpenDate(DateTime.Now()).setSlaDate(DateTime.Now()).create();
        
        //Create Account
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        //Create Contact
        new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
            			.setEmail('no-reply@defaultemail.com').create();
        
        //Infra Variables set-up
        List<FSM_InfraDataCaptureForm2__c> allDCFInfra1 = new List<FSM_InfraDataCaptureForm2__c>();
        FSM_InfraDataCaptureForm2__c testrecordInfra1;
        
        //Fetching Record Type Id for Infra 2 object
        ID infraRecordTypeID1 = Schema.SObjectType.FSM_InfraDataCaptureForm2__c.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.FORMTYPE_INFRA1).getRecordTypeId();
        
        //Looping over bulk infra 1 record creation
        for(Integer i = 0;i<numberOfRecordsToCreate;i++){
            testrecordInfra1 = new FSM_TestDataFactory.DataCaptureFormInfra1Creator().setWorkorder(wo.Id).setStatus(FSM_Constants.STATUS_NEW).setTerritory(st.Id).setResourceId(sr.Id)
                .setRecordTypeId(infraRecordTypeID1).setSWRTask('2').setSewerStatus('Strategic').setSewerType('Foul').setMedium('MOBI').setSiteName('SiteInfra2').returnWithoutCreate();
                allDCFInfra1.add(testrecordInfra1);
        }
        Insert allDCFInfra1;
    }
    
	/********************************************************************************************************
    @Author      : Subir Maji
    @Description : method to test populate No of line item same type and populate Grid Number 
    @description : Created as part of user story #SFI-2041
    @Date        : 01-Aug-2024
	********************************************************************************************************/
    @istest
    static void testPopulateNoOflineSameType(){
        List<FSM_InfraDataCaptureForm2__c> allInfraRec = [Select ID, FSM_Status__c, FSM_WorkOrder__c from FSM_InfraDataCaptureForm2__c];
        ID infralineitemRecordTypeId = Schema.SObjectType.FSM_InfraDataCaptureLineItem2__c.getRecordTypeInfosByDeveloperName()
            .get('FSM_Incident_at_Location').getRecordTypeId();
        
        List<FSM_InfraDataCaptureLineItem2__c> allDCFInfraline = new List<FSM_InfraDataCaptureLineItem2__c>();
        FSM_InfraDataCaptureLineItem2__c testrecordInfraLine;
        FSM_InfraDataCaptureLineItem2__c testrecordInfraLineFirstRec;
        
        test.startTest();
        for(Integer i = 0;i<4;i++){
            testrecordInfraLine = new FSM_TestDataFactory.DataCaptureFormLineItemInfra2Creator().setWorkorder(allInfraRec[0].FSM_WorkOrder__c).setRecordTypeId(infralineitemRecordTypeId)
                .setInfraParentId(allInfraRec[0].ID).returnWithoutCreate();
            if(i==0){
                Insert testrecordInfraLine;
                testrecordInfraLineFirstRec = testrecordInfraLine;
            }else{
                if(i>0 && i<3){
                    testrecordInfraLine.FSM_LineItem__c = testrecordInfraLineFirstRec.id;
                }
                allDCFInfraline.add(testrecordInfraLine);
            }
        }
        Insert allDCFInfraline;
        
        allDCFInfraline = new List<FSM_InfraDataCaptureLineItem2__c>();
        for(Integer i = 0;i<4;i++){
            testrecordInfraLine = new FSM_TestDataFactory.DataCaptureFormLineItemInfra2Creator().setWorkorder(allInfraRec[0].FSM_WorkOrder__c).setRecordTypeId(infralineitemRecordTypeId)
                .setInfraParentId(allInfraRec[0].ID).returnWithoutCreate();
            if(i==0){
                Insert testrecordInfraLine;
                testrecordInfraLineFirstRec = testrecordInfraLine;
            }else{
                if(i>0 && i<3){
                    testrecordInfraLine.FSM_LineItem__c = testrecordInfraLineFirstRec.id;
                }
                allDCFInfraline.add(testrecordInfraLine);
            }
        }
        Insert allDCFInfraline;
        
        testrecordInfraLine = allDCFInfraline[0];
        testrecordInfraLine.FSM_SIRCity__c = 'test';
        update testrecordInfraLine;
      
        test.stopTest();
        
        //Log creation record fetch
        List<FSM_InfraDataCaptureLineItem2__c> dcflineUpdated = [Select ID, FSM_NoOfLineItemsEformsOfSameType__c from FSM_InfraDataCaptureLineItem2__c];
        System.assertEquals(dcflineUpdated != null, true, 'DCF Line created');   
        System.assertEquals(dcflineUpdated[0].FSM_NoOfLineItemsEformsOfSameType__c != null, true , 'Fields populated as expected');
    }
}
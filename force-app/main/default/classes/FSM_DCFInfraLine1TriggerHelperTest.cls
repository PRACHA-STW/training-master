/********************************************************************************************************
@Author 	 : Subir Maji
@Description : This class is used to test FSM_DCFInfraLine1TriggerHelper.
@description : Created as part of user story #SFI-2041
@Main Class  : FSM_DCFInfraLine1TriggerHelper
@Date        : 01-Aug-2024
********************************************************************************************************/
@istest(SeeAllData = False)
public class FSM_DCFInfraLine1TriggerHelperTest {
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
        List<FSM_DataCaptureFormInfra__c> allDCFInfra = new List<FSM_DataCaptureFormInfra__c>();
        FSM_DataCaptureFormInfra__c testrecordInfra;
        
        //Fetching Record Type Id 
        ID infraRecordTypeID = Schema.SObjectType.FSM_DataCaptureFormInfra__c.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.FORMTYPE).getRecordTypeId();
        
        //Looping over bulk infra record creation
        for(Integer i = 0;i<numberOfRecordsToCreate;i++){
            testrecordInfra = new FSM_TestDataFactory.DataCaptureFormInfraCreator().setWorkorder(wo.Id).setStatus(FSM_Constants.STATUS_NEW).setTerritory(st.Id).setResourceId(sr.Id)
                .setRecordTypeId(infraRecordTypeID).setComment('test').setTime(18, 30, 2, 20).setGridReference('250001').setDateTime(System.today()).setMedium('MOBI').returnWithoutCreate();
                allDCFInfra.add(testrecordInfra);
        }
        Insert allDCFInfra;
    }     
     
	/********************************************************************************************************
    @Author      : Subir Maji
    @Description : method to test populate No of line item same type and populate Grid Number 
    @description : Created as part of user story #SFI-2041
    @Date        : 01-Aug-2024
	********************************************************************************************************/
    @istest
    static void testPopulateNoOflineSameType(){
        List<FSM_DataCaptureFormInfra__c> allInfraRec = [Select ID, FSM_Status__c, FSM_WorkOrder__c from FSM_DataCaptureFormInfra__c];
        ID infralineitemRecordTypeId = Schema.SObjectType.FSM_DCFLineItemInfra__c.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.FORMTYPE).getRecordTypeId();
        
        ID infralineitemGridRecordTypeId = Schema.SObjectType.FSM_DCFLineItemInfra__c.getRecordTypeInfosByDeveloperName()
            .get('FSM_GridRefForExcavation').getRecordTypeId();
        List<FSM_DCFLineItemInfra__c> allDCFInfraline = new List<FSM_DCFLineItemInfra__c>();
        FSM_DCFLineItemInfra__c testrecordInfraLine;
        FSM_DCFLineItemInfra__c testrecordInfraLineFirstRec;
        
        test.startTest();
        for(Integer i = 0;i<4;i++){
            testrecordInfraLine = new FSM_TestDataFactory.DataCaptureFormLineItemInfraCreator().setWorkorder(allInfraRec[0].FSM_WorkOrder__c).setRecordTypeId(infralineitemRecordTypeId).setUid(2992)
                .setGridRefX(250001).setJobNumber(189).setExternalId('1221').setInfraParentId(allInfraRec[0].ID).setCATSerial('1234').setGennySerial('453.01').returnWithoutCreate();
            if(i==0){
                Insert testrecordInfraLine;
                testrecordInfraLineFirstRec = testrecordInfraLine;
            }else{
                if(i>0 && i<3){
                    testrecordInfraLine.FSM_LineItem__c = testrecordInfraLineFirstRec.id;
                    testrecordInfraLine.RecordTypeId = infralineitemGridRecordTypeId;
                }
                allDCFInfraline.add(testrecordInfraLine);
            }
        }
        Insert allDCFInfraline;
        
        allDCFInfraline = new List<FSM_DCFLineItemInfra__c>();
        for(Integer i = 0;i<4;i++){
            testrecordInfraLine = new FSM_TestDataFactory.DataCaptureFormLineItemInfraCreator().setWorkorder(allInfraRec[0].FSM_WorkOrder__c).setRecordTypeId(infralineitemRecordTypeId).setUid(2992)
                .setGridRefX(250001).setJobNumber(189).setExternalId('1221').setValveSeqNum(1).setInfraParentId(allInfraRec[0].ID).setCATSerial('1234').setGennySerial('453.01').returnWithoutCreate();
            if(i==0){
                Insert testrecordInfraLine;
                testrecordInfraLineFirstRec = testrecordInfraLine;
            }else{
                if(i>0 && i<3){
                    testrecordInfraLine.FSM_LineItem__c = testrecordInfraLineFirstRec.id;
                    testrecordInfraLine.RecordTypeId = infralineitemGridRecordTypeId;
                }
                allDCFInfraline.add(testrecordInfraLine);
            }
        }
        Insert allDCFInfraline;
        
        testrecordInfraLine = allDCFInfraline[0];
        testrecordInfraLine.FSM_1stRec__c = 'test';
        update testrecordInfraLine;
      
        test.stopTest();
        
        //Log creation record fetch
        List<FSM_DCFLineItemInfra__c> dcflineUpdated = [Select ID, FSM_NoOfLineItemsEformsOfSameType__c, FSM_GridNo__c 
                                                        from FSM_DCFLineItemInfra__c
                                                       Where FSM_ValveSeqNumber__c != null];
        System.assertEquals(dcflineUpdated != null, true, 'DCF Line created');   
        System.assertEquals(dcflineUpdated[0].FSM_NoOfLineItemsEformsOfSameType__c != null, true , 'Fields populated as expected');
    }
}
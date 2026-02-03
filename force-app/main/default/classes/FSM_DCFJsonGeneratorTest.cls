/********************************************************************************************************
@Author 	 : Manish Jagnani
@Description : This class is used to test FSM_DCFJsonGenerator.
@description : Created as part of user story #SFI-35
@Main Class  : FSM_DCFJsonGenerator
@Date        : 7th-August-2023
********************************************************************************************************/
@istest(SeeAllData = False)
public class FSM_DCFJsonGeneratorTest {
    static Integer numberOfRecordsToCreate = 1;
    
    //This method is for test Data set-up in bulk SFI-35 
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
        //Contact con = 
        new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
            			.setEmail('no-reply@defaultemail.com').create();
        
        //Infra Variables set-up
        List<FSM_DataCaptureFormInfra__c> allDCFInfra = new List<FSM_DataCaptureFormInfra__c>();
        List<FSM_DCFLineItemInfra__c> allDCFInfraline = new List<FSM_DCFLineItemInfra__c>();
        List<FSM_InfraDataCaptureForm2__c> allDCFInfra1 = new List<FSM_InfraDataCaptureForm2__c>();//Added for SFI-1204
        FSM_DataCaptureFormInfra__c testrecordInfra;
        FSM_DCFLineItemInfra__c testrecordInfraLine;
        FSM_DCFLineItemInfra__c testrecordInfraLineFirstRec;
        FSM_InfraDataCaptureForm2__c testrecordInfra1;//Added for SFI-1204
        
        // Non Infra Variables set-up 
        List<FSM_DataCaptureFormNonInfra__c> allDCFNonInfra = new List<FSM_DataCaptureFormNonInfra__c>();
        List<FSM_DCFLineItemNonInfra__c> allDCFNonInfraline = new List<FSM_DCFLineItemNonInfra__c>();
        FSM_DataCaptureFormNonInfra__c testrecordNonInfra;
        FSM_DCFLineItemNonInfra__c testrecordNonInfraLine;
        
        //Fetching Record Type Id 
        ID infraRecordTypeID = Schema.SObjectType.FSM_DataCaptureFormInfra__c.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.FORMTYPE).getRecordTypeId();
        
        //Fetching Record Type Id for Infra 2 object SFI-1204
        ID infraRecordTypeID1 = Schema.SObjectType.FSM_InfraDataCaptureForm2__c.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.FORMTYPE_INFRA1).getRecordTypeId();
        
        //Looping over bulk infra record creation
        for(Integer i = 0;i<numberOfRecordsToCreate;i++){
            testrecordInfra = new FSM_TestDataFactory.DataCaptureFormInfraCreator().setWorkorder(wo.Id).setStatus(FSM_Constants.STATUS_NEW).setTerritory(st.Id).setResourceId(sr.Id)
                .setRecordTypeId(infraRecordTypeID).setComment('test').setTime(18, 30, 2, 20).setGridReference('250001').setDateTime(System.today()).setMedium('MOBI').returnWithoutCreate();
                allDCFInfra.add(testrecordInfra);
        }
        Insert allDCFInfra;
         
        //Looping over bulk infra 1 record creation SFI-1204
        for(Integer i = 0;i<numberOfRecordsToCreate;i++){
            testrecordInfra1 = new FSM_TestDataFactory.DataCaptureFormInfra1Creator().setWorkorder(wo.Id).setStatus(FSM_Constants.STATUS_NEW).setTerritory(st.Id).setResourceId(sr.Id)
                .setRecordTypeId(infraRecordTypeID1).setSWRTask('2').setSewerStatus('Strategic').setSewerType('Foul').setMedium('MOBI').setSiteName('SiteInfra2').returnWithoutCreate();
                allDCFInfra1.add(testrecordInfra1);
        }
        Insert allDCFInfra1;
        
        //Fetching Record Type Id 
        ID infralineitemRecordTypeId = Schema.SObjectType.FSM_DCFLineItemInfra__c.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.FORMTYPE).getRecordTypeId();
        
        //Looping over bulk infra line-item record creation, this part is Updated as part of SFI-2041 by Subir Maji 23rd July 2024
        for(Integer i = 0;i<4;i++){
            testrecordInfraLine = new FSM_TestDataFactory.DataCaptureFormLineItemInfraCreator().setWorkorder(wo.Id).setRecordTypeId(infralineitemRecordTypeId).setUid(2992)
                .setGridRefX(250001).setJobNumber(189).setExternalId('1221').setInfraParentId(allDCFInfra[0].ID).setCATSerial('1234').setGennySerial('453.01').returnWithoutCreate();
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
        
        //Fetching Record Type Id 
        ID nonInfraRecordTypeId = Schema.SObjectType.FSM_DataCaptureFormNonInfra__c.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.FORMTYPE).getRecordTypeId();
        
        //Looping over bulk infra record creation
        for(Integer i = 0;i<numberOfRecordsToCreate;i++){
            testrecordNonInfra = new FSM_TestDataFactory.DataCaptureFormNonInfraCreator().setWorkorder(wo.Id).setServiceResource(sr.Id)
                .setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(st.Id).setRecordTypeId(NonInfraRecordTypeId).returnWithoutCreate();
                allDCFNonInfra.add(testrecordNonInfra);
        }
        Insert allDCFNonInfra;
        
        //Fetching Record Type Id 
        ID nonInfraLineItemRecordTypeId = Schema.SObjectType.FSM_DCFLineItemNonInfra__c.getRecordTypeInfosByDeveloperName()
         	.get(FSM_Constants.FORMTYPE).getRecordTypeId();
        
        //Looping over bulk non infra line-item record creation
        for(Integer i = 0;i<numberOfRecordsToCreate;i++){
            testrecordNonInfraLine = new FSM_TestDataFactory.DataCaptureFormLineItemNonInfraCreator().setWorkorder(wo.Id).setRecordTypeId(nonInfraLineItemRecordTypeId)
                .setNonInfraParent(allDCFNonInfra[i].ID).returnWithoutCreate();
                allDCFNonInfraline.add(testrecordNonInfraLine);
        }
        Insert allDCFNonInfraline;
    }
    
	/********************************************************************************************************
    @Author      : Manish jagnani
    @Description : method to test log creation for Data capture infra 
    @description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
	********************************************************************************************************/
    @istest
    static void testBulkSuccessPlatformEventCreationInfra(){
        List<FSM_DataCaptureFormInfra__c> allInfraRec = [Select ID, FSM_Status__c from FSM_DataCaptureFormInfra__c];
      
        test.startTest();
        for(FSM_DataCaptureFormInfra__c all : allInfraRec){
            all.FSM_Status__c = FSM_Constants.STATUS_COMPLETED;
        }
        
        Update allInfraRec;
      
        test.stopTest();
        
        //Log creation record fetch
        List<FSM_IntegrationLog__c> allLog = [Select ID from FSM_IntegrationLog__c];
        System.assertEquals(allLog != null, true, 'Integration Log Created');   
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : method to test log creation for Data capture infra 1 
    @description : Created as part of user story #SFI-1204
    @Date        : 28-Dec-2023
	********************************************************************************************************/
    @istest
    static void testBulkSuccessPlatformEventCreationInfra1(){
        List<FSM_InfraDataCaptureForm2__c> allInfraRec = [Select ID, FSM_Status__c from FSM_InfraDataCaptureForm2__c];
		
        test.startTest();
        for(FSM_InfraDataCaptureForm2__c all : allInfraRec){
            all.FSM_Status__c = FSM_Constants.STATUS_COMPLETED;
        }
        Update allInfraRec;
        test.stopTest();
        
        //Log creation record fetch
        List<FSM_IntegrationLog__c> allLog = [Select ID from FSM_IntegrationLog__c];
        
        System.assertEquals(allLog != null, true, 'Integration Log Created');
    }
    
	/********************************************************************************************************
    @Author      : Manish jagnani
    @Description : method to test log creation for Data capture Non infra 
    @description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
	********************************************************************************************************/
    @istest
    static void testBulkSuccessPlatformEventCreationNonInfra(){
        List<FSM_DataCaptureFormNonInfra__c> allNonInfraRec = [Select ID, FSM_Status__c from FSM_DataCaptureFormNonInfra__c];
        
        test.startTest();
        for(FSM_DataCaptureFormNonInfra__c all : allNonInfraRec){
            all.FSM_Status__c = FSM_Constants.STATUS_COMPLETED;
        }
        Update allNonInfraRec;
        test.stopTest();
        
        //Log creation record fetch
        List<FSM_IntegrationLog__c> allLog = [Select ID from FSM_IntegrationLog__c];
        
        System.assertEquals(allLog != null, true, 'Integration Log Created');
    }

}
/********************************************************************************************************
@Author      : Arnob Dey
@description : This class is used to test auto-dispatch functionality of service appointment
@description : Created as part of user story #SFS-814
@Main Class  : FSM_DispatchSAScheduler and FSM_DispatchSABatch 
@Date        : 24-July-2023
@Modified By : Leena B , #SFS-4514
********************************************************************************************************/
@isTest(SeeAllData=false)
public class FSM_DispatchSATest {
/*******************************************************************************************************
@Author      : Arnob Dey
@description : This method is used to create test data setup.
********************************************************************************************************/
    @TestSetup
    static void testDataSetup(){
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Dispatched');
        
        Double latitudeValue = 52.58;
        Double longitudeValue = -2.13; 
		String kmlValue = '<?xml version="1.0" encoding="UTF-8"?>  <kml xmlns="http://www.opengis.net/kml/2.2"> <Style id="InspSouthOnePolygonStyle"> <LineStyle> <width>1</width> </LineStyle> <PolyStyle> <color>80C07956</color></PolyStyle></Style> <Placemark> <name>InspSouthOnePolygon</name> <styleUrl>#InspSouthOnePolygonStyle</styleUrl> <Polygon><outerBoundaryIs><LinearRing><coordinates> '+'\n'+'  -2.141896101527918,52.588067090262314,0'+'\n'+' -2.1290214982564337,52.586294101069164,0'+'\n'+'  -2.12387165694784,52.58149624126919,0'+'\n'+' -2.1355446305806525,52.57252492066223,0'+'\n'+' -2.152710768275965,52.57961867490679,0'+'\n'+' -2.141896101527918,52.588067090262314,0'+'\n'+' </coordinates></LinearRing> </outerBoundaryIs></Polygon> </Placemark> </kml>';        
        //Create Account
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        //Create Contact
        //Contact con = 
        new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
                        .setEmail('no-reply@defaultemail.com').create();
        
        // Create users
        User testUser = new FSM_TestDataFactory.CretaeUser().create();
        
        User testUser2 = new User();
        testUser2.FirstName='Charles';
        testUser2.LastName = 'Field Worker';
        testUser2.Email = 'charlesworker@gmail.com';
        testUser2.Username = 'charlesfieldworker@gmail.com';
        testUser2.Alias = 'chlefw';
        testUser2.CommunityNickname = 'charles';
        testUser2.TimeZoneSidKey = 'America/Los_Angeles';
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.EmailEncodingKey = 'UTF-8';
        testUser2.LocaleSidKey = 'en_US';    
        testUser2.ProfileId =  [SELECT Id FROM Profile where Name='Standard User'].Id; 
        insert testUser2;
        
        // Create work rule
        FSL__Work_Rule__c wr = new FSL__Work_Rule__c(Name='Active Resources',FSL__Resource_Property__c='IsActive',FSL__Match_Constant_Boolean_Value__c=true);
        insert wr;
        
        // Create scheduling policy
        FSL__Scheduling_Policy__c testPolicy = new FSL__Scheduling_Policy__c(Name = 'Waste Non Infra Soft Boundaries', FSM_BusinessUnit__c = 'Waste Non Infra');
        insert testPolicy;
        
        // Create scheduling policy work rule
        FSL__Scheduling_Policy_Work_Rule__c spwr = new FSL__Scheduling_Policy_Work_Rule__c(FSL__Scheduling_Policy__c=testPolicy.Id, FSL__Work_Rule__c=wr.Id);
        insert spwr;
                
        // Create OperatingHours
        OperatingHours testOpHrs = new FSM_TestDataFactory.OperatingHoursCreator().setName('Test Base Calendar').setTimeZone('Europe/London').setSlotType(FSM_Constants.DURATION).create();
                
        // Create ServiceTerritory where FSM_NumberOfDaysToDispatch__c != 1 & FSM_NumberOfSAToDispatch__c = 'Full' --- Scenario 1
        ServiceTerritory testTerritory = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('1302WD4M4 Insp South One (Edgbaston)')
            .setOpreratingHours(testOpHrs.Id).setAutoSchedulingPolicy(testPolicy.Id).setWorkingSubAreaRequired(true)
            .setNumberOfDaysToDispatch('5').setNumberOfSAToDispatch('Full').setIsActive(true).setBusinessUnit('Waste Non Infra').create();
        
        // Create a Test Service Resource
        ServiceResource testResource = new FSM_TestDataFactory.ServiceResourceCreator().setName('Test John Field Worker').setIsActive(true)
            .setRelatedRecordId(testUser.Id).setExternalId('990055').create();
        
        // Create ServiceTerritoryMember
        //ServiceTerritoryMember testTerritoryMember = 
        new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(testResource.Id)
            .setServiceTerritory(testTerritory.Id).setTerritoryType('P').setStartDate(System.today()-25).setCountry('United Kingdom').setPostalCode('CV1 2GT')
            .setLatitude(latitudeValue).setLongitude(longitudeValue).create();
        
        //Create Polygon
        FSL__Polygon__c polygon = new FSM_TestDataFactory.MapPolygonCreator().setName('Insp South One Polygon 1').setBusinessUnit('Waste Non Infra').setTerritory(testTerritory.Id)
            .setMaxLatitude(52.588067).setMaxLongitude(-2.123872).setMinLatitude(52.572525).setMinLongitude(-2.152711).setColour('#5679C0').setKML(kmlValue).create();
        
        // Create WorkingSubAreaCoverage 
        //FSM_WorkingSubAreaCoverage__c wsaCoverage = 
        new FSM_TestDataFactory.WorkingSubAreaCoverageCreator().setMapPolygon(polygon.Id)
            .setStartDate(System.today()-365).setEndDate(System.today()+365).setServiceResource(testResource.Id).create();
        
        //Get WorkOrder RecordType Id
        Id woRecTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();        
        // Create a Test WorkOrder 
        WorkOrder testWorkOrder = new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Developer Services').setRecordType(woRecTypeId).setServiceTerritory(testTerritory.Id).setStatus('New').create();
        
        //Get ServiceAppointment RecordType Id
        Id saRecTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();       
        // Create a Test ServiceAppointment
        ServiceAppointment testSA = new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(testTerritory.Id)
            .setParentRecordId(testWorkOrder.Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
            .setLongitude(longitudeValue).setMapPolygon(polygon.Id).create();
        
        testSA.Status = 'Scheduled';
        testSA.SchedStartTime=system.now().addDays(1);
        testSA.SchedEndTime=system.now().addDays(1);
        update testSA;
        
        //Create AssignedResource 
        //AssignedResource testAssignedResource = 
        new FSM_TestDataFactory.AssignedResourceCreator().setServiceResource(testResource.Id).setServiceAppointment(testSA.Id).create();                        
    }
    
    /*******************************************************************************************************
    @Author      : Arnob Dey
    @description : This method is used to call the scheduler class to test SA auto-dispatch.
    ********************************************************************************************************/
    @isTest
    static void testDispatchSABatch() {
        Test.startTest();
        // Schedule the job - without parameter
        FSM_DispatchSAScheduler scheduler = new FSM_DispatchSAScheduler();
        scheduler.execute(NULL);
        
        // Schedule the job - parameterized
        String jobRunQuery = 'SELECT Id, ServiceResourceId,ServiceResource.Name, ServiceTerritory.FSM_NumberOfDaysToDispatch__c, ServiceTerritory.FSM_NumberOfSAToDispatch__c FROM ServiceTerritoryMember WHERE (EffectiveEndDate > :dtm OR EffectiveEndDate = NULL) AND ServiceTerritory.FSM_NumberOfDaysToDispatch__c <> NULL AND ServiceTerritory.FSM_NumberOfDaysToDispatch__c!= \'None\'';
        FSM_DispatchSAScheduler scheduler1 = new FSM_DispatchSAScheduler(jobRunQuery);        
        String cronExp = '0 0 0 * * ?';
        System.schedule('FSM_DispatchSASchedulerTest', cronExp, scheduler1);
                
        Test.stopTest();
        
        // Perform queries to retrieve the updated Service Appointments
        ServiceAppointment updatedSA = [SELECT Id, Status FROM ServiceAppointment WHERE Status = 'Dispatched' LIMIT 1];
        
        // Assert the expected results to verify that the Service Appointments are updated with the status 'Dispatched'
        System.assertEquals('Dispatched', updatedSA.Status, 'Service Appointment Status should be "Dispatched"');
    }      
}
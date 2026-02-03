/**********************************************************************************************************
@Author      :  Subir Maji
@Description : This class is used to test FSM_GetPolygon
@Description : Created as part of user story #SFL-68
@Main Class  : FSM_GetPolygon
@Date        : 17-Nov-2024
********************************************************************************************************/
@istest(SeeAllData = False)
public class FSM_GetPolygonTest {
    //This method is for test Data set-up in bulk SFI-35 
    @TestSetup
    static void makeData(){
        List<ServiceTerritory> allterritory = new List<ServiceTerritory>();
        List<WorkOrder> allOrder = new List<WorkOrder>();
        List<FSM_PolygonStandardTextKey__c> allPolySTK = new List<FSM_PolygonStandardTextKey__c>();
        String kmlValue = '<?xml version="1.0" encoding="UTF-8"?>  <kml xmlns="http://www.opengis.net/kml/2.2"> <Style id="InspSouthOnePolygonStyle"> <LineStyle> <width>1</width> </LineStyle> <PolyStyle> <color>80C07956</color></PolyStyle></Style> <Placemark> <name>InspSouthOnePolygon</name> <styleUrl>#InspSouthOnePolygonStyle</styleUrl> <Polygon><outerBoundaryIs><LinearRing><coordinates> '+'\n'+'  -2.141896101527918,52.588067090262314,0'+'\n'+' -2.1290214982564337,52.586294101069164,0'+'\n'+'  -2.12387165694784,52.58149624126919,0'+'\n'+' -2.1355446305806525,52.57252492066223,0'+'\n'+' -2.152710768275965,52.57961867490679,0'+'\n'+' -2.141896101527918,52.588067090262314,0'+'\n'+' </coordinates></LinearRing> </outerBoundaryIs></Polygon> </Placemark> </kml>';        
        
        //Create Operating hours
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName(FSM_Constants.OH_AM_PM).setSlotType(FSM_Constants.DURATION)
            .setBusinessUnit(FSM_Constants.BUSINESS_UNIT).create();
        
        //Create Scheduling Policy
        FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName('Test Policy').create();
        
        //Create Service Territory
        allterritory.add(new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory1').setIsActive(true)
                         .setExtenalId('888999').setOpreratingHours(op.Id).setTerritoryLevel(5).setWorkingSubAreaRequired(true)
                         .setispolygonbasedonstdtxtkey(true).setSchedulingPolicy(schedulingPolicy.Id)
                         .setAutoSchedulingPolicy(schedulingPolicy.Id).returnWithoutCreate()); // With STK test positive
        allterritory.add(new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory2').setIsActive(true)
                         .setExtenalId('888998').setOpreratingHours(op.Id).setTerritoryLevel(5).setWorkingSubAreaRequired(true)
                         .setispolygonbasedonstdtxtkey(false).setSchedulingPolicy(schedulingPolicy.Id)
                         .setAutoSchedulingPolicy(schedulingPolicy.Id).returnWithoutCreate()); //Without STK test Positive
        allterritory.add(new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory3').setIsActive(true)
                         .setExtenalId('888997').setOpreratingHours(op.Id).setTerritoryLevel(5).setWorkingSubAreaRequired(true)
                         .setispolygonbasedonstdtxtkey(true).setSchedulingPolicy(schedulingPolicy.Id)
                         .setAutoSchedulingPolicy(schedulingPolicy.Id).returnWithoutCreate()); //STK Missing test
        allterritory.add(new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory4').setIsActive(true)
                         .setExtenalId('888996').setOpreratingHours(op.Id).setTerritoryLevel(5).setWorkingSubAreaRequired(true)
                         .setispolygonbasedonstdtxtkey(false).setSchedulingPolicy(schedulingPolicy.Id)
                         .setAutoSchedulingPolicy(schedulingPolicy.Id).returnWithoutCreate()); //Polygon Missing test
        
        insert allterritory;
        
        //Create TMA
        FSM_TMAPermit__c tma = new FSM_TestDataFactory.TMAPermitCreator().create();
        
        //Create Work Order
        allOrder.add(new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId1').setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(allterritory[0].Id)
                     .setBusinessUnit('Waste Infra').setOpenDate(DateTime.Now()).setSlaDate(DateTime.Now())
                     .standardTextKey('1234').setWorkTypeCode('Test').setTma(tma.ID).returnWithoutCreate());
        allOrder.add(new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId2').setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(allterritory[1].Id)
                     .setBusinessUnit('Waste Infra').setOpenDate(DateTime.Now()).setSlaDate(DateTime.Now())
                     .standardTextKey('MHHVFTS').setWorkTypeCode('Test').setTma(tma.ID).returnWithoutCreate());
        allOrder.add(new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId3').setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(allterritory[2].Id)
                     .setBusinessUnit('Waste Infra').setOpenDate(DateTime.Now()).setSlaDate(DateTime.Now())
                     .standardTextKey('MHHVFTS').setWorkTypeCode('Test').setTma(tma.ID).returnWithoutCreate());
        allOrder.add(new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId4').setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(allterritory[3].Id)
                     .setBusinessUnit('Waste Infra').setOpenDate(DateTime.Now()).setSlaDate(DateTime.Now())
                     .standardTextKey('MHHVFTS').setWorkTypeCode('Test').setTma(tma.ID).returnWithoutCreate());
        allOrder.add(new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId5').setStatus(FSM_Constants.STATUS_NEW).setServiceTerritory(allterritory[0].Id)
                     .setBusinessUnit('Waste Infra').setOpenDate(DateTime.Now()).setSlaDate(DateTime.Now())
                     .standardTextKey('1234').setWorkTypeCode('Test').setTma(tma.ID).returnWithoutCreate());
        Insert allOrder;
        
        //Create Polygon STK
        allPolySTK.add(new FSM_TestDataFactory.PolygonSTKCreator().setName('1234').setServiceTerritory(allterritory[0].id).returnWithoutCreate());
        allPolySTK.add(new FSM_TestDataFactory.PolygonSTKCreator().setName('1234').setServiceTerritory(allterritory[1].id).returnWithoutCreate());
        insert allPolySTK;
        
        //Create Polygon
        List<FSL__Polygon__c> allpolygon = new List<FSL__Polygon__c>();
        allpolygon.add(new FSM_TestDataFactory.MapPolygonCreator().setName('Insp South One Polygon 1').setBusinessUnit('Waste Infra').setTerritory(allterritory[0].Id)
            .setMaxLatitude(52.588067).setMaxLongitude(-2.123872).setMinLatitude(52.572525).setMinLongitude(-2.152711).setColour('#5679C0').setKML(kmlValue).returnWithoutCreate());   
        allpolygon.add(new FSM_TestDataFactory.MapPolygonCreator().setName('Insp South One Polygon 3').setBusinessUnit('Waste Infra').setTerritory(allterritory[1].Id)
            .setMaxLatitude(52.588067).setMaxLongitude(-2.123872).setMinLatitude(52.572525).setMinLongitude(-2.152711).setColour('#5679C0').setKML(kmlValue).returnWithoutCreate()); 
        allpolygon.add(new FSM_TestDataFactory.MapPolygonCreator().setName('Insp South One Polygon 2').setBusinessUnit('Waste Infra').setTerritory(allterritory[1].Id)
            .setMaxLatitude(52.588067).setMaxLongitude(-2.123872).setMinLatitude(52.572525).setMinLongitude(-2.152711).setColour('#5679C0').setKML(kmlValue).returnWithoutCreate());
        Insert allpolygon;
        
        //Service Appointment creation
        Id saRecTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        Double latitudeValue = 52.58;
        Double longitudeValue = -2.13;
        ServiceAppointment sa = new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allOrder[4].ServiceTerritoryId)
            .setParentRecordId(allOrder[4].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
            .setLongitude(longitudeValue).setArrivialStart(System.today()-1).setArrivialEnd(System.today()).Create();
        
        sa.FSM_Polygon__c = allpolygon[1].Id;
        Update sa;
    }
    
    /**********************************************************************************************************
    @Author      :  Subir Maji
    @Description : This Method will test a combination of success and failure secnario
    @Description : Created as part of user story #SFL-68
    @Date        : 17-Nov-2024
    ********************************************************************************************************/
    @istest
    static void testPolygonUpdateSuccessAndFail(){
        List<WorkOrder> allWo = [Select ID, ServiceTerritoryId from WorkOrder];
        //Get ServiceAppointment RecordType Id
        Id saRecTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        Double latitudeValue = 52.58;
        Double longitudeValue = -2.13;
        List<ServiceAppointment> allSA = new List<ServiceAppointment>();
        
        test.startTest();
        // Create a Test ServiceAppointment
        allSA.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allWo[0].ServiceTerritoryId)
                  .setParentRecordId(allWo[0].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                  .setLongitude(longitudeValue).returnWithoutCreate());
        allSA.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allWo[1].ServiceTerritoryId)
                  .setParentRecordId(allWo[1].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                  .setLongitude(longitudeValue).returnWithoutCreate());
        allSA.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allWo[2].ServiceTerritoryId)
                  .setParentRecordId(allWo[2].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                  .setLongitude(longitudeValue).returnWithoutCreate());
        allSA.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allWo[3].ServiceTerritoryId)
                  .setParentRecordId(allWo[3].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                  .setLongitude(longitudeValue).returnWithoutCreate());
        
        insert allSA;
        test.stopTest();
        
        //Log creation record fetch
        List<ServiceAppointment> allUpdatedSA = [Select ID, FSM_Polygon__c from ServiceAppointment Where ParentRecordId In : allWo];
        System.assertEquals(allUpdatedSA[0].FSM_Polygon__c != null, true, 'Polygon Populated');   
        System.assertEquals(allUpdatedSA[1].FSM_Polygon__c != null, true, 'Polygon Populated');   
    }
    
    /**********************************************************************************************************
    @Author      :  Subir Maji
    @Description : This Method will test succes secnario
    @Description : Created as part of user story #SFL-68
    @Date        : 17-Nov-2024
    ********************************************************************************************************/
    @istest
    static void testPolygonUpdateSuccess(){
        List<WorkOrder> allWo = [Select ID, ServiceTerritoryId from WorkOrder where FSM_ExternalId__c  = 'testId1' OR FSM_ExternalId__c  = 'testId2'];
        //Get ServiceAppointment RecordType Id
        Id saRecTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        Double latitudeValue = 52.58;
        Double longitudeValue = -2.13;
        List<ServiceAppointment> allSA = new List<ServiceAppointment>();
        ServiceAppointment sa;
        
        test.startTest();
        // Create a Test ServiceAppointment
        allSA.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allWo[0].ServiceTerritoryId)
                  .setParentRecordId(allWo[0].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                  .setLongitude(longitudeValue).setArrivialStart(System.today()-1).setArrivialEnd(System.today()).returnWithoutCreate());
        allSA.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allWo[1].ServiceTerritoryId)
                  .setParentRecordId(allWo[1].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                  .setLongitude(longitudeValue).returnWithoutCreate());
        
        Insert allSA;
        test.stopTest();
        
        //Log creation record fetch
        List<ServiceAppointment> allUpdatedSA = [Select ID, FSM_Polygon__c from ServiceAppointment Where ParentRecordId In : allWo];
        System.assertEquals(allUpdatedSA[0].FSM_Polygon__c != null, true, 'Polygon Populated');   
        System.assertEquals(allUpdatedSA[1].FSM_Polygon__c != null, true, 'Polygon Populated');   
    }
    
    /**********************************************************************************************************
    @Author      :  Subir Maji
    @Description : This Method will test failure secnario
    @Description : Created as part of user story #SFL-68
    @Date        : 17-Nov-2024
    ********************************************************************************************************/
    @istest
    static void testPolygonUpdateFailure(){
        List<WorkOrder> allWo = [Select ID, ServiceTerritoryId from WorkOrder where FSM_ExternalId__c  = 'testId3' OR FSM_ExternalId__c  = 'testId4'];
        //Get ServiceAppointment RecordType Id
        Id saRecTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        Double latitudeValue = 52.58;
        Double longitudeValue = -2.13;
        List<ServiceAppointment> allSA = new List<ServiceAppointment>();
        
        test.startTest();
        // Create a Test ServiceAppointment
        allSA.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allWo[0].ServiceTerritoryId)
                  .setParentRecordId(allWo[0].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                  .setLongitude(longitudeValue).returnWithoutCreate());
        allSA.add(new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId).setServiceTerritory(allWo[1].ServiceTerritoryId)
                  .setParentRecordId(allWo[1].Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                  .setLongitude(longitudeValue).returnWithoutCreate());
        
        insert allSA;
        test.stopTest();
        
        //Log creation record fetch
        List<ServiceAppointment> allUpdatedSA = [Select ID, FSM_Polygon__c from ServiceAppointment Where ParentRecordId In : allWo];
        System.assertEquals(allUpdatedSA[0].FSM_Polygon__c != null, false, 'Polygon Not Populated');   
        System.assertEquals(allUpdatedSA[1].FSM_Polygon__c != null, false, 'Polygon Not Populated'); 
        List<FSM_ErrorLog__c> allLog = [Select ID from FSM_ErrorLog__c];
        System.assertEquals(allLog[0].ID != null, true, 'Error Log Created'); 
        System.assertEquals(allLog[1].ID != null, true, 'Error Log Created'); 
    }
    
    /**********************************************************************************************************
    @Author      :  Subir Maji
    @Description : This Method will test succes secnario
    @Description : Created as part of user story #SFL-68
    @Date        : 17-Nov-2024
    ********************************************************************************************************/
    @istest
    static void testPolygonUpdateExistRecSuccess(){
        List<ServiceAppointment> allSA = [Select ID from ServiceAppointment];
        ServiceAppointment sa;
        
        test.startTest();
        // Create a Test ServiceAppointment
        allSA[0].FSM_Polygon__c = null;
        Update allSA;
        test.stopTest();
        
        //Log creation record fetch
        List<ServiceAppointment> allUpdatedSA = [Select ID, FSM_Polygon__c from ServiceAppointment];
        System.assertEquals(allUpdatedSA[0].FSM_Polygon__c != null, true, 'Polygon Populated');   
    }
}
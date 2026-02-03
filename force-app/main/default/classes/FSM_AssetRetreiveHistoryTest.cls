/********************************************************************************************************
@Author      : Srikanth Palla
@Description : This class is created to cover FSM_AssetRetreiveHistory
@description  Created as part of user story #SFI-2161
@Date        : 24-June-2024
********************************************************************************************************/
@isTest
public class FSM_AssetRetreiveHistoryTest {
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description This method is used to create test data setup.
    *********************************************************************************************************/
    @testsetup
    static void testSetup(){
        // Creating a new WorkOrder for testing purposes
        WorkOrder newWorkOrder = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus('New').setBusinessUnit('Waste Infra').create();
        // Defining dates for the ServiceAppointment
        DateTime earliestDate = datetime.newInstance(2023, 11, 15, 12, 30, 0);
        DateTime dueDate = datetime.newInstance(2023, 11, 15, 13, 30, 0);
        // Fetching RecordTypeId for ServiceAppointment
        id recordTypeId=Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_WASTEINFRA).getRecordTypeId();
        // Creating a new ServiceAppointment and associating it with the previously created WorkOrder
        ServiceAppointment newServiceAppointment= new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(recordTypeId).setParentRecordId(newWorkOrder.id).setStatus('New').setEarliestStartTime(earliestDate).setDueDate(dueDate).create();
        
    }
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This test method to fetch workorder from SA.
    ******************************************************************************************************/
    @isTest
    static void testGetWorkOrderRecord() {
        workOrder wo=[Select id from WorkOrder limit 1];
        ServiceAppointment sa = [Select id from ServiceAppointment limit 1];
        
        Test.startTest();
        WorkOrder result = FSM_AssetRetreiveHistory.getWorkOrderRecord(sa.Id);
        Test.stopTest();
        
        // Assert results
        System.assertEquals(wo.Id, result.Id);
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This test method verifies interface toggle is active.
    ******************************************************************************************************/
    @isTest
    static void testCheckToggle() {
        Test.startTest();
        Boolean toggle = FSM_AssetRetreiveHistory.checkToggle();
        Test.stopTest();
        System.assertEquals(true, toggle); 
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This test method verifies the successful Level4 call using HttpCalloutMock class.
    ******************************************************************************************************/
    @isTest
    static void testLevel4Callout() {
        Test.startTest();
        // Set mock callout class
        String mockResponse = '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/StreamCollection</id>' +
            '<title type="text">StreamCollection</title>' +
            '<updated>2024-06-19T06:56:28Z</updated>' +
            '<author><name/></author>' +
            '<link href="StreamCollection" rel="self" title="StreamCollection"/>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/StreamCollection(\'13168-WP1-TWP1-0002\')</id>' +
            '<title type="text">StreamCollection(\'13168-WP1-TWP1-0002\')</title>' +
            '<updated>2024-06-19T06:56:28Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.Stream" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0002\')" rel="self" title="Stream"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0002\')/Nav_Unit" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Unit" type="application/atom+xml;type=feed" title="Nav_Unit"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0002\')/Nav_StreamCharacteristics" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_StreamCharacteristics" type="application/atom+xml;type=feed" title="Nav_StreamCharacteristics"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:StageId>13168-WP1-TWP1</d:StageId>' +
            '<d:StreamId>13168-WP1-TWP1-0002</d:StreamId>' +
            '<d:StreamDesc>PUMPING STREAM-MAIN PUMP HOUSE</d:StreamDesc>' +
            '<d:StreamAssetType/>' +
            '<d:StreamLocationId/>' +
            '<d:StreamLocationDesc/>' +
            '<d:StreamAssetClass/>' +
            '<d:StreamAssetClassDesc/>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/StreamCollection(\'13168-WP1-TWP1-0007\')</id>' +
            '<title type="text">StreamCollection(\'13168-WP1-TWP1-0007\')</title>' +
            '<updated>2024-06-19T06:56:28Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.Stream" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0007\')" rel="self" title="Stream"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0007\')/Nav_Unit" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Unit" type="application/atom+xml;type=feed" title="Nav_Unit"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0007\')/Nav_StreamCharacteristics" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_StreamCharacteristics" type="application/atom+xml;type=feed" title="Nav_StreamCharacteristics"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:StageId>13168-WP1-TWP1</d:StageId>' +
            '<d:StreamId>13168-WP1-TWP1-0007</d:StreamId>' +
            '<d:StreamDesc>PUMPING STREAM-NORTHFIELD 2</d:StreamDesc>' +
            '<d:StreamAssetType/>' +
            '<d:StreamLocationId/>' +
            '<d:StreamLocationDesc/>' +
            '<d:StreamAssetClass/>' +
            '<d:StreamAssetClassDesc/>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/StreamCollection(\'13168-WP2-TWP1-0002\')</id>' +
            '<title type="text">StreamCollection(\'13168-WP2-TWP1-0002\')</title>' +
            '<updated>2024-06-19T06:56:28Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.Stream" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="StreamCollection(\'13168-WP2-TWP1-0002\')" rel="self" title="Stream"/>' +
            '<link href="StreamCollection(\'13168-WP2-TWP1-0002\')/Nav_Unit" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Unit" type="application/atom+xml;type=feed" title="Nav_Unit"/>' +
            '<link href="StreamCollection(\'13168-WP2-TWP1-0002\')/Nav_StreamCharacteristics" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_StreamCharacteristics" type="application/atom+xml;type=feed" title="Nav_StreamCharacteristics"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:StageId>13168-WP2-TWP1</d:StageId>' +
            '<d:StreamId>13168-WP2-TWP1-0002</d:StreamId>' +
            '<d:StreamDesc>PUMPING STREAM TO NORTON</d:StreamDesc>' +
            '<d:StreamAssetType/>' +
            '<d:StreamLocationId/>' +
            '<d:StreamLocationDesc/>' +
            '<d:StreamAssetClass/>' +
            '<d:StreamAssetClassDesc/>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '</feed>';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(FSM_Constants.RESPONSE_200, 'OK', mockResponse));
        // Test.setMock(HttpCalloutMock.class, new AssetHistoryLevel4MockCallout());
        // Test the makeCallout method
        List<FSM_AssetRetreiveHistory.FlocInputs> result = FSM_AssetRetreiveHistory.level4Callout('FlocValue', 'Description');
        Test.stopTest();
        FSM_IntegrationLog__c log = new FSM_IntegrationLog__c();
        log = [Select ID from FSM_IntegrationLog__c Limit 1];
        // Assert results
        System.assertNotEquals(null, result);
        System.assertEquals(3, result.size());
        System.Assert(log != null, 'Integration Log created');  
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This test method verifies the successful Level6 call using HttpCalloutMock class.
    ******************************************************************************************************/
    @isTest
    static void testLevel6Callout() {
        String mockResponse = '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/SubUnitCollection</id>' +
            '<title type="text">SubUnitCollection</title>' +
            '<updated>2024-06-20T11:40:06Z</updated>' +
            '<author><name/></author>' +
            '<link href="SubUnitCollection" rel="self" title="SubUnitCollection"/>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0001\')</id>' +
            '<title type="text">SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0001\')</title>' +
            '<updated>2024-06-20T11:40:06Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.SubUnit" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0001\')" rel="self" title="SubUnit"/>' +
            '<link href="SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0001\')/Nav_Equipment" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Equipment" type="application/atom+xml;type=entry" title="Nav_Equipment"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:UnitId>13168-WP1-TWP1-0002-0006</d:UnitId>' +
            '<d:SubUnitId>13168-WP1-TWP1-0002-0006-M0001</d:SubUnitId>' +
            '<d:SubUnitDesc>VALVE-MIXING AND PUMP SUCTION TANK-F7</d:SubUnitDesc>' +
            '<d:SubUnitType></d:SubUnitType>' +
            '<d:SubUnitLocationId></d:SubUnitLocationId>' +
            '<d:SubUnitLocationDesc></d:SubUnitLocationDesc>' +
            '<d:SubUnitAssetClass></d:SubUnitAssetClass>' +
            '<d:SubUnitAssetClassDesc></d:SubUnitAssetClassDesc>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0002\')</id>' +
            '<title type="text">SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0002\')</title>' +
            '<updated>2024-06-20T11:40:06Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.SubUnit" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0002\')" rel="self" title="SubUnit"/>' +
            '<link href="SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0002\')/Nav_Equipment" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Equipment" type="application/atom+xml;type=entry" title="Nav_Equipment"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:UnitId>13168-WP1-TWP1-0002-0006</d:UnitId>' +
            '<d:SubUnitId>13168-WP1-TWP1-0002-0006-M0002</d:SubUnitId>' +
            '<d:SubUnitDesc>VALVE-MIXING AND PUMP SUCTION TANK-F6</d:SubUnitDesc>' +
            '<d:SubUnitType></d:SubUnitType>' +
            '<d:SubUnitLocationId></d:SubUnitLocationId>' +
            '<d:SubUnitLocationDesc></d:SubUnitLocationDesc>' +
            '<d:SubUnitAssetClass></d:SubUnitAssetClass>' +
            '<d:SubUnitAssetClassDesc></d:SubUnitAssetClassDesc>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '</feed>';
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new AssetHistoryLevel6MockCallout());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', mockResponse));
        List<FSM_AssetRetreiveHistory.FlocLevelSix> result = FSM_AssetRetreiveHistory.level6Callout('FlocValue', 'SubUnitDesc');
        Test.stopTest();
        FSM_IntegrationLog__c log = new FSM_IntegrationLog__c();
        log = [Select ID from FSM_IntegrationLog__c Limit 1];
        // Assert results
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.size());
        System.Assert(log != null, 'Integration Log created'); 
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This test method verifies the failure scenario for Level4 using HttpCalloutMock class.
    ******************************************************************************************************/
    @isTest
    static void testAssetHistoryLevel4CalloutFailure() {
        Test.startTest();
        // Set mock callout class
        String mockResponse = '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/StreamCollection</id>' +
            '<title type="text">StreamCollection</title>' +
            '<updated>2024-06-19T06:56:28Z</updated>' +
            '<author><name/></author>' +
            '<link href="StreamCollection" rel="self" title="StreamCollection"/>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/StreamCollection(\'13168-WP1-TWP1-0002\')</id>' +
            '<title type="text">StreamCollection(\'13168-WP1-TWP1-0002\')</title>' +
            '<updated>2024-06-19T06:56:28Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.Stream" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0002\')" rel="self" title="Stream"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0002\')/Nav_Unit" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Unit" type="application/atom+xml;type=feed" title="Nav_Unit"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0002\')/Nav_StreamCharacteristics" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_StreamCharacteristics" type="application/atom+xml;type=feed" title="Nav_StreamCharacteristics"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:StageId>13168-WP1-TWP1</d:StageId>' +
            '<d:StreamId>13168-WP1-TWP1-0002</d:StreamId>' +
            '<d:StreamDesc>PUMPING STREAM-MAIN PUMP HOUSE</d:StreamDesc>' +
            '<d:StreamAssetType/>' +
            '<d:StreamLocationId/>' +
            '<d:StreamLocationDesc/>' +
            '<d:StreamAssetClass/>' +
            '<d:StreamAssetClassDesc/>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/StreamCollection(\'13168-WP1-TWP1-0007\')</id>' +
            '<title type="text">StreamCollection(\'13168-WP1-TWP1-0007\')</title>' +
            '<updated>2024-06-19T06:56:28Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.Stream" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0007\')" rel="self" title="Stream"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0007\')/Nav_Unit" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Unit" type="application/atom+xml;type=feed" title="Nav_Unit"/>' +
            '<link href="StreamCollection(\'13168-WP1-TWP1-0007\')/Nav_StreamCharacteristics" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_StreamCharacteristics" type="application/atom+xml;type=feed" title="Nav_StreamCharacteristics"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:StageId>13168-WP1-TWP1</d:StageId>' +
            '<d:StreamId>13168-WP1-TWP1-0007</d:StreamId>' +
            '<d:StreamDesc>PUMPING STREAM-NORTHFIELD 2</d:StreamDesc>' +
            '<d:StreamAssetType/>' +
            '<d:StreamLocationId/>' +
            '<d:StreamLocationDesc/>' +
            '<d:StreamAssetClass/>' +
            '<d:StreamAssetClassDesc/>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/StreamCollection(\'13168-WP2-TWP1-0002\')</id>' +
            '<title type="text">StreamCollection(\'13168-WP2-TWP1-0002\')</title>' +
            '<updated>2024-06-19T06:56:28Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.Stream" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="StreamCollection(\'13168-WP2-TWP1-0002\')" rel="self" title="Stream"/>' +
            '<link href="StreamCollection(\'13168-WP2-TWP1-0002\')/Nav_Unit" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Unit" type="application/atom+xml;type=feed" title="Nav_Unit"/>' +
            '<link href="StreamCollection(\'13168-WP2-TWP1-0002\')/Nav_StreamCharacteristics" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_StreamCharacteristics" type="application/atom+xml;type=feed" title="Nav_StreamCharacteristics"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:StageId>13168-WP2-TWP1</d:StageId>' +
            '<d:StreamId>13168-WP2-TWP1-0002</d:StreamId>' +
            '<d:StreamDesc>PUMPING STREAM TO NORTON</d:StreamDesc>' +
            '<d:StreamAssetType/>' +
            '<d:StreamLocationId/>' +
            '<d:StreamLocationDesc/>' +
            '<d:StreamAssetClass/>' +
            '<d:StreamAssetClassDesc/>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '</feed>';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(FSM_Constants.RESPONSE_400, 'ERROR', mockResponse));
        List<FSM_AssetRetreiveHistory.FlocInputs> result = FSM_AssetRetreiveHistory.level4Callout('FlocValue', 'Description');        
        Test.stopTest();
        FSM_ErrorLog__c errLog = [Select id from FSM_ErrorLog__c Limit 1];
        System.Assert(errLog != null, 'Error log created');
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This test method verifies the failure scenario for Level6 using HttpCalloutMock class.
    ******************************************************************************************************/
    @isTest
    static void testAssetHistoryLevel6CalloutFailure() {
        Test.startTest();
        // Set mock callout class
        String mockResponse = '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/SubUnitCollection</id>' +
            '<title type="text">SubUnitCollection</title>' +
            '<updated>2024-06-20T11:40:06Z</updated>' +
            '<author><name/></author>' +
            '<link href="SubUnitCollection" rel="self" title="SubUnitCollection"/>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0001\')</id>' +
            '<title type="text">SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0001\')</title>' +
            '<updated>2024-06-20T11:40:06Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.SubUnit" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0001\')" rel="self" title="SubUnit"/>' +
            '<link href="SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0001\')/Nav_Equipment" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Equipment" type="application/atom+xml;type=entry" title="Nav_Equipment"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:UnitId>13168-WP1-TWP1-0002-0006</d:UnitId>' +
            '<d:SubUnitId>13168-WP1-TWP1-0002-0006-M0001</d:SubUnitId>' +
            '<d:SubUnitDesc>VALVE-MIXING AND PUMP SUCTION TANK-F7</d:SubUnitDesc>' +
            '<d:SubUnitType></d:SubUnitType>' +
            '<d:SubUnitLocationId></d:SubUnitLocationId>' +
            '<d:SubUnitLocationDesc></d:SubUnitLocationDesc>' +
            '<d:SubUnitAssetClass></d:SubUnitAssetClass>' +
            '<d:SubUnitAssetClassDesc></d:SubUnitAssetClassDesc>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '<entry>' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_OP_RISK_MGMT/SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0002\')</id>' +
            '<title type="text">SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0002\')</title>' +
            '<updated>2024-06-20T11:40:06Z</updated>' +
            '<category term="ZWFM_OP_RISK_MGMT.SubUnit" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0002\')" rel="self" title="SubUnit"/>' +
            '<link href="SubUnitCollection(\'13168-WP1-TWP1-0002-0006-M0002\')/Nav_Equipment" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Nav_Equipment" type="application/atom+xml;type=entry" title="Nav_Equipment"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:UnitId>13168-WP1-TWP1-0002-0006</d:UnitId>' +
            '<d:SubUnitId>13168-WP1-TWP1-0002-0006-M0002</d:SubUnitId>' +
            '<d:SubUnitDesc>VALVE-MIXING AND PUMP SUCTION TANK-F6</d:SubUnitDesc>' +
            '<d:SubUnitType></d:SubUnitType>' +
            '<d:SubUnitLocationId></d:SubUnitLocationId>' +
            '<d:SubUnitLocationDesc></d:SubUnitLocationDesc>' +
            '<d:SubUnitAssetClass></d:SubUnitAssetClass>' +
            '<d:SubUnitAssetClassDesc></d:SubUnitAssetClassDesc>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '</feed>';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(FSM_Constants.RESPONSE_400, 'ERROR', mockResponse));
        List<FSM_AssetRetreiveHistory.FlocLevelSix> result = FSM_AssetRetreiveHistory.level6Callout('FlocValue', 'Description');        
        Test.stopTest();
        FSM_ErrorLog__c errLog = [Select id from FSM_ErrorLog__c Limit 1];
        System.Assert(errLog != null, 'Error log created');
    }
    
    /******************************************************************************************************
    @Author       : Srikanth Palla
    @description   This HttpCalloutMock class to build Mockresponses.
    ******************************************************************************************************/
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String statusReason;
        private String body;
        
        MockHttpResponseGenerator(Integer statusCode, String statusReason, String body) {
            this.statusCode = statusCode;
            this.statusReason = statusReason;
            this.body = body;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setStatus(statusReason);
            res.setBody(body);
            return res;
        }
    }
}
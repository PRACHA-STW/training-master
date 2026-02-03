/********************************************************************************************************
@Author      : Srikanth Palla
@Description : This class is created to cover FSM_AssetRetreiveHistory
@description  Created as part of user story #SFI-1886
@Date        : 03-July-2024
********************************************************************************************************/
@isTest
public class FSM_JobHistoryRetrieveTest {
    
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
@description   This test method verifies interface toggle is active.
******************************************************************************************************/
    @isTest
    static void testCheckToggle() {
        Test.startTest();
        FSM_InterfaceToggle__mdt toggle = FSM_JobHistoryRetrieve.checkToggle();
        Test.stopTest();
        System.assertEquals(true, toggle.Active__c); 
    }
    
    
    /******************************************************************************************************
@Author       : Srikanth Palla
@description   This test method verifies the successful WorkOrderReport call using HttpCalloutMock class.
******************************************************************************************************/
    @isTest
    static void testWorkOrderReport() {
        String mockResponse = '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/WorkOrderReportSet</id>' +
            '<title type="text">WorkOrderReportSet</title>' +
            '<updated>2024-06-26T11:44:58Z</updated>' +
            '<author>' +
            '<name/>' +
            '</author>' +
            '<link href="WorkOrderReportSet" rel="self" title="WorkOrderReportSet"/>' +
            '<m:count>2</m:count>' +
            '<entry m:etag="W/&quot;datetimeoffset\'2024-06-18T08%3A26%3A51Z\'&quot;">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/WorkOrderReportSet(WorkOrderId=\'11756146\',OperationNumber=\'0010\')</id>' +
            '<title type="text">WorkOrderReportSet(WorkOrderId=\'11756146\',OperationNumber=\'0010\')</title>' +
            '<updated>2024-06-26T11:44:58Z</updated>' +
            '<category term="ZWFM_CUSTOMER_MGMT_SRV.WorkOrderReport" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="WorkOrderReportSet(WorkOrderId=\'11756146\',OperationNumber=\'0010\')" rel="self" title="WorkOrderReport"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:ModifiedOn>2024-06-18T08:26:51Z</d:ModifiedOn>' +
            '<d:WorkOrderId>11756146</d:WorkOrderId>' +
            '<d:ServiceNotificationId>12365980</d:ServiceNotificationId>' +
            '<d:FormattedAddress>GONALSTON LANE, EPPERSTONE, NG14 6AZ</d:FormattedAddress>' +
            '<d:CreatedOn>2024-05-01T14:49:50Z</d:CreatedOn>' +
            '<d:CodeText>S81 Dangerous Cover</d:CodeText>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '<entry m:etag="W/&quot;datetimeoffset\'2024-06-18T08%3A26%3A09Z\'&quot;">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/WorkOrderReportSet(WorkOrderId=\'11756145\',OperationNumber=\'0010\')</id>' +
            '<title type="text">WorkOrderReportSet(WorkOrderId=\'11756145\',OperationNumber=\'0010\')</title>' +
            '<updated>2024-06-26T11:44:58Z</updated>' +
            '<category term="ZWFM_CUSTOMER_MGMT_SRV.WorkOrderReport" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="WorkOrderReportSet(WorkOrderId=\'11756145\',OperationNumber=\'0010\')" rel="self" title="WorkOrderReport"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:ModifiedOn>2024-06-18T08:26:09Z</d:ModifiedOn>' +
            '<d:WorkOrderId>11756145</d:WorkOrderId>' +
            '<d:ServiceNotificationId>12365979</d:ServiceNotificationId>' +
            '<d:FormattedAddress>GONALSTON LANE, EPPERSTONE, NG14 6AZ</d:FormattedAddress>' +
            '<d:CreatedOn>2024-05-01T14:46:21Z</d:CreatedOn>' +
            '<d:CodeText>S81 Dangerous Cover</d:CodeText>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '</feed>';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', mockResponse));
        List<FSM_JobHistoryRetrieve.WorkOrderInfo> result = FSM_JobHistoryRetrieve.getWorkOrderReport('postCode','dma','drainageArea','floc','orderType');
        Test.stopTest();
        FSM_IntegrationLog__c log = new FSM_IntegrationLog__c();
        log = [Select ID from FSM_IntegrationLog__c Limit 1];
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.size());
        System.Assert(log != null, 'Integration Log created'); 
    }
    
    /******************************************************************************************************
@Author       : Srikanth Palla
@description   This test method verifies the failure scenario WorkOrderReport call using HttpCalloutMock class.
******************************************************************************************************/
    @isTest
    static void testWorkOrderReportFailure() {
        String mockResponse = '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/WorkOrderReportSet</id>' +
            '<title type="text">WorkOrderReportSet</title>' +
            '<updated>2024-06-26T11:44:58Z</updated>' +
            '<author>' +
            '<name/>' +
            '</author>' +
            '<link href="WorkOrderReportSet" rel="self" title="WorkOrderReportSet"/>' +
            '<m:count>2</m:count>' +
            '<entry m:etag="W/&quot;datetimeoffset\'2024-06-18T08%3A26%3A51Z\'&quot;">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/WorkOrderReportSet(WorkOrderId=\'11756146\',OperationNumber=\'0010\')</id>' +
            '<title type="text">WorkOrderReportSet(WorkOrderId=\'11756146\',OperationNumber=\'0010\')</title>' +
            '<updated>2024-06-26T11:44:58Z</updated>' +
            '<category term="ZWFM_CUSTOMER_MGMT_SRV.WorkOrderReport" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="WorkOrderReportSet(WorkOrderId=\'11756146\',OperationNumber=\'0010\')" rel="self" title="WorkOrderReport"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:ModifiedOn>2024-06-18T08:26:51Z</d:ModifiedOn>' +
            '<d:WorkOrderId>11756146</d:WorkOrderId>' +
            '<d:ServiceNotificationId>12365980</d:ServiceNotificationId>' +
            '<d:FormattedAddress>GONALSTON LANE, EPPERSTONE, NG14 6AZ</d:FormattedAddress>' +
            '<d:CreatedOn>2024-05-01T14:49:50Z</d:CreatedOn>' +
            '<d:CodeText>S81 Dangerous Cover</d:CodeText>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '<entry m:etag="W/&quot;datetimeoffset\'2024-06-18T08%3A26%3A09Z\'&quot;">' +
            '<id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/WorkOrderReportSet(WorkOrderId=\'11756145\',OperationNumber=\'0010\')</id>' +
            '<title type="text">WorkOrderReportSet(WorkOrderId=\'11756145\',OperationNumber=\'0010\')</title>' +
            '<updated>2024-06-26T11:44:58Z</updated>' +
            '<category term="ZWFM_CUSTOMER_MGMT_SRV.WorkOrderReport" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>' +
            '<link href="WorkOrderReportSet(WorkOrderId=\'11756145\',OperationNumber=\'0010\')" rel="self" title="WorkOrderReport"/>' +
            '<content type="application/xml">' +
            '<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">' +
            '<d:ModifiedOn>2024-06-18T08:26:09Z</d:ModifiedOn>' +
            '<d:WorkOrderId>11756145</d:WorkOrderId>' +
            '<d:ServiceNotificationId>12365979</d:ServiceNotificationId>' +
            '<d:FormattedAddress>GONALSTON LANE, EPPERSTONE, NG14 6AZ</d:FormattedAddress>' +
            '<d:CreatedOn>2024-05-01T14:46:21Z</d:CreatedOn>' +
            '<d:CodeText>S81 Dangerous Cover</d:CodeText>' +
            '</m:properties>' +
            '</content>' +
            '</entry>' +
            '</feed>';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(FSM_Constants.RESPONSE_400, 'ERROR', mockResponse));
        List<FSM_JobHistoryRetrieve.WorkOrderInfo> result = FSM_JobHistoryRetrieve.getWorkOrderReport('postCode','dma','drainageArea','floc','orderType');
        Test.stopTest();
        FSM_ErrorLog__c errLog = [Select id from FSM_ErrorLog__c Limit 1];
        System.Assert(errLog != null, 'Error log created');
    }
    
    /******************************************************************************************************
@Author       : Srikanth Palla
@description   This test method verifies the successful LognTextNotification call using HttpCalloutMock class.
******************************************************************************************************/
    @isTest
    static void testLognTextNotification() {
        String mockResponse = '<?xml version="1.0" encoding="utf-8"?>\n' +
            '<entry m:etag="W/&quot;datetimeoffset\'2024-06-25T09%3A46%3A04Z\'&quot;" xml:base="https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/" xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">\n' +
            '   <id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/ServiceNotificationSet(\'95723921\')</id>\n' +
            '   <title type="text">ServiceNotificationSet(\'95723921\')</title>\n' +
            '   <updated>2024-06-26T12:44:59Z</updated>\n' +
            '   <category term="ZWFM_CUSTOMER_MGMT_SRV.ServiceNotification" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')" rel="self" title="ServiceNotification"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/WorkOrder" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/WorkOrder" type="application/atom+xml;type=entry" title="WorkOrder"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ContactPerson" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ContactPerson" type="application/atom+xml;type=entry" title="ContactPerson"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/Attachment" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Attachment" type="application/atom+xml;type=feed" title="Attachment"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ChangeHistory" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ChangeHistory" type="application/atom+xml;type=feed" title="ChangeHistory"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/StatusAssignmentActive" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/StatusAssignmentActive" type="application/atom+xml;type=feed" title="StatusAssignmentActive"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ServiceNotificationTask" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ServiceNotificationTask" type="application/atom+xml;type=feed" title="ServiceNotificationTask"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ServiceNotificationActivity" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ServiceNotificationActivity" type="application/atom+xml;type=feed" title="ServiceNotificationActivity"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ActionBox" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ActionBox" type="application/atom+xml;type=feed" title="ActionBox"/>\n' +
            '   <content type="application/xml">\n' +
            '       <m:properties>\n' +
            '           <d:Address m:type="ZWFM_CUSTOMER_MGMT_SRV.Address">\n' +
            '               <d:HouseNo/>\n' +
            '               <d:Street>GONALSTON LANE</d:Street>\n' +
            '               <d:FlatOrg/>\n' +
            '               <d:HouseName/>\n' +
            '               <d:SubStreet/>\n' +
            '               <d:SubTown/>\n' +
            '               <d:City>EPPERSTONE</d:City>\n' +
            '               <d:Postcode>NG14 6AZ</d:Postcode>\n' +
            '           </d:Address>\n' +
            '           <d:ServiceNotificationId>95723921</d:ServiceNotificationId>\n' +
            '           <d:MainPlant>W001</d:MainPlant>\n' +
            '           <d:HeaderNotification>true</d:HeaderNotification>\n' +
            '           <d:CatalogProfile>ZNT0000Z1</d:CatalogProfile>\n' +
            '           <d:ChangedBy>TRAINMOB01</d:ChangedBy>\n' +
            '           <d:ChangedOn>2024-06-25T09:46:04Z</d:ChangedOn>\n' +
            '           <d:CompletionFlag>false</d:CompletionFlag>\n' +
            '           <d:CodeGroup>WPUOEQ</d:CodeGroup>\n' +
            '           <d:JobCode>EREL</d:JobCode>\n' +
            '           <d:Completed>false</d:Completed>\n' +
            '           <d:CreatedBy>SBUTTX1</d:CreatedBy>\n' +
            '           <d:CreatedOn>2024-02-14T11:30:21Z</d:CreatedOn>\n' +
            '           <d:CustomerId/>\n' +
            '           <d:Description>MP test</d:Description>\n' +
            '           <d:DmaId/>\n' +
            '           <d:DrainageArea/>\n' +
            '           <d:FormattedAddress>GONALSTON LANE, EPPERSTONE, NG14 6AZ</d:FormattedAddress>\n' +
            '           <d:FlocId>13290-ZZ1-ZZZ1-0001-0005-M0001</d:FlocId>\n' +
            '           <d:ProblemTypeId/>\n' +
            '           <d:Historical>false</d:Historical>\n' +
            '           <d:HouseHold>X</d:HouseHold>\n' +
            '           <d:Trackable/>\n' +
            '           <d:Inprocess>false</d:Inprocess>\n' +
            '           <d:JobCodeId/>\n' +
            '           <d:Services>WP01</d:Services>\n' +
            '           <d:Notes> \n' +
            ' 19.03.2024 13:43:51 GMTUK  asdads (TRAINMOB01) \n' +
            ' Parked \n' +
            ' \n' +
            ' 13.06.2024 12:52:49 GMTUK  asdads (TRAINMOB01) \n' +
            ' sb 1 and sb 2 \n' +
            ' \n' +
            ' 21.06.2024 11:58:55 GMTUK  asdads (TRAINMOB01) \n' +
            ' \n' +
            ' \n' +
            ' Site - 10mm Bitmac (Tarmac) 12 mCarriageway-SB notes for site 1 \n' +
            ' Site - 6mm Bitmac (Tarmac) 23 mFootway-SB notes site 2 \n' +
            ' Site - Grass 33 mVerge-SB notes site 3 \n' +
            ' \n' +
            ' 25.06.2024 10:46:02 GMTUK  asdads (TRAINMOB01) \n' +
            ' dsd \n' +
            '</d:Notes>\n' +
            '           <d:NotificationType>Z1</d:NotificationType>\n' +
            '           <d:Outstanding>false</d:Outstanding>\n' +
            '           <d:PlanGroup>WP2</d:PlanGroup>\n' +
            '           <d:PlannerInfo>W001-WP2</d:PlannerInfo>\n' +
            '           <d:NotificationSla>5</d:NotificationSla>\n' +
            '           <d:SlaText>SLA 17FEB2024 11:29</d:SlaText>\n' +
            '           <d:Status>OPEN</d:Status>\n' +
            '           <d:ModifiedOn>2024-06-25T09:46:04Z</d:ModifiedOn>\n' +
            '           <d:WorkCentreNumber>4105WP3</d:WorkCentreNumber>\n' +
            '           <d:WorkCentreDescription>4105WP3 Nottingham GW Res-Bstrs</d:WorkCentreDescription>\n' +
            '           <d:WorkCentrePlant>W001</d:WorkCentrePlant>\n' +
            '           <d:WorkCentrePlantDescription>Water</d:WorkCentrePlantDescription>\n' +
            '           <d:WorkOrderId>95668481</d:WorkOrderId>\n' +
            '           <d:WorkOrderType>ZPM1</d:WorkOrderType>\n' +
            '           <d:ServiceNotificationEditable>false</d:ServiceNotificationEditable>\n' +
            '           <d:AttachmentSendToMobile>true</d:AttachmentSendToMobile>\n' +
            '           <d:AttachmentSendToMobileEditable>true</d:AttachmentSendToMobileEditable>\n' +
            '           <d:TargetServiceOrder/>\n' +
            '           <d:NotificationContactName/>\n' +
            '           <d:NotificationContactNumber/>\n' +
            '       </m:properties>\n' +
            '   </content>\n' +
            '</entry>';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', mockResponse));
        String result = FSM_JobHistoryRetrieve.getNotificationLongText('notificationNumber');
        Test.stopTest();
        FSM_IntegrationLog__c log = new FSM_IntegrationLog__c();
        log = [Select ID from FSM_IntegrationLog__c Limit 1];
        System.assertNotEquals(null, result);
        System.assert(result.contains('mVerge-SB notes site 3'), 'Result should contain expected substring');
        System.Assert(log != null, 'Integration Log created'); 
    }
    
    
    /******************************************************************************************************
@Author       : Srikanth Palla
@description   This test method verifies the Failure scenario LognTextNotification call using HttpCalloutMock class.
******************************************************************************************************/
    @isTest
    static void testLognTextNotificationFailure() {
        String mockResponse = '<?xml version="1.0" encoding="utf-8"?>\n' +
            '<entry m:etag="W/&quot;datetimeoffset\'2024-06-25T09%3A46%3A04Z\'&quot;" xml:base="https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/" xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">\n' +
            '   <id>https://prjdevgw:8443/sap/opu/odata/sap/ZWFM_CUSTOMER_MGMT_SRV/ServiceNotificationSet(\'95723921\')</id>\n' +
            '   <title type="text">ServiceNotificationSet(\'95723921\')</title>\n' +
            '   <updated>2024-06-26T12:44:59Z</updated>\n' +
            '   <category term="ZWFM_CUSTOMER_MGMT_SRV.ServiceNotification" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')" rel="self" title="ServiceNotification"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/WorkOrder" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/WorkOrder" type="application/atom+xml;type=entry" title="WorkOrder"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ContactPerson" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ContactPerson" type="application/atom+xml;type=entry" title="ContactPerson"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/Attachment" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Attachment" type="application/atom+xml;type=feed" title="Attachment"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ChangeHistory" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ChangeHistory" type="application/atom+xml;type=feed" title="ChangeHistory"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/StatusAssignmentActive" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/StatusAssignmentActive" type="application/atom+xml;type=feed" title="StatusAssignmentActive"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ServiceNotificationTask" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ServiceNotificationTask" type="application/atom+xml;type=feed" title="ServiceNotificationTask"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ServiceNotificationActivity" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ServiceNotificationActivity" type="application/atom+xml;type=feed" title="ServiceNotificationActivity"/>\n' +
            '   <link href="ServiceNotificationSet(\'95723921\')/ActionBox" rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/ActionBox" type="application/atom+xml;type=feed" title="ActionBox"/>\n' +
            '   <content type="application/xml">\n' +
            '       <m:properties>\n' +
            '           <d:Address m:type="ZWFM_CUSTOMER_MGMT_SRV.Address">\n' +
            '               <d:HouseNo/>\n' +
            '               <d:Street>GONALSTON LANE</d:Street>\n' +
            '               <d:FlatOrg/>\n' +
            '               <d:HouseName/>\n' +
            '               <d:SubStreet/>\n' +
            '               <d:SubTown/>\n' +
            '               <d:City>EPPERSTONE</d:City>\n' +
            '               <d:Postcode>NG14 6AZ</d:Postcode>\n' +
            '           </d:Address>\n' +
            '           <d:ServiceNotificationId>95723921</d:ServiceNotificationId>\n' +
            '           <d:MainPlant>W001</d:MainPlant>\n' +
            '           <d:HeaderNotification>true</d:HeaderNotification>\n' +
            '           <d:CatalogProfile>ZNT0000Z1</d:CatalogProfile>\n' +
            '           <d:ChangedBy>TRAINMOB01</d:ChangedBy>\n' +
            '           <d:ChangedOn>2024-06-25T09:46:04Z</d:ChangedOn>\n' +
            '           <d:CompletionFlag>false</d:CompletionFlag>\n' +
            '           <d:CodeGroup>WPUOEQ</d:CodeGroup>\n' +
            '           <d:JobCode>EREL</d:JobCode>\n' +
            '           <d:Completed>false</d:Completed>\n' +
            '           <d:CreatedBy>SBUTTX1</d:CreatedBy>\n' +
            '           <d:CreatedOn>2024-02-14T11:30:21Z</d:CreatedOn>\n' +
            '           <d:CustomerId/>\n' +
            '           <d:Description>MP test</d:Description>\n' +
            '           <d:DmaId/>\n' +
            '           <d:DrainageArea/>\n' +
            '           <d:FormattedAddress>GONALSTON LANE, EPPERSTONE, NG14 6AZ</d:FormattedAddress>\n' +
            '           <d:FlocId>13290-ZZ1-ZZZ1-0001-0005-M0001</d:FlocId>\n' +
            '           <d:ProblemTypeId/>\n' +
            '           <d:Historical>false</d:Historical>\n' +
            '           <d:HouseHold>X</d:HouseHold>\n' +
            '           <d:Trackable/>\n' +
            '           <d:Inprocess>false</d:Inprocess>\n' +
            '           <d:JobCodeId/>\n' +
            '           <d:Services>WP01</d:Services>\n' +
            '           <d:Notes> \n' +
            ' 19.03.2024 13:43:51 GMTUK  asdads (TRAINMOB01) \n' +
            ' Parked \n' +
            ' \n' +
            ' 13.06.2024 12:52:49 GMTUK  asdads (TRAINMOB01) \n' +
            ' sb 1 and sb 2 \n' +
            ' \n' +
            ' 21.06.2024 11:58:55 GMTUK  asdads (TRAINMOB01) \n' +
            ' \n' +
            ' \n' +
            ' Site - 10mm Bitmac (Tarmac) 12 mCarriageway-SB notes for site 1 \n' +
            ' Site - 6mm Bitmac (Tarmac) 23 mFootway-SB notes site 2 \n' +
            ' Site - Grass 33 mVerge-SB notes site 3 \n' +
            ' \n' +
            ' 25.06.2024 10:46:02 GMTUK  asdads (TRAINMOB01) \n' +
            ' dsd \n' +
            '</d:Notes>\n' +
            '           <d:NotificationType>Z1</d:NotificationType>\n' +
            '           <d:Outstanding>false</d:Outstanding>\n' +
            '           <d:PlanGroup>WP2</d:PlanGroup>\n' +
            '           <d:PlannerInfo>W001-WP2</d:PlannerInfo>\n' +
            '           <d:NotificationSla>5</d:NotificationSla>\n' +
            '           <d:SlaText>SLA 17FEB2024 11:29</d:SlaText>\n' +
            '           <d:Status>OPEN</d:Status>\n' +
            '           <d:ModifiedOn>2024-06-25T09:46:04Z</d:ModifiedOn>\n' +
            '           <d:WorkCentreNumber>4105WP3</d:WorkCentreNumber>\n' +
            '           <d:WorkCentreDescription>4105WP3 Nottingham GW Res-Bstrs</d:WorkCentreDescription>\n' +
            '           <d:WorkCentrePlant>W001</d:WorkCentrePlant>\n' +
            '           <d:WorkCentrePlantDescription>Water</d:WorkCentrePlantDescription>\n' +
            '           <d:WorkOrderId>95668481</d:WorkOrderId>\n' +
            '           <d:WorkOrderType>ZPM1</d:WorkOrderType>\n' +
            '           <d:ServiceNotificationEditable>false</d:ServiceNotificationEditable>\n' +
            '           <d:AttachmentSendToMobile>true</d:AttachmentSendToMobile>\n' +
            '           <d:AttachmentSendToMobileEditable>true</d:AttachmentSendToMobileEditable>\n' +
            '           <d:TargetServiceOrder/>\n' +
            '           <d:NotificationContactName/>\n' +
            '           <d:NotificationContactNumber/>\n' +
            '       </m:properties>\n' +
            '   </content>\n' +
            '</entry>';
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new AssetHistoryLevel6MockCallout());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, 'OK', mockResponse));
        String result = FSM_JobHistoryRetrieve.getNotificationLongText('notificationNumber');
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
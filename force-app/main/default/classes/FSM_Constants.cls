/********************************************************************************************************
@Author      : Srikanth Palla
@description : Created to declare contacts varibales used in differnet classes
********************************************************************************************************/
public with sharing class FSM_Constants {
    
    public static final integer RESPONSE_200=200;
    public static final integer RESPONSE_400=400;
    public static final string RES_SUCCESS='SUCCESS';
    public static final string NO_POLYGON='No Polygon Found';
    public static final string RES_ERROR='ERROR';
    public static final string SLOT_TYPE_2HOUR='2 hour';
    public static final string FSM_APPOINTMENT_SERVICE_NAME='CreateCustomerAppointmentWOSA'; //Added as part of SFI-261, By Srikanth Palla
    public static final string FSM_GIS_SERVICE_NAME='GIS LATLONG Conversion';
    public static final String RECORDTYPE_DEVELOPERSERVICES = 'FSM_DeveloperServices'; // [Added by Arnob Dey #SFS-318]
    public static final String RECORDTYPE_WASTENONINFRA='FSM_WasteNonInfra';//SFS-3028
    public static final String RECORDTYPE_INFRAFOLLOWONWORKREQUEST = 'Infra_Follow_On_Work_Request'; // [Added by Aishwarya Bhosale #SFS-1005]
    public static final String RECORDTYPE_SEWERAGEFURTHERWORKREQUEST ='FSM_SewerageFurtherWorkRequestSCM';//  [Added by Brajesh Kumar #SFS-5399]
    public static final String RECORDTYPE_METERING = 'FSM_Metering'; // [Added by Arnob Dey #SFS-1298]
    public static final String RECORDTYPE_WASTEINFRA = 'FSM_WasteInfra'; // [Added by Aishwarya Dey #SFS-3050]
    Public Static Final String DCF_LINEITEM_PREFIX = 'LineItem_'; //To Add a prefix to Dcf Line item field api name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DEFAULT_NODE = 'DCF'; //To Add a prefix to Dcf Line item field api name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_PAYLOAD_1 = 'FSM_DCFPayload1__c'; //DCF payload field name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_PAYLOAD_2 = 'FSM_DCFPayload2__c'; //DCF payload field name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_PAYLOAD_3 = 'FSM_DCFPayload3__c'; //DCF payload field name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_PAYLOAD_4 = 'FSM_DCFPayload4__c'; //DCF payload field name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_PAYLOAD_5 = 'FSM_DCFPayload5__c'; //DCF payload field name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_PAYLOAD_LINE = 'FSM_DCFLineItemsPayload__c'; //DCF payload field name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String FIRSTBRACKETSTART_DOUBLEQUOTE = '{"'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DOUBLEQUOTE_COLON = '":'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String FIRSTBRACKETEND_FIRSTBRACKETEND = '}}'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String FIRSTBRACKETSTART = '{'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String FIRSTBRACKETEND = '}'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String COMMA = ','; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DOT = '.'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String BLANK = ''; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String THIRDBRACKATSTART = '['; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String THIRDBRACKATEND = ']'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String CUSTOMSYMBOL1 = '"","'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String CUSTOMSYMBOL2 = ',"'; //Symbol SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_INFRA = 'FSM_DataCaptureFormInfra__c'; //DCF Infra object APi name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_INFRA1 = 'FSM_InfraDataCaptureForm2__c'; //DCF Infra object APi name SFI-1204, 27th Dec 2023, Subir Maji
    Public Static Final String DCF_INFRA_LINE = 'FSM_DataCaptureFormLineItems__r'; //DCF Infra Line relation APi name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_INFRA_LINE1 = 'FSM_InfraDataCaptureLineItem2__r'; //DCF Infra Line relation APi name SFI-1204, 27th Dec 2023, Subir Maji
    Public Static Final String DCF_NONINFRA_LINE = 'FSM_DataCaptureFormLineItemNonInfras__r'; //DCF Non Infra Line relation APi name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_NONINFRA = 'FSM_DataCaptureFormNonInfra__c'; //DCF non Infra object APi name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_BASEQUERY = 'SELECT id, FSM_DCFHierarchyLevel__c, FSM_NoOfEformsOfSameType__c, FSM_Medium__c, RecordType.developerName, FSM_WorkOrder__c, FSM_ServiceResource__c, FSM_ServiceTerritory__c, FSM_WorkOrder__r.FSM_ExternalId__c, FSM_WorkOrder__r.FSM_OrderNumber__c ,FSM_WorkOrder__r.FSM_OperationNumber__c , FSM_WorkOrder__r.FSM_NotificationNumber__c,FSM_WorkOrder__r.RecordType.DeveloperName,FSM_ServiceResource__r.Name';//DCF object Query start SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String DCF_LINE_BASEQUERY = ', (SELECT id, FSM_LineItem__c ';//DCF Line object Query start SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String QUERYHELPER1 = ' FROM '; //DCF object Query SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String QUERYEND = ' WHERE ID IN : allId WITH SECURITY_ENFORCED'; //DCF object Query End SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String WORKORDER_R = 'FSM_WorkOrder__r'; //Work Order field api relation name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String SERVICERESOURCE_R = 'FSM_ServiceResource__r'; //Service resource field api relation name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String SERVICETERRITORY_R = 'FSM_ServiceTerritory__r'; //Service territory field api relation name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String WORKORDER_C = 'FSM_WorkOrder__c'; //Work Order field api name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String SERVICERESOURCE_C = 'FSM_ServiceResource__c'; //Service resource field api name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String SERVICETERRITORY_C = 'FSM_ServiceTerritory__c'; //Service territory field api name SFI-35, 7th Aug 2023, Subir Maji
    Public Static Final String RESPONSE_PAYLOAD_START = '{"attributes":{"type":"FSM_SendDCFUpdates__e"},"FSM_FormName__c":"'; //Response Payload Start SFI-35, 7th Aug 2023, Subir Maji
    public static final string  DCF_SCHEDULING_POLICY='Test Policy';//SFI-35 used in test class
    public static final string 	OH_BUSINESS_UNIT='Developer Services';
    public static final string 	BUSINESS_UNIT='Developer Services';
    public static final string 	OH_AM_PM='AM/Pm Operating Hours';
    public static final string 	DURATION='AMPM';
    public static final string 	RESOURCE_NAME='Testing Resource';
    public static final string 	WO_BUSINESS_UNIT='Waste Infra';
    public static final string 	FORMTYPE='FSM_ValveManagement';
    public static final string 	FORMTYPE_INFRA1='FSM_SewerageJobFeedback';//Added as part of SFI-1204
	public static final string  STATUS_COMPLETED='Completed';
    public static final string  STATUS_NEW='New';
    public static final string  GIS_ENDPOINT = 'callout:calloutGIS'; //Added As part of SFI-21
    public static final string  CUSTOMSYMBOL3 = '{"XCord":"'; //Added As part of SFI-21
    public static final string  CUSTOMSYMBOL4 = '","YCord" :"'; //Added As part of SFI-21
    public static final string  CUSTOMSYMBOL5 = '","LayerRefid":"'; //Added As part of SFI-21
    public static final string  CUSTOMSYMBOL6 = '"}'; //Added As part of SFI-21
    public static final string  CUSTOMSYMBOL7 = '""'; //Added As part of SFI-21
    public static final string  RESTMETHODPOST = 'POST'; //Added As part of SFI-21
    public static final string  HEADER1 = 'proxyPort'; //Added As part of SFI-21
    public static final string  HEADER2 = '443'; //Added As part of SFI-21
    public static final string  HEADER3 = 'Content-Type'; //Added As part of SFI-21
    public static final string  HEADER4 = 'application/json;charset=UTF-8'; //Added As part of SFI-21
    public static final string  NO_VALUE_GIS = 'None'; //Added As part of SFI-21
    public static final string PREFIX='[';//Added As part of SFI-1557
    public static final string SUFIX=']';//Added As part of SFI-1557
    public static final string FILEUPLOAD_SERVCIE='Send Upload Attachments';//Added As part of SFI-1213
    public static final string MAILJET_BCC_NAME='Customer';//Added As part of SFI-1821
    
    public static final string ORDER_BY=' Order By ';//added as part of SFI-2974 by Subir Maji 22nd Oct 24
    public static final string ORDER_BY_ASC=' ASC';//added as part of SFI-2974 by Subir Maji 22nd Oct 24
    public static final string ORDER_BY_DESC=' DESC';//added as part of SFI-2974 by Subir Maji 22nd Oct 24
}
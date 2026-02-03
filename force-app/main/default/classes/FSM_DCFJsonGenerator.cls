/**********************************************************************************************************
@Author      :  Subir Maji
@Description : This Class is going to build JSON and publish platform event for Data capture Form.
@Description : Created as part of user story #SFI-35
@Test Class  : FSM_DCFJsonGeneratorTest
@Date        : 31-July-2023
********************************************************************************************************/
public with sharing Class FSM_DCFJsonGenerator {
    
    public Static Map<String, Map<String, String>> formAndFieldAndFormulaMap; //To Create Map between Form and Field and Formula
    public Static Map<String, Map<String, String>> formAndFieldAndPlatformFieldMap; //To Create Map between Form and Field and Platform Event Field
    public Static Map<String, Map<String, String>> formAndFieldAndJSOnLabelMap; //To Create Map between Form and Field and JSOn Label
    public Static Map<String, Map<String, String>> formAndFieldAndNodeMap; //To Create Map between Form and Field and Node
    public Static Map<String, Map<String, String>> formAndFieldandTypeMap; //To Create Map between Form and Field and Type
    public Static Set<String> allGrandChildId = new Set<String>(); //Variable to keep Id for all Grand child record, this part is added as part of SFI-2041 by Subir Maji 23rd July 2024
    public Static Map<String, List<String>> mapOfParentChildLineItem = new Map<String, List<String>>(); //Variable to keep a map of Line item parent and child, this part is added as part of SFI-2041 by Subir Maji 23rd July 2024
    
    //All Final Static variables
    Static String dcfLineItemPreFix = FSM_Constants.DCF_LINEITEM_PREFIX; //To Add a prefix to Dcf Line item field api name
    
    Static Set<String> isLineItemQueryNeeded;//This will indicate if the record have line Item
    Static String formName; //To hold the form type
    
    //To build the paylod
    public Static String dcfLineItemsPayload; 
    public Static String dcfPayload1; 
    public Static String dcfPayload2; 
    public Static String dcfPayload3; 
    public Static String dcfPayload4; 
    public Static String dcfPayload5;
    public Static List<FieldStructureGenerator> fieldHelperAll;
    Static FieldStructureGenerator fieldHelper;
    
    //To Keep the Master Object details
    Static Map<String, WorkOrder> allWorkOrder;
    Static Map<String, ServiceTerritory> allServiceTerritory;
    Static Map<String, ServiceResource> allResource;
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is invocable method getting called from flows and construct the query to get relavant record based on certain condition.
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    @InvocableMethod(label = 'DCFJsonGenerator')
    public static void jsonGenerator(List<DCFInputParam> dcfInputs){
        String objectApiName = dcfInputs[0].objectApiName; //To get the Objcet API name
        String sapuserid = dcfInputs[0].sapUserID; //To get the SAP user id Added as part of SFI-1724
        List<FSM_DataCaptureFormInfra__c> dcfRecordInfra; //To collect the data from DCF Infra object
        List<FSM_InfraDataCaptureForm2__c> dcfRecordInfra1; //To collect the data from DCF Infra object2 Added as part of SFI-1204
        List<FSM_DataCaptureFormNonInfra__c> dcfRecordNonInfra; //To collect the data from DCF Non Infra object
        Set<ID> allId = new Set<ID>(); //To Collect record id's
        Set<String> formType = new Set<String>(); //To collect form names
        String lineItemObjectApiName = objectApiName == FSM_Constants.DCF_INFRA?FSM_Constants.DCF_INFRA_LINE:FSM_Constants.DCF_NONINFRA_LINE; //To get the Objcet related line iten object API name
		lineItemObjectApiName = objectApiName == FSM_Constants.DCF_INFRA1?FSM_Constants.DCF_INFRA_LINE1:lineItemObjectApiName; //Added as part of SFI-1204 for new DCF object
        allWorkOrder = new Map<String, WorkOrder>();
        allServiceTerritory = new Map<String, ServiceTerritory>();
        allResource = new Map<String, ServiceResource>();
        PlatformEventHeaderGenerator peHeaderhelper; //To create Pleatform event header structure.
        Map<ID, FSM_SendDCFUpdates__e> recordIDAndPE = new Map<ID, FSM_SendDCFUpdates__e>(); //To collect the platform events and DCF Record id
        
        //Create List of ID and Set of Form Type
        for(DCFInputParam inputs : dcfInputs){
            allId.add(inputs.recordId);
            formType.add(inputs.recordTypeDeveloperName);
            allWorkOrder.put(inputs.workOrderId, inputs.workOrderRecord);
            allServiceTerritory.put(inputs.serviceTerritoryID, inputs.serviceTerritoryRecord);
            allResource.put(inputs.serviceResourceID, inputs.serviceResourceRecord);
        }
        
        //Get Custom metadata and build teh maps for form and fields etc..
        buildStructureBasedOnMetadata(objectApiName, lineItemObjectApiName, formType);
        
        try{
       		//Check Objcet API name and build query based on that
       		if(objectApiName.equals(FSM_Constants.DCF_INFRA)){
                //Build and Run Query to get records
                dcfRecordInfra = Database.query(buildQuery(allId, objectApiName, lineItemObjectApiName));
                
                //Going through the records
                for( FSM_DataCaptureFormInfra__c iterator :dcfRecordInfra){
                    formName = iterator.RecordType.developername;
                    initiateVeriables();
                    convertDataDCF(iterator, null, null); //Updated as part of SFI-1204
                    if(isLineItemQueryNeeded.Contains(formName)){
                        for(FSM_DCFLineItemInfra__c lineInfra : iterator.FSM_DataCaptureFormLineItems__r){
                            convertDataDCFLineItem(lineInfra, null, Null);
                        }
                    }
                    //Create header structure for DCF, added as part of SFI-547
                    peHeaderhelper = assignHeaderFieldValues(iterator.FSM_Workorder__r.FSM_OrderNumber__c,iterator.FSM_Workorder__r.FSM_OperationNumber__c ,iterator.FSM_Workorder__r.FSM_NotificationNumber__c , iterator.FSM_ServiceResource__r.Name, formName,Integer.valueOf(iterator.FSM_NoOfEformsOfSameType__c),iterator.FSM_Medium__c,Integer.valueOf(iterator.FSM_DCFHierarchyLevel__c));
                    //Create platform event record
                    recordIDAndPE.put(iterator.ID, createPlatformEvent(formName, iterator.FSM_Workorder__r.FSM_ExternalId__c, JSON.serialize(peHeaderhelper),sapuserid)); //Updated as part of SFI-1724
                }
            }else if(objectApiName.equals(FSM_Constants.DCF_INFRA1)){ //If Condition Added as part of SFI-1204
                //Build and Run Query to get records
                dcfRecordInfra1 = Database.query(buildQuery(allId, objectApiName, lineItemObjectApiName));
                
                //Going through the records
                for( FSM_InfraDataCaptureForm2__c iterator :dcfRecordInfra1){
                    formName = iterator.RecordType.developername;
                    initiateVeriables();
                    convertDataDCF(null, iterator, null);
                    if(isLineItemQueryNeeded.Contains(formName)){
                        for(FSM_InfraDataCaptureLineItem2__c lineInfra : iterator.FSM_InfraDataCaptureLineItem2__r){
                            convertDataDCFLineItem(null, lineInfra, Null);
                        }
                    }
                    //Create header structure for DCF, added as part of SFI-547
                    peHeaderhelper = assignHeaderFieldValues(iterator.FSM_Workorder__r.FSM_OrderNumber__c,iterator.FSM_Workorder__r.FSM_OperationNumber__c ,iterator.FSM_Workorder__r.FSM_NotificationNumber__c , iterator.FSM_ServiceResource__r.Name, formName,Integer.valueOf(iterator.FSM_NoOfEformsOfSameType__c),iterator.FSM_Medium__c,Integer.valueOf(iterator.FSM_DCFHierarchyLevel__c));
                    //Create platform event record
                    recordIDAndPE.put(iterator.ID, createPlatformEvent(formName, iterator.FSM_Workorder__r.FSM_ExternalId__c, JSON.serialize(peHeaderhelper),sapuserid)); //Updated as part of SFI-1724
                }
            }else if(objectApiName.equals(FSM_Constants.DCF_NONINFRA)){
                //Build and Run Query to get records
                dcfRecordNonInfra = Database.query(buildQuery(allId, objectApiName, lineItemObjectApiName));
                //Going through the records
                for(FSM_DataCaptureFormNonInfra__c iterator :dcfRecordNonInfra){
                    formName = iterator.RecordType.developername;
                    initiateVeriables();
                    convertDataDCF(null, Null, iterator);//Updated as part of SFI-1204
                    if(isLineItemQueryNeeded.Contains(formName)){
                        for(FSM_DCFLineItemNonInfra__c lineNonInfra : iterator.FSM_DataCaptureFormLineItemNonInfras__r){
                            convertDataDCFLineItem(Null, null, lineNonInfra); //Updated as part of SFI-1204
                        }
                    }
                    //Create header structure for DCF, added as part of SFI-547
                    peHeaderhelper = assignHeaderFieldValues(iterator.FSM_Workorder__r.FSM_OrderNumber__c,iterator.FSM_Workorder__r.FSM_OperationNumber__c ,iterator.FSM_Workorder__r.FSM_NotificationNumber__c , iterator.FSM_ServiceResource__r.Name, formName,Integer.valueOf(iterator.FSM_NoOfEformsOfSameType__c),iterator.FSM_Medium__c,Integer.valueOf(iterator.FSM_DCFHierarchyLevel__c)); //Updated As part of SFI-1801 Subir Maji 3rd July 24
                    //Create platform event record
                    recordIDAndPE.put(iterator.ID, createPlatformEvent(formName, iterator.FSM_Workorder__r.FSM_ExternalId__c, JSON.serialize(peHeaderhelper),sapuserid)); //Updated as part of SFI-1724
                }
            }
            
            //Publish Platform Event
            if(recordIDAndPE != null && !recordIDAndPE.isEmpty()){
                EventBus.publish(recordIDAndPE.values());
                //Create Integration log for individual platform Event
                createIntegrationLog(recordIDAndPE);
            }
        }catch(Exception ex){
            //Added/Updated as part of SFI-2314 by Subir Maji 28th June 24
            String allRecordID = '';
            if(recordIDAndPE != null && !recordIDAndPE.isEmpty()){
                allRecordID = String.valueof(recordIDAndPE.KeySet()).Left(254);
            }else{
                allRecordID = String.valueof(allID).Left(254);
            }
            //Create one single error log
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_DCFJsonGenerator').setErrorMessage(ex.getMessage()).setLineNumber(string.valueof(ex.getLineNumber())).setExternalID(allRecordID).setMethodName('JsonGenerator').setStackTrace(ex.getStackTraceString()).setType('Integration').create();
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This will create the Platform Event header field structure
    @Description : Created as part of user story #SFI-547
	@input		 : orderNumber, operationNumber, notificationNumber, resourceName, woRecTypedevName
	@output		 : PlatformEventHeaderGenerator
    @Date        : 31-August-2023
	@date 		 : Updated as part of SFI-2041 by Subir Maji 23rd July 2024
    ********************************************************************************************************/ 
    private static PlatformEventHeaderGenerator assignHeaderFieldValues(String orderNumber, String operationNumber, String notificationNumber, String resourceName, String formType,Integer noOfEforms,String medium, Integer hierarchyLevel){
        PlatformEventHeaderGenerator helper = new PlatformEventHeaderGenerator();
        helper.AUFNR = orderNumber;
        helper.VORNR = operationNumber;
        helper.QMNUM = notificationNumber;
        helper.Name = resourceName;
		helper.FormType = formType;   
        helper.SEQNR = noOfEforms;
        helper.MEDIUM = medium;
        helper.HIERARCHYLEVEL = hierarchyLevel; //this part is added as part of SFI-2041 by Subir Maji 23rd July 2024
        return helper;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This will create the integration logs
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void createIntegrationLog(Map<ID, FSM_SendDCFUpdates__e> recordIDAndPE){
        FSM_IntegrationLog__c ieLog;
        List<FSM_IntegrationLog__c> allIeLog = new List<FSM_IntegrationLog__c>();
        
        for(ID recID : recordIDAndPE.keySet()){
            ieLog = new FSM_Utility.IntegrationLogCreator().setRecordId(recID)
                .setReqPayload(buildRequestPayload(recordIDAndPE.get(recID))).setServiceName(recordIDAndPE.get(recID).FSM_FormName__c).setExternalId(recordIDAndPE.get(recID).FSM_ExternalId__c)
                .returnWithoutCreate();
            allIeLog.add(ieLog);
        }
        
        if(!allIeLog.isEmpty()){
            if (SObjectType.FSM_IntegrationLog__c.isCreateable()) {
                Insert allIeLog;
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is invocable Variables getting called from flows.
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static String buildRequestPayload(FSM_SendDCFUpdates__e pe){
        String requestPayload = FSM_Constants.RESPONSE_PAYLOAD_START + pe.FSM_FormName__c + '","FSM_SAPUserID__c":"'+ pe.FSM_SAPUserID__c +
            '","FSM_ExternalId__c":"' + pe.FSM_ExternalId__c + '","FSM_DCFHeaderPayload__c":' + pe.FSM_DCFHeaderPayload__c +',"'+FSM_Constants.DCF_PAYLOAD_LINE + FSM_Constants.DOUBLEQUOTE_COLON;
        
        if(pe.FSM_DCFLineItemsPayload__c != null && !String.isBlank(pe.FSM_DCFLineItemsPayload__c)){
            requestPayload = requestPayload + pe.FSM_DCFLineItemsPayload__c + FSM_Constants.CUSTOMSYMBOL2 +FSM_Constants.DCF_PAYLOAD_1 + FSM_Constants.DOUBLEQUOTE_COLON;
        }else{
            requestPayload = requestPayload + FSM_Constants.CUSTOMSYMBOL1 + FSM_Constants.DCF_PAYLOAD_1 + FSM_Constants.DOUBLEQUOTE_COLON;
        }
        if(pe.FSM_DCFPayload1__c != null && !String.isBlank(pe.FSM_DCFPayload1__c)){
            requestPayload = requestPayload + pe.FSM_DCFPayload1__c + FSM_Constants.CUSTOMSYMBOL2+FSM_Constants.DCF_PAYLOAD_2 + FSM_Constants.DOUBLEQUOTE_COLON;
        }else{
            requestPayload = requestPayload + FSM_Constants.CUSTOMSYMBOL1+FSM_Constants.DCF_PAYLOAD_2+ FSM_Constants.DOUBLEQUOTE_COLON;
        }
        if(pe.FSM_DCFPayload2__c != null && !String.isBlank(pe.FSM_DCFPayload2__c)){
            requestPayload = requestPayload + pe.FSM_DCFPayload2__c + FSM_Constants.CUSTOMSYMBOL2+FSM_Constants.DCF_PAYLOAD_3 + FSM_Constants.DOUBLEQUOTE_COLON;
        }else{
            requestPayload = requestPayload + FSM_Constants.CUSTOMSYMBOL1+FSM_Constants.DCF_PAYLOAD_3+ FSM_Constants.DOUBLEQUOTE_COLON;
        }
        if(pe.FSM_DCFPayload3__c != null && !String.isBlank(pe.FSM_DCFPayload3__c)){
            requestPayload = requestPayload + pe.FSM_DCFPayload3__c + FSM_Constants.CUSTOMSYMBOL2+FSM_Constants.DCF_PAYLOAD_4 + FSM_Constants.DOUBLEQUOTE_COLON;
        }else{
            requestPayload = requestPayload + FSM_Constants.CUSTOMSYMBOL1+FSM_Constants.DCF_PAYLOAD_4+ FSM_Constants.DOUBLEQUOTE_COLON;
        }
        if(pe.FSM_DCFPayload4__c != null && !String.isBlank(pe.FSM_DCFPayload4__c)){
            requestPayload = requestPayload + pe.FSM_DCFPayload4__c + FSM_Constants.CUSTOMSYMBOL2+FSM_Constants.DCF_PAYLOAD_5+ FSM_Constants.DOUBLEQUOTE_COLON;
        }else{
            requestPayload = requestPayload + FSM_Constants.CUSTOMSYMBOL1+FSM_Constants.DCF_PAYLOAD_5 + FSM_Constants.DOUBLEQUOTE_COLON;
        }
        if(pe.FSM_DCFPayload5__c != null && !String.isBlank(pe.FSM_DCFPayload5__c)){
            requestPayload = requestPayload + pe.FSM_DCFPayload5__c + FSM_Constants.COMMA;
        }else{
            requestPayload = requestPayload + '"",';
        }
        
        requestPayload = requestPayload + '"EventUuid":"' + pe.EventUuid + '"}';
        
        return requestPayload;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is invocable Variables getting called from flows.
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public Class DCFInputParam{
        @InvocableVariable
        public String recordId;
        
        @InvocableVariable
        public String recordTypeDeveloperName;
        
        @InvocableVariable
        public String objectApiName;
        
        @InvocableVariable
        public String sapUserID; //Added as part of SFI-1724
        
        @InvocableVariable
        public String workOrderId;
        
        @InvocableVariable
        public String serviceResourceID;
        
        @InvocableVariable
        public String serviceTerritoryID;
        
        @InvocableVariable
        public FSM_DataCaptureFormInfra__c dcfInfraRecord;
        
        @InvocableVariable
        public FSM_InfraDataCaptureForm2__c dcfInfraRecord1; //Added as part of SFI-1204
        
        @InvocableVariable
        public FSM_DataCaptureFormNonInfra__c dcfNonInfraRecord;
        
        @InvocableVariable
        public WorkOrder workOrderRecord;
        
        @InvocableVariable
        public ServiceResource serviceResourceRecord;
        
        @InvocableVariable
        public ServiceTerritory serviceTerritoryRecord;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This will initiate or reset the variables
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void initiateVeriables(){
    	dcfLineItemsPayload = FSM_Constants.BLANK;
        dcfPayload1 = FSM_Constants.BLANK;
        dcfPayload2 = FSM_Constants.BLANK;
        dcfPayload3 = FSM_Constants.BLANK;
        dcfPayload4 = FSM_Constants.BLANK;
        dcfPayload5 = FSM_Constants.BLANK;
        fieldHelperAll = new List<fieldStructureGenerator>();
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will create the platform event record
    @Description : Created as part of user story #SFI-35///Updated as part of SFI-1724 to add SAP user id
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static FSM_SendDCFUpdates__e createPlatformEvent(String formName, String externalID, String header,String sapuserid){
    	FSM_SendDCFUpdates__e createDCF = new FSM_SendDCFUpdates__e();
        FSM_DCFJsonGeneratorHelper.createStringJSON();
        createDCF.FSM_FormName__c = formName;
        createDCF.FSM_ExternalId__c = externalID;
        createDCF.FSM_DCFHeaderPayload__c = header;
        createDCF.FSM_DCFLineItemsPayload__c = dcfLineItemsPayload;
        createDCF.FSM_DCFPayload1__c = dcfPayload1;
        createDCF.FSM_DCFPayload2__c = dcfPayload2;
        createDCF.FSM_DCFPayload3__c = dcfPayload3;
        createDCF.FSM_DCFPayload4__c = dcfPayload4;
        createDCF.FSM_DCFPayload5__c = dcfPayload5;
        createDCF.FSM_SAPUserID__c=sapuserid; //Added as part of SFI-1724
        return createDCF;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will get the metaddata and build the structures for further operations.
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static Void buildStructureBasedOnMetadata(String objectApiName, String lineItemObjectApiName, Set<String> formType){
        List<FSM_DCFFormFieldMapping__mdt> dCFFormFieldMetadataRecords; //To Collect custom Metadata details
        String fieldApiName; //To format the field API name so that we can differ between parent and child
        
        //Get metadata record based on the trigerring object and formtype
        If(Test.isRunningTest() && formType.contains(FSM_Constants.FORMTYPE)){
        	dCFFormFieldMetadataRecords = [SELECT Id, Active__c, FSM_DataType__c, FSM_FieldAPIName__c, FSM_Formula__c,
                                       FSM_IsFormulaField__c, FSM_IsParentObjectField__c, FSM_JSONLabel__c, FSM_Node__c,
                                       FSM_ObjectAPIName__c, FSM_FormName__c, FSM_PlatformEventField__c, FSM_IsDCFLineItemField__c 
                                       FROM FSM_DCFFormFieldMapping__mdt 
                                       WHERE FSM_FormName__c IN : formType
                                       AND DeveloperName Like '%_Testing%'
                                       AND (FSM_ObjectAPIName__c =: objectApiName OR FSM_ObjectAPIName__c =: lineItemObjectApiName)
                                       AND Active__c = true WITH SECURITY_ENFORCED ORDER BY FSM_PlatformEventField__c ASC NULLS FIRST];
        
        }else{
            dCFFormFieldMetadataRecords = [SELECT Id, Active__c, FSM_DataType__c, FSM_FieldAPIName__c, FSM_Formula__c,
                                       FSM_IsFormulaField__c, FSM_IsParentObjectField__c, FSM_JSONLabel__c, FSM_Node__c,
                                       FSM_ObjectAPIName__c, FSM_FormName__c, FSM_PlatformEventField__c, FSM_IsDCFLineItemField__c 
                                       FROM FSM_DCFFormFieldMapping__mdt 
                                       WHERE (NOT DeveloperName Like '%_Testing%')
                                       AND FSM_FormName__c IN : formType
                                       AND (FSM_ObjectAPIName__c =: objectApiName OR FSM_ObjectAPIName__c =: lineItemObjectApiName)
                                       AND Active__c = true WITH SECURITY_ENFORCED ORDER BY FSM_PlatformEventField__c ASC NULLS FIRST];
        }
        
        //If Metadata records available then separate and collect info from metadata
        if(dCFFormFieldMetadataRecords != null && !dCFFormFieldMetadataRecords.isEmpty()){
            formAndFieldandTypeMap = new Map<String, Map<String, String>>();
            formAndFieldAndFormulaMap = new Map<String, Map<String, String>>();
            formAndFieldAndJSOnLabelMap = new Map<String, Map<String, String>>();
            formAndFieldAndNodeMap = new Map<String, Map<String, String>>();  
            formAndFieldAndPlatformFieldMap = new Map<String, Map<String, String>>();
                
            for(FSM_DCFFormFieldMapping__mdt dcfMdt : dCFFormFieldMetadataRecords){
                if(dcfMdt.FSM_IsDCFLineItemField__c){
                	fieldApiName = dcfLineItemPreFix+dcfMdt.FSM_FieldAPIName__c;
                }else{
                    fieldApiName = dcfMdt.FSM_FieldAPIName__c;
                }
                //To Create Map between Form and Field and Type
                FSM_DCFJsonGeneratorHelper.formAndFieldandTypeMap(dcfMdt.FSM_FormName__c, fieldApiName, dcfMdt.FSM_DataType__c);
                //To Create Map between Form and Field and Formula
                FSM_DCFJsonGeneratorHelper.formAndFieldAndFormulaMap(dcfMdt.FSM_IsFormulaField__c, dcfMdt.FSM_FormName__c, fieldApiName, dcfMdt.FSM_Formula__c);
                //To Create Map between Form and Field and Platform Event Field
                FSM_DCFJsonGeneratorHelper.formAndFieldAndPlatformFieldMap(dcfMdt.FSM_FormName__c, fieldApiName, dcfMdt.FSM_PlatformEventField__c);
                //To Create Map between Form and Field and JSOn Label
                FSM_DCFJsonGeneratorHelper.formAndFieldAndJSOnLabelMap(dcfMdt.FSM_FormName__c, fieldApiName, dcfMdt.FSM_JSONLabel__c);
                //To Create Map between Form and Field and Node
                FSM_DCFJsonGeneratorHelper.formAndFieldAndNodeMap(dcfMdt.FSM_FormName__c, fieldApiName, dcfMdt.FSM_Node__c);
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to build teh query based on custom metadata.
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static String buildQuery(Set<ID> allId, String objectAPIName, String lineItemObjectApiName){
    	String query; //To build the query
        String lineItemQuery; //To build the query for line items
        Map<String, String> fieldName = new Map<String, String>(); //to Find teh Field Api name
        Set<String> allFields = new Set<String>(); //collect unique set of fields
        isLineItemQueryNeeded = New Set<String>(); // Seting the variable to false
        Map<String, String> childFormName = new Map<String, String>();
        String orderByFieldName = 'FSM_NoOfLineItemsEformsOfSameType__c'; //To maintain sequence of the records, added as part of SFI-2974 by Subir Maji 22nd Oct 24
        //added as part of SFI-2974 by Subir Maji 22nd Oct 24
        if(lineItemObjectApiName == FSM_Constants.DCF_NONINFRA_LINE){
            orderByFieldName = 'CreatedDate';
        }
        
        // for Infra or Non Infra Object adding Number of eform field, Updated by Subir Maji SFI-1801 3rd July 24
        query = FSM_Constants.DCF_BASEQUERY;
		
        //build basic query Master
        lineItemQuery = FSM_Constants.DCF_LINE_BASEQUERY; //build basic query Line item
        
        //go through filed and collet in a set
        if(formAndFieldandTypeMap != null && !formAndFieldandTypeMap.isEmpty()){
            for(String str : formAndFieldandTypeMap.keySet()){
                fieldName = formAndFieldandTypeMap.get(str);
                for(String field : fieldName.keySet()){
                    allFields.add(field);
                    childFormName.put(field,str);
                }
            }
            
            // add field in the query
            for(String str : allFields){
                if(!str.contains(dcfLineItemPreFix)){ //if not a line item
                   query = query + FSM_Constants.COMMA + str; 
                }else{ //If line Item available
                    isLineItemQueryNeeded.add(childFormName.get(str));
                    lineItemQuery = lineItemQuery + FSM_Constants.COMMA + str.removeStart(dcfLineItemPreFix);
                }
                
            }
        }
        
        //If line Item field available
        //Updated as part of SFI-2974 by Subir Maji 22nd Oct 24 tO add Order by
        if(isLineItemQueryNeeded != null && !isLineItemQueryNeeded.isEmpty()){
            lineItemQuery = lineItemQuery + FSM_Constants.QUERYHELPER1+ lineItemObjectApiName+ FSM_Constants.ORDER_BY+ orderByFieldName+ FSM_Constants.ORDER_BY_ASC+')';
            query = query + lineItemQuery;
        }
        
        query = query + FSM_Constants.QUERYHELPER1+ objectApiName +FSM_Constants.QUERYEND; //Final query
        return query; //return query
        
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method convert the data based on custom metadata for DCF.
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static Void convertDataDCF(FSM_DataCaptureFormInfra__c dcfInfra, FSM_InfraDataCaptureForm2__c dcfInfra1, FSM_DataCaptureFormNonInfra__c dcfNonInfra){
        Map<String,String> fieldAndType = new Map<String,String>(); //To collect Map between Field and field type
        //If DCF Infra convert data based on field type
        if(dcfInfra != null && formAndFieldandTypeMap.containsKey(formName)){
            fieldAndType = formAndFieldandTypeMap.get(formName);
            
            for(String str : fieldAndType.keySet()){
                if(!str.contains(dcfLineItemPreFix)){
                    if(str.contains(FSM_Constants.WORKORDER_R) && allWorkOrder.containskey(String.ValueOf(dcfInfra.get(FSM_Constants.WORKORDER_C)))){
                        applyDataType(getWorkOrderDetails(allWorkOrder.get(String.ValueOf(dcfInfra.get(FSM_Constants.WORKORDER_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(str.contains(FSM_Constants.SERVICERESOURCE_R) && allResource.containskey(String.ValueOf(dcfInfra.get(FSM_Constants.SERVICERESOURCE_C)))){
                        applyDataType(getServiceResourceDetails(allResource.get(String.ValueOf(dcfInfra.get(FSM_Constants.SERVICERESOURCE_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(str.contains(FSM_Constants.SERVICETERRITORY_R) && allServiceTerritory.containskey(String.ValueOf(dcfInfra.get(FSM_Constants.SERVICETERRITORY_C)))){
                        applyDataType(getServiceTerritoryDetails(allServiceTerritory.get(String.ValueOf(dcfInfra.get(FSM_Constants.SERVICETERRITORY_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(!str.contains(FSM_Constants.WORKORDER_R) && !str.contains(FSM_Constants.SERVICERESOURCE_R) && !str.contains(FSM_Constants.SERVICETERRITORY_R)){
                        applyDataType(String.ValueOf(dcfInfra.get(str)), fieldAndType.get(str), formName, str, false, null);
                    }
            	}
            }
        }
        //If DCF Infra 2 convert data based on field type Added as part of SFI-1204
        if(dcfInfra1 != null && formAndFieldandTypeMap.containsKey(formName)){
            fieldAndType = formAndFieldandTypeMap.get(formName);
            
            for(String str : fieldAndType.keySet()){
                if(!str.contains(dcfLineItemPreFix)){
                    if(str.contains(FSM_Constants.WORKORDER_R) && allWorkOrder.containskey(String.ValueOf(dcfInfra1.get(FSM_Constants.WORKORDER_C)))){
                        applyDataType(getWorkOrderDetails(allWorkOrder.get(String.ValueOf(dcfInfra1.get(FSM_Constants.WORKORDER_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(str.contains(FSM_Constants.SERVICERESOURCE_R) && allResource.containskey(String.ValueOf(dcfInfra1.get(FSM_Constants.SERVICERESOURCE_C)))){
                        applyDataType(getServiceResourceDetails(allResource.get(String.ValueOf(dcfInfra1.get(FSM_Constants.SERVICERESOURCE_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(str.contains(FSM_Constants.SERVICETERRITORY_R) && allServiceTerritory.containskey(String.ValueOf(dcfInfra1.get(FSM_Constants.SERVICETERRITORY_C)))){
                        applyDataType(getServiceTerritoryDetails(allServiceTerritory.get(String.ValueOf(dcfInfra1.get(FSM_Constants.SERVICETERRITORY_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(!str.contains(FSM_Constants.WORKORDER_R) && !str.contains(FSM_Constants.SERVICERESOURCE_R) && !str.contains(FSM_Constants.SERVICETERRITORY_R)){
                        applyDataType(String.ValueOf(dcfInfra1.get(str)), fieldAndType.get(str), formName, str, false, null);
                    }
            	}
            }
        }
        //If DCF Non Infra convert data based on field type
        if(dcfNonInfra != null && formAndFieldandTypeMap.containsKey(dcfNonInfra.RecordType.developername)){
            fieldAndType = formAndFieldandTypeMap.get(dcfNonInfra.RecordType.developername);
            
            for(String str : fieldAndType.keySet()){
                if(!str.contains(dcfLineItemPreFix)){
                    if(str.contains(FSM_Constants.WORKORDER_R) && allWorkOrder.containskey(String.ValueOf(dcfNonInfra.get(FSM_Constants.WORKORDER_C)))){
                        applyDataType(getWorkOrderDetails(allWorkOrder.get(String.ValueOf(dcfNonInfra.get(FSM_Constants.WORKORDER_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(str.contains(FSM_Constants.SERVICERESOURCE_R) && allResource.containskey(String.ValueOf(dcfNonInfra.get(FSM_Constants.SERVICERESOURCE_C)))){
                        applyDataType(getServiceResourceDetails(allResource.get(String.ValueOf(dcfNonInfra.get(FSM_Constants.SERVICERESOURCE_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(str.contains(FSM_Constants.SERVICETERRITORY_R) && allServiceTerritory.containskey(String.ValueOf(dcfNonInfra.get(FSM_Constants.SERVICETERRITORY_C)))){
                        applyDataType(getServiceTerritoryDetails(allServiceTerritory.get(String.ValueOf(dcfNonInfra.get(FSM_Constants.SERVICETERRITORY_C))), str), fieldAndType.get(str), formName, str, false, null);
                    }else if(!str.contains(FSM_Constants.WORKORDER_R) && !str.contains(FSM_Constants.SERVICERESOURCE_R) && !str.contains(FSM_Constants.SERVICETERRITORY_R)){
                        applyDataType(String.ValueOf(dcfNonInfra.get(str)), fieldAndType.get(str), formName, str, false, null);
                    }
                }
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method to get work order record details
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static String getWorkOrderDetails(WorkOrder newWO, String fieldName){
        String actualField = fieldName.remove(FSM_Constants.WORKORDER_R + FSM_Constants.DOT);
        return String.ValueOf(newWO.get(actualField));
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method to get Service resource record details
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static String getServiceResourceDetails(ServiceResource newSR, String fieldName){
        String actualField = fieldName.remove(FSM_Constants.SERVICERESOURCE_R + FSM_Constants.DOT);
        return String.ValueOf(newSR.get(actualField));
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method to get Service Territory record details
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static String getServiceTerritoryDetails(ServiceTerritory newST, String fieldName){
        String actualField = fieldName.remove(FSM_Constants.SERVICETERRITORY_R + FSM_Constants.DOT);
        return String.ValueOf(newST.get(actualField));
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will populate line item parent and child mapping
    @Description : Created as part of user story #SFI-2041
    @Date        : 23-July-2024
    ********************************************************************************************************/ 
    Private static Void populateGrandChildMap(String parentID, String childID){
        allGrandChildId.add(childID);
        if(mapOfParentChildLineItem.containsKey(parentID)){
            mapOfParentChildLineItem.get(parentID).add(childID);
        }else{
            mapOfParentChildLineItem.put(parentID, new List<String>());
            mapOfParentChildLineItem.get(parentID).add(childID);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method convert the data based on custom metadata for DCF Line Item.
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static Void convertDataDCFLineItem(FSM_DCFLineItemInfra__c dcfLineInfra, FSM_InfraDataCaptureLineItem2__c dcfLineInfra1, FSM_DCFLineItemNonInfra__c dcfLineNonInfra){
        Map<String,String> fieldAndType = new Map<String,String>(); //To collect Map between Field and field type
        String fieldApiName; //To get actual field api name
        //If DCF Infra convert data based on field type
        if(dcfLineInfra != null && formAndFieldandTypeMap.containsKey(formName)){
            if(dcfLineInfra.FSM_LineItem__c != null){ //This part is added as part of SFI-2041 by Subir Maji 23rd July 2024
                populateGrandChildMap(dcfLineInfra.FSM_LineItem__c, dcfLineInfra.id);
            }
            fieldAndType = formAndFieldandTypeMap.get(formName);
            for(String str : fieldAndType.keySet()){
                if(str.contains(dcfLineItemPreFix)){
                	fieldApiName = str.removeStart(dcfLineItemPreFix);
                    applyDataType(String.ValueOf(dcfLineInfra.get(fieldApiName)), fieldAndType.get(str), formName, str, true, dcfLineInfra.ID);
                }
            }
        }
        //If DCF Infra 1 convert data based on field type SFI-1204
        if(dcfLineInfra1 != null && formAndFieldandTypeMap.containsKey(formName)){
            if(dcfLineInfra1.FSM_LineItem__c != null){ //This part is added as part of SFI-2041 by Subir Maji 23rd July 2024
                populateGrandChildMap(dcfLineInfra1.FSM_LineItem__c, dcfLineInfra1.id);
            }
            fieldAndType = formAndFieldandTypeMap.get(formName);
            for(String str : fieldAndType.keySet()){
                if(str.contains(dcfLineItemPreFix)){
                	fieldApiName = str.removeStart(dcfLineItemPreFix);
                    applyDataType(String.ValueOf(dcfLineInfra1.get(fieldApiName)), fieldAndType.get(str), formName, str, true, dcfLineInfra1.ID);
                }
            }
        }
        //If DCF Non Infra convert data based on field type
        if(dcfLineNonInfra != null && formAndFieldandTypeMap.containsKey(formName)){
            if(dcfLineNonInfra.FSM_LineItem__c != null){ //This part is added as part of SFI-2041 by Subir Maji 23rd July 2024
                populateGrandChildMap(dcfLineNonInfra.FSM_LineItem__c, dcfLineNonInfra.id);
            }
            fieldAndType = formAndFieldandTypeMap.get(formName);
            for(String str : fieldAndType.keySet()){
                if(str.contains(dcfLineItemPreFix)){
                	fieldApiName = str.removeStart(dcfLineItemPreFix);
                    applyDataType(String.ValueOf(dcfLineNonInfra.get(fieldApiName)), fieldAndType.get(str), formName, str, true, dcfLineNonInfra.ID);
                }
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method apply data type and apply formula.
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static Void applyDataType(String value, String fieldType, String formName, String fieldName, Boolean isChild, String childRecordId){
        Map<String,String> allFieldAndJSONLabel; //To collect the map of Field and Json label
        Map<String,String> allFieldAndNode; //To collect the map of Field and Node
        Map<String,String> allFieldAndFormula; //To collect the map of Field and Formula
        Map<String,String> allFieldAndPlatformField; //To collect the map of Field and PlatformField
        Integer intVal; //To store Integer value
        Decimal decVal; //To store decimal value
        Date dtval; //To store Date value
        Time tiVal; //To store Time value
        DateTime dtTimVal; //To store DateTime value
        fieldHelper = new FieldStructureGenerator();//initiate wrapper
        Date tempDate = system.today();// temporay date for time helper
        String tempStr;// temporay date for time helper
        
        //If field have no value then stop execution for teh field
        if(value == null || value == ''){
            return;
        }
        //Create the Map for Field and JSON Label
        if(formAndFieldAndJSOnLabelMap != null && formAndFieldAndJSOnLabelMap.containsKey(formName)){
            allFieldAndJSONLabel = new Map<String,String>();
            allFieldAndJSONLabel = formAndFieldAndJSOnLabelMap.get(formName);
        }
        
        //Create the Map for Field and Node
        if(formAndFieldAndNodeMap != null && formAndFieldAndNodeMap.containsKey(formName)){
            allFieldAndNode = new Map<String,String>();
            allFieldAndNode = formAndFieldAndNodeMap.get(formName);
        }
        
        //Create the Map for Field and Formula
        if(formAndFieldAndFormulaMap != null && formAndFieldAndFormulaMap.containsKey(formName)){
            allFieldAndFormula = new Map<String,String>();
            allFieldAndFormula = formAndFieldAndFormulaMap.get(formName);
        }
        
        //Create the Map for Field and PlatformField
        if(formAndFieldAndPlatformFieldMap != null && formAndFieldAndPlatformFieldMap.containsKey(formName)){
            allFieldAndPlatformField = new Map<String,String>();
            allFieldAndPlatformField = formAndFieldAndPlatformFieldMap.get(formName);
           // System.debug('fieldvalue---->'+allFieldAndPlatformField);
        }
        
        //Convert data based on field type
        if(fieldType == 'Number' && formName != 'FSM_ReinstatementForm'){
            decVal = Decimal.valueOf(value);
            if(decVal > 2147483647){
            	fieldHelper.decVal = decVal.round();
            }else{
                intVal = Integer.valueOf(decVal);
                fieldHelper.intVal = intVal;
            }
        }else if(fieldType == 'Decimal'){
            decVal = Decimal.valueOf(value);
            if(allFieldAndFormula != null && allFieldAndFormula.containsKey(fieldName)){
                decVal = FSM_DCFJsonGeneratorHelper.applyDecimalFormula(decVal, allFieldAndFormula.get(fieldName));
            }
            fieldHelper.decVal = decVal;
        }else if(fieldType == 'Date'){
            dtval = Date.valueOf(value);
            if(allFieldAndFormula != null && allFieldAndFormula.containsKey(fieldName)){
                dtval = FSM_DCFJsonGeneratorHelper.applyDateFormula(dtval, allFieldAndFormula.get(fieldName));
            }
            fieldHelper.strVal = String.ValueOf(dtval);
        }else if(fieldType == 'Time'){
            if(value.endsWith('Z')){
                tempStr = string.valueOf(tempDate);
                value = tempStr.removeEnd('Z')+' '+value;
            }
            tiVal = Time.newInstance(Datetime.valueOf(value).addHours(1).Hour(), Datetime.valueOf(value).addHours(1).minute(), 0, 0);
        	if(allFieldAndFormula != null && allFieldAndFormula.containsKey(fieldName)){
                tiVal = FSM_DCFJsonGeneratorHelper.applyTimeFormula(tiVal, allFieldAndFormula.get(fieldName));
            }
            fieldHelper.strVal = String.ValueOf(tiVal);
        }else if(fieldType == 'Date/Time'){
            //added as part of SFI-3006 by Srikanth Palla 26nd Nov 24
            Datetime dt = !String.isEmpty(value) ? DateTime.valueOfGmt(value) : null;
            TimeZone tz = UserInfo.getTimeZone();
            dtTimVal = dt != null ? dt.addSeconds(tz.getOffset(dt) / 1000) : null;
        	if(allFieldAndFormula != null && allFieldAndFormula.containsKey(fieldName)){
                dtTimVal = FSM_DCFJsonGeneratorHelper.applyDateTimeFormula(dtTimVal, allFieldAndFormula.get(fieldName));
            }
            fieldHelper.strVal = String.ValueOf(dtTimVal);
        }else{
            if(allFieldAndFormula != null && allFieldAndFormula.containsKey(fieldName)){
                value = FSM_DCFJsonGeneratorHelper.applyStringFormula(value, allFieldAndFormula.get(fieldName));
            }
            fieldHelper.strVal = String.ValueOf(value);
        }
        //Build rest of the wrapper
        fieldWrapperBuild(allFieldAndNode.get(fieldName), allFieldAndPlatformField.get(fieldName), 
                          allFieldAndJSONLabel.get(fieldName), isChild, childRecordId);
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method build the Field Wrapper
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Private static Void fieldWrapperBuild(String node, String platField, String jsonLabel, Boolean isChild, String childRecordId){
        fieldHelper.node = node;
        fieldHelper.platEveFieldname = platField;
        fieldHelper.jsonLabel = jsonLabel;
        fieldHelper.isChild = isChild;
        fieldHelper.childRecordId = childRecordId;
        
        fieldHelperAll.add(fieldHelper);
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This wrapper class will be building the final structure for the field value and node etc..
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Public Class FieldStructureGenerator{  
        Public String  platEveFieldname; //To Store platform event field name
        Public String node; //To store node name
        Public String strVal; //To store String value
        Public Integer intVal; //To store Integer value
        Public Decimal decVal; //To store decimal value
        Public String  jsonLabel;  
        Public Boolean  isChild = false;
        Public String  childRecordId;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This wrapper class will be building the Header Structure for teh DCF platform event
    @Description : Created as part of user story #SFI-547 , updated as a part of SFI-1802
    @Date        : 30-August-2023
 	@Date		 : Updated as part of SFI-2041 by Subir Maji 23rd July 2024
    ********************************************************************************************************/ 
    Public Class PlatformEventHeaderGenerator{  
        Public String AUFNR; //To Store Work Order Number
        Public String VORNR; //To store Work Order Operation Number
        Public String Name; //To store Service resource Name who created the record
        Public String QMNUM; //To store the Work order Notification number
        Public String FormType; //To store the DCF Record Type developer name
        Public Integer SEQNR;//To store the Number of eforms having same formtype
        Public String MEDIUM; //Medium of form generation 
        Public Integer HIERARCHYLEVEL; //Level of Hierarchy based on Parent child and grand child, this part is added as part of SFI-2041 by Subir Maji 23rd July 2024
    }
}
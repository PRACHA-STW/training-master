/********************************************************************************************************
@Author      : Srikanth Palla
@description This class is getting used to Call SAP to send the file via Integration Rest call
@description : Created as part of SFI-1213 By Srikanth 24-Apr-2024
@description : Invoked from FSM_ContentDocumentLinkTriggerHelper class
@Test Class  : FSM_ContentDocLinkTriggerTest
@Date        : 01-April-2024
********************************************************************************************************/
public With Sharing class FSM_SendUploadAttachmentsQueueable implements Queueable, Database.AllowsCallouts{
	Map<Id,Id> contentLinkAndDocumentMap = new Map<Id,Id>(); //Variable to get the record ID's
    Boolean retryFlag; //Variable to flag if a retry is needed in case Attachment Upload fails SFI-2208
    Map<Id,String> contentLinkAndSAPUserID = new Map<Id,Id>(); //Map of Content Doc Link and SAP User id based on assigned resource SFI-2208
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description Created as part of user story #SFI-1213
    @description : this method is the Constructor method for Queueable class.
	@description  Updated As part of SFI-2208 by Asutosh Singh 21st June 24
    @param contentLinkAndDocumentMap
    @Date        : 01-April-2024
    ********************************************************************************************************/
    public FSM_SendUploadAttachmentsQueueable(Map<Id,Id> contentLinkAndDocumentMap, Boolean flag, Map<Id,String> contentLinkAndSAPUserID){
        this.contentLinkAndDocumentMap = contentLinkAndDocumentMap;
        this.retryFlag= flag;
        this.contentLinkAndSAPUserID = contentLinkAndSAPUserID;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description Created as part of user story #SFI-1213
    @description : this method is the execute method of Queueable class.
	@description  Updated As part of SFI-2208 by Asutosh Singh 21st June 24
    @param context
    @Date        : 01-April-2024
    ********************************************************************************************************/
    public void execute(QueueableContext context) {
    	sendUploadAttachments(contentLinkAndDocumentMap, retryFlag, contentLinkAndSAPUserID);  
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description Created as part of user story #SFI-1213
    @description : this method is used make callout and send file.
	@description  Updated As part of SFI-2208 by Asutosh Singh 21st June 24
    @param contentLinkAndDocumentMap, retryFlag, contentLinkAndSAPUserID
    @Date        : 01-April-2024
    ********************************************************************************************************/
    private void sendUploadAttachments(Map<Id,Id> contentLinkAndDocumentMap, Boolean retryFlag, Map<Id,String> contentLinkAndSAPUserID){ 
        List<FSM_ErrorLog__c> errorLogList=new List<FSM_ErrorLog__c>();
        try{
            // variable's to fecth and store sObject values and id's
            Map<id,contentVersion> contentVersionRecords;
            Map<id,ServiceAppointment> allServiceAppointment;
            Map<id,WorkOrder> allWorkOrder;
            Map<id,ContentDocumentLink> contentDocumentLinkRecord;
            Set<id> salinkedEntityId=new Set<Id>();
            Set<id> workorderlinkedEntityId=new Set<Id>();
            Set<Id> allContentDocumentId=new Set<ID>(contentLinkAndDocumentMap.values());
            String accessToken;
            FSM_ErrorLog__c errorLog;
            List<FSM_IntegrationLog__c> intLogList=new List<FSM_IntegrationLog__c>();
            String httpReqBody;
            FSM_IntegrationLog__c intlog;
            FSM_AttachmentUplaodRequest dataBody = new FSM_AttachmentUplaodRequest();
            integer maxHttpCallout=90;
            integer count=0;
            string userId=getCurrentUserInfo();
            
            
            contentDocumentLinkRecord=new Map<id,ContentDocumentLink>(getContentLinks(allContentDocumentId));
                        
            for(ID iterator1: contentLinkAndDocumentMap.keyset()){          
                if(contentDocumentLinkRecord.get(iterator1).linkedEntityId.getSObjectType() == ServiceAppointment.getSObjectType()){
                    salinkedEntityId.add(contentDocumentLinkRecord.get(iterator1).linkedEntityId);
                }
                else if(contentDocumentLinkRecord.get(iterator1).linkedEntityId.getSObjectType() == WorkOrder.getSObjectType()){   
                    workorderlinkedEntityId.add(contentDocumentLinkRecord.get(iterator1).linkedEntityId);
                }
            }
            
            contentVersionRecords=new Map<id,contentVersion>(getContentVersion(allContentDocumentId));
            
            //Fetch serviceAppointment or Workorder based on linkedEntityId
            allServiceAppointment=new Map<id,ServiceAppointment>(getServiceApppointment(salinkedEntityId));
            allWorkOrder=new Map<id,WorkOrder>(getWorkOrder(workorderlinkedEntityId));
            //Fetch Org OAuth information from metadata
            FSM_SapOAuthServiceConfig__mdt config=getConfig();	
            //create request body using RequestData wrapper class
            for(ID iterator : contentLinkAndDocumentMap.keyset()){
                if(contentLinkAndSAPUserID.containsKey(iterator) && contentLinkAndSAPUserID.get(iterator) != null){
                    userId = contentLinkAndSAPUserID.get(iterator);
                }
                // create request data ...
                RequestData data=createRequestData(iterator,contentVersionRecords,contentLinkAndDocumentMap,contentDocumentLinkRecord,allServiceAppointment,allWorkOrder,config,userId);
                
                //Http callout 
                if(maxHttpCallout>count){
                    httpReqBody = dataBody.createReqBody(data);
                    intlog = integrationLogInitiator(httpReqBody.left(32000),data.referenceObject, iterator);
                    HttpResponse res=new Http().send(createHttpRequest(httpReqBody,config));
                    //If Success then create Integration Log with response
                    if(res.getStatusCode() == 200){
                        intlog = responsegenerator(res, intlog);
                        //If received 200 but don't have success message then create error log as well SFI-2208
                        if(intlog.FSM_ResponsePayload__c != null && !intlog.FSM_ResponsePayload__c.contains(System.Label.FSM_INT14SuccessMessage)){
                            errorLog=new FSM_Utility.ErrorLogCreator().setClassName('FSM_SendUploadAttachmentsQueueable').setMethodName('sendUploadAttachments').setErrorMessage(res.getBody()).setLineNumber(iterator).setType('Integration').setRetryFlag(retryFlag).setInterface('INT-014').returnWithoutCreate();
                        	errorLogList.add(errorLog);
                        }
                        count++;
                    }else{ //Create error log if failure
                        errorLog=new FSM_Utility.ErrorLogCreator().setClassName('FSM_SendUploadAttachmentsQueueable').setMethodName('sendUploadAttachments').setErrorMessage(res.getBody()).setLineNumber(iterator).setType('Integration').setRetryFlag(retryFlag).setInterface('INT-014').returnWithoutCreate();
                        errorLogList.add(errorLog);
                    }
                    intLogList.add(intlog);
                }
            }
            if(intLogList.size()>0){
                createIntegrationLog(intLogList); 	              
            }
            
            if(errorLogList.size()>0){
                createErrorLog(errorLogList);	              
            }
        }catch(exception e){
            for(String cdl : contentLinkAndDocumentMap.KeySet()){
            	errorLogList.add(new FSM_Utility.ErrorLogCreator().setClassName('FSM_SendUploadAttachmentsQueueable').setMethodName('sendUploadAttachments').setErrorMessage(e.getMessage()).setLineNumber(cdl).setStackTrace(e.getStackTraceString()).setType('Integration').setInterface('INT-014').returnWithoutCreate());
            }
            createErrorLog(errorLogList);
        }
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description For Error log Creation, Created as part of user story #SFI-1213
    @param errorLogList
    @Date        : 01-April-2024
    ********************************************************************************************************/
    private void createErrorLog( List<FSM_ErrorLog__c> errorLogList){
        if(Schema.sObjectType.FSM_ErrorLog__c.isCreateable())        {
            Insert errorLogList;
        }
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  For Integration log Creation, Created as part of user story #SFI-1213
    @param integrationLogList
    @Date        : 01-April-2024
    ********************************************************************************************************/
    private void createIntegrationLog(List<FSM_IntegrationLog__c> integrationLogList){
        if(Schema.sObjectType.FSM_IntegrationLog__c.isCreateable()){
            Insert integrationLogList;
        }
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description For Creation of Request Data structure, Created as part of user story #SFI-1213
    @param contentVersionRecords contentLinkAndDocumentMap contentDocumentLinkRecord allServiceAppointment allWorkOrder
	@return RequestData
    @Date        : 01-April-2024
    ********************************************************************************************************/
    private RequestData createRequestData(Id iterator,Map<id,contentVersion> contentVersionRecords,Map<id,Id> contentLinkAndDocumentMap,Map<id,ContentDocumentLink> contentDocumentLinkRecord, Map<id,ServiceAppointment> allServiceAppointment,Map<id,WorkOrder> allWorkOrder,FSM_SapOAuthServiceConfig__mdt config,string userId){
        RequestData data=new RequestData();
        data.versionData=contentLinkAndDocumentMap.get(iterator); //Updated as part of SFI-2585, by Subir Maji 5th Aug 24, to reduce heap size
        data.referenceObject=(contentDocumentLinkRecord.get(iterator).linkedEntityId.getSObjectType()==ServiceAppointment.getSObjectType()) ? 
            allServiceAppointment.get(contentDocumentLinkRecord.get(iterator).linkedEntityId).FSSK__FSK_Work_Order__r.FSM_NotificationNumber__c : allWorkOrder.get(contentDocumentLinkRecord.get(iterator).linkedEntityId).FSM_NotificationNumber__c;
        //Updated below to convert to Upper case and take only 3 char from Left for File Extension as part of SFI-2614 14th Aug 24 By Subir Maji
        data.fileType=contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).FileExtension.toUpperCase().left(3);
        data.filePath=contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).Title.contains('.')?contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).Title:contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).Title+'.'+contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).FileExtension;
        data.fileSize=contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).ContentSize;
        data.fileDescription=contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).Title;
        data.fileName=contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).Title;
        
        data.woOperation= allWorkOrder.get(contentDocumentLinkRecord.get(iterator).linkedEntityId)!=NULL ?
            allWorkOrder.get(contentDocumentLinkRecord.get(iterator).linkedEntityId).FSM_OperationNumber__c : allServiceAppointment.get(contentDocumentLinkRecord.get(iterator).linkedEntityId).FSSK__FSK_Work_Order__r.FSM_OperationNumber__c;
        
        data.woNumber= allWorkOrder.get(contentDocumentLinkRecord.get(iterator).linkedEntityId)!=NULL ?  allWorkOrder.get(contentDocumentLinkRecord.get(iterator).linkedEntityId).FSM_OrderNumber__c : 
        allServiceAppointment.get(contentDocumentLinkRecord.get(iterator).linkedEntityId)
            .FSSK__FSK_Work_Order__r.FSM_OrderNumber__c;
        data.vendorNumber=config.FSM_vendorId__c;
        data.versionId=contentVersionRecords.get(contentLinkAndDocumentMap.get(iterator)).ContentDocumentId;
        data.sapUserId=userId!=NULL ? userId :'NoUserId'; //Updated as part of SFI-2614 14th Aug 24 by Subir Maji to Send NoUserId text if SAP Usre id not present in the user record in SF side.
        return data;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description Based on the request initiate Integration Log, Created as part of user story #SFI-1213
    @param reqBody extID recordID
	@return FSM_IntegrationLog__c
    @Date        : 01-April-2024
    ********************************************************************************************************/
    private FSM_IntegrationLog__c integrationLogInitiator(String reqBody, String extID, String recordID){
        return new FSM_Utility.IntegrationLogCreator().setServiceName(FSM_Constants.FILEUPLOAD_SERVCIE).setReqPayload(reqBody).setExternalId(extID).setRecordId(recordID).returnWithoutCreate();
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  Process The response and update Integration Log, Created as part of user story #SFI-1213
    @param res log
	@return FSM_IntegrationLog__c
    @Date        : 01-April-2024
    ********************************************************************************************************/
    private FSM_IntegrationLog__c responsegenerator(HttpResponse res, FSM_IntegrationLog__c log){
        // Parse the XML response
        Dom.Document doc = new Dom.Document();  
        doc.load(res.getBody());
        
        Dom.XmlNode rootElement = doc.getRootElement();
        // Get the Document element
        Dom.XmlNode documentElement = rootElement.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
            .getChildElement('DocumentERPCreateConfirmation_sync_V1', 'http://sap.com/xi/SAPGlobal20/Global')
            .getChildElement('Document', null);
        
        String logNote = rootElement.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
            .getChildElement('DocumentERPCreateConfirmation_sync_V1', 'http://sap.com/xi/SAPGlobal20/Global')
            .getChildElement('Log', null)
            .getChildElement('Item', null)
            .getChildElement('Note', null).getText();
        
        log.FSM_ResponsePayload__c = logNote;
        return log;
     }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description For Sending the HTTP Request, Created as part of user story #SFI-1213
    @param allHttpReqBody
	@return HttpRequest config
    @Date        : 01-April-2024
    ********************************************************************************************************/
    private HttpRequest createHttpRequest(String allHttpReqBody,FSM_SapOAuthServiceConfig__mdt config){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(config.FSM_NamedCredential__c);
        req.setHeader('Content-Type', 'application/xml');
        req.setBody(allHttpReqBody);
        req.setTimeout(120000);
        req.setMethod(FSM_Constants.RESTMETHODPOST);
        return req;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description This method is to fetch contentVersion record, Created as part of user story #SFI-1213
    @param allContentDocId
    @Date        : 01-April-2024
	@return Map<id ,ContentVersion>
    ********************************************************************************************************/
    private Map<id ,ContentVersion> getContentVersion(Set<id> allContentDocId){
        Map<Id ,ContentVersion> contentversionRecords=new Map<Id ,ContentVersion>(); 
        //Updated as part of SFI-2585, by Subir Maji 5th Aug 24, to reduce heap size to remove VersionData from Query
        for(ContentVersion iterator : [SELECT Id, Title, PathOnClient, FileType, Description, ContentSize, FileExtension, ContentDocumentId 
                                       FROM ContentVersion 
                                       WHERE ContentDocumentId IN :allContentDocId WITH SECURITY_ENFORCED]){
        	contentversionRecords.put(iterator.ContentDocumentId,iterator);
        }
        return contentversionRecords;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch Content Document link record, Created as part of user story #SFI-1213
    @param allContentDocumentId
    @Date        : 01-April-2024
	@return Map<id ,ContentDocumentLink>
    ********************************************************************************************************/
    private Map<id ,ContentDocumentLink> getContentLinks(Set<Id> allContentDocumentId){
        Map<id ,ContentDocumentLink> contentLinkRecords= new Map<id ,ContentDocumentLink>([SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId  IN : allContentDocumentId WITH SECURITY_ENFORCED]);
        return contentLinkRecords;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch ServiceAppointment record, Created as part of user story #SFI-1213
    @param allSaLinkedEntityId
    @Date        : 01-April-2024
	@return Map<id ,ServiceAppointment>
    ********************************************************************************************************/
    private Map<id ,ServiceAppointment> getServiceApppointment(Set<Id> allSaLinkedEntityId){
        Map<id ,ServiceAppointment> saRecords= new  Map<id ,ServiceAppointment>([SELECT id,FSSK__FSK_Work_Order__r.FSM_OperationNumber__c,FSSK__FSK_Work_Order__r.FSM_NotificationNumber__c,FSSK__FSK_Work_Order__r.FSM_OrderNumber__c,FSSK__FSK_Work_Order__r.Case.FSM_ExternalId__c from ServiceAppointment WHERE Id IN : allSaLinkedEntityId WITH SECURITY_ENFORCED]);
        return saRecords;
    }
    
   /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch WorkOrder record, Created as part of user story #SFI-1213
    @param allWoLinkedEntityId
    @Date        : 01-April-2024
	@return Map<id ,WorkOrder>
    ********************************************************************************************************/
    private Map<id ,WorkOrder>  getWorkOrder(Set<Id> allWoLinkedEntityId){
        Map<id ,WorkOrder> woRecords= new Map<id ,Workorder>([SELECT id,Case.FSM_ExternalId__c,FSM_OperationNumber__c,FSM_OrderNumber__c,FSM_NotificationNumber__c from WorkOrder WHERE Id IN : allWoLinkedEntityId WITH SECURITY_ENFORCED]);
        return woRecords;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch Config details for Named cred based on org type, Created as part of user story #SFI-1213
    @param 
    @Date        : 01-April-2024
	@return FSM_SapOAuthServiceConfig__mdt
    ********************************************************************************************************/
    private FSM_SapOAuthServiceConfig__mdt getConfig(){
        FSM_SapOAuthServiceConfig__mdt config;
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();
        String configName = sfdcBaseURL.substringBetween('--','.sandbox');
        
        if(!sfdcBaseURL.contains('.sandbox')){
            config=FSM_SapOAuthServiceConfig__mdt.getInstance('PROD');
        }else{
            config=FSM_SapOAuthServiceConfig__mdt.getInstance(configName);
        }       
        return config;
    }

	/********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch current user and send back user external id, Created as part of user story #SFI-1213
    @param 
    @Date        : 01-April-2024
	@return String
    ********************************************************************************************************/
    private string getCurrentUserInfo(){
        User currentUser =[SELECT Id,FSM_ExternalId__c from User WHERE Id=:UserInfo.getUserId()];
        return currentUser.FSM_ExternalId__c;
    }    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This wrapper class is used to create request, Created as part of user story #SFI-1213
    @Date        : 01-April-2024
	********************************************************************************************************/
    public class RequestData{
        public String versionData;
        public String referenceObject;
        public String fileType;
        public String filePath;
        public String fileDescription;
        public String fileName;
        public String woNumber;
        public String woOperation;
        public Integer fileSize;
        public String vendorNumber;
        public String versionId;
        public String sapUserId;
    }
}
/********************************************************************************************************
@Author      : Srikanth Palla
@description This class is getting used to make Callout to SAP to get Job History
@description : Created as part of SFI-1866
@description : Invoked from datretrievalComp 
@Test Class  : FSM_JobHistoryRetrieveTest
@Date        : 02-July-2024
********************************************************************************************************/
public with sharing class FSM_JobHistoryRetrieve {
    
    /********************************************************************************************************
    @description  This method is to make call to SAP and get Job history, Created as part of user story #SFI-1886
    @param postCode
    @param dma
    @param drainageArea
    @param floc
    @param orderType
    @Date        : 02-July-2024
	@return List<WorkOrderInfo>
    ********************************************************************************************************/
    @auraEnabled
    public static List<WorkOrderInfo> getWorkOrderReport(String postCode, String dma, String drainageArea, String floc, String orderType) {
        List<WorkOrderInfo> workOrders = new List<WorkOrderInfo>();
        String finalURL=buildDynamicUrl(postCode,dma,drainageArea,floc,orderType);
        
        try{
            HttpRequest req = new HttpRequest();
            FSM_SapOAuthServiceConfig__mdt config=getConfig();
            req.setEndpoint(config.FSM_NamedCredentialINT15__c+Label.FSM_INT17Vesion+finalURL);
            req.setHeader('Content-Type', 'application/xml');
            req.setMethod('GET');
            req.setTimeout(120000);
            http instance =new http();
            HttpResponse res=instance.send(req);
            
            
            if (res.getStatusCode() == FSM_Constants.RESPONSE_200) {
                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
                Dom.XmlNode root = doc.getRootElement();
                List<Dom.XmlNode> entries = root.getChildElements();
                for (Dom.XmlNode entry : entries) {
                    WorkOrderInfo wo = new WorkOrderInfo();
                    Dom.XmlNode content = getContentElement(entry);
                    if (content != null) {
                        Dom.XmlNode properties = content.getChildElement('properties', 'http://schemas.microsoft.com/ado/2007/08/dataservices/metadata');
                        if (properties != null) {
                            string modifiedDate=convertToBST(getPropertyText(properties, 'ModifiedOn'));
                           wo.modifiedOn=modifiedDate;
                            wo.workOrderId = getPropertyText(properties, 'WorkOrderId');
                            wo.serviceNotificationId = getPropertyText(properties, 'ServiceNotificationId');
                            wo.formattedAddress = getPropertyText(properties, 'FormattedAddress');
                            string createdDate=convertToBST(getPropertyText(properties, 'CreatedOn'));
                           wo.createdOn = createdDate;
                            wo.codeText = getPropertyText(properties, 'CodeText');
                            
                            workOrders.add(wo);
                        }
                    } 
                }
                new FSM_Utility.IntegrationLogCreator().setReqPayload(req.getEndpoint()).setResPayload(res.getbody().left(32000)).setServiceName('Job History WorkOrderReports').create();
                
            }
            else{
                new FSM_Utility.ErrorLogCreator().setClassName('FSM_JobHistoryRetrieve').setMethodName('getWorkOrderReport')
                    .setErrorMessage(res.getBody()).setType('Integration').create();
            }
        }
        catch(Exception e){
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_JobHistoryRetrieve').setMethodName('getWorkOrderReport').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Integration').create();
        }
        return workOrders;
    }
    
    /********************************************************************************************************
    @description  This Helper method to get 'content' element under 'entry', Created as part of user story #SFI-1886
    @param entry
    @Date : 02-July-2024
	@return Dom.XmlNode 
    ********************************************************************************************************/
    private static Dom.XmlNode getContentElement(Dom.XmlNode entry) {
        for (Dom.XmlNode child : entry.getChildElements()) {
            if (child.getName() == 'content' && child.getNamespace() == 'http://www.w3.org/2005/Atom') {
                return child;
            }
        }
        return null;
    }
    
    /********************************************************************************************************
    @description  This Helper method to get text of a property under 'm:properties', Created as part of user story #SFI-1886
    @param properties
    @param propertyName
    @Date : 02-July-2024
	@return String 
    ********************************************************************************************************/
    private static String getPropertyText(Dom.XmlNode properties, String propertyName) {
        Dom.XmlNode property = properties.getChildElement(propertyName, 'http://schemas.microsoft.com/ado/2007/08/dataservices');
        if (property != null) {
            return property.getText();
        }
        return null;
    }
    
    /********************************************************************************************************
    @description  This class used to Handle XML response from Callout, Created as part of user story #SFI-1886
    @Date : 02-July-2024
	@return String 
    ********************************************************************************************************/
    public class WorkOrderInfo {
        @AuraEnabled public String modifiedOn;
        @AuraEnabled public String workOrderId;
        @AuraEnabled public String serviceNotificationId;
        @AuraEnabled public String formattedAddress;
        @AuraEnabled public String createdOn;
        @AuraEnabled public String codeText;
    }
    
     /********************************************************************************************************
    @description  This method is to make call to SAP and get Notifiaction Long Text, Created as part of user story #SFI-1886
    @param notificationNumber
    @Date : 02-July-2024
	@return string
    ********************************************************************************************************/
    @auraEnabled
    public static string getNotificationLongText(String notificationNumber) {
        String notesValue;
        try{
            HttpRequest req = new HttpRequest();
            FSM_SapOAuthServiceConfig__mdt config=getConfig();
            
            req.setEndpoint(config.FSM_NamedCredentialINT15__c+Label.FSM_INT17Vesion+'/ZWFM_CUSTOMER_MGMT_SRV/ServiceNotificationSet(\'' + notificationNumber + '\')');
            req.setHeader('Content-Type', 'application/xml');
            req.setMethod('GET');
            req.setTimeout(120000);
            http instance =new http();
            HttpResponse res=instance.send(req);
            if (res.getStatusCode() == FSM_Constants.RESPONSE_200) {
                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
                Dom.XmlNode root = doc.getRootElement();
                Dom.XmlNode content = root.getChildElement('content', 'http://www.w3.org/2005/Atom');
                if (content != null) {
                    Dom.XmlNode properties = content.getChildElement('properties', 'http://schemas.microsoft.com/ado/2007/08/dataservices/metadata');
                    if (properties != null) {
                        Dom.XmlNode notesNode = properties.getChildElement('Notes', 'http://schemas.microsoft.com/ado/2007/08/dataservices');
                        if (notesNode != null) {
                            notesValue = notesNode.getText().trim();
                            
                        }
                    } 
                } 
                new FSM_Utility.IntegrationLogCreator().setReqPayload(req.getEndpoint()).setResPayload(res.getbody().left(32000)).setServiceName('Job History Notification LongText').create();
            }
            else{
                
                new FSM_Utility.ErrorLogCreator().setClassName('FSM_JobHistoryRetrieve').setMethodName('getNotificationLongText')
                    .setErrorMessage(res.getBody()).setType('Integration').create();
            }
        }
        catch(Exception e){
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_JobHistoryRetrieve').setMethodName('getNotificationLongText').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Integration').create();
        }
        return notesValue;
    }
    
    /********************************************************************************************************
    @Description : this method is for metadata interface toggle
    @Description : Created as part of user story #SFI-1886
    @return		 : FSM_InterfaceToggle__mdt
    @Date        : 02-July-2024
    ********************************************************************************************************/
    @AuraEnabled
    public static FSM_InterfaceToggle__mdt checkToggle(){
        FSM_InterfaceToggle__mdt toggle=FSM_InterfaceToggle__mdt.getInstance('FSM_WorkHistorySearch');
        return toggle;
    }
    
   
    /********************************************************************************************************
    @description  This method Used to built Runtime URL based on User input, Created as part of user story #SFI-1886
    @param postCode
    @param dma
    @param drainageArea
    @param floc
    @param orderType
    @Date: 02-July-2024
	@return String
    ********************************************************************************************************/
    public static String buildDynamicUrl(String postCode, String dma, String drainageArea, String floc, String orderType) {
        string postCodeVal;
        Date today = Date.today();
        String formattedDate = String.valueOf(today)+'T00:00:00.000Z';
        Date twoYearsAgo = today.addYears(-2);
        String formattedDate1 = String.valueOf(twoYearsAgo) +'T23:00:00.000Z';
        if(string.isNotBlank(postCode)){
            postCodeVal=postCode.replace(' ', '%20');
        }
        String baseUrlPrefix = '/ZWFM_CUSTOMER_MGMT_SRV/WorkOrderReportSet?$filter=((Completed%20eq%20true)%20or%20(Inprocess%20eq%20true))%20and%20';
        String baseUrlSufix='%20and%20GroupBy%20eq%20%27WorkOrderId%27&$top=10&$skip=0&$select=WorkOrderId,ServiceNotificationId,FormattedAddress,CreatedOn,ModifiedOn,CodeText&$inlinecount=allpages&$orderby=CreatedOn%20desc';        
        List<String> filterParams = new List<String>();
        if (postCodeVal != null && string.isNotBlank(postCodeVal)) {
            filterParams.add('(Address/Postcode%20eq%20\'' + postCodeVal + '\')');
        }
        if ((orderType != null && string.isNotBlank(orderType)) && orderType!='None' ) {
            filterParams.add('(OrderType%20eq%20\'' + orderType + '\')');
        }
        if (floc != null && string.isNotBlank(floc)) {
            filterParams.add('(FlocId%20eq%20\'' + floc + '\')');
        }
        if (dma != null && string.isNotBlank(dma)) {
            filterParams.add('(DmaId%20eq\'' + dma + '\')');
        }
        if (drainageArea != null && string.isNotBlank(drainageArea)) {
            filterParams.add('(DrainageArea%20eq\'' + drainageArea + '\')');
        }
        filterParams.add('(ReferenceDate%20ge%20datetimeoffset\'' + formattedDate1 + '\')');
        filterParams.add('(ReferenceDate%20lt%20datetimeoffset\'' + formattedDate + '\')');
        String filterString = String.join(filterParams, '%20and%20');
        String finalUrl = baseUrlPrefix + filterString + baseUrlSufix;
        	
        return finalUrl;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch Config details for Named cred based on org type, Created as part of user story #SFI-1886
    @Date        : 02-July-2024
    @return FSM_SapOAuthServiceConfig__mdt
    ********************************************************************************************************/
    private static FSM_SapOAuthServiceConfig__mdt getConfig(){
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
    @description  This method is to convert DateTime to BST, Created as part of user story #SFI-2564
    @Date        : 01-Aug-2024
    @return String
    ********************************************************************************************************/
    public static String convertToBST(String isoDateStr) { 
        
        Datetime dt = !String.isEmpty(isoDateStr) ? DateTime.valueOfGmt(isoDateStr.replace('T',' ')) : null;
        TimeZone tz = UserInfo.getTimeZone();
        String dtBST = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', String.valueof(tz));
        return dtBST;    
    }
      
}
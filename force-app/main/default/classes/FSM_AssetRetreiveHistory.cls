/**********************************************************************************************************
@Author      : Manish Jagnani/Srikanth
@Description : This Class is going to deserialize the callout response for asset data history
@Description : Created as part of user story #SFI-1811,SFI-2161
@Test Class  : FSM_AssetRetreiveHistrory_Test
@Date        : 23-May-2024
********************************************************************************************************/
public with sharing Class FSM_AssetRetreiveHistory{  
    /***************************************************************************************************
    * @description : To get wo deatils from current record page
    * @description : Created as part of user story #SFI-1811
    * @param : recordId
    * @return : workOrder
    * @Date        : 07-June-2024
    *******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static WorkOrder getWorkOrderRecord(Id recordId){
        WorkOrder wo = new WorkOrder();
        ServiceAppointment sa=[select id,ParentRecordId from ServiceAppointment where Id=:recordId WITH SECURITY_ENFORCED];
        if (sa != null && sa.ParentRecordId != null) {
         wo=[select id,PostalCode,FSM_DMADA__c,FSM_Floc__c from workorder where id=:sa.ParentRecordId WITH SECURITY_ENFORCED];
        }
        return wo;
    }
    
    /********************************************************************************************************
    @Author      : Manish Jagnani
    @Description : this method is for metadata interface toggle
    @Description : Created as part of user story #SFI-1811
    @return      : boolean
    @Date        : 07-June-2024
    ********************************************************************************************************/    
    @AuraEnabled
    public static boolean checkToggle(){
        FSM_InterfaceToggle__mdt toggle=FSM_InterfaceToggle__mdt.getInstance('FSM_AssetSearch');
        return toggle.Active__c;
    }
   
    /********************************************************************************************************
    @Author      : Srikanth Palla/Manish
    @description  This method is to make Level4 callout, Created as part of user story #SFI-2161
    @param floc
    @param description
    @Date        : 22-June-2024
    @return List<FlocInputs>
    ********************************************************************************************************/
    @auraenabled
    public static List<FlocInputs> level4Callout(String floc,String description){
       Map<String, String> streamMap = new Map<String, String>();
        try{
            HttpRequest req = new HttpRequest();
            FSM_SapOAuthServiceConfig__mdt config=getConfig();
             if ((description != null && string.isNotBlank(description))) {
                req.setEndpoint(config.FSM_NamedCredentialINT15__c+Label.FSM_INT15Version+'/ZWFM_OP_RISK_MGMT/StreamCollection?$filter=startswith(StageId,\'' + floc + '\')%20and%20substringof(\'' + EncodingUtil.urlEncode(description, 'UTF-8')+ '\',StreamDesc)'+'&$top=50&$skip=0&$inlinecount=allpages');
            }
                else{
                 req.setEndpoint(config.FSM_NamedCredentialINT15__c+Label.FSM_INT15Version+'/ZWFM_OP_RISK_MGMT/StreamCollection?$filter=startswith(StageId,\'' + floc + '\')'+'&$top=50&$skip=0&$inlinecount=allpages'); 
                }   
            req.setHeader('Content-Type', 'application/xml');
            req.setMethod('GET');
            req.setTimeout(120000);
            http instance =new http();
            HttpResponse res=instance.send(req);    
            if (res.getStatusCode() == FSM_Constants.RESPONSE_200) {
                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());    
                for (Dom.XmlNode entry : doc.getRootElement().getChildElements()) {
                    if (entry.getName() != 'entry') continue;       
                    String streamId = '';
                    String streamDesc = '';       
                    for (Dom.XmlNode contentNode : entry.getChildElements()) {
                        if (contentNode.getName() == 'content'){
                            for (Dom.XmlNode propertiesNode : contentNode.getChildElements()) {
                                if (propertiesNode.getName() == 'properties') {
                                    for (Dom.XmlNode property : propertiesNode.getChildElements()) {
                                        String propertyName = property.getName();
                                        String propertyValue = property.getText();                            
                                        if (propertyName == 'StreamId') {
                                            streamId = propertyValue;
                                        } else if (propertyName == 'StreamDesc') {
                                            streamDesc = propertyValue;
                                        }
                                    }
                                    streamMap.put(streamId, streamDesc);
                                }
                            }
                        }
                    }
                }
                new FSM_Utility.IntegrationLogCreator().setReqPayload(req.getEndpoint()).setResPayload(res.getbody().left(32000)).setServiceName('Asset Hierarchy Level4').create();
            } 
            else{
                new FSM_Utility.ErrorLogCreator().setClassName('FSM_AssetRetreiveHistrory').setMethodName('level4Callout')
                    .setErrorMessage(res.getBody()).setType('Integration').create();
            }
        }
        catch(Exception e){
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_AssetRetreiveHistrory').setMethodName('level4Callout').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Integration').create();
        }
        
        List<FlocInputs> allFlocinputs=new List<FlocInputs>();
        for(String iterator:streamMap.keySet()){
            FlocInputs singleRecord=new FlocInputs();
            singleRecord.streamId=iterator;
            singleRecord.flocDesp=streamMap.get(iterator);
            allFlocinputs.add(singleRecord);
        }
        return allFlocinputs;
    }

    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to make Level6 callout, Created as part of user story #SFI-2161
    @param floc
    @param SubUnitDesc
    @Date        : 22-June-2024
    @return List<FlocLevelSix>
    ********************************************************************************************************/
    @auraEnabled
    public static List<FlocLevelSix> level6Callout(String floc,String SubUnitDesc){
        Map<String, String> streamMap = new Map<String, String>();
        try{
            HttpRequest req = new HttpRequest();
            FSM_SapOAuthServiceConfig__mdt config=getConfig();  
             if ((SubUnitDesc != null && string.isNotBlank(SubUnitDesc))) {
            //     req.setEndpoint(config.FSM_NamedCredentialINT15__c+Label.FSM_INT15Version+'/ZWFM_OP_RISK_MGMT/SubUnitCollection?$filter=startswith(UnitId,\''+floc+'\')%20and%20substringof(\''+SubUnitDesc+'\',SubUnitDesc)'+'&$top=50&$skip=0&$inlinecount=allpages');
            //     }
            req.setEndpoint(config.FSM_NamedCredentialINT15__c+Label.FSM_INT15Version+'/ZWFM_OP_RISK_MGMT/SubUnitCollection?$filter=startswith(UnitId,\''+floc+'\')%20and%20substringof(\''+EncodingUtil.urlEncode(SubUnitDesc, 'UTF-8')+'\',SubUnitDesc)'+'&$top=50&$skip=0&$inlinecount=allpages');
             }
                else{
               req.setEndpoint(config.FSM_NamedCredentialINT15__c+Label.FSM_INT15Version+'/ZWFM_OP_RISK_MGMT/SubUnitCollection?$filter=startswith(UnitId,\''+floc+'\')'+'&$top=50&$skip=0&$inlinecount=allpages');
    
                }
            req.setHeader('Content-Type', 'application/xml');
            req.setTimeout(120000);
            req.setMethod('GET');
            http instance =new http();
            HttpResponse res=instance.send(req);
            if (res.getStatusCode() == FSM_Constants.RESPONSE_200) {
                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());           
                for (Dom.XmlNode entry : doc.getRootElement().getChildElements()) {
                    if (entry.getName() != 'entry') continue;                            
                    String streamId = '';
                    String streamDesc = '';                           
                    for (Dom.XmlNode contentNode : entry.getChildElements()) {                              
                        if (contentNode.getName() == 'content'){
                            for (Dom.XmlNode propertiesNode : contentNode.getChildElements()) {
                                if (propertiesNode.getName() == 'properties') {
                                    for (Dom.XmlNode property : propertiesNode.getChildElements()) {
                                        String propertyName = property.getName();
                                        String propertyValue = property.getText();                                                
                                        if (propertyName == 'SubUnitId') {
                                            streamId = propertyValue;
                                        } else if (propertyName == 'SubUnitDesc') {
                                            streamDesc = propertyValue;
                                        }
                                    }
                                    streamMap.put(streamId, streamDesc);                                           
                                }
                            }    
                        }
                    }                            
                }
                new FSM_Utility.IntegrationLogCreator().setReqPayload(req.getEndpoint()).setResPayload(res.getbody().left(32000)).setServiceName('Asset Hierarchy Level6').create();
            }else{
                new FSM_Utility.ErrorLogCreator().setClassName('FSM_AssetRetreiveHistrory').setMethodName('level6Callout')
                    .setErrorMessage(res.getBody()).setType('Integration').create();
            }
        }
        catch(Exception e){
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_AssetRetreiveHistrory').setMethodName('level6Callout').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Integration').create();  
        }
        List<FlocLevelSix> allFlocLevelSix=new List<FlocLevelSix>();
        for(String iterator:streamMap.keySet()){
            FlocLevelSix singleRecord=new FlocLevelSix();
            singleRecord.subUnitId=iterator;
            singleRecord.subUnitDesc=streamMap.get(iterator);
            allFlocLevelSix.add(singleRecord);
        }
        return allFlocLevelSix;
    }
    
    public class FlocInputs{
        @auraEnabled
        public String streamId;
        @auraEnabled
        public String flocDesp;
    }
    
    public class FlocLevelSix{
        @auraEnabled
        public String subUnitId;
        @auraEnabled
        public String subUnitDesc;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch Config details for Named cred based on org type, Created as part of user story #SFI-2161
    @Date        : 22-June-2024
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
}
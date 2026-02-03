/********************************************************************************************************
@Author      : Deepak Moudekar
@Description : This class is used to perform WorkOrder update when Case is updated.
@Description : Created as part of user story #SFI-24
@Description : Invoked from FSM_ContentVersionTriggerHandler class
@Test Class  : FSM_ContentVersionTriggerHandlerTest
@Date        : 13-June-2023
********************************************************************************************************/
public with sharing class FSM_ContentVersionTriggerHelper {
    
    /********************************************************************************************************
    @Author      : Deepak Moudekar
    @Description : This method is to update content version source field
    @Description : Created as part of user story #SFI-24
    @Description : Invoked from FSM_ContentVersionTriggerHandler class
    @Date        : 13-June-2023
    ********************************************************************************************************/
    public static void updateContentVersionSource(List<sObject> newList){
         Map<Id,String> userIdProfileNameMap = new Map<Id,String>();
         Set<String> ownerIds = new Set<String>();
        
         String profileNames = Label.FSM_SystemAdminProfile;
         List<String> profileNameList = profileNames.split(',');
         Set<String> setProfileName = new Set<String>(profileNameList);
        
         for(ContentVersion conv :(List<ContentVersion>) newList){
             ownerIds.add(conv.OwnerId);
         }
        
         for(User usr : [Select Id,FSM_ProfileName__c from User where Id IN : ownerIds WITH SECURITY_ENFORCED]){
            userIdProfileNameMap.put(usr.Id, usr.FSM_ProfileName__c);             
         }
        
         for(ContentVersion conv :(List<ContentVersion>) newList){
             if(userIdProfileNameMap.containsKey(conv.OwnerId)){
                 conv.FSM_Source__c = setProfileName.contains(userIdProfileNameMap.get(conv.OwnerId)) ? 'SAP':'Salesforce';

         }
    }
    }
    public static void attachcontentversiontorecord(Map<Id, sObject> newMap){
        List<ContentDocumentLink>clist=new List<ContentDocumentLink>();
        Map<Id,ContentVersion> cversion = (Map<Id,ContentVersion>)newMap;
        for(ContentVersion cv : cversion.values()) 
        { 
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = cv.FSM_RelatedrecordId__c;
            cdl.ShareType = 'I'; 
            cdl.Visibility = 'AllUsers'; 
            
        
         	clist.add(cdl);
             
        }

        try {
            if(Schema.sObjectType.ContentVersion.isCreateable()){
                insert clist;
            }
            
        } catch(DMLException e) {
            System.debug('error'+e);
            
        }
       
        
        

    } 
    
   
}
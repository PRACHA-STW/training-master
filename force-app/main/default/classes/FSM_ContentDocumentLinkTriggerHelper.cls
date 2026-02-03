/********************************************************************************************************
@Author      : Aishwarya Bhosale
@description This class is used to perform ContentDocumentLink ShareType and 
Visibility fields so that community users are able to view files attached in files section.
Also this class is getting used to Call SAP to send the file via Integration Rest call
@description : Created as part of user story #SFS-3017
Updated as part of SFI-1213 By Srikanth 24-Apr-2024
@description : Invoked from FSM_ContentDocumentLinkTriggerHandler class
@Test Class  : FSM_ContentDocLinkTriggerTest
@Date        : 10-Nov-2023
********************************************************************************************************/
public with sharing class FSM_ContentDocumentLinkTriggerHelper {
    
    /********************************************************************************************************
    @Author      : Aishwarya Bhosale
    @description This will update the CDL details on before record creation, Created as part of user story #SFS-3017
    @param 		 newList
    @Date        : 10-Nov-2023
    ********************************************************************************************************/
    public static void updateContentDocumentLink(List<sObject> newList){
        for(ContentDocumentLink cdl :(List<ContentDocumentLink>) newList){
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
        }
    } 
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description This get called from Handler class, this method is used to if Toggle is on to send files,Created as part of user story #SFI-1213
    @description This get called from Scheduler class, this method is used to if Toggle is on to send files also sends value for the retry flag,Updated as part of user story #SFI-2208
    @param newMap
	@param retrtyFlag
    @Date        : 01-April-2024
	@Update	: Updated by Asutosh Singh 25-June-2024 SFI-2208
    ********************************************************************************************************/
    public static void sendContentVersionToggleCheck(Map<Id, sObject> newMap, Boolean retryFlag){ 
        FSM_InterfaceToggle__mdt toggle = FSM_InterfaceToggle__mdt.getInstance('FSM_SendFileEvent');
        if(toggle!= null && toggle.Active__c){
            sendContentVersion(newMap, retryFlag);
        }
    }

    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description This get called from Handler class, this method is used to call the Queueable class,Created as part of user story #SFI-1213
	@description  Updated As part of SFI-2208 by Asutosh Singh 21st June 24    
	@param newMap
    @Date        : 01-April-2024
    ********************************************************************************************************/
    private static void sendContentVersion(Map<Id, sObject> newMap, Boolean flag){ 
        Map<id,ServiceAppointment> allServiceAppointment;
        Map<id,WorkOrder> allWorkOrder;
        Set<id> salinkedEntityId = new Set<Id>();
        Set<id> workorderlinkedEntityId = new Set<Id>();
        Map<Id,ContentDocumentLink> cdlMap = (Map<Id,ContentDocumentLink>)newMap; //To collect teh created records
        Map<Id,Id> contentLinkAndDocumentMap = new Map<Id,Id>(); //Map of Content Doc Link and Contente Doc ID
        Map<Id,String> contentLinkAndSAPUserID = new Map<Id,String>(); //Map of Content Doc Link and SAP User id based on assigned resource SFI-2208
        Map<Id,contentVersion> cvMap=new Map<Id,contentVersion>();
        Map<ID,ContentVersion> contDocAndContVerMap;
        String linkedEntityPrefix;
        String sapuserId=getCurrentUserId();
        ID jobID;
        ContentVersion contVer;
        
        //Prepare the Map of Content Doc Link and Contente Doc ID
        for(ContentDocumentLink cdl : cdlMap.values()){ 
            if(cdl.linkedEntityId.getSObjectType() == ServiceAppointment.getSObjectType()){
                salinkedEntityId.add(cdl.linkedEntityId);
                contentLinkAndDocumentMap.put(cdl.Id,cdl.ContentDocumentId);
            }
            else if(cdl.linkedEntityId.getSObjectType() == WorkOrder.getSObjectType()){   
                workorderlinkedEntityId.add(cdl.linkedEntityId);
                contentLinkAndDocumentMap.put(cdl.Id,cdl.ContentDocumentId);
            }
        }
        
        if(!contentLinkAndDocumentMap.isEmpty()){
            contDocAndContVerMap = getContentVersion(contentLinkAndDocumentMap);
            allServiceAppointment = getServiceApppointment(salinkedEntityId);
            allWorkOrder = getWorkOrder(workorderlinkedEntityId);
        }
        
        if(contDocAndContVerMap != null && !contDocAndContVerMap.isEmpty()){
            for (ID cdlID : contentLinkAndDocumentMap.KeySet()) {
                contVer = contDocAndContVerMap.get(contentLinkAndDocumentMap.get(cdlID));
                if(cdlMap.get(cdlID).linkedEntityId.getSObjectType() == ServiceAppointment.getSObjectType()){
                    linkedEntityPrefix = allServiceAppointment.get(cdlMap.get(cdlID).linkedEntityId).AppointmentNumber;
                    contentLinkAndSAPUserID.put(cdlID, sapuserId);
                    //collect SAP user id for the CDL SFI-2208
                    //commenting the below lines as part of SFL-307
                   /* if(allServiceAppointment.get(cdlMap.get(cdlID).linkedEntityId).FSM_ServiceResourceSAPUserID__c != null){
                    	contentLinkAndSAPUserID.put(cdlID, allServiceAppointment.get(cdlMap.get(cdlID).linkedEntityId).FSM_ServiceResourceSAPUserID__c);
                    }*/
                }else{
                    linkedEntityPrefix = allWorkOrder.get(cdlMap.get(cdlID).linkedEntityId).WorkOrderNumber;
                    contentLinkAndSAPUserID.put(cdlID, sapuserId);
                    //collect SAP user id for the CDL SFI-2208
                    //commenting the below lines as part of SFL-307
                   /* if(allWorkOrder.get(cdlMap.get(cdlID).linkedEntityId).ServiceAppointments[0].FSM_ServiceResourceSAPUserID__c != null){
                    	contentLinkAndSAPUserID.put(cdlID, allWorkOrder.get(cdlMap.get(cdlID).linkedEntityId).ServiceAppointments[0].FSM_ServiceResourceSAPUserID__c);
                    }*/
                }
                
                //If this is a service report or Do not send checkbox is checked then remove from map
                if((linkedEntityPrefix!= null && contVer.Title.startsWith(linkedEntityPrefix + '_V')) || contVer.FSM_Do_not_send_to_SAP__c){
                    contentLinkAndDocumentMap.remove(cdlID);
                }
            }
        }
        //IF map have data then Call Queueable class
        if(!contentLinkAndDocumentMap.isempty()){
            jobID = System.enqueueJob(new FSM_SendUploadAttachmentsQueueable(contentLinkAndDocumentMap, flag, contentLinkAndSAPUserID));
        }
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description This method is to get Contentversion Records,Created as part of user story #SFI-1213
    @param newMap
	@return Map<ID,ContentVersion>
    @Date        : 29-April-2024
    ********************************************************************************************************/
    private static Map<ID,ContentVersion> getContentVersion(Map<Id,Id> contentLinkAndDocumentMap){
        Set<ID> allContDocID = new Set<ID>();
        List<ContentVersion> allContVer;
        Map<ID,ContentVersion> contDocAndContVerMap;
        
        allContDocID.addAll(contentLinkAndDocumentMap.values());
        //Added FileExtension field as part of SFI-2614 14th Aug 24 By Subir Maji
        allContVer = [SELECT Id, Title, FileExtension, ContentDocumentId, FSM_Do_not_send_to_SAP__c FROM ContentVersion WHERE ContentDocumentId IN :allContDocID WITH SECURITY_ENFORCED];
        
        if(allContVer != null && !allContVer.iSEmpty()){
            contDocAndContVerMap = new Map<ID,ContentVersion>();
            for(ContentVersion cvt : allContVer){
                contDocAndContVerMap.put(cvt.ContentDocumentId, cvt);
            }
        }
        return contDocAndContVerMap;
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch ServiceAppointment record, Created as part of user story #SFI-1213
	@description  Updated As part of SFI-2208 by Asutosh Singh 21st June 24
    @param allSaLinkedEntityId
    @Date        : 01-April-2024
	@return Map<id ,ServiceAppointment>
    ********************************************************************************************************/
    private static Map<id ,ServiceAppointment> getServiceApppointment(Set<Id> allSaLinkedEntityId){
        Map<id ,ServiceAppointment> saRecords= new  Map<id ,ServiceAppointment>([SELECT id, AppointmentNumber, FSM_ServiceResourceSAPUserID__c from ServiceAppointment WHERE Id IN : allSaLinkedEntityId WITH SECURITY_ENFORCED]);
        return saRecords;
    }
    
   /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method is to fetch WorkOrder record, Created as part of user story #SFI-1213
	@description  Updated As part of SFI-2208 by Asutosh Singh 21st June 24
    @param allWoLinkedEntityId
    @Date        : 01-April-2024
	@return Map<id ,WorkOrder>
    ********************************************************************************************************/
    private static  Map<id ,WorkOrder>  getWorkOrder(Set<Id> allWoLinkedEntityId){
        Map<id ,WorkOrder> woRecords= new Map<id ,Workorder>([SELECT id, WorkOrderNumber, (SELECT id, FSM_ServiceResourceSAPUserID__c from ServiceAppointments) from WorkOrder WHERE Id IN : allWoLinkedEntityId WITH SECURITY_ENFORCED]);
        return woRecords;
    }
    
     /********************************************************************************************************
    @Author      : Geethanjali
    @description  This method is to fetch current user and send back user external id, Created as part of jira SFL-307
    @param
    @Date        : 12-June-2025
	@return String
    ********************************************************************************************************/
    private static String getCurrentUserId(){
        User currentUser =[SELECT Id,FSM_ExternalId__c from User WHERE Id=:UserInfo.getUserId()];
        return currentUser.FSM_ExternalId__c;

    }
}
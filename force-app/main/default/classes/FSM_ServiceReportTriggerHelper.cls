/********************************************************************************************************
@Author      : Aishwarya Bhosale
@Description : This class is used to Create Task to be sent to Mailjet for proforma
@Description : Created as part of user story #SFS-5350
@Description : Invoked from FSM_ServiceReportTriggerHandler class
@Test Class  : FSM_ServiceReportTriggerTest
@Date        : 21-May-2024
********************************************************************************************************/
public with Sharing class FSM_ServiceReportTriggerHelper {
    
    /********************************************************************************************************
    @Author      : Aishwarya Bhosale
    @Description : This Method will create task and update SA based on Service report.
    @Description : Created as part of user story #SFS-5350
	@param 		 : newMap
    @Date        : 06-June-2024
    ********************************************************************************************************/ 
    public void createTask(Map<Id,sObject> newMap){
        Map<Id,ServiceReport> serviceReportNewRecords = (Map<Id,ServiceReport>)newMap;
        ServiceAppointment servApp = new  ServiceAppointment ();
        Set<Id> tempIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        Map<Id, ServiceAppointment> serviceAppointmentsMap;
        Map<ID, ServiceReportLayout> allServReportLayout;
        Map<ID,Task> allServRepTaskToBeCreatedMap;
        List<Task> taskToUpdate;
        List<ContentDocumentLink> allContentDocumentLinkInsert;
        SET<String> templateName = new Set<String>{'Emergency Land Entry Notice',
                                                   'Private Sewer Blockages',
                                                   'Permission to Dig',
                                                   'Permission to Dig (Welsh version)',
                                                   'HD - Emergency Notice Land Entry Notice',
                                                   '7 Day Land Entry Notice',
                                                   'HD - 7 Day Land Entry Notice','Aquapea',
                                                   'Gas Leak Detection',
                                                   'Leak on Private Supply Pipe',
                                                   'HD - Leak on Private Supply Pipe (English version)',
                                                   'HD - BOPPs 3rd Party',
                                                   'BOPPS 3rd Party',
            									   'HD - Leak on Private Supply Pipe (Welsh version)'};
        
        // get template ids for Proforma from Service report template cmdt
        List<FSM_ServiceReportTemplates__mdt> ServReportTempName = [Select Id,FSM_TemplateName__c,FSM_TemplateId__c 
                                                           			from FSM_ServiceReportTemplates__mdt 
                                                           			where FSM_TemplateName__c IN: templateName WITH SECURITY_ENFORCED];
        
        for(FSM_ServiceReportTemplates__mdt srt: ServReportTempName){
            tempIds.add(srt.FSM_TemplateId__c);
        }
        
        if(!tempIds.IsEmpty()){
            allServReportLayout = New MAP<ID, ServiceReportLayout>([Select ID, DeveloperName 
                                                                    from ServiceReportLayout 
                                                                    where Id IN: tempIds WITH SECURITY_ENFORCED]);
            
            for(ServiceReport servReport : serviceReportNewRecords.values()){
                //check if service report created has proforma template
                if(tempIds.contains(servReport.Template)){
                    parentIds.add(servReport.ParentId);
                }
            }
        }
        
        if(!parentIds.isEmpty()){
            serviceAppointmentsMap = new Map<Id, ServiceAppointment>([
                SELECT Id, FSM_ProformaAction__c, FSSK__FSK_Assigned_Service_Resource__r.RelatedRecordId,FSSK__FSK_Assigned_Service_Resource__r.ServiceCrewId, FSM_SAPWorkorderNumber__c 
                FROM ServiceAppointment 
                WHERE Id IN :parentIds WITH SECURITY_ENFORCED]);
        }
        
        if(serviceAppointmentsMap != null && !serviceAppointmentsMap.isEmpty()){
            allServRepTaskToBeCreatedMap = new Map<ID,Task>();
            
            for(ServiceReport servReport : serviceReportNewRecords.values()) {
                if (tempIds.contains(servReport.Template) && serviceAppointmentsMap.containsKey(servReport.ParentId)) {
                    servApp = serviceAppointmentsMap.get(servReport.ParentId);
                    if (ServApp.FSM_ProformaAction__c == 'Generate and Send') {
                        allServRepTaskToBeCreatedMap.Put(servReport.ContentVersionDocumentId,createTaskPerforma(ServApp, allServReportLayout.get(servReport.Template).DeveloperName,servReport.CreatedById));
                    }
                }
            }
            system.debug('allServRepTaskToBeCreatedMap ===>'+allServRepTaskToBeCreatedMap);
            Try{
                taskToUpdate = new List<Task>();
                //Insert Task
                if(allServRepTaskToBeCreatedMap != null && !allServRepTaskToBeCreatedMap.isEmpty() && Schema.sObjectType.Task.isCreateable()){
                    Insert allServRepTaskToBeCreatedMap.values();
                }
                
                //Insert Content Document Link
                allContentDocumentLinkInsert = createContentDocumentLink(allServRepTaskToBeCreatedMap);
                if(allContentDocumentLinkInsert != null && !allContentDocumentLinkInsert.isEmpty() && Schema.sObjectType.ContentDocumentLink.isCreateable()){
                    Insert allContentDocumentLinkInsert;
                }
                
                //Update task   
                for(Task tsk : allServRepTaskToBeCreatedMap.values()){
                    tsk.Status = 'Open';
                    taskToUpdate.add(tsk);
                }
                system.debug('tasktoUpdate'+taskToUpdate);

                if(taskToUpdate != null && !taskToUpdate.isEmpty() && Schema.sObjectType.Task.isUpdateable()){
                    Update taskToUpdate;
                }
                
            }Catch(Exception ex){
                new FSM_Utility.ErrorLogCreator().setClassName('FSM_ServiceReportTriggerHelper').setMethodName('createTask').setErrorMessage(ex.getMessage()).setLineNumber(String.valueOf(ex.getLineNumber())).setStackTrace(ex.getStackTraceString()).setType('Field Service').create();
            }
    	}
    }
    
    /********************************************************************************************************
    @Author      : Aishwarya Bhosale
    @Description : This Method will create task and update SA based on Service report.
    @Description : Created as part of user story #SFS-5350
	@param 		 : servApp, templateName
	@return		 : Task
    @Date        : 06-June-2024
    ********************************************************************************************************/ 
    private task createTaskPerforma(ServiceAppointment servApp, String templateName,string servReportcreatedbyId){
        Task tsk = new task();
        tsk.Subject=servApp.FSM_SAPWorkorderNumber__c +' ' +templateName;
        tsk.WhatId=servApp.Id;
        String crewLeaderId = getRelatedCrewId(servApp.FSSK__FSK_Assigned_Service_Resource__r.ServiceCrewId,servReportcreatedbyId);
        tsk.OwnerId=String.isBlank(servApp.FSSK__FSK_Assigned_Service_Resource__r.RelatedRecordId) ? crewLeaderId :  servApp.FSSK__FSK_Assigned_Service_Resource__r.RelatedRecordId;
        //tsk.OwnerId=String.isBlank(servApp.FSSK__FSK_Assigned_Service_Resource__r.RelatedRecordId)? servReportcreatedbyId :  servApp.FSSK__FSK_Assigned_Service_Resource__r.RelatedRecordId;

        tsk.Status = 'Not Started';
        tsk.Type='Proforma';
       // System.debug('sccreewww id ' + servApp.FSSK__FSK_Assigned_Service_Resource__r.ServiceCrewId);

        return tsk;
    }
    private String getRelatedCrewId(String serviceCrewId,string servReportcreatedbyId){ //added this method to get crews leaders user into task owner field when a job is assigned to a crew instead of Single resoruce as a part of SFL-646 by Anil G
        String crewLeaderId;
        //select id,IsLeader,ServiceResource.RelatedRecordId,ServiceResource.Name from ServiceCrewMember where ServiceCrewId = '1crPu000000158vIAA'
        List<ServiceCrewMember> crewServiceResource = [SELECT Id,ServiceResource.RelatedRecordId,IsLeader,ServiceResource.Name,ServiceResource.IsActive FROM ServiceCrewMember WHERE ServiceCrewId =:serviceCrewId and ServiceResource.RelatedRecordId =:servReportcreatedbyId and ServiceResource.IsActive =true  WITH SECURITY_ENFORCED limit 1];
        if(crewServiceResource.size()>0){
            crewLeaderId = crewServiceResource[0].ServiceResource.RelatedRecordId;
        }
        return crewLeaderId;
    }
    
    /********************************************************************************************************
    @Author      : Aishwarya Bhosale
    @Description : This Method will create Content Doc Link update Content version. 
    @Description : Created as part of user story #SFS-5350
	@param 		 : allServRepTaskToBeCreatedMap
	@return		 : List<ContentDocumentLink>
    @Date        : 06-June-2024
    ********************************************************************************************************/
    private List<ContentDocumentLink> createContentDocumentLink(Map<ID,Task> allServRepTaskToBeCreatedMap){
        List<ContentDocumentLink> allContentDocumentLinkInsert = new List<ContentDocumentLink>();
        ContentDocumentLink cDocLink;
        MAP<ID, ContentVersion> allContentVersion = New MAP<ID, ContentVersion>(
            										[Select ID, ContentDocumentId, FSM_Do_not_send_to_SAP__c 
                                                     from ContentVersion 
                                                     where Id IN: allServRepTaskToBeCreatedMap.KeySet() WITH SECURITY_ENFORCED]);
        
        for(Id cvID: allServRepTaskToBeCreatedMap.KeySet()){
            cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = allContentVersion.get(cvID).ContentDocumentId;//Add ContentDocumentId
            cDocLink.LinkedEntityId = allServRepTaskToBeCreatedMap.get(cvID).Id;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            allContentDocumentLinkInsert.add(cDocLink);
        }
        
        for(ContentVersion contVer : allContentVersion.Values()){
            contVer.FSM_Do_not_send_to_SAP__c = true;
        }
        if(Schema.sObjectType.ContentVersion.isUpdateable()){
        	Update allContentVersion.Values();
        }
        
        return allContentDocumentLinkInsert;
    }
}
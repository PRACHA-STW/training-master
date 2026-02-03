/** ************************************************************************************
@Author : Brajesh Kumar
@Description  : Created for Select & Schedule - Jobs on same asset (non-infra)
@Created Date : 24th May 2024
@Test Class : FSM_SelectAndScheduleTest
@description : Created as part of user story SFS-5428 
**************************************************************************************** **/

// run this in system mode, as the user will lose the access to the record when SA status : Scheduled
public without sharing class FSM_SelectAndSchedule {
    
    // To Update SA status to 'Scheduled' create 'AssignedResource' record and update status to : Dispatched
    @AuraEnabled
    public static String scheduleAndDispatchSA(String saId,String asgnResource) {
        try{
            ServiceResource sr;
           
            sr= [Select id from ServiceResource where RelatedRecordId=:UserInfo.getUserId() limit 1];
            
            system.debug('sr'+sr);
            ServiceAppointment saForSched = [SELECT Id,Duration,DurationType FROM ServiceAppointment where Id =:saId WITH SECURITY_ENFORCED Limit 1];
            List<ServiceAppointment> updateSAList1 = new List<ServiceAppointment>(); //collecting updated SA on Schedule
            List<AssignedResource> updateListSR = new List<AssignedResource>();      //collecting record of Assigned Resource
            List<ServiceAppointment> updateSAList2 = new List<ServiceAppointment>(); //collecting  updated SA on Dispatch
            ServiceAppointment sa = new ServiceAppointment();
            AssignedResource ar = new AssignedResource();
            ServiceAppointment sa1 = new ServiceAppointment();
            Datetime currentTime = Datetime.now();
            sa.Id = saId;
            sa.SchedStartTime = currentTime; 
            if(saForSched.DurationType == 'Minutes'){
                Integer minToAdd = Integer.valueOf(saForSched.Duration);
                sa.SchedEndTime = currentTime.addMinutes(minToAdd);
            }
            else if(saForSched.DurationType =='Hours'){
                Integer hoursToAdd = Integer.valueOf(saForSched.Duration);
                sa.SchedEndTime = currentTime.addHours(hoursToAdd);
            }
            sa.FSSK__FSK_Assigned_Service_Resource__c = sr.Id;
            sa.Status = 'Scheduled';
            
            ar.ServiceAppointmentId = saId;
            ar.ServiceResourceId = sr.Id;
            sa1.Id = saId;
            //Start-added as part of SFS-7569
            sa1.FSM_Self_Assigned__c=true;
            //End-added as part of SFS-7569
            sa1.Status = 'Dispatched';
            updateSAList1.add(sa);
            System.debug('sa1'+sa);
            updateListSR.add(ar);
            updateSAList2.add(sa1); 
             System.debug('sa2'+sa1);
            
            if(updateSAList1.size() >0&&Schema.sObjectType.ServiceAppointment.isUpdateable()){
                update updateSAList1; 
            }   
            
            if(updateListSR.size() >0&&Schema.sObjectType.AssignedResource.isCreateable()){
                insert updateListSR;  
            }
            if(updateSAList2.size() >0&&Schema.sObjectType.ServiceAppointment.isUpdateable()){
              update updateSAList2;
            }
            return 'Success';
        }
        catch (exception e) {
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_SelectAndSchedule').setMethodName('scheduleAndDispatchSA').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Field Service').create();
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    
    // Method to retrieve Current Service Appointment
    @AuraEnabled(cacheable=true)
    public static List<ServiceAppointment> getServiceAppointment(String saId) {
        List<ServiceAppointment> sa = new  List<ServiceAppointment>();
        try{
            sa = [SELECT Id,FSSK__FSK_Work_Order__c,PostalCode,FSSK__FSK_Work_Order__r.FSM_Floc__c,FSSK__FSK_Work_Order__r.FSM_ContactName__c,ServiceTerritoryId,FSSK__FSK_Assigned_Service_Resource__c FROM ServiceAppointment Where Id =:saId WITH SECURITY_ENFORCED LIMIT 1 ];
        }
        catch (exception e) {new FSM_Utility.ErrorLogCreator().setClassName('FSM_SelectAndSchedule').setMethodName('getServiceAppointment').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Field Service').create();
                            }
        return sa;
    }
    
    // Method to Search SA's based on filter and predefined criteria
    @AuraEnabled(cacheable=false)
    public static List<ServiceAppointment> searchSA(String saId,List<String> selectedFilters) {
        //Returning matching criteria SA
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();
        try{
            
            // Perform queries to retrieve Service Appointments
            ServiceAppointment sa = [SELECT Id,FSSK__FSK_Work_Order__c,PostalCode,FSSK__FSK_Work_Order__r.FSM_Floc__c,FSSK__FSK_Work_Order__r.FSM_ContactName__c,ServiceTerritoryId,FSSK__FSK_Assigned_Service_Resource__c FROM ServiceAppointment Where Id =:saId WITH SECURITY_ENFORCED];
            String postCode = sa.PostalCode;
            String flocWO =sa.FSSK__FSK_Work_Order__r.FSM_Floc__c ;
            String contactName = sa.FSSK__FSK_Work_Order__r.FSM_ContactName__c;
            String serviceTerritoryId = sa.ServiceTerritoryId;
            String woId = sa.FSSK__FSK_Work_Order__c;
            String assignedSR = sa.FSSK__FSK_Assigned_Service_Resource__c;
            
            // Add Query Filter based on Checkbox on Apply Filter Screen (Screen 1)
            String filterQuery = '';
            if (selectedFilters.contains('postalTrue')) {
                filterQuery += ' AND PostalCode =: postCode'; 
            }
            if (selectedFilters.contains('flocTrue')) {
                filterQuery += ' AND FSSK__FSK_Work_Order__r.FSM_Floc__c =: flocWO'; 
            }
            
            // Get Service Resource Skills
            Set<Id> serviceResourceSkillIds = new Set<Id>();
            for (ServiceResourceSkill srs : [
                SELECT SkillId 
                FROM ServiceResourceSkill 
                WHERE ServiceResourceId =: assignedSR WITH SECURITY_ENFORCED
            ]) {
                serviceResourceSkillIds.add(srs.SkillId);
            }
            
            // Calculate Date Range 
            Date today = Date.today();
            Date nextWeek = today.addDays(7);
            Date lastTwoMonths = today.addDays(-90);
            // Query on SA object to get Select and Schedule SAs
            String query ='SELECT Id, Status, ParentRecordId,FSSK__FSK_Assigned_Service_Resource__c,FSSK__FSK_Work_Order__r.FSM_Floc__c,FSSK__FSK_Work_Order__r.FSM_ContactName__c,FSM_ServiceOrderType__c,FSM_ExternalId__c,FSM_SAPWorkorderNumber__c ,FSM_TaskType__c,Subject, ServiceTerritoryId, DueDate,FSSK__FSK_Work_Order__c  FROM ServiceAppointment WHERE Status = \'New\' AND (FSM_ServiceOrderType__c = \'ZPM1\' OR FSM_ServiceOrderType__c = \'ZPM2\') AND ServiceTerritoryId =:serviceTerritoryId AND DueDate >= :lastTwoMonths AND DueDate <= :nextWeek '+ filterQuery;                
            
            //Filtering SA based on Skills  
            Map<Id,List<Id>> woSA = new Map<Id,List<Id>>();
            for (ServiceAppointment filterSA : Database.query(query)) {
                if (woSA.containsKey(filterSA.ParentRecordId)) {
                    List<Id> saIds= woSA.get(filterSA.ParentRecordId);saIds.add(filterSA.Id);woSA.put(filterSA.ParentRecordId, saIds);
                }else{
                    woSA.put(filterSA.ParentRecordId, new List<Id> {filterSA.Id});
                }
            }    
            List<Id> results = new List<Id>();
            for (WorkOrder filterWO : [select Id,(select id,skillId from SkillRequirements) from WorkOrder where id =: woSA.keySet() WITH SECURITY_ENFORCED]) {
                Boolean skillMatch = true;
                for (SkillRequirement skillReq : filterWO.SkillRequirements) {
                    if(!serviceResourceSkillIds.contains(skillReq.skillId)){
                        skillMatch = false;
                    }   
                }
                if(skillMatch){results.addAll(woSA.get(filterWO.Id));}
            }
            
            
            serviceAppointments = [Select Id, Status, ParentRecordId,FSSK__FSK_Assigned_Service_Resource__c,FSSK__FSK_Work_Order__r.FSM_Floc__c,FSSK__FSK_Work_Order__r.FSM_ContactName__c,FSM_ServiceOrderType__c,FSM_ExternalId__c,FSM_SAPWorkorderNumber__c ,FSM_TaskType__c,Subject, ServiceTerritoryId, DueDate,FSSK__FSK_Work_Order__c  from ServiceAppointment where Id in :results LIMIT 20];
        }
        catch (exception e) {new FSM_Utility.ErrorLogCreator().setClassName('FSM_SelectAndSchedule').setMethodName('searchSA').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Field Service').create();
                            }
        return serviceAppointments;
    }
}
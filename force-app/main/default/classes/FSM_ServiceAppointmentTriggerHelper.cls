/********************************************************************************************************
@Author      : Srikanth Palla
@description : FSM_ServiceAppointmentTriggerHelper class to handle trigger logic.
@description : Created as part of user story #SFI-21
@Test Class  :  FSM_WorkOrderTriggerHandlerTest, FSM_GetPolygonTest
@Date        : 04-Aug-2023
14-Sep-2023      Srikanth Palla        Updated as part of  SFI-29
********************************************************************************************************/
public with sharing class FSM_ServiceAppointmentTriggerHelper {
    Static MAP<ID,Boolean> isBundleCasePopulated = new MAP<ID,Boolean>();//Added as part of user story #SFL-132 11th Dec 24 by Subir Maji, So that same parent WO don't get updated multiple time in same transaction
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method Will check the logic to populate the Case in Parent Bundle Work order.
    @Description : Created as part of user story #SFL-132
    @input       : newMap, oldMap
    @Date        : 11-Dec-2024
    ********************************************************************************************************/ 
    Public Void casePopulationForParentBundle(Map<Id,sObject> newMap,Map<Id,sObject> oldMap){
        Map<Id, ServiceAppointment> allNewSa=(Map<Id, ServiceAppointment>)newMap; //collecting all updated SA
        Map<Id, ServiceAppointment> allOldSa=(Map<Id, ServiceAppointment>)oldMap; //collecting all updated SA
        Map<Id,ID> bundleSaCaseIds = new Map<Id,ID>(); //To collect alll Parent Bundle SA ID and related Case id
        WorkOrder wo; //Temporary veriable to hold the Work Order details
        List<WorkOrder> woList=new List<WorkOrder>();//List of WO to update
        Map<ID,ServiceAppointment> allParentBundleSA; //To collect the parent bundle SA details
        
        //Check logic to collect the bundleSaCaseIds variable and also isBundleCasePopulated variable
        for(ServiceAppointment sa : allNewSa.values()){
            if(sa.RelatedBundleId != null && sa.RelatedBundleId != allOldSa.get(sa.Id).RelatedBundleId && !isBundleCasePopulated.containsKey(sa.RelatedBundleId)){
                isBundleCasePopulated.put(sa.RelatedBundleId, true);
                bundleSaCaseIds.put(sa.RelatedBundleId, sa.FSM_CaseId__c);               
            }
        }
        
        //Populate Case in Parent Bundle WO
        if(!bundleSaCaseIds.isEmpty()){
            //Query Parent Bundle SA
            allParentBundleSA = new Map<ID,ServiceAppointment>([SELECT ID, ParentRecordId 
                                                                FROM ServiceAppointment 
                                                                WHERE ID IN : bundleSaCaseIds.KeySet() WITH SECURITY_ENFORCED]);
            if(allParentBundleSA != null && !allParentBundleSA.isEmpty()){
                for(id saID : bundleSaCaseIds.KeySet()) {
                    wo = new WorkOrder();
                    wo.ID = allParentBundleSA.get(saID).ParentRecordId;
                    wo.CaseId=bundleSaCaseIds.get(saID);
                    woList.add(wo);
                }
            }
        }
        
        //Update WO record
        if(!woList.isEmpty() && Schema.sObjectType.WorkOrder.isUpdateable()){
            try{
                update woList;
            }catch(exception e){
                new FSM_Utility.ErrorLogCreator().setExternalID(String.valueof(allNewSa.KeySet())).setClassName('FSM_ServiceAppointmentTriggerHelper').setMethodName('casePopulationForParentBundle').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Field Service').create();
            }
        }
        
    }
    
    /**
    * @description :workOrderReasonUpdates to update Reasons fields on WorkOrder
    * @param newMap
    * @param oldMap
    * @added as part of SFI-35, Srikanth palla, 17th Aug 2023
    */    
    public void workOrderReasonUpdates(Map<Id,sObject> newMap,Map<Id,sObject> oldMap){
        Map<Id, ServiceAppointment> allNewSa=(Map<Id, ServiceAppointment>)newMap; //collecting all updated SA
        Map<Id, ServiceAppointment> allOldSa=(Map<Id, ServiceAppointment>)oldMap; //collecting all updated SA
        Set<Id> woIds = new Set<Id>(); //To collect alll WO ID from SA
        WorkOrder wo; //Temporary veriable to hold teh Work Order details
        List<WorkOrder> woList=new List<WorkOrder>();//List of WO to update
        
        //Go through SA and collect WO
        for (ServiceAppointment sa : allNewSa.values()) {
            if(sa.FSM_SuspendReason__c!=allOldSa.get(sa.Id).FSM_SuspendReason__c || sa.FSM_RejectReason__c!=allOldSa.get(sa.Id).FSM_RejectReason__c){
                woIds.add(sa.ParentRecordId); 
            }
        }
        
        //Update WO fields
        if(!woIds.isEmpty()){
            for(ServiceAppointment sa : allNewSa.values()) {
                if(woIds.contains(sa.ParentRecordId)){
                    wo = new WorkOrder();
                    wo.ID = sa.ParentRecordId;
                    wo.FSM_SuspendReason__c=sa.FSM_SuspendReason__c;
                    wo.FSM_RejectReason__c=sa.FSM_RejectReason__c;
                    woList.add(wo);
                }
            }
        }
        
        //Update WO
        if(woList.size()>0&&Schema.sObjectType.WorkOrder.isUpdateable()){
            try{
                update woList;
            }catch(exception e){
                new FSM_Utility.ErrorLogCreator().setClassName('FSM_ServiceAppointmentTriggerHelper').setMethodName('workOrderReasonUpdates').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Field Service').create();
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method Will check the logic to populate the Polygon.
    @Description : Created as part of user story #SFL-68
    @input       : isInsert, newServiceAppointment, newMap, oldMap
    @Date        : 17-Nov-2024
    ********************************************************************************************************/ 
    public void polygonUpdate(Boolean isInsert, List<ServiceAppointment> newServiceAppointment, Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        List<ServiceAppointment> allServAppForpolygon = new List<ServiceAppointment>();//To collect all SA for Polygom Check
        Map<Id, ServiceAppointment> allNewSa=(Map<Id, ServiceAppointment>)newMap; //collecting all updated SA
        Map<Id, ServiceAppointment> allOldSa=(Map<Id, ServiceAppointment>)oldMap; //collecting all updated SA
        
        //If records Inserted
        if(isInsert){
            checkConditions(newServiceAppointment);
        }else{ //If record Updated
            for(Id saId : allNewSa.KeySet()){
                if(allOldSa.ContainsKey(saId)){ //Check for Field Update
                    if(allNewSa.get(saId).Latitude != allOldSa.get(saId).Latitude 
                       || allNewSa.get(saId).Longitude != allOldSa.get(saId).Longitude 
                       || allNewSa.get(saId).FSM_Polygon__c != allOldSa.get(saId).FSM_Polygon__c){
                        allServAppForpolygon.add(allNewSa.get(saId));
                    }
                }
            }
            if(!allServAppForpolygon.isEmpty()){
                checkConditions(allServAppForpolygon);
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method Will check the logic to populate the Polygon.
    @Description : Created as part of user story #SFL-68
    @input       : newServiceAppointment
    @Date        : 17-Nov-2024
    ********************************************************************************************************/
    private void checkConditions(List<ServiceAppointment> newServiceAppointment){
        Set<ID> allStId = new Set<ID>(); //To collect All Service territory Id
        Map<Id, ServiceTerritory> allterritory = new Map<Id, ServiceTerritory>(); //Map of Id and Service Territory record
        Map<ServiceAppointment,Boolean> allSAforPolugonSearch = new Map<ServiceAppointment,Boolean>(); //Map of Service Appointmnet and STK based or not
        
        //Collect all St ID
        for(ServiceAppointment sa : newServiceAppointment){
            if(sa.Longitude != null && sa.Latitude != null && sa.FSM_Polygon__c == null){
                allStId.add(sa.ServiceTerritoryId);
            }
        }
        
        //If ST present get teh ST related details
        if(!allStId.isEmpty()){
            allterritory = getServiceTerritory(allStId);
            
            //Go through all Appointments and populate map based on STK logic and Working Sub Area logic
            for(ServiceAppointment sa : newServiceAppointment){
                if(allterritory.ContainsKey(sa.ServiceTerritoryId) && allterritory.get(sa.ServiceTerritoryId).FSM_WorkingSubAreaRequired__c){
                    if(allterritory.get(sa.ServiceTerritoryId).FSM_IsPolygonBasedOnStandardTextKey__c && sa.FSM_StandardTextKey__c != null){
                        allSAforPolugonSearch.put(sa,true);
                    }else If(!allterritory.get(sa.ServiceTerritoryId).FSM_IsPolygonBasedOnStandardTextKey__c){
                        allSAforPolugonSearch.put(sa,false);
                    }
                }
            }
            //Call FSM_GetPolygon class to check further logic and populate polygon field
            FSM_GetPolygon.populatePolygon(allSAforPolugonSearch,allterritory);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method Will get teh relavant Service territory information.
    @Description : Created as part of user story #SFL-68
    @input       : allStId
    @output      : Map<Id, ServiceTerritory>
    @Date        : 17-Nov-2024
    ********************************************************************************************************/
    private Map<Id, ServiceTerritory> getServiceTerritory(Set<Id> allStId){
        Map<Id, ServiceTerritory> allterritory = new Map<Id, ServiceTerritory>([Select ID, Name, FSM_WorkingSubAreaRequired__c, 
                                                                                FSM_IsPolygonBasedOnStandardTextKey__c, FSM_ExternalId__c, FSM_SchedulingPolicy__c, FSM_AutoSchedulePolicy__c
                                                                              From ServiceTerritory where ID IN : allStId WITH SECURITY_ENFORCED]);
        
        return allterritory;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method Will get the relavant WorkOrder information.
    @Description : Created as part of user story #SFL-68
    @input       : allWoId
    @output      : Map<Id, WorkOrder>
    @Date        : 17-Nov-2024
    ********************************************************************************************************/
    private Map<Id, WorkOrder> getWorkOrder(Set<Id> allWoId){
        Map<Id, WorkOrder> allWorkOrder = new Map<Id, WorkOrder>([Select ID, FSM_WorkTypeCode__c, FSM_TMAPermit__c, FSM_TMAPermit__r.FSM_NoticeType__c
                                                                From WorkOrder where ID IN : allWoId WITH SECURITY_ENFORCED]);
        
        return allWorkOrder;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method Will check the logic to populate the Auto Schedule.
    @Description : Created as part of user story #SFL-68
    @input       : isInsert, newServiceAppointment, newMap, oldMap
    @Date        : 17-Nov-2024
    ********************************************************************************************************/ 
    public void autoScheduleUpdate(Boolean isInsert, List<ServiceAppointment> newServiceAppointment, Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        List<ServiceAppointment> allServAppForAutoSchudule = new List<ServiceAppointment>();//To collect all SA for Auto Schedule Check
        Map<Id, ServiceAppointment> allNewSa=(Map<Id, ServiceAppointment>)newMap; //collecting all updated SA
        Map<Id, ServiceAppointment> allOldSa=(Map<Id, ServiceAppointment>)oldMap; //collecting all updated SA
        
        //If records Inserted
        if(isInsert){
            checkConditionsAutoSchedule(newServiceAppointment);
        }else{ //If record Updated
            for(Id saId : allNewSa.KeySet()){
                if(allOldSa.ContainsKey(saId)){ //Check for Field Update
                    if(allNewSa.get(saId).Latitude != allOldSa.get(saId).Latitude 
                       || allNewSa.get(saId).Longitude != allOldSa.get(saId).Longitude 
                       || allNewSa.get(saId).FSM_Polygon__c != allOldSa.get(saId).FSM_Polygon__c
                       || allNewSa.get(saId).ServiceTerritoryId != allOldSa.get(saId).ServiceTerritoryId
                       || allNewSa.get(saId).FSM_RetriggerAutoScheduleBasedonWO__c){
                        allServAppForAutoSchudule.add(allNewSa.get(saId));
                    }
                }
            }
            if(!allServAppForAutoSchudule.isEmpty()){
                checkConditionsAutoSchedule(allServAppForAutoSchudule);
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method Will check the logic to populate the Polygon.
    @Description : Created as part of user story #SFL-68
    @input       : newServiceAppointment
    @Date        : 17-Nov-2024
    23-April-2025  Nishant kumar  Updated as part of SFL-571
    ********************************************************************************************************/
    private void checkConditionsAutoSchedule(List<ServiceAppointment> newServiceAppointment){
        Set<ID> allStWoId = new Set<ID>(); //To collect All Service territory Id and Work Order Id
        Map<Id, ServiceTerritory> allterritory = new Map<Id, ServiceTerritory>(); //Map of Id and Service Territory record
        Map<Id, WorkOrder> allWorkOrder = new Map<Id, WorkOrder>();// Map of all relavant Work orders
        Set<String> allSTname = new Set<String>();
        List<FSM_BatchProcess__mdt> allmdt;
        Boolean stFlag;
        
        Map<ServiceAppointment,Boolean> allSAforPolugonSearch = new Map<ServiceAppointment,Boolean>(); //Map of Service Appointmnet and STK based or not
        
        //Collect all ST and WO ID
        for(ServiceAppointment sa : newServiceAppointment){
            //Added new condition sa.FSM_IsTemporaryRecord__c != true to the below if block on 29/10/2025 SFL-1252
            if(sa.FSM_IsTemporaryRecord__c != true && sa.Longitude != null && sa.Latitude != null && sa.Status == 'New'
              && sa.FSM_StandardTextKey__c != 'MHHVFTS' && sa.FSM_StandardTextKey__c != 'MNHHVTS'){
                allStWoId.add(sa.ServiceTerritoryId);
                allStWoId.add(sa.ParentRecordId);
            }
        }
        
        //If ST present get teh ST related details
        if(!allStWoId.isEmpty()){
            allterritory = getServiceTerritory(allStWoId);
            allWorkOrder = getWorkOrder(allStWoId);
            
            for(ServiceTerritory st : allterritory.values()){
                allSTname.add(st.name);
            }
            
            allmdt = [Select Id, Process_Name__c, Service_Territory__c 
                      From FSM_BatchProcess__mdt 
                      Where Process_Name__c = 'Shift Round Territories'
                     AND Service_Territory__c IN : allSTname];
            
            if(allmdt != null && !allmdt.isEmpty()){
                for(ServiceTerritory st : allterritory.values()){
                    stFlag = false;
                    for(FSM_BatchProcess__mdt mdt : allmdt){
                        if(mdt.Service_Territory__c == st.Name){
                            stFlag = true;
                            break;
                        }
                    }
                    if(stFlag){
                        allterritory.remove(st.Id);
                    }
                }
            }
            
            //Go through all Appointments and populate Auto Schedule and policy
            for(ServiceAppointment sa : newServiceAppointment){
                System.debug('SA inside loop');
                //Added new condition sa.FSM_IsTemporaryRecord__c != true to the below if block on 29/10/2025 SFL-1252
                if(allterritory.ContainsKey(sa.ServiceTerritoryId) 
                   && sa.FSM_IsTemporaryRecord__c != true
                   && allWorkOrder.get(sa.ParentRecordId).FSM_WorkTypeCode__c != 'SELF'
                   && (allWorkOrder.get(sa.ParentRecordId).FSM_TMAPermit__c == null
                   || (allWorkOrder.get(sa.ParentRecordId).FSM_TMAPermit__r.FSM_NoticeType__c != '05'
                   && allWorkOrder.get(sa.ParentRecordId).FSM_TMAPermit__r.FSM_NoticeType__c != '04'))
                ){
                    if(sa.ArrivalWindowEndTime != null && sa.ArrivalWindowStartTime != null 
                       && allterritory.get(sa.ServiceTerritoryId).FSM_SchedulingPolicy__c != null){
                        sa.FSL__Auto_Schedule__c = true;
                        sa.FSL__Scheduling_Policy_Used__c = allterritory.get(sa.ServiceTerritoryId).FSM_SchedulingPolicy__c;
                    }else if(sa.ArrivalWindowEndTime == null && sa.ArrivalWindowStartTime == null 
                       && allterritory.get(sa.ServiceTerritoryId).FSM_AutoSchedulePolicy__c != null && sa.FSM_CoreTMAJob__c == false){
                        sa.FSL__Auto_Schedule__c = true;
                        sa.FSL__Scheduling_Policy_Used__c = allterritory.get(sa.ServiceTerritoryId).FSM_AutoSchedulePolicy__c;   
                    }
                    else if(sa.ArrivalWindowEndTime == null && sa.ArrivalWindowStartTime == null && sa.FSM_CoreTMAJob__c == True){
                        sa.FSL__Auto_Schedule__c = true;
                        if(allterritory.get(sa.ServiceTerritoryId).FSM_AutoSchedulePolicy__c != null){
                        	sa.FSL__Scheduling_Policy_Used__c = allterritory.get(sa.ServiceTerritoryId).FSM_AutoSchedulePolicy__c;   
                        }
                    }
                    
                }
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method Will check which Mailjet fields get updated and set teh rest of the fields to blank.
    @Description : Created as part of user story #SFS-8263 and SFS-8264
    @input       : newMap, oldMap
    @Date        : 13-Dec-2024
    ********************************************************************************************************/ 
    public void mailJetFieldsReset(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        Map<Id, ServiceAppointment> allNewSa=(Map<Id, ServiceAppointment>)newMap; //collecting all updated SA
        Map<Id, ServiceAppointment> allOldSa=(Map<Id, ServiceAppointment>)oldMap; //collecting all updated SA
        Boolean resetToFalse = false; //To reset the field to false
        List<String> allFieldToBeBlank = new List<String>();
                
        //Go through the SA and the one which didn't updated set those to blank
        for(ServiceAppointment sa : allNewSa.Values()){
            //if Record updated for mailjet secnario
            if(sa.FSM_MailJetFieldsToBeBlanked__c != null&& sa.FSM_MailjetFieldUpdateDateAndTime__c != allOldSa.get(sa.Id).FSM_MailjetFieldUpdateDateAndTime__c){
                allFieldToBeBlank = sa.FSM_MailJetFieldsToBeBlanked__c.split('//'); //collect all fields to be blanked
                for(String blankFields : allFieldToBeBlank){ //Go through field for each record
                    sa.put(blankFields,null);
                }
            }
        }
    }
}
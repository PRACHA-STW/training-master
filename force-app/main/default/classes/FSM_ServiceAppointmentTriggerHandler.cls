/********************************************************************************************************
@Author      : Srikanth Palla
@description : FSM_ServiceAppointmentTriggerHandler class to handle trigger logic.
@description : Created as part of user story #SFI-21
@Test Class  :  FSM_WorkOrderTriggerHandlerTest, FSM_GetPolygonTest
@Date        : 04-Aug-2023
********************************************************************************************************/
public class FSM_ServiceAppointmentTriggerHandler implements FSM_TriggerBaseHandler{
    // Use this variable to disable this trigger from transaction
    public static Boolean triggerDisabled = false;
    Public Static Boolean isVisited = false;
        
    /**
    * @description :Check if the trigger is disabled from transaction
    * @return :Boolean
    */
    public Boolean isDisabled(){
        return triggerDisabled;        
    }
    
    /**
    * @description :to handle before insert logic
    * @param newWorkOrders
    */
    public void beforeInsert(List<sObject> newList) {
        //Added as part of user story #SFL-68 19th Nov 24 by Subir Maji
        if(!isVisited){
            FSM_ServiceAppointmentTriggerHelper helper = new FSM_ServiceAppointmentTriggerHelper(); 
            helper.polygonUpdate(true, newList, null,null);
            helper.autoScheduleUpdate(true, newList, null,null);
            isVisited = true;
        }
    }
    
    /**
    * @description :to handle after update logic
    * @param newMap
    * @param oldMap
    */
    public void afterUpdate(Map<Id, sObject> newMap,Map<Id, sObject> oldMap){
       FSM_ServiceAppointmentTriggerHelper helper = new FSM_ServiceAppointmentTriggerHelper(); //Added as part of user story #SFL-68 19th Nov 24 by Subir Maji
       helper.workOrderReasonUpdates(newmap,oldMap); //Added as part of user story #SFL-68 19th Nov 24 by Subir Maji
       helper.casePopulationForParentBundle(newmap,oldMap);//Added as part of user story #SFL-132 11th Dec 24 by Subir Maji
    }
    
    /**
    * @description :to handle before update logic
    * @param newMap
    * @param oldMap
    */
    public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        //Added as part of user story #SFL-68 19th Nov 24 by Subir Maji
        if(!isVisited){
            FSM_ServiceAppointmentTriggerHelper helper = new FSM_ServiceAppointmentTriggerHelper();
            helper.polygonUpdate(false, null, newMap,oldMap); 
            helper.autoScheduleUpdate(false, null, newMap,oldMap);
            helper.mailJetFieldsReset(newMap,oldMap);
            isVisited = true;
        }
    } 
    
    /**
    * @description :to handle after insert logic
    * @param newMap
    */
    public void afterInsert(Map<Id, sObject> newMap){}
}
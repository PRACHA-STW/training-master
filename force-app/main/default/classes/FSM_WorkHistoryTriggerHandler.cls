/********************************************************************************************************
@Author      : Subir Maji
@Description : FSM_WorkHistoryTriggerHandaler class to handle trigger logic.
@Description : Created as part of user story #SFI-2152
@Test Class  : FSM_WorkHistoryTriggerHandlerTest 
@Date        : 30-May-2024
********************************************************************************************************/
public class FSM_WorkHistoryTriggerHandler implements FSM_TriggerBaseHandler{
    // Use this variable to disable this trigger from transaction
    public static Boolean triggerDisabled = false;
    
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
    public void beforeInsert(List<sObject> newWorkOrders) {
        //Added by Subir Maji 15th July 2024 SFI-2381
        FSM_WorkHistoryTriggerHelper.updateWorkHistoryExternalID(newWorkOrders);
    }
    
    /**
    * @description :to handle after update logic
    * @param newMap
    * @param oldMap
    */
    public void afterUpdate(Map<Id, sObject> newMap,Map<Id, sObject> oldMap){}
    
    /**
    * @description :to handle before update logic
    * @param newMap
    * @param oldMap
    */
    public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){} 
    
    /**
    * @description :to handle after insert logic
    * @param newMap
    */
    public void afterInsert(Map<Id, sObject> newMap){
        FSM_WorkHistoryTriggerHelper.deleteOldWorkHistory(newMap);
    }
}
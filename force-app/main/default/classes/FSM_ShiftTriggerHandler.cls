/********************************************************************************************************
@Author      : Subir Maji
@description : FSM_ShiftTriggerHandler class to handle trigger logic.
@description : Created as part of user story #SFI-2314
@Test Class  :  FSM_ShiftTriggerHelperTest
@Date        : 26-July-2024
********************************************************************************************************/
public with sharing class FSM_ShiftTriggerHandler implements FSM_TriggerBaseHandler{
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
    * @param newList
    */
    public void beforeInsert(List<sObject> newList) {
        FSM_ShiftTriggerHelper helper = new FSM_ShiftTriggerHelper();
        helper.checkLogicForTimeSheetCreateion(newList, null, null);
    }
    
    /**
    * @description :to handle before update logic
    * @param newMap
    * @param oldMap
    */
    public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        FSM_ShiftTriggerHelper helper = new FSM_ShiftTriggerHelper();
        helper.checkLogicForTimeSheetCreateion(null, newMap, oldMap);
    } 
    
    /**
    * @description :to handle after update logic
    * @param newMap
    * @param oldMap
    */
    public void afterUpdate(Map<Id, sObject> newMap,Map<Id, sObject> oldMap){}
    
    /**
    * @description :to handle after insert logic
    * @param newMap
    */
    public void afterInsert(Map<Id, sObject> newMap){}
}
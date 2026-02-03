/********************************************************************************************************
@Author      : Subir Maji
@Description : This Class is used to invoke FSM_DCFInfraLine2TriggerHelper class
@Description : Created as part of user story #SFI-2041
@description : Invoked from FSM_DCFInfraLine2Trigger
@Test Class  : FSM_DCFInfraLine2TriggerHelperTest
@Date        : 01-Aug-2024
********************************************************************************************************/
public with sharing class FSM_DCFInfraLine2TriggerHandler implements FSM_TriggerBaseHandler{
    // Use this variable to disable this trigger from transaction
    public static Boolean triggerDisabled = false;
    
    /**
     * @description :Check if the trigger is disabled from transaction
     * @return Boolean
    */
    public Boolean isDisabled(){
        return triggerDisabled;        
    }
    
    /**
     * @description :to handle before insert logic
     * @param newWorkOrders
    */
    public void beforeInsert(List<sObject> newList) {
        FSM_DCFInfraLine2TriggerHelper.populateNoOflineSameType(newList);
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
    public void afterInsert(Map<Id, sObject> newMap){} 
 
}
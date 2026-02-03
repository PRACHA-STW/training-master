/********************************************************************************************************
@Author      : Arnob Dey
@Description : This class is used to invoke FSM_CaseTriggerHelper class
@Description : Created as part of user story #SFS-318
@Description : Invoked from FSM_CaseTrigger
@Test Class  : FSM_CaseTriggerHandlerTest
@Date        : 07-July-2023
********************************************************************************************************/
public with sharing class FSM_CaseTriggerHandler implements FSM_TriggerBaseHandler{
    // Use this variable to disable this trigger from transaction
    public static Boolean triggerDisabled = false;
    
    // Check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return triggerDisabled;
    }
    
    public void beforeInsert(List<sObject> newList){} public void afterInsert(Map<Id, sObject> newMap){} public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){}
    
    public void afterUpdate(Map<Id, sObject> newMap,  Map<Id, sObject> oldMap){
        FSM_CaseTriggerHelper.copyCustomerInformation(newMap, oldMap);       
    }
}
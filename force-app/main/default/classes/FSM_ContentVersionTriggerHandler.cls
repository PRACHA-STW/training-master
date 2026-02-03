/********************************************************************************************************
@Author      : Deepak Moudekar
@Description : This class calls FSM_ContentVersionTriggerHelper
@Description : Created as part of user story #SFI-24
@Test Class  : FSM_ContentVersionTriggerHandlerTest
@Date        : 13-June-2023
********************************************************************************************************/
public with sharing class FSM_ContentVersionTriggerHandler implements FSM_TriggerBaseHandler {
     //Use this variable to disable this trigger from transaction
    public static Boolean triggerDisabled = false;
 
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return triggerDisabled;
    }
    
    //For Before Insert functionalities
    public void beforeInsert(List<sObject> newList) {
         FSM_ContentVersionTriggerHelper.updateContentVersionSource(newList);     
    }
    
    //For After insert functionalities 
    public void afterInsert(Map<Id, sObject> newMap) {
        FSM_ContentVersionTriggerHelper.attachcontentversiontorecord(newMap);
         }
    
    //For Before Update functionalities
    public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    }
    
    //For After Update functionalities
    public void afterUpdate(Map<Id, sObject> newMap,  Map<Id, sObject> oldMap) {
    }
}
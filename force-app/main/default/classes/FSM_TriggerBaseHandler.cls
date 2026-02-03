/********************************************************************************************************
@Author : Deepak Moudekar
@Date   : 13-June-2022
@Description : This class used as a interface for all trigger handlers.

********************************************************************************************************/
public interface FSM_TriggerBaseHandler{
    //before insert event 
    void beforeInsert(List<sObject> newList);
    //after insert event 
    void afterInsert(Map<Id, sObject> newMap);
    //before update event 
    void beforeUpdate(Map<Id, sObject> newMap,  Map<Id, sObject> oldMap);
   //after update event 
    void afterUpdate(Map<Id, sObject> newMap,  Map<Id, sObject> oldMap);
    /*       
    void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap);

    void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap);

    void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap);
    */ 
    // used for toggle logic 
    Boolean isDisabled();
}
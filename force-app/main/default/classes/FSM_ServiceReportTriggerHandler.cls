/********************************************************************************************************
@Author      : Aishwarya Bhosale
@description  This class calls FSM_ServiceReportTriggerHelper
@Description : Created as part of user story #SFS-5350
@TestClass : FSM_ServiceReportTriggerTest
@Date        : 21-May-2024
********************************************************************************************************/
public class FSM_ServiceReportTriggerHandler implements FSM_TriggerBaseHandler{
      public static Boolean triggerDisabled = false;
 
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return triggerDisabled;
    }
    
      //For Before Insert functionalities
    public void beforeInsert(List<sObject> newList) {
       
    }
    
  //For After insert functionalities 
    public void afterInsert(Map<Id, sObject> newMap) {
        FSM_ServiceReportTriggerHelper helper=new FSM_ServiceReportTriggerHelper();
             helper.createTask(newMap);
         }
    
     public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    }
    
    //For After Update functionalities
    public void afterUpdate(Map<Id, sObject> newMap,  Map<Id, sObject> oldMap) {
       
    }

}
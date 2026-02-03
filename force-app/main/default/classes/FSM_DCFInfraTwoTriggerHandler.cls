/********************************************************************************************************
@Author      : Brajesh Kumar
@Description : This class calls FSM_DCFInfraTwoTriggerHelper
@Description : Created as part of user story #SFS-5399
@Test Class  : FSM_DCFInfraTwoTriggerTest
@Date        : 28-June-2024
********************************************************************************************************/
public with sharing class FSM_DCFInfraTwoTriggerHandler implements FSM_TriggerBaseHandler {

      public static Boolean triggerDisabled = false;

      string binVar = '';
 
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return triggerDisabled;
    }
    
    //For Before Insert functionalities
    public void beforeInsert(List<sObject> newList) {
        binVar = '';
    }
    
    //For After insert functionalities 
    public void afterInsert(Map<Id, sObject> newMap) {
        binVar = '';
         }
    
    //For Before Update functionalities
    public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        binVar = '';
    }
    
    //For After Update functionalities
    public void afterUpdate(Map<Id, sObject> newMap,  Map<Id, sObject> oldMap) {
        FSM_DCFInfraTwoTriggerHelper helper=new FSM_DCFInfraTwoTriggerHelper();
             helper.generatePdf(newMap,oldMap);
    }

}
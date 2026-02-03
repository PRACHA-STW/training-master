/********************************************************************************************************
@Author      : Aishwarya Bhosale
@Description : This class calls FSM_DCFInfraTriggerHelper
@Description : Created as part of user story #SFS-3841
@Test Class  : FSM_DCFInfratriggerTest
@Date        : 15-Dec-2023
********************************************************************************************************/
public with sharing class FSM_DCFInfraTriggerHandler implements FSM_TriggerBaseHandler{
    
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
       
         }
    
    //For Before Update functionalities
    public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    }
    
    //For After Update functionalities
    public void afterUpdate(Map<Id, sObject> newMap,  Map<Id, sObject> oldMap) {
        FSM_DCFInfraTriggerHelper helper=new FSM_DCFInfraTriggerHelper();
             helper.generatePdf(newMap,oldMap);
    }

}
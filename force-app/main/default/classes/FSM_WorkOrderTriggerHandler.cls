/********************************************************************************************************
@Author      : Arnob Dey
@Description : This trigger is used to invoke FSM_WorkOrderTriggerHelper class
@Description : Created as part of user story #SFS-318
@description : Invoked from FSM_WorkOrderTrigger
@Test Class  : FSM_WorkOrderTriggerHandlerTest // FSM_GISAPIHandlerTest
@Date        : 07-July-2023
********************************************************************************************************/
public with sharing class FSM_WorkOrderTriggerHandler implements FSM_TriggerBaseHandler{
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
    public void beforeInsert(List<sObject> newWorkOrders) {
        FSM_WorkOrderTriggerHelper.copyCustomerInformation(newWorkOrders);
    }
    
    /**
     * @description :to handle after update logic
     * @param newMap
     * @param oldMap
    */
    public void afterUpdate(Map<Id, sObject> newMap,Map<Id, sObject> oldMap){
       FSM_WorkOrderTriggerHelper helper = new FSM_WorkOrderTriggerHelper();
         //Commenting GIS callout as Part of SFI-1257
       /**helper.sendToGIS(newMap,oldMap);
       helper.gisResponseUpdated(newMap,oldMap); //To Send Email to GIS based on response received */
      helper.generatePdf(newMap,oldMap);
		        
    }
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
/********************************************************************************************************
@Author      : Arnob Dey
@Description : This trigger is used to call FSM_WorkOrderTriggerHandler class.
@Description : Created as part of user story #SFS-318
@Test Class  : FSM_WorkOrderTriggerHandlerTest 
@Date        : 07-July-2023
********************************************************************************************************/
trigger FSM_WorkOrderTrigger on WorkOrder (before insert, before update, after insert, after update) {
        // Parameter : TriggerHandler class , API Name of Custom settings entry
        FSM_TriggerBaseDispatcher.run(new FSM_WorkOrderTriggerHandler(), 'FSM_ToggleLogic__c');   
}
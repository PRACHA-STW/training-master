/********************************************************************************************************
@Author      : Subir Maji
@Description : This trigger is used to call FSM_WorkHistoryTriggerHandler class.
@Description : Created as part of user story #SFI-2152
@Test Class  : FSM_WorkHistoryTriggerHandlerTest 
@Date        : 30-May-2024
********************************************************************************************************/
trigger FSM_WorkHistoryTrigger on FSM_WorkHistory__c (before insert, before update, after insert, after update) {
	// Parameter : TriggerHandler class , API Name of Custom settings entry
    FSM_TriggerBaseDispatcher.run(new FSM_WorkHistoryTriggerHandler(), 'FSM_ToggleLogic__c');
}
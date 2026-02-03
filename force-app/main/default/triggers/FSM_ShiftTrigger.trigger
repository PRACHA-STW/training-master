/********************************************************************************************************
@Author      : Subir Maji
@Description : This trigger is used to call FSM_ShiftTriggerHandler class.
@Description : Created as part of user story #SFI-2314
@Test Class  : FSM_ShiftTriggerHelperTest
@Date        : 26-June-2024
********************************************************************************************************/
trigger FSM_ShiftTrigger on Shift (before insert, before update, after insert, after update) {
    //Parameter : TriggerHandler class , API Name of Custom settings entry
    FSM_TriggerBaseDispatcher.run(new FSM_ShiftTriggerHandler(), 'FSM_ToggleLogic__c');
}
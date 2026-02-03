/********************************************************************************************************
@Author      : Subir Maji
@Description : This trigger is used to call FSM_DCFInfraLine1TriggerHandler class.
@Description : Created as part of user story #SFI-2041
@Test Class  : FSM_DCFInfraLine1TriggerHelperTest 
@Date        : 01-Aug-2024
********************************************************************************************************/
trigger FSM_DCFInfraLine1Trigger on FSM_DCFLineItemInfra__c (before insert, before update, after insert, after update) {
    // Parameter : TriggerHandler class , API Name of Custom settings entry
    FSM_TriggerBaseDispatcher.run(new FSM_DCFInfraLine1TriggerHandler(), 'FSM_ToggleLogic__c');
}
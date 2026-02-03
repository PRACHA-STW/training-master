/********************************************************************************************************
@Author      : Subir Maji
@Description : This trigger is used to call FSM_DCFInfraLine2TriggerHandler class.
@Description : Created as part of user story #SFI-2041
@Test Class  : FSM_DCFInfraLine2TriggerHelperTest 
@Date        : 01-Aug-2024
********************************************************************************************************/
trigger FSM_DCFInfraLine2Trigger on FSM_InfraDataCaptureLineItem2__c (before insert, before update, after insert, after update) {
    // Parameter : TriggerHandler class , API Name of Custom settings entry
    FSM_TriggerBaseDispatcher.run(new FSM_DCFInfraLine2TriggerHandler(), 'FSM_ToggleLogic__c');
}
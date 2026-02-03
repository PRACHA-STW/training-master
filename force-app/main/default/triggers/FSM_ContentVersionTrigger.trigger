/********************************************************************************************************
@Author      : Deepak Moudekar
@Description : This trigger is used to update content version type & publish platform event.
@Description : Created as part of user story #SFI-24
@Test Class  : FSM_ContentVersionTriggerHandlerTest
@Date        : 13-June-2023
********************************************************************************************************/
trigger FSM_ContentVersionTrigger on ContentVersion (before insert, after insert, before update, after update) {
     // Parameter : TriggerHandler class , API Name of Custom settings entry
      FSM_TriggerBaseDispatcher.run(new FSM_ContentVersionTriggerHandler(),'FSM_ToggleLogic__c');
}
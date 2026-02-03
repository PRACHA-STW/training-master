/********************************************************************************************************
@Author      : Aishwarya Bhosale
@Description : This trigger is used to update content document link ShareType and Visibility fields so that community users will be able to view files
@Description : Created as part of user story #SFS-3017
@Test Class  : FSM_ContentDocLinkTriggerTest
@Date        : 10-Nov-2023
********************************************************************************************************/
trigger FSM_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before update, after update) {
FSM_TriggerBaseDispatcher.run(new FSM_ContentDocumentLinkTriggerHandler(),'FSM_ToggleLogic__c');
}
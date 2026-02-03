/********************************************************************************************************
@Author      : Aishwarya Bhosale
@Description : This trigger is used to create task to send service report via mailjet
@Description : Created as part of user story #SFS-5350
@Test Class  : FSM_ServiceReportTrigger
@Date        : 20-May-2024
********************************************************************************************************/
trigger FSM_ServiceReportTrigger on ServiceReport (before insert, after insert, before update, after update) {
FSM_TriggerBaseDispatcher.run(new FSM_ServiceReportTriggerHandler(), 'FSM_ToggleLogic__c');
}
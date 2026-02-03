/********************************************************************************************************
@Author      : Aishwarya Bhosale
@Description : This trigger is used to generate pdf of Follow on work request form
@Description : Created as part of user story #SFS-3841
@Test Class  : FSM_DCFInfratriggerTest
@Date        : 15-Dec-2023
********************************************************************************************************/
trigger FSM_DCFInfraTrigger on FSM_DataCaptureFormInfra__c (before insert, after insert, before update, after update) {
 // Parameter : TriggerHandler class , API Name of Custom settings entry
      FSM_TriggerBaseDispatcher.run(new FSM_DCFInfraTriggerHandler(),'FSM_ToggleLogic__c');
}
/********************************************************************************************************
@Author      : Brajesh Kumar
@Description : This trigger is used to generate pdf of Sewerage FWR
@Description : Created as part of user story #SFS-3841
@Test Class  : FSM_DCFInfraTwoTriggerTest
@Date        : 28-June-2024
********************************************************************************************************/
trigger FSM_DCFInfraTwoTrigger on FSM_InfraDataCaptureForm2__c (before insert, after insert, before update, after update) {
 // Parameter : TriggerHandler class , API Name of Custom settings entry
      FSM_TriggerBaseDispatcher.run(new FSM_DCFInfraTwoTriggerHandler(),'FSM_ToggleLogic__c');
}
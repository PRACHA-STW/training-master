/********************************************************************************************************
@Author      : Srikanth Palla
@Description : This trigger is used to call FSM_ServiceAppointmentTriggerHandler class.
@Description : Created as part of user story #SFI-21
@Test Class  :  FSM_GISAPIHandlerTest
@Date        : 04-Aug-2023
********************************************************************************************************/
trigger FSM_ServiceAppointmentTrigger on ServiceAppointment (before insert,after insert,before update,after update) {
 // Parameter : TriggerHandler class , API Name of Custom settings entry
        FSM_TriggerBaseDispatcher.run(new FSM_ServiceAppointmentTriggerHandler(), 'FSM_ToggleLogic__c');
}
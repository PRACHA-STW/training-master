/********************************************************************************************************
@Author      : Srikanth Palla
@description : This Batch class is used to delete WO and related SA records.
@description : Created as part of user story #SFI-1783
@Test Class  : FSM_PurgeOrphanWorkOrderSABatchTest
@Date        : 23-April-2024
********************************************************************************************************/
public with sharing class FSM_PurgeOrphanWorkOrderSABatch implements Database.Batchable<sObject>{
    
    
 /********************************************************************************************************
 @description : This Method is used to query all Temporary Workorder and SA records
  @param  bc object containing information about the batch job context.
  @return     Database.QueryLocator for the batch job's start.
    ********************************************************************************************************/ 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime createdDateTime = System.now().addMinutes(-5);
        if(Test.isRunningTest()){
            createdDateTime = System.now().addMinutes(10);
        }
        
        return Database.getQueryLocator([
            select id,(select id from ServiceAppointments) from WorkOrder 
            WHERE FSM_IsTemporaryRecord__c = true AND CreatedDate <= :createdDateTime WITH SECURITY_ENFORCED
        ]);
    }
    
    /********************************************************************************************************
  @description : This Method is used perform deletion of WO and SA records
  @param bc context Database.BatchableContext object containing information about the batch job context.
  @param workorderDeletionList
    ********************************************************************************************************/ 
    public void execute(Database.BatchableContext bc, List<WorkOrder> workorderDeletionList) {
        Map<ID,serviceappointment> serviceappointmentDeletionList = new Map<ID,serviceappointment>(); //To collect the Service Appointment for deletion
        
         if(workorderDeletionList != null && !workorderDeletionList.isEmpty()){
            serviceappointmentDeletionList = new Map<ID,serviceappointment>([select id 
                                                                             from serviceappointment 
                                                                             where FSSK__FSK_Work_Order__c in :workorderDeletionList WITH SECURITY_ENFORCED]);
         }
        try{
        	deleteSaWoRecords(serviceappointmentDeletionList.values(), workorderDeletionList);
        }
        catch(Exception ex){
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_PurgeOrphanWorkOrderSABatch').setErrorMessage(ex.getMessage()).setLineNumber(String.ValueOF(ex.getLineNumber())).setMethodName('execute').setStackTrace(ex.getStackTraceString()).setType('Field Service').create();
        }
       
    }
    
    /********************************************************************************************************
    @description : This Method is used make a call to scheduler and schedule job every 5 minutes.
    @param serviceappointmentDeletionList
    @param workorderDeletionList
    ********************************************************************************************************/ 
    private void deleteSaWoRecords(List<ServiceAppointment> serviceappointmentDeletionList, List<WorkOrder> workorderDeletionList){
        If(serviceappointmentDeletionList != null && !serviceappointmentDeletionList.isEmpty()
           && Schema.sObjectType.ServiceAppointment.isDeletable()){
               delete serviceappointmentDeletionList;
           }
            
        If(workorderDeletionList != null && !workorderDeletionList.isEmpty()
           && Schema.sObjectType.workorder.isDeletable()){
               delete workorderDeletionList;
           }
            
    }
    /********************************************************************************************************
    @description : This Method is used make a call to scheduler and schedule job every 5 minutes.
    @param bc context Database.BatchableContext object containing information about the batch job context.
    ********************************************************************************************************/ 
    public void finish(Database.BatchableContext bc) {
        
        Datetime sysTime=System.now().addSeconds(300);
        String cronExpression=' ' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName='FSM_PurgeOrphanWorkOrderSASchedule';
        if(Test.isRunningTest()){
            strJobName='FSM_PurgeOrphanWorkOrderSAScheduleTest';
        }
        System.schedule(strJobName,cronExpression,new FSM_PurgeOrphanWorkOrderSASchedule());
    }
}
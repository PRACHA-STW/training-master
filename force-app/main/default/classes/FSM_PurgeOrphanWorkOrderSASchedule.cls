/********************************************************************************************************
@Author      : Srikanth Palla
@description : This Batch class is used to delete WO and related SA records.
@description : Created as part of user story #SFI-1783
@Test Class  : FSM_PurgeOrphanWorkOrderSABatchTest
@Date        : 23-April-2024
********************************************************************************************************/
public class FSM_PurgeOrphanWorkOrderSASchedule implements Schedulable {
    
    /********************************************************************************************************
@description : This Method is used Schedule the Batch job.
@param     : context Database.BatchableContext object containing information about the batch job context.
********************************************************************************************************/ 
    public void execute(SchedulableContext sc) {
        
        FSM_PurgeOrphanWorkOrderSABatch batch = new FSM_PurgeOrphanWorkOrderSABatch();
        Database.executeBatch(batch,20);
        System.abortJob(sc.getTriggerID());
    }
    
    
}
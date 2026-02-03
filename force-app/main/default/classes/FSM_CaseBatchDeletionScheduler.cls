/********************************************************************************************************
@Author      : Himanshu Dobriyal
@description : This class is to schedule FSM_CaseBatchDeletion batch.
@description : Created as part of user story #SFI-468
@Test Class  : FSM_CaseBatchDeletionTest
@Date        : 24-July-2023
********************************************************************************************************/
public with sharing class FSM_CaseBatchDeletionScheduler implements Schedulable {
    
    /**
    * Executes the scheduled batch job for case deletion.
    * Instantiates the FSM_CaseBatchDeletion batch class and starts the batch job.
    * @param sc SchedulableContext object containing information about the scheduled job context.
    */
    public void execute(SchedulableContext sc) {
        // Instantiate the batch class
        FSM_CaseBatchDeletion batchDeletion = new FSM_CaseBatchDeletion();
        
        // Start the batch job
        Database.executeBatch(batchDeletion, FSM_CaseBatchDeletion.BATCH_SIZE);
    }
}
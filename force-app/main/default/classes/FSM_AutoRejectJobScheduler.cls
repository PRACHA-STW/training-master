/********************************************************************************************************
@Author      : Nishant Kumar
@description : This class contains actual logic of a batch job for auto-reject service appointment
@description : Created as part of user story #SFS-7456
@description : Used to invoke FSM_AutoRejectJobBatch class where the actual logic is written
@Test Class  : FSM_AutoRejectJobSchedulerTest
@Date        : 17th-September-2024
@Last Modified By : Brajesh Kumar
********************************************************************************************************/
public with sharing class FSM_AutoRejectJobScheduler implements Schedulable { 
    
    // Construct the query to be passed to the batch job
    private String jobRunQuery = 'SELECT Id FROM ServiceAppointment WHERE Status = \'New\' AND IsBundleMember = TRUE AND FSM_RejectBundle__c = TRUE AND ServiceTerritoryId IN :territoryIds'; 
    /**
* @description empty constructor
*/
    public FSM_AutoRejectJobScheduler(){
    }
    /**

/**
* @description parameterised constructor
*/
    public FSM_AutoRejectJobScheduler(String queryParam){
        if(queryParam!= NULL){
            this.jobRunQuery = queryParam;            
        }
    }
    /**
* @description execute
* @param sc
*/
    public void execute(SchedulableContext context) {
        // FSM_AutoRejectJobBatch batch = new  FSM_AutoRejectJobBatch(jobRunQuery,territoryIds);
        FSM_AutoRejectJobBatch batch = new FSM_AutoRejectJobBatch(jobRunQuery);
        Database.executeBatch(batch, FSM_AutoClosureSABatch.BATCH_SIZE);
    }
}
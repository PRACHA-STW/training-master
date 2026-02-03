/********************************************************************************************************
@Author      : Arnob Dey
@description : This class is created to schedule a job to auto-dispatch service appointment
@description : Created as part of user story #SFS-814
@description : Used to invoke FSM_DispatchSABatch class where the actual logic is written
@Test Class  : FSM_DispatchSATest
@Date        : 24-July-2023
********************************************************************************************************/
global with sharing class FSM_DispatchSAScheduler implements Schedulable{
    // Construct the query to be passed to the batch job
    private String jobRunQuery = 'SELECT Id, ServiceResourceId,ServiceResource.Name, ServiceTerritory.FSM_NumberOfDaysToDispatch__c, ServiceTerritory.FSM_NumberOfSAToDispatch__c FROM ServiceTerritoryMember WHERE (EffectiveEndDate > :dtm OR EffectiveEndDate = NULL) AND ServiceTerritory.FSM_NumberOfDaysToDispatch__c <> NULL AND ServiceTerritory.FSM_NumberOfDaysToDispatch__c!= \'None\'';
    
    /**
     * @description empty constructor
     */
    global FSM_DispatchSAScheduler(){
    }
    /**
     * @description parameterised constructor
     * @param jobRunQuery
     */
    global FSM_DispatchSAScheduler (String queryParam){
        if(queryParam!= NULL){
            this.jobRunQuery = queryParam;            
        }
    }
    /**
     * @description execute
     * @param sc
     */
    global void execute(SchedulableContext sc){
        // Schedule the batch job with the constructed query
        FSM_DispatchSABatch batch = new FSM_DispatchSABatch(jobRunQuery);
        Database.executeBatch(batch, FSM_DispatchSABatch.BATCH_SIZE);
    }
}
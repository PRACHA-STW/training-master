/*------------------------------------------------------------
* @description:  A test class created to delete Integration and Error log records.               
* @group      :  Capgemini
* Test Class  :  FSM_DeleteBatchLog_Test
* ver    Date                Author             Modification
1.0    23th June 2023       Srikanth           Created-SFI-193
------------------------------------------------------------*/
global class FSM_DeleteBatchLog implements Database.Batchable<sObject>,System.Schedulable{
private integer queryIndex;
@TestVisible
/**
 * @description to get queries listQueries
 */
    public List<FSM_BatchClassQueries__mdt> listQueries {
        get {
            if (listQueries == null) {
                this.listQueries = [
                    SELECT FSM_Query__c
                    FROM FSM_BatchClassQueries__mdt
                    WHERE FSM_Active__c = true AND FSM_Type__c='Delete'  WITH SECURITY_ENFORCED ORDER BY FSM_SequenceNumber__c];
            }

            return listQueries;
        }
        private set;
    }
    
/**
 * @description FSM_DeleteBatchLog 
 */
    global FSM_DeleteBatchLog(){
        this.queryIndex = 0;
    }
/**
 * @description runBatch method
 */
    global void runBatch(){
        if(this.queryIndex < this.listQueries.size()){
            Database.executeBatch(this, 200);
        }
    }
/**
 * @description execute method
 * @param sc
 */
    global void execute(SchedulableContext sc){
        runBatch();
    }
/**
 * @description Start method
 * @param bc
 * @return Database.QueryLocator
 */
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(listQueries[queryIndex].FSM_Query__c);
    }
/**
 * @description execute method
 * @param bc
 * @param lst
 */
    global void execute(Database.BatchableContext bc, List<sObject> lst){

           delete lst;

    }
/**
 * @description finish method
 * @param bc
 */
    global void finish(Database.BatchableContext bc){
        this.queryIndex++;
        runBatch();
    }

}
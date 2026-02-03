/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class contains actual logic of a batch job to auto-complete service appointment
@description : Created as part of user story #SFS-3024
@description : Used to invoke FSM_AutoClosureSABatch class where the actual logic is written
@Test Class  : FSM_AutoClosureSATest
@Date        : 11th-December-2023
********************************************************************************************************/
global class  FSM_AutoClosureSAScheduler implements Schedulable {
    
    private String jobRunQuery;
    List<String> serviceTerritoriesNames = new List<String>();
    List<Id> serviceTerritoriesIds = new List<Id>();
    /**
* @description empty constructor
*/
    global FSM_AutoClosureSAScheduler(){
        /**  Service Territories Name from BatchProcess__mdt CMDT */
        List<FSM_BatchProcess__mdt> batchProcessCMDT = FSM_BatchProcess__mdt.getAll().values();
        for (FSM_BatchProcess__mdt mdtLst : batchProcessCMDT) {
            serviceTerritoriesNames.add(mdtLst.Service_Territory__c);
        }
        if(serviceTerritoriesNames.size()>0){
            List<ServiceTerritory> serviceTerritories = [Select Id,Name from ServiceTerritory where Name In :serviceTerritoriesNames WITH SECURITY_ENFORCED];
            for (ServiceTerritory territory : serviceTerritories) {
                serviceTerritoriesIds.add(territory.Id);
            }
        }
      	 if(jobRunQuery == NULL){ 
            jobRunQuery = 'SELECT Id, Status FROM ServiceAppointment WHERE Status IN (\'Scheduled\', \'Dispatched\') AND SchedStartTime >=:schedStartDate AND SchedStartTime < :schedEndDate';
         }
    }

    /**
    /**
* @description execute
* @param sc
*/
    global void execute(SchedulableContext sc) {   
        FSM_AutoClosureSABatch batch = new FSM_AutoClosureSABatch(jobRunQuery,serviceTerritoriesIds);
        Database.executeBatch(batch, FSM_AutoClosureSABatch.BATCH_SIZE);
    }
}
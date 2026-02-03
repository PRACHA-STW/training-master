/********************************************************************************************************
@Author      : Nishant Kumar
@description : This class contains actual logic of a batch job for auto-reject service appointment
@description : Created as part of user story #SFS-7456
@description : SAs generated for dummy users should be forcefully rejected 24 hours after the due date of the bundle SA.
@Date        : 17-September-2024
@modified Date: 01/10/2024 
@Last Modified By : Brajesh Kumar
********************************************************************************************************/
public class FSM_AutoRejectJobBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private String jobRunQuery;
    public static final Integer BATCH_SIZE = Integer.valueOf(System.Label.FSM_AutoRejectBathSize); //To have the Batch size
    Set<Id> territoryIds = new Set<Id>();
    
    
    /**
* @description parameterised constructor 
*/ 
    public FSM_AutoRejectJobBatch(String jobRunQuery){
        this.jobRunQuery = jobRunQuery; 
    }
    
    
    /*** @description start**/
    public Database.QueryLocator start(Database.BatchableContext bc) {
         List<FSM_BatchProcess__mdt> batchProcesses = [SELECT Process_Name__c,Service_Territory__c FROM FSM_BatchProcess__mdt WHERE Process_Name__c = 'Shift Round Territories'];
            Set<String> territoryNames = new Set<String>();
            for (FSM_BatchProcess__mdt batchProcess : batchProcesses) {
                territoryNames.add(batchProcess.Service_Territory__c);
            }
            List<ServiceTerritory> territories = [SELECT Id FROM ServiceTerritory WHERE Name IN :territoryNames];
            Set<Id> territoryIds = new Set<Id>();
            for (ServiceTerritory territory : territories) {
                territoryIds.add(territory.Id);
            }    
        if(jobRunQuery == NULL){  
               
            jobRunQuery = 'SELECT Id FROM ServiceAppointment WHERE Status = \'New\' AND IsBundleMember = TRUE AND FSM_RejectBundle__c = TRUE AND ServiceTerritoryId IN :territoryIds';
        }   
        
        System.debug('territoryIds----> '+territoryIds);
        return Database.getQueryLocator(jobRunQuery);
    }
    
    /*** @description execute**/    
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment varSa : scope) {
            ServiceAppointment sa = new ServiceAppointment();
            sa.Id = varSa.Id;
            sa.Status = 'Rejected';
            sa.FSM_ReasonCategory__c = 'AUTO';
            sa.FSM_RejectReason__c = 'AUTO';
            appointmentsToUpdate.add(sa);
        }
        // Update Service Appointments 
        if(appointmentsToUpdate.size() > 0) {
            try {
                Database.SaveResult[] updateResult = Database.update(appointmentsToUpdate,false);
                for (Integer i = 0; i < updateResult.size(); i++) {
                    if (!updateResult[i].isSuccess()) {
                        //Error ecountered              
                        for(Database.Error error : updateResult[i].getErrors()){
                            //Handle error                           
                            FSM_ErrorLog__c errorLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_AutoRejectJobBatch').setErrorMessage(error.getMessage()+' Failed record id: '+updateResult[i].getId()).setMethodName('execute').setType('Field Service').create();                                                       
                        }
                    }
                }
            } 
            //If there is an exception, log it in the error log object
            catch (Exception e) {FSM_ErrorLog__c errorLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_AutoRejectJobBatch').setErrorMessage(e.getMessage()).setLineNumber(String.ValueOF(e.getLineNumber())).setMethodName('execute').setStackTrace(e.getStackTraceString()).setType('Field Service').create();e.setMessage('Error occurred while trying to reject service appointment'); } 
        }
    }
    /*** @description finish**/
    public void finish(Database.BatchableContext bc) {
        // finish
    }
}
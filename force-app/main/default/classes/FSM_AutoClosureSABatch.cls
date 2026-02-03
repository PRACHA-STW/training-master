/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class contains actual logic of a batch job to auto-Complete service appointment
@description : Created as part of user story #SFS-3024
@description : SAs generated for dummy users should be force completed after the 30 days of Scheduled start date 
@Date        : 07-December-2023
********************************************************************************************************/
global without sharing class FSM_AutoClosureSABatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private String jobRunQueryMaster;
    
    public static final Integer BATCH_SIZE = Integer.valueOf(System.Label.FSM_SABatchJobSize); //To have the Batch size
    List<Id> territoryIds = new List<Id>();
    
    // Logic to get Schedule start date + 30 days
    Date currentDate = Date.today();
    Datetime schedStartDate = Datetime.newInstance(currentDate.addDays(-31), Time.newInstance(0, 0, 0, 0));
    Datetime schedEndDate = Datetime.newInstance(currentDate.addDays(-30), Time.newInstance(0, 0, 0, 0));
    /* * @description parameterised constructor*/
    global FSM_AutoClosureSABatch(String jobRunQuery,List<Id> territoryId) {
        territoryIds.addAll(territoryId);
        jobRunQueryMaster = (territoryId.size() > 0 ? jobRunQuery + ' AND ServiceTerritoryId IN :territoryIds' : jobRunQuery);
    }
    /*** @description start**/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(jobRunQueryMaster);
    }
    
    /*** @description execute**/    
    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        List<FeedItem> feedToUpdate = new List<FeedItem>();
        for(ServiceAppointment varSa : scope) {
            ServiceAppointment sa = new ServiceAppointment();
            FeedItem feedItem = new FeedItem();
            sa.Id = varSa.Id;
            sa.Status = 'Completed';
            feedItem.ParentId = sa.Id;
            feedItem.Body = 'Completed by auto closure job.';
            appointmentsToUpdate.add(sa);
            feedToUpdate.add(feedItem);
        }
        // Update Service Appointments 
        if(appointmentsToUpdate.size() > 0) {
            try {
                Database.SaveResult[] updateResult = Database.update(appointmentsToUpdate,false);
                List<FeedItem> successfullFeeds = new List<FeedItem>();
                for (Integer i = 0; i < updateResult.size(); i++) {
                    if (updateResult[i].isSuccess()) {
                        // Add corresponding feed item for successful updates
                        successfullFeeds.add(feedToUpdate[i]);
                    }
                    else if (!updateResult[i].isSuccess()) {
                        //Error ecountered              
                        for(Database.Error error : updateResult[i].getErrors()){
                            //Handle error                           
                            FSM_ErrorLog__c errorLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_AutoClosureSABatch').setErrorMessage(error.getMessage()+' Failed record id: '+updateResult[i].getId()).setMethodName('execute').setType('Field Service').create();                                                       
                        }
                    }
                }
                // Bulk insert successful feed items
                if (!successfullFeeds.isEmpty()) {
                    Database.insert(successfullFeeds, false);
                }
                
            }
            //If there is an exception, log it in the error log object
            catch (Exception e) {FSM_ErrorLog__c errorLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_AutoClosureSABatch').setErrorMessage(e.getMessage()).setLineNumber(String.ValueOF(e.getLineNumber())).setMethodName('execute').setStackTrace(e.getStackTraceString()).setType('Field Service').create();e.setMessage('Error occurred while trying to complete service appointment'); } 
        }
    }
    /*** @description finish**/
    global void finish(Database.BatchableContext bc) {
        // finish
    }
}
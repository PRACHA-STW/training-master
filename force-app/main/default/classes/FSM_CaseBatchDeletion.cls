/********************************************************************************************************
@Author      : Himanshu Dobriyal
@description : This Batch class is used to delete case and related child records.
@description : Created as part of user story #SFI-468
@Test Class  : FSM_CaseBatchDeletionTest
@Date        : 20-July-2023
********************************************************************************************************/
public with sharing class FSM_CaseBatchDeletion implements Database.Batchable<SObject> {
    Public static final Integer BATCH_SIZE = integer.valueOf(system.label.CaseBatchSize); //To have the Batch size
    
    /********************************************************************************************************
    @Author      : Himanshu Dobriyal
    @description : This Method is used to query all case record where case record are closed & older than sepcified number of days in NumberOfPriorDaysForCaseDeletion.
    @description : Created as part of user story #SFI-468
	@param		 : context Database.BatchableContext object containing information about the batch job context.
	@return 	 : Database.QueryLocator for the batch job's start.
    @Date        : 20-July-2023
    ********************************************************************************************************/ 
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        datetime priorDate = system.now().addDays(-(integer.valueOf(system.label.NumberOfPriorDaysForCaseDeletion))); //Getting that how many prior days we need to look for
        //If Coming from test class then set teh priorDate to today so that deletion happen immidiately
        if(Test.isRunningTest()){
            priorDate =system.now();
        }
        return Database.getQueryLocator([select id from case where closeddate <=:priorDate WITH SECURITY_ENFORCED]);
    }
    
    /********************************************************************************************************
    @Author      : Himanshu Dobriyal
    @description : This Method is used to Execute the Logic for all case record where case record 
    are closed & older than sepcified number of days in NumberOfPriorDaysForCaseDeletion.
    @description : Created as part of user story #SFI-468
	@param 		 : context Database.BatchableContext object containing information about the batch job context.
	@param 		 : caseRecordsforDeletion List of Case records to be deleted.
    @Date        : 20-July-2023
	@Date		 : Updated by Subir Maji, 26th June 2024 as part of SFI-2314 to add IsBundle check
    ********************************************************************************************************/ 
    public void execute(Database.BatchableContext context, List<case> caseRecordsforDeletion) {
        Map<ID,workorder> workorderDeletionList = new Map<ID,workorder>(); //To collect the work order for deletion
        Map<ID,serviceappointment> serviceappointmentDeletionList = new Map<ID,serviceappointment>(); //To collect the Service Appointment for deletion
        Map<ID,FSL__Time_Dependency__c> appointmentDependencyDeletionList = new Map<ID,FSL__Time_Dependency__c>(); //To collect the Service Appointment dependency for deletion
        Map<ID,serviceappointment> bundleMemberAppDeletionList = new Map<ID,serviceappointment>(); //To collect the Service Appointment Bundle Members for deletion, Subir Maji SFI-2314 1st July 24
        Map<ID,FSM_TMAPermit__c> tmaPermitDeletionList = new Map<ID,FSM_TMAPermit__c>(); //To collect the TMA Permit for deletion
        Map<ID,FSM_DataCaptureFormInfra__c> dataCaptureFormInfraDeletionList = new Map<ID,FSM_DataCaptureFormInfra__c>(); //To collect the DCF Infra for deletion
        Map<ID,FSM_DataCaptureFormNonInfra__c> dataCaptureFormNonInfraDeletionList = new Map<ID,FSM_DataCaptureFormNonInfra__c>(); //To collect the DCF Non Infra for deletion
        FSM_TMAPermit__c tmaPermit; //To create temp record for TMA permit
        
        //To Collect Work Order records
        if(caseRecordsforDeletion != null && !caseRecordsforDeletion.isEmpty()) {
            workorderDeletionList = New Map<ID,workorder>([select id,FSM_TMAPermit__c 
                                                           from workorder 
                                                           where caseid in :caseRecordsforDeletion WITH SECURITY_ENFORCED]);
            // To collect all related TMA records
            for (workorder workorderForDeletion : workorderDeletionList.values()) {
                if(workorderForDeletion.FSM_TMAPermit__c != null){
                    tmaPermit = new FSM_TMAPermit__c();
                    tmaPermit.ID = workorderForDeletion.FSM_TMAPermit__c;
                    tmaPermitDeletionList.put(workorderForDeletion.FSM_TMAPermit__c, tmaPermit);
                }
            }
        }
        
        //To Collect Service Appointments and data capture form
        if(workorderDeletionList != null && !workorderDeletionList.isEmpty()){
            serviceappointmentDeletionList = new Map<ID,serviceappointment>([select id 
                                                                             from serviceappointment 
                                                                             where FSSK__FSK_Work_Order__c in :workorderDeletionList.keySet() WITH SECURITY_ENFORCED]);
            
            dataCaptureFormInfraDeletionList = New Map<ID,FSM_DataCaptureFormInfra__c>([select id 
                                                                                        from FSM_DataCaptureFormInfra__c 
                                                                                        where FSM_WorkOrder__c in :workorderDeletionList.keySet() WITH SECURITY_ENFORCED]);
            
            dataCaptureFormNonInfraDeletionList = New Map<ID,FSM_DataCaptureFormNonInfra__c>([select id 
                                                                                              from FSM_DataCaptureFormNonInfra__c 
                                                                                              where FSM_WorkOrder__c in :workorderDeletionList.keySet() WITH SECURITY_ENFORCED]);
        }
        
        //To collect Service appointment dependency and buldle members
        if(serviceappointmentDeletionList != null && !serviceappointmentDeletionList.isEmpty()){
            appointmentDependencyDeletionList = New Map<ID,FSL__Time_Dependency__c>([select id 
                                                                                     from FSL__Time_Dependency__c 
                                                                                     where FSL__Service_Appointment_1__c in :serviceappointmentDeletionList.keySet() WITH SECURITY_ENFORCED]);
        	//Subir Maji SFI-2314 1st July 24
            bundleMemberAppDeletionList = New Map<ID,ServiceAppointment>([select id 
                                                                          from ServiceAppointment 
                                                                          where RelatedBundleId in :serviceappointmentDeletionList.keySet() WITH SECURITY_ENFORCED]);
        	
            //Remove Duplicate record in multiple list, Subir Maji SFI-2314 1st July 24
            if(bundleMemberAppDeletionList != null && !bundleMemberAppDeletionList.IsEmpty()){
                for(Id appID : bundleMemberAppDeletionList.keySet()){
                    if(serviceappointmentDeletionList.ContainsKey(appID)){
                        serviceappointmentDeletionList.remove(appID);
                    }
                }
            }
        }
        //To pass all the map value for deletion to methods deleteDCFRecords,deleteTMAandSADepRecords and deleteSaWoCaseRecords.
        try{
            deleteDCFRecords(dataCaptureFormNonInfraDeletionList.values(), dataCaptureFormInfraDeletionList.values());
            deleteTMAandSADepRecords(tmaPermitDeletionList.values(), appointmentDependencyDeletionList.values(), bundleMemberAppDeletionList.Values()); //Subir Maji SFI-2314 1st July 24
            deleteSaWoCaseRecords(serviceappointmentDeletionList.values(), workorderDeletionList.values(), caseRecordsforDeletion);
        }Catch(Exception ex){
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_CaseBatchDeletion').setErrorMessage(ex.getMessage()).setLineNumber(String.ValueOF(ex.getLineNumber())).setMethodName('execute').setStackTrace(ex.getStackTraceString()).setType('Field Service').create();
        }
        
    }
    
    /********************************************************************************************************
    @Author      : Himanshu Dobriyal
    @description : This method is to delete all child related Dcf records
    @description : Created as part of user story #SFI-468
	@param 		 : dataCaptureFormNonInfraDeletionList
	@param 		 : dataCaptureFormInfraDeletionList
    @Date        : 20-July-2023
	********************************************************************************************************/ 
    private void deleteDCFRecords(List<FSM_DataCaptureFormNonInfra__c> dataCaptureFormNonInfraDeletionList, List<FSM_DataCaptureFormInfra__c> dataCaptureFormInfraDeletionList){
       IF(dataCaptureFormNonInfraDeletionList != null && !dataCaptureFormNonInfraDeletionList.isEmpty()
           && Schema.sObjectType.FSM_DataCaptureFormNonInfra__c.isDeletable()){
               delete dataCaptureFormNonInfraDeletionList;
           } 
        IF(dataCaptureFormInfraDeletionList != null && !dataCaptureFormInfraDeletionList.isEmpty()
           && Schema.sObjectType.FSM_DataCaptureFormInfra__c.isDeletable()){
                delete dataCaptureFormInfraDeletionList;
           } 
    }
    
    /********************************************************************************************************
    @Author      : Himanshu Dobriyal
    @description : This method is to delete all child related Tma and appointment dependency records
    @description : Created as part of user story #SFI-468
	@param 		 : tmaPermitDeletionList
	@param 		 : appointmentDependencyDeletionList
	@param		 : allBundleSA
    @Date        : 20-July-2023
	@Date		 : Updated by Subir Maji, 26th June 2024 as part of SFI-2314
    ********************************************************************************************************/ 
    private void deleteTMAandSADepRecords(List<FSM_TMAPermit__c> tmaPermitDeletionList, List<FSL__Time_Dependency__c> appointmentDependencyDeletionList, List<ServiceAppointment> allBundleSA){
        IF(tmaPermitDeletionList != null && !tmaPermitDeletionList.isEmpty()
           && Schema.sObjectType.FSM_TMAPermit__c.isDeletable()){
                delete tmaPermitDeletionList;
           } 
        IF(appointmentDependencyDeletionList != null && !appointmentDependencyDeletionList.isEmpty()
           && Schema.sObjectType.FSL__Time_Dependency__c.isDeletable()){
                delete appointmentDependencyDeletionList;
           }   
        //Subir Maji SFI-2314 1st July 24
        IF(allBundleSA != null && !allBundleSA.isEmpty() && Schema.sObjectType.case.isDeletable()){
            delete allBundleSA;
        }
    }
    
    /********************************************************************************************************
    @Author      : Himanshu Dobriyal
    @description : This method is to delete all case and related child service appointment and workorder records
    @description : Created as part of user story #SFI-468
	@param 		 : serviceappointmentDeletionList
	@param 		 : workorderDeletionList
	@param		 : caseRecordsforDeletion
    @Date        : 20-July-2023
	********************************************************************************************************/
    private void deleteSaWoCaseRecords(List<ServiceAppointment> serviceappointmentDeletionList, List<WorkOrder> workorderDeletionList, List<Case> caseRecordsforDeletion){
        IF(serviceappointmentDeletionList != null && !serviceappointmentDeletionList.isEmpty()
           && Schema.sObjectType.ServiceAppointment.isDeletable()){
               delete serviceappointmentDeletionList;
           }
        IF(workorderDeletionList != null && !workorderDeletionList.isEmpty()
           && Schema.sObjectType.workorder.isDeletable()){
               delete workorderDeletionList;
           }
        IF(caseRecordsforDeletion != null && !caseRecordsforDeletion.isEmpty()
           && Schema.sObjectType.case.isDeletable()){
               delete caseRecordsforDeletion;
           }    
    }
    
    /**
    * Finish method called after the batch job completes its execution.
    * This method provides an opportunity for cleanup or post-processing tasks.
    * @param context Database.BatchableContext object containing information about the batch job context.
    */
    public void finish(Database.BatchableContext context) {
        // Optional: Add cleanup or post-processing logic here
        // This method is executed after the batch job completes its execution
    }
}
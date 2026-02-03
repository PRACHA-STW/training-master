/********************************************************************************************************
@Author      : Manish Jagnani and Kaustav Chanda
@description : This class contains actual logic of a batch job to perform Backlog service appointment
@description : Created as part of user story #SFS-3028 & SFS-3043
@description : Updated as part of SFL-347 to move the query logic to Apex 18th March 2025 by Subir Maji
@description : Invoked from FSM_BacklogMaintenanceNonInfraScheduleJob scheduled trigger flow
@Test Class  : FSM_BacklogMaintenanceBatchTest
@Date        : 27-December-2023
********************************************************************************************************/
public with sharing class FSM_BacklogMaintenanceBatch implements Database.Batchable<sObject>,Schedulable{
    private String jobRunQuery;
    
    /**
    * @description constructor
    * @param saUpdatedList
    */
    public FSM_BacklogMaintenanceBatch(){} //Updated as part of SFL-347 18th March 2025 by Subir Maji
    
     /***
    * @description saListInput to invoke from Flow
    * @param void
    * Updated as part of SFL-347 18th March 2025 by Subir Maji
    */
    @InvocableMethod(label = 'BacklogMaintenance')
    public static void saListInput(){
        Id jobId = Database.executeBatch(new FSM_BacklogMaintenanceBatch());
    }
    
    /**
    *@description start
    * @param bc
    * @return Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> saStatus = new List<String>{'New'}; //Added as part of SFL-347 18th March 2025 by Subir Maji
		List<String> servOrderType = new List<String>{'ZPM1','ZPM2'}; //added as part of SFL-347 18th March 2025 by Subir Maji
		List<String> businessUnit = new List<String>{'Waste Non Infra','Water Non Infra', 'Bio Resource'}; //Added as part of SFL-347 18th March 2025 by Subir Maji
		
		if(jobRunQuery == null){
            //Updated as part of SFL-347 18th March 2025 by Subir Maji
            jobRunQuery = 'SELECT Id, Status, FSM_ServiceOrderType__c, FSM_Backlog__c, FSM_HoursUntilDueDate__c,'+ 
                'FSM_DueDateApplyCounter__c, FSM_DueDateApplyCounterZPM1__c, FSM_SAPJobPriority__c, FSM_BacklogScore__c,'+
                ' FSM_InternalSLA__c, DueDate, EarliestStartTime '+
                'FROM ServiceAppointment '+
                'WHERE Status IN: saStatus AND '+
                'FSM_ServiceOrderType__c IN : servOrderType AND '+
                'FSM_Backlog__c = false AND '+
                'FSM_BusinessUnit__c IN : businessUnit WITH SECURITY_ENFORCED';
        }
        return Database.getQueryLocator(jobRunQuery);
    }
    
    /**
    *@description execute
    * @param bc, saList
    * @return void
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> saList){
        
        //declaring an empty SA List
        List<ServiceAppointment> saNewList = new List<ServiceAppointment>();
        ServiceAppointment saReturn;
        for(ServiceAppointment sa: saList){
            //ZPM2
            if(sa.FSM_ServiceOrderType__c == 'ZPM2'){
                saReturn=zpm2(sa);
            }
            //ZPM1 
            else if(sa.FSM_ServiceOrderType__c == 'ZPM1'){
                saReturn=zpm1(sa);
            }
            saNewList.add(saReturn);
        }
        if(saNewList.Size() > 0){
            databaseSaveResult(saNewList);
        }
    }
    
    /**
    * @description finish 
    * @param context
    */
    public void finish(Database.BatchableContext context) {}
    
    /**
    * @description zpm2
    * @param sa
    * @return ServiceAppointment
    */
    Private static ServiceAppointment zpm2(ServiceAppointment sa){
        //criteria-1
        if(sa.FSM_InternalSLA__c >= 28 && sa.FSM_HoursUntilDueDate__c <= 23){
            sa.FSM_Backlog__c = TRUE;
        }
        //criteria-2 & 2.1
        if(sa.FSM_InternalSLA__c >= 5 && sa.FSM_InternalSLA__c < 28 && 
           sa.FSM_HoursUntilDueDate__c <= 23){
               if(sa.FSM_DueDateApplyCounter__c == 1){
                   sa.FSM_Backlog__c = TRUE;
               }else{
                   sa.DueDate=sa.DueDate+7;
                   sa.FSM_DueDateApplyCounter__c = sa.FSM_DueDateApplyCounter__c + 1;
               }
           }
        //criteria-3 & criteria-3.1
        if(sa.FSM_InternalSLA__c >= 3 && sa.FSM_InternalSLA__c <= 4 && 
           sa.FSM_HoursUntilDueDate__c <= 23){
               if(sa.FSM_DueDateApplyCounter__c == 1){
                   sa.FSM_Backlog__c = TRUE;
               }else{
                   sa.DueDate=sa.DueDate+7;
                   sa.FSM_DueDateApplyCounter__c = sa.FSM_DueDateApplyCounter__c + 1;
               } 
           }
        //criteria-4
        if(sa.FSM_InternalSLA__c == 1 && sa.FSM_HoursUntilDueDate__c <= 23){
            sa.FSM_Backlog__c = TRUE;
        }
        return sa;
    }
    
    /**
    * @description zpm1
    * @param sa
    * @return ServiceAppointment
    */ 
    Private static ServiceAppointment zpm1(ServiceAppointment sa){
        //Scenario 1
        scenarioOne(sa);
        
        //Scenario 2
        if((sa.FSM_SAPJobPriority__c==5||sa.FSM_SAPJobPriority__c==6||
            sa.FSM_SAPJobPriority__c==7 || sa.FSM_SAPJobPriority__c==8) && (sa.FSM_HoursUntilDueDate__c <=23))
        {
            
            if(sa.FSM_DueDateApplyCounterZPM1__c == 2){
                sa.FSM_Backlog__c = TRUE;
            }
            else{
                sa.DueDate=sa.DueDate+7;
                sa.FSM_DueDateApplyCounterZPM1__c =sa.FSM_DueDateApplyCounterZPM1__c + 1;   
            }
            
        }
        // Scenario 3 
        if((sa.FSM_SAPJobPriority__c==9||sa.FSM_SAPJobPriority__c==10) && (sa.FSM_HoursUntilDueDate__c <=23)){
            sa.FSM_Backlog__c = TRUE;  
        }
        
        return sa;
    }
    
    /**
    * @description databaseSaveResult
    * @param saList
    */
    private static void databaseSaveResult(List<ServiceAppointment> saList){
        try{
            Database.SaveResult[] updateResult = Database.update(saList,false);
            List<FSM_ErrorLog__c> errLogs= new List<FSM_ErrorLog__C>();
            for (Database.SaveResult result : updateResult){
                if (!result.isSuccess()) {
                    //Error ecountered              
                    for(Database.Error error : result.getErrors()){
                        //Handle error                           
                        FSM_ErrorLog__c errorLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_BacklogMaintenanceBatch').setErrorMessage(error.getMessage()+' Failed record id: '+result.getId()).setMethodName('execute').setType('Field Service').returnWithoutCreate();                                                       
                        errLogs.add(errorLog );
                    }
                }
                if(errLogs.Size()>0 && SObjectType.FSM_ErrorLog__c.isCreateable()) {
                Upsert errLogs;
               }
            }
        }catch (Exception e) {
            FSM_ErrorLog__c errorLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_BacklogMaintenanceBatch').setErrorMessage(e.getMessage()).setLineNumber(String.ValueOF(e.getLineNumber())).setMethodName('execute').setStackTrace(e.getStackTraceString()).setType('Field Service').create();
        }
    }
    
    /**
    * @description scenarioOne
    * @param sa
    */
    private static void scenarioOne(ServiceAppointment sa){
        if((sa.FSM_SAPJobPriority__c==1||sa.FSM_SAPJobPriority__c==2||
            sa.FSM_SAPJobPriority__c==3 || sa.FSM_SAPJobPriority__c==4) && (sa.FSM_HoursUntilDueDate__c <=23))
        { 
            if(sa.FSM_DueDateApplyCounterZPM1__c == 3){
                sa.FSM_Backlog__c = TRUE;
            }
            else{
                sa.DueDate=sa.DueDate+2;
                sa.FSM_DueDateApplyCounterZPM1__c = sa.FSM_DueDateApplyCounterZPM1__c + 1;
            }  
        }

        
    } 
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new FSM_BacklogMaintenanceBatch(),200);
    }  
}
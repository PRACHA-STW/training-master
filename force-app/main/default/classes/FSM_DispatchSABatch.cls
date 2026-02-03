/********************************************************************************************************
@Author      : Arnob Dey
@description : This class contains actual logic of a batch job to auto-dispatch service appointment
@description : Created as part of user story #SFS-814
@description : Invoked from FSM_DispatchSAScheduler class 
@Test Class  : FSM_DispatchSATest
@Date        : 24-July-2023
********************************************************************************************************/
global with sharing class FSM_DispatchSABatch implements Database.Batchable<sObject>{
    private String jobRunQuery;
    public static final Integer BATCH_SIZE = Integer.valueOf(System.Label.FSM_SABatchSize); //To have the Batch size
    /**
* @description parameterised constructor
* @param jobRunQuery
*/
    global FSM_DispatchSABatch(String jobRunQuery){
        this.jobRunQuery = jobRunQuery;        
    }
    /**
* @description start
* @param bc
* @return Database.QueryLocator
*/
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        Datetime dtm = DateTime.now();
        if(jobRunQuery == NULL){            
            jobRunQuery = 'SELECT Id, ServiceResourceId,ServiceResource.Name, ServiceTerritory.FSM_NumberOfDaysToDispatch__c, ServiceTerritory.FSM_NumberOfSAToDispatch__c FROM ServiceTerritoryMember WHERE (EffectiveEndDate > :dtm OR EffectiveEndDate = NULL) AND ServiceTerritory.FSM_NumberOfDaysToDispatch__c <> NULL AND ServiceTerritory.FSM_NumberOfDaysToDispatch__c!= \'None\'';
        }        
        return Database.getQueryLocator(jobRunQuery);
    }
    
    /**
* @description execute
* @param bc
* @param stmList
*/
    global void execute(Database.BatchableContext bc, List<ServiceTerritoryMember> stmList){
        
        Date startDate = Date.today().addDays(1);
        Date endDate;
        Integer noOfSA =0;
        Id resourceId;
        
        for(ServiceTerritoryMember stm: stmList){
        
            Integer dy = Integer.valueOf(stm.ServiceTerritory.FSM_NumberOfDaysToDispatch__c);
            endDate = endDateCalc(dy);
            resourceId = stm.ServiceResourceId;
            
            if(dy == 1 && stm.ServiceTerritory.FSM_NumberOfSAToDispatch__c != 'Full'){
                noOfSA = Integer.valueOf(stm.ServiceTerritory.FSM_NumberOfSAToDispatch__c);
            }
        }
        
        String qry;
        if(noOfSA > 0){
            qry = 'SELECT Id, ServiceResourceId, ServiceAppointmentId,ServiceAppointment.AppointmentNumber from AssignedResource where ServiceResourceId =:resourceId AND ServiceAppointment.SchedStartTime >= :startDate  AND ServiceAppointment.SchedStartTime <= :endDate AND ServiceAppointment.Status = \'Scheduled\' ORDER BY ServiceAppointment.SchedStartTime ASC Limit :noOfSA';
        }else{
            qry = 'SELECT Id, ServiceResourceId,ServiceAppointmentId, ServiceAppointment.AppointmentNumber from AssignedResource where ServiceResourceId =:resourceId AND ServiceAppointment.SchedStartTime >= :startDate  AND ServiceAppointment.SchedStartTime <= :endDate AND ServiceAppointment.Status = \'Scheduled\' ORDER BY ServiceAppointment.SchedStartTime ASC';
        }
        
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        //Assigned resource 
        for(AssignedResource ar: DataBase.Query(qry)){
            ServiceAppointment sa = new ServiceAppointment();
            sa.Id = ar.ServiceAppointmentId;
            sa.Status = 'Dispatched';
            saList.add(sa);            
        }
        
        if(saList.size() > 0){
            try {
                Database.SaveResult[] updateResult = Database.update(saList,false);
                for (Database.SaveResult result : updateResult) {
                    if (result.isSuccess()) {
                    }
                    else {
                        //Error ecountered              
                        for(Database.Error error : result.getErrors()) {
                            //Handle error                           
                            FSM_ErrorLog__c errorLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_DispatchSABatch').setErrorMessage(error.getMessage()+' Failed record id: '+result.getId()).setMethodName('execute').setType('Field Service').create();                                                       
                        }
                    }
                }
            } catch (Exception e) {
                //If there is an exception, log it in the error log object
                FSM_ErrorLog__c errorLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_DispatchSABatch').setErrorMessage(e.getMessage()).setLineNumber(String.ValueOF(e.getLineNumber())).setMethodName('execute').setStackTrace(e.getStackTraceString()).setType('Field Service').create();
                e.setMessage('Error occurred while trying to dispatch service appointment');               
            }
        }
    }
        
    /**
* @description finish
* @param context
*/
    global void finish(Database.BatchableContext context) {      
    }
    
    /**
* @description Calculate end date
* @param noOfDays
*/
    public Date endDateCalc(Integer noOfDays){
        
        Integer daysToDispatch = noOfDays;
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='Full Day'];
                
        Datetime tomDate = Date.today().addDays(1);
        
        for (Integer i=0; i <= daysToDispatch; i++)
        {
            
            if (BusinessHours.isWithin(bh.Id, tomDate)) 
            {
                tomDate = tomDate.addDays(1);
            }else {
                tomDate = BusinessHours.nextStartDate(bh.Id, tomDate);
            }
            
        }
        
        Date dt = tomDate.date();
        return dt;
    }
}
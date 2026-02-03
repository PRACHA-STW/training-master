/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class contains actual logic of a batch job to support data masking / anonymization of data
@description : Created as part of user story #SFS-4144
@Date        : 07-February-2024
********************************************************************************************************/

public class FSM_PrepareMySandboxBatchUpdate implements Database.Batchable<SObject> {
    /*** @description start**/
    public List<sObject> start(Database.BatchableContext context) {
        List<sObject> scope = new List<sObject>();
        scope.addAll([SELECT id,FSM_ContactID__c,FSM_ContactName__c,FSM_ContactEmail__c,FSM_ContactPhoneNumber__c,FSM_SpecialCondition__c,FSM_MSN__c FROM Case WHERE FSM_isRefreshed__C = FALSE]);
        scope.addAll([SELECT id,FSM_ContactID__c,FSM_ContactName__c,FSM_ContactEmail__c,FSM_ContactPhoneNumber__c,FSM_SpecialCondition__c,
                      FSM_ManufacturersSerialNumber__c FROM WorkOrder WHERE FSM_isRefreshed__C = FALSE]);
        return scope;
        
    }
    /*** @description execute**/  
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        try{
            List<Case> caseRecordsforUpdate = new List<Case>();
            List<WorkOrder> workOrderRecordsforUpdate = new List<WorkOrder>();
            for(sObject obj : scope)
            {
                switch on obj
                {
                    when Case cas
                    {
                        // Logic to update  all Cases
                        // Add the case record to the list
                        caseRecordsforUpdate.add(cas);
                        // Logic here to prepare the sandbox for use.
                        List<Case> caseList = new List<Case>();
                        for(Case c : caseRecordsforUpdate){
                            c.FSM_ContactID__c  = 'Demo@example.com';
                            c.FSM_ContactName__c  ='Test Customer';
                            c.FSM_ContactEmail__c = 'Test.Customer@emaildomain.com';
                            c.FSM_ContactPhoneNumber__c='0123456789';
                            c.FSM_SpecialCondition__c ='Test Special Condition';
                            c.FSM_MSN__c = 'Dummy000001';
                            c.FSM_isRefreshed__C = True;
                            caseList.add(c); 
                        }
                    }
                    when WorkOrder wo
                    {
                        // Add the case record to the list
                        workOrderRecordsforUpdate.add(wo);
                        // Logic here to prepare the sandbox for use.
                        List<WorkOrder> woList = new List<WorkOrder>();
                        for(WorkOrder wo: workOrderRecordsforUpdate){
                            wo.FSM_ContactID__c  = 'Demo@example.com';
                            wo.FSM_ContactName__c  ='Test Customer';
                            wo.FSM_ContactEmail__c = 'Test.Customer@emaildomain.com';
                            wo.FSM_ContactPhoneNumber__c='0123456789';
                            wo.FSM_SpecialCondition__c ='Test Special Condition';
                            wo.FSM_ManufacturersSerialNumber__c = 'Dummy000001';
                            wo.FSM_isRefreshed__C = True;
                            woList.add(wo);
                        }
                    }
                    
                }  
            }
            // Update all case and work order
            if(caseRecordsforUpdate.size() > 0) {
                Database.update(caseRecordsforUpdate,false);
            }
            if(workOrderRecordsforUpdate.size() > 0){
                Database.update(workOrderRecordsforUpdate,false);
            }
        }
        //If there is an exception, log it in the error log object
        catch(exception ex){FSM_ErrorLog__c newLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_PrepareMySandboxBatchUpdate').setErrorMessage(ex.getMessage()).setLineNumber(String.ValueOF(ex.getLineNumber())).setMethodName('execute').setStackTrace(ex.getStackTraceString()).setType('Field Service').create();ex.setMessage('There is some error happened when tried to Update case/Work order while refreshing Sandbox');
        }
        
    }
    /*** @description finish**/
    public void finish(Database.BatchableContext context) {
        //finish
    }
    
}
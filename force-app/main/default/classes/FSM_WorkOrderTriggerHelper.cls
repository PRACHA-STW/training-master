/********************************************************************************************************
@Author      : Arnob Dey
@description : This trigger is used to perform Case update when WorkOrder is created.
@description : Created as part of user story #SFS-318,SFI-21
@Description : Invoked from FSM_WorkOrderTriggerHandler class
@Test Class  : FSM_WorkOrderTriggerHandlerTest  AND FSM_GISAPIHandlerTest
@Date        : 07-July-2023
14-Sep-2023	 	 Srikanth Palla 	   Updated as part of SFI-29
             02-12-2024  Aishwarya Bhosale Updated as part of SFS-8045
********************************************************************************************************/
public with sharing class FSM_WorkOrderTriggerHelper {
    MAP<String, EmailTemplate> emailTemplateMap; //Map of template name and ID
    
    /********************************************************************************************************
    @Author      : Arnob Dey
    @description : This method is used to copy Customer Information from Case to WorkOrder when WorkOrder is created.
    @description : Invoked from FSM_WorkOrderTriggerHandler class
    @param newList
    Updated: Mitansh Banduk   Updated as a part of SFS-3039
    ********************************************************************************************************/
    public static void copyCustomerInformation(List<WorkOrder> newList){       
        // Set to store Case IDs
        Set<Id> caseIds = new Set<Id>();
        // Map of Id, Case 
        Map<Id, Case> caseMap;
        
        // Collect the Case IDs for the related WorkOrders
        for (WorkOrder workOrder : newList) {
            if (workOrder.CaseId != NULL) {
                caseIds.add(workOrder.CaseId);
            }
        }
        
        if(!caseIds.isEmpty()){
            // Query for the related Case records
            caseMap = new Map<Id, Case>([SELECT Id, FSM_ContactID__c, FSM_ContactName__c, FSM_ContactPhoneNumber__c, 
                                         FSM_ContactEmail__c, FSM_SpecialCondition__c, FSM_MSN__c,Description FROM Case WHERE Id IN :caseIds
                                         WITH SECURITY_ENFORCED]);
        }
        
        // Populate the customer information on WorkOrder from Case
        for (WorkOrder workOrder : newList) {
            if (caseMap != NULL && caseMap.containsKey(workOrder.CaseId)) {
                workOrder.FSM_ContactID__c = caseMap.get(workOrder.CaseId).FSM_ContactID__c;
                workOrder.FSM_ContactName__c = caseMap.get(workOrder.CaseId).FSM_ContactName__c;
                workOrder.FSM_ContactPhoneNumber__c = caseMap.get(workOrder.CaseId).FSM_ContactPhoneNumber__c;
                workOrder.FSM_ContactEmail__c = caseMap.get(workOrder.CaseId).FSM_ContactEmail__c;
                workOrder.FSM_SpecialCondition__c = caseMap.get(workOrder.CaseId).FSM_SpecialCondition__c;
                if( workOrder.FSM_ManufacturersSerialNumber__c==NULL || String.isBlank(workOrder.FSM_ManufacturersSerialNumber__c)){ // Updated by Manish Kumar jagnani as part of SFI-1469
                    workOrder.FSM_ManufacturersSerialNumber__c = caseMap.get(workOrder.CaseId).FSM_MSN__c;
                }
                //Added as part of sfs-8045
                if(workOrder.FSM_NotificationLongText__c==Null){
                        workOrder.FSM_NotificationLongText__c = caseMap.get(workOrder.CaseId).Description;
                }
            }
            
        }
    }
    
    public void generatePdf(Map<Id,sObject> newMap,Map<Id,sObject> oldMap){
        Map<Id, WorkOrder> allNewDCF=(Map<Id, WorkOrder>)newMap; //collecting all updated Data capture form infra records
        Map<Id, WorkOrder> allOldDCF=(Map<Id, WorkOrder>)oldMap; //collecting all updated Data capture form infra records old value
        List<WorkOrder>dcfinfraUpdtList=new List<WorkOrder>();
        for(WorkOrder cmp : allNewDCF.values()) {
            if((cmp.FSM_GeneratePDF__c!=allOldDCF.get(cmp.Id).FSM_GeneratePDF__c) && (allOldDCF.get(cmp.Id).FSM_GeneratePDF__c==false)){	
                try{
                    FSM_simpleSketchCls.pdfCreation(cmp.Id);
                }catch(Exception ex){
                    new FSM_Utility.ErrorLogCreator().setClassName('FSM_WorkOrderTriggerHelper').setErrorMessage(ex.getMessage()).setLineNumber(string.valueof(ex.getLineNumber())).setMethodName('generatePdf').setStackTrace(ex.getStackTraceString()).setType('Field Service').create();
                }
            }            
        }        
    }
    
}
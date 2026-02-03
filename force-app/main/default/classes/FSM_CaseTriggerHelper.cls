/********************************************************************************************************
@Author      : Arnob Dey
@Description : This class is used to perform WorkOrder update when Case is updated.
@Description : Created as part of user story #SFS-318
@Description : Invoked from FSM_CaseTriggerHandler class
@Test Class  : FSM_CaseTriggerHandlerTest
@Date        : 07-July-2023
               02-12-2024 Aishwarya Bhosale Updated as part of SFS-8045
********************************************************************************************************/
public with sharing class FSM_CaseTriggerHelper {
    /********************************************************************************************************
@Author      : Arnob Dey
@Description : This class is used to copy Customer Information from Case to WorkOrder when Case is updated.
@Description : Created as part of user story #SFS-318
@Description : Invoked from FSM_CaseTriggerHandler class
@Date        : 07-July-2023
********************************************************************************************************/
    public static void copyCustomerInformation(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        // Set to store Case IDs with updated custom field
        Set<Id> updatedCaseIds = new Set<Id>();
        Map<Id, Case> varCaseNewMap = (Map<Id, Case>)newMap;
        Map<Id, Case> varCaseOldMap = (Map<Id, Case>)oldMap;
        List<WorkOrder> workOrdersToUpdate;
        
        // Collect the Case IDs with updated customer information
        for (Case caseObj : varCaseNewMap.values()) {           
            if ((varCaseOldMap.get(caseObj.Id).FSM_ContactID__c != caseObj.FSM_ContactID__c || 
                 varCaseOldMap.get(caseObj.Id).FSM_ContactName__c != caseObj.FSM_ContactName__c || varCaseOldMap.get(caseObj.Id).FSM_ContactPhoneNumber__c != caseObj.FSM_ContactPhoneNumber__c ||varCaseOldMap.get(caseObj.Id).FSM_ContactEmail__c != caseObj.FSM_ContactEmail__c ||varCaseOldMap.get(caseObj.Id).FSM_SpecialCondition__c != caseObj.FSM_SpecialCondition__c)|| varCaseOldMap.get(caseObj.Id).FSM_MSN__c != caseObj.FSM_MSN__c || varCaseOldMap.get(caseObj.Id).Description != caseObj.Description) {
                     updatedCaseIds.add(caseObj.Id);
                 }
        }
        
        if(!updatedCaseIds.isEmpty()){
            // Query for the related WorkOrder records
            workOrdersToUpdate = [SELECT Id, FSM_ContactID__c, FSM_ContactName__c, FSM_ContactPhoneNumber__c,
                                                  FSM_ContactEmail__c, FSM_SpecialCondition__c, CaseId, FSM_ManufacturersSerialNumber__c,FSM_NotificationLongText__c FROM WorkOrder WHERE CaseId IN :updatedCaseIds
                                                  WITH SECURITY_ENFORCED];
        }    
        // Populate the customer information on WorkOrder from Case
        if (workOrdersToUpdate != null && !workOrdersToUpdate.isEmpty()){
            for (WorkOrder workOrder : workOrdersToUpdate) {
                if (varCaseNewMap.containskey(workOrder.CaseId)) {
                    workOrder.FSM_ContactID__c = varCaseNewMap.get(workOrder.CaseId).FSM_ContactID__c;
                    workOrder.FSM_ContactName__c = varCaseNewMap.get(workOrder.CaseId).FSM_ContactName__c;
                    workOrder.FSM_ContactPhoneNumber__c = varCaseNewMap.get(workOrder.CaseId).FSM_ContactPhoneNumber__c;
                    workOrder.FSM_ContactEmail__c = varCaseNewMap.get(workOrder.CaseId).FSM_ContactEmail__c;
                    workOrder.FSM_SpecialCondition__c = varCaseNewMap.get(workOrder.CaseId).FSM_SpecialCondition__c;
                    // below check Added by Manish Kumar Jagnani SFI-1469
                    if(varCaseOldMap.get(workOrder.CaseId).FSM_MSN__c != varCaseNewMap.get(workOrder.CaseId).FSM_MSN__c && varCaseNewMap.get(workOrder.CaseId).FSM_MSN__c != null && !(String.ISBLANK(varCaseNewMap.get(workOrder.CaseId).FSM_MSN__c))){
                        workOrder.FSM_ManufacturersSerialNumber__c = varCaseNewMap.get(workOrder.CaseId).FSM_MSN__c;
                    }
                    //Added as part of sfs-8045
                    if(varCaseOldMap.get(workOrder.CaseId).Description != varCaseNewMap.get(workOrder.CaseId).Description && varCaseNewMap.get(workOrder.CaseId).Description != null){
                        workOrder.FSM_NotificationLongText__c = varCaseNewMap.get(workOrder.CaseId).Description;
                    }
                }
            }
        }
            
        //Update the WorkOrder records
        if (workOrdersToUpdate != null &&
            !workOrdersToUpdate.isEmpty() &&
            Schema.sObjectType.WorkOrder.fields.FSM_ContactID__c.isUpdateable() && 
            Schema.sObjectType.WorkOrder.fields.FSM_ContactName__c.isUpdateable() && 
            Schema.sObjectType.WorkOrder.fields.FSM_ContactPhoneNumber__c.isUpdateable() && 
            Schema.sObjectType.WorkOrder.fields.FSM_ContactEmail__c.isUpdateable() && 
            Schema.sObjectType.WorkOrder.fields.FSM_SpecialCondition__c.isUpdateable() && 
            Schema.sObjectType.WorkOrder.fields.FSM_ManufacturersSerialNumber__c.isUpdateable()){
                try{
                	update workOrdersToUpdate;
                }Catch(Exception ex){
                    FSM_ErrorLog__c newLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_CaseTriggerHelper').setErrorMessage(ex.getMessage()).setLineNumber(String.ValueOF(ex.getLineNumber())).setMethodName('copyCustomerInformation').setStackTrace(ex.getStackTraceString()).setType('Field Service').create();
                    ex.setMessage('There is some error happened when tried to update Work order record, Admin is checking the issue');
                }
        }        
    }     
}
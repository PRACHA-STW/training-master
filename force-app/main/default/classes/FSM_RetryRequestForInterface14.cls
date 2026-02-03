/********************************************************************************************************
@Author      : Asutosh Singh
@description : This class is created to schedule a Retry Mechanism to send attachments to SAP
@description : Created as part of user story #SFI-2208
@description : Used to invoke FSM_ContentDocumentLinkTriggerHelper class where the actual logic is written
@Test Class  : FSM_ContentDocLinkTriggerTest
@Date        : 24-June-2024
********************************************************************************************************/
public with sharing class FSM_RetryRequestForInterface14 implements Schedulable{
    
    /********************************************************************************************************
    @Author      : Asutosh Singh
    @description : Created as part of user story #SFI-2208
    @description : This method is the execute method for Schedulable class.
    @param 		 : sc
    @Date        : 01-April-2024
    ********************************************************************************************************/
    public void execute(SchedulableContext sc){
        Boolean retryFlag = true; // to set the Retry Flag as true for new errorlog record in case attachment upload fails again 
        List<Id> contentDocumentLinkIds = new List<Id>(); // stores the Content Document Link Id's from the error log
        List<FSM_ErrorLog__c> updatedErrorLog = new List<FSM_ErrorLog__C>(); // to update the retry flag once retry is done
        try{
            // fetch error log records with retry flag = true
            Map<Id, FSM_ErrorLog__c> errorLogMap = new Map<Id, FSM_ErrorLog__c>([
                SELECT Id, FSM_ExceptionLineNumber__c, FSM_RetryFlag__c FROM FSM_ErrorLog__c 
                WHERE FSM_RetryFlag__c = true AND FSM_Interface__c = 'INT-014'
                WITH SECURITY_ENFORCED LIMIT 1000
            ]);
            // get the contentDocumentLinkIds from the error log records and update ErrorLog with retry flag = false
            for(FSM_ErrorLog__c item: errorLogMap.values()){
                contentDocumentLinkIds.add(item.FSM_ExceptionLineNumber__c);
                item.FSM_RetryFlag__c=false; // Update the Retry Flag to false
                updatedErrorLog.add(item);
            }
            if(!contentDocumentLinkIds.isEmpty() && contentDocumentLinkIds!=null){
                Map<Id,ContentDocumentLink> contentDocumentLinkMap = new Map<Id,ContentDocumentLink>([
                    SELECT Id, ContentDocumentId, linkedEntityId FROM ContentDocumentLink 
                    WHERE Id IN :contentDocumentLinkIds WITH SECURITY_ENFORCED
                ]);
                FSM_ContentDocumentLinkTriggerHelper.sendContentVersionToggleCheck(contentDocumentLinkMap, retryFlag);
            }
            if (!updatedErrorLog.isEmpty() && updatedErrorLog!=null && Schema.sObjectType.FSM_ErrorLog__c.isUpdateable()) {
                update updatedErrorLog;
            }
        } catch (Exception e) {
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_RetryRequestForInterface14').setMethodName('execute')
                .setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString())
                .setType('Integration').create();
        }
    }
}
/********************************************************************************************************
@Author      : Subir Maji
@Description : FSM_WorkHistoryTriggerHelper class is helper class for FSM_WorkHistoryTriggerHandler.
@Description : Created as part of user story #SFI-2152
@Test Class  : FSM_WorkHistoryTriggerHandlerTest 
@Date        : 30-May-2024
********************************************************************************************************/
public with sharing class FSM_WorkHistoryTriggerHelper {
    /**
    * @description :To Delete old Work History recotrds for same WOrkorder
    * @param newMap
    * @added as part of SFI-2152, Subir Maji, 30-May-2024
    */ 
    public static void deleteOldWorkHistory(Map<Id, sObject> newMap){
        Map<Id, FSM_WorkHistory__c> allNewWH=(Map<Id, FSM_WorkHistory__c>)newMap; //collecting all new Work History
        Set<String> allWOId = new Set<String>(); //To Collect all Work Order ID
        
        //Collecting WO ID
        for(FSM_WorkHistory__c allWH : allNewWH.Values()){
            allWOId.add(allWH.FSM_WorkOrder__c);
        }
        
        //Query to get all old records based on Work Order and current record id
        List<FSM_WorkHistory__c> allOldHistory = [Select ID 
                                                  From FSM_WorkHistory__c 
                                                  Where ID NOT IN: newMap.KeySet()
                                                 AND FSM_WorkOrder__c IN : allWOId WITH SECURITY_ENFORCED];
        
        //If any record present then delete old records.
        if(allOldHistory != null && !allOldHistory.isEmpty()){
           try{
               if (SObjectType.FSM_WorkHistory__c.isDeletable()) {
                   Delete allOldHistory;
               }
            }catch(exception e){
                new FSM_Utility.ErrorLogCreator().setClassName('FSM_WorkHistoryTriggerHelper').setMethodName('deleteOldWorkHistory').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Integration').create();
            }
        }
    }
    
    /**
    * @description :To Update Work History recotrds with New external ID by adding timestamp
    * @param newMap
    * @added as part of SFI-2381, Subir Maji, 11-July-2024
    */ 
    public static void updateWorkHistoryExternalID(List<sObject> newMap){
        List<FSM_WorkHistory__c> allNewWH=(List<FSM_WorkHistory__c>)newMap; //collecting all new Work History
        DateTime currentTime = system.now();

        for(FSM_WorkHistory__c allWH : allNewWH){
            allWH.FSM_ExternalIdSendBySAP__c = allWH.FSM_ExternalId__c;
            allWH.FSM_ExternalId__c = allWH.FSM_ExternalId__c+currentTime;
        }
    }
}
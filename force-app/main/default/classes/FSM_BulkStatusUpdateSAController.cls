/** ************************************************************************************
@Author : Brajesh Kumar
@Description  : Created for for Bulk Status Update Action
@Created Date : 16th June 2024
@Test Class : FSM_SelectAndScheduleTest
@description : Created as part of user story SFS-6634
**************************************************************************************** **/
public with sharing class FSM_BulkStatusUpdateSAController {
    // Get Status from FSM_StatusTransition CMDT Object
    @AuraEnabled(cacheable=true)
    public static List<FSM_StatusTransition__mdt> getStatusTransition() {
        // Query the custom metadata
        List<FSM_StatusTransition__mdt> metadataList = [SELECT FSM_CurrentStatus__c , FSM_StatusToUpdate__c FROM FSM_StatusTransition__mdt where FSM_ProfileName__c = 'FSM Site Worker' WITH SECURITY_ENFORCED];
        return metadataList;
    }
    
    
    // Get Reject Category & Reject Reason from FSM_CMDTLevel2__mdt Object
    @AuraEnabled(cacheable=true)
    public static List<FSM_CMDTLevel2__mdt> getRejectionDetails() {
        return [SELECT FSM_RejectionCategory__c, FSM_RejectionReason__c,FSM_SAPName__c,FSM_BusinessUnit__c FROM FSM_CMDTLevel2__mdt WHERE FSM_Workmate__c = true WITH SECURITY_ENFORCED];
    }
    
    
}
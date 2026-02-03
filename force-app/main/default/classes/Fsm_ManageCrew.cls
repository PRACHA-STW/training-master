/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class is used fetch manage crew members in Manage Crew Feature - LWC :FsmManageCrew
@description : Created as part of user story #SFL-886
@Test Class  : Fsm_ManageCrewTest
@Date        : 10-July-2025
********************************************************************************************************/
public with sharing class Fsm_ManageCrew {
    Static Id currentUserId = UserInfo.getUserId();// Get current user Id
    /********************************************************************************************************
    @Author      : Brajesh Kumar
    @description : Method to fetch ServiceResources based on their Business Unit and ResourceType.
    ********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ServiceResource> getActiveResources() {
        // Find ServiceResource for current user
        List<ServiceResource> userResources = [
            SELECT Id, FSM_BusinessUnit__c
            FROM ServiceResource
            WHERE RelatedRecordId = :currentUserId AND
            IsActive = true AND
            FSM_BusinessUnit__c != null WITH SECURITY_ENFORCED];
        
        // If not found, return empty list
        if (userResources == null || userResources.isEmpty()) {
            return new List<ServiceResource>();
        }
        
        // Fetch all active ServiceResources with ResourceType 'T' and same business unit as user, EXCLUDING current user
        // is it possible to mark user as current user when returning the list
        List<ServiceResource> resources = [
            SELECT Id, Name, FSM_WorkCentreExternalId__c, FSL__GanttLabel__c
            FROM ServiceResource
            WHERE IsActive = true
            AND ResourceType = 'T'
            AND FSM_BusinessUnit__c = : userResources[0].FSM_BusinessUnit__c
            AND RelatedRecordId != :currentUserId WITH SECURITY_ENFORCED];
        
        return resources;
    }
     
    /********************************************************************************************************
    @Author      : Brajesh Kumar
    @description : This method retrieves the ID of the active ServiceResource record associated with the 
                   current user, if available, by querying based on the user's ID and active.
    ********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Id getCurrentUserServiceResourceId() {
        // Declare a variable to hold a blank ID (will be returned if no matching resource is found)
        ID blankID;
        // Query the ServiceResource object to find active resources related to the current user
        List<ServiceResource> resources = [
            SELECT Id
            FROM ServiceResource
            WHERE RelatedRecordId = :currentUserId AND 
            IsActive = true WITH SECURITY_ENFORCED];
        
        // If no matching ServiceResource is found, return the blank ID else Return the ID of the first matching ServiceResource
        if (resources == null || resources.isEmpty()) {
            return blankID;
        }else{
            return resources[0].Id;
        }
    }
}
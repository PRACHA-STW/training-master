/********************************************************************************************************
@Author      : Himanshu Dobriyal
@description : This AuraEnabled class is used to return list of Custom metadata referred in fSM_PlatformEventSubscribe_lwc Component.
@Description : Created as part of platform Event testing requirement SFI-1002.
@Test Class  : FSM_PlatformEventControllerPicklistTest
@Date        : 01-November-2023
********************************************************************************************************/
public with sharing class FSM_PlatformEventControllerPicklist {
/************************************************************************************************************************
@Author      : Himanshu Dobriyal
@description : This Method is used to return list of Custom metadata referred in fSM_PlatformEventSubscribe_lwc Component.
@return : List<FSM_PlatformEventPicklistLwc__mdt>
@Test Class  : FSM_PlatformEventControllerPicklistTest
@Date        : 01-November-2023
************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<FSM_PlatformEventPicklistLwc__mdt> getCustomSettingPicklistValues() {
        List<FSM_PlatformEventPicklistLwc__mdt> picklistValues = new List<FSM_PlatformEventPicklistLwc__mdt>();
        picklistValues = [SELECT Label, FSM_EventApiName__c,FSM_Active__c FROM FSM_PlatformEventPicklistLwc__mdt where FSM_Active__c=true WITH SECURITY_ENFORCED];
        // Query on metadata to get the Platform event api name and label which are active to populate the picklistValues list.
        return picklistValues;
    }
/************************************************************************************************************************
@Author      : Himanshu Dobriyal
@description : This Method is used to return a boolean value referred in fSM_PlatformEventSubscribe_lwc Component.
@return : Boolean
@Test Class  : FSM_PlatformEventControllerPicklistTest
@Date        : 02-November-2023
************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean isCurrentUserValidToSeeComponent() {
        string[] isAllowedProfileName = new string[]{'System Administrator','FSM System Administrator','Salesforce API Only System Integrations','FSM Integration'};
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];
            if(currentUser.Profile.Name!=null && isAllowedProfileName.contains(currentUser.Profile.Name)){
                return true;
               }
        return false;
    }
}
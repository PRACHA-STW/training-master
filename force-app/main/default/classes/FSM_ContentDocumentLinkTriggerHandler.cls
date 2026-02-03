/********************************************************************************************************
@Author      : Aishwarya Bhosale
@description  This class calls FSM_ContentDocumentLinkTriggerHelper
@Description : Created as part of user story #SFS-3017
@TestClass : FSM_ContentDocLinkTriggerTest
@Date        : 10-Nov-2023
********************************************************************************************************/
public class FSM_ContentDocumentLinkTriggerHandler implements FSM_TriggerBaseHandler {
    
    public static Boolean triggerDisabled = false;
    
    /********************************************************************************************************
    @Author      : Aishwarya Bhosale
    @description  check if the trigger is disabled from transaction, SFS-3017
    @return Boolean
    @Date        : 10-Nov-2023
	********************************************************************************************************/
    public Boolean isDisabled(){
        return triggerDisabled;
    }  
    
    /********************************************************************************************************
    @Author      : Aishwarya Bhosale
    @description  For Before Insert functionalities, SFS-3017
    @param newList
    @Date        : 10-Nov-2023
	********************************************************************************************************/
    //For Before Insert functionalities
    public void beforeInsert(List<sObject> newList) {
         FSM_ContentDocumentLinkTriggerHelper.updateContentDocumentLink(newList);     
    }  
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  For After Insert functionalities, SFI-1213
    @param newMap
    @Date        : 10-APR-2024
	********************************************************************************************************/
    public void afterInsert(Map<Id, sObject> newMap) {
      FSM_ContentDocumentLinkTriggerHelper.sendContentVersionToggleCheck(newMap, true);
    }
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  For Before Update functionalities, SFI-1213
    @param newMap
    @param oldMap
    @Date        : 10-APR-2024
	********************************************************************************************************/
    public void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {}
    
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  For After Update functionalities, SFI-1213
    @param newMap
    @param oldMap
    @Date        : 10-APR-2024
	********************************************************************************************************/
    public void afterUpdate(Map<Id, sObject> newMap,  Map<Id, sObject> oldMap) {}

}
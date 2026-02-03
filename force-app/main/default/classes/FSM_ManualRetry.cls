/**********************************************************************************************************
@Author      : Asutosh Singh
@Description : This Class is used to create a Retry Mechanism to send attachments.
@Description : Created as part of user story #SFI-2208
@Test Class  : FSM_ContentDocLinkTriggerTest
@Date        : 25-June-2024
********************************************************************************************************/
public with sharing Class FSM_ManualRetry {
/********************************************************************************************************
@Author      : Asutosh Singh
@Description : This method getting called from FSM_ManualRetry flow.
@Description : Created as part of user story #SFI-2208
@Date        : 25-June-2024
********************************************************************************************************/
    @InvocableMethod(label = 'ManualRetry')
    public static void manualRetry(List<RetryInputParam> retryInputs) {
        Boolean retryFlag = true; // to set the Retry Flag as true for new errorlog record in case attachment upload fails again 
        ContentDocumentLink cdl= retryInputs[0].cdlRecord; // to store the ContentDocumentLink record from input param
        Map<Id, ContentDocumentLink> cdlMap= new Map<Id, ContentDocumentLink>();
        cdlMap.put(cdl.Id,cdl);
        FSM_ContentDocumentLinkTriggerHelper.sendContentVersionToggleCheck(cdlMap, retryFlag);
    }
    /********************************************************************************************************
    @Author      : Asutosh Singh
    @Description : This is invocable Variables getting called from FSM_ManualRetry flow.
    @Description : Created as part of user story #SFI-2208
    @Date        : 25-June-2024
    ********************************************************************************************************/
    public class RetryInputParam{
        @InvocableVariable
        public ContentDocumentLink cdlRecord;
    }
}
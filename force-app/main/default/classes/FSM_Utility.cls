/********************************************************************************************************
@Author      : Deepak
@description : This Class is going to be used as a utility class
@description : Created as part of user story #SFI-
@Test Class  : FSM_UtilityTest
@Date        : 1-July-2023
********************************************************************************************************/
public with sharing class FSM_Utility {
    
    /********************************************************************************************************
@Author      : Deepak
@description : This is invocable method getting called from flows and create the integration log
@description : Created as part of user story #SFI-
@Date        : 1-July-2023
**********************************************************************************************************/ 
    @InvocableMethod(label = 'CreateIntegrationLog')
    public static void createIntegrationLog(List<FSM_IntegrationLog> logData) {
        List<FSM_IntegrationLog__c> intgLogRecords = new List<FSM_IntegrationLog__c>();
        FSM_IntegrationLog__c intgLog ;
        
        for(FSM_IntegrationLog iterator :logData){  //Added By manish  8th oct 2024 sfi-2889
            intgLog= new FSM_IntegrationLog__c();
            intgLog.FSM_RecordId__c = iterator.recordId;
            intgLog.FSM_RequestPayload__c = iterator.requestPayLoad;
            intgLog.FSM_ResponsePayload__c = iterator.responsePayLoad;
            intgLog.FSM_ServiceName__c = iterator.serviceName;
            intgLog.FSM_ExternalId__c = iterator.externalId;
            intgLogRecords.add(intgLog); 
        }
        if (SObjectType.FSM_IntegrationLog__c.isCreateable()) { //Added By Subir Maji 10th June 2023 for SFS-231
            Insert intgLogRecords;
        }
    }
    
    /********************************************************************************************************
@Author      : Deepak
@description : This is the invocable variables which can be set fro flows
@description : Created as part of user story #SFI-
@Date        : 1-July-2023
********************************************************************************************************/ 
    public class FSM_IntegrationLog{
        @InvocableVariable
        public String recordId;
        
        @InvocableVariable
        public String requestPayLoad;
        
        @InvocableVariable
        public String responsePayLoad;
        
        @InvocableVariable
        public String serviceName;
        
        @InvocableVariable
        public String externalId;
    }
    
    /********************************************************************************************************
@Author      : Deepak
@description : To Generate Random numbers
@description : Created as part of user story #SFI-
@Date        : 1-July-2023
********************************************************************************************************/ 
    public static String generateRandomNumber(){
        return Integer.valueOf((Math.random() * 1000000))+'';
    }
    
    /********************************************************************************************************
@Author      : Subir Maji
@description : This Method will be used to create error log record
@description : Created as part of user story #SFS-231
@Date        : 10-July-2023
********************************************************************************************************/ 
    public with sharing class ErrorLogCreator {
        FSM_ErrorLog__c item;
        //Constructor
        public ErrorLogCreator() {
            item = new FSM_ErrorLog__c();
        }
        //Setter method for the Class/Flow Name field
        public ErrorLogCreator setClassName(String className){
            item.FSM_ClassFlowName__c = className;
            return this;
        }
        //Setter method for the Error Message field
        public ErrorLogCreator setErrorMessage(String errorMessage){
            item.FSM_ErrorMessage__c = errorMessage;
            return this;
        }
        //Setter method for the Exception Line Number field
        public ErrorLogCreator setLineNumber(String lineNumber){
            item.FSM_ExceptionLineNumber__c = lineNumber;
            return this;
        }
        //Setter method for the Method Name field
        public ErrorLogCreator setMethodName(String methodName){
            item.FSM_MethodName__c = methodName;
            return this;
        }
        //Setter method for the Stack Trace field
        public ErrorLogCreator setStackTrace(String stackTrace){
            item.FSM_StackTrace__c = stackTrace;
            return this;
        }
        //Setter method for the Type field
        public ErrorLogCreator setType(String errorType){
            item.FSM_Type__c = errorType;
            return this;
        }
        //Setter method for the External Id field
        public ErrorLogCreator setExternalID(String extID){
            item.FSM_ExternalId__c = extID;
            return this;
        }
        //Setter method for the Retry Flag field
        public ErrorLogCreator setRetryFlag(Boolean retryFlag){
            item.FSM_RetryFlag__c = retryFlag;
            return this;
        }
        //Setter method for the Interface field
        public ErrorLogCreator setInterface(String interfaceName){
            item.FSM_Interface__c = interfaceName;
            return this;
        }
        //Creates a new FSM_ErrorLog__c record if the current user has permission to create it.
        public FSM_ErrorLog__c create() {
            if (SObjectType.FSM_ErrorLog__c.isCreateable()) {
                Insert item;
            }
            return item;
        }
        //Returns the existing 'item' instance of FSM_ErrorLog__c
        public FSM_ErrorLog__c returnWithoutCreate(){
            return item;
        }
    }
    
    /********************************************************************************************************
@Author      : Subir Maji
@description : This Method will be used to create Integration log record
@description : Created as part of user story #SFI-35
@Date        : 7-August-2023
********************************************************************************************************/ 
    public with sharing class IntegrationLogCreator {
        FSM_IntegrationLog__c item;
        //Constructor
        public IntegrationLogCreator() {
            item = new FSM_IntegrationLog__c();
        }
        //Setter method for the Record Id field
        public IntegrationLogCreator setRecordId(String recId){
            item.FSM_RecordId__c = recId;
            return this;
        }
        //Setter method for the Request Payload field
        public IntegrationLogCreator setReqPayload(String reqPayload){
            item.FSM_RequestPayload__c = reqPayload;
            return this;
        }
        //Setter method for the Response Payload field
        public IntegrationLogCreator setResPayload(String resPayload){
            item.FSM_ResponsePayload__c = resPayload;
            return this;
        }
        //Setter method for the Service Name field
        public IntegrationLogCreator setServiceName(String servicename){
            item.FSM_ServiceName__c = servicename;
            return this;
        }
        //Setter method for the External Id field
        public IntegrationLogCreator setExternalId(String extId){
            item.FSM_ExternalId__c = extId;
            return this;
        }
        //Creates a new FSM_IntegrationLog__c record if the current user has permission to create it.
        public FSM_IntegrationLog__c create() {
            if (SObjectType.FSM_IntegrationLog__c.isCreateable()) {
                Insert item;
            }
            return item;
        }
        //Returns the existing 'item' instance of FSM_IntegrationLog__c
        public FSM_IntegrationLog__c returnWithoutCreate(){
            return item;
        }
    }
}
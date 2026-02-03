/**----------------------------------------------------
* @description :  To get avilable appointment booking slots               
* @group      :  Capgemini
* Test Class  :  FSM_AppointmentBookingTest
* ver    Date                Author             Modification
1.0    23th June 2023       Srikanth           Created-SFI-261
2.0    11th June 2024       Srikanth           Updated-SFI-2213
--------------------------------------------------*/
@RestResource(urlMapping='/FSM_CreateCustomerAppointmentWOSA')
global with sharing class FSM_CreateCustomerAppointmentWOSA {
    /**
    * @description createData to create required data
    * @added as part of SFI-261, Srikanth Palla, 23th June 2023
    */
    @HttpPost
    global static void createData(){
        RestRequest req=RestContext.request;
        RestResponse res=RestContext.response;
        String resBody; //Response body
        try{
            //De-serilize the request body
            FSM_AppointmentRequest requestData=(FSM_AppointmentRequest)json.deserialize(req.requestBody.toString(),FSM_AppointmentRequest.class);
            FSM_AppointmentBookingHelper.checkForDataIssues(requestData); //Check for data Errors, Added by Subir Maji 16th July 2024 as part of SFI-2479
            ServiceTerritory st=FSM_AppointmentBookingHelper.st; //Get Service territory
            Id operatingHoursId=FSM_AppointmentBookingHelper.oh.ID; //Get Operating Hours ID
            WorkOrder wo=FSM_AppointmentBookingHelper.createWorkOrder(requestData,st); //Create teh Work Order and Skill requirement and Preferred resource
            ServiceAppointment sa=FSM_AppointmentBookingHelper.createServiceAppointment(requestData,st,wo); //Create the Appointment
            //Get Scheduling policy based on Service territory, if no territory present in Service territory then get default Policy
            Id schedulingPolicyId=st.FSM_SchedulingPolicy__c!=NUll?st.FSM_SchedulingPolicy__c:FSM_AppointmentBookingHelper.getDefaultSchedulingPolicyID();
            String timezone=userInfo.getTimeZone().toString();//Logged in User timezone
            List<Id> idList=new List<Id>(); //To collect all record id to send to SAP
            idList.add(wo.Id);
            idList.add(sa.Id);
            idList.add(operatingHoursId);
            idList.add(schedulingPolicyId);
            RecordDetail responseWrap=returnData(idList,timezone); //Put relavant data in wrapper
            resBody  = JSON.serialize(responseWrap); //Create JSON body          
            res.responseBody = Blob.valueOf(resBody); //Set response body
            res.statusCode = FSM_Constants.RESPONSE_200; //Set response code
            //Updated by Subir Maji 16th July 2024 as part of SFI-2479
            new FSM_Utility.IntegrationLogCreator().setReqPayload(req.requestBody.toString()).setResPayload(resBody).setServiceName('FSM_CreateCustomerAppointmentWOSA').create(); //To Create Integration log first with Request body
        }
        catch(exception e){ //If error
            FSM_AppointmentBookingHelper.ErrorResponseWrapper wrap = FSM_AppointmentBookingHelper.returnErrorResponse(e.getMessage());
            resBody  = JSON.serialize(wrap); //Serilize Error message         
            res.responseBody = Blob.valueOf(resBody); //Set response body
            res.statusCode = FSM_Constants.RESPONSE_400; //set response code
            //Added by Subir Maji 16th July 2024 as part of SFI-2479
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_CreateCustomerAppointmentWOSA').setErrorMessage(resBody).setLineNumber(String.valueof(e.getLineNumber())).setInterface('INT-011').setMethodName('createData').setStackTrace(req.requestBody.toString()).setType('Integration').create();
            new FSM_Utility.IntegrationLogCreator().setReqPayload(req.requestBody.toString()).setResPayload(resBody).setServiceName('FSM_CreateCustomerAppointmentWOSA').create(); //To Create Integration log first with Request body
        }
    }
    
    /**
    * @description returnData to return response
    * @param idList
    * @param timezone
    * @return RecordDetail
    */
    private static RecordDetail returnData(List<Id> idList,string timezone){
        RecordDetail wrap=new RecordDetail();
        wrap.WorkorderId=idList[0];
        wrap.ServiceAppointmentId=idList[1];
        wrap.OperatingHoursId=idList[2];
        wrap.SchedulingPolicyId=idList[3];
        wrap.TimeZone=timezone;
        return wrap;
    }
    
    /**
    * @description RecordDetail for response
    */
    public class RecordDetail{
        private string workorderId;
        private string serviceAppointmentId;
        private string schedulingPolicyId;
        private string operatingHoursId;
        private string timeZone;
    }
    
    /**
    * @description FSM_AppointmentRequest for request
    */
    public class FSM_AppointmentRequest{
        public string earlyStart; //Changed to String as part of SFI-2566 by Subir Maji 30th July 24
        public string dueDate; //Changed to String as part of SFI-2566 by Subir Maji 30th July 24
        public string priority;
        public string serviceTerritoryId;
        public string postcode;
        public string latitude; //Changed to String as part of SFI-2566 by Subir Maji 30th July 24
        public string longitude; //Changed to String as part of SFI-2566 by Subir Maji 30th July 24
        public string[] preferredResource;
        public string taskType;
        public string duration; //Changed to String as part of SFI-2566 by Subir Maji 30th July 24
        public string[] requiredSkills;
        public string businessArea;
        public string standardTextKey;
        public string slotType; 
        public string durationType;
        public string minimumCrewSize;
    }
}
/**----------------------------------------------------
* @description :  To get avilable appointment booking slots               
* @group      :  Capgemini
* Test Class  :  FSM_AppointmentBookingTest
* ver    Date                Author             Modification
1.0    23th June 2023       Srikanth           Created-SFI-31
--------------------------------------------------*/
@RestResource(urlMapping='/FSM_AppointmentBooking')
global with sharing class FSM_AppointmentBooking {
    
    /**
    * @description getAppointmentBookingSlots to get avilable slots
    */
    @HttpPost
    global static void getAppointmentBookingSlots(){
        RestRequest req=RestContext.request;
        RestResponse res=RestContext.response;
        try{
            FSM_AppointmentRequest requestData=(FSM_AppointmentRequest)json.deserialize(req.requestBody.toString(),FSM_AppointmentRequest.class);

            Timezone timeZone =userInfo.getTimeZone();

            
            List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(requestData.RecordDetails.ServiceAppointmentId,requestData.RecordDetails.SchedulingPolicyId,requestData.RecordDetails.OperatingHoursId,timeZone,false);

            res.responseBody = Blob.valueOf(JSON.serialize(returnResponseSlots(slots)));
            res.statusCode = FSM_Constants.RESPONSE_200;
            deleteSAWO(requestData.RecordDetails.ServiceAppointmentId,requestData.RecordDetails.workorderId);
            //Added by Subir Maji 16th July 2024 as part of SFI-2479
            new FSM_Utility.IntegrationLogCreator().setReqPayload(req.requestBody.toString()).setResPayload(JSON.serialize(returnResponseSlots(slots))).setServiceName('FSM_AppointmentBooking').create();
        }
        catch(exception e){ //Updated by Subir Maji 16th July 2024 as part of SFI-2479
            FSM_AppointmentBookingHelper.ErrorResponseWrapper wrap = FSM_AppointmentBookingHelper.returnErrorResponse(e.getMessage());
            String resBody  = JSON.serialize(wrap);          
            res.responseBody = Blob.valueOf(resBody);
            res.statusCode = FSM_Constants.RESPONSE_400;

            //Added by Subir Maji 16th July 2024 as part of SFI-2479
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_AppointmentBooking').setErrorMessage(resBody).setInterface('INT-011').setLineNumber(String.valueof(e.getLineNumber())).setMethodName('getAppointmentBookingSlots').setStackTrace(req.requestBody.toString()).setType('Integration').create();
            new FSM_Utility.IntegrationLogCreator().setReqPayload(req.requestBody.toString()).setResPayload(resBody).setServiceName('FSM_AppointmentBooking').create();
        }
    }
    /**
    * @description FSM_AppointmentRequest
    * @param slots
    * @return ResponseWrapper
    * @Created by Subir Maji 11th April 2024 user story SFI-xxx
    */
    Private static List<ResponseWrapperSlots> returnResponseSlots(List<FSL.AppointmentBookingSlot> slots){
        List<ResponseWrapperSlots> allSlots = new List<ResponseWrapperSlots>();
        ResponseWrapperSlots wrap;
        
        if(slots != null && !slots.isEmpty()){
            for(integer i=0; i<slots.size(); i++){
                wrap = new ResponseWrapperSlots();
                wrap.intervalStartTime = slots[i].Interval.Start;
                wrap.intervalEndTime = slots[i].Interval.Finish;
                wrap.grade = slots[i].Grade;
                allSlots.add(wrap);
        	}
    	}
        return allSlots;
    }
       
    /**
    * @description Delete records
    * @param saId
    * @param woId
    */
    Private static void deleteSAWO(Id saId,Id woId){
        List < Id > toDeleteIds = new List < Id >();
        IF(saId != Null && woId != Null && Schema.sObjectType.ServiceAppointment.isDeletable() && Schema.sObjectType.WorkOrder.isDeletable()){
            toDeleteIds.add(saId);
            toDeleteIds.add(woId);
            
            Database.delete( toDeleteIds, true );
        }
    }
    /**
    * @description FSM_AppointmentRequest
    */
    public class FSM_AppointmentRequest{
        public RecordDetail recordDetails;
    }
    
    /**
    * @description RecordDetail
    */
    public class RecordDetail{
        public string workorderId;
        public string serviceAppointmentId;
        public string schedulingPolicyId;
        public string operatingHoursId;
        public string timeZone;
    }
    
    /**
    * @description Response Wrapper
    * @param 
    * @return 
    * @Created by Subir Maji 11th April 2024 user story SFI-xxx
    */
    public class ResponseWrapperSlots{
        public DateTime intervalStartTime;
        public DateTime intervalEndTime;
        public Decimal grade;
        
    }
}
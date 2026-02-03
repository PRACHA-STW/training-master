/********************************************************************************************************
@Apex className: FSM_TimeSheetEntryGenerator
@Author      : Manish & Srikanth
@description : This class is designed to generate a JSON payload to publish a platform event for Time Sheet Entry records.
@description : Created as part of user story #SFI-1557
@Test Class  : FSM_TimeSheetEntryGeneratorTest
@date        : 04-March-2024
********************************************************************************************************/
public without sharing class FSM_TimeSheetEntryGenerator {
    /**
     * @methodName : tsejsonGenerator
     * @description :This is an invocable method that is called from flows to retrieve TimesheetEntry IDs.
     * @param : ids - A list of TSEInputParams containing TimesheetEntry IDs.
     * @return : A list of JSON strings containing the TimesheetEntry data.
    */
    @InvocableMethod(label = 'TimeSheetEntryGenerator')
    public static List<String> tsejsonGenerator(List<TSEInputParams> ids){
        Set<id> timeSheetEntryIDs =new Set<id>();           //To store TimeSheetentry ids
        string mergedString;                                // To store final merged JSON response
        string response;                                    // To store the response from the method       
        List<String> outputs=new List<String>();            // To return the final output from the invocable method 
        List<TimesheetEntry> timeSheetEntryList;            // To store the list of TimesheetEntry records
        
		try{
			//Collect all TSE Id's
            for(TSEInputParams tse:ids){
                timeSheetEntryIDs.addAll(tse.tseId);
            }
			//Based on ID and other condition Query all Timesheet records
			//Updated by Vishesh Gupta, 4th July 2025, as part of SFL-889, added Service resource external id field and added condition to check resource type
            timeSheetEntryList= new List<TimesheetEntry> ([SELECT Id,StartTime,EndTime,Type,
                                                           FSM_TimeDuration__c,FSM_FinalConfirmation__c,FSM_NonProductiveReason__c,
                                                           TimeSheet.ServiceResource.FSM_ExternalId__c 
                                                           FROM TimesheetEntry 
                                                           WHERE Id IN:timeSheetEntryIDs AND 
                                                           TimeSheet.ServiceResource.FSM_ExternalId__c != null AND 
                                                           TimeSheet.ServiceResource.ResourceType = 'T'  WITH SECURITY_ENFORCED]);
            //If TSE records found call prepareTimesheetJsonResponse to get the JSON structure
			if(timeSheetEntryList!=NULL && !timeSheetEntryList.isEmpty()){
                response = prepareTimesheetJsonResponse(timeSheetEntryList);
            }
			//Prepare final JSON structure
            mergedString = response;
        }Catch(Exception ex){ //If any exception create error log
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_TimeSheetEntryGenerator').setMethodName('tsejsonGenerator').setErrorMessage(ex.getMessage()).setLineNumber(String.valueOf(ex.getLineNumber())).setStackTrace(ex.getStackTraceString()).setType('Integration').create();
        }
        outputs.add(mergedString);                          // Adding the final merged JSON response to outputs list
        return outputs;
    }
    
    /**
     * @className : TSEInputParams
     * @description : These are invocable variables that are called from flows.
     * @InvocableVariable : This class is used to pass the TimesheetEntry IDs from the flow to the invocable method.
     * @InvocableVariable : It contains a list of TimesheetEntry IDs.
    */
    Public class TSEInputParams{
        @InvocableVariable
        public List<id> tseId; //List of TSE ids coming from Flow
    }
    
    /**
     * @className : TimesheetEntryWrapper
     * @description : This class is used to wrap the TimesheetEntry fields into a structure.
    */
    public class TimesheetEntryWrapper{
        DateTime StartTime; //TSE Start Time
        DateTime EndTime; //TSE End Time
        String Type; //TSE Type
        String TimeDuration; //TSE Duration
        String FinalConfirmation; //TSE final confirmation if any
        String NonProductiveReason; //TSE non Productiv reason if any
    }
    
    /**
     * @className : ServiceResourceTimesheetWrapper
     * @description : This class is used to wrap the ServiceResource and its associated TimesheetEntries.
     * @description : It contains the ServiceResource's external ID and a list of TimesheetEntryWrapper objects.
     * @description : This structure is used to prepare the final JSON response.
     * @description : This class is created as part of user story SFL-889.
     * @Variable : ServiceResourceExtID - The external ID of the ServiceResource.
     * @Variable : TimesheetEntries - A list of TimesheetEntryWrapper objects that represent the timesheet entries for the ServiceResource.
	 *@history : Created by Vishesh Gupta, 4th July 2025, as part of SFL-889
    */
    public class ServiceResourceTimesheetWrapper{
        String ServiceResourceExtID; //Service resource External ID
        List<TimesheetEntryWrapper> TimesheetEntries; //Collection of TSE againest Service Resource
    }
    
    /**
     * @methodName : mappingTimeSheetRecords
     * @description : This method maps the TimesheetEntry records to a TimesheetEntryWrapper object.
     * @param tseRecord, The TimesheetEntry record to be mapped.
     * @return TimesheetEntryWrapper, The wrapper object containing mapped values from the TimesheetEntry.
    */
    Private static TimesheetEntryWrapper mappingTimeSheetRecords(TimesheetEntry tseRecord){
        TimesheetEntryWrapper tseWrapper=new TimesheetEntryWrapper(); //Creating new Wrapper class Variable to assign values
        tseWrapper.StartTime=tseRecord.StartTime; //Assign Start Time
        tseWrapper.EndTime=tseRecord.EndTime; //Assign End Time
        tseWrapper.Type=tseRecord.Type; //Assign TSE Type
        tseWrapper.TimeDuration=String.valueOf(tseRecord.FSM_TimeDuration__c); //Assign TSE duration in String format
        tseWrapper.FinalConfirmation=String.valueOF(tseRecord.FSM_FinalConfirmation__c); // Assign Final confirmation as True or False
        tseWrapper.NonProductiveReason=tseRecord.FSM_NonProductiveReason__c; //Assign Non productive reason if any
        return tseWrapper;
    }
	
	/**
     * @methodName : mappingTimeSheetWithResource
     * @description : This method maps the TimesheetEntry records with Service resource to a ServiceResourceTimesheetWrapper object.
     * @param servresExtID, Service resource Resource ext id.
	 * @param listOfTimesheetEntry, List of TimesheetEntry records to be mapped with Resource ext id.
     * @return ServiceResourceTimesheetWrapper, The wrapper object containing mapped values from the TimesheetEntry and service resource.
	 *@history : Created by Vishesh Gupta, 4th July 2025, as part of SFL-889
    */
    Private static ServiceResourceTimesheetWrapper mappingTimeSheetWithResource(String servResExtID, List<TimesheetEntryWrapper> listOfTimesheetEntry){
        ServiceResourceTimesheetWrapper tseWrapper = new ServiceResourceTimesheetWrapper(); //Creating new variable for Wrapper class
        tseWrapper.ServiceResourceExtID=servResExtID; //Assigning Service resource external Id
        tseWrapper.TimesheetEntries=listOfTimesheetEntry; //Assigning List of Time sheet Entries
        
        return tseWrapper;
    }
    
    /**
     * @methodName : prepareTimesheetJsonResponse
     * @description : This method prepares the JSON response for TimesheetEntry records.
     * @description : This method is created as part of user story SFL-889.
     * @param timesheetEntries, A list of TimesheetEntry records to be processed.
     * @return String, The JSON string representing the TimesheetEntry data grouped by ServiceResource external ID.
	 *@history : Created by Vishesh Gupta, 4th July 2025, as part of SFL-889
    */
    Private static String prepareTimesheetJsonResponse(List<TimesheetEntry> timesheetEntries) {
        String externalId; //Temporary variable to hold Serviec resource external id
        TimesheetEntryWrapper wrappedEntry; //Wrapper class variable to hold Time sheet entry structure
        Map<String, List<TimesheetEntryWrapper>> externalIdToTimesheetWrappers = new Map<String,List<TimesheetEntryWrapper>>(); //variable to create a map between Service resource External id and Time sheet entries
		List<ServiceResourceTimesheetWrapper> finalListForWrap = new  List<ServiceResourceTimesheetWrapper>(); //List of all Service resource and Time sheet entries under a single appointmnet.
		//loop through Time sheet entries records and prepare the externalIdToTimesheetWrappers map
        for (TimesheetEntry timeSheetEntry : timeSheetEntries){
            externalId = timeSheetEntry.Timesheet.ServiceResource.FSM_ExternalId__c;
            wrappedEntry = mappingTimeSheetRecords(timeSheetEntry);
            if (!externalIdToTimesheetWrappers.containsKey(externalId)) {
                externalIdToTimesheetWrappers.put(externalId, new List<TimesheetEntryWrapper>());
                externalIdToTimesheetWrappers.get(externalId).add(wrappedEntry);
            }else{
                externalIdToTimesheetWrappers.get(externalId).add(wrappedEntry);
            }          
        }
		//Loop through externalIdToTimesheetWrappers map Keyset and prepare the list of finalListForWrap
		for(String servExtId : externalIdToTimesheetWrappers.KeySet()){
			finalListForWrap.add(mappingTimeSheetWithResource(servExtId, externalIdToTimesheetWrappers.get(servExtId)));
		}
		//Serialize finalListForWrap and return back
        String jsonString = JSON.serialize(finalListForWrap);
        return jsonString;
    }
}
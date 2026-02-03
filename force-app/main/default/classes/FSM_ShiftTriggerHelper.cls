/********************************************************************************************************
@Author      : Subir Maji
@description : FSM_ShiftTriggerHelper class to handle trigger logic.
@description : Created as part of user story #SFI-2314
@Test Class  : FSM_ShiftTriggerHelperTest
@Date        : 26-June-2024
********************************************************************************************************/
public with sharing class FSM_ShiftTriggerHelper {
     
    /*********************************************************************
    * @description :Check the Shift Condition and prepare map for timesheet creation
    * @param newMap
    * @param oldMap
    * @param newList
    * @added as part of SFI-2314, Subir Maji, 26-June-2024
    ********************************************************************/    
    public void checkLogicForTimeSheetCreateion(List<sObject> newList,Map<Id,sObject> newMap,Map<Id,sObject> oldMap){
        Map<Id, Shift> allNewShift=(Map<Id, Shift>)newMap; //collecting all Updated Shift
        Map<Id, Shift> allOldShift=(Map<Id, Shift>)oldMap; //collecting all Updated Shift old values
        List<Shift> allNewList = (List<Shift>)newList; //collecting all new Shift
        List<Shift> allUpdatedShiftTimeSheet = new List<Shift>(); //Collecting all valid Shifts for timesheet creation
        Shift oldShift; //Temporary variable to hold old Shift data
        Set<ID> serviceResourceID = new Set<Id>(); //Set of all relavant service resource from Shift
        Set<Date> startDate = new Set<Date>(); //Set of all the dates WRT Shift
        
        //Check if record created or updated based on that collect info
        if(allNewList != null && !allNewList.isEmpty()){ //If Created
            for(Shift sft : allNewList){
                if(sft.ServiceResourceId != null && sft.StartTime != null && sft.EndTime != null){
                    allUpdatedShiftTimeSheet.add(sft);
                    startDate.add(sft.StartTime.date());
                    serviceResourceID.add(sft.ServiceResourceId);
                }
            }
            if(!allUpdatedShiftTimeSheet.isEmpty()){ //Call Other method to create Timesheet
                createTimeSheet(allUpdatedShiftTimeSheet, startDate, serviceResourceID);
            }
        }else{ //If Updated
            for(Shift sft : allNewShift.Values()){
                oldShift = allOldShift.get(sft.Id);
                if(sft.ServiceResourceId != null && sft.StartTime != null && sft.EndTime != null &&
													(sft.ServiceResourceId != oldShift.ServiceResourceId
                                                    || sft.StartTime != oldShift.StartTime || sft.EndTime != oldShift.EndTime)){
                    allUpdatedShiftTimeSheet.add(sft);
                    startDate.add(sft.StartTime.date());
                    serviceResourceID.add(sft.ServiceResourceId);
                }
            }
            if(!allUpdatedShiftTimeSheet.isEmpty()){ //Call Other method to create Timesheet
                createTimeSheet(allUpdatedShiftTimeSheet, startDate, serviceResourceID);
            }
        }
    }
    
    /*********************************************************************
    * @description :Check For existing Timesheet and create new Timesheet
    * @param allNewShift
    * @param startDate
    * @param serviceResourceID
    * @added as part of SFI-2314, Subir Maji, 26-June-2024
	* @Updated as part of SFI-2782, Subir Maji, 18-Sept-2024
    ********************************************************************/   
    private void createTimeSheet(List<Shift> allNewShift, Set<Date> startDate, Set<ID> serviceResourceID){
        MAP<ID, Map<Date, ID>> servResTimeSheetMap = new MAP<ID, Map<Date, ID>>();//Map to hold if a Timesheet available for a Service resource for a Given Date //Updated as part of SFI-2782, Subir Maji, 18-Sept-2024
        TimeSheet timeSh; //Temporary variable for Timesheet
        Map<Shift,TimeSheet> allTimeSheet = new Map<Shift,TimeSheet>(); //Collect all Timesheet WRt Shift
        List<FSM_ErrorLog__c> errorLogList = new List<FSM_ErrorLog__c>(); //Collect all errorlog
        
        //Query Existing Timesheet
        Map<ID,TimeSheet> allExistingTimesheet = new Map<ID,TimeSheet>([Select ID, StartDate, ServiceResourceId 
                                                                        From TimeSheet
                                                                        Where ServiceResourceId IN : serviceResourceID
                                                                        AND StartDate IN : startDate WITH SECURITY_ENFORCED]);
        
        //If Timesheet present then prepare map
        if(allExistingTimesheet != null && !allExistingTimesheet.isEmpty()){
            for(TimeSheet ts : allExistingTimesheet.Values()){
                if(servResTimeSheetMap.containsKey(ts.ServiceResourceId)){
                    servResTimeSheetMap.get(ts.ServiceResourceId).put(ts.StartDate, ts.ID); //Updated as part of SFI-2782, Subir Maji, 18-Sept-2024
                }else{
                    servResTimeSheetMap.put(ts.ServiceResourceId, new Map<Date, ID>()); //Updated as part of SFI-2782, Subir Maji, 18-Sept-2024
                    servResTimeSheetMap.get(ts.ServiceResourceId).put(ts.StartDate, ts.ID); //Updated as part of SFI-XXXX, Subir Maji, 18-Sept-2024
                }
            }
        } 
        
        //go through Shift and create timesheet
        for(Shift sft : allNewShift){
            //Updated as part of SFI-2782, Subir Maji, 18-Sept-2024
            if(!servResTimeSheetMap.containsKey(sft.ServiceResourceId) || (servResTimeSheetMap.containsKey(sft.ServiceResourceId) && !servResTimeSheetMap.get(sft.ServiceResourceId).containsKey(sft.StartTime.date()))){
                timeSh = new TimeSheet();
                timeSh.StartDate = sft.StartTime.date();
                timeSh.EndDate = sft.EndTime.date();
                timeSh.ServiceResourceId = sft.ServiceResourceId;
                allTimeSheet.put(sft,timeSh);
            }else if(servResTimeSheetMap.containsKey(sft.ServiceResourceId) && servResTimeSheetMap.get(sft.ServiceResourceId).containsKey(sft.StartTime.date())){ //Added as part of SFI-2782, Subir Maji, 18-Sept-2024
                sft.FSM_TimeSheetId__c = servResTimeSheetMap.get(sft.ServiceResourceId).get(sft.StartTime.date()); //Added as part of SFI-2782, Subir Maji, 18-Sept-2024
            }
        }
        
        //Insert Timesheet or errorlog
        if(allTimeSheet != null && !allTimeSheet.isEmpty() && Schema.sObjectType.TimeSheet.isCreateable()){
            try{
                List<Database.SaveResult> results = Database.insert(allTimeSheet.Values(), false);
                
                for(Shift sft : allTimeSheet.KeySet()){
                    sft.FSM_TimeSheetId__c = allTimeSheet.get(sft).Id;
                }
                
                for(Database.SaveResult sr : results) {
                    if(!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            errorLogList.add(new FSM_Utility.ErrorLogCreator().setClassName('FSM_ShiftTriggerHelper').setMethodName('createTimeSheet').setErrorMessage(err.getStatusCode() + ': ' + err.getMessage() + '. Fields : '+err.getFields()).setType('Integration').returnWithoutCreate());
                        }
                    }
                }
                if(Schema.sObjectType.FSM_ErrorLog__c.isCreateable() && errorLogList != null && !errorLogList.isEmpty()){
                    Insert errorLogList;
                }
                
            }Catch(Exception e){
                new FSM_Utility.ErrorLogCreator().setClassName('FSM_ShiftTriggerHelper').setMethodName('createTimeSheet').setErrorMessage(e.getMessage()).setLineNumber(String.valueOf(e.getLineNumber())).setStackTrace(e.getStackTraceString()).setType('Integration').create();
            }
        }
    }
}
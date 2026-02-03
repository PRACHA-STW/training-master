/** ************************************************************************************
@Author : Brajesh Kumar
@Description  : Created for Calculation of Next Working Day for Earliest Schedulable Date
@Created Date : 31st July 2024
@Test Class : Fsm_WorkdayDateUtilityTest
@description : Created as part of user story SFS-6665
**************************************************************************************** **/

public without sharing class Fsm_WorkdayDateUtility {
    
    private static Id businessHoursId;
    
    @InvocableMethod(label='Calculate Next Working Date')
    public static List<WorkingDate> calculateNextWorkingDate(List<Request> requests) {
        List<WorkingDate> results = new List<WorkingDate>();
        
        // Fetch the default business hours
        if(businessHoursId == null){
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true  WITH SECURITY_ENFORCED  LIMIT 1];
            businessHoursId = bh.Id;
        }
        
        for (Request req : requests) {
         //   DateTime currentDateTime = req.currentDateTime; // old
            
            DateTime dateTimeValue = req.currentDateTime;
            Date currentDateTime = dateTimeValue.date();
            
            Integer daysToAdd = req.daysToAdd;
            System.debug('Current DateTime: ' + currentDateTime + ', Days to Add: ' + daysToAdd);
            
            DateTime futureDateTime = addBusinessDays(currentDateTime, daysToAdd, businessHoursId);
            
            DateTime nextWorkingDateTime = getNextWorkingDay(futureDateTime, businessHoursId);
            
            WorkingDate wd = new WorkingDate();
            wd.nextWorkingDate = nextWorkingDateTime.date();
            results.add(wd);
        }
        return results;
    }
    
    private static DateTime getNextWorkingDay(DateTime dateTimes, Id businessHoursId) {
        DateTime nextWorkingDateTime = dateTimes;
        if (!BusinessHours.isWithin(businessHoursId, nextWorkingDateTime)) {
            nextWorkingDateTime = BusinessHours.nextStartDate(businessHoursId, nextWorkingDateTime);
        }
        return nextWorkingDateTime;
    }
    
    private static DateTime addBusinessDays(DateTime startDate, Integer daysToAdd, Id businessHoursId) {
        DateTime resultDate = startDate;
        Integer addedDays = 0;
        
        while (addedDays < daysToAdd) {
            // Move to the next day
            resultDate = resultDate.addDays(1);
            
            // Check if the current date is within business hours
            if (BusinessHours.isWithin(businessHoursId, resultDate)) {
                System.debug('addedDays-->'+addedDays);
                addedDays++;
            }

            System.debug('Intermediate resultDate: ' + resultDate + ', Added Days: ' + addedDays);
        }
        System.debug('resultDate-->'+resultDate);
        return resultDate;
    }
    
    
    public class Request {
        @InvocableVariable
        public DateTime currentDateTime;
        
        @InvocableVariable
        public Integer daysToAdd;
    }
    
    public class WorkingDate {
        @InvocableVariable
        public Date nextWorkingDate;
    }
}
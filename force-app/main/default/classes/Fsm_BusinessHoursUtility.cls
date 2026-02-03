/** ************************************************************************************
@Author : Brajesh Kumar
@Description  : Created for Calculation of Next Working Day for Earliest Schedulable Date 
@Created Date : 30th July 2024
@Test Class : Fsm_BusinessHoursUtilityTest
@description : Created as part of user story SFS-6665 
**************************************************************************************** **/

public without sharing class Fsm_BusinessHoursUtility {
    @InvocableMethod(label='Check If Today Is Working Day')
    public static List<BusinessHoursResult> checkIfTodayIsWorkingDay() {
        List<BusinessHoursResult> results = new List<BusinessHoursResult>();

        // Fetch the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true WITH SECURITY_ENFORCED LIMIT 1];

        // Use the current date and time : 10 AM
        DateTime targetDateTime = DateTime.newInstance(Date.today(), Time.newInstance(10, 0, 0, 0));
        
        // Check if the DateTime is within business hours
        Boolean isWithinBusinessHours = BusinessHours.isWithin(bh.Id, targetDateTime);
        
        // Create result object
        BusinessHoursResult result = new BusinessHoursResult();
        result.isWithinBusinessHours = isWithinBusinessHours;
        results.add(result);

        return results;
    }

    public class BusinessHoursResult {
        @InvocableVariable
        public Boolean isWithinBusinessHours;
    }
}
/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class is used to test Calculation of Next Working Day for Earliest Schedulable Date 
@description : Created as part of user story #SFS-6665
@Main Class  : Fsm_BusinessHoursUtility 
@Date        : 30th July 2024
********************************************************************************************************/
@isTest(SeeAllData=false)
public class Fsm_BusinessHoursUtilityTest {
    @isTest
    static void testCheckIfTodayIsWorkingDay() {
        // Retrieve the default business hours
        BusinessHours defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];

        // Ensure the default business hours exist
        System.assertNotEquals(null, defaultBusinessHours, 'Default business hours should be set up in the org.');

        // Call the method
        Test.startTest();
        List<Fsm_BusinessHoursUtility.BusinessHoursResult> results = Fsm_BusinessHoursUtility.checkIfTodayIsWorkingDay();
        Test.stopTest();

        // Validate the results
        System.assertEquals(1, results.size(), 'There should be one result');
        
        DateTime targetDateTime = DateTime.newInstance(Date.today(), Time.newInstance(10, 0, 0, 0));
        Boolean expected = BusinessHours.isWithin(defaultBusinessHours.Id, targetDateTime);
        System.assertEquals(expected, results[0].isWithinBusinessHours, 'The result should match the expected value');
    }
}
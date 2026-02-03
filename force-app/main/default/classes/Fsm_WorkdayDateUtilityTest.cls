/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class is used to test Calculation of Earliest Schedulable Date 
@description : Created as part of user story #SFS-6665
@Main Class  : Fsm_WorkdayDateUtility 
@Date        : 2nd-August-2024
********************************************************************************************************/

@isTest(SeeAllData=false)
public class Fsm_WorkdayDateUtilityTest {
    @isTest
    static void testCalculateNextWorkingDate() {
        // Create test data
        List<Fsm_WorkdayDateUtility.Request> requests = new List<Fsm_WorkdayDateUtility.Request>();

        // Test case 1: Adding 11 business days to August 2, 2024
        Fsm_WorkdayDateUtility.Request req1 = new Fsm_WorkdayDateUtility.Request();
        req1.currentDateTime = DateTime.newInstance(2024, 8, 2, 10, 0, 0);
      //  req1.currentDateTime = DateTime.newInstance(2024, 8, 5, 10, 0, 0);
        req1.daysToAdd =11;
        requests.add(req1);

        // Run the method
        Test.startTest();
        List<Fsm_WorkdayDateUtility.WorkingDate> results = Fsm_WorkdayDateUtility.calculateNextWorkingDate(requests);
        Test.stopTest();

        // Verify result for the first request
       System.assertEquals(Date.newInstance(2024, 8, 19), results[0].nextWorkingDate, 'The next working date is incorrect');
    }
}
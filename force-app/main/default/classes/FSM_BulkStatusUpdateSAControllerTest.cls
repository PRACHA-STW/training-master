/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class is used to test Bulk Status Update Action
@description : Created as part of user story #SFS-6634
@Main Class  : FSM_BulkStatusUpdateSAController 
@Date        : 16th June 2024
********************************************************************************************************/
@isTest
public class FSM_BulkStatusUpdateSAControllerTest {
    /*******************************************************************************************************
@Author      : Brajesh Kumar
@description : Test method for FSM_BulkStatusUpdateSAController.getStatusTransition().
               This method checks if the getStatusTransition() method returns a list with a size greater than 0.
********************************************************************************************************/
    @IsTest
    static void testGetStatusTransition() {
        Test.startTest();
        List<FSM_StatusTransition__mdt> result = FSM_BulkStatusUpdateSAController.getStatusTransition();
        Test.stopTest();
        // Verify the result
        System.assert(result.size() > 0, 'Expected non-zero length for status transition records');
    }
    /*******************************************************************************************************
@Author      : Brajesh Kumar
@description : Test method for FSM_BulkStatusUpdateSAController.getRejectionDetails().
               This method checks if the getRejectionDetails() method returns a list with a size greater than 0.
********************************************************************************************************/
    @IsTest
    static void testGetRejectionDetails() {
        // Call the method
        Test.startTest();
        List<FSM_CMDTLevel2__mdt> result = FSM_BulkStatusUpdateSAController.getRejectionDetails();
        Test.stopTest();
        
        // Verify the result
        System.assert(result.size() > 0, 'Expected non-zero length for rejection detail records');
    }   
}
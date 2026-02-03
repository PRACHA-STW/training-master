/*------------------------------------------------------------
* @description:  A test class for FSM_DeleteBatchLog.               
* @group:        Capgemini
* ver    Date                Author             Modification
1.0    23th June 2023       Srikanth           Created class-SFI-193
------------------------------------------------------------*/
@isTest
public class FSM_DeleteBatchLog_Test {
 @isTest
    private static void execute() {
        FSM_DeleteBatchLog eraser = new FSM_DeleteBatchLog();
        eraser.listQueries = new List<FSM_BatchClassQueries__mdt>{
            new FSM_BatchClassQueries__mdt(
                FSM_Active__c = true,
                FSM_Query__c = 'SELECT Id FROM FSM_IntegrationLog__c'
            )
        };
        Test.startTest();
        Database.executeBatch(eraser);
        String schTime = '0 0 12 * * ?';
        FSM_DeleteBatchLog schedulableEraser = new FSM_DeleteBatchLog();
        system.schedule('DataEraser', schTime, schedulableEraser);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM FSM_IntegrationLog__c].size(),'records size will be zero');
    }

    @TestSetup
    private static void testSetup() {
        FSM_IntegrationLog__c testLog = new FSM_IntegrationLog__c(FSM_ServiceName__c='Integration Log',FSM_ExternalId__c='3323'
        );
        insert testLog;
        System.assertEquals('Integration Log',testLog.FSM_ServiceName__c,'Log name');
    }

}
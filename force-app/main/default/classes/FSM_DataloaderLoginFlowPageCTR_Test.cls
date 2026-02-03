@isTest
public class FSM_DataloaderLoginFlowPageCTR_Test {
    @isTest
    static void testControllerInitialization() {
        // Set up test data
        String testRetURL = 'https://test.salesforce.com/RemoteAccessAuthorizationPage';

        // Mock the current page with parameters
        Test.startTest();
        PageReference testPage = new PageReference('/apex/TestPage');
        testPage.getParameters().put('retURL', testRetURL);
        Test.setCurrentPage(testPage);

        // Initialize the controller
        FSM_DataloaderLoginFlowPageCTR controller = new FSM_DataloaderLoginFlowPageCTR();

        // Assert that the redirectUrl is set correctly
        System.assertEquals(testRetURL, controller.redirectUrl);
        Test.stopTest();
    }

    @isTest
    static void testFinishLoginFlowHomeWithRemoteAccessPage() {
        // Set up test data
        String testRetURL = 'https://test.salesforce.com/RemoteAccessAuthorizationPage';

        // Mock the current page with parameters
        Test.startTest();
        PageReference testPage = new PageReference('/apex/TestPage');
        testPage.getParameters().put('retURL', testRetURL);
        Test.setCurrentPage(testPage);

        // Initialize the controller
        FSM_DataloaderLoginFlowPageCTR controller = new FSM_DataloaderLoginFlowPageCTR();

        // Invoke the method
        PageReference result = controller.FinishLoginFlowHome();

        // Assert that the result is not null and correct
        System.assertNotEquals(null, result, 'PageReference should not be null');
        Test.stopTest();
    }

    @isTest
    static void testFinishLoginFlowHomeWithoutRetURL() {
        // Mock the current page without parameters
        Test.startTest();
        PageReference testPage = new PageReference('/apex/TestPage');
        Test.setCurrentPage(testPage);

        // Initialize the controller
        FSM_DataloaderLoginFlowPageCTR controller = new FSM_DataloaderLoginFlowPageCTR();

        // Invoke the method
        PageReference result = controller.FinishLoginFlowHome();

        // Assert that the result is null
        System.assertEquals(null, result, 'PageReference should be null');
        Test.stopTest();
    }
}
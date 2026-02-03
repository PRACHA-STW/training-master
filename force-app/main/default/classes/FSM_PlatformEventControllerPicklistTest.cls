/********************************************************************************************************
@Author      : Himanshu Dobriyal
@description : Test class for FSM_PlatformEventControllerPicklist SFI-1002.
@Date        : 03-November-2023
********************************************************************************************************/
@isTest
public class FSM_PlatformEventControllerPicklistTest {
/********************************************************************************************************
@Author      : Himanshu Dobriyal
@description : This to test method isCurrentUserValidToSeeComponent on class FSM_PlatformEventControllerPicklist.
@Date        : 03-November-2023
********************************************************************************************************/
    @isTest
    static void testGetCustomSettingPicklistValues() {
        user testUser = new FSM_TestDataFactory.CretaeUser().create();//Creating Test user for data set up
        system.runas(testuser){ //logged in as a test User
        Test.startTest();
        boolean queryTest =FSM_PlatformEventControllerPicklist.isCurrentUserValidToSeeComponent();
       system.assertEquals(false,queryTest,'For standard user boolean value will be false');
        Test.stopTest();
        }
    }
/********************************************************************************************************
@Author      : Himanshu Dobriyal
@description : This to test method getCustomSettingPicklistValues on class FSM_PlatformEventControllerPicklist.
@Date        : 03-November-2023
********************************************************************************************************/
    @isTest
        static void testGetCustomMetadata(){
            Test.startTest();
            list<FSM_PlatformEventPicklistLwc__mdt> testQuery =FSM_PlatformEventControllerPicklist.getCustomSettingPicklistValues();
            system.assertEquals(true,testQuery[0].FSM_Active__c,'True value should be returned');
                Test.stopTest();
        }      
}
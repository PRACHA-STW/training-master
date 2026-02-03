/****************************************************************************************************************************
@Author : Rijita Bose
@Date   : 21/05/2024
@Description : Created as part of user story #SFS-5308
@Main Class : FSM_permissionsetgroupassign  
==============================================================================================================================
*/
@isTest(SeeAllData=false)
public class FSM_permissionsetgroupassigntest {
    @IsTest
    static void testMethod1()
    {
       // PermissionSetGroup psg = [select Id, Status from PermissionSetGroup where DeveloperName='FSM_AppointmentAssistantGroup'];
        PermissionSet psg = [SELECT Id FROM PermissionSet WHERE Name='FSM_AppointmentAssistant' LIMIT 1];
        FSM_permissionsetgroupassign.PermissionSetGroup permissionSetGroupData1 = new FSM_permissionsetgroupassign.PermissionSetGroup();
        permissionSetGroupData1.userId = Userinfo.getUserId();
     	permissionSetGroupData1.permissionSetGroupId = psg.Id;
        permissionSetGroupData1.assignPsg = true;
        permissionSetGroupData1.removePsg = false;
        Test.startTest();
        System.debug('Userinfo.getUserId()---> '+Userinfo.getUserId());
        List<FSM_permissionsetgroupassign.PermissionSetGroup> data = new List<FSM_permissionsetgroupassign.PermissionSetGroup>();
        data.add(permissionSetGroupData1);
        FSM_permissionsetgroupassign.invokeManagePermissionSetGroup(data);
        Test.stopTest();
        
    }
    @IsTest
    static void testMethod2()
    {
        PermissionSetGroup psg = [select Id, Status from PermissionSetGroup where DeveloperName='FSM_AppointmentAssistantGroup'];
        FSM_permissionsetgroupassign.PermissionSetGroup permissionSetGroupData1 = new FSM_permissionsetgroupassign.PermissionSetGroup();
        permissionSetGroupData1.userId = Userinfo.getUserId();
     	permissionSetGroupData1.permissionSetGroupId = psg.Id;
        permissionSetGroupData1.assignPsg = false;
        permissionSetGroupData1.removePsg = true;
        Test.startTest();
        List<FSM_permissionsetgroupassign.PermissionSetGroup> data = new List<FSM_permissionsetgroupassign.PermissionSetGroup>();
        data.add(permissionSetGroupData1);
        FSM_permissionsetgroupassign.invokeManagePermissionSetGroup(data);
        Test.stopTest();      
    }

}
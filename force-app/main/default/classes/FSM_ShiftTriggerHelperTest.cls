/********************************************************************************************************
@Author      : Subir Maji
@description : This class is created to cover FSM_ShiftTriggerHelper, FSM_ShiftTriggerHandler, FSM_ShiftTrigger.
@description : Created as part of user story #SFI-2314
@Test Class  : FSM_ShiftTriggerHelperTest
@Date        : 26-June-2024
********************************************************************************************************/
@isTest(SeeAllData = False)
public class FSM_ShiftTriggerHelperTest {
    /********************************************************************************************************
    @Author      : Subir Maji
    @description This method is used to create test data setup.
    *********************************************************************************************************/
    @testsetup 
    static void makeData(){
        // Create Admin user for RunAs purposes to create users and assign permission sets
        Id adminProfileId = [select Id from Profile where Name = 'System Administrator'].Id;
        User adminUser = new FSM_TestDataFactory.CretaeUserCustom('admUsr12','johndoe@exampleAdmin.com', 'johndoe2', adminProfileId).create();
        PermissionSet psSysadmin = [select Id from PermissionSet where Name ='FSM_SystemAdminPermissions'];
        insert new PermissionSetAssignment(PermissionSetId = psSysadmin.Id,AssigneeId = adminUser.ID);
        // Add FSL Admin Permissions if not already to running user (assuming admin)
        System.runAs(adminUser){
            // Lookup the Field Service Admin Permissions permission set
            PermissionSet psSFSAdmin = [select Id from PermissionSet where Name ='FSL_Admin_Permissions'];
                        
            // Associate it to the current user
            try {
                insert new PermissionSetAssignment(
                    PermissionSetId = psSFSAdmin.Id,
                    AssigneeId = UserInfo.getUserId()
                );
            } catch (Exception e) {
                // Perm set already assigned, continue
            }
            
            //Create Scheduling Policy
            FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName('Test Policy').create();
            
            //Create Operating Hours
            List<OperatingHours> listOp = new List<OperatingHours>();
            OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setTimeZone(UserInfo.getTimeZone().getID()).setName('AM/Pm Operating Hours').setSlotType('AMPM').setBusinessUnit('Developer Services').returnWithoutCreate();
            listOp.add(op);
            op = new FSM_TestDataFactory.OperatingHoursCreator().setTimeZone(UserInfo.getTimeZone().getID()).setName('2 hours Operating Hours').setSlotType('2HRS').setBusinessUnit('Developer Services').returnWithoutCreate();
            listOp.add(op);
            insert listOp;
            
            //Create Timeslots
            List<TimeSlot> listTimeSlots = new List<TimeSlot>();
            TimeSlot ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Monday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(11, 2, 3, 4)).setOperatingHoursId(listOp[0].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Tuesday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(13, 2, 3, 4)).setOperatingHoursId(listOp[0].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Wednesday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(14, 2, 3, 4)).setOperatingHoursId(listOp[0].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Thursday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(15, 2, 3, 4)).setOperatingHoursId(listOp[1].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            ts = new FSM_TestDataFactory.TimeSlotCreator().setDayOfWeek('Friday').setStartTime(Time.newInstance(1, 10, 30, 4)).setEndTime(Time.newInstance(16, 2, 3, 4)).setOperatingHoursId(listOp[1].Id).returnWithoutCreate();
            listTimeSlots.add(ts);
            
            insert listTimeSlots; 
            
            //Create Service Territory
            ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('Testing Territory').setIsActive(true).setExtenalId('888999').setOpreratingHours2HourSlot(listOp[1].Id).setOpreratingHours(listOp[0].Id).setSchedulingPolicy(schedulingPolicy.Id).create();
            
            // Create user for a field technician resource with the right permission sets
            Id techProfileId = [select Id from Profile where Name = 'FSM Standard Desktop User'].Id;
            User tech = new FSM_TestDataFactory.CretaeUserCustom('techUsr1','johndoe@exampleTech.com','johndoe1', techProfileId).create();
            User tech1 = new FSM_TestDataFactory.CretaeUserCustom('techUsr2','johndoe@exampleTech2.com','johndo23', techProfileId).create();
            
            List<PermissionSet> sfsPermSets = [select Id from PermissionSet where Name = 'FSL_Resource_Permissions' OR Name ='FSL_Resource_License'];
            
            List<PermissionSetAssignment> permSetAssigns = new List<PermissionSetAssignment>();
            for (PermissionSet sfsPermSet : sfsPermSets){
                permSetAssigns.Add(
                    new PermissionSetAssignment(
                        PermissionSetId = sfsPermSet.Id,
                        AssigneeId = tech.Id
                    )
                );
                permSetAssigns.Add(
                    new PermissionSetAssignment(
                        PermissionSetId = sfsPermSet.Id,
                        AssigneeId = tech1.Id
                    )
                );
            }
            insert permSetAssigns;
            
            //Service Resource Creation
            ServiceResource serRes = new FSM_TestDataFactory.ServiceResourceCreator().setName('Testing Resource').setIsActive(true).setRelatedRecordId(tech.Id).setExternalId('Tech1324').create();
            //Service Resource Creation
            ServiceResource serRes1 = new FSM_TestDataFactory.ServiceResourceCreator().setName('Testing Resource1').setIsActive(true).setRelatedRecordId(tech1.Id).setExternalId('Tech1325').create();
            
            //Create STM
            DateTime startT = Datetime.newInstance(2024, 06, 01, 9, 0, 0);
            new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(serRes.Id).setServiceTerritory(st.Id).setTerritoryType('P')
                .setStartDate(startT).setCountry('India').setPostalCode('713335').create();
            new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(serRes1.Id).setServiceTerritory(st.Id).setTerritoryType('P')
                .setStartDate(startT).setCountry('India').setPostalCode('713335').create();
        }    
    }

    /******************************************************************************************************
    @Author       : Subir Maji
    @description   This test method verifies the successful creation of Shift and Timesheet
    ******************************************************************************************************/
    @isTest
    static void testCreateUpdateShiftSuccess(){
		List<ServiceResource> allRes = [Select id From ServiceResource];
        DateTime dt = Datetime.newInstance(2024, 06, 01, 9, 0, 0);
        List<Shift> allSh = new List<Shift>();
        List<Shift> allShUpdate = new List<Shift>();
        Shift sh;
        DateTime startT = Datetime.newInstance(2024, 06, 01, 9, 0, 0);
        DateTime endT = Datetime.newInstance(2024, 06, 01, 18, 0, 0);
        
        Test.startTest();
        	if(allRes != null){
                for(ServiceResource servres : allRes){
                    startT = Datetime.newInstance(2024, 06, 01, 9, 0, 0);
                    endT = Datetime.newInstance(2024, 06, 01, 18, 0, 0);
                    for(Integer i = 0; i<120; i++){
                        sh = new FSM_TestDataFactory.ShiftCreator().setStatus('Confirmed').setStartTime(startT).setEndTime(endT).
                            setTimeSlotType('Normal').setServiceResourceId(servres.ID).returnWithoutCreate();
                        allSh.add(sh);
                        startT = startT.addDays(1);
                        endT = endT.addDays(1);
                    }
                }
                Insert allSh;
                
                Shift shUp = allSh[20];
                shUp.StartTime = shUp.StartTime.addDays(200);
                shUp.EndTime = shUp.EndTime.addDays(200);
                allShUpdate.add(shUp);
                shUp = allSh[21];
                shUp.ServiceResourceId = allRes[1].ID;
                allShUpdate.add(shUp);
                shUp = allSh[121];
                shUp.StartTime = shUp.StartTime.addDays(10);
                shUp.EndTime = shUp.EndTime.addDays(10);
                allShUpdate.add(shUp);
                Update allShUpdate;
            }
        Test.stopTest();
        List<TimeSheet> allTimeSheet = [Select ID from TimeSheet];
        // Assert All Timesheet record created.
        System.AssertEquals(allTimeSheet.size(), 241, 'All TimeSheet created Successfully'); 
    }
}
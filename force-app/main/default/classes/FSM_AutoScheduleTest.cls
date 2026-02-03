@isTest
public class FSM_AutoScheduleTest {
    @TestSetup
    static void dataSetup() {
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('Base Calendar').setSlotType(FSM_Constants.DURATION).setBusinessUnit('Waste Non Infra').setTimeZone('Europe/London').create();
        FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName('Test Policy').create();
        ServiceTerritory se = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('5216WW1 Wolverhampton').setIsActive(true).setExtenalId('888999').setOpreratingHours(op.Id).setSchedulingPolicy(schedulingPolicy.Id).create();
        
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setServiceTerritory(se.Id).setBusinessUnit('Developer Services').create();
        ServiceAppointment sa1 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New')
            .setEarliestStartTime(DateTime.Now().AddDays(-35)).setDueDate(DateTime.Now().AddDays(-25)).create();
    }  
    @isTest
    static void testFSMAutoScheduling() {
        List<ServiceAppointment> saList = [SELECT id,FSL__Scheduling_Policy_Used__c FROM ServiceAppointment LIMIT 1];
        List<FSL__Scheduling_Policy__c> spList = [SELECT id FROM FSL__Scheduling_Policy__c LIMIT 1];
        Test.startTest();
        FSM_AutoScheduleding__e autoSchedule = new FSM_AutoScheduleding__e();
        autoSchedule.FSM_ServiceAppointmentId__c = saList[0].Id;
        autoSchedule.FSM_SchedulingPolicyId__c = spList[0].Id;
        Database.SaveResult sr = EventBus.publish(autoSchedule);
        saList[0].FSL__Scheduling_Policy_Used__c = spList[0].Id;
        Test.stopTest();
        List<ServiceAppointment> updatedSaList = [SELECT id, FSL__Auto_Schedule__c, FSL__Scheduling_Policy_Used__c
                                                  FROM ServiceAppointment LIMIT 1];
        system.assertEquals(saList[0].FSL__Scheduling_Policy_Used__c, spList[0].Id, 'Auto-schedule Successful');
    }
    
    
}
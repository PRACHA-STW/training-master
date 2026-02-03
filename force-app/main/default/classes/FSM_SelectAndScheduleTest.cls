/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class is used to test Select & Schedule - Jobs on same asset (non-infra) 
@description : Created as part of user story #SFS-5428
@Main Class  : FSM_SelectAndSchedule 
@Date        : 27-May-2024
********************************************************************************************************/
@isTest(SeeAllData=false)
private without sharing class FSM_SelectAndScheduleTest {
    /*******************************************************************************************************
@Author      : Brajesh Kumar
@Description : This method is used to create test data setup.
********************************************************************************************************/
    @TestSetup
    static void makeData() {
       // Allowing Status Transition to user
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Dispatched');
        
        // Create a Service Territory
        List<OperatingHours> listOp = new List<OperatingHours>();
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('AM/Pm Operating Hours').setSlotType(FSM_Constants.DURATION).setBusinessUnit('Metering').returnWithoutCreate();
        listOp.add(op);
        op = new FSM_TestDataFactory.OperatingHoursCreator().setName('2 hours Operating Hours').setSlotType('2HRS').setBusinessUnit('Metering').returnWithoutCreate();
        listOp.add(op);
        insert listOp;
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName('Test Policy').create();
        
        ServiceTerritory se = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('6101M01 Meter North East').setIsActive(true).setExtenalId('888999').setOpreratingHours2HourSlot(listOp[1].Id).setOpreratingHours(listOp[0].Id).setSchedulingPolicy(schedulingPolicy.Id).create();
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setBusinessUnit('Metering').setServiceTerritory(se.Id).setFloc('test').setServiceOrderType('ZPM1').create();
        WorkOrder wo1 = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setBusinessUnit('Metering').setServiceTerritory(se.Id).setFloc('test').setServiceOrderType('ZPM1').create();
        WorkOrder wo2 = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setBusinessUnit('Metering').setServiceTerritory(se.Id).setFloc('test').setServiceOrderType('ZPM1').create();
        User newUser = new FSM_TestDataFactory.CretaeUser().create();
        
        ServiceResource sr = new FSM_TestDataFactory.ServiceResourceCreator().setName('Testing Resource').setIsActive(true).setRelatedRecordId(newUser.Id).setExternalId('1234').create();
        ServiceTerritoryMember stm=new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(sr.Id).setServiceTerritory(se.id).setStartDate(DateTime.Now().AddDays(-1)).setTerritoryType('S').create();
        ServiceAppointment sa1 = new FSM_TestDataFactory.ServiceAppointmentCreator().setPostalCode('831013').setParentRecordId(wo.Id).setDurationType('Hours').setDuration(1).setStatus('New').setServiceTerritory(se.id).setServiceResource(sr.Id)
            .setEarliestStartTime(DateTime.Now()).setDueDate(DateTime.Now().AddDays(4)).setLatitude(24).setLongitude(86).create();
        
        ServiceAppointment sa2 = new FSM_TestDataFactory.ServiceAppointmentCreator().setPostalCode('831013').setParentRecordId(wo1.Id).setStatus('New').setDurationType('Minutes').setDuration(30).setServiceTerritory(se.id).setServiceResource(sr.Id)
            .setEarliestStartTime(DateTime.Now()).setDueDate(DateTime.Now().AddDays(4)).setLatitude(24).setLongitude(86).create();
        ServiceAppointment sa3 = new FSM_TestDataFactory.ServiceAppointmentCreator().setPostalCode('831013').setParentRecordId(wo2.Id).setStatus('New').setServiceTerritory(se.id).setServiceResource(sr.Id)
            .setEarliestStartTime(DateTime.Now()).setDueDate(DateTime.Now().AddDays(4)).setLatitude(24).setLongitude(86).create();
        
        
        // Create Service Resource Skill
        Skill skillId = [select Id,DeveloperName from Skill where DeveloperName like 'P%' LIMIT 1];
        //  String skillIds = skillId;
        Skill skillId1 = [SELECT Id FROM Skill where Id !=: skillId.Id AND DeveloperName like 'P%' LIMIT 1];
        //  String skillIds2 = skillId;
        
        // Create a Skill Requirement
        SkillRequirement srq = new SkillRequirement(
            RelatedRecordId = wo.Id,
            SkillId = skillId.Id
        );
        insert srq;
        
        SkillRequirement srq1 = new SkillRequirement(
            RelatedRecordId = wo1.Id,
            SkillId = skillId.Id
        );
        insert srq1;
        
        SkillRequirement srq2 = new SkillRequirement(
            RelatedRecordId = wo2.Id,
            SkillId = skillId1.Id
        );
        insert srq2;
        
        ServiceResourceSkill srs = new ServiceResourceSkill(
            ServiceResourceId = sr.Id,
            SkillId = skillId.Id,
            EffectiveStartDate = Date.today()
        );
        insert srs;
    	
    }
    
    /*******************************************************************************************************
    @Author      : Brajesh Kumar
    @description : This method is used to test Select & Schedule - Jobs on same asset (non-infra)
    ********************************************************************************************************/
    @IsTest
    static void testGetServiceAppointment() {
        ServiceAppointment saList = [SELECT Id FROM ServiceAppointment LIMIT 1];
        String saId = saList.Id;
        Test.startTest();
         User userInfo = [select Id,Profile.Name from User limit 1];
        System.debug('userInfo'+userInfo);
        Skill skillName = [SELECT DeveloperName FROM Skill LIMIT 1];
        System.debug('skillName---->'+skillName);
        List<ServiceAppointment> result = FSM_SelectAndSchedule.getServiceAppointment(saId);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Service Appointment size should be 1');
    }
    
    @IsTest
    static void testSearchSA() {
        ServiceAppointment saList = [SELECT Id FROM ServiceAppointment LIMIT 1];
        String saId = saList.Id;
        List<String> selectedFilters = new List<String>{'postalTrue', 'flocTrue'};
          Test.startTest();
        List<ServiceAppointment> result = FSM_SelectAndSchedule.searchSA(saId, selectedFilters);
        Test.stopTest();

        List<ServiceAppointment> saSched = [Select Id, Status from ServiceAppointment where Id =:saId];
        System.assert(saSched.size() > 0, 'There should be at least one Service Appointment returned');
    }
    
    // Test scheduleAndDispatchSA Duration in Hours
    @IsTest
    static void testScheduleAndDispatchSA() {
         ServiceResource srList = [SELECT Id,RelatedRecordId FROM ServiceResource LIMIT 1 ];
        system.debug('srList---->'+srList);
         User u = [SELECT Id FROM User where id=:srList.RelatedRecordId LIMIT 1 ];
         
       
        ServiceAppointment saList = [SELECT Id FROM ServiceAppointment Where Status = 'New' LIMIT 1];
       
        system.debug('salist---->'+saList);
        String saId = saList.Id;
        String srId = srList.Id; 
        System.debug('saId2'+saId);
              System.debug('srid2'+srId);
         System.runAs(u){
             
        Test.startTest();
        try{
            String saDispatchedStatus = FSM_SelectAndSchedule.scheduleAndDispatchSA(saId,srId);
                        //system.debug('saDispatchedStatus'+saDispatchedStatus);
        }catch(exception e){
            system.debug('exception---->'+e);
        } 	
        Test.stopTest();
              System.debug('saId1'+saId);
              System.debug('srid1'+srId);
        ServiceAppointment saSched = [Select Id, Status from ServiceAppointment where Id =:saId];
        System.assertEquals('Dispatched',saSched.Status, 'Status update Failed' );
    } 
        }
    
    // Test scheduleAndDispatchSA Duration in Minutes
    @IsTest
    static void testSchedAndDispatchDurationMin() {
        ServiceAppointment saList = [SELECT Id,Status FROM ServiceAppointment Where Status = 'New' AND DurationType = 'Minutes' LIMIT 1];
        ServiceResource srList = [SELECT Id,RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u = [SELECT Id FROM User where id=:srList.RelatedRecordId LIMIT 1 ];
        String saId = saList.Id;
        String srId = srList.Id; 
         System.runAs(u){
        Test.startTest();
        try{
            String saDispatchedStatus =  FSM_SelectAndSchedule.scheduleAndDispatchSA(saId,srId);
        }catch(exception e){
            system.debug('exception--->'+e);
        } 	
        Test.stopTest();
       ServiceAppointment saSched = [Select Id, Status from ServiceAppointment where Id =:saId];
        System.assertEquals('Dispatched',saSched.Status, 'Status update Failed' );
         } }
    
}
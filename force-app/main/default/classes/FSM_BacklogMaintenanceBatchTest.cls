/********************************************************************************************************
@Author      : Manish Jagnani and Kaustav Chanda
@description : This class is used to test to perform auto backlog service appointment functionality
@description : Created as part of user story #SFS-3028 & SFS-3043
@description : Updated as part of SFL-347 to move the query logic to Apex 18th March 2025 by Subir Maji
@Main Class  : FSM_BacklogMaintenanceBatch and FSM_BacklogMaintenanceNonInfraScheduleJob scheduled trigger flow 
@Date        : 27-Decemebr-2023
********************************************************************************************************/
@isTest
public class FSM_BacklogMaintenanceBatchTest {
    @TestSetUp
    static void testDataSetUp(){
        //Get RecordType Id *
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_WASTENONINFRA).getRecordTypeId();
        // Create scheduling policy
        FSL__Scheduling_Policy__c testPolicy = new FSL__Scheduling_Policy__c(Name = 'Waste Non Infra Soft Boundaries', FSM_BusinessUnit__c = 'Waste Non Infra');
        insert testPolicy;
        
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('Base Calendar').setSlotType(FSM_Constants.DURATION)
            .setTimeZone('Europe/London').create();
        
        ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('5216WW1 Wolverhampton').setIsActive(true)
            .setOpreratingHours(op.Id).setSchedulingPolicy(testPolicy.Id).setBusinessUnit('Waste Non Infra').create();
        
        WorkOrder wo1 = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setStatus('New').setServiceTerritory(st.Id).setBusinessUnit('Waste Non Infra').
            setServiceOrderType('ZPM1').setPriority('2').create();
        
        WorkOrder wo2 = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setStatus('New').setServiceTerritory(st.Id).setBusinessUnit('Waste Non Infra').
            setServiceOrderType('ZPM1').setPriority('5').create();
        
        WorkOrder wo3 = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setStatus('New').setServiceTerritory(st.Id).setBusinessUnit('Waste Non Infra').
            setServiceOrderType('ZPM1').setPriority('9').create();
        
        WorkOrder wo4 = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setStatus('New').setServiceTerritory(st.Id).setBusinessUnit('Waste Non Infra').
            setServiceOrderType('ZPM2').create();
        
        ServiceAppointment sa1 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo1.Id).setStatus('New').setServiceTerritory(st.id)
            .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now()).create();
        
        ServiceAppointment sa2 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo2.Id).setStatus('New').setServiceTerritory(st.id)
            .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now()).create();
        
        ServiceAppointment sa3 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo3.Id).setStatus('New').setServiceTerritory(st.id)
            .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now()).create();
        
        ServiceAppointment sa4 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo4.Id).setStatus('New').setServiceTerritory(st.id)
            .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now()).create();
        
    }
    @isTest
    static void testScenarioZPM1() {          
        Test.startTest(); 
        	FSM_BacklogMaintenanceBatch  backlockbatch= new FSM_BacklogMaintenanceBatch();
        	Database.executeBatch(backlockbatch); 
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_DueDateApplyCounterZPM1__c,DueDate from  ServiceAppointment limit 1];
        system.assertEquals(1,saexecute.FSM_DueDateApplyCounterZPM1__c,'ZPM1 counter increased');   
    }
    @isTest
    static void testScenarioOneZPM1() {
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounterZPM1__c,FSM_SAPJobPriority__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM1'
                                        AND FSM_SAPJobPriority__c = 2];
        sa.FSM_DueDateApplyCounterZPM1__c = 3;
        update sa;
        
        Test.startTest(); 
        	FSM_BacklogMaintenanceBatch  backlockbatch= new FSM_BacklogMaintenanceBatch();
        	Database.executeBatch(backlockbatch); 
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_Backlog__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(true,saexecute.FSM_Backlog__c,'backlog is true');   
    }
    @isTest
    static void testScenarioTwoZPM1() {
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounterZPM1__c,FSM_SAPJobPriority__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM1'
                                        AND FSM_SAPJobPriority__c = 5];
        sa.FSM_DueDateApplyCounterZPM1__c =2 ;
        update sa;
        
        Test.startTest(); 
        	FSM_BacklogMaintenanceBatch  backlockbatch= new FSM_BacklogMaintenanceBatch();
        	Database.executeBatch(backlockbatch); 
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_Backlog__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(true,saexecute.FSM_Backlog__c,'backlog is true');   
    }
    @isTest
    static void testCriteriaOneZPM2() {          
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounter__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM2'];
        sa.EarliestStartTime = DateTime.Now().AddDays(-29);
        update sa;
        
        Test.startTest(); 
        	FSM_BacklogMaintenanceBatch  backlogbatch= new FSM_BacklogMaintenanceBatch();
        	Database.executeBatch(backlogbatch); 
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_Backlog__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(true,saexecute.FSM_Backlog__c,'backlog is true');
    }
    @isTest
    static void testCriteriaTwoZPM2() {          
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounter__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM2'];
        sa.EarliestStartTime = DateTime.Now().AddDays(-10);
        update sa;
        
        Test.startTest(); 
        	FSM_BacklogMaintenanceBatch  backlogbatch= new FSM_BacklogMaintenanceBatch();
        	Database.executeBatch(backlogbatch); 
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_DueDateApplyCounter__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(1,saexecute.FSM_DueDateApplyCounter__c,'counter increased');  
    }
    @isTest
    static void testCriteriaThreeZPM2() {          
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounter__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM2'];
        sa.EarliestStartTime = DateTime.Now().AddDays(-8);
        update sa;
        
        Test.startTest(); 
        	FSM_BacklogMaintenanceBatch  backlogbatch= new FSM_BacklogMaintenanceBatch();
        	Database.executeBatch(backlogbatch); 
        Test.stopTest();
       
        ServiceAppointment saexecute=[select id ,FSM_DueDateApplyCounter__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(1,saexecute.FSM_DueDateApplyCounter__c,'counter increased');   
    }
    @isTest
    static void testCriteriaFourZPM2() {          
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounter__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM2'];
        sa.EarliestStartTime = DateTime.Now().AddDays(-3);
        update sa;
        
        Test.startTest(); 
        	FSM_BacklogMaintenanceBatch  backlogbatch= new FSM_BacklogMaintenanceBatch();
        	Database.executeBatch(backlogbatch); 
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_DueDateApplyCounter__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(1,saexecute.FSM_DueDateApplyCounter__c,'counter increased');   
    }
    @isTest
    static void testCriteriaFiveZPM2() {          
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounter__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM2'];
        sa.EarliestStartTime = DateTime.Now().AddDays(-4);
        sa.FSM_DueDateApplyCounter__c = 1;
        update sa;
        
        Test.startTest(); 
        	FSM_BacklogMaintenanceBatch  backlogbatch= new FSM_BacklogMaintenanceBatch();
        	Database.executeBatch(backlogbatch); 
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_Backlog__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(true,saexecute.FSM_Backlog__c,'backlog is true');   
    }
    @isTest
    static void testCriteriaSixZPM2() {          
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounter__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM2'];
        sa.EarliestStartTime = DateTime.Now().AddDays(-1);
        update sa;
        
        Test.startTest(); 
            FSM_BacklogMaintenanceBatch  backlogbatch= new FSM_BacklogMaintenanceBatch();
            Database.executeBatch(backlogbatch); 
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_Backlog__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(true,saexecute.FSM_Backlog__c,'backlog is true');   
    }
    @isTest
    static void testFlowInputs(){
        ServiceAppointment sa=[select Id,EarliestStartTime,DueDate,FSM_ServiceOrderType__c,Status,FSM_InternalSLA__c,FSM_HoursUntilDueDate__c,FSM_DueDateApplyCounter__c,FSM_Backlog__c from  ServiceAppointment WHERE FSM_ServiceOrderType__c = 'ZPM2'];
        sa.FSM_DueDateApplyCounter__c = 1;
        sa.EarliestStartTime = DateTime.Now().AddDays(-8);
        update sa;
        
        Test.startTest();
            FSM_BacklogMaintenanceBatch.saListInput();
            FSM_BacklogMaintenanceBatch  backlogbatch= new FSM_BacklogMaintenanceBatch();
            Database.executeBatch(backlogbatch);
        Test.stopTest();
        
        ServiceAppointment saexecute=[select id ,FSM_Backlog__c from  ServiceAppointment WHERE Id = :sa.Id];
        system.assertEquals(true,saexecute.FSM_Backlog__c,'backlog is true');
    }
}
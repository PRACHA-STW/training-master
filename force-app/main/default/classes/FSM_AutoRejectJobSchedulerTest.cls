/********************************************************************************************************
@Author      : Nishant Kumar
@description : This class is used to test auto-reject functionality of service appointment
@description : Created as part of user story #SFS-7456
@Main Class  : FSM_AutoRejectJobScheduler and FSM_AutoRejectJobBatch 
@Date        : 18th-September-2024
********************************************************************************************************/
@isTest
public class FSM_AutoRejectJobSchedulerTest {
    /*******************************************************************************************************
@Author      : Nishant Kumar
@Description : This method is used to create test data setup.
********************************************************************************************************/
    //Created for test data setup
    @testsetup 
    static void makeData(){
        FSL.GlobalAPIS.addStatusTransition('New', 'Rejected');
        List<OperatingHours> listOp = new List<OperatingHours>();
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('AM/Pm Operating Hours').setSlotType(FSM_Constants.DURATION).setBusinessUnit('Waste Non Infra').returnWithoutCreate();
        listOp.add(op);
        op = new FSM_TestDataFactory.OperatingHoursCreator().setName('2 hours Operating Hours').setSlotType('2HRS').setBusinessUnit('Waste Non Infra').returnWithoutCreate();
        listOp.add(op);
        insert listOp;        
        ServiceTerritory se = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('5220WW1S Minworth Shift').setIsActive(true).setExtenalId('888999').setOpreratingHours2HourSlot(listOp[1].Id).setOpreratingHours(listOp[0].Id).create();
        
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_WASTENONINFRA).getRecordTypeId();
        
       // Creat WO order 
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setServiceTerritory(se.Id).setBusinessUnit('Waste Non Infra').setStatus('New').setJobSla(36).setSlaUnitOfMeasure('Hours').create(); 
        
		// Creat SA order 
        ServiceAppointment sa1 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New').setEarliestStartTime(DateTime.Now().AddDays(-12)).setDueDate(DateTime.Now().AddDays(-5)).create();
        ServiceAppointment sa2 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New').setEarliestStartTime(DateTime.Now().AddDays(-12)).setDueDate(DateTime.Now().AddDays(-5)).create();
        ServiceAppointment sa3	= new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New').setIsBundle(true).create();
        new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('New').setIsBundleMember(true).setRelatedBundleId(sa3.id).setEarliestStartTime(DateTime.Now().AddDays(-12)).setDueDate(DateTime.Now().AddDays(-5)).Create();  
    }
    /*******************************************************************************************************
@Author      : Nishant Kumar
@description : This method is used to call the scheduler class to test SA FSM_AutoRejectJobScheduler.
********************************************************************************************************/
     @isTest
    static void testAutoRejectSABatch() {
        Test.startTest();  
        // Schedule the job - without parameter
        FSM_AutoRejectJobScheduler scheduler = new FSM_AutoRejectJobScheduler();
        scheduler.execute(NULL);
        
        // Schedule the job - parameterized
        String jobRunQuery ='SELECT Id FROM ServiceAppointment WHERE Status = \'New\' AND IsBundleMember = TRUE AND FSM_RejectBundle__c = TRUE';
        // Schedule the job 
        FSM_AutoRejectJobScheduler scheduler1 = new FSM_AutoRejectJobScheduler(jobRunQuery);
        String cronExp = '0 0 0 * * ?';
        System.schedule('FSM_AutoRejectJobSchedulerTest', cronExp, scheduler1);          
        Test.stopTest();
      
        // Perform queries to retrieve the updated Service Appointments
        ServiceAppointment updatedSA = [SELECT Id, Status,DueDate,EarliestStartTime,IsBundleMember,FSM_RejectBundle__c FROM ServiceAppointment where Status = 'Rejected' LIMIT 1]; 
        System.assertEquals('Rejected', updatedSA.Status, 'Service Appointment Status should be "Rejected"');
    } 
    
  
    
}
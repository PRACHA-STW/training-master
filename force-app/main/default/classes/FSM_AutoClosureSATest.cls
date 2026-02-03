/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class is used to test auto-Complete functionality of service appointment
@description : Created as part of user story #SFS-3024
@Main Class  : FSM_AutoClosureSAScheduler and FSM_AutoClosureSABatch 
@Date        : 12th-December-2023
********************************************************************************************************/
@isTest
private class FSM_AutoClosureSATest {
    /*******************************************************************************************************
@Author      : Brajesh Kumar
@Description : This method is used to create test data setup.
********************************************************************************************************/
    //Created for test data setup
    @testsetup 
    static void makeData(){
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Dispatched');
        FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Completed');
        FSL.GlobalAPIS.addStatusTransition('Dispatched', 'Completed');
        List<OperatingHours> listOp = new List<OperatingHours>();
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('AM/Pm Operating Hours').setSlotType(FSM_Constants.DURATION).setBusinessUnit('Metering').returnWithoutCreate();
        listOp.add(op);
        op = new FSM_TestDataFactory.OperatingHoursCreator().setName('2 hours Operating Hours').setSlotType('2HRS').setBusinessUnit('Metering').returnWithoutCreate();
        listOp.add(op);
        insert listOp;
        
        //Create Account
        Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
        //Create Contact
        Contact con = new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
            .setEmail('no-reply@defaultemail.com').create();
        
        FSL__Scheduling_Policy__c schedulingPolicy = new FSM_TestDataFactory.SchedulingPolicyCreator().setName('Test Policy').create();
        
        ServiceTerritory se = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('6101M01 Meter North East').setIsActive(true).setExtenalId('888999').setOpreratingHours2HourSlot(listOp[1].Id).setOpreratingHours(listOp[0].Id).setSchedulingPolicy(schedulingPolicy.Id).create();
        ServiceTerritory se1 = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('5216WW1 Wolverhampton').setIsActive(true).setExtenalId('888998').setOpreratingHours2HourSlot(listOp[1].Id).setOpreratingHours(listOp[0].Id).setSchedulingPolicy(schedulingPolicy.Id).create();
        
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
        // List to store WorkOrder and ServiceAppointment records
        List<WorkOrder> workOrders = new List<WorkOrder>();
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();
        for (Integer i = 1; i <= 100; i++) {
             // Create a bulk WorkOrder record
             WorkOrder wo2 = new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Developer Services').setRecordType(recTypeId).setServiceTerritory(se.Id).returnWithoutCreate();
            // Add the WorkOrder to the list
            workOrders.add(wo2);
        }
        // Bulk insert WorkOrders
        if (!workOrders.isEmpty()) {
            insert workOrders;
        }
        // Loop through inserted WorkOrders and create ServiceAppointment records
        for (Integer i = 0; i < workOrders.size(); i++) {
            // Create a new ServiceAppointment record linked to the WorkOrder
             ServiceAppointment sa = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(workOrders[i].Id).setStatus('New').setServiceTerritory(se.id)
            .setEarliestStartTime(DateTime.Now().AddDays(-35)).setDueDate(DateTime.Now().AddDays(-25)).setLatitude(24).setLongitude(86).returnWithoutCreate();
            serviceAppointments.add(sa);
        }
        // Bulk insert ServiceAppointments
        if (!serviceAppointments.isEmpty()) {
            insert serviceAppointments;
        }
        
        User newUser = new FSM_TestDataFactory.CretaeUser().create();
        
        ServiceResource sr = new FSM_TestDataFactory.ServiceResourceCreator().setName('Testing Resource').setIsActive(true).setRelatedRecordId(newUser.Id).setExternalId('1234').create();
        
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
        
        // Logic to get Schedule start date + 30 days
        Date currentDate = Date.today();
        Datetime schedStartDate = Datetime.newInstance(currentDate.addDays(-31), Time.newInstance(0, 0, 0, 0));
        Datetime schedEndDate = Datetime.newInstance(currentDate.addDays(-31), Time.newInstance(0, 0, 0, 0));
        schedEndDate = schedStartDate.addHours(1);
        
        // Update Service Appointment records to set Status to 'Scheduled'
        for (ServiceAppointment saRecord : serviceAppointments) {
            saRecord.Status = 'Scheduled';
            saRecord.SchedStartTime = schedStartDate;
        	saRecord.SchedEndTime = schedEndDate;
        }
        // Update the Service Appointment records
        update serviceAppointments;     
    }
    /*******************************************************************************************************
    @Author      : Brajesh Kumar
    @description : This method is used to call the scheduler class to test SA FSM_AutoClosureSAScheduler.
    ********************************************************************************************************/
    @isTest
    static void testDispatchSABatch() {
        
        Test.startTest();  
        // Schedule the job 
        FSM_AutoClosureSAScheduler scheduler = new FSM_AutoClosureSAScheduler();
        scheduler.execute(NULL);
        String cronExp = '0 0 0 * * ?';
        Test.stopTest();
        List<ServiceAppointment> totalSA = [SELECT Id, Status FROM ServiceAppointment];
        // Perform queries to retrieve the updated Service Appointments
        ServiceAppointment updatedSA = [SELECT Id, Status FROM ServiceAppointment LIMIT 1];
        
        // Assert the expected results to verify that the Service Appointments are updated with the status 'Completed'
        System.assertEquals('Completed', updatedSA.Status, 'Service Appointment Status should be "Completed"');
    }    
    
    @isTest
    static void testDispatchSABatchNegative() {
        // Create a test WorkOrder data
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        WorkOrder wo1 = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setBusinessUnit('Developer Services').create();
        
        ServiceAppointment sa2 = new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo1.Id).setStatus('New')
            .setEarliestStartTime(DateTime.Now().AddDays(-4)).setDueDate(DateTime.Now().AddDays(-2)).create();
        
        Test.startTest();  
        // Schedule the job
        FSM_AutoClosureSAScheduler scheduler = new FSM_AutoClosureSAScheduler();
        scheduler.execute(NULL);
        String cronExp = '0 0 0 * * ?';
        System.schedule('FSM_AutoClosureSASchedulerTest', cronExp, scheduler);          
        Test.stopTest();
        
        // Perform queries to retrieve the updated Service Appointments
        ServiceAppointment updatedSA1 = [SELECT Id, Status FROM ServiceAppointment Where Status = 'New' LIMIT 1 ];
        
        // Assert the expected results to verify that the Service Appointments with the status 'New'
        System.assertEquals('New', updatedSA1.Status, 'Service Appointment Status should be "New"');
    }    
    
}
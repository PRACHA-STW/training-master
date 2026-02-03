/********************************************************************************************************
@Author      : Aishwarya Bhosale
@Description : This class is created to cover FSM_ServiceReportTriggerHelper, FSM_ServiceReportTriggerHandler,FSM_ServiceReportTrigger
@description : Created as part of user story #SFS-5350
@Date        : 21-May-2024
********************************************************************************************************/
@isTest
public class FSM_ServiceReportTriggerTest {
    
    //Created for test data setup
    @testsetup 
    static void makeData(){
		// Create Admin user for RunAs purposes to create users and assign permission sets
        Id adminProfileId = [select Id from Profile where Name = 'System Administrator'].Id;
    	User adminUser = new FSM_TestDataFactory.CretaeUserCustom('admUsr12','johndoe@exampleAdmin.com', 'johndoe2', adminProfileId).create();
        
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
            OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setTimeZone(UserInfo.getTimeZone().getID()).setName('AM/Pm Operating Hours').setSlotType(FSM_Constants.DURATION).setBusinessUnit('Developer Services').returnWithoutCreate();
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
            
            List<PermissionSet> sfsPermSets = [select Id from PermissionSet where Name = 'FSL_Resource_Permissions' OR Name ='FSL_Resource_License'];
            
            List<PermissionSetAssignment> permSetAssigns = new List<PermissionSetAssignment>();
            for (PermissionSet sfsPermSet : sfsPermSets){
                permSetAssigns.Add(
                    new PermissionSetAssignment(
                        PermissionSetId = sfsPermSet.Id,
                        AssigneeId = tech.Id
                    )
                );
            }
            insert permSetAssigns;
            
            //Service Resource Creation
            ServiceResource serRes = new FSM_TestDataFactory.ServiceResourceCreator().setName('Testing Resource').setIsActive(true).setRelatedRecordId(tech.Id).setExternalId('Tech1324').create();
            
            //Create STM
            new FSM_TestDataFactory.ServiceTerritoryMemberCreator().setServiceResource(serRes.Id).setServiceTerritory(st.Id).setTerritoryType('S')
                .setStartDate(System.now().addDays(-3)).create(); //Updated as a part of SFL-141
            
            //Get WO record type
            Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
            // Create a test WorkOrder data
            WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Water Infra').setRecordType(recTypeId).create();
            
            //Create Service Appointment
             new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('NEW')
                .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now().AddDays(18)).create();
           
        }         
    }
    
    //Test Positive Task creation
    @isTest
    static void testCreateTask(){
        ServiceAppointment servApp = [Select ID,FSM_ProformaAction__c, FSSK__FSK_Assigned_Service_Resource__c from ServiceAppointment Limit 1];
        ServiceResource servRes = [Select ID from ServiceResource Limit 1];
        ServiceReport servReport;
        
        Test.startTest();
        servApp.FSM_ProformaAction__c = 'Generate and Send';
        servApp.FSSK__FSK_Assigned_Service_Resource__c = servRes.ID;
        Update ServApp;
        
        ContentVersion cv1 = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('Penguins.pdf').setTitle('Penguins').setVersionData(Blob.valueOf( 'Testing content version')).create();
        Blob documentbody = cv1.VersionData;
        
        List<FSM_ServiceReportTemplates__mdt> srtemplates=[Select Id,FSM_TemplateName__c,FSM_TemplateId__c from FSM_ServiceReportTemplates__mdt where FSM_TemplateName__c IN ('Emergency Land Entry Notice','Aquapea')];     
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        servReport = new FSM_TestDataFactory.ServiceReportCreator().setdocumentbody(documentbody).setcontenttype('application/pdf').setdocumentname('Aquapea').setparentid(servApp.Id ).settemplate(srtemplates[0].FSM_TemplateId__c).create();   
       	Test.stopTest(); 
        //To Cover Handaler class
        servReport.Status='Failed';
		update servReport;   
        
        Task tsk = [Select ID, WhatId from Task Limit 1];
        System.Assert(tsk.WhatId == ServApp.ID, 'Task record created successfully');
    }
    
    //Test Failure Task creation
    @isTest
    static void testCreateTaskFailure(){
        ServiceAppointment servApp = [Select ID,FSM_ProformaAction__c, FSSK__FSK_Assigned_Service_Resource__c,FSM_SAPWorkorderNumber__c from ServiceAppointment Limit 1];
        ServiceReport servReport;
        
        Test.startTest();
        servApp.FSM_ProformaAction__c = 'Generate and Send';
        Update ServApp;
        
        ContentVersion cv1 = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('Penguins.pdf').setTitle('Penguins').setVersionData(Blob.valueOf( 'Testing content version')).create();
        Blob documentbody = cv1.VersionData;
        
        List<FSM_ServiceReportTemplates__mdt> srtemplates=[Select Id,FSM_TemplateName__c,FSM_TemplateId__c from FSM_ServiceReportTemplates__mdt where FSM_TemplateName__c IN ('Emergency Land Entry Notice','Aquapea')];     
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        servReport = new FSM_TestDataFactory.ServiceReportCreator().setdocumentbody(documentbody).setcontenttype('application/pdf').setdocumentname('Aquapea').setparentid(servApp.Id ).settemplate(srtemplates[0].FSM_TemplateId__c).create();   
       	Test.stopTest(); 
        
        FSM_ErrorLog__c errorLog = [Select ID from FSM_ErrorLog__c Limit 1];
        System.Assert(errorLog != null, 'Error Log record created successfully');
    }
 }
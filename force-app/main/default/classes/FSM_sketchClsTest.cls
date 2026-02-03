/*@author: Kaustav
@description: this is test class for FSM_SketchCls
@Date: 12/07/23
@last modified by: Aishwarya Bhosale
@last modified on:28-05-2024

*/
@isTest(SeeAllData=false)
public class FSM_sketchClsTest {
    
    @isTest
    public static void testSaveCanvas() {
        // Test data
        String base64 = 'sampleBase64Data';
        String filename = 'sampleFilename';
        
        User newUser = new FSM_TestDataFactory.CretaeUser().create();
        newUser.ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        update newUser;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = newUser.Id;
        psa.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name='FSM_SystemAdminPermissions' LIMIT 1].Id;
        system.debug('------- psa.AssigneeId :'+psa.AssigneeId);
        system.debug('------- psa.PermissionSetId :'+psa.PermissionSetId);
        insert psa;
        System.debug('newUser----> '+newUser.username);
        System.runAs(newUser){
            //create Case
            new FSM_TestDataFactory.CaseCreator().setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').create(); 
            //insert operating hours
            List<OperatingHours> listOp = new List<OperatingHours>();
            OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('AM/Pm Operating Hours').setBusinessUnit('Developer Services').returnWithoutCreate(); //.setSlotType('AM')
            listOp.add(op);
            op = new FSM_TestDataFactory.OperatingHoursCreator().setName('2 hours Operating Hours').setBusinessUnit('Developer Services').returnWithoutCreate(); //.setSlotType('2 hour')
            listOp.add(op);
            insert listOp;
            //Create Account
            Account acc = new FSM_TestDataFactory.AccountCreator().setName('Test Account').create();
            //Create Contact
            new FSM_TestDataFactory.ContactCreator().setFirstName('FSM').setLastName('Salesforce Default Contact For Email').setAccount(acc.ID)
                .setEmail('no-reply@defaultemail.com').create();
            //Create Service Territory
            ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('7203D02 Small Developer West Gangs').setBusinessUnit('Developer Services').setIsActive(true).setExtenalId('888999')
                .setOpreratingHours(listOp[0].Id).create();
            //Create Case
            Case testCase = new FSM_TestDataFactory.CaseCreator().setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').create();        
            
            Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
                .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
            
            // Create a test WorkOrder data
            WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setServiceTerritory(st.Id).
                setEsating(40.0).setNorthing(50.4).standardTextKey('83773848743').setSuitability('E').setMinimumCrewSize(2).setCaseId(testCase.ID).setBusinessUnit('Developer Services').create();
            Double latitudeValue = 52.41;
            Double longitudeValue = -1.50;
            
            ID saRecordTypeID= Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName()
                .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
            
            //Create ServiceAppointment and assign it to workorder
            ServiceAppointment sa=new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('NEW').setRecordType(saRecordTypeID)
                .setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                .setLongitude(longitudeValue).setServiceTerritory(st.Id).create();
            
            Id dcfrectypeid= Schema.SObjectType.FSM_DataCaptureFormInfra__c.getRecordTypeInfosByDeveloperName()
                .get(FSM_Constants.RECORDTYPE_INFRAFOLLOWONWORKREQUEST).getRecordTypeId();
            //create infra data capture1 form record
            FSM_DataCaptureFormInfra__c dcfRecord=new FSM_TestDataFactory.DataCaptureFormInfraCreator().setWorkorder(wo.Id).setRecordTypeId(dcfrectypeid).create();
            WorkPlan wp=new FSM_TestDataFactory.WorkPlanCreator().setName('Developer Services').setparent(wo.Id).setWorkorder(wo.Id).create();
            
            system.debug('workplan'+wp.Id+'wp.ParentRecordId'+wp.ParentRecordId);
            WorkStep ws=new FSM_TestDataFactory.WorkStepCreator().setActionDef('WorkStep.Follow_on_work_request').setWorkPlan(wp.Id).setStatus('New').setName('Infra Follow on work request').create();
            
            
            FSM_DataCaptureFormInfra__c dcfinfra=[SELECT Id,FSM_WorkOrder__c,FSM_WorkStep__c from FSM_DataCaptureFormInfra__c where id=:dcfRecord.Id];
            dcfinfra.FSM_Location__c = 'Public Highway';
            dcfinfra.FSM_Asset__c= 'D 8';
            dcfinfra.FSM_WorkStep__c=ws.Id;
            update dcfinfra;
            system.debug('workstep'+dcfinfra.FSM_WorkStep__c);
            // Call the method to be tested
            Test.startTest();
            //ApexPages.StandardController con = new ApexPages.StandardController(dcfRecord);
 
            //site Icons
            List<fileObj> objList = new List<fileObj>();
            
            fileObj obj1 = new fileObj();
            obj1.data = 'test,data';
            obj1.metadata = new Map<String, Object> { 'ext' => 'png', 'fileName' => 'SiteIcons'};
                objList.add(obj1);
            
            //Photo List
            List<fileObj> photoObjList = new List<fileObj>();
            
            fileObj pObj1 = new fileObj();
            pObj1.data = 'test,data';
            pObj1.metadata = new Map<String, Object> { 'ext' => 'png', 'fileName' => 'PhotoIcons'};
                photoObjList.add(pObj1);
            
            List<fileObj> bannerObjList = new List<fileObj>();
            fileObj bObj1 = new fileObj();
            bObj1.data = 'test,data';
            bObj1.metadata = new Map<String, Object> { 'ext' => 'png', 'fileName' => 'Banner'};
                bannerObjList.add(bObj1);
            
            // String result = FSM_sketchCls.saveCanvas(base64, filename, recId, JSON.serialize(photoObjList), JSON.serialize(objList),JSON.serialize(bannerObjList), dcfRecordId);
            FSM_sketchCls.pdfCreation(sa.Id,dcfinfra.Id);
            // System.debug('result== '+result);
            dcfinfra.FSM_Location__c = 'Private Land';
            dcfinfra.FSM_Asset__c= 'D 28';
            update dcfinfra;
            FSM_sketchCls.pdfCreation(sa.Id,dcfinfra.Id);
            Test.stopTest();
            
        }
    }
    /** Communities are no longer in use, so commenting out the codes related to it.
    @isTest
    public static void testcommunityuser() {
        User item = new User();
        item.FirstName='Test';
        item.LastName = 'User';
        item.Email = 'johndoe@example.com';
        item.Username = 'johndoeTestuser@gmail.com';
        item.Alias = 'jdoe';
        item.CommunityNickname = 'johndoe';
        item.TimeZoneSidKey = 'America/Los_Angeles';
        item.LanguageLocaleKey = 'en_US';
        item.EmailEncodingKey = 'UTF-8';
        item.LocaleSidKey = 'en_US';
        item.IsActive = true;
        item.UserRoleId=[Select id from UserRole where DeveloperName='Director'].Id;
        item.isActive=true;
        item.ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        Insert item;
        
        User newUser2=new User();
        System.runAs(item){
            Account acc=new FSM_TestDataFactory.AccountCreator().setName('test acc1').create();
            Contact con=new FSM_TestDataFactory.ContactCreator().setFirstName('test1').setLastName('testsurname1').setAccount(acc.id).setEmail('no-reply@defaultemail.com').create();
            newUser2.FirstName='Test';
            newUser2.LastName = 'User';
            newUser2.Email = 'johndoe1@example.com';
            newUser2.Username = 'johndoe1Testuser@gmail.com';
            newUser2.Alias = 'jdoe1';
            newUser2.CommunityNickname = 'johndoe1';
            newUser2.TimeZoneSidKey = 'America/Los_Angeles';
            newUser2.LanguageLocaleKey = 'en_US';
            newUser2.EmailEncodingKey = 'UTF-8';
            newUser2.LocaleSidKey = 'en_US';
            newUser2.IsActive = true;
            newUser2.ProfileId = [SELECT Id FROM Profile where Name LIKE 'Customer Community%' OR Name LIKE '%Customer Community' OR Name LIKE '%Customer Community%' LIMIT 1].Id;
            newUser2.ContactId=[Select id from Contact where LastName='testsurname1'Limit 1].id;
            insert newUser2;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = newUser2.Id;
            psa.PermissionSetGroupId = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName='FSM_FieldforceSitemate' LIMIT 1].Id;
            insert psa;
        } 
      
        System.runAs(newUser2){
            //create Case
            new FSM_TestDataFactory.CaseCreator().setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').create(); 
            //insert operating hours
            List<OperatingHours> listOp = new List<OperatingHours>();
            OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('AM/Pm Operating Hours').setBusinessUnit('Developer Services').returnWithoutCreate(); //.setSlotType('AM')
            listOp.add(op);
            op = new FSM_TestDataFactory.OperatingHoursCreator().setName('2 hours Operating Hours').setBusinessUnit('Developer Services').returnWithoutCreate(); //setSlotType('2 hour').
            listOp.add(op);
            insert listOp;
            
            
            
            //Create Service Territory
            ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('7203D02 Small Developer West Gangs').setBusinessUnit('Developer Services').setIsActive(true).setExtenalId('888999')
                .setOpreratingHours(listOp[0].Id).create();
            
            
            Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
                .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
            
            // Create a test WorkOrder data
            WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setServiceTerritory(st.Id).
                setEsating(40.0).setNorthing(50.4).standardTextKey('83773848743').setSuitability('E').setMinimumCrewSize(2).setBusinessUnit('Developer Services').create();
            Double latitudeValue = 52.41;
            Double longitudeValue = -1.50;
            
            ID saRecordTypeID= Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName()
                .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
            
            //Create ServiceAppointment and assign it to workorder
            ServiceAppointment sa=new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('NEW').setRecordType(saRecordTypeID)
                .setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
                .setLongitude(longitudeValue).setServiceTerritory(st.Id).create();
            
            Id dcfrectypeid= Schema.SObjectType.FSM_DataCaptureFormInfra__c.getRecordTypeInfosByDeveloperName()
                .get(FSM_Constants.RECORDTYPE_INFRAFOLLOWONWORKREQUEST).getRecordTypeId();
            //create infra data capture1 form record
            FSM_DataCaptureFormInfra__c dcfRecord=new FSM_TestDataFactory.DataCaptureFormInfraCreator().setWorkorder(wo.Id).setRecordTypeId(dcfrectypeid).create();
            WorkPlan wp=new FSM_TestDataFactory.WorkPlanCreator().setName('Developer Services').setparent(wo.Id).setWorkorder(wo.Id).create();
            
            system.debug('workplan'+wp.Id+'wp.ParentRecordId'+wp.ParentRecordId);
            WorkStep ws=new FSM_TestDataFactory.WorkStepCreator().setActionDef('WorkStep.Follow_on_work_request').setWorkPlan(wp.Id).setStatus('New').setName('Infra Follow on work request').create();
            
            
            FSM_DataCaptureFormInfra__c dcfinfra=[SELECT Id,FSM_WorkOrder__c,FSM_WorkStep__c from FSM_DataCaptureFormInfra__c where id=:dcfRecord.Id];
            
            dcfinfra.FSM_WorkStep__c=ws.Id;
            dcfinfra.FSM_Location__c = 'Private Land';
            dcfinfra.FSM_Asset__c= 'D 28';
            update dcfinfra;
            system.debug('workstep'+dcfinfra.FSM_WorkStep__c);
            FSM_sketchCls.pdfCreation(sa.Id,dcfinfra.Id);
            // Call the method to be tested
            Test.startTest();
            //ApexPages.StandardController con = new ApexPages.StandardController(dcfRecord);
            
            //site Icons
            List<fileObj> objList = new List<fileObj>();
            
            fileObj obj1 = new fileObj();
            obj1.data = 'test,data';
            obj1.metadata = new Map<String, Object> { 'ext' => 'png', 'fileName' => 'SiteIcons'};
                objList.add(obj1);
            
            //Photo List
            List<fileObj> photoObjList = new List<fileObj>();
            
            fileObj pObj1 = new fileObj();
            pObj1.data = 'test,data';
            pObj1.metadata = new Map<String, Object> { 'ext' => 'png', 'fileName' => 'PhotoIcons'};
                photoObjList.add(pObj1);
            
            List<fileObj> bannerObjList = new List<fileObj>();
            fileObj bObj1 = new fileObj();
            bObj1.data = 'test,data';
            bObj1.metadata = new Map<String, Object> { 'ext' => 'png', 'fileName' => 'Banner'};
                bannerObjList.add(bObj1);
            
            // String result = FSM_sketchCls.saveCanvas(base64, filename, recId, JSON.serialize(photoObjList), JSON.serialize(objList),JSON.serialize(bannerObjList), dcfRecordId);
            FSM_sketchCls.pdfCreation(sa.Id,dcfinfra.Id);
            // System.debug('result== '+result);
            FSM_DataCaptureFormInfra__c dcfinfra1=[SELECT Id,FSM_WorkOrder__c,FSM_WorkStep__c from FSM_DataCaptureFormInfra__c where id=:dcfRecord.Id];
            
            dcfinfra1.FSM_WorkStep__c=ws.Id;
            dcfinfra1.FSM_Location__c = 'Public Highway';
            dcfinfra1.FSM_Asset__c= 'D 8';
            update dcfinfra1;
            FSM_sketchCls.pdfCreation(sa.Id,dcfinfra1.Id);
            Test.stopTest();
            
        }
  
    }
	**/
    
    public class fileObj {
        public String data;
        public Map<String, Object> metadata;
    }
    
}
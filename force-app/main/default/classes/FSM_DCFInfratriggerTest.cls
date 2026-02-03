/********************************************************************************************************
@Author      : Aishwarya Bhosale
@Description : This class is created to cover FSM_DCFInfraTriggerHelper, FSM_DCFInfraTriggerHandler, FSM_DCFInfraTrigger
@Description : Created as part of user story #SFS-3841
@Date        : 15-Dec-2023
********************************************************************************************************/
@isTest
public class FSM_DCFInfratriggerTest {
     @testsetup
    static void testSetup(){
      FSM_WorkPlanTemplateMapping__mdt woMdt = [Select MasterLabel,FSM_RecordTypeDeveloperName__c,FSM_WorkPlanTemplateName__c from FSM_WorkPlanTemplateMapping__mdt limit 1];
        
        WorkPlanTemplate woTemp = new FSM_TestDataFactory.WorkPlanTemplateCreator().setName(woMdt.FSM_WorkPlanTemplateName__c).setIsActive(true).create();
         
        WorkStepTemplate woStep = new FSM_TestDataFactory.WorkStepTemplateCreator().setName('Test workStep').setIsActive(true).create();
        
        WorkPlanTemplateEntry woEntry = new FSM_TestDataFactory.WorkPlanTemplateEntryCreator().setWorkPlanTemplateId(woTemp.Id).setWorkStepTemplateId(woStep.Id).create();
         Account acc=new FSM_TestDataFactory.AccountCreator().setName('test acc').create();
        Contact con=new FSM_TestDataFactory.ContactCreator().setFirstName('test').setLastName('testsurname').setAccount(acc.id).setEmail('no-reply@defaultemail.com').create();
        new FSM_TestDataFactory.CaseCreator().setStatus('New').setOrigin('Web').setContactName('Jon Hall').setContactEmail('jon.hall@gmail.com').create();        
        
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus('New').setBusinessUnit('Waste Infra').create();
        DateTime earliestdte = datetime.newInstance(2023, 11, 15, 12, 30, 0);
		 DateTime duedate = datetime.newInstance(2023, 11, 15, 13, 30, 0);
        boolean pdfgenerate=false;
        //Id recTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_WASTEINFRA).getRecordTypeId();
        id rectype=Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_WASTEINFRA).getRecordTypeId();
          id fwrrectype=Schema.SObjectType.FSM_DataCaptureFormInfra__c.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_INFRAFOLLOWONWORKREQUEST).getRecordTypeId();
        ServiceAppointment sv= new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(rectype).setParentRecordId(wo.id).setStatus('New').setEarliestStartTime(earliestdte).setDueDate(duedate).create();
    FSM_DataCaptureFormInfra__c dcf=new FSM_TestDataFactory.DataCaptureFormInfraCreator().setWorkorder(wo.id).setGeneratepdf(pdfgenerate).setRecordTypeId(fwrrectype).create();
        ContentVersion cv1 = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('Site1.jpeg').setTitle('Site1').setVersionData(Blob.valueOf( 'Testing content version')).setRelatedrecordId(dcf.id).create();
    ContentVersion cv2 = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('Site2.jpeg').setTitle('Site2').setVersionData(Blob.valueOf( 'Testing content version')).setRelatedrecordId(dcf.id).create();
         ContentVersion cv3 = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('sketch.jpeg').setTitle('sketch.jpeg').setVersionData(Blob.valueOf( 'Testing content version')).setRelatedrecordId(dcf.id).create();
    ContentVersion cv4 = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('Banner.jpeg').setTitle('Banner.jpeg').setVersionData(Blob.valueOf( 'Testing content version')).setRelatedrecordId(dcf.id).create();
   
    }
    
    @isTest
    static void testgeneratepdf(){
 		Test.startTest();
        FSM_DataCaptureFormInfra__c dcfrec=[Select id,FSM_Generate_PDF__c from FSM_DataCaptureFormInfra__c LIMIT 1];
       	dcfrec.FSM_Generate_PDF__c=true;
        update dcfrec;
        Test.stopTest();        
    }

}
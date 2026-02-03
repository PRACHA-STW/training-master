/********************************************************************************************************
@Author      : Deepak Moudekar
@Description : This class is created to cover FSM_ContentVersionTrigger, FSM_ContentVersionTriggerHandler, FSM_ContentVersionTriggerHelper
@Description : Created as part of user story #SFI-24
@Date        : 13-June-2023
********************************************************************************************************/
@isTest
public class FSM_ContentVersionTriggerHandlerTest {
    
    /********************************************************************************************************
    @Author      : Deepak Moudekar
    @Description : This method is used to create test data setup.
    ******************************************************************************************************* */
    @testsetup
    static void testSetup(){
        FSM_WorkPlanTemplateMapping__mdt woMdt = [Select MasterLabel,FSM_RecordTypeDeveloperName__c,FSM_WorkPlanTemplateName__c from FSM_WorkPlanTemplateMapping__mdt limit 1];
        
        WorkPlanTemplate woTemp = new FSM_TestDataFactory.WorkPlanTemplateCreator().setName(woMdt.FSM_WorkPlanTemplateName__c).setIsActive(true).create();
         
        WorkStepTemplate woStep = new FSM_TestDataFactory.WorkStepTemplateCreator().setName('Test workStep').setIsActive(true).create();
        
        WorkPlanTemplateEntry woEntry = new FSM_TestDataFactory.WorkPlanTemplateEntryCreator().setWorkPlanTemplateId(woTemp.Id).setWorkStepTemplateId(woStep.Id).create();
        
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setExternalId('testId').setStatus('New').setBusinessUnit('Waste Infra').create();
        DateTime earliestdte = datetime.newInstance(2023, 11, 15, 12, 30, 0);
		 DateTime duedate = datetime.newInstance(2023, 11, 15, 13, 30, 0);
        //Id recTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_WASTEINFRA).getRecordTypeId();
        id rectype=Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_WASTEINFRA).getRecordTypeId();
        ServiceAppointment sv= new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(rectype).setParentRecordId(wo.id).setStatus('New').setEarliestStartTime(earliestdte).setDueDate(duedate).create();
		
    }
    
    /********************************************************************************************************
    @Author      : Deepak Moudekar
    @Description : This method is used to test whether content version source is SAP or salesforce
    ******************************************************************************************************* */
    @isTest
    static void testCreateContentVersion(){
        WorkOrder woData = [select id from WorkOrder limit 1];
        ServiceAppointment sappt=[Select id from ServiceAppointment limit 1];
        Test.startTest();
        //ContentVersion conv = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('test.txt').setTitle('test title').setVersionData(Blob.valueOf( 'Testing')).create();
        ContentVersion cv = new FSM_TestDataFactory.ContentVersionCreator().setPathOnClient('test.pdf').setTitle('test title').setVersionData(Blob.valueOf( 'Testing content version')).setRelatedrecordId(sappt.id).create();
        Test.stopTest();
        
        ContentVersion conVer = [select id,FSM_Source__c from ContentVersion where Id = :cv.Id];
        System.Assert(conVer.FSM_Source__c != '' , 'Error occurred');
        
    }
}
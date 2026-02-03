/****************************************************************************************************************************
@Author : Leena Bheemarasetty
@Date   : 8th August 2023
@Description : This class is used to test the if Forms names are available ot not according to the WorkStep Configurations 
               of Main Class which will be called from a sub Flow
@Description : Created as part of user story #SFS-1298
@Main Class : FSM_InvocableDcfConfiguration  
==============================================================================================================================
*/
@isTest (SeeAlldata = false)
public class FSM_InvocableDcfConfiguration_Test {

/*--------------------------------------------------------------
@Author      : Leena Bheemarasetty
@Description : This method is used to create test data setup.
-----------------------------------------------------------------*/
    @TestSetup
    static void testDataSetup(){
        List<OperatingHours> listOp = new List<OperatingHours>();
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('AM/Pm Operating Hours').setSlotType(FSM_Constants.DURATION).setBusinessUnit('Metering').create();
     
        ServiceTerritory se = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('6302M03 Central').setBusinessUnit('Metering').setIsActive(true).setExtenalId('888999')
            .setOpreratingHours(op.Id).create();
        
        ServiceTerritory stWaste = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('4106WP3 Derby-Res-Bstrs').setBusinessUnit('Waste Non Infra').setIsActive(true).setExtenalId('8889991')
            .setOpreratingHours(op.Id).create();
        
    }
    
/*-----------------------------------------------------------------------------------------------------------------
@Author      : Leena Bheemarasetty
@Description : This method is used to test whether FormNames are present or not for the WorkOrder According to the 
               configurations set in MetaData.
-------------------------------------------------------------------------------------------------------------------*/
    @IsTest
    static void testGetFormNames(){  
        test.startTest();
        ServiceTerritory st=[Select Id,Name from ServiceTerritory where FSM_BusinessUnit__c = 'Metering'];
        Id rtId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
                             .get(FSM_Constants.RECORDTYPE_METERING).getRecordTypeId();
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(rtId).setBusinessUnit('Metering').setServiceTerritory(st.Id).standardTextKey('SVO').returnWithoutCreate(); 
        INSERT wo;
        //Fetching  the created record
        WorkOrder wo1=[Select Id,ServiceTerritoryId,FSM_StandardTextKey__c,FSM_Suitability__c,MinimumCrewSize, FSM_BusinessUnit__c from WorkOrder];
        //Creating parameters for Invocable Method
        FSM_InvocableDcfConfiguration.InputParams conditions = new FSM_InvocableDcfConfiguration.InputParams();
        conditions.minimumCrewSize=wo1.MinimumCrewSize;
        conditions.serviceTerritory=st.Name;
        conditions.standardTextKey=wo1.FSM_StandardTextKey__c;
        conditions.suitability=wo1.FSM_Suitability__c;
        conditions.workorderId=wo1.Id;
        conditions.businessUnit=wo1.FSM_BusinessUnit__c;
        
        //Calling the Invocable Method
        List<List<FSM_DCFConfigurationWorkStep__mdt>> formList= FSM_InvocableDcfConfiguration.getFormNames(new List<FSM_InvocableDcfConfiguration.InputParams> {conditions});
        test.stopTest();
        
        List<FSM_DCFConfigurationWorkStep__mdt> configs = formList[0];
        System.assert(configs.isEmpty() == false, 'No forms returned.');
        
    }
    
    @IsTest
    static void dedupeCheck(){  
        
        OperatingHours op = [SELECT Id FROM OperatingHours WHERE Name = 'AM/Pm Operating Hours'];
        
        ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator()
            .setName('1301WD2 Leak Warwickshire')
            .setBusinessUnit('Water Infra')
            .setIsActive(true).setExtenalId('889999')
            .setOpreratingHours(op.Id)
            .create();
        
        test.startTest();
        
        Id rtId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
                             .get(FSM_Constants.RECORDTYPE_METERING).getRecordTypeId();
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(rtId).setBusinessUnit('Water Infra').setServiceTerritory(st.Id).standardTextKey('SVOF').create(); 
        //Fetching  the created record
        WorkOrder wo1=[Select Id,ServiceTerritoryId,FSM_StandardTextKey__c,FSM_Suitability__c,MinimumCrewSize, FSM_BusinessUnit__c from WorkOrder];
        //Creating parameters for Invocable Method
        FSM_InvocableDcfConfiguration.InputParams conditions = new FSM_InvocableDcfConfiguration.InputParams();
        conditions.minimumCrewSize=wo1.MinimumCrewSize;
        conditions.serviceTerritory=st.Name;
        conditions.standardTextKey=wo1.FSM_StandardTextKey__c;
        conditions.suitability=wo1.FSM_Suitability__c;
        conditions.workorderId=wo1.Id;
        conditions.businessUnit=wo1.FSM_BusinessUnit__c;
        
        //Calling the Invocable Method
        List<List<FSM_DCFConfigurationWorkStep__mdt>> formList= FSM_InvocableDcfConfiguration.getFormNames(new List<FSM_InvocableDcfConfiguration.InputParams> {conditions});
        test.stopTest();
        
        //asserting there are no duplicates returned.
        Boolean hasDuplicate = false;
        Set<String> uniqueWorkSteps = new Set<String>();
        
        for(FSM_DCFConfigurationWorkStep__mdt  config: formList[0]){
            String workstepName = config.FSM_WorkStepName__c;
            if(!uniqueWorkSteps.contains(workstepName)){
                uniqueWorkSteps.add(workstepName);
            } else{
                hasDuplicate = true;
            }
        }
        
        
        WorkPlan wp=new FSM_TestDataFactory.WorkPlanCreator().setName('Developer Services').setparent(wo.Id).setWorkorder(wo.Id).create();
        
        Workstep workstep = new FSM_TestDataFactory.WorkStepCreator().setName('Boards & Barriers').setActionDef('WorkStep.FSM_BoardsAndBarriers').setWorkPlan(wp.Id).setStatus('New').returnWithoutCreate();
        workstep.FSM_MaxInstance__c = 2;
        INSERT workstep;
        
        
        Boolean hasWorkStepReached = FSM_InvocableDcfConfiguration.hasDCFLimitReached(workstep.Id);
        
        System.assertEquals(false, hasWorkStepReached, 'Max Instance Check failed.');
        
    }

    @IsTest
    static void testNonInfraBU(){  
        test.startTest();
        ServiceTerritory st=[Select Id,Name from ServiceTerritory where FSM_BusinessUnit__c = 'Waste Non Infra'];
        Id rtId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
                             .get(FSM_Constants.RECORDTYPE_WASTENONINFRA).getRecordTypeId();
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(rtId).setBusinessUnit('Waste Non Infra').setServiceTerritory(st.Id).standardTextKey('WPASC1').returnWithoutCreate(); 
        INSERT wo;
        //Fetching  the created record
        WorkOrder wo1=[Select Id,ServiceTerritoryId,FSM_StandardTextKey__c,FSM_Suitability__c,MinimumCrewSize, FSM_BusinessUnit__c from WorkOrder];
        //Creating parameters for Invocable Method
        FSM_InvocableDcfConfiguration.InputParams conditions = new FSM_InvocableDcfConfiguration.InputParams();
        conditions.minimumCrewSize=wo1.MinimumCrewSize;
        conditions.serviceTerritory=st.Name;
        conditions.standardTextKey=wo1.FSM_StandardTextKey__c;
        conditions.suitability=wo1.FSM_Suitability__c;
        conditions.workorderId=wo1.Id;
        conditions.businessUnit=wo1.FSM_BusinessUnit__c;
        
        //Calling the Invocable Method
        List<List<FSM_DCFConfigurationWorkStep__mdt>> formList= FSM_InvocableDcfConfiguration.getFormNames(new List<FSM_InvocableDcfConfiguration.InputParams> {conditions});
        test.stopTest();
        List<FSM_DCFConfigurationWorkStep__mdt> configs=new List<FSM_DCFConfigurationWorkStep__mdt>();
        if(formList!=null && !formList.isEmpty()){
        	configs = formList[0];
        }
        System.assert(configs.isEmpty() == true, 'Forms returned.');
        
    }
}
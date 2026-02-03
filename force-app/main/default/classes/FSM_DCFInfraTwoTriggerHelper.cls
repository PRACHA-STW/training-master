/********************************************************************************************************
@Author      : Brajesh Kumar
@Description : This class is used to call vf page for pdf creation of dcf infra form 2.
@Description : Created as part of user story #SFS-5399
@Description : Invoked from FSM_DCFInfraTwoTriggerHandler class
@Test Class  : FSM_DCFInfraTwoTriggerTest
@Date        : 28-June-2024
********************************************************************************************************/
public class FSM_DCFInfraTwoTriggerHelper {
    public void generatePdf(Map<Id,sObject> newMap,Map<Id,sObject> oldMap){
        Map<Id, FSM_InfraDataCaptureForm2__c> allNewDCF=(Map<Id, FSM_InfraDataCaptureForm2__c>)newMap; //collecting all updated Data capture form infra records
        Map<Id, FSM_InfraDataCaptureForm2__c> allOldDCF=(Map<Id, FSM_InfraDataCaptureForm2__c>)oldMap; //collecting all updated Data capture form infra records old value
        List<FSM_InfraDataCaptureForm2__c>dcfinfraUpdtList=new List<FSM_InfraDataCaptureForm2__c>();
        for(FSM_InfraDataCaptureForm2__c cmp : allNewDCF.values()) {
            if((cmp.FSM_Generate_PDF__c!=allOldDCF.get(cmp.Id).FSM_Generate_PDF__c) && (allOldDCF.get(cmp.Id).FSM_Generate_PDF__c==false))
            {	
                system.debug('data capture form id'+cmp);
                String woRecordId = [Select Id,FSM_WorkOrder__c,FSM_WorkStep__r.Id  from FSM_InfraDataCaptureForm2__c where id=:cmp.Id AND RecordType.DeveloperName = 'FSM_SewerageFurtherWorkRequestSCM' Limit 1].FSM_WorkOrder__c;
                ServiceAppointment sa = [Select Id from ServiceAppointment where ParentRecordId=:woRecordId order by createdDate desc Limit 1];
                try{ 
                    FSM_sketchCls_DCF2.pdfCreation(sa.Id,cmp.Id);
                }catch(Exception e){
                    system.debug('error'+e);
                }
            }else{
                system.debug('do nothing');
            }
            
        }
        
    }
    
}
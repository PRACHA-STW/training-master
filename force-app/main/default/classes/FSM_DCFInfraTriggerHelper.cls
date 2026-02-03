/********************************************************************************************************
@Author      : Aishwarya Bhosale
@Description : This class is used to call vf page for pdf creation of dcf infra form.
@Description : Created as part of user story #SFS-3841
@Description : Invoked from FSM_DCFInfraTriggerHandler class
@Test Class  : FSM_DCFInfratriggerTest
@Date        : 15-Dec-2023
********************************************************************************************************/
public with sharing class FSM_DCFInfraTriggerHelper {
    public void generatePdf(Map<Id,sObject> newMap,Map<Id,sObject> oldMap){
         Map<Id, FSM_DataCaptureFormInfra__c> allNewDCF=(Map<Id, FSM_DataCaptureFormInfra__c>)newMap; //collecting all updated Data capture form infra records
        Map<Id, FSM_DataCaptureFormInfra__c> allOldDCF=(Map<Id, FSM_DataCaptureFormInfra__c>)oldMap; //collecting all updated Data capture form infra records old value
        List<FSM_DataCaptureFormInfra__c>dcfinfraUpdtList=new List<FSM_DataCaptureFormInfra__c>();
        for(FSM_DataCaptureFormInfra__c cmp : allNewDCF.values()) {
            if((cmp.FSM_Generate_PDF__c!=allOldDCF.get(cmp.Id).FSM_Generate_PDF__c) && (allOldDCF.get(cmp.Id).FSM_Generate_PDF__c==false))
               {	
                   system.debug('data capture form id'+cmp);
                    String woRecordId = [Select Id,FSM_WorkOrder__c from FSM_DataCaptureFormInfra__c where id=:cmp.Id AND RecordType.DeveloperName = 'Infra_Follow_On_Work_Request' Limit 1].FSM_WorkOrder__c;
                    ServiceAppointment sa = [Select Id from ServiceAppointment where ParentRecordId=:woRecordId order by createdDate desc Limit 1];
                   try{
                       
                       FSM_sketchCls.pdfCreation(sa.Id,cmp.Id);
                     
                      }catch(Exception e){
                       system.debug('error'+e);
                   }
               }else{
                   system.debug('do nothing');
               }
 
    }
     
}
    
}
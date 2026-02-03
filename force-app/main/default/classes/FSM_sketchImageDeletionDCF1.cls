/********************************************************************************************************
@Author      : Brajesh Kumar
@Description : This class is used for deletion of Sketch Image after Sketch PDF Creation,
@Description : Created as part of user story #SFL-1015
@Description : Invoked from FSM_sketchCls class
@Test Class  : FSM_sketchClsTest
@Date        : 04-August-2025
********************************************************************************************************/
public without sharing class FSM_sketchImageDeletionDCF1 {
    /********************************************************************************************************
    @Author      : Brajesh Kumar
    @Description : This Method will be used for deletion of Sketch Image after Sketch PDF Creation.
    @Description : Created as part of user story #SFL-1015
    @Date        : 04-August-2025
    ********************************************************************************************************/
	    //added as part of SFS-4061
    public static void deleteimagesafterpdfcreation(string dcfid){        
        List<Id> contentdocids=new List<Id>();
        List<Id> contentdocidsflagtrue=new List<Id>();
        List<ContentDocument> cdocdel=new List<ContentDocument>();
        List<FSM_DataCaptureFormInfra__c> dcfupdate = new List<FSM_DataCaptureFormInfra__c>();
        List<WorkStep> ws=new List<WorkStep>();
         
        List<ContentDocumentLink> cdl=[Select LinkedEntityId,ContentDocumentId,ContentDocument.Title from ContentDocumentLink where (ContentDocument.Title LIKE '%Photo%' OR ContentDocument.Title LIKE '%Site%' OR ContentDocument.Title LIKE '%sketch%' OR ContentDocument.Title LIKE '%Banner%') AND LinkedEntityId=:dcfid];
        
        for(ContentDocumentLink cd:cdl){
            
            contentdocids.add(cd.ContentDocumentId);
            }
        List<ContentVersion> cvlist=[Select id,Title,ContentDocumentId from ContentVersion where ContentVersion.FSM_Sketch_Additional_Images__c=true AND ContentDocumentId  IN:contentdocids with security_enforced];
        for(ContentVersion cvs:cvlist){
            
            contentdocidsflagtrue.add(cvs.ContentDocumentId);
            }        
        cdocdel=[Select id,ContentDocument.Title From ContentDocument where id IN:contentdocidsflagtrue with security_enforced];
        if (Schema.sObjectType.ContentDocument.isDeletable()) {
            try{
                delete cdocdel;
            }catch(DmlException e) {
                System.debug('The following exception has occurred while deleting ContentDocument: ' + e.getMessage());
            }
    
}
         String workStepId;    
        dcfupdate=[Select id,FSM_Generate_PDF__c,FSM_WorkOrder__c,FSM_WorkStep__r.Id from FSM_DataCaptureFormInfra__c where id=:dcfid];
        workStepId=dcfupdate[0].FSM_WorkStep__r.Id;
       
        if(dcfupdate.size()>0){
            dcfupdate[0].FSM_Generate_PDF__c=false;
            dcfupdate[0].FSM_Status__c='Completed';
          
            try {
                update dcfupdate;
                
            } catch(DmlException e) {System.debug('The following exception has occurred while updating dcf infra: ' + e.getMessage());
            }
            
        }
       //update workStep Status
       updateworkstepStatus(workStepId);
    }
    /********************************************************************************************************
    @Author      : Brajesh Kumar
    @Description : This Method will be used for updating workstep status.
    @Description : Created as part of user story #SFL-1015
    @Date        : 04-August-2025
    ********************************************************************************************************/ 
    public static void updateworkstepStatus(String wsId){
        WorkStep ws=[Select id,Status from WorkStep where id=:wsId limit 1];
        if(ws != null){
            ws.Status='Completed';
            ws.FSM_IsCompleted__c = true;
            try {
                update ws;
                
            } catch(DmlException e) {System.debug('The following exception has occurred while updating workstep: ' + e.getMessage());
            } 
        }
        
           
    }
}
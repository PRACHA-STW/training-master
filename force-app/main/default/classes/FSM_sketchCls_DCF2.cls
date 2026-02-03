/*@author: Alagar
@Date: 02/07/24
@comments: This creates a PDF of the edit image
@LastModifiedby:Brajesh for SFS-5399
*/
public with sharing class FSM_sketchCls_DCF2 {
    /*
@methiodname: pdfCreation
@comments: calls vf page for PDF creation
*/
    @Future(callout=true)
    public static void pdfCreation(Id saID,string recId){ 
        
        FSM_InfraDataCaptureForm2__c dcfupdate=new FSM_InfraDataCaptureForm2__c();
        
        
        Pagereference pg;
        List<FSM_InfraDataCaptureForm2__c> fetchDcf = new List<FSM_InfraDataCaptureForm2__c>();
        fetchDcf = [select id, FSM_DeviceType__c,FSM_WorkOrder__r.FSM_OrderNumber__c,FSM_WorkOrder__r.FSM_OperationNumber__c from FSM_InfraDataCaptureForm2__c where id=: recId LIMIT 1];
        
        String getDateTime= getFormattedDateTime();
        String pdfFileName = fetchDcf[0].FSM_WorkOrder__r.FSM_OrderNumber__c+'_'+fetchDcf[0].FSM_WorkOrder__r.FSM_OperationNumber__c+'_FWR_'+getDateTime+'.pdf';
        string device=fetchDcf[0].FSM_DeviceType__c;
        if(device=='Mobile'){
            pg = Page.FSM_Sewerage_Mobile;
        }
        else{
            pg = Page.FSM_Sewerage_Desktop;
        } 
        pg.getParameters().put('id', recId);
        Blob pdfFileData ;
        if(Test.isRunningTest()) { 
            pdfFileData = blob.valueOf('Unit.Test');
        } else {
            pdfFileData = pg.getContentaspdf();
        } 
        dcfupdate=[Select id,FSM_Generate_PDF__c,FSM_ServiceTerritory__c,FSM_WorkOrder__c,FSM_WorkOrder__r.CaseId from FSM_InfraDataCaptureForm2__c where id=:recId];
        //PDF generation
        ContentVersion cv = createContentVersion(pdfFileData , null, pdfFileName );
        ContentDocumentLink cdl = createContentLink(cv.Id, recId);
        ContentDocumentLink cd2 = createContentLink(cv.Id, dcfupdate.FSM_WorkOrder__c);  //commented as queueable error is thrown
        ContentDocumentLink cd3 = createContentLink(cv.Id, dcfupdate.FSM_WorkOrder__r.CaseId); // added a part of SFL-1110
        //Added as part of SFS-4516
        
        List<WorkOrder> wo=[Select id,ServiceTerritoryId from WorkOrder where id=:dcfupdate.FSM_WorkOrder__c WITH SECURITY_ENFORCED];
        if(wo.size() > 0){
            if (Schema.sObjectType.FSM_InfraDataCaptureForm2__c.fields.FSM_ServiceTerritory__c.isUpdateable()) {
                dcfupdate.FSM_ServiceTerritory__c=wo[0].ServiceTerritoryId;
                update dcfupdate;
            }
        }
        
    }
    //@return String - The formatted date and time as a string in the format YYYY-MM-DD_HHMMSS.
    public static String getFormattedDateTime() {
        // Get the current datetime
        Datetime now = Datetime.now();
        // Extract and format year, month, day, hours, minutes, and seconds
        String formattedDateTime = String.format(
            '{0}{1}{2}{3}{4}{5}',
            new List<Object>{
                String.valueOf(now.year()),
                    now.month() < 10 ? '0' + String.valueOf(now.month()) : String.valueOf(now.month()),
                        now.day() < 10 ? '0' + String.valueOf(now.day()) : String.valueOf(now.day()),
                            now.hour() < 10 ? '0' + String.valueOf(now.hour()) : String.valueOf(now.hour()),
                                now.minute() < 10 ? '0' + String.valueOf(now.minute()) : String.valueOf(now.minute()),
                                    now.second() < 10 ? '0' + String.valueOf(now.second()) : String.valueOf(now.second())
                                        }
        );
        return formattedDateTime;
    }
    /*
@methiodname: createContentVersion
@comments: content document creation
*/
    public static ContentVersion createContentVersion(Blob bData, String base64, String filename) {
        system.debug('inside createContentVersion');
        String userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        ContentVersion cv = new ContentVersion();
        cv.VersionData = ( bData <> Null ? bData : EncodingUtil.base64Decode(base64));
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.FSM_Do_not_send_to_SAP__c=false; //added as part of SFS-4061  
        try {
            if(Schema.sObjectType.ContentVersion.isCreateable()){
                insert cv;
                system.debug('pdf cv'+cv);
            }
            return cv;
        } catch(DMLException e) {System.debug('error'+e);return null;
                                }
    }
    
    /*
@methiodname: ContentDocumentLink
@comments: link the document with the record
*/
    public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        system.debug('inside createContentLink');
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                insert cdl;
                system.debug('inside after insert');
            }
            //added as part of sfs-4061
            Id recid=recordId;
            String sObjName = recid.getSObjectType().getDescribe().getName();
            if(sObjName == 'FSM_InfraDataCaptureForm2__c')
            {
                FSM_sketchImageDeletionDCF2.deleteimagesafterpdfcreation(recordId);
            }
            
            return cdl;
            
        }catch(DMLException e) { return null;
                               }
        
    }
}
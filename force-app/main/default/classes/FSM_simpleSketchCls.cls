/*@author: Alagar
@Date: 12/07/23
@comments: This creates a PDF of the edit image
@LastModifiedby:Aishwarya Bhosale
*/
public with sharing class FSM_simpleSketchCls {   
    /*
@methiodname: pdfCreation
@comments: calls vf page for PDF creation
*/
    @Future(callout=true)
    //public static void pdfCreation(string recId, string docId){
    public static void pdfCreation(string recId){   
        // pdf logic
        // sketch.png on name from  recId
        //then insert pdf on same record
        Blob pdfFileData ;
        WorkOrder wo=[Select FSM_DeviceType__c,FSM_FileName__c from WorkOrder where id=:recId];
        string device=wo.FSM_DeviceType__c;
        String pdfFileName=wo.FSM_FileName__c+'.pdf';
        //system.debug('device'+device+'--filename'+pdfFileName);
        if(device=='Mobile'){
            pdfCreationMobile(recId,pdfFileName);
        }else{
            pdfCreationDesktop(recId,pdfFileName);
        }
    }
    
    /*
@methiodname: createContentVersion
@comments: content document creation
*/
    public static ContentVersion createContentVersion(Blob bData, String base64, String filename) {
        String userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        ContentVersion cv = new ContentVersion();
            cv.VersionData = ( bData <> Null ? bData : EncodingUtil.base64Decode(base64));
            cv.Title = filename;
            cv.PathOnClient = filename;
            cv.FSM_Do_not_send_to_SAP__c=false; //added as part of SFS-4061
            /** Communities are no longer in use, so commenting out the codes related to it.
       // if(profileName=='FSM Customer Community Plus User')
        if(profileName.contains('Customer Community'))
        {
            Id networkId = [SELECT NetworkId, MemberId FROM NetworkMember WHERE MemberId =:userId].NetworkId;
            
            cv.VersionData = ( bData <> Null ? bData : EncodingUtil.base64Decode(base64));
            cv.Title = filename;
            cv.PathOnClient = filename;
            cv.NetworkId= networkId;
            cv.FSM_Do_not_send_to_SAP__c=false; //added as part of SFS-4061
        }else{
            
            cv.VersionData = ( bData <> Null ? bData : EncodingUtil.base64Decode(base64));
            cv.Title = filename;
            cv.PathOnClient = filename;
            cv.FSM_Do_not_send_to_SAP__c=false; //added as part of SFS-4061
            
        }
        **/
        
        //system.debug('networkid'+networkId);
        // ContentVersion cv = new ContentVersion();
        // cv.VersionData = ( bData <> Null ? bData : EncodingUtil.base64Decode(base64));
        // cv.Title = filename;
        // cv.PathOnClient = filename;
        // cv.NetworkId= networkId;
        try {
            if(Schema.sObjectType.ContentVersion.isCreateable()){
                insert cv;
            }
            return cv;
        } catch(DMLException e) {
            System.debug('error'+e);
            return null;
        }
    }
    
    /*
@methiodname: ContentDocumentLink
@comments: link the document with the record
*/
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
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
                
            }
            deleteimagesafterpdfcreation(recordId);
            return cdl;
        } catch(DMLException e) {
            //System.debug(e);
            return null;
        }
    }
    
    public static void deleteimagesafterpdfcreation(string woid){
        system.debug('inside delete');
        
        List<Id> contentdocids=new List<Id>();
        List<ContentDocument> cdocdel=new List<ContentDocument>();
        List<Id> contentdocidsflagtrue=new List<Id>();
        List<WorkOrder> woupdate = new List<WorkOrder>();
        
        List<ContentDocumentLink> cdl=[Select LinkedEntityId,ContentDocumentId,ContentDocument.Title from ContentDocumentLink where (ContentDocument.Title LIKE '%Photo%' OR ContentDocument.Title LIKE '%Site%' OR ContentDocument.Title LIKE '%sketch%') AND LinkedEntityId=:woid];
        
        for(ContentDocumentLink cd:cdl){
            system.debug('ContentDocument.Title'+cd.ContentDocument.Title);
            contentdocids.add(cd.ContentDocumentId);
            system.debug('contentdocids'+contentdocids);
        }
        //added as part of SFS-4061
        List<ContentVersion> cvlist=[Select id,Title,ContentDocumentId from ContentVersion where ContentVersion.FSM_Sketch_Additional_Images__c=true AND ContentDocumentId  IN:contentdocids with security_enforced];
        for(ContentVersion cvs:cvlist){
            
            contentdocidsflagtrue.add(cvs.ContentDocumentId);
            system.debug('contentdocidsflagtrue'+contentdocidsflagtrue);
        }
        
        
        cdocdel=[Select id,ContentDocument.Title From ContentDocument where id IN:contentdocidsflagtrue with Security_enforced];
        if (Schema.sObjectType.ContentDocument.isDeletable()) {
            try{
                delete cdocdel;
            }catch(DmlException e) {
                System.debug('The following exception has occurred while deleting ContentDocument: ' + e.getMessage());
            }
            
        }
        
        woupdate=[Select id,FSM_GeneratePDF__c from WorkOrder where id=:woid with Security_enforced];
        if(woupdate.size()>0){
            woupdate[0].FSM_GeneratePDF__c=false;
            try {
                if (Schema.sObjectType.WorkOrder.fields.FSM_GeneratePDF__c.isUpdateable()) {
                    update woupdate;
                }
              
            } catch(DmlException e) {System.debug('The following exception has occurred while updating dcf infra: ' + e.getMessage());
            }
        }
        
    }
    public static void pdfCreationMobile(string recId,string fileNameuserinput){
        Blob pdfFileData;
        Pagereference pg1 = Page.FSM_simpleSketchPotraitPDF;
        
        pg1.getParameters().put('recId', recId);
        if(Test.isRunningTest()) { 
            pdfFileData = blob.valueOf('Unit.Test');
        } else { pdfFileData = pg1.getContentaspdf();
            system.debug('pdf data'+pdfFileData);
        } 
        ContentVersion cv = createContentVersion(pdfFileData , null, fileNameuserinput);
        ContentDocumentLink cdl = createContentLink(cv.Id, recId); 
        
    }
    public static void pdfCreationDesktop(string recId,string fileNameinput){
        
        Blob pdfFileData;
        Pagereference pg = Page.FSM_SimpleSketchPDF;
        pg.getParameters().put('recId', recId);
        if(Test.isRunningTest()) { 
            pdfFileData = blob.valueOf('Unit.Test');
        } else {  pdfFileData = pg.getContentaspdf();} 
        ContentVersion cv = createContentVersion(pdfFileData , null, fileNameinput);
        ContentDocumentLink cdl = createContentLink(cv.Id, recId); 
        
    }
    
}
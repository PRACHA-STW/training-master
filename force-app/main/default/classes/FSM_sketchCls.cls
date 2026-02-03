/*@author: Alagar
@Date: 12/07/23
@comments: This creates a PDF of the edit image
@LastModifiedby:Brajesh Kumar
*/

public with sharing class FSM_sketchCls {
  /*
@methiodname: pdfCreation
@comments: calls vf page for PDF creation
*/
    @Future(callout=true)
    //public static void pdfCreation(Id saID, string recId, string docId){ ash  commented as part of 3841
     public static void pdfCreation(Id saID,string recId){ 
            
        FSM_DataCaptureFormInfra__c dcfupdate=new FSM_DataCaptureFormInfra__c();
     
        Set<String> BOPPS_ASSET_TYPES = new Set<String>{
          'D 28',// HOUSEHOLD PROPERTY
          'D 29',// NON HOUSEHOLD PROPERTY
          'D 30',// HOUSEHOLD SUPPLY PIPE
          'D 31' // NON HOUSEHOLD PROPERTY
        };
        Pagereference pg;
        List<FSM_DataCaptureFormInfra__c> fetchDcf = new List<FSM_DataCaptureFormInfra__c>();
        try{
         fetchDcf = [select id,FSM_WorkOrder__r.FSM_OrderNumber__c,FSM_WorkOrder__r.FSM_OperationNumber__c,FSM_WorkOrder__r.FSM_ExternalId__c, FSM_DeviceType__c, FSM_Location__c, FSM_Asset__c,FSM_FileName__c from FSM_DataCaptureFormInfra__c where id=: recId LIMIT 1];
        // String pdfFileName = 'FWR_'+System.now()+'.pdf';
        // Updated as part of SFL-562
		 String getDateTime= getFormattedDateTime();
         String pdfFileName = fetchDcf[0].FSM_WorkOrder__r.FSM_OrderNumber__c+'_'+fetchDcf[0].FSM_WorkOrder__r.FSM_OperationNumber__c+'_FWR_'+getDateTime+'.pdf';
        if(detectPageToLoad(fetchDcf) == 'FSM_Water_Mobile')
        {
            pg = Page.FSM_Water_Mobile;
        }
        else if(detectPageToLoad(fetchDcf) == 'FSM_Water_Desktop')
        {pg = Page.FSM_Water_Desktop;}
        else if (detectPageToLoad(fetchDcf) == 'FSM_BOPPS_Mobile')
        {pg = Page.FSM_BOPPS_Mobile;}
        else if (detectPageToLoad(fetchDcf) == 'FSM_BOPPS_Desktop')
        {
            pg = Page.FSM_BOPPS_Desktop;
        }else {string device=fetchDcf[0].FSM_DeviceType__c;if(device=='Mobile'){ pg = Page.FSM_Water_Mobile;}else{pg = Page.FSM_Water_Desktop;}  }
            
        
        pg.getParameters().put('id', recId);
        Blob pdfFileData ;
        if(Test.isRunningTest()) { 
            pdfFileData = blob.valueOf('Unit.Test');
        } else {pdfFileData = pg.getContentaspdf();
        } 
        system.debug('----- pdfFileData'+pdfFileData);
        
        //PDF generation
        ContentVersion cv = createContentVersion(pdfFileData , null, pdfFileName );
        ContentDocumentLink cdl = createContentLink(cv.Id, recId);
       // ContentDocumentLink cd2 = createContentLink(cv.Id, saID);commented as queueable error is thrown
         //Added as part of SFS-4516
         dcfupdate=[Select id,FSM_Generate_PDF__c,FSM_ServiceTerritory__c,FSM_WorkOrder__c from FSM_DataCaptureFormInfra__c where id=:recId with Security_enforced];
         List<WorkOrder> wo=[Select id,ServiceTerritoryId from WorkOrder where id=:dcfupdate.FSM_WorkOrder__c with Security_enforced];
         if(wo.size() > 0){
            if (Schema.sObjectType.FSM_DataCaptureFormInfra__c.fields.FSM_ServiceTerritory__c.isUpdateable()) {
                dcfupdate.FSM_ServiceTerritory__c=wo[0].ServiceTerritoryId;
                update dcfupdate;
             }
            }
        }
        catch (VisualforceException vfe){
        	system.debug('------ VF exception'+ vfe);
        }
        catch (Exception e){
           system.debug('------  exception'+ e);
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



    
    public static string detectPageToLoad(List<FSM_DataCaptureFormInfra__c> fetchDcf)
    {
        Set<String> BOPPS_ASSET_TYPES = new Set<String>{
          'D 28',// HOUSEHOLD PROPERTY
          'D 29',// NON HOUSEHOLD PROPERTY
          'D 30',// HOUSEHOLD SUPPLY PIPE
          'D 31' // NON HOUSEHOLD PROPERTY
        };
        if((fetchDcf[0].FSM_Location__c!=null && fetchDcf[0].FSM_Location__c == 'Private Land') && (fetchDcf[0].FSM_Asset__c!=null && BOPPS_ASSET_TYPES.contains(fetchDcf[0].FSM_Asset__c)))
        {
            string device=fetchDcf[0].FSM_DeviceType__c;
            if(device=='Mobile'){ return 'FSM_BOPPS_Mobile';
            }
            else{ return 'FSM_BOPPS_Desktop';
            }
        }else{string device=fetchDcf[0].FSM_DeviceType__c;if(device=='Mobile'){ return 'FSM_Water_Mobile';}else{return 'FSM_Water_Desktop';}}
       // return null;
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
     /** Communities are no longer in use, so commenting out the codes related to it.
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

        try {
            if(Schema.sObjectType.ContentVersion.isCreateable()){
                insert cv;
                system.debug('pdf cv'+cv);
            }
            return cv;
        } catch(DMLException e) {System.debug('error'+e); return null;
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
            if(sObjName == 'FSM_DataCaptureFormInfra__c')
            {
                 FSM_sketchImageDeletionDCF1.deleteimagesafterpdfcreation(recordId);
            }
            
            return cdl;
           
        }catch(DMLException e) { return null;
        }
        
    }
}
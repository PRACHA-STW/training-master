/*@author: Alagar 
@Date: 25/06/24
@comments: This creates a PDF of the edit image
@LastModifiedby:Brajesh Kumar
*/
public with sharing class FSM_SketchPDFCtr_DCF2 {
    
    public String dcfRecordId  {get;set;}
    public string bannerImageURL { get; set; }
    //public ServiceAppointment serviceAppointmentObj{get;set;}
    public FSM_InfraDataCaptureForm2__c dcfObj {get;set;}
    
    public String pdfNo{get;set;}
    public String efNo{get;set;}
    public boolean show{get;set;}
    public boolean showpdf{get;set;}
    //public ApexPages.PageReference page2{get;set;}
    public String imageURL{get;set;}
    public String username{get;set;}
    public String phonenumber{get;set;}
    public String contentId{get;set;}
    public List<Id> siteIds {get;set;}
    public List<Id> photoIds {get;set;}
    public List<Id> bannerIds {get;set;}
    public Id cversionId{get;set;}
    public Date currDate{get;set;}
    public string addressFields{get;set;}
    public String dateString{get;set;}
    /*
@method: constructor
@comments: constructor function
*/
    String binVar = '';
    public FSM_SketchPDFCtr_DCF2(){
        binVar = '';
    }
    
    /*
@method: FSM_SketchPDFCtr_DCF2
@comments: constructor function
*/
    public FSM_SketchPDFCtr_DCF2(ApexPages.StandardController controller){
        
        //SFS-5401 - get current date and Address
        currDate = Date.Today();
        Date d = Date.today();
        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
        dateString = dt.format('dd-MM-yyyy');
        
        
        Id userId =UserInfo.getUserId(); 
        User u = [SELECT Name FROM User WHERE Id =: userId];
        List<ServiceResource> sr=[Select FSM_Phone__c,Name from ServiceResource where RelatedRecordId=:userId Limit 1 ];
        if (!sr.isEmpty()) {
            phoneNumber = sr[0].FSM_Phone__c;
             username=sr[0].Name;
        }
        dcfRecordId = ApexPages.currentPage().getParameters().get('id');
        dcfObj = [Select Id,FSM_UserName__c,FSM_TelephoneNumber__c,FSM_GridsReferenceX__c,FSM_GridsReferenceY__c,       
                  FSM_Location__c,      
                  FSM_HouseName__c,
                  FSM_WorkOrder__r.WorkOrderNumber,
                  FSM_WorkOrder__r.FSM_ExternalId__c,
                  FSM_HouseNo__c,       
                  FSM_Street__c,FSM_Town__c,FSM_PostCode__c,FSM_OccupiersHouseName__c,FSM_OccupiersPostcode__c,FSM_OccupiersHouseNo__c,FSM_OccupiersTown__c,FSM_OccupiersStreet__c,FSM_OccupiersName__c,FSM_OccupiersTelephoneNumber__c,
                  FSM_OwnersTelephoneNumber__c,
                  FSM_Verge__c,FSM_BridlewayFootpath__c,FSM_PrivateLand__c,FSM_Footway__c,FSM_Cycleway__c,FSM_PedestrianZone__c,
                  FSM_SFWXcoordinate__c,FSM_SFWYcoordinate__c,
                  FSM_FWRPlanningInformation__c,
                  FSM_Monday__c,FSM_Tuesday__c,
                  FSM_Wednesday__c,FSM_Thursday__c,FSM_Friday__c,FSM_Saturday__c,FSM_Sunday__c,FSM_AM__c,FSM_PM__c,FSM_Night__c,
                  FSM_OwnersHouseName__c,FSM_OwnersHouseNo__c,FSM_OwnersStreet__c,FSM_OwnersTown__c,FSM_OwnersPostcode__c,FSM_Carriageway__c,
                  toLabel(FSM_SWRJobScope__c),toLabel(FSM_SWRTransferredAsset__c),      
                  toLabel(FSM_SWRAsset__c),toLabel(FSM_SWRTask__c),toLabel(FSM_SWRJobRecipient__c),FSM_FWRFootwayWidth__c,FSM_FWRCarriagewayWidth__c,FSM_Speed__c ,     
                  FSM_FWRRoadType__c,FSM_FWRVisibilityToMenAtWork__c,   
                  FSM_SurfaceType__c,FSM_FWRTrafficFlow__c,FSM_FWRPedestrianWalkway__c, 
                  FSM_FWRSpecialFeature__c,FSM_FWRPedestrianLights__c,FSM_TrafficLightRestriction__c,   
                  FSM_FWRTrainOrTram__c,        
                  FSM_FWRBus__c ,       
                  FSM_FWRCycle__c ,             
                  FSM_FWRCommsMethod__c,        
                  FSM_FWRCommsType__c  FROM FSM_InfraDataCaptureForm2__c
                  Where Id =: dcfRecordId ];
        
        addressFields = dcfObj.FSM_WorkOrder__r.FSM_ExternalId__c!=null ? ' '+dcfObj.FSM_WorkOrder__r.FSM_ExternalId__c: '';
        addressFields +=dcfObj.FSM_OccupiersHouseName__c!=null ? ' '+dcfObj.FSM_OccupiersHouseName__c : '';
        addressFields +=dcfObj.FSM_OccupiersHouseNo__c!= null ? ' '+string.valueOf(dcfObj.FSM_OccupiersHouseNo__c) : '';
        addressFields +=dcfObj.FSM_OccupiersStreet__c!=null ? ' '+dcfObj.FSM_OccupiersStreet__c: '';
    }
    
    /*
@method: pdfAction
@comments: creates the PDF
*/
    public void pdfAction()
    {
        siteIds = new List<Id>();
        photoIds = new List<Id>();
        bannerIds=new List<Id>();
        system.debug('inside pdfAction');
        //id cversionId;
        id bannerid;
        dcfRecordId = ApexPages.currentPage().getParameters().get('id');
        
        List<ContentVersion> documentList = new List<ContentVersion>();
        
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();    
        
        ContentDocumentLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId, Visibility, IsDeleted, ShareType,
                                   ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                                   FROM ContentDocumentLink WHERE LinkedEntityId =: dcfRecordId and ContentDocument.Title = 'sketch.jpeg' WITH SECURITY_ENFORCED LIMIT 1];
        
        if(ContentDocumentLinkList.size() > 0)
        {
            documentList=[SELECT id, Title, ContentDocumentId, ContentDocument.id,ContentDocument.LatestPublishedVersionId 
                          FROM ContentVersion WHERE ContentDocumentId =: ContentDocumentLinkList[0].ContentDocumentId WITH SECURITY_ENFORCED LIMIT 1];
            contentId= documentList[0].id;
        }   
        
        //Site Icons
        Set<Id> siteDocId = new Set<Id>();
        List<ContentDocumentLink> siteiconlist=new List<ContentDocumentLink>();
        siteiconlist=[SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink
                      WHERE LinkedEntityId =: dcfRecordId and ContentDocument.Title like '%Site%' WITH SECURITY_ENFORCED];
        if(siteiconlist.size() > 0){
            
            for(ContentDocumentLink sd:siteiconlist){
                siteDocId.add(sd.ContentDocumentId );                                               
            }
            
            for(ContentVersion cv: [SELECT id, Title, ContentDocumentId, ContentDocument.id,ContentDocument.LatestPublishedVersionId 
                                    FROM ContentVersion WHERE ContentDocumentId IN: siteDocId  WITH SECURITY_ENFORCED]){
                                        siteIds.add(cv.Id);
                                    }
        }
        
        
        //Photo Capture
        Set<Id> photoDocId = new Set<Id>();
        List<ContentDocumentLink> photoiconlist=new List<ContentDocumentLink>();
        photoiconlist=[SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId,SystemModstamp FROM ContentDocumentLink
                       WHERE LinkedEntityId =: dcfRecordId and ContentDocument.Title like '%Photo%' WITH SECURITY_ENFORCED ORDER BY SystemModstamp DESC limit 3];
        if(photoiconlist.size()>0){
            for(ContentDocumentLink pd: photoiconlist){
                photoDocId.add(pd.ContentDocumentId );                                               
            }
            
            for(ContentVersion cv: [SELECT id, Title, ContentDocumentId, ContentDocument.id,ContentDocument.LatestPublishedVersionId 
                                    FROM ContentVersion WHERE ContentDocumentId IN: photoDocId WITH SECURITY_ENFORCED]){
                                        photoIds.add(cv.Id);
                                    }
        }
        List<ContentDocumentLink> cdlink=new List<ContentDocumentLink>();    
        Set<id> cdocid=new Set<id>();
        //ContentDocumentLink cdlink=new ContentDocumentLink();
        cdlink= [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink
                 WHERE LinkedEntityId =: dcfRecordId and ContentDocument.Title like '%Banner%' WITH SECURITY_ENFORCED];
        if(cdlink.size() > 0){
            for(ContentDocumentLink bd: cdlink){
                cdocid.add(bd.ContentDocumentId );                                               
            }  
            for(ContentVersion cv: [SELECT id, Title, ContentDocumentId, ContentDocument.id,ContentDocument.LatestPublishedVersionId 
                                    FROM ContentVersion WHERE ContentDocumentId IN:cdocid  WITH SECURITY_ENFORCED]){
                                        bannerIds.add(cv.Id);
                                        
                                        
                                    }
            cversionId=bannerIds[0];
            system.debug('cversionId id of banner'+cversionId);
        }
        
        
    }
    
}
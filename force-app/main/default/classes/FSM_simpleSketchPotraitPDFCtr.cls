public class FSM_simpleSketchPotraitPDFCtr {
 public String woId {get;set;}
   
    //public ServiceAppointment serviceAppointmentObj{get;set;}
   
    
    public String pdfNo{get;set;}
    public String efNo{get;set;}
    public boolean show{get;set;}
    public boolean showpdf{get;set;}
    //public ApexPages.PageReference page2{get;set;}
    //public String imageURL{get;set;}
    public String username{get;set;}
    public String contentId{get;set;}
    public List<Id> siteIds {get;set;}
    public List<Id> photoIds {get;set;}
        
    public FSM_simpleSketchPotraitPDFCtr(){
        
   
        Id userId =UserInfo.getUserId(); 
        User u = [SELECT Name FROM User WHERE Id =: userId];
        username=u.Name;
        woId = ApexPages.currentPage().getParameters().get('recId');
    }
    
    /*
      @method: pdfAction
      @comments: creates the PDF
    */
    public void pdfAction()
    {
        siteIds = new List<Id>();
        photoIds = new List<Id>();
        woId = ApexPages.currentPage().getParameters().get('recId');
        system.debug('mobile rec id'+woId);
        List<ContentVersion> documentList = new List<ContentVersion>();
      
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();    
        
        ContentDocumentLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId, Visibility, IsDeleted, ShareType,
                                    ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                                   FROM ContentDocumentLink WHERE LinkedEntityId =: woId and ContentDocument.Title = 'sketch.jpeg' WITH SECURITY_ENFORCED LIMIT 1];
        
        if(ContentDocumentLinkList.size() > 0)
        {
            documentList=[SELECT id, Title, ContentDocumentId, ContentDocument.id,ContentDocument.LatestPublishedVersionId 
                          FROM ContentVersion WHERE ContentDocumentId =: ContentDocumentLinkList[0].ContentDocumentId WITH SECURITY_ENFORCED LIMIT 1];
            contentId= documentList[0].id;
        }   
        
        //Site Icons
        Set<Id> siteDocId = new Set<Id>();
        for(ContentDocumentLink sd: [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink
                                                        WHERE LinkedEntityId =: woId  and ContentDocument.Title like '%Site%' WITH SECURITY_ENFORCED]){
            siteDocId.add(sd.ContentDocumentId );                                               
        }

        for(ContentVersion cv: [SELECT id, Title, ContentDocumentId, ContentDocument.id,ContentDocument.LatestPublishedVersionId 
                      FROM ContentVersion WHERE ContentDocumentId IN: siteDocId  WITH SECURITY_ENFORCED]){
            siteIds.add(cv.Id);
        }
        
        //Photo Capture
        Set<Id> photoDocId = new Set<Id>();
        for(ContentDocumentLink pd: [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink
                                                        WHERE LinkedEntityId =: woId and ContentDocument.Title like '%Photo%' WITH SECURITY_ENFORCED]){
            photoDocId.add(pd.ContentDocumentId ); 
            system.debug('photos'+photoDocId);
        }

        for(ContentVersion cv: [SELECT id, Title, ContentDocumentId, ContentDocument.id,ContentDocument.LatestPublishedVersionId 
                      FROM ContentVersion WHERE ContentDocumentId IN: photoDocId WITH SECURITY_ENFORCED]){
            photoIds.add(cv.Id);
                          system.debug('photos'+photoIds);
        }
        
      //return null;
    }
}
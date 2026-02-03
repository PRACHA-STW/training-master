/*@author: Alagar
@Date: 12/07/23
@comments: This creates the PDF temoplate
*/
public with sharing class FSM_sketchPDFCtr {
    
    public String dcfRecordId  {get;set;}
    public string bannerImageURL { get; set; }
    //public ServiceAppointment serviceAppointmentObj{get;set;}
    public FSM_DataCaptureFormInfra__c dcfObj {get;set;}
    
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
    public string restrictedDays{get;set;}
    public string restrictedTimes{get;set;}
    public string positionOfWork{get;set;}
    public list<FSM_DCFLineItemInfra__c> allLineItems {get;set;}
    public list<FSM_DCFLineItemInfra__c> allLineItems1 {get;set;}
    
    /*
@method: constructor
@comments: constructor function
*/
    public FSM_sketchPDFCtr(){}
    
    /*
@method: FSM_sketchPDFCtr
@comments: constructor function
*/
    public FSM_sketchPDFCtr(ApexPages.StandardController controller){
        
        //SFS-5401 - get current date and Address
        currDate = Date.Today();
        Date d = Date.today();
        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
        dateString = dt.format('dd-MM-yyyy');
        
        /*bannerImageURL  = PageReference.forResource('FSM_SketchBanner').getUrl();
system.debug(bannerImageURL);

bannerImageURL = (Test.isRunningTest() ? 'test data' : bannerImageURL.subString(0, bannerImageURL.indexOf('?')) );*/
        //bannerImageURL = bannerImageURL.subString(0, bannerImageURL.indexOf('?'));
        Id userId =UserInfo.getUserId(); 
        // User u = [SELECT Name,MobilePhone FROM User WHERE Id =: userId];
        List<ServiceResource> sr=[Select FSM_Phone__c,Name from ServiceResource where RelatedRecordId=:userId Limit 1 ];
        if (!sr.isEmpty()) {
            phoneNumber = sr[0].FSM_Phone__c;
            username=sr[0].Name;
        }
        
        dcfRecordId = ApexPages.currentPage().getParameters().get('id');
        //contentId = ApexPages.currentPage().getParameters().get('docId');
        //System.debug('content id --> ');
        ////Schema.SObjectType.FSM_DataCaptureForm__c.fields.FSM_Comments__c.isAccessible()
        /* dcfObj = [Select Id,Name,FSM_WorkOrder__r.Workordernumber, FSM_GridRefOfProposedWorkX__c, FSM_GridRefOfProposedWorkY__c, FSM_CommentsForTheGangs__c, FSM_OccupiersName__c,
FSM_OccupiersHouseNo__c,FSM_OccupiersHouseName__c, FSM_OccupiersStreet__c,FSM_OccupiersTown__c,FSM_OccupiersPostcode__c,FSM_OccupiersTelephoneNumber__c,
FSM_Asset__c, FSM_Task__c, FSM_Technique__c,FSM_AssetSize__c,FSM_AssetMaterial__c,FSM_MethodOfWork__c,FSM_FootwayWidth__c,FSM_CarriagewayWidth__c,FSM_Speed__c,
FSM_RoadType__c,FSM_SurfaceType__c,FSM_TrafficFlow__c, FSM_VehiclePosition__c,FSM_PedestrianWalkway__c,FSM_SpecialFeature__c,FSM_VisibilityToMenAtWork__c,
FSM_TrafficLightsLessThan50m__c,FSM_TrainOrTram__c,FSM_Bus__c,FSM_Cycle__c,FSM_RestrictedTime__c,FSM_ReasonForFirstTimeReinstatement__c,FSM_TrailerTeam__c,
FSM_LetterWarn__c,FSM_SensitiveCustomer__c,FSM_Contamination__c,FSM_SchedulingCommentsBox__c
From FSM_DataCaptureFormInfra__c Where Id =: dcfRecordId ];*/
        dcfObj = [Select Id,Name,FSM_WorkOrder__r.Workordernumber, FSM_GridRefOfProposedWorkX__c, FSM_GridRefOfProposedWorkY__c, FSM_CommentsForTheGangs__c, FSM_OccupiersName__c,
                  FSM_OccupiersHouseNo__c,FSM_OccupiersHouseName__c, FSM_OccupiersStreet__c,FSM_OccupiersTown__c,FSM_OccupiersPostcode__c,FSM_OccupiersTelephoneNumber__c,FSM_MeterReading__c,FSM_ResidentialStatus__c,
                  toLabel(FSM_Asset__c), toLabel(FSM_Task__c), toLabel(FSM_Technique__c),toLabel(FSM_AssetSize__c),toLabel(FSM_AssetMaterial__c),FSM_MethodOfWork__c,FSM_FootwayWidth__c,FSM_CarriagewayWidth__c,FSM_Speed__c,
                  FSM_RoadType__c,FSM_SurfaceType__c,FSM_TrafficFlow__c, FSM_VehiclePosition__c,FSM_PedestrianWalkway__c,FSM_SpecialFeature__c,FSM_VisibilityToMenAtWork__c,FSM_LibraryTimeExtensions__c,FSM_ESTLocationX__c,
                  FSM_TrafficLightsLessThan50m__c,FSM_TrainOrTram__c,FSM_Bus__c,FSM_Cycle__c,FSM_RestrictedTime__c,FSM_ReasonForFirstTimeReinstatement__c,FSM_TrailerTeam__c,FSM_PedestrianLights__c,FSM_ESTLocationY__c,
                  FSM_Friday__c, FSM_Monday__c, FSM_Saturday__c, FSM_Sunday__c, FSM_Thursday__c, FSM_Tuesday__c, FSM_Wednesday__c,FSM_LeakLocation__c,FSM_VisibleLeak__c,FSM_MeterReadingMethod__c,FSM_IsThisASharedSupply__c,
                  FSM_LetterWarn__c,FSM_SensitiveCustomer__c,FSM_Contamination__c,FSM_SchedulingCommentsBox__c,FSM_TypeOfLeak__c,FSM_AreNoWaitingConesRequired__c,FSM_UserName__c,FSM_LeakQuantified__c,FSM_Night__c,FSM_AM__c,FSM_PM__c,
                  FSM_CommsMethod__c,FSM_LampSupportRemovalRequired__c,FSM_OverheadPowerLinesWithin10m__c,FSM_Position__c,FSM_WorkOrder__r.FSM_ExternalId__c,FSM_MeterSerialNo__c,FSM_MeterSerial__c,FSM_MeterSerialNumber__c,
                  FSM_GridsReferenceX__c,FSM_GridsReferenceY__c, FSM_HouseName__c,FSM_HouseNo__c,FSM_Street__c,FSM_Town__c,FSM_PostCode__c,FSM_PlanningInfoAndComms__c,FSM_PermissionToDig__c,
                  FSM_AquaPeaUsed__c,FSM_PostAquaPea__c,FSM_FlowValveFitted__c,FSM_PostFlowValve__c,FSM_Gassing__c,FSM_PipeMIC__c,FSM_AccessRestricted__c,FSM_Carriageway__c,FSM_Verge__c,FSM_BridlewayFootpath__c,FSM_PrivateLand__c,FSM_Footway__c,FSM_Cycleway__c,FSM_PedestrianZone__c
                  
                  From FSM_DataCaptureFormInfra__c Where Id =: dcfRecordId ];
        
        addressFields = dcfObj.FSM_WorkOrder__r.FSM_ExternalId__c!=null ? ' '+dcfObj.FSM_WorkOrder__r.FSM_ExternalId__c: '';
        addressFields +=dcfObj.FSM_OccupiersHouseName__c!=null ? ', '+dcfObj.FSM_OccupiersHouseName__c: '';
        addressFields +=dcfObj.FSM_OccupiersHouseNo__c!= null ? ', '+string.valueOf(dcfObj.FSM_OccupiersHouseNo__c) : '';
        addressFields +=dcfObj.FSM_OccupiersStreet__c!=null ? ', '+dcfObj.FSM_OccupiersStreet__c: '';
        
        restrictedDays = dcfObj.FSM_Monday__c == true ? 'Mon ' : ''; 
        restrictedDays += dcfObj.FSM_Tuesday__c== true ? 'Tue ' : ''; 
        restrictedDays += dcfObj.FSM_Wednesday__c== true ? 'Wed ' : ''; 
        restrictedDays += dcfObj.FSM_Thursday__c== true ? 'Thu ' : ''; 
        restrictedDays += dcfObj.FSM_Friday__c== true ? 'Fri ' : ''; 
        restrictedDays += dcfObj.FSM_Saturday__c== true ? 'Sat ' : ''; 
        restrictedDays += dcfObj.FSM_Sunday__c== true ? 'Sun ' : ''; 
        //added as part of SFS-7660
        restrictedTimes = dcfObj.FSM_AM__c == true ? 'AM ' : ''; 
        restrictedTimes += dcfObj.FSM_PM__c== true ? 'PM ' : ''; 
        restrictedTimes += dcfObj.FSM_Night__c== true ? 'Night ' : '';
        
        positionOfWork =dcfObj.FSM_Carriageway__c== true ? 'Carriageway ' : ''; 
        positionOfWork +=dcfObj.FSM_Verge__c== true ? 'Verge ' : ''; 
        positionOfWork +=dcfObj.FSM_BridlewayFootpath__c== true ? 'Bridleway/ Footpath ' : ''; 
        positionOfWork +=dcfObj.FSM_PrivateLand__c== true ? 'Private Land ' : ''; 
        positionOfWork +=dcfObj.FSM_Footway__c== true ? 'Footway ' : ''; 
        positionOfWork +=dcfObj.FSM_Cycleway__c== true ? 'Cycleway ' : ''; 
        positionOfWork +=dcfObj.FSM_PedestrianZone__c== true ? 'Pedestrianised Zone ' : ''; 
        
        
        allLineItems = [select FSM_CustomerName__c,FSM_GridRefX__c,FSM_GridRefY__c,FSM_ContactNumber__c, FSM_ResidentialStatus__c, FSM_Address__c, FSM_ContactWithCustomer__c,FSM_CanISTBeIsolated__c from FSM_DCFLineItemInfra__c where FSM_DataCaptureFormInfra__r.id =: dcfRecordId order by createddate desc LIMIT 2];
          allLineItems1 = [select FSM_CustomerName__c,FSM_GridRefX__c,FSM_GridRefY__c,FSM_ContactNumber__c, FSM_ResidentialStatus__c, FSM_Address__c, FSM_ContactWithCustomer__c,FSM_CanISTBeIsolated__c from FSM_DCFLineItemInfra__c where FSM_DataCaptureFormInfra__r.id =: dcfRecordId Limit 10];
        //dcfObj.FSM_OccupiersHouseName__c; //+','+dcfObj.FSM_OccupiersHouseNo__c+','+dcfObj.FSM_OccupiersStreet__c;
        
        /* if (Schema.SObjectType.FSM_DataCaptureForm__c.isAccessible() &&
Schema.SObjectType.FSM_DataCaptureForm__c.fields.Id.isAccessible() &&
Schema.SObjectType.FSM_DataCaptureForm__c.fields.Name.isAccessible() &&
Schema.SObjectType.FSM_DataCaptureForm__c.fields.FSM_GridRefX__c.isAccessible() &&
Schema.SObjectType.FSM_DataCaptureForm__c.fields.FSM_GridRefY__c.isAccessible() &&            
Schema.SObjectType.FSM_DataCaptureForm__c.fields.FSM_WorkCentre__c.isAccessible() ){
dcfObj = [Select Id,Name,FSM_WorkOrder__r.Workordernumber, FSM_GridRefX__c,FSM_GridRefY__c, FSM_WorkCentre__c,FSM_Comments__c 
From FSM_DataCaptureForm__c Where Id =: MstrId WITH SECURITY_ENFORCED];
} */
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
        photoiconlist=[SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink
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
        
        //     id cdocid;
        //cdocid=cdlink.ContentDocumentId;
        //system.debug('cd id of banner'+cdocid);
        //if(cdocid != null || cdocid != undefined){
        
        //ContentVersion cversion=[SELECT id, Title, ContentDocumentId, ContentDocument.id,ContentDocument.LatestPublishedVersionId 
        // FROM ContentVersion WHERE ContentDocumentId =:cdocid  WITH SECURITY_ENFORCED];
        
        
        
        
        
        // }
        
        
        
        
        //return null;
    }
    
}
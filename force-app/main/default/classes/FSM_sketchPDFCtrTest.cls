/**
 * @description  : Test class for FSM_sketchPDFCtr. 
 **/
@isTest
public class FSM_sketchPDFCtrTest {
    
    /**
 * @description  : Test method for PDF template creation of FSM_sketchPDFCtr. 
 **/
    @isTest 
    private static void testPDFAction() {
        
        //Create DCF record
        //Create Data Capture Form Record
        FSM_DataCaptureFormInfra__c dcfRec = new FSM_TestDataFactory.DataCaptureFormInfraCreator().setGridReference('250000').returnWithoutCreate();
        insert dcfRec ;
        
        //Create Contentversion record
        ContentVersion content=new ContentVersion(); 
        content.Title='sketch.jpeg'; 
        content.PathOnClient='/' + content.Title; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        //Create ContentDcoument link record
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=dcfRec.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
         ContentVersion cv=new ContentVersion(); 
        cv.Title='Banner.jpeg'; 
        cv.PathOnClient='/' + cv.Title; 
        Blob bannerBlob=Blob.valueOf('Unit Test banner Body'); 
        cv.VersionData=bannerBlob; 
        //content.LinkedEntityId=sub.id;
        cv.origin = 'H';
        insert cv;
        
  ContentDocumentLink cdlink=new ContentDocumentLink();
        cdlink.LinkedEntityId=dcfRec.id;
        cdlink.contentdocumentid=[select contentdocumentid from contentversion where id =: cv.id].contentdocumentid;
        cdlink.ShareType = 'I';
        cdlink.Visibility = 'AllUsers'; 
        insert cdlink;        
        
          ContentVersion photo=new ContentVersion(); 
        photo.Title='Photo1.jpeg'; 
        photo.PathOnClient='/' + photo.Title; 
        Blob bodyBlob1=Blob.valueOf('Unit Test ContentVersion Body'); 
        photo.VersionData=bodyBlob1; 
        //content.LinkedEntityId=sub.id;
        photo.origin = 'H';
        insert photo;
        
         ContentDocumentLink cdlink1=new ContentDocumentLink();
        cdlink1.LinkedEntityId=dcfRec.id;
        cdlink1.contentdocumentid=[select contentdocumentid from contentversion where id =: photo.id].contentdocumentid;
        cdlink1.ShareType = 'I';
        cdlink1.Visibility = 'AllUsers'; 
        insert cdlink1; 
        
        
         ContentVersion site=new ContentVersion(); 
        site.Title='Site1.jpeg'; 
        site.PathOnClient='/' + site.Title; 
        Blob sitebody=Blob.valueOf('Unit Test ContentVersion Body'); 
        site.VersionData=sitebody; 
        //content.LinkedEntityId=sub.id;
        site.origin = 'H';
        insert site;
        
         ContentDocumentLink cdlink2=new ContentDocumentLink();
        cdlink2.LinkedEntityId=dcfRec.id;
        cdlink2.contentdocumentid=[select contentdocumentid from contentversion where id =: site.id].contentdocumentid;
        cdlink2.ShareType = 'I';
        cdlink2.Visibility = 'AllUsers'; 
        insert cdlink2; 
        
        
        
        PageReference pageRef = Page.FSM_SketchPDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',dcfRec.id);
        ApexPages.currentPage().getParameters().put('docId',content.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(dcfRec);
        Test.startTest();
        FSM_sketchPDFCtr ctr = new FSM_sketchPDFCtr(sc);
        ctr.pdfAction();
        ctr.pdfNo = '1';
        ctr.efNo = '1';
        ctr.show = false;
        ctr.showpdf = false;
        Test.stopTest();
        FSM_sketchPDFCtr ctr1 = new FSM_sketchPDFCtr();
        //System.assertEquals(dcfRec.id, ctr.mstrId, 'Template created');
        System.assertEquals(content.id, ctr.contentId, 'ContentDocumentLink created successfully');
        
    }
}
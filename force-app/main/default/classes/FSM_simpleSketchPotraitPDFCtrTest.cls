@isTest(SeeAllData=false)
/**
* @description  : Test class for FSM_simpleSketchPotraitPDFCtr. 
**/
public class FSM_simpleSketchPotraitPDFCtrTest {
    @isTest 
    private static void testPDFAction() {
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        List<OperatingHours> listOp = new List<OperatingHours>();
        OperatingHours op = new FSM_TestDataFactory.OperatingHoursCreator().setName('AM/Pm Operating Hours').setBusinessUnit('Developer Services').returnWithoutCreate(); //.setSlotType('AM')
        listOp.add(op);
        op = new FSM_TestDataFactory.OperatingHoursCreator().setName('2 hours Operating Hours').setBusinessUnit('Developer Services').returnWithoutCreate(); //.setSlotType('2 hour')
        listOp.add(op);
        insert listOp;
        //Create Service Territory
        ServiceTerritory st = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('7203D02 Small Developer West Gangs').setBusinessUnit('Developer Services').setIsActive(true).setExtenalId('888999')
            .setOpreratingHours(listOp[0].Id).create();
        //Create Workorder
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Developer Services').setRecordType(recTypeId).setgeneratepdf(false).setServiceTerritory(st.Id).setpdfFilename('testsimplesketchpdf').setdeviceType('Mobile').create();
        Double latitudeValue = 52.41;
        Double longitudeValue = -1.50;
        
        ID saRecordTypeID= Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
        //Create ServiceAppointment and assign it to workorder
        ServiceAppointment sa=new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('NEW').setRecordType(saRecordTypeID)
            .setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
            .setLongitude(longitudeValue).setServiceTerritory(st.Id).create();
        
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
        contentlink.LinkedEntityId=wo.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ContentVersion photo=new ContentVersion(); 
        photo.Title='Photo1.jpeg'; 
        photo.PathOnClient='/' + photo.Title; 
        Blob bodyBlob1=Blob.valueOf('Unit Test ContentVersion Body'); 
        photo.VersionData=bodyBlob1; 
        //content.LinkedEntityId=sub.id;
        photo.origin = 'H';
        insert photo;
        
        ContentDocumentLink cdlink1=new ContentDocumentLink();
        cdlink1.LinkedEntityId=wo.id;
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
        cdlink2.LinkedEntityId=wo.id;
        cdlink2.contentdocumentid=[select contentdocumentid from contentversion where id =: site.id].contentdocumentid;
        cdlink2.ShareType = 'I';
        cdlink2.Visibility = 'AllUsers'; 
        insert cdlink2; 
        
        PageReference pageRef = Page.FSM_simpleSketchPotraitPDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('recId',wo.id);
        //ApexPages.currentPage().getParameters().put('docId',content.id);
        
        // ApexPages.StandardController sc = new ApexPages.StandardController(dcfRec);
        Test.startTest();
        FSM_simpleSketchPotraitPDFCtr ctr = new FSM_simpleSketchPotraitPDFCtr();
        ctr.pdfAction();
        ctr.pdfNo = '1';
        ctr.efNo = '1';
        ctr.show = false;
        ctr.showpdf = false;
        Test.stopTest();
        FSM_simpleSketchPotraitPDFCtr ctr1 = new FSM_simpleSketchPotraitPDFCtr();
        //System.assertEquals(dcfRec.id, ctr.mstrId, 'Template created');
        System.assertEquals(content.id, ctr.contentId, 'ContentDocumentLink created successfully');
    }
}
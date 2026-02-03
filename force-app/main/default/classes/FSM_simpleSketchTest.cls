/*@author: Aishwarya Bhosale
@Date: 23/01/24
@Modified:24-04-2024
@comments: this is test class for FSM_simpleSketchCls

*/
@isTest(SeeAllData=false)
public class FSM_simpleSketchTest {
    @TestSetup
    static void testDataSetup(){
        Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
        Double latitudeValue = 52.41;
        Double longitudeValue = -1.50;
        
        // Create a test WorkOrder data
        WorkOrder wo = new FSM_TestDataFactory.WorkOrderCreator().setBusinessUnit('Developer Services').setRecordType(recTypeId).setgeneratepdf(false).setpdfFilename('testsimplesketchpdf').setdeviceType('Mobile').create();
        Account acc=new FSM_TestDataFactory.AccountCreator().setName('test acc').create();
        Contact con=new FSM_TestDataFactory.ContactCreator().setFirstName('test').setLastName('testsurname').setAccount(acc.id).setEmail('no-reply@defaultemail.com').create();
        
        //Get ServiceAppointment RecordType Id
        Id saRecTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get(FSM_Constants.RECORDTYPE_DEVELOPERSERVICES).getRecordTypeId();
        
        // Create a Test ServiceAppointment
        ServiceAppointment testSA = new FSM_TestDataFactory.ServiceAppointmentCreator().setRecordType(saRecTypeId)
            .setParentRecordId(wo.Id).setStatus('New').setEarliestStartTime(System.today()-10).setDueDate(System.today()+10).setLatitude(latitudeValue)
            .setLongitude(longitudeValue).create();
        
        //Create Contentversion record
        ContentVersion content=new ContentVersion(); 
        content.Title='sketch.jpeg'; 
        content.PathOnClient='/' + content.Title; 
        content.FSM_Sketch_Additional_Images__c=true;
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
        photo.FSM_Sketch_Additional_Images__c=true;
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
        site.FSM_Sketch_Additional_Images__c=true;
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
    }
    @isTest
    public static void testmobilepdf() {   
        WorkOrder wo = [SELECT Id,FSM_FileName__c FROM WorkOrder where FSM_FileName__c='testsimplesketchpdf' LIMIT 1];
        String recId = wo.Id;
        Test.startTest();
        FSM_simpleSketchCls.pdfCreation(recId);
        Test.stopTest();
    }
    @isTest
    public static void testdesktoppdf() {   
        WorkOrder wo = [SELECT Id,FSM_DeviceType__c,FSM_FileName__c FROM WorkOrder where FSM_FileName__c='testsimplesketchpdf' LIMIT 1];
        
        wo.FSM_DeviceType__c='Desktop';
        update wo;
        String recId = wo.Id;
        Test.startTest();
        FSM_simpleSketchCls.pdfCreation(recId);
        Test.stopTest();
    }  
}
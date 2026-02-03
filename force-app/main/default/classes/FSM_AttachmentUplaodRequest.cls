/********************************************************************************************************
@Author      : Srikanth Palla
@description : This class is used to create request for callout.
@description : Created as part of user story #SFI-1213
@description  Invoked from FSM_ContentDocumentLinkTriggerHelper class
@Test Class  : FSM_ContentDocLinkTriggerTest
@Date        : 02-April-2024
********************************************************************************************************/
public with sharing class FSM_AttachmentUplaodRequest {
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  This method used to create request for callout.
	@description  Updated As part of SFI-2208 by Asutosh Singh 21st June 24
    @param  req
    @Date        : 02-April-2024
    ********************************************************************************************************/
    public string createReqBody(FSM_SendUploadAttachmentsQueueable.RequestData req){
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode envelopeNode = doc.createRootElement('Envelope', 'http://schemas.xmlsoap.org/soap/envelope/', 'soapenv');
        envelopeNode.setAttribute('xmlns:glob', 'http://sap.com/xi/SAPGlobal20/Global');
        
        // Add Header
        Dom.XmlNode headerNode = envelopeNode.addChildElement('soapenv:Header', null, null);
        
        // Add Body
        Dom.XmlNode bodyNode = envelopeNode.addChildElement('soapenv:Body', null, null);
        Dom.XmlNode documentRequestNode = bodyNode.addChildElement('glob:DocumentERPCreateRequest_sync_V1', null, null);
        
        // Add Document
        Dom.XmlNode documentNode = documentRequestNode.addChildElement('Document', null, null);
        
        // Add TypeCode
        Dom.XmlNode typeCodeNode = documentNode.addChildElement('TypeCode', null, null);
        typeCodeNode.setAttribute('listID', req.vendorNumber!=NULL ? req.vendorNumber : '');
        typeCodeNode.setAttribute('listAgencyID', req.woOperation!=NULL ? req.woOperation : '');
        typeCodeNode.setAttribute('listVersionID', req.woNumber!=NUll ? req.woNumber : '');
        typeCodeNode.addTextNode('ZFM');
        
        // Add CategoryCode
        Dom.XmlNode categoryCodeNode = documentNode.addChildElement('CategoryCode', null, null);
        categoryCodeNode.addTextNode('2');
        
        // Add Description
        Dom.XmlNode descriptionNode = documentNode.addChildElement('Description', null, null);
        descriptionNode.addTextNode(req.fileDescription!=NULL ? req.fileDescription :'');
        
        // Add ComputerAidedDesignDrawing
        Dom.XmlNode cadNode = documentNode.addChildElement('ComputerAidedDesignDrawing', null, null);
        cadNode.addTextNode('false');
        
        // Add FileVariant
        Dom.XmlNode fileVariantNode = documentNode.addChildElement('FileVariant', null, null);
        
        //Add DocumentFormatCode
        Dom.XmlNode formatCodeNode = fileVariantNode.addChildElement('DocumentFormatCode', null, null);
        formatCodeNode.setAttribute('listAgencySchemeID', req.versionId!=NULL ? req.versionId :''); //SFI-2208
        formatCodeNode.addTextNode(req.fileType);
        
        //Add DocumentPathName
        Dom.XmlNode pathNameNode = fileVariantNode.addChildElement('DocumentPathName', null, null);
        pathNameNode.addTextNode(req.filePath);
        
        //Add DocumentRepositoryCode
        Dom.XmlNode repositoryCodeNode = fileVariantNode.addChildElement('DocumentRepositoryCode', null, null);
        repositoryCodeNode.addTextNode('ZDMS_WFM');
        
        //Add BinaryObject
        Dom.XmlNode binaryObjectNode = fileVariantNode.addChildElement('BinaryObject', null, null);
        binaryObjectNode.setAttribute('format', req.fileType);
        binaryObjectNode.setAttribute('fileName', req.fileName);
        binaryObjectNode.addTextNode('[[VersionDataToBeReplaced]]'); //Updated as part of SFI-2585, by Subir Maji 5th Aug 24, to reduce heap size we are adding the node and will be replaced by Version data later on
        
        // Add ObjectReference
        Dom.XmlNode objectReferenceNode = documentNode.addChildElement('ObjectReference', null, null);
        Dom.XmlNode refObjectIdNode = objectReferenceNode.addChildElement('ReferenceObjectID', null, null);
        refObjectIdNode.setAttribute('schemeID',req.sapUserId);
        refObjectIdNode.addTextNode(req.referenceObject!=NULL ?req.referenceObject: '' );
        Dom.XmlNode refObjectTypeNode = objectReferenceNode.addChildElement('ReferenceObjectTypeCode', null, null);
        refObjectTypeNode.addTextNode('SMQMEL');
        
        // Add Status SFI-2208
        Dom.XmlNode statusNode = documentNode.addChildElement('Status', null, null);
        Dom.XmlNode codeNode = statusNode.addChildElement('Code', null, null);
        codeNode.addTextNode('WR');//SFI-1214
        String xmlString = doc.toXmlString();
        //Updated as part of SFI-2585, by Subir Maji 5th Aug 24,
        //This is used againest salesforce best practice, but needed to avoid heap size limit for files.
        //Assumption is based on functional requirement not more than 50 file will be uploaded at once, also max size will be 5 mb per file.
        ContentVersion cv = [SELECT Id, VersionData, ContentDocumentId 
                             FROM ContentVersion 
                             WHERE ContentDocumentId =: req.versionData WITH SECURITY_ENFORCED Limit 1];
        xmlString = xmlString.replace('[[VersionDataToBeReplaced]]', EncodingUtil.base64Encode(cv.VersionData));
        cv = null;
        return xmlString;
    }
}
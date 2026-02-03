/********************************************************************************************************
@Author      : Srikanth Palla
@Description : This class serves as a mock implementation designed to simulate HTTP callouts during attachment uploads.
@description  Created as part of user story #SFI-1213
@Date        : 22-April-2024
********************************************************************************************************/
@isTest
public class FSM_AttachmentUploadCalloutMock implements HttpCalloutMock{
 
    /********************************************************************************************************
    @Author      : Srikanth Palla
    @description  Respond method to simulate the HTTP response based on the request body.
    @param req The HTTPRequest object representing the request being made.
    @return HTTPResponse The HTTPResponse object representing the response to the request with status code as 200.
    *********************************************************************************************************/
    public HTTPResponse respond(HTTPRequest req) {
        // Create a new HTTPResponse object
        HTTPResponse res = new HTTPResponse();
        // If false, construct a SOAP response XML.
        String responseXml = '<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">'+
            '<SOAP:Header/>'+
            '<SOAP:Body xmlns:glob="http://sap.com/xi/SAPGlobal20/Global">'+
            '<nm:DocumentERPCreateConfirmation_sync_V1 xmlns:nm="http://sap.com/xi/SAPGlobal20/Global" xmlns:prx="urn:sap.com:proxy:DPE:/1SAI/TAE7384CBF7F9A2D6436F82:702">'+
            '<Document>'+
            '<Name>902612809</Name>'+
            '<TypeCode listID="105616" listVersionID="11746849" listAgencyID="30">ZPO</TypeCode>'+
            '<TypeName>WFM Portal Documents</TypeName>'+
            '<AlternativeDocumentID>000</AlternativeDocumentID>'+
            '<VersionID>00</VersionID>'+
            '<SystemAdministrativeData>'+
            '<CreationDateTime>2024-03-28T11:17:04Z</CreationDateTime>'+
            '<CreationUserAccountID>BASIS</CreationUserAccountID>'+
            '</SystemAdministrativeData>'+
            '</Document>'+
            '<Log>'+
            '<Item>'+
            '<TypeID>077(DMS_MESSAGES)</TypeID>'+
            '<SeverityCode>1</SeverityCode>'+
            '<Note>Document 902612809/ZPO/00/000 created successfully</Note>'+
            '</Item>'+
            '</Log>'+
            '</nm:DocumentERPCreateConfirmation_sync_V1>'+
            '</SOAP:Body>'+
            '</SOAP:Envelope>';
        
        // Set the response body with the constructed SOAP response XML
        res.setBody(responseXml);
        // Set the response status code to 200
        res.setStatusCode(200);
        // Return the HTTPResponse object
        return res;
    }
}
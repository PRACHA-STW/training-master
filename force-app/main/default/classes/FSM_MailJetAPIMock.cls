/********************************************************************************************************
@Author      : Asutosh Singh
@Description : This class serves as a mock implementation designed to simulate HTTP callouts during Mailjet API Call.
@description : Created as part of user story #SFI-1821
@Date        : 31-May-2024
********************************************************************************************************/
@isTest
Public class FSM_MailJetAPIMock implements HttpCalloutMock {
    /********************************************************************************************************
    @Author      : Asutosh Singh
    @description : Respond method to simulate the HTTP response based on the request body.
    @param req   : The HTTPRequest object representing the request being made.
    @return HTTPResponse The HTTPResponse object representing the response to the request with status code as 200.
    *********************************************************************************************************/
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Messages":[{"Status":"success"}]}');
        res.setStatusCode(200);
        return res;
    }
}
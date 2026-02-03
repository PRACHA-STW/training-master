/**********************************************************************************************************
@Author      : Subir Maji
@Description : This Class is going to build JSON and Send Rest API call for Mailjet.
@Description : Created as part of user story #SFI-1821
@Test Class  : FSM_MailJetAPICallTest
@Date        : 24-May-2024
********************************************************************************************************/
public with sharing Class FSM_MailJetAPICall {
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is invocable method getting called from flows.
    @Description : Created as part of user story #SFI-1821
    @Date        : 24-May-2024
	@Date		 : Updated by Subir Maji 4th July 24 SFI-2346
    ********************************************************************************************************/ 
    @InvocableMethod(label = 'MailJetAPI')
    public static void jsonGenerator(List<MailJetInputParam> mailJetInputs){
        String businessUnitTemplateUniqueKey; //to hold the unique key temporarely
        Set<String> businessUnit = new Set<String>(); //collect all BU
        Set<String> templateName = new Set<String>(); //Collect all template name
        MAP<String, String> templateNameTemplateIDMap = new MAP<String, String>(); //Map of template name and id
        MAP<String, String> templateNameWelshTemplateIDMap = new MAP<String, String>(); //Map of template name and id for Welsh
        MAP<String, List<String>> businessUnitTemplateUniqueKeyFields = new MAP<String, List<String>>();//Map of unique key based on BU and template name and Field under that combination
		MAP<String, List<String>> businessUnitAndTemplateUniqueKey = new MAP<String, List<String>>();//Map of Business Unit and unique key, added by Subir Maji 4th July 24 SFS-8124
        List<FSM_LeafletIntegrationConfiguration__mdt> mailJetData; //to get all relavant Custom metadata record
		List<FSM_LeafletIntegrationConfiguration__mdt> mailJetDataGeneric = new List<FSM_LeafletIntegrationConfiguration__mdt>(); //to Collect all relavant Custom metadata record Generic
        ServiceAppointment servApp; // Single Service Appointment record
        MAP<String, String> taskIDJsonStringBodyMap; //Based on Task have JSON Body
        String customerName; //Added as part of SFS-8124 By Subir Maji 6th Nov 24 to collect teh customer name
        
		//All Wrapper class Initiation
		Cls_Messages singleMessage;
        List<Cls_Messages> messagesList;
        Cls_ALLMessages messagesFormat;
        Cls_From from1 = new Cls_From();
        from1.Email = System.Label.FSM_MailjetDefaultFromAddress; //Fixed from Address
        from1.Name = System.Label.FSM_MailjetDefaultFromAddressName; //Fixed From name
        
        Cls_To toEmail;
        List <Cls_To> toEmailList = new List <Cls_To>();
        List <Cls_Bcc> bccEmailList = new List <Cls_Bcc>();
        Cls_Attachments emailAttachment;
        List <Cls_Attachments> emailAttachmentList = new List <Cls_Attachments>();
        MAP<String, String> fieldNameValueMap;
        Set<String> allEmail;
        Integer templateID;
        
        //Preparing maps for data fetch
        for(MailJetInputParam inputs : mailJetInputs){
            businessUnit.add(inputs.businessUnit);
            templateName.add(inputs.templateName);
        }
        
        //Querying Metadata, Updated by Subir Maji 4th July 24 SFS-8124 to Add FSM_IsGeneric__c check
        if(!businessUnit.isEmpty() && !templateName.isEmpty()){
            mailJetData = [SELECT ID, FSM_FieldAPIName__c, FSM_TemplateId__c, FSM_BusinessUnit__c, FSM_TemplateName__c, FSM_IsGeneric__c, FSM_TemplateIDWelsh__c 
                           FROM FSM_LeafletIntegrationConfiguration__mdt
                          WHERE FSM_Active__c = true AND
                          FSM_BusinessUnit__c IN: businessUnit AND 
                          FSM_TemplateName__c IN: templateName WITH SECURITY_ENFORCED];
            mailJetDataGeneric = [SELECT ID, FSM_FieldAPIName__c, FSM_TemplateId__c, FSM_BusinessUnit__c, FSM_TemplateName__c, FSM_IsGeneric__c, FSM_TemplateIDWelsh__c 
                           FROM FSM_LeafletIntegrationConfiguration__mdt
                          WHERE FSM_Active__c = true AND
                          FSM_BusinessUnit__c IN: businessUnit AND 
                          FSM_IsGeneric__c = true WITH SECURITY_ENFORCED];
        }
        
        //If found metadata then go through and populate map
        if(mailJetData != null && !mailJetData.isEmpty()){
            //Adding non generic fields
			for(FSM_LeafletIntegrationConfiguration__mdt mailJet : mailJetData){
                businessUnitTemplateUniqueKey = mailJet.FSM_BusinessUnit__c+mailJet.FSM_TemplateName__c;
				//to create map of Business unit and related forms added by Subir Maji 4th July 24 SFS-8124
				if(!mailJet.FSM_IsGeneric__c){
					templateNameTemplateIDMap.put(mailJet.FSM_TemplateName__c,mailJet.FSM_TemplateId__c);
          			templateNameWelshTemplateIDMap.put(mailJet.FSM_TemplateName__c,mailJet.FSM_TemplateIDWelsh__c);
					if(businessUnitAndTemplateUniqueKey.containsKey(mailJet.FSM_BusinessUnit__c)){
						businessUnitAndTemplateUniqueKey.get(mailJet.FSM_BusinessUnit__c).add(businessUnitTemplateUniqueKey);
					}else{
						businessUnitAndTemplateUniqueKey.put(mailJet.FSM_BusinessUnit__c, new List<String>());
                        businessUnitAndTemplateUniqueKey.get(mailJet.FSM_BusinessUnit__c).add(businessUnitTemplateUniqueKey);
					}
				}
				
                if(mailJet.FSM_FieldAPIName__c != null && !mailJet.FSM_IsGeneric__c){
					if(businessUnitTemplateUniqueKeyFields.containsKey(businessUnitTemplateUniqueKey)){
                        businessUnitTemplateUniqueKeyFields.get(businessUnitTemplateUniqueKey).add(mailJet.FSM_FieldAPIName__c);
                    }else{
                        businessUnitTemplateUniqueKeyFields.put(businessUnitTemplateUniqueKey, new List<String>());
                        businessUnitTemplateUniqueKeyFields.get(businessUnitTemplateUniqueKey).add(mailJet.FSM_FieldAPIName__c);
                    }
                }
            }
        }
		
        //Adding generic fields, added by Subir Maji 4th July 24 SFS-8124
        if(mailJetDataGeneric != null && !mailJetDataGeneric.isEmpty()){
            for(FSM_LeafletIntegrationConfiguration__mdt mailJet : mailJetDataGeneric){
                if(businessUnitAndTemplateUniqueKey.containsKey(mailJet.FSM_BusinessUnit__c)){
					for(String forms : businessUnitAndTemplateUniqueKey.get(mailJet.FSM_BusinessUnit__c)){
						if(businessUnitTemplateUniqueKeyFields.containsKey(forms)){
							businessUnitTemplateUniqueKeyFields.get(forms).add(mailJet.FSM_FieldAPIName__c);
						}else{
							businessUnitTemplateUniqueKeyFields.put(forms, new List<String>());
							businessUnitTemplateUniqueKeyFields.get(forms).add(mailJet.FSM_FieldAPIName__c);
						}
					}
				}
            }
        }
        
		//Prepare the JSOn Body to be send to mailjet
        try{
       		if(mailJetData != null && !mailJetData.isEmpty()){
                taskIDJsonStringBodyMap = new MAP<String, String>();
                fieldNameValueMap = new MAP<String, String>();
                
				//Go through Inputs
                for(MailJetInputParam inputs : mailJetInputs){
                    messagesList = new List<Cls_Messages>();
                    allEmail = new Set<String>();
                    
                    messagesFormat = new Cls_ALLMessages();
                    
                    servApp = inputs.serviceAppointmentRecord;
                    customerName = servApp.FSM_CustomerName__c;//Added as part of SFS-8124 By Subir Maji 6th Nov 24
                    
                    //Setting To details
                    if(servApp.FSM_CustomerEmail__c != null){
                        allEmail.add(servApp.FSM_CustomerEmail__c);
                    }
                    if(servApp.FSM_CustomerEmail1__c != null){
                        allEmail.add(servApp.FSM_CustomerEmail1__c);
                    }
                    if(servApp.FSM_CustomerEmail2__c != null){
                        allEmail.add(servApp.FSM_CustomerEmail2__c);
                    }
                    if(servApp.FSM_CustomerEmail3__c != null){
                        allEmail.add(servApp.FSM_CustomerEmail3__c);
                    }
                    if(servApp.FSM_CustomerEmail4__c != null){
                        allEmail.add(servApp.FSM_CustomerEmail4__c);
                    }
                    if(servApp.FSM_CustomerEmail5__c != null){
                        allEmail.add(servApp.FSM_CustomerEmail5__c);
                    }
                    
                    //Added as part of SFS-8124 By Subir Maji 6th Nov 24 if BCC Email present then send dear customer for all
                    if(servApp.FSM_CustomerEmail1__c != null || servApp.FSM_CustomerEmail2__c != null || servApp.FSM_CustomerEmail3__c != null || servApp.FSM_CustomerEmail4__c != null|| servApp.FSM_CustomerEmail5__c != null){
                        customerName = FSM_Constants.MAILJET_BCC_NAME;
                    }
                    
					//Based on Type set different fields
                    if(inputs.type == 'Leaflets'){ //For Leaflets
                        //Added this part as part of SFS-8124 by Subir Maji 6th Nov 24 to put Different template id based on Language
                        if(inputs.language == 'English' || inputs.language == null || inputs.language == ''){
                            templateID = Integer.valueOf(templateNameTemplateIDMap.get(servApp.FSM_ListOfTemplates__c));//Leaflet template ID English
                        }else{
                            templateID = Integer.valueOf(templateNameWelshTemplateIDMap.get(servApp.FSM_ListOfTemplates__c));//Leaflet template ID Welsh
                        }
                        //Custom dynamic fields value setup
						if(businessUnitTemplateUniqueKeyFields.containsKey(inputs.businessUnitTemplateKey)){
                            for(String field : businessUnitTemplateUniqueKeyFields.get(inputs.businessUnitTemplateKey)){
                                //Added as part of SFS-8124 By Subir Maji 6th Nov 24 so that we can set the Customer name based on email
                                if(servApp.get(field) != null){
                                	if(field == 'FSM_CustomerName__c'){
                                       fieldNameValueMap.put(field,customerName);
                                    }else if(field == 'FSM_SuppInfoURL__c'){ //added as part of SFS-8043 by Subir maji 16th Jan 25
                                        fieldNameValueMap.put(field,'<br>' + String.ValueOf(servApp.get(field)).replaceAll(';', '<br>'));
                                    }else{
                                        fieldNameValueMap.put(field,String.ValueOf(servApp.get(field)));
                                    }
                                }else{ //Added this part as part of SFS-8124 by Subir Maji 6th Nov 24
                                    fieldNameValueMap.put(field,'');
                                }
                            }
                            fieldNameValueMap.put('DateAndTime',String.ValueOf(System.now())); //Updated this part as part of SFS-8124 by Subir Maji 6th Nov 24
                        }
                    }else{ //For Performa
                        templateID = Integer.valueOf(System.Label.FSM_MailjetProformaTemplateID); //Performa have static Template ID
						fieldNameValueMap.put('FSM_SAPWorkorderNumber__c',servApp.FSM_SAPWorkorderNumber__c);//Setting SAP WO Number for Performa, Added as part of SFS-8124 By Subir Maji 6th Nov 24
                        fieldNameValueMap.put('FSM_CustomerName__c', customerName);//Setting Customer Name for Performa, Added as part of SFS-8124 By Subir Maji 6th Nov 24
                        fieldNameValueMap.put('FSM_OperativeName__c',servApp.FSM_OperativeName__c);//Setting Operative Name for Performa, Added as part of SFS-8124 By Subir Maji 6th Nov 24
                        //Set Email Attachments
                        if(inputs.ContentVersionRecord != null){
                            emailAttachment = new Cls_Attachments();
                            if(inputs.ContentVersionRecord.Title.endsWith('.'+inputs.ContentVersionRecord.FileExtension) || inputs.ContentVersionRecord.Title.endsWith('.'+inputs.ContentVersionRecord.FileType)){
                                emailAttachment.Filename = inputs.ContentVersionRecord.Title;
                            }else{
                                emailAttachment.Filename = inputs.ContentVersionRecord.Title +'.'+ inputs.ContentVersionRecord.FileExtension;
                            }
                            emailAttachment.ContentType = inputs.ContentVersionRecord.FileType;
                            emailAttachment.Base64Content = EncodingUtil.base64Encode(inputs.ContentVersionRecord.VersionData);
                            emailAttachmentList.add(emailAttachment);
                        }
                    }
                    
                    //Added as part of SFS-8124 By Subir Maji 6th Nov 24, so that for each mail we can send details separately.
                    for(String checkMail : allEmail){
                        singleMessage = new Cls_Messages();
                        singleMessage.From1 = from1;
                        singleMessage.Bcc = bccEmailList;
                        singleMessage.Attachments = emailAttachmentList;
                        singleMessage.Variables = fieldNameValueMap;
                        singleMessage.TemplateID = templateID;
                        singleMessage.Subject = '';//Setting Subject of Email to blank, Updated as part of SFS-8124 By Subir Maji 6th Nov 24
                        singleMessage = setToEmailstoSingleMessage(checkMail, customerName, singleMessage);
                        messagesList.add(singleMessage);
                    }
                    
                    messagesFormat.Messages = messagesList;
                    taskIDJsonStringBodyMap.put(inputs.taskRecordId, Json.serialize(messagesFormat).replace('From1','From'));
                }
				//Call Future Method
                callMailJetAPI(taskIDJsonStringBodyMap);
            }
            
        }catch(Exception ex){
            //Create one single error log
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_MailJetAPICall').setErrorMessage(ex.getMessage()).setLineNumber(string.valueof(ex.getLineNumber())).setMethodName('JsonGenerator').setStackTrace(ex.getStackTraceString()).setType('Integration').create();
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is invocable Variables getting called from flows.
    @Description : Created as part of user story #SFI-1821
    @Date        : 24-May-2024
    ********************************************************************************************************/ 
    public Class MailJetInputParam{
        @InvocableVariable
        public ServiceAppointment serviceAppointmentRecord;
        
        @InvocableVariable
        public ContentVersion ContentVersionRecord;
        
        @InvocableVariable
        public String taskRecordId;
        
        @InvocableVariable
        public String templateName;
        
        @InvocableVariable
        public String businessUnit;
        
        @InvocableVariable
        public String businessUnitTemplateKey;
        
        @InvocableVariable
        public String type;
        
        @InvocableVariable
        public String language;
    }
	
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is to set the To email list for each email.
	@Description : Created as part of user story #SFI-XXXX
	@param 		 : emailAddress,customerName,singleMessage
	@return		 : Cls_Messages
    @Date        : 20-Nov-2024
    ********************************************************************************************************/ 
    private static Cls_Messages setToEmailstoSingleMessage(String emailAddress, String customerName, Cls_Messages singleMessage){
        List <Cls_To> toEmailList = new List <Cls_To>();
        toEmailList.add(setToEmails(emailAddress, customerName));
        singleMessage.To = toEmailList;
        return singleMessage;
	}
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is to set the To Email details.
	@Description : Created as part of user story #SFI-XXXX
	@param 		 : emailAddress, customerName
	@return		 : Cls_To
    @Date        : 20-Nov-2024
    ********************************************************************************************************/ 
    private static Cls_To setToEmails(String emailAddress, String customerName){
		Cls_To toEmail = new Cls_To();
        toEmail.Email = emailAddress;
        toEmail.Name = customerName;
        return toEmail;
	}
	
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is Future method to do the Mailjet callout.
	@Description : Created as part of user story #SFI-1821
	@param 		 : taskIDJsonStringBodyMap
    @Date        : 24-May-2024
    ********************************************************************************************************/ 
    @future(callout=true)
    public static void callMailJetAPI(MAP<String, String> taskIDJsonStringBodyMap){
        HttpRequest req; //To create single request
		HTTPResponse res; //To create single Response
		Http http; //To call SAP
        String request; //To Hold Whole Request Body
        String response; //To Hold Whole Response Body
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm(); //To get The BAse URL
        List<FSM_IntegrationLog__c> allIeLog = new List<FSM_IntegrationLog__c>(); //Collect All Integration Log
        FSM_IntegrationLog__c ieLog; //Single Integration Log Record
        List<FSM_ErrorLog__c> errorLogList=new List<FSM_ErrorLog__c>(); //Collect All Error Log
        FSM_ErrorLog__c errorLog; //Single Error Log Record
        Task singleTask; //Single Task record
        List<Task> allTaskToUpdate = new List<Task>(); //Collection of all Taks record for update
        
		//Go Through Task ID
		for(String taskId : taskIDJsonStringBodyMap.KeySet()){
            //Initiate veriavle
			req = new HttpRequest();
			http = new Http();
            singleTask = new Task();
            singleTask.Id = taskId;
            
			//Based onBAse URL assign Named Credential
            if(sfdcBaseURL.contains('.sandbox')){
                req.setEndpoint('callout:MailJetNamedCredDev');
            }else{
                req.setEndpoint('callout:MailJetNamedCredProd');
            }
            
			//Set other parts of teh request
            req.setMethod(FSM_Constants.RESTMETHODPOST);
            req.SetBody(taskIDJsonStringBodyMap.get(taskId));
            req.setTimeout(120000);
            
			res = http.send(req);
            
			//Collect request and response Body
            request = taskIDJsonStringBodyMap.get(taskId);
            response = res.toString() + '<br/>'+'Body : '+ res.getBody();
            
			//Create Integration Log
            ieLog = new FSM_Utility.IntegrationLogCreator().setRecordId(taskId)
                .setReqPayload(request.left(32000)).setExternalId(taskId)
                .setResPayload(response.left(32000)).setServiceName('MailJetAPICall').returnWithoutCreate();
            allIeLog.add(ieLog);
            
			//If error than create error log
            if(res.getStatusCode() != 200){
                errorLog=new FSM_Utility.ErrorLogCreator().setClassName('FSM_MailJetAPICall').setMethodName('callMailJetAPI')
                    .setErrorMessage(response.left(32000)).setLineNumber(res.toString()).setExternalID(taskId)
                    .setType('Integration').returnWithoutCreate();
                errorLogList.add(errorLog);
                
                singleTask.Status = 'Failure';
            }else{
                singleTask.Status = 'Success';
            }
            allTaskToUpdate.add(singleTask);
        }
		
		//Do All DML in Try
        try{
			//Integration Log Creation
            if(!allIeLog.isEmpty() && Schema.sObjectType.FSM_IntegrationLog__c.isCreateable()) {
                Insert allIeLog;
            }
            //Error Log Creation
            if(!errorLogList.isEmpty() && Schema.sObjectType.FSM_ErrorLog__c.isCreateable()) {
                Insert errorLogList;
            }
            //Task Status Update
            if(!allTaskToUpdate.isEmpty() && Schema.sObjectType.Task.isUpdateable()) {
                Update allTaskToUpdate;
            }
        }catch(Exception ex){
            //Create one single error log
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_MailJetAPICall').setErrorMessage(ex.getMessage()).setLineNumber(string.valueof(ex.getLineNumber())).setMethodName('callMailJetAPI').setStackTrace(ex.getStackTraceString()).setType('Integration').create();
        }
    }
	
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is Wrapper class for Final Wrap.
    @Description : Created as part of user story #SFI-1821
    @Date        : 24-May-2024
    ********************************************************************************************************/ 
    class Cls_ALLMessages {
		public Cls_Messages[] Messages;
	}
    
	/********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is Wrapper class for wrapping up actual message with from/to/bcc/attachments/variables etc.
    @Description : Created as part of user story #SFI-1821
    @Date        : 24-May-2024
    ********************************************************************************************************/ 
    class Cls_Messages {
		Cls_From From1;
		Cls_To[] To;
		Cls_Bcc[] Bcc;
		String Subject;	//Your email flight plan!
		Integer TemplateID;	//12345
		Cls_Attachments[] Attachments;
        MAP<String, String> Variables; //"FSM_CustomerName__c": "Subir"
	}
    
	/********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is Wrapper class for Email from.
    @Description : Created as part of user story #SFI-1821
    @Date        : 24-May-2024
    ********************************************************************************************************/ 
	class Cls_From {
		String Email;	//pilot@mailjet.com
		String Name;	//Your Mailjet Pilot
	}
    
	/********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is Wrapper class for email To.
    @Description : Created as part of user story #SFI-1821
    @Date        : 24-May-2024
    ********************************************************************************************************/ 
	class Cls_To {
		String Email;	//passenger1@mailjet.com
		String Name;	//Passenger 1
	}
    
	/********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is Wrapper class for BCC emails.
    @Description : Created as part of user story #SFI-1821
    @Date        : 24-May-2024
    ********************************************************************************************************/ 
	class Cls_Bcc {
		String Email;	//passenger3@mailjet.com
		String Name;	//Passenger 3
	}
    
	/********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is Wrapper class for attachments.
    @Description : Created as part of user story #SFI-1821
    @Date        : 24-May-2024
    ********************************************************************************************************/ 
	class Cls_Attachments {
		String Filename;	//test.txt
		String ContentType;	//text/plain
		String Base64Content;	//VGhpcyBpcyB5b3VyIGF0dGFjaGVkIGZpbGUhISEK
    }    
}
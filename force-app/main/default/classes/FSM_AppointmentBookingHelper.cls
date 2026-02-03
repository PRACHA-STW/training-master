/**----------------------------------------------------
* @description :  To get avilable appointment booking slots               
* @group      :  Capgemini
* Test Class  :  FSM_AppointmentBookingTest
* ver    Date                Author             Modification
1.0    23th June 2023       Srikanth           Created-SFI-31
2.0    11th June 2024       Srikanth           Updated-SFI-2213
--------------------------------------------------*/
public with sharing class FSM_AppointmentBookingHelper{
    
    private static String randomExternalId = FSM_Utility.generateRandomNumber(); //To generate random External ID for Work order
    //Below variables added by Subir Maji 16th July 2024 as part of SFI-2479
    private static List<Skill> listSkill = new List<Skill>(); //To query existing skill records in SF
    private static List<ServiceResource> listSR = new List<ServiceResource>(); //To query existing Service resource records in SF
    public static ServiceTerritory st ; //To query existing Service territory records in SF
    public static OperatingHours oh; //To query existing Operating Hours records in SF
    
    /**
    * @description checkForDataIssues Check if any data is missing in payload or missing in SF side then throw error
    * @param requestBody
    * @date Added by Subir Maji 16th July 2024 as part of SFI-2479 
    */
    public static void checkForDataIssues(FSM_CreateCustomerAppointmentWOSA.FSM_AppointmentRequest requestData){
        List<String> extIDNotPresent = new List<String>(); //To Collect all the ID which is not present in SF
        List<String> extIDPresent = new List<String>(); //To Collect all the ID which is present in SF
        List<String> allErrors = new List<String>(); //To create a single error message
        Boolean isErrorPresent = false; //for throwing exception at teh end just once
        
        //Check for service territory is present or not
        if(String.isBlank(requestData.serviceTerritoryId)){
            isErrorPresent = true;
            allErrors.add(system.label.FSM_ServTerBlankErrINT11);
        }else{
            List<ServiceTerritory> allTerritory = [Select id,FSM_ExternalId__c,OperatingHoursId,FSM_SchedulingPolicy__c,
                                                   OperatingHours.TimeZone 
                                                   from ServiceTerritory 
                                                   where FSM_ExternalId__c=:requestData.serviceTerritoryId WITH SECURITY_ENFORCED limit 1];
            
            if(allTerritory == null || allTerritory.isEmpty()){
                isErrorPresent = true;
                allErrors.add(requestData.serviceTerritoryId + system.label.FSM_ServTerNotFoundErrINT11);
            }else{
                st = allTerritory[0];
            }
        }
        
        //Check for Slot type or operating hours is present or not
        if(String.isBlank(requestData.SlotType)){
            isErrorPresent = true;
            allErrors.add(system.label.FSM_SlotTypeErrINT11);
        }else{
            List<OperatingHours> allOperatingHour = [select id,Name, FSM_SlotType__c, FSM_BusinessUnit__c  
                                                     from OperatingHours 
                                                     where FSM_SlotType__c=:requestData.slotType 
                                                     AND FSM_BusinessUnit__c=:requestData.businessArea WITH SECURITY_ENFORCED LIMIT 1];
            
            if(allOperatingHour == null || allOperatingHour.isEmpty()){
                isErrorPresent = true;
                allErrors.add(system.label.FSM_SlotTypeNotFoundErrINT11);
            }else{
                oh = allOperatingHour[0];
            }
        }
        
        //Check if Service Resource are available in SF or not, if not present then throw error
        //Updated by Subir Maji as part of SFI-2585 6th Aug 24
        if(requestData.preferredResource != null && requestData.preferredResource.size() > 0){
            listSR = [select id,FSM_ExternalId__c 
                      from ServiceResource 
                      where FSM_ExternalId__c In :requestData.preferredResource WITH SECURITY_ENFORCED];
            
            if(listSR == null || listSR.isEmpty()){
                isErrorPresent = true;
                allErrors.add(system.label.FSM_ServResNotFoundErrINT11);
            }else if(requestData.preferredResource.size() != listSR.size()){
                for(ServiceResource sr : listSR){
                    extIDPresent.add(sr.FSM_ExternalId__c);
                }
                for(String sr : requestData.preferredResource){
                    if(!extIDPresent.contains(sr)){
                        extIDNotPresent.add(sr);
                    }
                }
                isErrorPresent = true;
                allErrors.add(extIDNotPresent +system.label.FSM_TheseServResNotFoundErrINT11);
            }
        }
        
        //Check if Skills are available in SF or not, if not present then throw error
        //Updated by Subir Maji as part of SFI-2585 6th Aug 24
        if(requestData.requiredSkills != null && requestData.requiredSkills.size() > 0){
            listSkill = [select id,MasterLabel 
                         from skill 
                         where MasterLabel In :requestData.requiredSkills WITH SECURITY_ENFORCED];
            
            if(listSkill == null || listSkill.isEmpty()){
                isErrorPresent = true;
                allErrors.add(system.label.FSM_SkillsNotFoundErrINT11);
            }else if(requestData.requiredSkills.size() != listSkill.size()){
                extIDNotPresent = new List<String>();
                extIDPresent = new List<String>();
                for(Skill sk : listSkill){
                    extIDPresent.add(sk.MasterLabel);
                }
                for(String sk : requestData.requiredSkills){
                    if(!extIDPresent.contains(sk)){
                        extIDNotPresent.add(sk);
                    }
                }
                isErrorPresent = true;
                allErrors.add(extIDNotPresent +system.label.FSM_TheseSkillsNotFoundErrINT11);
            }
        }
        
        //Check for Mandatory field value is present or not
		//Added as part of SFI-2566 by Subir Maji 30th July 24
		if(String.isBlank(requestData.longitude) || String.isBlank(requestData.latitude) || String.isBlank(requestData.earlyStart) || String.isBlank(requestData.dueDate) || String.isBlank(requestData.postcode) || 
          String.isBlank(requestData.duration) || String.isBlank(requestData.businessArea) || String.isBlank(requestData.durationType)){
            isErrorPresent = true;
            allErrors.add(system.label.FSM_MandatoryFieldErrINT11);
        }
        //If any data issue found throw exception
        if(isErrorPresent){
            throw new Fieldscheckexception(JSON.serialize(allErrors));
        }
    }
    
    /**
    * @description getOperatingHours to get OperatingHours
    * @return Id
    */
    public static Id getDefaultSchedulingPolicyID(){
        FSL__Scheduling_Policy__c schPol = [select id  
                                             from FSL__Scheduling_Policy__c 
                                             where Name=: System.Label.FSM_DefaultSchedulingPolicy WITH SECURITY_ENFORCED Limit 1 ];
        return schPol.Id;
    }
    
    /**
    * @description createWorkOrder to create WorkOrder 
    * @param requestData
    * @param st
    * @return WorkOrder
    */
    public static WorkOrder createWorkOrder(FSM_CreateCustomerAppointmentWOSA.FSM_AppointmentRequest requestData,ServiceTerritory st){
        WorkOrder wo=new WorkOrder();
        
        wo.FSM_ExternalId__c= randomExternalId;
        wo.StartDate=DateTime.valueOf(requestData.earlyStart.replace('T',' ')); //Updated as part of SFI-2566 by Subir Maji 30th July 24       
        wo.EndDate=DateTime.valueOf(requestData.dueDate.replace('T',' ')); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        wo.Duration=Decimal.valueof(requestData.duration); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        wo.Priority=requestData.priority;
        wo.FSM_StandardTextKey__c=requestData.standardTextKey;
        wo.ServiceTerritoryId=st.Id;
        wo.FSM_TaskType__c=requestData.taskType; 
        wo.PostalCode=requestData.postcode;
        wo.FSM_BusinessUnit__c=requestData.businessArea;
        wo.Longitude=Decimal.valueof(requestData.longitude); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        wo.Latitude=Decimal.valueof(requestData.latitude); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        wo.FSM_IsTemporaryRecord__c=true;
        wo.DurationType=requestData.DurationType;
        if(!String.isBlank(requestData.minimumCrewSize)){
            wo.MinimumCrewSize=Integer.valueOf(requestData.minimumCrewSize);
        }
        
        if(Schema.sObjectType.WorkOrder.isCreateable() && Schema.sObjectType.WorkOrder.isUpdateable()){
            upsert wo FSM_ExternalId__c;
        }
        if(requestData.preferredResource!=null){
            addPreferedResource(requestData.preferredResource , wo.Id);
        }
        if(requestData.requiredSkills!=null){
            addSkills(requestData.requiredSkills,wo.Id);
        }
        return wo;
    }
    
    /**
    * @description createServiceAppointment to create ServiceAppointment 
    * @param requestData
    * @param st
    * @param wo
    * @return WorkOrder
    */
    public static ServiceAppointment createServiceAppointment(FSM_CreateCustomerAppointmentWOSA.FSM_AppointmentRequest requestData,ServiceTerritory st,workOrder wo){
        ServiceAppointment sa=new ServiceAppointment();
        sa.FSM_ExternalId__c=randomExternalId;
        sa.EarliestStartTime=DateTime.valueOf(requestData.earlyStart.replace('T',' ')); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        sa.DueDate=DateTime.valueOf(requestData.dueDate.replace('T',' ')); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        sa.Duration=Decimal.valueOf(requestData.duration); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        sa.ServiceTerritoryId=st.Id;
        sa.Longitude=Decimal.valueof(requestData.longitude); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        sa.Latitude=Decimal.valueof(requestData.latitude); //Updated as part of SFI-2566 by Subir Maji 30th July 24
        sa.PostalCode=requestData.postcode;
        sa.FSM_CustomerAppointment__c=true;
        sa.FSSK__FSK_Work_Order__c=wo.Id;
        sa.ParentRecordId=wo.Id;
        sa.FSM_IsTemporaryRecord__c = true;
        sa.DurationType=requestData.DurationType;
        
        if(Schema.sObjectType.ServiceAppointment.isCreateable() && Schema.sObjectType.ResourcePreference.isUpdateable()){
            upsert sa FSM_ExternalId__c;
        }
        return sa;
    }
    
    /**
    * @description addPreferedResource to create Resource Preference 
    * @param preferedResource
    * @param workOrderId
    */
    private static void addPreferedResource(String[] preferedResource,Id workOrderId){
        if(preferedResource.size() == 0){
            return ;
        }
        List<ResourcePreference> listRP = new List<ResourcePreference>();
        ResourcePreference rp;
        
        for(ServiceResource sr : listSR){
            rp = new ResourcePreference();
            rp.RelatedRecordId = workOrderId;
            rp.ServiceResourceId = sr.id;
            listRP.add(rp);
        }
        if(listRP.size()>0 && Schema.sObjectType.ResourcePreference.isCreateable()){
            insert listRP;
        }
    }
    
    /**
    * @description addSkills to create Skills for teh job 
    * @param skills
    * @param workOrderId
    */
    private static void addSkills(String[] skills,Id workOrderId){
        if(skills.size() == 0){
            return ;
        }
        List<SkillRequirement> listSkillReq = new List<SkillRequirement>();
        SkillRequirement skillReq;
        
        for(skill sr : listSkill){
            skillReq = new SkillRequirement();
            skillReq.RelatedRecordId = workOrderId;
            skillReq.SkillId = sr.id;
            listSkillReq.add(skillReq);
        }
        
        if(listSkillReq.size()>0 && Schema.sObjectType.SkillRequirement.isCreateable()){
            insert listSkillReq;
        }
    }
    
    /**
    * @description FSM_AppointmentRequest
    * @param errMsg
    * @return ResponseWrapper1
    */
    public static ErrorResponseWrapper returnErrorResponse(String errMsg){
        ErrorResponseWrapper wrap=new ErrorResponseWrapper();
        wrap.status=FSM_Constants.RES_ERROR;
        wrap.StatusCode=FSM_Constants.RESPONSE_400;
        //Added below part by Subir Maji as part of SFI-2585 6th Aug 24
        if(!errMsg.startsWith('[')){
            errMsg = '["' + errMsg + '"]';
        }
        wrap.ErrorMessage=(List<String>)JSON.deserialize(errMsg, List<String>.class);//Updated by Subir Maji as part of SFI-2585 6th Aug 24
        return wrap;
    }
    
    /**
    * @description ErrorResponseWrapper for error response
    * @date Added by Subir Maji 16th July 2024 as part of SFI-2479
    */
    public class ErrorResponseWrapper{
        public string status;
        public Integer statusCode;
        public List<String> errorMessage; //Updated by Subir Maji as part of SFI-2585 6th Aug 24
    }
    
    /**
    * @description Fieldscheckexception to show exception messages
    */
    Public class Fieldscheckexception extends Exception{}    
}
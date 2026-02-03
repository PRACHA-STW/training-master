/**********************************************************************************************************
@Author      : Asutosh Singh
@Description : This class is used to find the delta between the new and old sa list that needs to be 
			   created and deleted based on based on crew membership changes.
@Description : Created as part of user story #SFL-885
@Test Class  : FSM_ServiceAppointmnetCrewDeltaTest
@Date        : 04-July-2025
********************************************************************************************************/
public with sharing class FSM_ServiceAppointmnetCrewDelta {
	/********************************************************************************************************
	@Author      : Asutosh Singh
	@Description : This method getting called from FSM_CrewMemberBasedSASearch flow.
	@Description : Created as part of user story #SFL-885
	@Date        : 04-July-2025
	********************************************************************************************************/
	@InvocableMethod(label='ServiceAppointmnetCrewDelta')
	public static list<SAOutputParam> deltaSA (list<SAInputParam> saInputList){
		// to store the new service appointment input in a map
		Map<Id,ServiceAppointment> allAppointmentMap;
        // to store the old service appointment input in a map
		Map<Id,ServiceAppointment> allAppointmentOldMap;
        // to store the output in the form of a wrapper class
        SAOutputParam saOutput; 
		// to return the output to the flow
		list<SAOutputParam> saOutputList = new list<SAoutputParam>();
        
        //Go through all records
        for(SAInputParam saInPara : saInputList){
            saOutput = new SAOutputParam();
            allAppointmentMap = new Map<Id,ServiceAppointment>();
            allAppointmentOldMap = new Map<Id,ServiceAppointment>();
            
			if(saInPara.allAppointment != null && !saInPara.allAppointment.isEmpty()){
				allAppointmentMap.putAll(saInPara.allAppointment);
            }  
            
            if(saInPara.allAppointmentOld != null && !saInPara.allAppointmentOld.isEmpty()){
                allAppointmentOldMap.putAll(saInPara.allAppointmentOld);
            }
            
            saOutput.allAppointmentCreate = getSADifference(allAppointmentMap,allAppointmentOldMap);
            saOutput.allAppointmentOldDelete = getSADifference(allAppointmentOldMap,allAppointmentMap);
            saOutputList.add(saOutput);
        }
        
		return saOutputList; // returning the output parameters
	}
	/********************************************************************************************************
	@Author      : Asutosh Singh
	@Description : This method is used to find the difference in SA between new and old SA map.
	@Description : Created as part of user story #SFL-885
	@Date        : 04-July-2025
	********************************************************************************************************/
	private static list<ServiceAppointment> getSADifference(map<Id,ServiceAppointment> newApptMap, map<Id,ServiceAppointment> oldApptMap){
		// to store the difference in appointments between the new and old map of appointments
		list<ServiceAppointment> saDiff = new list<ServiceAppointment>();
		if(newApptMap != null && !newApptMap.isEmpty()){
			for(Id newApptId : newApptMap.keySet()){
				// Checking if SA not there in the old SA list then add to the saDiff
				if(!oldApptMap.containsKey(newApptId)){
					saDiff.add(newApptMap.get(newApptId));
				}
			}
		}
		return saDiff; // return the saDiff list
	}

	/********************************************************************************************************
    @Author      : Asutosh Singh
    @Description : This invocable Variables getting called from FSM_CrewMemberBasedSASearch flow.
    @Description : Created as part of user story #SFL-885
    @Date        : 04-July-2025
	********************************************************************************************************/
    public class SAInputParam{
        @InvocableVariable
        public list<ServiceAppointment> allAppointment;
		@InvocableVariable
        public list<ServiceAppointment> allAppointmentOld;   
	}
	/********************************************************************************************************
    @Author      : Asutosh Singh
    @Description : This invocable Variables are sent back to FSM_CrewMemberBasedSASearch flow as output.
    @Description : Created as part of user story #SFL-885
    @Date        : 04-July-2025
	********************************************************************************************************/
    public class SAOutputParam{
        @InvocableVariable
        public list<ServiceAppointment> allAppointmentCreate;
		@InvocableVariable
        public list<ServiceAppointment> allAppointmentOldDelete;   
	}
}
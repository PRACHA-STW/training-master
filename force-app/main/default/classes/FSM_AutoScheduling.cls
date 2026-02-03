public without sharing class FSM_AutoScheduling {
    
    public static void updateSAAutoScheduling(List<FSM_AutoScheduleding__e> newMap) {
        List<ServiceAppointment> updateList = new List<ServiceAppointment>();
        for(FSM_AutoScheduleding__e autoSch :newMap){
            
            ServiceAppointment sa = new ServiceAppointment();
            sa.Id = autoSch.FSM_ServiceAppointmentId__c;
            sa.FSL__Auto_Schedule__c = TRUE;
            sa.FSL__Scheduling_Policy_Used__c = autoSch.FSM_SchedulingPolicyId__c;
            updateList.add(sa);
        }
        
        if(updateList.size() >0){
            Update updateList;
        }
    }

}
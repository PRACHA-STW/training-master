/*===========================================================================================================================
@Author      : Aishwarya Bhosale
@Description : This Class is used to calculate Notice Date on TMA Permit.
@Description : Created as part of user story #SFS-1833
@Test Class  : FSM_updatenoticedateTest
@Date        : 10th August 2023
==============================================================================================================================*/
public with sharing class FSM_updatenoticedate{
    //invocable method to calculate notice date considering all holidays and weekends
    @InvocableMethod(label='Calculate Notice Date')
    public static void calculateNoticeDateonPermit(List<Serviceappoitments> sAid){
        
        List<List<FSM_TMAPermit__c>> outputList = new List<List<FSM_TMAPermit__c>>();
        List<FSM_TMAPermit__c> tempList = new List<FSM_TMAPermit__c>();
        DateTime scheduledstartdatetoupdate;
        List<Id> saIds = new List<Id>();
        Map<Id, String> permitWithEventMap = new Map<Id, String>();
        try{
        for(Integer i=0;i<sAid.size();i++){
            saIds.add(sAid.get(i).serviceapptid);
            //map to update event type on tma permit
            permitWithEventMap.put( sAid.get(i).tmaid , sAid.get(i).eventtype);
        }
        
        //Get master notice periods
        Map<String, Decimal> noticePeriodMap = new Map<String, Decimal>();
        for(FSM_TMAPermitNoticePeriods__c tmaNp: [Select Id, FSM_HighwayAuthority__c, FSM_WorksCategory__c, FSM_NoticePeriod__c from FSM_TMAPermitNoticePeriods__c with security_enforced Limit 200]){
            noticePeriodMap.put( tmaNp.FSM_HighwayAuthority__c + tmaNp.FSM_WorksCategory__c,  tmaNp.FSM_NoticePeriod__c);
            
        }
        
        //TMA and its notice period
        Map<Id, Decimal> tmaNoticeMap = new Map<Id, Decimal>();
        Map<Id, Datetime> tmaNoticeDateMap = new Map<Id, Datetime>();
        Set<Id> permitIds = new Set<Id>();
        Map<Id, String> permitWithWOMap = new Map<Id, String>();
        for(ServiceAppointment sa: [Select Id, FSSK__FSK_Work_Order__r.FSM_TMAPermit__c, FSSK__FSK_Work_Order__r.FSM_TMAPermit__r.FSM_HighwayAuthority__c,
                                           FSSK__FSK_Work_Order__r.FSM_TMAPermit__r.FSM_NoticeType__c from ServiceAppointment where Id IN:saIds with security_enforced]){
                                           
            String authCode = sa.FSSK__FSK_Work_Order__r.FSM_TMAPermit__r.FSM_HighwayAuthority__c;
            system.debug('authCode---------------->'+authCode);
            String workCat = sa.FSSK__FSK_Work_Order__r.FSM_TMAPermit__r.FSM_NoticeType__c;
              system.debug('workCat---------------->'+workCat);
            if(noticePeriodMap.containsKey( authCode + workCat)){
                tmaNoticeMap.put(sa.FSSK__FSK_Work_Order__r.FSM_TMAPermit__c, noticePeriodMap.get( authCode + workCat ) );
                
            }
            system.debug('tmaNoticeMap--------------->'+tmaNoticeMap);
            permitIds.add(sa.FSSK__FSK_Work_Order__r.FSM_TMAPermit__c);
            permitWithWOMap.put(sa.FSSK__FSK_Work_Order__r.FSM_TMAPermit__c, sa.FSSK__FSK_Work_Order__c);
        }
        //find SA having same permit
        List<AggregateResult> aggrRes = [Select FSSK__FSK_Work_Order__r.FSM_TMAPermit__c permitId, MIN(SchedStartTime) schedTime from ServiceAppointment 
                                                 where Status NOT IN ('New','Rejected','Cancelled') AND FSSK__FSK_Work_Order__r.FSM_TMAPermit__c <> Null 
                                                 AND FSSK__FSK_Work_Order__r.FSM_TMAPermit__c IN: permitIds AND SchedStartTime <> Null 
                                                 AND FSSK__FSK_Work_Order__r.FSM_TMAPermit__r.FSM_InitialNoticesenttoSAP__c = false  
                                         		 AND FSSK__FSK_Work_Order__r.FSM_CoreTMAJob__c=true with Security_Enforced 
                                                 group by FSSK__FSK_Work_Order__r.FSM_TMAPermit__c ];
        system.debug('aggr----------->'+aggrRes.size());
        BusinessHours bh = [SELECT Id From BusinessHours WHERE IsDefault=true with Security_Enforced];
        Map<String, DateTime> permitWithDates = new Map<String, DateTime>();
        Set<String> permitCheck = new Set<String>();
        for(AggregateResult aggr: aggrRes ){
            system.debug('inside aggr');
            String permitRecId = (String) aggr.get('permitId');
            system.debug('permitRecId------------------>'+permitRecId);
            permitCheck.add(permitRecId);
            DateTime scheduledstartdate = (DateTime) aggr.get('schedTime');
            scheduledstartdatetoupdate=scheduledstartdate;
            if(tmaNoticeMap.containsKey(permitRecId) ){
                
                Date noticeDateToUpdate = null;
                Decimal noticeperiodtosub = tmaNoticeMap.get(permitRecId);
                Integer elapsed = 0;
                Integer cnt = 0;
                while (elapsed < noticeperiodtosub)
                {
                    system.debug('4444444444444444444');
                    cnt ++;
                    scheduledstartdate = scheduledstartdate.addDays(-1);
                    if (BusinessHours.isWithin(bh.Id, scheduledstartdate)) 
                    {
                        system.debug('5555555555555');
                        elapsed++;
                    }else {
                        continue;
                        system.debug('do nothing');
                    }
                    
                }
                
                if(cnt > 0){
                    system.debug('11111111111111111111111');
                    noticeDateToUpdate = scheduledstartdate.date(); 
                     FSM_TMAPermit__c outputPermit = new FSM_TMAPermit__c();
                     outputPermit.Id = permitRecId;
                     outputPermit.FSM_NoticeDate__c = noticeDateToUpdate;
                     outputPermit.FSM_ScheduledStartDate__c = scheduledstartdatetoupdate; 
                     outputPermit.FSM_EventType__c = permitWithEventMap.get(permitRecId);
                     outputPermit.FSM_WorkOrderRefID__c = permitWithWOMap.get(permitRecId);
                    system.debug('outputPermit---------------------->'+outputPermit);
                     tempList.add(outputPermit); 
                }
            }
        }
        
        for(String pmt: permitIds ){
            system.debug('inside emptys');
            if(!permitCheck.contains(pmt)){
                system.debug('permitCheck------------>');
             FSM_TMAPermit__c outputPermit = new FSM_TMAPermit__c();
             outputPermit.Id = pmt;
             outputPermit.FSM_NoticeDate__c = null;
             outputPermit.FSM_ScheduledStartDate__c = null;
             outputPermit.FSM_EventType__c = null;
             outputPermit.FSM_WorkOrderRefID__c = null;
             tempList.add(outputPermit); 
           }
        }
        
        if(tempList.size() > 0){
            system.debug('333333333333333');
                if (Schema.sObjectType.FSM_TMAPermit__c.isUpdateable()){
                database.update(tempList);
                }
               outputList.add(tempList); 
            }
	  }catch(Exception ex){
          system.debug('666666666666666666');
            //Creating an error log if exception occoured
            FSM_ErrorLog__c testerrorlog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_updatenoticedate').setErrorMessage(ex.getMessage()).setLineNumber(string.valueof(ex.getLineNumber())).setMethodName('calculateNoticeDateonPermit').setStackTrace(ex.getStackTraceString()).create();  
      }      
    }
    public class Serviceappoitments{
        @InvocableVariable
        public DateTime schedulestart;
        @InvocableVariable
        public Decimal noticeperiod;
        @InvocableVariable
        public String tmaid;
        @InvocableVariable
        public String serviceapptid;
        @InvocableVariable
        public String eventtype;
        
    }
    
    
}
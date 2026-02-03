/****************************************************************************************************************************
@Author : Aishwarya Bhosale
@Date   : 10th August 2023
@Description : This class is used to test if Notice date on permit is calculated correctly
@Description : Created as part of user story #SFS-1833
@Main Class : FSM_updatenoticedate  
@LastModified: 22-11-2024 Aishwarya Bhosale
==============================================================================================================================
*/
@IsTest
public class FSM_updatenoticedateTest {
    /*--------------------------------------------------------------
@Author      : Aishwarya Bhosale
@Description : This method is used to create test data setup.
-----------------------------------------------------------------*/
    @TestSetup
    static void testDataSetup(){
         FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Dispatched');
        User u=new FSM_TestDataFactory.CretaeUser().create();
         Double latitudeValue = 52.58;
        Double longitudeValue = -2.13; 
         //Get WO record type
            Id recTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
            .get(FSM_Constants.RECORDTYPE_WASTENONINFRA).getRecordTypeId();
          Date currentDate = Date.today();
        WorkOrder wo=new WorkOrder();
           // Create work rule
        FSL__Work_Rule__c wr = new FSL__Work_Rule__c(Name='Active Resources',FSL__Resource_Property__c='IsActive',FSL__Match_Constant_Boolean_Value__c=true);
        insert wr;
        
        // Create scheduling policy
        FSL__Scheduling_Policy__c testPolicy = new FSL__Scheduling_Policy__c(Name = 'Waste Non Infra Soft Boundaries', FSM_BusinessUnit__c = 'Waste Non Infra');
        insert testPolicy;
        
        // Create scheduling policy work rule
        FSL__Scheduling_Policy_Work_Rule__c spwr = new FSL__Scheduling_Policy_Work_Rule__c(FSL__Scheduling_Policy__c=testPolicy.Id, FSL__Work_Rule__c=wr.Id);
        insert spwr;
                
        // Create OperatingHours
        OperatingHours testOpHrs = new FSM_TestDataFactory.OperatingHoursCreator().setName('Test Base Calendar').setTimeZone('Europe/London').setSlotType(FSM_Constants.DURATION).create();
                
        // Create ServiceTerritory where FSM_NumberOfDaysToDispatch__c != 1 & FSM_NumberOfSAToDispatch__c = 'Full' --- Scenario 1
        ServiceTerritory testTerritory = new FSM_TestDataFactory.ServiceTerritoryCreator().setName('1302WD4M4 Insp South One (Edgbaston)')
            .setOpreratingHours(testOpHrs.Id).setAutoSchedulingPolicy(testPolicy.Id).setWorkingSubAreaRequired(true)
            .setNumberOfDaysToDispatch('5').setNumberOfSAToDispatch('Full').setIsActive(true).setBusinessUnit('Waste Non Infra').create();

        
        //create tma permit
        FSM_TMAPermit__c tmaminor=new FSM_TestDataFactory.TMAPermitCreator().setHighwayAuthority('0011').setWorksCategory('03').setTMAtype('PRMT').create(); 
        FSM_TMAPermit__c tmamajor =new FSM_TestDataFactory.TMAPermitCreator().setHighwayAuthority('0011').setWorksCategory('01').setTMAtype('PRMT').create(); 
            // Create a test WorkOrder data
        for(Integer i=0;i<2;i++){
            wo = new FSM_TestDataFactory.WorkOrderCreator().setRecordType(recTypeId).setTma(tmaminor.id).setBusinessUnit('Waste Non Infra').setServiceTerritory(testTerritory.Id).setSuitability('E').setNoticeState('NTBS').create(); 
             //Create Service Appointment
             new FSM_TestDataFactory.ServiceAppointmentCreator().setParentRecordId(wo.Id).setStatus('NEW').setLongitude(longitudeValue).setLatitude(latitudeValue).setServiceTerritory(testTerritory.Id)
                .setEarliestStartTime(DateTime.Now().AddDays(-2)).setDueDate(DateTime.Now().AddDays(18)).create();
        }
      
         //create tma noticeperiod records
         FSM_TMAPermitNoticePeriods__c tmanoticeperiod = new FSM_TestDataFactory.TMAPermitNoticePeriodCreator().setHighwayAuthority('0011').setWorksCategory('03').setNoticePeriod(4).create(); 
         FSM_TMAPermitNoticePeriods__c tmanoticeperiod1 =   new FSM_TestDataFactory.TMAPermitNoticePeriodCreator().setHighwayAuthority('0011').setWorksCategory('01').setNoticePeriod(11).create(); 
         FSM_TMAPermitNoticePeriods__c tmanoticeperiod2 = new FSM_TestDataFactory.TMAPermitNoticePeriodCreator().setHighwayAuthority('0012').setWorksCategory('03').setNoticePeriod(4).create(); 
         FSM_TMAPermitNoticePeriods__c tmanoticeperiod3 =   new FSM_TestDataFactory.TMAPermitNoticePeriodCreator().setHighwayAuthority('0012').setWorksCategory('01').setNoticePeriod(11).create(); 
            
        
    }
    @IsTest
    static void testcalnoticedate(){  
    
            test.startTest();
            List<FSM_updatenoticedate.Serviceappoitments> serviceAppList = new List<FSM_updatenoticedate.Serviceappoitments>();
            List <ServiceAppointment> serviceappt=[Select id,SchedStartTime,SchedEndTime,FSSK__FSK_Work_Order__r.FSM_TMAPermit__c from ServiceAppointment];
            //  Datetime schedulestart = Datetime.newInstance(2024, 11, 02, 14, 30, 0);
              Date currentDate = Date.today();
            Datetime schedulestart =   Datetime.newInstance(currentDate.addDays(+1), Time.newInstance(14, 30, 0, 0));
            List <ServiceAppointment> serviceapptupdt=new List<ServiceAppointment>();
            Integer i=0;
            for(ServiceAppointment saupdt:serviceappt){
                saupdt.SchedStartTime=Datetime.newInstance(currentDate.addDays(i+1), Time.newInstance(14, 30, 0, 0));
                saupdt.SchedEndTime=Datetime.newInstance(currentDate.addDays(i+1), Time.newInstance(15, 30, 0, 0));
                saupdt.Status='Scheduled';
                i=i+1;
                serviceapptupdt.add(saupdt);
                
            }
            update serviceapptupdt;
            List <ServiceAppointment> updatedserviceappt=[Select id,SchedStartTime,SchedEndTime,FSSK__FSK_Work_Order__r.FSM_TMAPermit__c from ServiceAppointment];
            for(ServiceAppointment sappt:updatedserviceappt){
                FSM_updatenoticedate.Serviceappoitments sa=new FSM_updatenoticedate.Serviceappoitments();
				sa.schedulestart=  sappt.SchedStartTime;
                sa.noticeperiod=  4;
                sa.tmaid=sappt.FSSK__FSK_Work_Order__r.FSM_TMAPermit__c;
                sa.eventtype='0200';
                sa.serviceapptid=sappt.Id;
                serviceAppList.add(sa);
                
            }
           /* Date currentDate = Date.today();
            Datetime schedulestart =   Datetime.newInstance(currentDate.addDays(+1), Time.newInstance(14, 30, 0, 0));
            system.debug('date from test class'+schedulestart);
            Decimal period=3.00;
            FSM_updatenoticedate.Serviceappoitments sa1=new FSM_updatenoticedate.Serviceappoitments();
            sa1.noticeperiod=period;
            
            sa1.schedulestart=schedulestart;
            FSM_updatenoticedate.Noticedate finalnoticedate=new FSM_updatenoticedate.Noticedate();
            List<FSM_updatenoticedate.Noticedate> noticedtlst=new List<FSM_updatenoticedate.Noticedate>();
            noticedtlst=FSM_updatenoticedate.calculateNoticeDateonPermit(new List<FSM_updatenoticedate.Serviceappoitments> {sa});
            System.debug('noticedtlst--->' + noticedtlst);
            System.assert(noticedtlst.size()>0,'notice date calculated');*/
            FSM_updatenoticedate.calculateNoticeDateonPermit(serviceAppList);
            test.stopTest(); 
        
    }
    @isTest
     static void testcalnoticedateonunschedule(){  
       
            test.startTest();
                    List<FSM_updatenoticedate.Serviceappoitments> newserviceappt = new List<FSM_updatenoticedate.Serviceappoitments>();
            List <ServiceAppointment> serviceapptlist=[Select id,SchedStartTime,SchedEndTime,FSSK__FSK_Work_Order__r.FSM_TMAPermit__c from ServiceAppointment];
            Date currentDate = Date.today();
            Datetime schedulestart =   Datetime.newInstance(currentDate.addDays(+1), Time.newInstance(14, 30, 0, 0));
           
            for(ServiceAppointment sappt:serviceapptlist){
                FSM_updatenoticedate.Serviceappoitments sa=new FSM_updatenoticedate.Serviceappoitments();
				sa.schedulestart=  sappt.SchedStartTime;
                sa.noticeperiod=  4;
                sa.tmaid=sappt.FSSK__FSK_Work_Order__r.FSM_TMAPermit__c;
                sa.eventtype='0200';
                sa.serviceapptid=sappt.Id;
                newserviceappt.add(sa);
                
            }
              FSM_updatenoticedate.calculateNoticeDateonPermit(newserviceappt);
            test.stopTest(); 
       
}
    
    
}
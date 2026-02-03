/*===========================================================================================================================
@Author      : Rajashri Todkar
@Description : This Class is used to check if the date is within business hours
@Description : Created as part of user story #SFS-5479
@Test Class  : FSM_checkbusinessHoursTest
@Date        : 20th May 2024
==============================================================================================================================*/

public with sharing class FSM_checkbusinessHours {
	//invocable method to check if the date is within business hours
    @InvocableMethod(label='Within Business hours')
    public static List<Validdate> checkbusinessHours(List<Serviceappoitmentwrapper> sAid)
    {
    	System.debug('Function Called');
        System.debug('SA'+sAid.get(0));
        DateTime todaydate = Date.Today();
        DateTime currduedate=sAid.get(0).duedate;
        Id businesshourid = sAid.get(0).businesshours;
        
        Datetime newdate=todaydate;
        List<Validdate> validdatelist = new List<Validdate>();
        
        system.debug('------- '+BusinessHours.isWithin(businesshourid, todaydate));
        //Return null if its a holiday or weekend.
        if(todaydate != BusinessHours.nextStartDate(businesshourid, Date.Today()) && !test.isRunningTest()){
            return null;
        }
        
        Integer daysbeetween = Date.valueOf(newdate).daysBetween(Date.valueOf(currduedate));
        System.debug('=== daysbeetween'+daysbeetween); 
        Integer counter=1;
        
        for(integer i=1;i<=daysbeetween;i++)
        {
            system.debug('----- newdate'+newdate);
            DateTime tempDate = newdate.addDays(1);
            system.debug('----- tempDate'+tempDate);
            Datetime nextStart = BusinessHours.nextStartDate(businesshourid, tempDate);
            if(nextStart<= currduedate)
            {
                counter++;
                newdate = nextStart;
                System.debug('=== newdate'+newdate);
            }
            else {
                Validdate returnvaliddate = new Validdate();
                returnvaliddate.isvaliddate = false;
                validdatelist.add(returnvaliddate);
                return validdatelist;
            }
            if(counter>3)
            {
                Validdate returnvaliddate = new Validdate();
                returnvaliddate.isvaliddate = true;
                validdatelist.add(returnvaliddate);
                return validdatelist;
            }
        }
        System.debug('=== counter'+counter);
        return null;
    }
    public class Serviceappoitmentwrapper{
        @InvocableVariable
        public DateTime duedate;
        @InvocableVariable
        public Id businesshours;
        
    }
    public class Validdate{
        @InvocableVariable
        public Boolean isvaliddate;
    }
}
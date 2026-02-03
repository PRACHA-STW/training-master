/****************************************************************************************************************************
@Author : Rajashri Todkar
@Date   : 20th May 2024
@Description : This class is used to test if Due date is within business hours
@Description : Created as part of user story #SFS-5479
@Main Class : FSM_checkbusinessHours  
==============================================================================================================================
*/
@isTest(SeeAllData=false)
public class FSM_checkbusinessHoursTest {
    
    /*--------------------------------------------------------------
@Author      : Rajashri Todkar
@Description : This method is used to create test data setup.
-----------------------------------------------------------------*/
    @TestSetup
    static void testDataSetup(){
        
        User u=new FSM_TestDataFactory.CretaeUser().create();
    }
    @IsTest
    static void testcalduedate(){  
        List<User> u=[Select id ,IsActive from User];
        u[0].IsActive=True;
        update u[0];
        system.runAs(u[0]){
            test.startTest();
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            if(!bhs.isEmpty())
            {
                Date currentDate = Date.today();
                Datetime tempDueDate =   currentDate.addDays(10);
                FSM_checkbusinessHours.Serviceappoitmentwrapper saWrapper = new FSM_checkbusinessHours.Serviceappoitmentwrapper();
                saWrapper.duedate = tempDueDate;
                saWrapper.businesshours = bhs[0].id;
                
                List<FSM_checkbusinessHours.Validdate> returnlist = new List<FSM_checkbusinessHours.Validdate>();
                returnlist=FSM_checkbusinessHours.checkbusinessHours(new List<FSM_checkbusinessHours.Serviceappoitmentwrapper> {saWrapper});
                
                saWrapper = new FSM_checkbusinessHours.Serviceappoitmentwrapper();
                saWrapper.duedate = currentDate.addDays(1);
                saWrapper.businesshours = bhs[0].id;
                returnlist=FSM_checkbusinessHours.checkbusinessHours(new List<FSM_checkbusinessHours.Serviceappoitmentwrapper> {saWrapper});
                   // Proceed with your assertion when returnlist is not null  
                if (returnlist != null) {
                    System.debug('returnlist--->' + returnlist);
                    System.assertEquals(returnlist[0].isvaliddate, false, 'not valid');
                } 
                
            }
            test.stopTest();
        }
    }
}
/********************************************************************************************************
@Author : Subir maji
@Date   : 5th June 2023
@description : This class used to Throw error, will be called from Record trigerred flow, SFS-278
@Main Class : InvocableCrash  
==============================================================================================================================
*/
@isTest 
public class FSM_InvocableCrash_Test {
    @isTest
    static void testCrash() {
        try {   
            FSM_InvocableCrash.execute(new String[] {'Hello there!'});
            System.assert(false, 'Method did not cause a crash');
        } catch (FSM_InvocableCrash.InvocableCrashException ex) {
            //All good!
        }
    }
}
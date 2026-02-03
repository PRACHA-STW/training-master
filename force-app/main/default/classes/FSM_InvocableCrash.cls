/********************************************************************************************************
@Author : Subir maji
@Date   : 5th June 2023
@description : This class used to Throw error, will be called from Record trigerred flow, SFS-278
@Test Class : FSM_InvocableCrash_Test   
==============================================================================================================================
*/
Public with sharing class FSM_InvocableCrash {
    /**
    * Throws an exception if error messages are present.
    * @param errorMessages List of error messages indicating reasons for the crash.
    */
    @InvocableMethod(Label='Crash' Description='You dont have required permission to delete this record')
    public static void execute(List<String> errorMessages) {
        if (errorMessages.size() > 0) {
            throw new InvocableCrashException(errorMessages.get(0));
        }
    }
    
    /**
    * Custom exception class for simulating an invocable crash.
    * It extends the Exception class.
    */
    public class InvocableCrashException extends Exception {}
}
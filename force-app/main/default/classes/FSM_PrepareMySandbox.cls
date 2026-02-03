/********************************************************************************************************
@Author      : Brajesh Kumar
@description : This class contains actual logic of a batch job to support data masking / anonymization of data
@description : Created as part of user story #SFS-4144
@description : Used to invoke FSM_PrepareMySandboxBatchUpdate class where the actual logic is written
@Test Class  : FSM_PrepareMySandboxTest & FSM_PrepareMySandboxTestProd
@Date        : 07-February-2024
********************************************************************************************************/

global class FSM_PrepareMySandbox implements SandboxPostCopy {
    /**Executes actions in a new sandbox to prepare it for use**/
    global void runApexClass(SandboxContext context) {
        // Batch class logic 
        FSM_PrepareMySandboxBatchUpdate batchUpdate = new FSM_PrepareMySandboxBatchUpdate();
        Database.executeBatch(batchUpdate);
        
        
    }
}
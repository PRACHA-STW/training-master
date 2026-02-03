/*===========================================================================================================================
@Author      : Leena B
@Description : This Class is used to get DCF Forms for WorkStep in WorkOrder Based on Configurations stored in MetaData.
@Description : Created as part of user story #SFS-1298
@Test Class  : FSM_InvocableDcfConfiguration_Test
@Date        : 3rd August 2023
@Modified By : Leena B , #SFS-4475, #SFS-4476
==============================================================================================================================*/
public with sharing class FSM_InvocableDcfConfiguration {
    // List to store all records of configurationWorkSteps
    static List<FSM_DCFConfigurationWorkStep__mdt> configurationWorkSteps = new List<FSM_DCFConfigurationWorkStep__mdt>();

    @InvocableMethod(Label='FetchDcfConfiguration')
    public static List<List<FSM_DCFConfigurationWorkStep__mdt>> getFormNames(List<InputParams> conditions) {
        system.debug('params --> ' + conditions);

        List<List<FSM_DCFConfigurationWorkStep__mdt>> formsList = new List<List<FSM_DCFConfigurationWorkStep__mdt>>();
        Map<Id, List<FSM_DCFConfigurationWorkStep__mdt>> woDCFMap = new Map<Id, List<FSM_DCFConfigurationWorkStep__mdt>>();

        try {
            // Group input conditions by business unit for optimized processing
            Map<String, List<InputParams>> buToInputs = new Map<String, List<InputParams>>();
            for (InputParams param : conditions) {
                if (!buToInputs.containsKey(param.businessUnit)) {
                    buToInputs.put(param.businessUnit, new List<InputParams>());
                }
                buToInputs.get(param.businessUnit).add(param);
            }
           //Fetch all unique Business Units from input and query corresponding metadata records
            Set<String> allBusinessUnits = getBusinessUnits(conditions);
            configurationWorkSteps = [
                SELECT Id, DeveloperName, FSM_BusinessUnit__c, FSM_DCFformName__c,
                       FSM_IsMandatory__c, FSM_MandatoryOnSuspend__c, FSM_MaxInstance__c, FSM_NoEngonOP__c,
                       FSM_StTextKy__c, FSM_Suitability__c, MasterLabel, FSM_WorkCentre__c, FSM_WorkStepName__c,
                       FSM_AlternativeFormsGroup__c
                FROM FSM_DCFConfigurationWorkStep__mdt
                WHERE FSM_BusinessUnit__c IN :allBusinessUnits
                WITH SECURITY_ENFORCED
                ORDER BY MasterLabel ASC
            ];
           //Iterate through each business unit group and match metadata records
            for (String businessUnit : buToInputs.keySet()) {
                List<InputParams> relatedInputs = buToInputs.get(businessUnit);
                for (FSM_DCFConfigurationWorkStep__mdt mdt : configurationWorkSteps) {
                    if (mdt.FSM_BusinessUnit__c != null && mdt.FSM_BusinessUnit__c != businessUnit && mdt.FSM_BusinessUnit__c != '*') {
                        continue;
                    }

                    for (InputParams inpt : relatedInputs) {
                        Boolean check1, check2, check3, check4;
                        String workStepName = mdt.FSM_WorkStepName__c;
                      //Match Work Centre with support for wildcards
                        check1 = ((mdt.FSM_WorkCentre__c == '*') ||
                            (mdt.FSM_WorkCentre__c != NULL && mdt.FSM_WorkCentre__c.startswith('*') && mdt.FSM_WorkCentre__c.endsWith('*') && inpt.serviceTerritory.contains(mdt.FSM_WorkCentre__c.Substring(1, mdt.FSM_WorkCentre__c.length() - 1))) ||
                            (mdt.FSM_WorkCentre__c != NULL && mdt.FSM_WorkCentre__c.startswith('*') && inpt.serviceTerritory.endsWith(mdt.FSM_WorkCentre__c.Substring(1))) ||
                            (mdt.FSM_WorkCentre__c != NULL && mdt.FSM_WorkCentre__c.endsWith('*') && inpt.serviceTerritory.startsWith(mdt.FSM_WorkCentre__c.Substring(0, mdt.FSM_WorkCentre__c.length() - 1))));
                      //Match Standard Text Key with support wildcards 
                        check2 = ((mdt.FSM_StTextKy__c == '*') ||
                            (mdt.FSM_StTextKy__c != NULL && mdt.FSM_StTextKy__c.startswith('*') && mdt.FSM_StTextKy__c.endsWith('*') && inpt.standardTextKey.contains(mdt.FSM_StTextKy__c.Substring(1, mdt.FSM_StTextKy__c.length() - 1))) ||
                            (mdt.FSM_StTextKy__c != NULL && mdt.FSM_StTextKy__c.startswith('*') && inpt.standardTextKey.endsWith(mdt.FSM_StTextKy__c.Substring(1))) ||
                            (mdt.FSM_StTextKy__c != NULL && mdt.FSM_StTextKy__c.endsWith('*') && inpt.standardTextKey.startsWith(mdt.FSM_StTextKy__c.Substring(0, mdt.FSM_StTextKy__c.length() - 1))) ||
                            (mdt.FSM_StTextKy__c != NULL && mdt.FSM_StTextKy__c == inpt.standardTextKey));
                      //Match Suitability 
                        check3 = (mdt.FSM_Suitability__c == '*' || (mdt.FSM_Suitability__c != NULL && mdt.FSM_Suitability__c == inpt.suitability) || (mdt.FSM_Suitability__c == NULL && String.isBlank(inpt.suitability)));
                        //Match conditionally based on business unit type
                        Set<String> nonInfraBU = new Set<String>{'Waste Non Infra', 'Water Non Infra', 'Bio Resource'};
                        if (nonInfraBU.contains(inpt.businessUnit)) {
                            check4 = ((mdt.FSM_BusinessUnit__c == '*' || (mdt.FSM_BusinessUnit__c != NULL && mdt.FSM_BusinessUnit__c == inpt.businessUnit)) &&
                                (String.isBlank(mdt.FSM_NoEngonOP__c) ||
                                (String.isNotBlank(mdt.FSM_NoEngonOP__c) && mdt.FSM_NoEngonOP__c.contains('*')) ||
                                (String.isNotBlank(mdt.FSM_NoEngonOP__c) && inpt.minimumCrewSize != null && inpt.minimumCrewSize >= Integer.valueOf(mdt.FSM_NoEngonOP__c))));
                        } else {
                            check4 = (String.isBlank(mdt.FSM_BusinessUnit__c) ||
                                String.isBlank(mdt.FSM_NoEngonOP__c) ||
                                (String.isNotBlank(mdt.FSM_NoEngonOP__c) && mdt.FSM_NoEngonOP__c.contains('*')) ||
                                (String.isNotBlank(mdt.FSM_NoEngonOP__c) && inpt.minimumCrewSize != null && inpt.minimumCrewSize >= Integer.valueOf(mdt.FSM_NoEngonOP__c)));
                        }
                      //If all check pass, add to the map for that Work Order
                        if (check1 && check2 && check3 && check4) {
                            if (!woDCFMap.containsKey(inpt.workorderId)) {
                                woDCFMap.put(inpt.workorderId, new List<FSM_DCFConfigurationWorkStep__mdt>());
                            }
                            woDCFMap.get(inpt.workorderId).add(mdt);
                        }
                    }
                }
            }
            //If no records found, return null
            if (woDCFMap.isEmpty()) {
                return null;
            }
            //Remove duplicates per Work Order based on work step name
            woDCFMap = dedupeDCFConfigMap(woDCFMap);

            for (InputParams request : conditions) {
                List<FSM_DCFConfigurationWorkStep__mdt> formNames = woDCFMap.containsKey(request.workorderId) ? woDCFMap.get(request.workorderId) : new List<FSM_DCFConfigurationWorkStep__mdt>();
                formsList.add(formNames);
            }
          
            return formsList;

        } catch (Exception ex) {
            FSM_ErrorLog__c testerrorlog = new FSM_Utility.ErrorLogCreator()
                .setClassName('FSM_InvocableDcfConfiguration')
                .setErrorMessage(ex.getMessage())
                .setLineNumber(String.valueOf(ex.getLineNumber()))
                .setMethodName('getFormNames')
                .setStackTrace(ex.getStackTraceString())
                .create();
            return null;
        }
    }
/********************************************************************************************************
@Author      : Hareesh Mohan
@Description : Returns the business units from flow variables, which will be used to query custom metadata configuration for worksteps.
@Description : Created as part of user story #SFS-6572
@Date        : 22nd July 2024
********************************************************************************************************/ 
    private static Set<String> getBusinessUnits(List<InputParams> flowInputs) {
        Set<String> businessUnits = new Set<String>();
        for (InputParams input : flowInputs) {
            businessUnits.add(input.businessUnit);
        }
        businessUnits.add(null);
        businessUnits.add('*');
        return businessUnits;
    }
/********************************************************************************************************
@Author      : Hareesh Mohan
@Description : Returns unique sets of worksteps for a workorder. Priority is given to the Workstep with Is_Mandatory = TRUE.
@Description : Created as part of user story #SFS-6572
@Date        : 22nd July 2024
********************************************************************************************************/
    private static Map<Id, List<FSM_DCFConfigurationWorkStep__mdt>> dedupeDCFConfigMap(Map<Id, List<FSM_DCFConfigurationWorkStep__mdt>> woToDCFConfigMap) {
        for (Id workOrderId : woToDCFConfigMap.keySet()) {
            Map<String, FSM_DCFConfigurationWorkStep__mdt> uniqueWorkSteps = new Map<String, FSM_DCFConfigurationWorkStep__mdt>();
            for (FSM_DCFConfigurationWorkStep__mdt workStep : woToDCFConfigMap.get(workOrderId)) {
                String workStepName = workStep.FSM_WorkStepName__c;
                if (!uniqueWorkSteps.containsKey(workStepName) || (workStep.FSM_IsMandatory__c == true && uniqueWorkSteps.get(workStepName).FSM_IsMandatory__c == false)) {
                    uniqueWorkSteps.put(workStepName, workStep);
                }
            }
            woToDCFConfigMap.put(workOrderId, new List<FSM_DCFConfigurationWorkStep__mdt>(uniqueWorkSteps.values()));
        }
        return woToDCFConfigMap;
    }
/********************************************************************************************************
@Author      : Hareesh Mohan
@Description : Returns if the workstep has exhausted the maximum number of DCF records under it.
@Description : Created as part of user story #SFS-6573
@Date        : 12th Aug 2024
********************************************************************************************************/
    @AuraEnabled(cacheable = true)
    public static Boolean hasDCFLimitReached(String workstepId) {
        Boolean hasLimitReached = false;
        List<FSM_DataCaptureFormInfra__c> completedWorksteps = [
            SELECT Id, FSM_WorkStep__r.FSM_MaxInstance__c
            FROM FSM_DataCaptureFormInfra__c
            WHERE FSM_WorkStep__c = :workstepId
            AND FSM_Status__c = 'Completed'
            AND FSM_WorkStep__c != null
            AND FSM_WorkStep__r.FSM_MaxInstance__c != null
        ];
        if (!completedWorksteps.isEmpty() && completedWorksteps.size() >= Integer.valueOf(completedWorksteps[0].FSM_WorkStep__r.FSM_MaxInstance__c)) {
            hasLimitReached = true;
        }
        if (!hasLimitReached) {
            List<FSM_InfraDataCaptureForm2__c> completedDCF2Worksteps = [
                SELECT Id, FSM_WorkStep__r.FSM_MaxInstance__c
                FROM FSM_InfraDataCaptureForm2__c
                WHERE FSM_WorkStep__c = :workstepId
                AND FSM_Status__c = 'Completed'
                AND FSM_WorkStep__c != null
                AND FSM_WorkStep__r.FSM_MaxInstance__c != null
            ];
            if (!completedDCF2Worksteps.isEmpty() && completedDCF2Worksteps.size() >= Integer.valueOf(completedDCF2Worksteps[0].FSM_WorkStep__r.FSM_MaxInstance__c)) {
                hasLimitReached = true;
            }
        }
        return hasLimitReached;
    }
/********************************************************************************************************
@Author      : Leena B
@Description : This is invocable Variables getting called from flows.
@Description : Created as part of user story #SFS-1298
@Date        : 3rd August 2023
********************************************************************************************************/ 
    public class InputParams {
        @InvocableVariable public String serviceTerritory;
        @InvocableVariable public String standardTextKey;
        @InvocableVariable public Integer minimumCrewSize;
        @InvocableVariable public String suitability;
        @InvocableVariable public String workorderId;
        @InvocableVariable public String businessUnit;
    }
}
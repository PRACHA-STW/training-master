/********************************************************************************************************
@Author      : Subir Maji
@Description : This Class is used to handle all DCF Infra Line 2 related triggers
@Description : Created as part of user story #SFI-2041
@description : Invoked from FSM_DCFInfraLine2Trigger
@Test Class  : FSM_DCFInfraLine2TriggerHelperTest
@Date        : 01-Aug-2024
********************************************************************************************************/
public with sharing class FSM_DCFInfraLine2TriggerHelper {
    /********************************************************************************************************
    @Author      : Subir Maji
    @description : This method is used to populate No of line item same type.
    @description : Invoked from FSM_DCFInfraLine2TriggerHandler class
    @param newList
    @Date        : 01-Aug-2024   Created as a part of SFI-2041
    ********************************************************************************************************/
    public static void populateNoOflineSameType(List<FSM_InfraDataCaptureLineItem2__c> newList){ 
        Set<String> allRecordTypeID = new Set<String>(); //To Collect all Record type Id
        Set<String> allParentRecordID = new Set<String>(); //To Collect all Parent DCF Record Id
        Map<ID, FSM_InfraDataCaptureLineItem2__c> allExistingLine; //Collect all existing DCF Line record
        MAP<String, Integer> noOfLineSameTypeMap = new MAP<String, Integer>(); //To Create a unique Key and count for each type DCF line
        String tempUnique; //Temporary variable for keeping the unique key
        Integer tempCount = 0; //Temporary variable to keep the count
        
        //Going through the list of records to collect record type id and DCF master record id
        for(FSM_InfraDataCaptureLineItem2__c infraLine2 : newList){
            allRecordTypeID.add(infraLine2.RecordTypeId);
            allParentRecordID.add(infraLine2.FSM_InfraDataCaptureForm2__c);
        }
        
        //Query all existing line item record based on record type and DCF master record
        allExistingLine = New Map<ID, FSM_InfraDataCaptureLineItem2__c>([SELECT ID, RecordTypeId, FSM_InfraDataCaptureForm2__c,
                                                                FSM_NoOfLineItemsEformsOfSameType__c
                                                                 FROM FSM_InfraDataCaptureLineItem2__c 
                                                                 WHERE FSM_InfraDataCaptureForm2__c IN : allParentRecordID
                                                                 AND RecordTypeId IN : allRecordTypeID WITH SECURITY_ENFORCED]);
        
        //If existing line item record found then prepare teh map of unique key and count
        if(allExistingLine != null && !allExistingLine.isEmpty()){
            for(FSM_InfraDataCaptureLineItem2__c infraLine2 : allExistingLine.Values()){
                //For Number of line Item of same type
                tempUnique = String.Valueof(infraLine2.FSM_InfraDataCaptureForm2__c) + String.Valueof(infraLine2.RecordTypeId);
                if(noOfLineSameTypeMap.containsKey(tempUnique)){
                    tempCount = noOfLineSameTypeMap.get(tempUnique) + 1;
                    noOfLineSameTypeMap.put(tempUnique,tempCount);
                }else{
                    noOfLineSameTypeMap.put(tempUnique,1);
                }
            }
        }
        
        //Go through all new record and populate the Grid number and number of line item same type
        for(FSM_InfraDataCaptureLineItem2__c infraLine2 : newList){
            //For Number of line Item of same type
            tempUnique = String.Valueof(infraLine2.FSM_InfraDataCaptureForm2__c) + String.Valueof(infraLine2.RecordTypeId);
            if(infraLine2.FSM_NoOfLineItemsEformsOfSameType__c == null){
            if(noOfLineSameTypeMap.containsKey(tempUnique)){
                tempCount = noOfLineSameTypeMap.get(tempUnique) + 1;
                infraLine2.FSM_NoOfLineItemsEformsOfSameType__c = tempCount;
                noOfLineSameTypeMap.put(tempUnique,tempCount);
            }else{
                infraLine2.FSM_NoOfLineItemsEformsOfSameType__c = 1;
                noOfLineSameTypeMap.put(tempUnique,1);
            }
            infraLine2.FSM_LineSequenceNumber__c = infraLine2.FSM_NoOfLineItemsEformsOfSameType__c; //Added as part of SFI-2974 by Subir Maji 22nd Oct 24
        }
            infraLine2.FSM_LineSequenceNumber__c = infraLine2.FSM_NoOfLineItemsEformsOfSameType__c; //Added as part of SFI-2974 by Subir Maji 22nd Oct 24
        }
    }
}
/********************************************************************************************************
@Author      : Subir Maji
@Description : This Class is used to handle all DCF Infra Line 1 related triggers
@Description : Created as part of user story #SFI-2041
@description : Invoked from FSM_DCFInfraLine1Trigger
@Test Class  : FSM_DCFInfraLine1TriggerHelperTest
@Date        : 01-Aug-2024
********************************************************************************************************/
public with sharing class FSM_DCFInfraLine1TriggerHelper {
    /********************************************************************************************************
    @Author      : Subir Maji
    @description : This method is used to populate No of line item same type and populate Grid Number.
    @description : Invoked from FSM_DCFInfraLine1TriggerHandler class
    @param newList
    @Date        : 01-Aug-2024   Created as a part of SFI-2041
    ********************************************************************************************************/
    public static void populateNoOflineSameType(List<FSM_DCFLineItemInfra__c> newList){ 
        Set<String> allRecordTypeID = new Set<String>(); //To Collect all Record type Id
        Set<String> allParentRecordID = new Set<String>(); //To Collect all Parent DCF Record Id
        Map<ID, FSM_DCFLineItemInfra__c> allExistingLine; //Collect all existing DCF Line record
        Map<ID, FSM_DataCaptureFormInfra__c> allParentRecord; //Added as part of SFI-2974 by Subir Maji 22nd Oct 24 to for collecting all parent record
        MAP<String, Integer> noOfLineSameTypeMap = new MAP<String, Integer>(); //To Create a unique Key and count for each type DCF line
        String tempUnique; //Temporary variable for keeping the unique key
        Integer tempCount = 0; //Temporary variable to keep the count
        //Fetching Record Type Id for Grid type Line item
        ID infralineitemGridRecordTypeId = Schema.SObjectType.FSM_DCFLineItemInfra__c.getRecordTypeInfosByDeveloperName()
            .get('FSM_GridRefForExcavation').getRecordTypeId();
        //Added as part of SFI-2974 by Subir Maji 22nd Oct 24 to fetch Valve Record type ID for parent record
        ID infraValveRecordTypeId= Schema.SObjectType.FSM_DataCaptureFormInfra__c.getRecordTypeInfosByDeveloperName()
            .get('FSM_ValveManagement').getRecordTypeId();
        
        //Going through the list of records to collect record type id and DCF master record id
        for(FSM_DCFLineItemInfra__c infraLine1 : newList){
            allRecordTypeID.add(infraLine1.RecordTypeId);
            allParentRecordID.add(infraLine1.FSM_DataCaptureFormInfra__c);
        }
        
        allParentRecord = new Map<ID, FSM_DataCaptureFormInfra__c> ([Select Id, RecordTypeId 
                                                                     from FSM_DataCaptureFormInfra__c
                                                                    Where ID IN : allParentRecordID WITH SECURITY_ENFORCED]);
        
        //Query all existing line item record based on record type and DCF master record
        allExistingLine = New Map<ID, FSM_DCFLineItemInfra__c>([SELECT ID, RecordTypeId, FSM_DataCaptureFormInfra__c, FSM_LineItem__c,
                                                                FSM_NoOfLineItemsEformsOfSameType__c, FSM_GridNo__c
                                                                 FROM FSM_DCFLineItemInfra__c 
                                                                 WHERE FSM_DataCaptureFormInfra__c IN : allParentRecordID
                                                                 AND RecordTypeId IN : allRecordTypeID WITH SECURITY_ENFORCED]);
        
        //If existing line item record found then prepare teh map of unique key and count
        if(allExistingLine != null && !allExistingLine.isEmpty()){
            for(FSM_DCFLineItemInfra__c infraLine1 : allExistingLine.Values()){
                //For Number of line Item of same type
                tempUnique = String.Valueof(infraLine1.FSM_DataCaptureFormInfra__c) + String.Valueof(infraLine1.RecordTypeId);
                if(noOfLineSameTypeMap.containsKey(tempUnique)){
                    tempCount = noOfLineSameTypeMap.get(tempUnique) + 1;
                    noOfLineSameTypeMap.put(tempUnique,tempCount);
                }else{
                    noOfLineSameTypeMap.put(tempUnique,1);
                }
                
                //For Grid number
                if(infraLine1.RecordTypeId == infralineitemGridRecordTypeId && infraLine1.FSM_LineItem__c != null){
                    tempUnique = String.Valueof(infraLine1.FSM_LineItem__c) + String.Valueof(infraLine1.RecordTypeId);
                    if(noOfLineSameTypeMap.containsKey(tempUnique)){
                        tempCount = noOfLineSameTypeMap.get(tempUnique) + 1;
                        noOfLineSameTypeMap.put(tempUnique,tempCount);
                    }else{
                        noOfLineSameTypeMap.put(tempUnique,1);
                    }
                }
            }
        }
        
        //Go through all new record and populate the Grid number and number of line item same type
        for(FSM_DCFLineItemInfra__c infraLine1 : newList){
            //For Number of line Item of same type
            tempUnique = String.Valueof(infraLine1.FSM_DataCaptureFormInfra__c) + String.Valueof(infraLine1.RecordTypeId);
            if(infraLine1.FSM_NoOfLineItemsEformsOfSameType__c == null){
            if(noOfLineSameTypeMap.containsKey(tempUnique)){
                tempCount = noOfLineSameTypeMap.get(tempUnique) + 1;
                infraLine1.FSM_NoOfLineItemsEformsOfSameType__c = tempCount;
                noOfLineSameTypeMap.put(tempUnique,tempCount);
            }else{
                infraLine1.FSM_NoOfLineItemsEformsOfSameType__c = 1;
                noOfLineSameTypeMap.put(tempUnique,1);
            }
            }
            
            //For Grid number
            if(infraLine1.RecordTypeId == infralineitemGridRecordTypeId && infraLine1.FSM_LineItem__c != null){
                tempUnique = String.Valueof(infraLine1.FSM_LineItem__c) + String.Valueof(infraLine1.RecordTypeId);
                if(noOfLineSameTypeMap.containsKey(tempUnique)){
                    tempCount = noOfLineSameTypeMap.get(tempUnique) + 1;
                    infraLine1.FSM_GridNo__c = tempCount;
                    infraLine1.FSM_NoOfLineItemsEformsOfSameType__c = tempCount; //IF GridNumber populated then match no of line item with GridNumber, added as part of SFI-2974 by Subir Maji 22nd Oct 24
                    noOfLineSameTypeMap.put(tempUnique,tempCount);
                }else{
                    infraLine1.FSM_GridNo__c = 1;
                    infraLine1.FSM_NoOfLineItemsEformsOfSameType__c = 1;//IF GridNumber populated then match no of line item with GridNumber, added as part of SFI-2974 by Subir Maji 22nd Oct 24
                    noOfLineSameTypeMap.put(tempUnique,1);
                }
            }
            
            //IF SiteNumber populated then match no of line item with SiteNumber, added as part of SFI-2974 by Subir Maji 22nd Oct 24
            if(infraLine1.FSM_SiteNumber__c != null){
                 infraLine1.FSM_NoOfLineItemsEformsOfSameType__c = infraLine1.FSM_SiteNumber__c;
            }
            //IF ValveSeqNumber populated then match no of line item with ValveSeqNumber, added as part of SFI-2974 by Subir Maji 22nd Oct 24
            if(infraLine1.FSM_ValveSeqNumber__c != null){
                infraLine1.FSM_NoOfLineItemsEformsOfSameType__c = infraLine1.FSM_ValveSeqNumber__c;
            }else if(infraValveRecordTypeId == allParentRecord.get(infraLine1.FSM_DataCaptureFormInfra__c).RecordTypeId){ //If Parent record type is valve and line item don't have vanve seq number then make the field blank
                infraLine1.FSM_NoOfLineItemsEformsOfSameType__c = null;
            }
        }
    }
}
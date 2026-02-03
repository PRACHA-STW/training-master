/**********************************************************************************************************
@Author      :  Subir Maji
@Description : This Class is going Populate Polygon field in Service Appointmnet, getting called from SA After trigger flow.
@Description : Created as part of user story #SFL-68
@Test Class  : FSM_GetPolygonTest
@Date        : 17-Nov-2024
********************************************************************************************************/
public with sharing class FSM_GetPolygon {
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This is invocable method getting called from SA After trigger flow.
    @Description : Created as part of user story #SFL-68
    @Date        : 17-Nov-2024
    ********************************************************************************************************/ 
    public static void populatePolygon(Map<ServiceAppointment,Boolean> allServiceAppointment, Map<Id, ServiceTerritory> allterritory){
        Map<ServiceAppointment, String> allSKTbasedSA= new Map<ServiceAppointment, String>(); //Collect all SA need to check for Standard Text Key
        Set<String> allSTK = new Set<String>(); //Collect all Standard Text Key
        Set<String> allServTerritory = new Set<String>(); //Collect All territory where STK need to be checked
        List<FSM_PolygonStandardTextKey__c> allSTKDetails; //Collect all Polygon Standard Text Key records based on territory and STK from WO
        Boolean stkPresentforST = false; //If STK present in ST then this will set to True
        Map<ServiceAppointment, Boolean> allAppointmentsForError = new Map<ServiceAppointment, Boolean>(); //All SA where Error log needs to be created where either map polygon not found or STK not found
        List<ServiceAppointment> allAppointmentsForPolygonSearch = new List<ServiceAppointment>(); //All SA where Polygon need to be searched
        List<ServiceAppointment> allAppointmentsToBeUpdated = new List<ServiceAppointment>(); //All appointments to be updated with valid polygon
        Id polygonID; //Polygon record Id to be updated in SA
        Integer count = 0;//Get Count of List Index
        Set<String> saExternalID = new Set<String>(); //Collect all Sa external IDs;
        
        //go through all input records and populate relavant variables
        for(ServiceAppointment sa : allServiceAppointment.KeySet()){
            if(allServiceAppointment.get(sa)){
                allSKTbasedSA.Put(sa, sa.FSM_StandardTextKey__c);
                allSTK.add(sa.FSM_StandardTextKey__c);
                allServTerritory.add(sa.ServiceTerritoryId);
            }
            allAppointmentsForPolygonSearch.add(sa);
            saExternalID.add(sa.FSM_ExternalId__c);
        }
        
        //Query Polygon STK based on STK from WO and Service Territory
        if(allSTK != null && !allSTK.isEmpty() && !allServTerritory.isEmpty()){
            allSTKDetails = [Select ID, Name, FSM_ServiceTerritory__c 
                             from FSM_PolygonStandardTextKey__c 
                             Where Name IN: allSTK
                             AND FSM_ServiceTerritory__c IN : allServTerritory WITH SECURITY_ENFORCED];
            
            //Go through Polygon STK to check if relavant STK present for ST or not
            if(allSTKDetails != null && !allSTKDetails.isEmpty()){
                for(ServiceAppointment servApp : allSKTbasedSA.KeySet()){
                    stkPresentforST = false;
                    for(FSM_PolygonStandardTextKey__c stk : allSTKDetails){
                        if(stk.Name == allSKTbasedSA.get(servApp) && stk.FSM_ServiceTerritory__c == servApp.ServiceTerritoryId){
                            stkPresentforST = true;
                            break;
                        }
                    }
                    if(!stkPresentforST){ //STK not found then raise error log
                        allAppointmentsForError.put(servApp, true);
                        count = allAppointmentsForPolygonSearch.indexOf(servApp);
                        allAppointmentsForPolygonSearch.remove(count);
                    }
                }
            }else{ //No STK record then raise error log for all records
                 for(ServiceAppointment servApp : allSKTbasedSA.KeySet()){
                    allAppointmentsForError.put(servApp, true);
                    count = allAppointmentsForPolygonSearch.indexOf(servApp);
                    allAppointmentsForPolygonSearch.remove(count);
                }
            }
        }
        
        //Call method to get the relavant polygons
        if(allAppointmentsForPolygonSearch != null && !allAppointmentsForPolygonSearch.isEmpty()){
            for(ServiceAppointment servApp : allAppointmentsForPolygonSearch){
                polygonID = getPolygon(servApp);
                if(polygonID == null){// if no polygon then errolog need to be created
                    allAppointmentsForError.put(servApp, false);
                }else{
                    servApp.FSM_Polygon__c = polygonID;
                }
            }
        }
        
        //Update SA or create Error log
        try{
            if(allAppointmentsForError != null && !allAppointmentsForError.isEmpty()){
                createErrorLog(allAppointmentsForError, allterritory);
            }
        }catch(exception ex){
            new FSM_Utility.ErrorLogCreator().setClassName('FSM_GetPolygon').setErrorMessage(ex.getMessage()).setLineNumber(string.valueof(ex.getLineNumber())).setExternalID(String.Valueof(saExternalID)).setMethodName('populatePolygon').setStackTrace(ex.getStackTraceString()).setType('Integration').create();
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This Method will get the polygon for Individual record
    @Description : Created as part of user story #SFL-68
	@input		 : servApp
	@output		 : id
    @Date        : 17-Nov-2024
    ********************************************************************************************************/ 
    Private static Id getPolygon(ServiceAppointment servApp){
        Double longitude = servApp.longitude;
        Double latitude = servApp.latitude;
        Id polygonID = null;
        //Call Standarda method to get the polygons    
        List<FSL__Polygon__c> relevantPolygons = FSL.PolygonUtils.getAllPolygonsByLatLong(longitude, latitude);
        
        //Check if relavat polygon found based on Setvice territory
        if(relevantPolygons != null && !relevantPolygons.isEmpty()){
            for(FSL__Polygon__c poly : relevantPolygons){
                if(poly.FSL__Service_Territory__c == servApp.ServiceTerritoryId){
                    polygonID = poly.Id;
                }
            }
        }
        return polygonID;        
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This Method will get the polygon for Individual record
    @Description : Created as part of user story #SFL-68
	@input		 : allErrorSA
	@Date        : 17-Nov-2024
    ********************************************************************************************************/ 
    Private static Void createErrorLog(Map<ServiceAppointment, Boolean> allErrorSA, Map<Id, ServiceTerritory> allterritory){
        List<FSM_ErrorLog__c> allErrLog = new List<FSM_ErrorLog__c>();
        FSM_ErrorLog__c errLog;
        String errorMsg;
        
        for(ServiceAppointment servApp : allErrorSA.keyset()){
            if(allErrorSA.get(servApp)){ //Create error log for STk not found
                errorMsg = 'Working  Sub Area not found for Service Territory- '+allterritory.get(servApp.ServiceTerritoryId).FSM_ExternalId__c + '.';
                errLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_GetPolygon').setErrorMessage(errorMsg).setExternalID(servApp.FSM_ExternalId__c).setMethodName('createErrorLog').setType('Integration').returnWithoutCreate();
                errLog.FSM_ErrorType__c = 'Warning';
                allErrLog.add(errLog);
            }else{ //Create error log for Polygon not found
                errorMsg = 'No relevant Map Polygons found for Latitude-'+servApp.Latitude+' and Longitide-' +servApp.Longitude+'.';
                errLog = new FSM_Utility.ErrorLogCreator().setClassName('FSM_GetPolygon').setErrorMessage(errorMsg).setExternalID(servApp.FSM_ExternalId__c).setMethodName('createErrorLog').setType('Integration').returnWithoutCreate();
                errLog.FSM_ErrorType__c = 'Warning';
                allErrLog.add(errLog);
            }
        }
        
        if(!allErrLog.isEmpty()){
            if (SObjectType.FSM_ErrorLog__c.isCreateable()) {
                Insert allErrLog;
            }
        }
    }
}
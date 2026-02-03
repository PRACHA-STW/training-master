/**----------------------------------------------------
* @description :  This class is used as a factory test class to hold methods for data creation.              
* @group      :  Capgemini
* ver    Date                Author             Modification
1.0    7th July 2023       Srikanth Palla      Created #SFS-318
1.1    24-July-2023      Himanshu Dobriyal     Updated as part of US-468 added appointmentdependency, 
dcf infra, non infra,TMA permit, Tma permit condition creator
1.2    24-July-2023      Srikanth Palla        Updated as part of SFI-261
1.3    8th august 2023  Manish                 Updated as a part of SFI-35
1.4    22nd Feb 2024     Leena                 Updated as a part of SFS-4514
	14/01/2025 Rijita	Updated as a part of SFL-141
    08-July-2025 Vishesh Updated as a part of SFL-889
--------------------------------------------------*/
@isTest
public class FSM_TestDataFactory {
    /*Create Shift*/
    public class ShiftCreator{
        Shift item;
        public ShiftCreator(){
            item = new Shift();
        }
        public ShiftCreator setStatus(String status){
            item.Status = status;
            return this;
        }
        public ShiftCreator setStartTime(DateTime startTime){
            item.StartTime = startTime;
            return this;
        }
        public ShiftCreator setEndTime(DateTime endTime){
            item.EndTime = endTime;
            return this;
        }
        public ShiftCreator setTimeSlotType(String timeSlotType){
            item.TimeSlotType = timeSlotType;
            return this;
        }
        public ShiftCreator setServiceResourceId(String serviceResourceId){
            item.ServiceResourceId = serviceResourceId;
            return this;
        }
        public Shift create() {
            insert item;
            return item;
        }
        public Shift returnWithoutCreate() {
            return item;
        }
    }
    
    /*Create Account*/
    public class AccountCreator{
        Account item;
        public AccountCreator(){
            item = new Account();
        }
        public AccountCreator setName(String name){
            item.Name = name;
            return this;
        }
        public Account create() {
            insert item;
            return item;
        }
        public Account returnWithoutCreate() {
            return item;
        }
    }
    
    /*Create Contact*/
    public class ContactCreator{
        Contact item;
        public ContactCreator(){
            item = new Contact();
        }
        public ContactCreator setFirstName(String firstname){
            item.FirstName = firstname;
            return this;
        }
        public ContactCreator setLastName(String lastname){
            item.lastName = lastname;
            return this;
        }
        public ContactCreator setAccount(Id accID){
            item.AccountID = accID;
            return this;
        }
        public ContactCreator setEmail(string email){
            item.Email = email;
            return this;
        }
        public Contact create() {
            insert item;
            return item;
        }
        public Contact returnWithoutCreate() {
            return item;
        }
    }
    
    /*Create Work Order history*/
    /*Subir Maji, 30th May 2024, SFI-2065*/
    public class WorkHistoryCreator{
        FSM_WorkHistory__c item;
        public WorkHistoryCreator(){
            item = new FSM_WorkHistory__c();
        }
        public WorkHistoryCreator setExternalID(String externalID){
            item.FSM_ExternalId__c = externalID;
            return this;
        }
        public WorkHistoryCreator setWorkOrder(Id woID){
            item.FSM_WorkOrder__c = woID;
            return this;
        }
        public FSM_WorkHistory__c create() {
            insert item;
            return item;
        }
        public FSM_WorkHistory__c returnWithoutCreate() {
            return item;
        }
    }
    
    /*Create SA*/
    public class ServiceAppointmentCreator{
        ServiceAppointment item;
        public ServiceAppointmentCreator(){
            item = new ServiceAppointment();
        }
        public ServiceAppointmentCreator setRecordType(Id recordTypeId){
            item.RecordTypeId = recordTypeId;
            return this;
        }
        public ServiceAppointmentCreator setServiceTerritory(String stId){
            item.ServiceTerritoryId = stId;
            return this;
        }
        public ServiceAppointmentCreator setScheduledStart(DateTime schstrt){
            item.SchedStartTime = schstrt;
            return this;
        }
        public ServiceAppointmentCreator setScheduledEnd(DateTime schend){
            item.SchedEndTime = schend;
            return this;
        }
        public ServiceAppointmentCreator setParentRecordId(Id parentRecordId){
            item.ParentRecordId = parentRecordId;
            return this;
        }
        public ServiceAppointmentCreator setStatus(string status){
            item.Status = status;
            return this;
        }
        public ServiceAppointmentCreator setEarliestStartTime(Datetime earliestStartTime){
            item.EarliestStartTime = earliestStartTime;
            return this;
        }
        public ServiceAppointmentCreator setDueDate(Datetime dueDate){
            item.DueDate = dueDate;
            return this;
        }
        public ServiceAppointmentCreator setDurationType(string durationType){
            item.DurationType = durationType;
            return this;
        }
        public ServiceAppointmentCreator setDuration(double duration){
            item.duration = duration;
            return this;
        }
        public ServiceAppointmentCreator setLatitude(double latitude){
            item.Latitude = latitude;
            return this;
        }
        public ServiceAppointmentCreator setLongitude(double longitude){
            item.Longitude = longitude;
            return this;
        }
        public ServiceAppointmentCreator setMapPolygon(Id polygon){
            item.FSM_Polygon__c = polygon;
            return this;
        }
        public ServiceAppointmentCreator setServiceResource(Id sr){
            item.FSSK__FSK_Assigned_Service_Resource__c=sr;
            return this;
        }
        public ServiceAppointmentCreator setPostalCode(String postCode){
            item.PostalCode=postCode;
            return this;
        }
        public ServiceAppointmentCreator setBusinessAreaMailjet(String businessAreaMailjet){
            item.FSM_BusinessAreaMailjet__c=businessAreaMailjet;
            return this;
        }
        public ServiceAppointmentCreator setCustomerEmail(String customerEmail){
            item.FSM_CustomerEmail__c=customerEmail;
            return this;
        }
        public ServiceAppointmentCreator setCustomerName(String customerName){
            item.FSM_CustomerName__c=customerName;
            return this;
        }
        public ServiceAppointmentCreator setListOfTemplates(String listOfTemplates){
            item.FSM_ListOfTemplates__c=listOfTemplates;
            return this;
        }
        public ServiceAppointmentCreator setCustomerEmail1(String customerEmail1){
            item.FSM_CustomerEmail1__c=customerEmail1;
            return this;
        }
        public ServiceAppointmentCreator setCustomerEmail2(String customerEmail2){
            item.FSM_CustomerEmail2__c=customerEmail2;
            return this;
        }
        public ServiceAppointmentCreator setCustomerEmail3(String customerEmail3){
            item.FSM_CustomerEmail3__c=customerEmail3;
            return this;
        }
        public ServiceAppointmentCreator setCustomerEmail4(String customerEmail4){
            item.FSM_CustomerEmail4__c=customerEmail4;
            return this;
        }
        public ServiceAppointmentCreator setCustomerEmail5(String customerEmail5){
            item.FSM_CustomerEmail5__c=customerEmail5;
            return this;
        }
        public ServiceAppointmentCreator setIsBundle(Boolean isBundle){
            item.IsBundle=isBundle;
            return this;
        }
        public ServiceAppointmentCreator setIsBundleMember(Boolean IsBundleMember){
            item.IsBundleMember=isBundleMember;
            return this;
        }
        public ServiceAppointmentCreator setRelatedBundleId(Id relatedBundleId){
            item.RelatedBundleId=relatedBundleId;
            return this;
        }
        public ServiceAppointmentCreator setDuringVisitWeFound(String duringVisit){
            item.FSM_NetTechDuringVisitWeFound__c=duringVisit;
            return this;
        }
        public ServiceAppointmentCreator setArrivialStart(DateTime arrivialStart){
            item.ArrivalWindowStartTime=arrivialStart;
            return this;
        }
        public ServiceAppointmentCreator setArrivialEnd(DateTime arrivialEnd){
            item.ArrivalWindowEndTime=arrivialEnd;
            return this;
        }
        public ServiceAppointment create() {
            insert item;
            return item;
        }
        public ServiceAppointment returnWithoutCreate() {
            return item;
        }
    }
    /*Create WorkOrder */
    public class WorkOrderCreator {
        WorkOrder item;
        public WorkOrderCreator() {
            item = new WorkOrder();
        }
        public WorkOrderCreator setRecordType(Id recordTypeId){
            item.RecordTypeId = recordTypeId;
            return this;
        }
        public WorkOrderCreator setCaseId(Id caseId){
            item.CaseId = caseId;
            return this;
        }
        public WorkOrderCreator setServiceOrderType(String serviceOrderType){
            item.FSM_ServiceOrderType__c=serviceOrderType;
            return this;
        }
        
        public WorkOrderCreator setServiceTerritory(Id serviceTerritoryId){
            item.ServiceTerritoryId = serviceTerritoryId;
            return this;
        }
        public WorkOrderCreator setExternalId(String externalID){
            item.FSM_ExternalId__c=externalID;
            return this;
        }
        public WorkOrderCreator setStartDate(Datetime stDate){
            item.StartDate=stDate;
            return this;
        }
        public WorkOrderCreator setEndDate(Datetime endDate){
            item.EndDate=endDate;
            return this;
        }
        public WorkOrderCreator setSuitability(string suitability){
            item.FSM_Suitability__c=suitability;
            return this;
        }
         public WorkOrderCreator setNoticeState(string noticestate){
            item.FSM_NoticeState__c=noticestate;
            return this;
        }
        
        
        public WorkOrderCreator setEsating(Decimal easting){
            item.FSM_Easting__c=easting;
            return this;
        }
        public WorkOrderCreator setNorthing(Decimal northing){
            item.FSM_Northing__c=northing;
            return this;
        }
        public WorkOrderCreator setDuration(Integer duration){
            item.Duration=duration;
            return this;
        }
        public WorkOrderCreator setBusinessUnit(String businessUnit){
            item.FSM_BusinessUnit__c=businessUnit;
            return this;
        }
        public WorkOrderCreator standardTextKey(String standardTextKey){
            item.FSM_StandardTextKey__c=standardTextKey;
            return this;
        }
        public WorkOrderCreator setLatitude(double latitude){
            item.Latitude = latitude;
            return this;
        }
        public WorkOrderCreator setLongitude(double longitude){
            item.Longitude = longitude;
            return this;
        }
        public WorkOrderCreator setStatus(String status){
            item.Status = status;
            return this;
        }
        public WorkOrderCreator setPermit(Id permit){
            item.FSM_TMAPermit__c = permit;
            return this;
        }
        public WorkOrderCreator setPriority(String priority){
            item.Priority = priority;
            return this;
        }
        public WorkOrderCreator setSlaDate(Datetime slaDate){
            item.SlaStartDate=slaDate;
            return this;
        }
        public WorkOrderCreator setOpenDate(Datetime openDate){
            item.FSM_OpenDate__c=openDate;
            return this;
        }
        public WorkOrderCreator setgeneratepdf(Boolean isgeneratepdf){
            item.FSM_GeneratePDF__c=isgeneratepdf;
            return this;
        }
        public WorkOrderCreator setpdfFilename(String pdfname){
            item.FSM_FileName__c=pdfname;
            return this;
        }
        public WorkOrderCreator setdeviceType(String device){
            item.FSM_DeviceType__c=device;
            return this;
        }
        public WorkOrderCreator setFloc(String floc){
            item.FSM_Floc__c=floc;
            return this;
        }
        public WorkOrderCreator setTemporaryRecord(boolean TemporaryRecord){
            item.FSM_IsTemporaryRecord__c=TemporaryRecord;
            return this;
        }
        public WorkOrderCreator setCreatedDate(Datetime CreatedDt){
            item.CreatedDate=CreatedDt;
            return this;
        }
        public WorkOrderCreator setMinimumCrewSize(Integer crewsize){
            item.MinimumCrewSize=crewsize;
            return this;
        }
        public WorkOrderCreator setContactId(String contactId){
            item.FSM_ContactID__c = contactId;
            return this;
        }
        public WorkOrderCreator setContactName(String contactName){
            item.FSM_ContactName__c = contactName;
            return this;
        }
        public WorkOrderCreator setContactEmail(String contactEmail){
            item.FSM_ContactEmail__c = contactEmail;
            return this;
        }
        public WorkOrderCreator setContactPhone(String contactPhone){
            item.FSM_ContactPhoneNumber__c = contactPhone;
            return this;
        }
        public WorkOrderCreator setSpecialCondition(String specialCondition){
            item.FSM_SpecialCondition__c = specialCondition;
            return this;
        }
        public WorkOrderCreator setMSN(String msn){
            item.FSM_ManufacturersSerialNumber__c = msn;
            return this;
        }
        public WorkOrderCreator setJobSla(Double jobSLA){
            item.FSM_JobSLA__c = jobSLA;
            return this;
        }
        public WorkOrderCreator setSlaUnitOfMeasure(String slaUnitOfMeasure){
            item.FSM_JobSLAUnitOfMeasure__c = slaUnitOfMeasure;
            return this;
        }
        public WorkOrderCreator setWorkTypeCode(String worktypeCode){
            item.FSM_WorkTypeCode__c = worktypeCode;
            return this;
        }
         public WorkOrderCreator setTma(id tmaId){
            item.FSM_TMAPermit__c = tmaId;
            return this;
        }
        public WorkOrder create() {
            insert item;
            return item;
        }
        public WorkOrder returnWithoutCreate() {
            return item;
        }
        
    }
    
    /*Create Case */
    public class CaseCreator {
        Case item;
        public CaseCreator() {
            item = new Case();
        }
        public CaseCreator setContactName(String contactName){
            item.FSM_ContactName__c = contactName;
            return this;
        }
        public CaseCreator setContactEmail(String contactEmail){
            item.FSM_ContactEmail__c = contactEmail;
            return this;
        }
        public CaseCreator setContactId(String contactId){
            item.FSM_ContactID__c = contactId;
            return this;
        }
        public CaseCreator setContactPhoneNumber(String contactPhone){
            item.FSM_ContactPhoneNumber__c = contactPhone;
            return this;
        }
        public CaseCreator setSpecialCondition(String specialCondition){
            item.FSM_SpecialCondition__c = specialCondition;
            return this;
        }
        public CaseCreator setMSN(String msn){
            item.FSM_MSN__c = msn;
            return this;
        }
        public CaseCreator setStatus(String status){
            item.Status = status;
            return this;
        }
        public CaseCreator setOrigin(String origin){
            item.Origin = origin;
            return this;
        }
        public CaseCreator setDescription(String des){
            item.Description = des;
            return this;
        }
        public CaseCreator setTMA(ID tmaID){
            item.FSM_TMAPermit__c = tmaID;
            return this;
        }
        public Case create() {
            insert item;
            return item;
        }
        public Case returnWithoutCreate() {
            return item;
        }
    }
    
    /*Create Polygon STK */
    public class PolygonSTKCreator {
        FSM_PolygonStandardTextKey__c item;
        public PolygonSTKCreator() {
            item = new FSM_PolygonStandardTextKey__c();
        }
        public PolygonSTKCreator setName(String stkName){
            item.Name = stkName;
            return this;
        }
        public PolygonSTKCreator setServiceTerritory(String stID){
            item.FSM_ServiceTerritory__c = stID;
            return this;
        }
        public FSM_PolygonStandardTextKey__c create() {
            insert item;
            return item;
        }
        public FSM_PolygonStandardTextKey__c returnWithoutCreate() {
            return item;
        }
    }
    
    
    /*Create OperatingHours*/
    public Class OperatingHoursCreator{
        OperatingHours item;
        public OperatingHoursCreator(){
            item=new OperatingHours();
        }
        
        public OperatingHoursCreator setName(string name){
            item.Name=name;
            return this;
        }
        
        public OperatingHoursCreator setTimeZone(String timeZone){
            item.TimeZone = timeZone;
            return this;
        }
        
        public OperatingHoursCreator setSlotType(string slotType){
            item.FSM_SlotType__c=slotType;
            return this;
        }
        
        public OperatingHoursCreator setBusinessUnit(string businessUnit){
            item.FSM_BusinessUnit__c=businessUnit;
            return this;
        }
        
        public OperatingHours create(){
            insert item;
            return item;
        }
        
        public OperatingHours returnWithoutCreate(){
            return item;
        }
    }
    
    /*Create Task
Added as part of SFI-1821*/
    public class TaskCreator{
        Task item;
        public TaskCreator(){
            item=new Task();
        }
        public TaskCreator setWhatId(Id whatId){
            item.WhatId=whatId;
            return this;
        }
        public TaskCreator setType(String type){
            item.Type=type;
            return this;
        }
        public TaskCreator setStatus(String status){
            item.Status=status;
            return this;
        }
        public Task create() {
            insert item;
            return item;
        }
        public Task returnWithoutCreate() {
            return item;
        }
    }
    
    /*Create Scheduling Policy
Added As part of SFI-261*/
    public Class SchedulingPolicyCreator{
        FSL__Scheduling_Policy__c item;
        public SchedulingPolicyCreator(){
            item=new FSL__Scheduling_Policy__c();
        }
        
        public SchedulingPolicyCreator setName(string name){
            item.Name=name;
            return this;
        }
        public SchedulingPolicyCreator setBusinessUnit(string bu){
            item.FSM_BusinessUnit__c=bu;
            return this;
        }
        public SchedulingPolicyCreator setExternalid(string extid){
            item.FSM_ExternalId__c=extid;
            return this;
        }
        
        
        public FSL__Scheduling_Policy__c create(){
            insert item;
            return item;
        }
        
        public FSL__Scheduling_Policy__c returnWithoutCreate(){
            return item;
        }
    }
    
    /*Create ServiceTerritory*/
    public Class ServiceTerritoryCreator{
        ServiceTerritory item;
        public ServiceTerritoryCreator(){
            item=new ServiceTerritory();
        }
        public ServiceTerritoryCreator setName(String name){
            item.Name=name;
            return this;
        }
        public ServiceTerritoryCreator setOpreratingHours(Id ohId){
            item.OperatingHoursId=ohId;
            return this;
        }
        public ServiceTerritoryCreator setOpreratingHours2HourSlot(Id ohId){
            item.FSM_OperatingHours2Hr__c=ohId;
            return this;
        }
        public ServiceTerritoryCreator setSchedulingPolicy(Id spId){
            item.FSM_SchedulingPolicy__c=spId;
            return this;
        }
        public ServiceTerritoryCreator setExtenalId(string externalId){
            item.FSM_ExternalId__c=externalId;
            return this;
        }
        public ServiceTerritoryCreator setAutoSchedulingPolicy(Id aspId){
            item.FSM_AutoSchedulePolicy__c = aspId;
            return this;
        }
        public ServiceTerritoryCreator setWorkingSubAreaRequired(Boolean wsaReqd){
            item.FSM_WorkingSubAreaRequired__c = wsaReqd;
            return this;
        }
        public ServiceTerritoryCreator setispolygonbasedonstdtxtkey(Boolean isreq){
            item.FSM_IsPolygonBasedOnStandardTextKey__c = isreq;
            return this;
        }
        public ServiceTerritoryCreator setBusinessUnit(String businessUnit){
            item.FSM_BusinessUnit__c = businessUnit;
            return this;
        }
        public ServiceTerritoryCreator setNumberOfDaysToDispatch(String numberOfDaysToDispatch){
            item.FSM_NumberOfDaysToDispatch__c = numberOfDaysToDispatch;
            return this;
        }
        public ServiceTerritoryCreator setNumberOfSAToDispatch(String numberOfSAToDispatch){
            item.FSM_NumberOfSAToDispatch__c = numberOfSAToDispatch;
            return this;
        }
        public ServiceTerritoryCreator setIsActive(boolean isActive){
            item.IsActive=isActive;
            return this;
        }
        public ServiceTerritoryCreator setTerritoryLevel(Integer level){
            item.FSL__TerritoryLevel__c=level;
            return this;
        }
        public ServiceTerritoryCreator setGISLayerId(String layerId){
            item.FSM_GISLayerID__c=layerId;
            return this;
        }
        public ServiceTerritory create(){
            insert item;
            return item;
        }
        public ServiceTerritory returnWithoutCreate(){
            return item;
        }
    }
    
    /*Create ServiceResource*/
    public Class ServiceResourceCreator{
        ServiceResource item;
        public ServiceResourceCreator(){
            item=new ServiceResource();
        }
        public ServiceResourceCreator setName(string name){
            item.Name=name;
            return this;
        }
        public ServiceResourceCreator setIsActive(boolean isActive){
            item.IsActive=isActive;
            return this;
        }
        public ServiceResourceCreator setRelatedRecordId(Id relatedRecordId){
            item.RelatedRecordId=relatedRecordId;
            return this;
        }
        public ServiceResourceCreator setExternalId(String externalID){
            item.FSM_ExternalId__c=externalID;
            return this;
        }
        public ServiceResourceCreator setIsOptimizationCapable(Boolean isOptCapable){
            item.IsOptimizationCapable = isOptCapable;
            return this;
        }
        public ServiceResourceCreator setBusinessUnit(String businessUnit){
            item.FSM_BusinessUnit__c =businessUnit;
            return this;
        }
        public ServiceResourceCreator setPhone(String phone){
            item.FSM_Phone__c =phone;
            return this;
        }
        //added as part of SFL-885
        public ServiceResourceCreator setResourceType(String type){
            item.ResourceType = type;
            return this;
        }
        //added as part of SFL-885
        public ServiceResourceCreator setServiceCrewId(Id crewId){
            item.ServiceCrewId = crewId;
            return this;
        }
        public ServiceResource create(){
            insert item;
            return item;
        }
        //added as part of SFL-889
        public ServiceResource returnWithoutCreate(){
            return item;
        }
    }
    
    /*Create AssignedResource*/
    public Class AssignedResourceCreator{
        AssignedResource item;
        public AssignedResourceCreator(){
            item=new AssignedResource();
        }
        public AssignedResourceCreator setServiceResource(Id srId){
            item.ServiceResourceId=srId;
            return this;
        }
        public AssignedResourceCreator setServiceAppointment(Id saId){
            item.ServiceAppointmentId=saId;
            return this;
        }
        public AssignedResource create(){
            insert item;
            return item;
        }
        //created as part of SFL-889
        public AssignedResource returnWithoutCreate(){
            return item;
        }
    }
    
    /*Create TimeSlot*/
    public Class TimeSlotCreator{
        TimeSlot item;
        public TimeSlotCreator(){
            item=new TimeSlot();
        }
        public TimeSlotCreator setDayOfWeek(string dayOfWeek){
            item.DayOfWeek=dayOfWeek;
            return this;
        }
        public TimeSlotCreator setStartTime(Time startTime){
            item.StartTime=startTime;
            return this;
        }
        public TimeSlotCreator setEndTime(Time endTime){
            item.EndTime=endTime;
            return this;
        }
        public TimeSlotCreator setOperatingHoursId(Id operatingHoursId){
            item.OperatingHoursId=operatingHoursId;
            return this;
        }
        public TimeSlot create(){
            insert item;
            return item;
        }
        
        public TimeSlot returnWithoutCreate(){
            return item;
        }
    }
    
    /*Create ServiceTerritoryMember*/
    public Class ServiceTerritoryMemberCreator{
        ServiceTerritoryMember item;
        public ServiceTerritoryMemberCreator(){
            item=new ServiceTerritoryMember();
        }
        public ServiceTerritoryMemberCreator setServiceResource(Id srId){
            item.ServiceResourceId = srId;
            return this;
        }
        public ServiceTerritoryMemberCreator setServiceTerritory(Id stId){
            item.ServiceTerritoryId = stId;
            return this;
        }
        public ServiceTerritoryMemberCreator setTerritoryType(String territoryType){
            item.TerritoryType = territoryType;
            return this;
        }
        public ServiceTerritoryMemberCreator setStartDate(Datetime startDate){
            item.EffectiveStartDate = startDate;
            return this;
        }
        public ServiceTerritoryMemberCreator setCountry(String country){
            item.Country = country;
            return this;
        }
        public ServiceTerritoryMemberCreator setPostalCode(String postalCode){
            item.PostalCode = postalCode;
            return this;
        }
        public ServiceTerritoryMemberCreator setLatitude(Double latitude){
            item.Latitude = latitude;
            return this;
        }
        public ServiceTerritoryMemberCreator setLongitude(Double longitude){
            item.Longitude = longitude;
            return this;
        }
        public ServiceTerritoryMember create(){
            insert item;
            return item;
        }
        //created as part of SFL-889
        public ServiceTerritoryMember returnWithoutCreate() {            
            return item;
        }
    }
    
    /*Create Map Polygon*/
    Public Class MapPolygonCreator{
        FSL__Polygon__c item;
        public MapPolygonCreator(){
            item = new FSL__Polygon__c();
        }
        public MapPolygonCreator setName(String name){
            item.Name = name;
            return this;
        }
        public MapPolygonCreator setBusinessUnit(String businessUnit){
            item.FSM_BusinessUnit__c = businessUnit;
            return this;
        }
        public MapPolygonCreator setTerritory(String territory){
            item.FSL__Service_Territory__c = territory;
            return this;
        }
        public MapPolygonCreator setDescription(String description){
            item.FSL__Description__c = description;
            return this;
        }
        public MapPolygonCreator setColour(String colour){
            item.FSL__Color__c = colour;
            return this;
        }
        public MapPolygonCreator setMaxLatitude(Decimal maxLat){
            item.FSL__Ma_La__c = maxLat;
            return this;
        }
        public MapPolygonCreator setMaxLongitude(Decimal maxLong){
            item.FSL__Ma_Lo__c = maxLong;
            return this;
        }
        public MapPolygonCreator setMinLatitude(Decimal minLat){
            item.FSL__Mi_La__c = minLat;
            return this;
        }
        public MapPolygonCreator setMinLongitude(Decimal minLong){
            item.FSL__Mi_Lo__c = minLong;
            return this;
        }
        public MapPolygonCreator setKML(String kml){
            item.FSL__KML__c = kml;
            return this; 
        }
        public FSL__Polygon__c create(){
            insert item;
            return item;
        }
        public FSL__Polygon__c returnWithoutCreate() {            
            return item;
        }
    }
    
    /*Create WorkingSubAreaCoverage*/
    public Class WorkingSubAreaCoverageCreator{
        FSM_WorkingSubAreaCoverage__c item;
        public WorkingSubAreaCoverageCreator(){
            item = new FSM_WorkingSubAreaCoverage__c();
        }
        public WorkingSubAreaCoverageCreator setMapPolygon(Id poly){
            item.FSM_Polygon__c = poly;
            return this; 
        }
        public WorkingSubAreaCoverageCreator setServiceResource(Id srId){
            item.FSM_ServiceResource__c = srId;
            return this;
        }  
        public WorkingSubAreaCoverageCreator setStartDate(DateTime startDate){
            item.FSM_StartDate__c = startDate;
            return this;
        }
        public WorkingSubAreaCoverageCreator setEndDate(DateTime endDate){
            item.FSM_EndDate__c = endDate;
            return this;
        }
        public FSM_WorkingSubAreaCoverage__c create(){
            insert item;
            return item;
        }
    }
    
    /*Create User*/
    public Class CretaeUser{
        User item;
        public CretaeUser(){
            item= new User();
            item.FirstName='Test';
            item.LastName = 'User';
            item.Email = 'johndoe@example.com';
            item.Username = 'johndoeTestuser@'+UserInfo.getOrganizationId()+'.stw.com';
            item.Alias = 'jdoe';
            item.CommunityNickname = 'johndoe';
            item.TimeZoneSidKey = 'America/Los_Angeles';
            item.LanguageLocaleKey = 'en_US';
            item.EmailEncodingKey = 'UTF-8';
            item.LocaleSidKey = 'en_US';
            item.IsActive = true;
            item.ProfileId = [SELECT Id FROM Profile where Name='Standard User' LIMIT 1].Id;
            item.FSM_ExternalId__c = 'TestId';
        }
        public User create() {
            insert item;
            return item;
        }
    }
    
    /*Create User*/
    public Class CreatePortalUser{
        User item;
        public CreatePortalUser(){
            item= new User();
            item.FirstName='Test';
            item.LastName = 'User';
            item.Email = 'johndoe1@example.com';
            item.Username = 'johndoe1Testuser@gmail.com';
            item.Alias = 'jdoe1';
            item.CommunityNickname = 'johndoe1';
            item.TimeZoneSidKey = 'America/Los_Angeles';
            item.LanguageLocaleKey = 'en_US';
            item.EmailEncodingKey = 'UTF-8';
            item.LocaleSidKey = 'en_US';
            item.IsActive = true;
            //  item.ProfileId = [SELECT Id FROM Profile where Name='FSM Customer Community Plus User' LIMIT 1].Id;
            item.ProfileId = [SELECT Id FROM Profile where Name LIKE 'Customer Community%' OR Name LIKE '%Customer Community' OR Name LIKE '%Customer Community%' LIMIT 1].Id;
        }
        public User create() {
            insert item;
            return item;
        }
        public User returnWithoutCreate() {            
            return item;
        }
    }
    
    /*Create User Custom*/
    public Class CretaeUserCustom{
        User item;
        public CretaeUserCustom(string alias, string userName, string nickName, Id profileID){
            item= new User();
            item.FirstName='Test';
            item.LastName = 'User';
            item.Email = 'johndoe@example.com';
            item.Username = userName;
            item.Alias = alias;
            item.CommunityNickname = nickName;
            item.TimeZoneSidKey = 'America/Los_Angeles';
            item.LanguageLocaleKey = 'en_US';
            item.EmailEncodingKey = 'UTF-8';
            item.LocaleSidKey = 'en_US';
            item.IsActive = true;
            item.ProfileId = profileID;
            item.FSM_ExternalId__c = userName; //14/01/2025 Rijita	Updated as a part of SFL-141
        }
        public User create() {
            insert item;
            return item;
        }
        public User returnWithoutCreate() {            
            return item;
        }
    }
    
    /*Create WorkPlanTemplate*/
    /*Added as part of SFI-24*/
    public class WorkPlanTemplateCreator {
        WorkPlanTemplate item;
        public WorkPlanTemplateCreator() {
            item = new WorkPlanTemplate();
        }
        public WorkPlanTemplateCreator setName(String name){
            item.Name = name;
            return this;
        }
        public WorkPlanTemplateCreator setIsActive(Boolean isActive){
            item.isActive  = isActive;
            return this;
        }
        public WorkPlanTemplate create() {
            insert item;
            return item;
        }
    }
    
    /*Create WorkStepTemplate*/
    /*Added as part of SFI-24*/
    public class WorkStepTemplateCreator {
        WorkStepTemplate item;
        public WorkStepTemplateCreator() {
            item = new WorkStepTemplate();
        }
        public WorkStepTemplateCreator  setName(String name){
            item.Name = name;
            return this;
        }
        public WorkStepTemplateCreator setIsActive(Boolean isActive){
            item.isActive  = isActive;
            return this;
        }
        public WorkStepTemplate create() {
            insert item;
            return item;
        }
    }
    
    /*Create WorkPlanTemplateEntry*/
    /*Added as part of SFI-24*/
    public class WorkPlanTemplateEntryCreator {
        WorkPlanTemplateEntry item;
        public WorkPlanTemplateEntryCreator() {
            item = new WorkPlanTemplateEntry();
        }
        public WorkPlanTemplateEntryCreator setWorkPlanTemplateId (ID workPlanTemplateId ){
            item.WorkPlanTemplateId = workPlanTemplateId;
            return this;
        }
        public WorkPlanTemplateEntryCreator setWorkStepTemplateId (ID workStepTemplateId ){
            item.WorkStepTemplateId = workStepTemplateId;
            return this;
        }
        public WorkPlanTemplateEntry create() {
            insert item;
            return item;
        }
    }
    
    /*Create ContentVersion*/
    /*Added as part of SFI-24*/
    public class ContentVersionCreator {
        ContentVersion item;
        public ContentVersionCreator() {
            item = new ContentVersion();
        }
        public ContentVersionCreator setPathOnClient (String pathOnClient ){
            item.PathOnClient = pathOnClient ;
            return this;
        }
        public ContentVersionCreator setTitle (String title){
            item.Title= title;
            return this;
        }
        public ContentVersionCreator setRelatedrecordId (String relatedId){
            item.FSM_RelatedrecordId__c= relatedId;
            return this;
        }
        public ContentVersionCreator setVersionData  (Blob versionData ){
            item.VersionData = versionData ;
            return this;
        }
        public ContentVersionCreator setDoNotSendToSAP  (Boolean sendToSAP ){
            item.FSM_Do_not_send_to_SAP__c = sendToSAP;
            return this;
        }
        public ContentVersion create() {
            insert item;
            return item;
        }
        public ContentVersion returnWithoutCreate() {
            return item;
        }
    }
    //created as part of SFS-5405
    public class WorkPlanCreator {
        WorkPlan item;
        public WorkPlanCreator() {
            item = new WorkPlan();
        }
        public WorkPlanCreator setName (string name ){
            item.Name = name;
            return this;
        }
        public WorkPlanCreator setparent (string parentid ){
            item.ParentRecordId = parentid;
            return this;
        }
        public WorkPlanCreator setWorkorder (string woId ){
            item.WorkOrderId = woId;
            return this;
        }
        public WorkPlan create() {
            insert item;
            return item;
        }
        public WorkPlan returnWithoutCreate() {
            return item;
        }
    }
    
    //created as part of SFS-5405
    public class WorkStepCreator {
        WorkStep item;
        public WorkStepCreator() {
            item = new WorkStep();
        }
        public WorkStepCreator setActionDef (string actiondef ){
            item.ActionDefinition = actiondef;
            return this;
        }
        public WorkStepCreator setWorkPlan (string workplan ){
            item.WorkPlanId = workplan;
            return this;
        }
        public WorkStepCreator setStatus (string status ){
            item.Status = status;
            return this;
        }
        public WorkStepCreator setName (string name ){
            item.Name = name;
            return this;
        }
        public WorkStep create() {
            insert item;
            return item;
        }
        public WorkStep returnWithoutCreate() {
            return item;
        }
    }
    
    /*Create Data Capture Form Infra*/
    /*Added as part of SFI-468*/
    public class DataCaptureFormInfraCreator {
        FSM_DataCaptureFormInfra__c item;
        public DataCaptureFormInfraCreator() {
            item = new FSM_DataCaptureFormInfra__c();
        }
        public DataCaptureFormInfraCreator setWorkorder(id workOrder) {
            item.FSM_WorkOrder__c = workOrder;
            return this;
        }
        public FSM_DataCaptureFormInfra__c create() {
            insert item;
            return item;
        }
        public DataCaptureFormInfraCreator setStatus(String status)
        {
            item.FSM_Status__c=status;
            return this;
        }
        public DataCaptureFormInfraCreator  setComment(String comment)
        {
            item.FSM_Comments__c=comment;
            return this;
        }
        public DataCaptureFormInfraCreator  setGeneratepdf(Boolean generatepdf)
        {
            item.FSM_Generate_PDF__c=generatepdf;
            return this;
        }
        public DataCaptureFormInfraCreator setDateTime(DateTime dt)
        {
            item.FSM_DateAndTime__c=dt;
            return this;
        }
        public DataCaptureFormInfraCreator setFormType(String formType)
        {
            item.FSM_FormType__c=formType;
            return this;
        }  
        public DataCaptureFormInfraCreator setTerritory(Id territoryId)
        {
            item.FSM_ServiceTerritory__c=territoryId;
            return this;
        } 
        public DataCaptureFormInfraCreator setResourceId(Id resourceId)
        {
            item.FSM_ServiceResource__c=resourceId;
            return this;
        }  
        public DataCaptureFormInfraCreator setRecordTypeId(Id recordTypeId)
        {
            item.RecordTypeId=recordTypeId;
            return this;
        }
        public DataCaptureFormInfraCreator setMedium(String medium)
        {
            item.FSM_Medium__c=medium;
            return this;
        }
        //
        public DataCaptureFormInfraCreator setTime(Integer hour,Integer minute,Integer second,Integer millisecond)
        {
            item.FSM_Time__c=Time.newInstance(hour, minute,second, millisecond);
            return this;
        }
        public DataCaptureFormInfraCreator setGridReference(String gridReference)
        {
            item.FSM_GridsReferenceX__c=Integer.valueOf(gridReference);
            return this;
        }
        public FSM_DataCaptureFormInfra__c returnWithoutCreate() {            
            return item;
        }
    }
    
    /*Create Data Capture Form Infra 1*/
    /*Added as part of SFI-1204*/
    public class DataCaptureFormInfra1Creator {
        FSM_InfraDataCaptureForm2__c item;
        public DataCaptureFormInfra1Creator() {
            item = new FSM_InfraDataCaptureForm2__c();
        }
        public DataCaptureFormInfra1Creator setWorkorder(id workOrder) {
            item.FSM_WorkOrder__c = workOrder;
            return this;
        }
        public DataCaptureFormInfra1Creator setMedium(String medium)
        {
            item.FSM_Medium__c=medium;
            return this;
        }
        public DataCaptureFormInfra1Creator setSiteName(String siteName)
        {
            item.FSM_SiteName__c=siteName;
            return this;
        }
        public DataCaptureFormInfra1Creator setStatus(String status){
            item.FSM_Status__c = status;
            return this;
        }
        public DataCaptureFormInfra1Creator setSWRTask(String swrTask){
            item.FSM_SWRTask__c = swrTask;
            return this;
        }
        public DataCaptureFormInfra1Creator setTerritory(Id territoryId){
            item.FSM_ServiceTerritory__c=territoryId;
            return this;
        } 
        public DataCaptureFormInfra1Creator setResourceId(Id resourceId){
            item.FSM_ServiceResource__c=resourceId;
            return this;
        }  
        public DataCaptureFormInfra1Creator setRecordTypeId(Id recordTypeId){
            item.RecordTypeId=recordTypeId;
            return this;
        }
        public DataCaptureFormInfra1Creator setSewerStatus(String sewStatus){
            item.FSM_SewerStatus__c = sewStatus;
            return this;
        }
        public DataCaptureFormInfra1Creator setSewerType(String sewType){
            item.FSM_SewerType__c = sewType;
            return this;
        }
        public FSM_InfraDataCaptureForm2__c returnWithoutCreate() {            
            return item;
        }
        public FSM_InfraDataCaptureForm2__c create() {
            insert item;
            return item;
        }
    }
    
    /*Create Data Capture Form Line Item Infra */
    /*Added as part of SFI-35*/
    public class DataCaptureFormLineItemInfraCreator {
        FSM_DCFLineItemInfra__c item;
        public DataCaptureFormLineItemInfraCreator() {
            item = new FSM_DCFLineItemInfra__c();
        }
        public DataCaptureFormLineItemInfraCreator setWorkorder(id workOrder) {
            item.FSM_WorkOrder__c = workOrder;
            return this;
        }
        public FSM_DCFLineItemInfra__c create() {
            insert item;
            return item;
        }
        public DataCaptureFormLineItemInfraCreator setRecordTypeId(Id recordId)
        {
            item.RecordTypeId=recordId;
            return this;
        }
        public DataCaptureFormLineItemInfraCreator  setUid(Integer uid)
        {
            item.FSM_UID__c=uid;
            return this;
        }
        public DataCaptureFormLineItemInfraCreator setGridRefX(Integer gridRefX)
        {
            item.FSM_GridRefX__c=gridRefX;
            return this;
        }
        public DataCaptureFormLineItemInfraCreator setJobNumber(Integer jobNumber)
        {
            item.FSM_JobNumber__c=jobNumber;
            return this;
        }  
        public DataCaptureFormLineItemInfraCreator setExternalId(String externalId)
        {
            item.FSM_ExternalId__c=externalId;
            return this;
        } 
        public DataCaptureFormLineItemInfraCreator setInfraParentId(Id infraParentId)
        {
            item.FSM_DataCaptureFormInfra__c=infraParentId;
            return this;
        } 
        public DataCaptureFormLineItemInfraCreator setCATSerial(String catSerial)
        {
            item.FSM_CATSerialNumber__c=catSerial;
            return this;
        }
        public DataCaptureFormLineItemInfraCreator setGennySerial(String gennySerial)
        {
            item.FSM_GennySerialNumber__c=gennySerial;
            return this;
        }
        public DataCaptureFormLineItemInfraCreator setValveSeqNum(Integer valvSseqNum){
            item.FSM_ValveSeqNumber__c=valvSseqNum;
            return this;
        }
        
        public FSM_DCFLineItemInfra__c  returnWithoutCreate() {            
            return item;
        }
    }
    
    /*Create Data Capture Form Line Item Infra 2 */
    /*Added as part of SFI-2041*/
    public class DataCaptureFormLineItemInfra2Creator {
        FSM_InfraDataCaptureLineItem2__c item;
        public DataCaptureFormLineItemInfra2Creator() {
            item = new FSM_InfraDataCaptureLineItem2__c();
        }
        public DataCaptureFormLineItemInfra2Creator setWorkorder(id workOrder) {
            item.FSM_WorkOrder__c = workOrder;
            return this;
        }
        public DataCaptureFormLineItemInfra2Creator setRecordTypeId(Id recordId){
            item.RecordTypeId=recordId;
            return this;
        }
        public DataCaptureFormLineItemInfra2Creator setInfraParentId(Id infraParentId){
            item.FSM_InfraDataCaptureForm2__c=infraParentId;
            return this;
        } 
        public FSM_InfraDataCaptureLineItem2__c create() {
            insert item;
            return item;
        }
        public FSM_InfraDataCaptureLineItem2__c  returnWithoutCreate() {            
            return item;
        }
    }
    
    /*Create Data Capture Form Non Infra*/
    /*Added as part of SFI-468*/
    public class DataCaptureFormNonInfraCreator {
        FSM_DataCaptureFormNonInfra__c item;
        public DataCaptureFormNonInfraCreator() {
            item = new FSM_DataCaptureFormNonInfra__c();
        }
        public FSM_DataCaptureFormNonInfra__c create() {
            insert item;
            return item;
        }
        public DataCaptureFormNonInfraCreator setWorkorder(id workOrder) {
            item.FSM_WorkOrder__c = workOrder;
            return this;
        }
        public DataCaptureFormNonInfraCreator setServiceResource(id serviceResource) {
            item.FSM_ServiceResource__c = serviceResource;
            return this;
        }
        public DataCaptureFormNonInfraCreator setStatus(String status) {
            item.FSM_Status__c = status;
            return this;
        }
        public DataCaptureFormNonInfraCreator setServiceTerritory(Id territory) {
            item.FSM_ServiceTerritory__c = Territory;
            return this;
        }
        public DataCaptureFormNonInfraCreator setRecordTypeId(Id recordType) {
            item.RecordTypeId =recordType;
            return this;
        }
        public FSM_DataCaptureFormNonInfra__c returnWithoutCreate() {            
            return item;
        }
        
    }
    
    /*Create Data Capture Form Line Item Non Infra*/
    /*Added as part of SFI-35*/
    public class DataCaptureFormLineItemNonInfraCreator {
        FSM_DCFLineItemNonInfra__c item;
        public DataCaptureFormLineItemNonInfraCreator() {
            item = new FSM_DCFLineItemNonInfra__c();
        }
        public DataCaptureFormLineItemNonInfraCreator setWorkorder(id workOrder) {
            item.WorkOrder__c = workOrder;
            return this;
        }
        public FSM_DCFLineItemNonInfra__c create() {
            insert item;
            return item;
        }
        public DataCaptureFormLineItemNonInfraCreator setRecordTypeId(Id record)
        {
            item.RecordTypeId=record;
            return this;
        }
        public DataCaptureFormLineItemNonInfraCreator  setNonInfraParent(Id nonInfraParent)
        {
            item.FSM_DataCaptureFormNonInfra__c=nonInfraParent;
            return this;
        }
        public FSM_DCFLineItemNonInfra__c  returnWithoutCreate() {            
            return item;
        }
        
    }
    
    /*Create Data Capture Form Infra*/
    /*Added as part of SFS-5399*/
    public class DataCaptureForm2Creator {
        FSM_InfraDataCaptureForm2__c item;
        public DataCaptureForm2Creator() {
            item = new FSM_InfraDataCaptureForm2__c();
        }
        public DataCaptureForm2Creator setWorkorder(id workOrder) {  
            item.FSM_WorkOrder__c = workOrder;
            return this;
        }
        public FSM_InfraDataCaptureForm2__c create() {
            insert item;
            return item;
        }
        public DataCaptureForm2Creator setStatus(String status)
        {
            item.FSM_Status__c=status;
            return this;
        }
        public DataCaptureForm2Creator  setComment(String comment)
        {
            item.FSM_Comments__c=comment;
            return this;
        }
        public DataCaptureForm2Creator  setGeneratepdf(Boolean generatepdf) 
        {
            item.FSM_Generate_PDF__c=generatepdf;
            return this;
        } 
        public DataCaptureForm2Creator setRecordTypeId(Id recordTypeId) 
        {
            item.RecordTypeId=recordTypeId;
            return this;
        }
        public DataCaptureForm2Creator setGridReference(String gridReference)
        {
            item.FSM_SFWXcoordinate__c=Integer.valueOf(gridReference);
            return this;
        }
        public FSM_InfraDataCaptureForm2__c returnWithoutCreate() {            
            return item;
        }
    }
    
    /*Create TMA permit Condition*/
    /*Added as part of SFI-468*/
    public class TMAPermitConditionsCreator {
        FSM_TMAPermitConditions__c item;
        public TMAPermitConditionsCreator() {
            item = new  FSM_TMAPermitConditions__c();
        }
        public TMAPermitConditionsCreator setTMAPermit(Id tMApermit) { 
            item.FSM_TMAPermit__c =    TMApermit;
            return this;
        }
        public FSM_TMAPermitConditions__c create() {
            insert item;
            return item;
        }
        public TMAPermitConditionsCreator returnWithoutCreate() {            
            return this;
        }
    }
    /*Create TMA Permit*/
    /*Added as part of SFI-468*/
    public class TMAPermitCreator {
        FSM_TMAPermit__c item;
        public TMAPermitCreator() {
            item = new  FSM_TMAPermit__c();
        }
           public TMAPermitCreator setHighwayAuthority(String ha) {
            item.FSM_HighwayAuthority__c = ha;
            return this;
        }
        public TMAPermitCreator setWorksCategory(String wc) {
            item.FSM_NoticeType__c = wc;
            return this;
        }
 		public TMAPermitCreator setTMAtype(String type) {
            item.FSM_Type__c = type;
            return this;
        }        
        public FSM_TMAPermit__c create() {
            insert item;
            return item;
        }
        public TMAPermitCreator returnWithoutCreate() {            
            return this;
        }
    }

    /*Create TMA Permit Notice Period Records */
    //Added as part of SFS-7965
      public class TMAPermitNoticePeriodCreator {
        FSM_TMAPermitNoticePeriods__c item;
        public TMAPermitNoticePeriodCreator() {
            item = new  FSM_TMAPermitNoticePeriods__c();
        }
           public TMAPermitNoticePeriodCreator setHighwayAuthority(String ha) {
            item.FSM_HighwayAuthority__c = ha;
            return this;
        }
        public TMAPermitNoticePeriodCreator setWorksCategory(String wc) {
            item.FSM_WorksCategory__c = wc;
            return this;
        }
 		public TMAPermitNoticePeriodCreator setNoticePeriod(Integer period) {
            item.FSM_NoticePeriod__c = period;
            return this;
        }        
        public FSM_TMAPermitNoticePeriods__c create() {
            insert item;
            return item;
        }
        public TMAPermitNoticePeriodCreator returnWithoutCreate() {            
            return this;
        }
    }
    
    /*Create Appointment Dependency*/
    /*Added as part of SFI-468*/
    public class AppointmentDependencyCreator {
        FSL__Time_Dependency__c item;
        public AppointmentDependencyCreator() {
            item = new FSL__Time_Dependency__c();
        }
        public AppointmentDependencyCreator setServiceAppointment1(Id serviceAppointment1) {
            item.FSL__Service_Appointment_1__c = serviceAppointment1;
            return this;
        }
        public AppointmentDependencyCreator setServiceAppointment2(Id serviceAppointment2) {
            item.FSL__Service_Appointment_2__c = serviceAppointment2;
            return this;
        }
        public FSL__Time_Dependency__c create() {
            insert item;
            return item;
        }
        public AppointmentDependencyCreator returnWithoutCreate() {            
            return this;
        }
    }
    
    public class DCFDependantPicklistCreator{
        FSM_DCFDependantPicklist__c item;
        public DCFDependantPicklistCreator() {
            item = new FSM_DCFDependantPicklist__c();
        }
        public DCFDependantPicklistCreator setAsset(String asset)
        {
            item.FSM_Asset__c=asset;
            return this;
        }
        public DCFDependantPicklistCreator setTask(String task)
        {
            item.FSM_Task__c=task;
            return this;
        }
        public DCFDependantPicklistCreator setTechnique(String technique)
        {
            item.FSM_Technique__c=technique;
            return this;
        }
        public DCFDependantPicklistCreator setMaterial(String material)
        {
            item.FSM_Material__c=material;
            return this;
        }
        public DCFDependantPicklistCreator setSize(String size)
        {
            item.FSM_Size__c=size;
            return this;
        }
        public DCFDependantPicklistCreator setSWRAsset(String swrAsset)
        {
            item.FSM_SWRAsset__c=swrAsset;
            return this;
        }
        public DCFDependantPicklistCreator setSWRTask(String swrTask)
        {
            item.FSM_SWRTask__c=swrTask;
            return this;
        }
        public DCFDependantPicklistCreator setSWRJobRecepient(String swrJobRecepient)
        {
            item.FSM_SWRJobRecipient__c=swrJobRecepient;
            return this;
        }
        //Start-Added as part of sfs-7045
        public DCFDependantPicklistCreator setSWRJobFeedbackAsset(String swrjobfbAsset)
        {
            item.FSM_SFAsset__c=swrjobfbAsset;
            return this;
        }
        
        public DCFDependantPicklistCreator setSWRJobFeedbackTask(String swrjobfbTask)
        {
            item.FSM_SFTask__c=swrjobfbTask;
            return this;
        }
        public DCFDependantPicklistCreator setSWRJobFeedbackRecepient(String swrJobfbRecepient)
        {
            item.FSM_SFJob__c=swrJobfbRecepient;
            return this;
        }
        public DCFDependantPicklistCreator setType(String formtype)
        {
            item.FSM_Type__c=formtype;
            return this;
        }
        //End-Added as part of sfs-7045
        public DCFDependantPicklistCreator setSWRJobScope(String swrJobScope)
        {
            item.FSM_SWRJobScope__c=swrJobScope;
            return this;
        }
        public DCFDependantPicklistCreator setSWRTransferredAsset(String swrTransferredAsset)
        { 
            item.FSM_SWRTransferredAsset__c=swrTransferredAsset;
            return this;
        }
        public FSM_DCFDependantPicklist__c create() {
            insert item;
            return item;
        }
        
        public FSM_DCFDependantPicklist__c returnWithoutCreate() {            
            return item;
        }
        
        
    }
    /*Added as part of SFS-3017*/
    public class ContentDocumentLinkCreator {
        ContentDocumentLink item;
        public ContentDocumentLinkCreator() {
            item = new ContentDocumentLink();
        }
        public ContentDocumentLinkCreator setContentDocId (String contentdocid ){
            item.ContentDocumentId = contentdocid ;
            return this;
        }
        public ContentDocumentLinkCreator setLinkedEntityId (String linkedentityid){
            item.LinkedEntityId= linkedentityid;
            return this;
        }
        public ContentDocumentLink returnWithoutCreate() {
            return item;
        }
        public ContentDocumentLink create() {
            insert item;
            return item;
        }
    }
    
    //Added as part of SFI-1557
    public class TimeSheetCreator {
        TimeSheet item;
        public TimeSheetCreator() {
            item = new TimeSheet();
        }
        public TimeSheetCreator  setStartDate(Date startDate){
            item.StartDate = startDate;
            return this;
        }
        public TimeSheetCreator  setEndDate(Date endDate){
            item.EndDate= endDate ;
            return this;
        }
        public TimeSheetCreator  setServiceResourceId(String serviceResourceId){
            item.ServiceResourceId= serviceResourceId;
            return this;
        }
        
        public TimeSheet create() {
            insert item;
            return item;
        }
    }
    //Added as part of SFI-1557
    public class TimeSheetEntryCreator {
        TimeSheetEntry item;
        public TimeSheetEntryCreator() {
            item = new TimeSheetEntry();
        }
        public TimeSheetEntryCreator  setFinalConfirmation(Boolean finalConfirmation){
            item.FSM_FinalConfirmation__c = finalConfirmation;
            return this;
        }
        
        public TimeSheetEntryCreator  setType(String type){
            item.Type= type;
            return this;
        }
        public TimeSheetEntryCreator  setTimeSheetId(String timeSheetId){
            item.TimeSheetId=timesheetId ;
            return this;
        }
        
        public TimeSheetEntryCreator setsaId(Id saId){
            item.FSM_ServiceAppointmentId__c=saId;
            return this;
        }
        
        public TimeSheetEntry create() {
            insert item;
            return item;
        }
        //Added as part of SFL-889
        public TimeSheetEntry returnWithoutCreate() {
            return item;
        }
    }
    /*Create Location*/
    public class LocationCreator{
        Schema.Location item;
        public LocationCreator(){
            item = new Schema.Location();
        }
        public LocationCreator setName(String name){
            item.Name = name;
            return this;
        }
        public LocationCreator setloctype(String type){
            item.LocationType = type;
            return this;
        }
        public LocationCreator setinventory(Boolean inventory){
            item.IsInventoryLocation = inventory;
            return this;
        }
        public Schema.Location create() {
            insert item;
            return item;
        }
        public Schema.Location returnWithoutCreate() {
            return item;
        }
    }
    /*Create Product*/
    public class ProductCreator{
        Product2 item;
        public ProductCreator(){
            item = new Product2();
        }
        public ProductCreator setName(String name){
            item.Name = name;
            return this;
        }
        public ProductCreator setprodcode(String code){
            item.ProductCode = code;
            return this;
        }
        public ProductCreator setexternalid(String extid){
            item.ExternalId = extid;
            return this;
        }
        public ProductCreator setactive(boolean active){
            item.IsActive = active;
            return this;
        }
        public Product2 create() {
            insert item;
            return item;
        }
        public Product2 returnWithoutCreate() {
            return item;
        }
    }
    
    /*Create Product Item*/
    public class ProductItemCreator{
        ProductItem item;
        public ProductItemCreator(){
            item = new ProductItem();
        }
        
        public ProductItemCreator setlocation(String loc){
            item.LocationId = loc;
            return this;
        }
        public ProductItemCreator setproduct(String prod){
            item.Product2Id = prod;
            return this;
        }
        public ProductItemCreator setquantity(Decimal qty){
            item.QuantityOnHand = qty;
            return this;
        }
        public ProductItem create() {
            insert item;
            return item;
        }
        public ProductItem returnWithoutCreate() {
            return item;
        }
    }
    
    //create service report
    public class ServiceReportCreator{
        ServiceReport item;
        public ServiceReportCreator(){
            item = new ServiceReport();
        }
        
        public ServiceReportCreator setdocumentbody(blob body){
            item.DocumentBody = body;
            return this;
        }
        public ServiceReportCreator setcontenttype(string contenttype){
            item.DocumentContentType = contenttype;
            return this;
        }
        public ServiceReportCreator setdocumentname(string docname){
            item.DocumentName = docname;
            return this;
        }
        public ServiceReportCreator setparentid(string parentid){
            item.ParentId = parentid;
            return this;
        }
        public ServiceReportCreator settemplate(string template){
            item.Template = template;
            return this;
        }
        
        public ServiceReport create() {
            insert item;
            return item;
        }
        public ServiceReport returnWithoutCreate() {
            return item;
        }
    }
    
    //Create Service Crew, created as part of SFL-885
    public class ServiceCrewCreator{
        ServiceCrew item;
        public ServiceCrewCreator(){
            item = new ServiceCrew();
        }
        public ServiceCrewCreator setName(string name){
            item.Name = name;
            return this;
        }
        public ServiceCrewCreator setCrewSize(Integer size){
            item.CrewSize = size;
            return this;
        }
        public ServiceCrewCreator setServiceTerritory(Id stId){
            item.FSM_ServiceTerritory__c = stId;
            return this;
        }
        public ServiceCrew create() {
            insert item;
            return item;
        }
        public ServiceCrew returnWithoutCreate() {
            return item;
        }
    }

    // Create Service Crew Member, created as part of SFL-885
    public class ServiceCrewMemberCreator {
        ServiceCrewMember item;
        public ServiceCrewMemberCreator(){
            item = new ServiceCrewMember();
        }
        public ServiceCrewMemberCreator setServiceCrew(Id sc){
            item.ServiceCrewId = sc;
            return this;
        }
        public ServiceCrewMemberCreator setServiceResource(Id sr){
            item.ServiceResourceId = sr;
            return this;
        }
        public ServiceCrewMemberCreator setStartDate(datetime startDate){
            item.StartDate = startDate;
            return this;
        }
        public ServiceCrewMemberCreator setEndDate(datetime endDate){
            item.EndDate = endDate;
            return this;
        }
        public ServiceCrewMemberCreator setIsLeader(boolean isLeader){
            item.IsLeader = isLeader;
            return this;
        }
        public ServiceCrewMember create() {
            insert item;
            return item;
        }
        public ServiceCrewMember returnWithoutCreate() {
            return item;
        }
    }
}
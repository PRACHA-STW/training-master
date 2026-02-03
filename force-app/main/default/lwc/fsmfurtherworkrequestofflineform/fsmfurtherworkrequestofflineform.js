import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DCFINFRA_OBJECT from '@salesforce/schema/FSM_DataCaptureFormInfra__c';
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import FSM_DCFLineItemInfraOBJECT from '@salesforce/schema/FSM_DCFLineItemInfra__c';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FSM_DCFDependantPicklist__c from '@salesforce/schema/FSM_DCFDependantPicklist__c';
//import getdependentpicklistRecord from '@salesforce/apex/FSM_DependantPicklistcls.getDependentPicklistrecord';
import getAllRecords from '@salesforce/apex/FSM_DependantPicklistcls.getAllRecords'; //Arnob
import getAssetList from '@salesforce/apex/FSM_DependantPicklistcls.getAssetList'; //Arnob
import { getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { gql, graphql } from "lightning/uiGraphQLApi";
import { deleteRecord } from 'lightning/uiRecordApi';
const fieldname = ["WorkStep.FSM_OccCity__c", "WorkStep.FSM_OccPostCode__c", "WorkStep.FSM_OccStreet__c", "WorkStep.FSM_OccTown__c", "WorkStep.FSM_ContactName__c", "WorkStep.FSM_ContactPhoneNumber__c", "WorkStep.FSM_Occupiers_Address__c"];
const fieldnames = ["FSM_DataCaptureFormInfra__c.FSM_GridRefOfProposedWorkX__c", "FSM_DataCaptureFormInfra__c.FSM_GridRefOfProposedWorkY__c", "FSM_DataCaptureFormInfra__c.FSM_SFWIsThisAtADifferentAddress__c", "FSM_DataCaptureFormInfra__c.FSM_OccupiersName__c", "FSM_DataCaptureFormInfra__c.FSM_OccupiersTelephoneNumber__c", "FSM_DataCaptureFormInfra__c.FSM_OccupiersHouseName__c", "FSM_DataCaptureFormInfra__c.FSM_OccupiersHouseNo__c", "FSM_DataCaptureFormInfra__c.FSM_OccupiersStreet__c", "FSM_DataCaptureFormInfra__c.FSM_OccupiersTown__c",
    "FSM_DataCaptureFormInfra__c.FSM_OccupiersCity__c", "FSM_DataCaptureFormInfra__c.FSM_WorkOrder__r.Street", "FSM_DataCaptureFormInfra__c.FSM_WorkOrder__r.City", "FSM_DataCaptureFormInfra__c.FSM_WorkOrder__r.State", "FSM_DataCaptureFormInfra__c.FSM_WorkOrder__r.Country", "FSM_DataCaptureFormInfra__c.FSM_WorkOrder__r.PostalCode", "FSM_DataCaptureFormInfra__c.FSM_OccupiersPostcode__c", "FSM_DataCaptureFormInfra__c.FSM_Location__c", "FSM_DataCaptureFormInfra__c.FSM_PermissionToDigRequired__c", "FSM_DataCaptureFormInfra__c.FSM_WhichProformaSigned__c", "FSM_DataCaptureFormInfra__c.FSM_PermissionToDig__c", "FSM_DataCaptureFormInfra__c.FSM_AssetUID__c", "FSM_DataCaptureFormInfra__c.FSM_Asset__c", "FSM_DataCaptureFormInfra__c.FSM_Task__c", "FSM_DataCaptureFormInfra__c.FSM_Technique__c", "FSM_DataCaptureFormInfra__c.FSM_AssetMaterial__c", "FSM_DataCaptureFormInfra__c.FSM_AssetSize__c", "FSM_DataCaptureFormInfra__c.FSM_ESTLocation__c", "FSM_DataCaptureFormInfra__c.FSM_LeakQuantified__c", "FSM_DataCaptureFormInfra__c.FSM_MeterSerial__c", "FSM_DataCaptureFormInfra__c.FSM_MeterReading__c",
    "FSM_DataCaptureFormInfra__c.FSM_AccessRestricted__c", "FSM_DataCaptureFormInfra__c.FSM_AccessRestricted__c", "FSM_DataCaptureFormInfra__c.FSM_Monday__c", "FSM_DataCaptureFormInfra__c.FSM_Tuesday__c", "FSM_DataCaptureFormInfra__c.FSM_Wednesday__c", "FSM_DataCaptureFormInfra__c.FSM_Thursday__c", "FSM_DataCaptureFormInfra__c.FSM_Friday__c", "FSM_DataCaptureFormInfra__c.FSM_Saturday__c", "FSM_DataCaptureFormInfra__c.FSM_Sunday__c", "FSM_DataCaptureFormInfra__c.FSM_AM__c", "FSM_DataCaptureFormInfra__c.FSM_PM__c", "FSM_DataCaptureFormInfra__c.FSM_Night__c",
    "FSM_DataCaptureFormInfra__c.FSM_RestrictedTime__c", "FSM_DataCaptureFormInfra__c.FSM_OverheadPowerLinesWithin10m__c", "FSM_DataCaptureFormInfra__c.FSM_IsExcavationRequired__c", "FSM_DataCaptureFormInfra__c.FSM_TypeOfLeak__c", "FSM_DataCaptureFormInfra__c.FSM_ReasonForFirstTimeReinstatement__c", "FSM_DataCaptureFormInfra__c.FSM_TrailerTeam__c",
    "FSM_DataCaptureFormInfra__c.FSM_LetterWarn__c", "FSM_DataCaptureFormInfra__c.FSM_SensitiveCustomer__c", "FSM_DataCaptureFormInfra__c.FSM_SiteComments__c", "FSM_DataCaptureFormInfra__c.FSM_OverheadPowerLinesWithin10m__c", "FSM_DataCaptureFormInfra__c.FSM_LampSupportRemovalRequired__c", "FSM_DataCaptureFormInfra__c.FSM_ConfinedSpaceWorking__c", "FSM_DataCaptureFormInfra__c.FSM_Contamination__c", "FSM_DataCaptureFormInfra__c.FSM_ContaminationComments__c", "FSM_DataCaptureFormInfra__c.FSM_IsThereConfirmedPollution__c", "FSM_DataCaptureFormInfra__c.FSM_ConfirmedPollutionComments__c", "FSM_DataCaptureFormInfra__c.FSM_IsThereARiskOfPollutionOccurring__c", "FSM_DataCaptureFormInfra__c.FSM_RiskToAnEnvironmentalSite__c", "FSM_DataCaptureFormInfra__c.FSM_IsShutOffOrValveOperationRequired__c",
    "FSM_DataCaptureFormInfra__c.FSM_EstimatedNoOfPropertiesAffected__c", "FSM_DataCaptureFormInfra__c.FSM_AlternativeSuppliesRequired__c", "FSM_DataCaptureFormInfra__c.FSM_SensitiveCustomersOnShutdown__c", "FSM_DataCaptureFormInfra__c.FSM_ThirdPartyDamageOccurOnThisSite__c", "FSM_DataCaptureFormInfra__c.FSM_CommsMethod__c", "FSM_DataCaptureFormInfra__c.FSM_LibraryTimeExtensions__c", "FSM_DataCaptureFormInfra__c.FSM_PlanningInfoAndComms__c", "FSM_DataCaptureFormInfra__c.FSM_SurfaceType__c", "FSM_DataCaptureFormInfra__c.FSM_ESTLocationX__c", "FSM_DataCaptureFormInfra__c.FSM_ESTLocationY__c", "FSM_DataCaptureFormInfra__c.FSM_LeakLocation__c", "FSM_DataCaptureFormInfra__c.FSM_VisibleLeak__c", "FSM_DataCaptureFormInfra__c.FSM_HasLeakBeenQuantified__c", "FSM_DataCaptureFormInfra__c.FSM_AquaPeaUsed__c", "FSM_DataCaptureFormInfra__c.FSM_PostAquaPea__c", "FSM_DataCaptureFormInfra__c.FSM_FlowValveFitted__c", "FSM_DataCaptureFormInfra__c.FSM_PostFlowValve__c", "FSM_DataCaptureFormInfra__c.FSM_Gassing__c", "FSM_DataCaptureFormInfra__c.FSM_PipeMIC__c", "FSM_DataCaptureFormInfra__c.FSM_IsThisASharedSupply__c", "FSM_DataCaptureFormInfra__c.FSM_ResidentialStatus__c", "FSM_DataCaptureFormInfra__c.FSM_WorkStep__c"];
const GET_DCF_WITH_LINEITEMS = gql`
    query getDCFLineItems($dcfId: ID!) {
        uiapi {
            query {
                FSM_DataCaptureFormInfra__c(where: {Id: {eq: $dcfId}}) {
                    edges {
                        node {
                            Id
                            FSM_DataCaptureFormLineItems__r{
                                edges {
                                    node {
                                        Id
                                        FSM_ValvesIDIdentifiedOnSketch__c {
                                            value
                                        }
                                        FSM_ProposedOp__c {
                                            value
                                        }
                                        FSM_ValveChecked__c {
                                            value
                                        }
                                        FSM_GridRefX__c {
                                            value
                                        }
                                        FSM_GridRefY__c {
                                            value
                                        }
                                        FSM_CommentsForAllValves__c {
                                            value
                                        }
                                        FSM_ResidentialStatus__c {
                                            value
                                        }
                                        FSM_CustomerName__c {
                                            value
                                        }
                                        FSM_ContactNumber__c {
                                            value
                                        }
                                        FSM_Address__c {
                                            value
                                        }
                                        FSM_ContactWithCustomer__c {
                                            value
                                        }
                                        FSM_CanISTBeIsolated__c {
                                            value
                                        }}}}}}}}}}`;


export default class Fsmfurtherworkrequestofflineform extends LightningElement {
    map;
    // @api objectApiName;
    proformaImageData = [];
    filesData = [];
    infraRecid;
    @api proformaimgfromnxtcmp;
    nextId = 0;
    isCompleted = false;
    locationselected;
    stopFlow = false;
    proformaimg = true;
    name;
    number;
    commmethod;
    flagfrompc;
    sharedsupplyyes = false;
    issharedsupply;
    residentialstatusoptions = [];
    residentstatusoptions = [];
    residentstatus;
    sharedsupplyoptions;
    ismonchecked = false;
    isaccesschecked = false;
    istuechecked = false;
    iswedchecked = false;
    isthurschecked = false;
    isfrichecked = false;
    issatchecked = false;
    issunchecked = false;
    isvalidadditionalcustomer = true;
    amval;
    pmval;
    nightval;
    isEdit;
    isboppsflow = false;
    isnormalflow = false;
    istmaflow = false;
    ischangedboppsflow = false;
    ischangedtmaflow = false;
    ischangednormalflow = false;
    isnightchecked = false;
    ispmchecked = false;
    isamchecked = false;
    isyesptd = false;
    ischeckeddiffaddr = false;
    @api recordId;
    @api woId;
    isDone = false;
    retainvaluestochild;
    permissionoptions;
    typeofleakoptions;
    letterwarnoptions;
    reinstatementoptions;
    locationoptions;
    customeroptions;
    digoptions;
    restrictedpicklistoptions;
    storetabledata;
    storecustomertabledata;
    isLoading = false;
    senddatatotmacmp;
    @track objectInfo;
    errormessage;
    submitValues = {};
    dcfrecdata = {};
    errormessages = [];
    datastoredtable = [];
    isdiffaddrr = false;
    occhsename;
    @track gridproposedworkx;
    lastpage = false;
    @track gridproposedworky;
    //landcomm;
    diffaddr;
    occname;
    location;
    occtelno;
    dcflineitemrectypid;
    occhseno;
    occstreet;
    occstown;
    occcity;
    retainchildvalues;
    occpostcode;
    occlocation;
    proformasigned;
    permissiondig;
    assetinp;
    taskinp;
    techniqueinp;
    sizeinp;
    materialinp;
    assetuuid;
    gridxerror;
    gridyerror;
    diffaddress;
    permissiontodigreq;
    isvalidscreenone = true;
    enablesecsixofchild = false;
    isnotatdiffadrr = false;
    sectionone = true;
    sectiontwo = false;
    sectionthree = false;
    sectionfour = false;
    sectionfive = false;
    sectionsix = false;
    sectionseven = false;
    sectioneight = false;
    sectionnine = false;
    sectionten = false;
    sectioneleven = false;
    sectiontwelve = false;
    dontloadgetrec;
    sectionadditionalcustomer = false;
    sectionthirteen = false;
    sectionboppsone = false;
    sectionboppstwo = false;
    prevdisabled = true;
    nextdisabled = false;
    isvalidscreentwo = true;
    sectionthreevalid = true;
    isvalidscreenfour = true;
    isvalidscreenfive = true;
    isvalidscreensix = true;
    isvalidscreenseven = true;
    isvalidscreennine = true;
    isvalidsectionten = true;
    isvalidsectiontwelve = true;
    //islocrestrictedland=true;
    issubmitenable = false;
    iscontaminationyes = false;
    ispollutionyes = false;
    isshutoff;
    estimatedproperties;
    altsupplies;
    sensitivecustonshuttdown;
    thirdpartydmge = 'No';
    objectApiName = DCFINFRA_OBJECT;
    isInputsoneCorrect;
    estloc;
    leakquant;
    meterserial;
    meterreading;
    accessissues;
    mon;
    tues;
    wed;
    thurs;
    fri;
    sat;
    sun;
    hasRun = false;
    hasRunWired = false;
    powerlines;
    excavation;
    leaktype;
    reason;
    trailer;
    letterwarn;
    sensitivecustomer;
    sitecomm;
    contactcustomeroptions;
    canistbeisolatedoptions;
    isaccessissuesyes = false;
    overheadpowerlines = 'No';
    lampsupport = 'No';
    confinedspace = 'No';
    contamination;
    contaminationcomm;
    pollution;
    pollutioncomm;
    risk;
    riskenv;
    selshutoffoperation;
    isshutofforvalvesel = false;
    surfacetype;
    surfacetypeoptions;
    estXloc;
    estYloc;
    leakloc;
    visibleleakoptions;
    leakquantified;
    visibleleak;
    leaklocaoptions;
    leakquantifiedoptions;
    @api objectName = 'FSM_DCFDependantPicklist__c';
    @track fieldLabel;
    @api recordTypeId;
    @api value;
    @track optionsasset;
    @track optionstask;
    @track optionsmaterial;
    @track optionstechnique;
    @track optionssize;
    dependentRecordsLoaded = false;
    @track assetvaluesarr = [];
    @track taskvaluesarr = [];
    @track techvaluesarr = [];
    @track sizevaluesarr = [];
    @track materialvaluesarr = [];
    sourceList = []
    dcfrectypid;
    arrFilteredRecords = []
    apiFieldName;
    @track error;
    @api isprevfromnextcmp;
    //table variables
    @track data = [{ id: 1, FSM_ValvesIDIdentifiedOnSketch__c: '', FSM_ProposedOp__c: '', FSM_ValveChecked__c: '', FSM_GridRefX__c: '', FSM_GridRefY__c: '', FSM_CommentsForAllValves__c: '' }];
    @track proposedoparr = [];
    @track valvescheckedarr = [];
    @track customerdata = [{ id: 1, FSM_CustomerName__c: '', FSM_ContactNumber__c: '', FSM_ResidentialStatus__c: '', FSM_ContactWithCustomer__c: '', FSM_CanISTBeIsolated__c: '', FSM_Address__c: '' }];
    isValid = true;
    dcflineitemdata;
    addcustomerlineitemdata;
    retainparentdcfdata;
    dcfinfralineitemdata;
    dcfinfrarecorddata;
    libext;
    planninginfo;
    hasRendered = false;
    aquapeaused;
    aquapeausedoptions;
    pipeMicoptions;
    gassingptions;
    valvefittedoptions;
    postaquapea;
    postflowvalve;
    valvefitted;
    gassing;
    pipeMic;
    Gridrefx;
    workstep;
    rectypename;
    occupiersaddress;
    ifnoconfirmedpollution = true;
    dataloaded = false;
    // Start-- added as part of SFS-7964
    @wire(getRecord, { recordId: '$recordId', fields: fieldname }) record({ error, data }) {
        if (error) {
            console.error('No address preset on workorder ', error);
            this.occupiersaddress = '';
        } else if (data) {
            console.log('Run before', this.dataloaded);
            this.occupiersaddress = data.fields.FSM_Occupiers_Address__c.value;
            if (this.dataloaded === false) {
                this.occcity = data.fields.FSM_OccCity__c.value;
                this.occpostcode = data.fields.FSM_OccPostCode__c.value;
                this.occstreet = data.fields.FSM_OccStreet__c.value;
                this.occstown = data.fields.FSM_OccTown__c.value;
                this.occname = data.fields.FSM_ContactName__c.value;
                this.occtelno = data.fields.FSM_ContactPhoneNumber__c.value;
            }

        }
    }
    // End-- added as part of SFS-7964
    //get all the existing records from FSM_DCFDependantPicklist__c
    @wire(getAllRecords)
    wiredAllRecords({ data, error }) {
        if (data) {
            console.log('wiredAllRecords---> ', this.woId)

            // alert('all recs');
            this.allRecords = JSON.stringify(data);
        } else if (error) {
            console.error('Error allrecords ', error);
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: fieldnames })
    dcfinfradata({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.FSM_WorkStep__c.value != null) {
                this.workstep = data.fields.FSM_WorkStep__c.value;
                this.isEdit = true;
                if (!this.hasRun) {
                    console.log('has run3');
                    this.hasRun = true;
                    console.log('has run2', this.hasRun);
                    if (data.fields.FSM_GridRefOfProposedWorkX__c.value != null) {
                        this.gridproposedworkx = data.fields.FSM_GridRefOfProposedWorkX__c.value;
                    }
                    //Start -- added as part oF SFS-7964
                    if (data.fields.FSM_WorkOrder__r.value.fields.Street.value != null || data.fields.FSM_WorkOrder__r.value.fields.City.value != null || data.fields.FSM_WorkOrder__r.value.fields.State.value != null || data.fields.FSM_WorkOrder__r.value.fields.Country.value != null || data.fields.FSM_WorkOrder__r.value.fields.PostalCode.value != null) {

                        this.occupiersaddress = `${data.fields.FSM_WorkOrder__r.value.fields.Street.value} ${data.fields.FSM_WorkOrder__r.value.fields.City.value} ${data.fields.FSM_WorkOrder__r.value.fields.State.value} ${data.fields.FSM_WorkOrder__r.value.fields.Country.value} ${data.fields.FSM_WorkOrder__r.value.fields.PostalCode.value}`;
                    }
                    //End -- added as part oF SFS-7964
                    if (data.fields.FSM_GridRefOfProposedWorkY__c.value != null) {
                        this.gridproposedworky = data.fields.FSM_GridRefOfProposedWorkY__c.value;
                    }
                    this.isdiffaddrr = data.fields.FSM_SFWIsThisAtADifferentAddress__c.value;
                    this.ischeckeddiffaddr = this.isdiffaddrr;
                    this.isnotatdiffadrr = this.isdiffaddrr;
                    this.occname = data.fields.FSM_OccupiersName__c.value;
                    this.occtelno = data.fields.FSM_OccupiersTelephoneNumber__c.value;
                    this.occhsename = data.fields.FSM_OccupiersHouseName__c.value;
                    this.occhseno = data.fields.FSM_OccupiersHouseNo__c.value;
                    this.occstreet = data.fields.FSM_OccupiersStreet__c.value;
                    this.occstown = data.fields.FSM_OccupiersTown__c.value;
                    this.occcity = data.fields.FSM_OccupiersCity__c.value;
                    this.occpostcode = data.fields.FSM_OccupiersPostcode__c.value;
                    this.occlocation = data.fields.FSM_Location__c.value;
                    this.permissiontodigreq = data.fields.FSM_PermissionToDigRequired__c.value;
                    if (this.permissiontodigreq == 'Yes') {
                        this.isyesptd = true;
                    } else {
                        this.isyesptd = false;
                    }
                    this.proformasigned = data.fields.FSM_WhichProformaSigned__c.value;
                    this.permissiondig = data.fields.FSM_PermissionToDig__c.value;
                    this.assetuuid = data.fields.FSM_AssetUID__c.value;
                    this.selectedasset = data.fields.FSM_Asset__c.value;
                    this.seltask = data.fields.FSM_Task__c.value;
                    this.selectedtechnique = data.fields.FSM_Technique__c.value;
                    this.selsize = data.fields.FSM_AssetSize__c.value;
                    this.selmaterial = data.fields.FSM_AssetMaterial__c.value;
                    this.estloc = data.fields.FSM_ESTLocation__c.value;
                    this.leakquant = data.fields.FSM_LeakQuantified__c.value;
                    this.meterserial = data.fields.FSM_MeterSerial__c.value;
                    this.meterreading = data.fields.FSM_MeterReading__c.value;
                    this.accessissues = data.fields.FSM_AccessRestricted__c.value;
                    this.isaccesschecked = data.fields.FSM_AccessRestricted__c.value;
                    this.mon = data.fields.FSM_Monday__c.value;
                    this.ismonchecked = data.fields.FSM_Monday__c.value;
                    this.tues = data.fields.FSM_Tuesday__c.value;
                    this.istuechecked = data.fields.FSM_Tuesday__c.value;
                    this.wed = data.fields.FSM_Wednesday__c.value;
                    this.iswedchecked = data.fields.FSM_Wednesday__c.value;
                    this.thurs = data.fields.FSM_Thursday__c.value;
                    this.isthurschecked = data.fields.FSM_Thursday__c.value;
                    this.fri = data.fields.FSM_Friday__c.value;
                    this.isfrichecked = data.fields.FSM_Friday__c.value;
                    this.sat = data.fields.FSM_Saturday__c.value;
                    this.issatchecked = data.fields.FSM_Saturday__c.value;
                    this.sun = data.fields.FSM_Sunday__c.value;
                    this.issunchecked = data.fields.FSM_Sunday__c.value;
                    this.amval = data.fields.FSM_AM__c.value;
                    this.pmval = data.fields.FSM_PM__c.value;
                    this.nightval = data.fields.FSM_Night__c.value;
                    this.isamchecked = data.fields.FSM_AM__c.value;
                    this.ispmchecked = data.fields.FSM_PM__c.value;
                    this.isnightchecked = data.fields.FSM_Night__c.value;
                    this.powerlines = data.fields.FSM_OverheadPowerLinesWithin10m__c.value;
                    this.excavation = data.fields.FSM_IsExcavationRequired__c.value;
                    this.leaktype = data.fields.FSM_TypeOfLeak__c.value;
                    this.reason = data.fields.FSM_ReasonForFirstTimeReinstatement__c.value;
                    this.trailer = data.fields.FSM_TrailerTeam__c.value;
                    if (data.fields.FSM_LetterWarn__c.value) {
                        this.letterwarn = data.fields.FSM_LetterWarn__c.value.split(';');
                    }
                    this.sensitivecustomer = data.fields.FSM_SensitiveCustomer__c.value;
                    this.sitecomm = data.fields.FSM_SiteComments__c.value;
                    this.overheadpowerlines = data.fields.FSM_OverheadPowerLinesWithin10m__c.value;
                    this.lampsupport = data.fields.FSM_LampSupportRemovalRequired__c.value;
                    this.confinedspace = data.fields.FSM_ConfinedSpaceWorking__c.value;
                    this.contamination = data.fields.FSM_Contamination__c.value;
                    if (this.contamination == 'Yes') {
                        this.iscontaminationyes = true;
                    } else {
                        this.iscontaminationyes = false;
                    }
                    this.contaminationcomm = data.fields.FSM_ContaminationComments__c.value;
                    this.pollution = data.fields.FSM_IsThereConfirmedPollution__c.value;
                    if (this.pollution == 'Yes') {
                        this.ispollutionyes = true;
                        this.ifnoconfirmedpollution = false;
                    } else {
                        this.ispollutionyes = false;
                        this.ifnoconfirmedpollution = true;
                    }
                    this.pollutioncomm = data.fields.FSM_ConfirmedPollutionComments__c.value;
                    this.risk = data.fields.FSM_IsThereARiskOfPollutionOccurring__c.value;
                    this.riskenv = data.fields.FSM_RiskToAnEnvironmentalSite__c.value;
                    this.isshutoff = data.fields.FSM_IsShutOffOrValveOperationRequired__c.value;
                    if (this.isshutoff == 'Yes') {
                        this.isshutofforvalvesel = true;
                    } else {
                        this.isshutofforvalvesel = false;
                    }
                    this.estimatedproperties = data.fields.FSM_EstimatedNoOfPropertiesAffected__c.value;
                    this.altsupplies = data.fields.FSM_AlternativeSuppliesRequired__c.value;
                    this.sensitivecustonshuttdown = data.fields.FSM_SensitiveCustomersOnShutdown__c.value;
                    this.thirdpartydmge = data.fields.FSM_ThirdPartyDamageOccurOnThisSite__c.value;
                    this.commmethod = data.fields.FSM_CommsMethod__c.value;
                    this.libext = data.fields.FSM_LibraryTimeExtensions__c.value;
                    this.planninginfo = data.fields.FSM_PlanningInfoAndComms__c.value;
                    this.surfacetype = data.fields.FSM_SurfaceType__c.value;
                    this.estXloc = data.fields.FSM_ESTLocationX__c.value;
                    this.estYloc = data.fields.FSM_ESTLocationY__c.value;
                    this.leakloc = data.fields.FSM_LeakLocation__c.value;
                    this.visibleleak = data.fields.FSM_VisibleLeak__c.value;
                    this.leakquantified = data.fields.FSM_HasLeakBeenQuantified__c.value;
                    this.aquapeaused = data.fields.FSM_AquaPeaUsed__c.value;
                    this.postaquapea = data.fields.FSM_PostAquaPea__c.value;
                    this.valvefitted = data.fields.FSM_FlowValveFitted__c.value;
                    this.postflowvalve = data.fields.FSM_PostFlowValve__c.value;
                    this.gassing = data.fields.FSM_Gassing__c.value;
                    this.pipeMic = data.fields.FSM_PipeMIC__c.value;
                    this.issharedsupply = data.fields.FSM_IsThisASharedSupply__c.value;
                    this.residentstatus = data.fields.FSM_ResidentialStatus__c.value;
                }
            } else {
                this.isEdit = false;
            }
        }
    }




    get variables() {
        return { dcfId: this.recordId };
    }
    @track LINEITEMS_RECORDS__GRAPHQL = [];

    @wire(graphql, {
        query: GET_DCF_WITH_LINEITEMS,
        variables: '$variables'
    })
    wiredDCFLineItems({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('wiredlineitems executed-', this.hasRunWired, typeof this.hasRunWired);
            if (this.hasRunWired === false) {
                this.hasRunWired = true;
                console.log('wiredlineitems executed 2-', this.hasRunWired);
                this.LINEITEMS_RECORDS__GRAPHQL = data?.uiapi?.query?.FSM_DataCaptureFormInfra__c?.edges[0]?.node;
                if (this.LINEITEMS_RECORDS__GRAPHQL != undefined) {
                    this.customerdata = [];
                    this.data = [];
                    this.LINEITEMS_RECORDS__GRAPHQL.FSM_DataCaptureFormLineItems__r.edges.map(edge => {
                        if (!!edge.node.FSM_CustomerName__c.value) {
                            const newRow = {
                                Id: this.customerdata.length + 1,
                                recordId: edge.node.Id,
                                FSM_CustomerName__c: edge.node.FSM_CustomerName__c.value,
                                FSM_ContactNumber__c: edge.node.FSM_ContactNumber__c.value,
                                FSM_ResidentialStatus__c: edge.node.FSM_ResidentialStatus__c.value,
                                FSM_Address__c: edge.node.FSM_Address__c.value,
                                FSM_ContactNumber__c: edge.node.FSM_ContactNumber__c.value,
                                FSM_ContactWithCustomer__c: edge.node.FSM_ContactWithCustomer__c.value,
                                FSM_CanISTBeIsolated__c: edge.node.FSM_CanISTBeIsolated__c.value
                            }
                            this.customerdata = [...this.customerdata, newRow];
                        }
                        else if (!!edge.node.FSM_GridRefX__c.value) {
                            const newRow = {
                                Id: this.data.length + 1,
                                recordId: edge.node.Id,
                                FSM_ValvesIDIdentifiedOnSketch__c: edge.node.FSM_ValvesIDIdentifiedOnSketch__c.value,
                                FSM_ProposedOp__c: edge.node.FSM_ProposedOp__c.value,
                                FSM_ValveChecked__c: edge.node.FSM_ValveChecked__c.value,
                                FSM_GridRefX__c: edge.node.FSM_GridRefX__c.value,
                                FSM_GridRefY__c: edge.node.FSM_GridRefY__c.value,
                                FSM_CommentsForAllValves__c: edge.node.FSM_CommentsForAllValves__c.value
                            };
                            this.data = [...this.data, newRow];
                        }
                    }
                    );
                }
            }
        }
    }
    get optionesyesno() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },

        ];
    }
    handlecommmethodChange(event) {
        this.commmethod = event.detail.value;
    }
    //fetch dcf infra recordtypeid
    @wire(getObjectInfo, { objectApiName: DCFINFRA_OBJECT })
    getobjdata({ data, error }) {
        if (data) {
            let recmap = JSON.parse(JSON.stringify(data.recordTypeInfos));

            this.dcfrectypid = Object.keys(recmap).find(recTyp => recmap[recTyp].name === 'Infra Follow On Work Request');
        }
    }
    //fetch dcf line item infra recordtypeid
    @wire(getObjectInfo, { objectApiName: FSM_DCFLineItemInfraOBJECT })
    getdcflineitemobjdata({ data, error }) {
        if (data) {
            let recmaplineitem = JSON.parse(JSON.stringify(data.recordTypeInfos));

            this.dcflineitemrectypid = Object.keys(recmaplineitem).find(recTyp => recmaplineitem[recTyp].name === 'Proposed Valve Operation');

        }
    }
    connectedCallback() {
        console.log('connected callback executed');
        if (!!JSON.stringify(this.isprevfromnextcmp)) {
            this.handlepreviousfromfwr(this.isprevfromnextcmp);
            console.log('inside if1 connected callback');
            if (!!this.proformaimgfromnxtcmp) {
                this.proformaImageData = JSON.parse(JSON.stringify(this.proformaimgfromnxtcmp));
            }
            this.hasRendered = true;
            this.isDone = true;
        }

    }
    renderedCallback() {
        if (this.hasRendered) {
            return;
        }
        setTimeout(() => {
            this.isDone = true;
            this.hasRendered = true;
        }, 2000);
    }
    //Added as part of sfs-6000.This method is used to clear all tma notice details section values if user goes back and changes location value selection to any other value than public highway
    clearalltmanoticedetailsvalues() {
        console.log('clear tma');
        this.submitValues.FSM_INFRAFWRActivityType__c = ''
        this.submitValues.FSM_RoadType__c = '';
        this.submitValues.FSM_MethodOfWork__c = '';
        this.submitValues.FSM_Speed__c = '';
        this.submitValues.FSM_FootwayWidth__c = '';
        this.submitValues.FSM_CarriagewayWidth__c = '';
        this.submitValues.FSM_Verge__c = false;
        this.submitValues.FSM_VergeM__c = '';
        this.submitValues.FSM_Carriageway__c = false;
        this.submitValues.FSM_BridlewayFootpath__c = false;
        this.submitValues.FSM_PrivateLand__c = false;
        this.submitValues.FSM_Footway__c = false;
        this.submitValues.FSM_Cycleway__c = false;
        this.submitValues.FSM_PedestrianZone__c = false;
        this.submitValues.FSM_VehicleRequirements__c = '';
        this.submitValues.FSM_VehiclePosition__c = '';
        this.submitValues.FSM_LocationType__c = '';
        this.submitValues.FSM_TrafficFlow__c = '';
        this.submitValues.FSM_SpecialFeature__c = '';
        this.submitValues.FSM_PedestrianWalkway__c = '';
        this.submitValues.FSM_VisibilityToMenAtWork__c = '';
        this.submitValues.FSM_PedestrianLights__c = '';
        this.submitValues.FSM_TrainOrTram__c = '';
        this.submitValues.FSM_Bus__c = '';
        this.submitValues.FSM_Cycle__c = '';
        this.submitValues.FSM_CarriagewayRestriction__c = '';
        this.submitValues.FSM_CarriagewaySpecification__c = '';
        // this.submitValues.FSM_SurfaceType__c = '';
        this.submitValues.FSM_FootpathClosed__c = '';
        this.submitValues.FSM_SpecialistTreatment__c = '';
        this.submitValues.FSM_SpecialistTreatmentComments__c = '';
        this.submitValues.FSM_RoadMarkings__c = '';
        this.submitValues.FSM_RoadMarkingsComments__c = '';
        this.submitValues.FSM_IsTheLocationTrafficSensitive__c = '';
        this.submitValues.FSM_IsTheJobUrgent__c = '';
        this.submitValues.FSM_AreNoWaitingConesRequired__c = '';
        this.submitValues.FSM_ParkingSuspension__c = '';
        this.submitValues.FSM_TrafficLightsLessThan50m__c = '';
        this.submitValues.FSM_CommentsForTheGangs__c = '';
        this.submitValues.FSM_SchedulingCommentsBox__c = '';
        //  this.submitValues.FSM_IsShutOffOrValveOperationRequired__c="No";

    }
    clearallboppssectionvariables() {
        console.log('clear bopps');
        // this.submitValues.FSM_TypeOfLeak__c = '';
        this.submitValues.FSM_ESTLocationX__c = '';
        this.submitValues.FSM_ESTLocationY__c = '';
        this.submitValues.FSM_LeakLocation__c = '';
        this.submitValues.FSM_VisibleLeak__c = '';
        this.submitValues.FSM_HasLeakBeenQuantified__c = '';
        this.submitValues.FSM_MeterSerial__c = '';
        this.submitValues.FSM_MeterReading__c = '';
        this.submitValues.FSM_LeakQuantified__c = '';
        this.submitValues.FSM_AquaPeaUsed__c = '';
        this.submitValues.FSM_PostAquaPea__c = '';
        this.submitValues.FSM_FlowValveFitted__c = '';
        this.submitValues.FSM_PostFlowValve__c = '';
        this.submitValues.FSM_Gassing__c = '';
        this.submitValues.FSM_PipeMIC__c = '';
        this.submitValues.FSM_AccessRestricted__c = false;
        // this.submitValues.FSM_Monday__c = false;
        // this.submitValues.FSM_Tuesday__c = false;
        // this.submitValues.FSM_Wednesday__c = false;
        // this.submitValues.FSM_Thursday__c = false;
        // this.submitValues.FSM_Friday__c = false;
        // this.submitValues.FSM_Saturday__c = false;
        // this.submitValues.FSM_Sunday__c = false;
        // this.submitValues.FSM_AM__c = false;
        // this.submitValues.FSM_PM__c = false;
        // this.submitValues.FSM_Night__c = false;
        this.submitValues.FSM_OverheadPowerLinesWithin10m__c = '';
        this.submitValues.FSM_IsThisASharedSupply__c = '';
        this.submitValues.FSM_ResidentialStatus__c = '';
        this.addcustomerlineitemdata = [];
    }
    clearallnormalscreenvalues() {
        console.log('clear normal');
        this.submitValues.FSM_IsExcavationRequired__c = '';
        //this.submitValues.FSM_TypeOfLeak__c='';
        // this.submitValues.FSM_Monday__c=false;
        // this.submitValues.FSM_Tuesday__c=false;
        // this.submitValues.FSM_Wednesday__c=false;
        // this.submitValues.FSM_Thursday__c=false;
        // this.submitValues.FSM_Friday__c=false;
        // this.submitValues.FSM_Saturday__c=false;
        // this.submitValues.FSM_Sunday__c=false;
        // this.submitValues.FSM_AM__c=false;
        // this.submitValues.FSM_PM__c=false;
        // this.submitValues.FSM_Night__c=false;
        this.submitValues.FSM_ReasonForFirstTimeReinstatement__c = '';
        this.submitValues.FSM_TrailerTeam__c = '';
        this.submitValues.FSM_CommsMethod__c = '';
        this.submitValues.FSM_LetterWarn__c = '';
        this.submitValues.FSM_SensitiveCustomer__c = '';
        this.submitValues.FSM_SiteComments__c = '';
        this.submitValues.FSM_OverheadPowerLinesWithin10m__c = '';
        this.submitValues.FSM_LampSupportRemovalRequired__c = '';
        this.submitValues.FSM_ConfinedSpaceWorking__c = '';
        this.submitValues.FSM_LibraryTimeExtensions__c = '';
        this.submitValues.FSM_PlanningInfoAndComms__c = '';
        this.submitValues.FSM_Contamination__c = '';
        this.submitValues.FSM_ContaminationComments__c = '';
        this.submitValues.FSM_IsThereConfirmedPollution__c = '';
        this.submitValues.FSM_ConfirmedPollutionComments__c = '';
        this.submitValues.FSM_IsThereARiskOfPollutionOccurring__c = '';
        this.submitValues.FSM_RiskToAnEnvironmentalSite__c = '';
        this.submitValues.FSM_IsShutOffOrValveOperationRequired__c = "No";
        this.submitValues.FSM_EstimatedNoOfPropertiesAffected__c = '';
        this.submitValues.FSM_AlternativeSuppliesRequired__c = '';
        this.submitValues.FSM_SensitiveCustomersOnShutdown__c = '';
        this.submitValues.FSM_ThirdPartyDamageOccurOnThisSite__c = '';
        this.dcflineitemdata = [];
    }
    savesectiononevalues() {

        this.submitValues.FSM_GridRefOfProposedWorkX__c = this.gridproposedworkx;
        this.submitValues.FSM_GridRefOfProposedWorkY__c = this.gridproposedworky;
        this.submitValues.FSM_SFWIsThisAtADifferentAddress__c = this.isdiffaddrr;
        this.submitValues.FSM_OccupiersName__c = this.occname;
        this.submitValues.FSM_OccupiersTelephoneNumber__c = this.occtelno;
        this.submitValues.FSM_OccupiersHouseName__c = this.occhsename;
        this.submitValues.FSM_OccupiersHouseNo__c = this.occhseno;
        this.submitValues.FSM_OccupiersStreet__c = this.occstreet;
        this.submitValues.FSM_OccupiersTown__c = this.occstown;
        this.submitValues.FSM_OccupiersCity__c = this.occcity;
        this.submitValues.FSM_OccupiersPostcode__c = this.occpostcode;
        this.submitValues.FSM_Location__c = this.occlocation;
        this.submitValues.FSM_PermissionToDigRequired__c = this.permissiontodigreq;
        this.submitValues.FSM_WhichProformaSigned__c = this.proformasigned;
        this.submitValues.FSM_PermissionToDig__c = this.permissiondig;
        this.submitValues.FSM_AssetUID__c = this.assetuuid;
        this.submitValues.FSM_LeakQuantified__c = this.leakquant;
        this.submitValues.FSM_MeterSerial__c = this.meterserial;
        this.submitValues.FSM_MeterReading__c = this.meterreading;
        this.submitValues.FSM_AccessRestricted__c = this.accessissues;
        this.submitValues.FSM_Monday__c = this.mon;
        this.submitValues.FSM_Tuesday__c = this.tues;
        this.submitValues.FSM_Wednesday__c = this.wed;
        this.submitValues.FSM_Thursday__c = this.thurs;
        this.submitValues.FSM_Friday__c = this.fri;
        this.submitValues.FSM_Saturday__c = this.sat;
        this.submitValues.FSM_Sunday__c = this.sun;
        this.submitValues.FSM_AM__c = this.amval;
        this.submitValues.FSM_PM__c = this.pmval;
        this.submitValues.FSM_Night__c = this.nightval;
        this.submitValues.FSM_OverheadPowerLinesWithin10m__c = this.powerlines;
        this.submitValues.FSM_IsExcavationRequired__c = this.excavation;
        this.submitValues.FSM_TypeOfLeak__c = this.leaktype;
        this.submitValues.FSM_CommsMethod__c = this.commmethod;
        this.submitValues.FSM_ReasonForFirstTimeReinstatement__c = this.reason;
        this.submitValues.FSM_TrailerTeam__c = this.trailer;
        this.submitValues.FSM_LetterWarn__c = this.letterwarn;
        this.submitValues.FSM_SensitiveCustomer__c = this.sensitivecustomer;
        this.submitValues.FSM_SiteComments__c = this.sitecomm;
        this.submitValues.FSM_OverheadPowerLinesWithin10m__c = this.overheadpowerlines;
        this.submitValues.FSM_LampSupportRemovalRequired__c = this.lampsupport;
        this.submitValues.FSM_ConfinedSpaceWorking__c = this.confinedspace;
        this.submitValues.FSM_Contamination__c = this.contamination;
        this.submitValues.FSM_ContaminationComments__c = this.contaminationcomm;
        this.submitValues.FSM_IsThereConfirmedPollution__c = this.pollution;
        this.submitValues.FSM_ConfirmedPollutionComments__c = this.pollutioncomm;
        this.submitValues.FSM_IsThereARiskOfPollutionOccurring__c = this.risk;
        this.submitValues.FSM_RiskToAnEnvironmentalSite__c = this.riskenv;
        this.submitValues.FSM_IsShutOffOrValveOperationRequired__c = this.isshutoff;
        this.submitValues.FSM_EstimatedNoOfPropertiesAffected__c = this.estimatedproperties;
        this.submitValues.FSM_AlternativeSuppliesRequired__c = this.altsupplies;
        this.submitValues.FSM_SensitiveCustomersOnShutdown__c = this.sensitivecustonshuttdown;
        this.submitValues.FSM_ThirdPartyDamageOccurOnThisSite__c = this.thirdpartydmge;
        this.submitValues.FSM_FormType__c = "Infra Follow On Work Request";
        this.submitValues.RecordTypeId = this.dcfrectypid;
        this.submitValues.FSM_LibraryTimeExtensions__c = this.libext;
        this.submitValues.FSM_PlanningInfoAndComms__c = this.planninginfo;
        if (this.isboppsflow) {
            this.submitValues.FSM_SurfaceType__c = this.surfacetype;
        }

        this.submitValues.FSM_ESTLocationX__c = this.estXloc;
        this.submitValues.FSM_ESTLocationY__c = this.estYloc;
        this.submitValues.FSM_LeakLocation__c = this.leakloc;
        this.submitValues.FSM_VisibleLeak__c = this.visibleleak;
        this.submitValues.FSM_HasLeakBeenQuantified__c = this.leakquantified;
        this.submitValues.FSM_AquaPeaUsed__c = this.aquapeaused;
        this.submitValues.FSM_PostAquaPea__c = this.postaquapea;
        this.submitValues.FSM_FlowValveFitted__c = this.valvefitted;
        this.submitValues.FSM_PostFlowValve__c = this.postflowvalve;
        this.submitValues.FSM_Gassing__c = this.gassing;
        this.submitValues.FSM_PipeMIC__c = this.pipeMic;
        this.submitValues.FSM_IsThisASharedSupply__c = this.issharedsupply;
        this.submitValues.FSM_ResidentialStatus__c = this.residentstatus;
    }

    validateInputFormat(value, digitsBefore, digitsAfter) {
        const regex = new RegExp(`^\\d{1,${digitsBefore}}(\\.\\d{1,${digitsAfter}})?$`);
        return regex.test(value);
    }

    handlesectiononevalidation() {
        this.isvalidscreenone = true;
        let gridxvalid = this.template.querySelector(".gridx");
        let gridyvalid = this.template.querySelector(".gridy");
        this.errormessages = [];
        if (gridxvalid.value < 250000 || gridxvalid.value > 550000 || gridxvalid.value == '' || gridxvalid.value == null) {
            this.gridxerror = 'Grid X should lie between 250000 and 550000';
            this.errormessages.push(this.gridxerror);
            this.isvalidscreenone = false;
        }
        if (gridyvalid.value < 170000 || gridyvalid.value > 440000 || gridyvalid.value == '' || gridxvalid.value == null) {
            this.gridyerror = 'Grid Y should lie between 170000 and 440000';
            this.errormessages.push(this.gridyerror);
            this.isvalidscreenone = false;
        }
    }
    handlesectiontwovalidation() {
        this.isvalidscreentwo = true;
        this.errormessages = [];
        let occname = this.template.querySelector(".occname");
        let occtelno = this.template.querySelector(".occtelno");
        let occhseno = this.template.querySelector(".occhseno");
        let occstreet = this.template.querySelector(".occstreet");
        let occcity = this.template.querySelector(".occcity");
        let occpostcode = this.template.querySelector(".occpostcode");
        let oname = occname.value;
        if (occstreet.value == null || occstreet.value.length > 60 || occstreet.value == '') {
            this.isvalidscreentwo = false;
            this.errormessages.push('Occupiers Street should be 60 Max characters');
        }
        if (occcity.value == null || occcity.value.length > 40 || occcity.value == '') {
            this.isvalidscreentwo = false;
            this.errormessages.push('Occupiers City should be 40 Max characters');
        }
        if (occpostcode.value == null || occpostcode.value.length > 10 || occpostcode.value == '') {
            this.isvalidscreentwo = false;
            this.errormessages.push('Occupiers postcode should be 10 Max characters');
        }
        if (oname?.length > 80) {
            this.errormessages.push('Occupers name should be 80 - characters max');
            this.isvalidscreentwo = false;
        }
        if (occtelno.value.length > 30) {
                this.isvalidscreentwo = false;
                this.errormessages.push('Enter Valid Occupiers telephone number');
             }
        // removed as SFL-588
        // if ((occtelno.value == null || occtelno.value == '')) {
        //     this.isvalidscreentwo = true;
        // } else if (occtelno.value.length < 30) {
        //     this.isvalidscreentwo = false;
        //     this.errormessages.push('Occupiers telephone no should contain only 11 digits');
        // }
        if (occhseno.value.length > 10) {
            this.isvalidscreentwo = false;
            this.errormessages.push('Occupiers house number should be Max 10 numbers');
        }
    }
    handlesectionthreevalidation() {
        this.sectionthreevalid = true;
        this.errormessages = [];
        let locvalue = this.template.querySelector(".locationcls")
        let preq = this.template.querySelector(".permissionreq");
        let pdig = this.template.querySelector(".permissiontodig");
        let proformasigned = this.template.querySelector(".proformasigned");
        if (locvalue.value == null || locvalue.value == '') {
            this.sectionthreevalid = false;
            this.errormessages.push('Please fill in value in Location');
        }
        if (preq.value == null || preq.value == '' || preq.value == '--None--') {
            this.sectionthreevalid = false;
            this.errormessages.push('Please fill in value in Permission to dig required');
        }
        if (preq.value == 'Yes' && (pdig.value == null || pdig.value == '')) {
            this.sectionthreevalid = false;
            this.errormessages.push('Please fill in value in Permission to dig');
        }
        if (preq.value == 'Yes' && (proformasigned.value == null || proformasigned.value.length > 20 || proformasigned.value == '')) {
            this.sectionthreevalid = false;
            this.errormessages.push('20 Max characters allowed for field proformasigned');
        }
        if (preq.value == 'No') {
            this.sectionthreevalid = true;
            this.errormessages = [];
        }
    }
    handlesectionfourvalidation() {
        this.errormessages = [];
        this.isvalidscreenfour = true;
        let uid = this.template.querySelector(".assetuidcls");
        let size = this.template.querySelector(".sizecls");
        let task = this.template.querySelector(".taskcls");
        let technique = this.template.querySelector(".techniquecls");
        let asset = this.template.querySelector(".assetcls");
        let material = this.template.querySelector(".materialcls");
        if (material.value == '' || material.value == null) {
            this.errormessages.push('Please select a value in Material');
            this.isvalidscreenfour = false;
        }
        if (size.value == '' || size.value == null) {
            this.errormessages.push('Please select a value in Size');
            this.isvalidscreenfour = false;
        }
        if (task.value == '' || task.value == null) {
            this.errormessages.push('Please select a value in Task');
            this.isvalidscreenfour = false;
        }
        if (technique.value == '' || technique.value == null) {
            this.errormessages.push('Please select a value in Technique');
            this.isvalidscreenfour = false;
        }
        if (asset.value == '' || asset.value == null) {
            this.errormessages.push('Please select a value in Asset');
            this.isvalidscreenfour = false;
        } if (asset.value == 'D 2' && (uid.value == null || uid.value == '')) {
            this.errormessages.push('Please fill in value in Asset UID');
            this.isvalidscreenfour = false;
        }
    }

    handlesectionfivevalidation() {
        this.errormessages = [];
        this.isvalidscreenfive = true;
        let ltype = this.template.querySelector(".leaktypecls");
        let surftype = this.template.querySelector(".surfacetypecls");
        let serial = this.template.querySelector(".meterserialcls");
        let estXlocval = this.template.querySelector(".estXloccls");
        let estYlocval = this.template.querySelector(".estYloccls");
        let leaklocval = this.template.querySelector(".leakloccls");
        let visibleleakval = this.template.querySelector(".visibleleakcls");
        let leakquantifiedval = this.template.querySelector(".leakquantifiedcls");
        let meterserialval = this.template.querySelector(".meterserialcls");
        let meterreadingval = this.template.querySelector(".meterreadingcls");
        let leakquantcval = this.template.querySelector(".leakquantcls");
        let sharedsupplyempty = this.template.querySelector(".sharedsupplycls");
        if (ltype.value == null || ltype.value == '' || surftype == null || surftype == '' || serial == null || serial == ''
            || estXlocval == null || estXlocval == '' || estYlocval == null || estYlocval == '' || leaklocval == null || leaklocval == ''
            || visibleleakval == null || visibleleakval == '' || leakquantifiedval == null || leakquantifiedval == '' ||
            meterserialval == null || meterserialval == '' || meterreadingval == null || meterreadingval == '' || leakquantcval == null || leakquantcval == '' || sharedsupplyempty == null || sharedsupplyempty == '' || sharedsupplyempty == undefined) {
            this.errormessages.push('Please fill in all mandatory fields');
            this.isvalidscreenfive = false;
        }
        if ((estXlocval.value != null || estXlocval.value != '') && estXlocval.value.length != 6) {

            this.errormessages.push('Please enter 6 digits in EST Location (X)');
            this.isvalidscreenfive = false;
        }
        if ((estYlocval.value != null || estYlocval.value != '') && estYlocval.value.length != 6) {

            this.errormessages.push('Please enter 6 digits in EST Location (Y)');
            this.isvalidscreenfive = false;
        }
    }
    handlesectionsixvalidation() {
        this.errormessages = [];
        this.isvalidscreensix = true;
        let aquapeausedval = this.template.querySelector(".aquapeausedcls");
        let postaquapeaval = this.template.querySelector(".postaquapeacls");
        let valvefittedval = this.template.querySelector(".valvefittedcls");
        let postflowvalveval = this.template.querySelector(".postflowvalvecls");
        let gassingval = this.template.querySelector(".gassingcls");
        let pipeMicval = this.template.querySelector(".pipeMiccls");
        let isValidAquapeauseValue = this.validateInputFormat(postaquapeaval.value, 4, 2);
        let isValidPostFlowValveValue = this.validateInputFormat(postflowvalveval.value, 4, 2);
        if (aquapeausedval.value == undefined || aquapeausedval.value == '' || aquapeausedval.value == null || postaquapeaval.value == undefined || postaquapeaval.value == '' || postaquapeaval.value == null ||
            valvefittedval.value == undefined || valvefittedval.value == '' || valvefittedval.value == null || postflowvalveval.value == undefined || postflowvalveval.value == '' || postflowvalveval.value == null || gassingval.value == undefined || gassingval.value == '' || gassingval.value == null || pipeMicval.value == undefined || pipeMicval.value == '' || pipeMicval.value == null) {
            this.errormessages.push('Please fill in all mandatory fields');
            this.isvalidscreensix = false;
        }
        else if (isValidAquapeauseValue === false) {
            this.errormessages.push("Invalid input for Post AquaPea (LPH). Use up to 4 digits before and 2 digits after the decimal.");
            this.isvalidscreensix = false;
        }
        else if (isValidPostFlowValveValue === false) {
            this.errormessages.push("Invalid input for Post flow Valve (LPH). Use up to 4 digits before and 2 digits after the decimal.");
            this.isvalidscreensix = false;
        }

        else {
            this.isvalidscreensix = true;
        }
    }

    handlesectionsevenvalidation() {
        this.errormessages = [];
        this.isvalidscreenseven = true;
        let excavation = this.template.querySelector(".excavationcls");
        let ltype = this.template.querySelector(".leaktypecls");
        let trailerval = this.template.querySelector(".trailercls");
        let letterval = this.template.querySelector(".letterwarncls");
        let sitecomments = this.template.querySelector(".sitecommcls");
        let methodcomm = this.template.querySelector(".cmethodcls");
        if (excavation.value == '' || excavation.value == null || ltype.value == '' || ltype.value == null ||
            trailerval.value == '' || trailerval.value == null || letterval.value == '' || letterval.value == null || sitecomments.value == '' || sitecomments.value == null || methodcomm.value == '' || methodcomm.value == null) {
            this.errormessages.push('Please fill in all mandatory fields');
            this.isvalidscreenseven = false;
        }
    }
    handlesectionninevalidation() {
        this.isvalidscreennine = true;
        this.errormessages = [];
        let powerlines = this.template.querySelector(".overheadpowerlinescls");
        let lampsupport = this.template.querySelector(".lampsupportcls");
        let confinedspace = this.template.querySelector(".confinedspacecls");
        let planninginfocomm = this.template.querySelector(".planningfocls");
        if (powerlines.value == null || lampsupport.value == null || confinedspace.value == null || planninginfocomm.value == null
            || powerlines.value == undefined || lampsupport.value == undefined || confinedspace.value == undefined || planninginfocomm.value == undefined) {
            this.isvalidscreennine = false;
            this.errormessages.push('Please fill in mandatory fields');
        } else {
            if (planninginfocomm.value.length > 1000) {
                this.isvalidscreennine = false;
                this.errormessages.push('planninginfocomm comments should have 1000 Max characters');
            } else {
                this.isvalidscreennine = true;
            }
        }
    }

    handleadditionalcustvalidation() {
        this.isvalidadditionalcustomer = true;
        this.errormessages = [];
        this.customerdata.forEach(phoneNumber => {
            if (phoneNumber.FSM_ContactNumber__c !== null) {
                const numericValue = phoneNumber.FSM_ContactNumber__c.replace(/\D/g, '');
                if (numericValue.length !== 11) {
                    this.isvalidadditionalcustomer = false;
                    this.errormessages.push("Phone number must be exactly 11 digits.");
                }
            }


        });

    }
    handlesectiontenvalidation() {
        this.isvalidsectionten = true;
        this.errormessages = [];
        let contaminationcomments = this.template.querySelector(".contaminationcommcls");
        let pollutionsel = this.template.querySelector(".pollutioncls");
        let polltncomm = this.template.querySelector(".pollutioncommcls");
        let riskoccur = this.template.querySelector(".riskoccurringcls");
        let envrisk = this.template.querySelector(".riskenvcls");
        let contaminationreq = this.template.querySelector('.contaminationcls');
        if (pollutionsel.value == '' || pollutionsel.value == null || contaminationreq.value == '' || contaminationreq.value == null || envrisk.value == '' || envrisk.value == null) {
            this.isvalidsectionten = false;
            this.errormessages.push('Please fill in values in the fields marked as required');
        }
        if (this.iscontaminationyes == true && (contaminationcomments.value == null || contaminationcomments.value == '')) {
            this.isvalidsectionten = false;
            this.errormessages.push('Please fill in value in Contamination Comments');
        }
        if (this.ispollutionyes == true && (polltncomm.value == null || polltncomm.value == '')) {
            this.isvalidsectionten = false;
            this.errormessages.push('Please fill in value in Confirmed Pollution Comments');

        }
        if (this.ispollutionyes == false && (riskoccur.value == '' || riskoccur.value == null)) {
            this.isvalidsectionten = false;
            this.errormessages.push('Please select value in Is there a risk of pollution occurring');

        }
    }

    handlesectionelevenvalidation() {
        this.isvalidscreeneleven = true;
        this.errormessages = [];
        let estimatedpropertiesval = this.template.querySelector(".estimatedpropertiescls");
        let altsuppliesval = this.template.querySelector(".altsuppliescls");
        let sensitivecustonshuttdownval = this.template.querySelector(".sensitivecustonshuttdowncls");
        let thirdpartydmgeval = this.template.querySelector(".thirdpartydmgecls");
        let shutoffvalve = this.template.querySelector(".isshutoffcls");
        if (!!shutoffvalve.value) {
            if (this.isshutoff == 'Yes') {
                if (estimatedpropertiesval.value == '' || altsuppliesval.value == null || sensitivecustonshuttdownval.value == '' ||
                    estimatedpropertiesval.value == null || altsuppliesval.value == '' || sensitivecustonshuttdownval.value == null) {
                    this.isvalidscreeneleven = false;
                    this.errormessages.push('Please fill all fields marked mandatory');
                }
            } else if (this.isshutoff == 'No') {
                if (thirdpartydmgeval.value == null || thirdpartydmgeval.value == '') {
                    this.isvalidscreeneleven = false;
                    this.errormessages.push('Please fill all fields marked mandatory');
                }
            } else {
                this.isvalidscreeneleven = true;
            }
        } else {
            this.isvalidscreeneleven = false;
            this.errormessages.push('Please fill all fields marked mandatory');
        }
    }


    handlePrevious() {
        if (this.sectionone) {
            return;
        } else if (this.sectiontwo) {
            this.savesectiononevalues();
            this.errormessages = [];
            this.sectionone = true;
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        } else if (this.sectionthree) {
            this.savesectiononevalues();
            this.errormessages = [];
            this.sectiontwo = true;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        } else if (this.sectionfour) {
            this.savesectiononevalues();
            this.savesectionfourvalues();
            this.errormessages = [];
            this.sectiontwo = false;
            this.sectionthree = true;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        } else if (this.sectionfive) {
            this.savesectiononevalues();
            this.errormessages = [];
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = true;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        } else if (this.sectionadditionalcustomer) {
            this.savesectiononevalues();
            this.handlepreviousfromcustomertable();
            this.errormessages = [];
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = true;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        }
        else if (this.sectionsix) {
            this.errormessages = [];
            this.savesectiononevalues();
            if (this.sharedsupplyyes == true || this.issharedsupply == 'Yes') {
                this.retaintcustomerlineitemfromsecsix();
            }
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            if (this.sharedsupplyyes == true || this.issharedsupply == 'Yes') {
                this.sectionfive = false;
                this.sectionadditionalcustomer = true;
            } else {
                this.sectionfive = true;
                this.sectionadditionalcustomer = false;
            }
        } else if (this.sectionseven) {

            this.savesectiononevalues();
            this.errormessages = [];
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
            if ((this.selectedasset == 'D 28' || this.selectedasset == 'D 29' || this.selectedasset == 'D 30' || this.selectedasset == 'D 31') && this.occlocation == 'Private Land') {
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = true;
                this.sectionseven = false;
            } else {
                this.sectionfour = true;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
            }

        } else if (this.sectioneight) {

            this.errormessages = [];
            this.savesectiononevalues();
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = true;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        } else if (this.sectionnine) {
            this.errormessages = [];
            this.savesectiononevalues();
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionadditionalcustomer = false;
            if (this.occlocation == 'Public Highway') {
                this.enablesecsixofchild = true;
                this.dontloadgetrec = this.hasRun;
                this.sectionseven = false;
                this.sectioneight = true;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = false;
            } else {
                this.sectionseven = true;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = false;

            }
        } else if (this.sectionten) {
            this.errormessages = [];
            this.savesectiononevalues();
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = true;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        } else if (this.sectioneleven) {
            this.errormessages = [];
            this.savesectiononevalues();
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = true;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        } else if (this.sectiontwelve) {
            this.errormessages = [];
            this.savesectiononevalues();
            this.handlepreviousfromtable();
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = true;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        } else if (this.sectionthirteen) {
            this.errormessages = [];
            this.savesectiononevalues();
            this.saveData();
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = true;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
        }
    }
    handleNext() {
        if (this.sectionone) {
            this.savesectiononevalues();
            this.handlesectiononevalidation();
            if (this.isvalidscreenone) {
                this.sectionone = false;
                this.sectiontwo = true;
                this.sectionthree = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = false;
                this.sectionadditionalcustomer = false;
            } else {
                console.log('error in sec one');
            }
        } else if (this.sectiontwo) {
            this.savesectiononevalues();
            if (this.isdiffaddrr) {
                this.handlesectiontwovalidation();
            } else {
                this.isvalidscreentwo = true;
            }
            if (this.isvalidscreentwo) {
                this.sectionthree = true;
                this.sectiontwo = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = false;
                this.sectionadditionalcustomer = false;
            } else {
                console.log('error in sec two');
            }
        } else if (this.sectionthree) {
            if (this.isEdit && this.dependentRecordsLoaded == false) {
                console.log('inside line 1392');
                this.handleAssetChange();
                this.handleTaskChange();
                this.handleTechniqueChange();
                this.handleSizeChange();
                this.dependentRecordsLoaded = true;
            }
            this.savesectiononevalues();
            this.handlesectionthreevalidation();
            if (this.sectionthreevalid) {
                this.sectionthree = false;
                this.sectiontwo = false;
                this.sectionone = false;
                this.sectionfour = true;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = false;
                this.sectionadditionalcustomer = false;
            } else {
                console.log('error in sec three');
            }
        } else if (this.sectionfour) {
            this.savesectiononevalues();
            this.handlesectionfourvalidation();
            if (this.isvalidscreenfour) {
                //added as part of sfs-5312
                this.checkConditions();
                if (this.stopFlow == false) {
                    this.sectiontwo = false;
                    this.sectionthree = false;
                    this.sectionone = false;
                    this.sectionfour = false;
                    this.sectioneight = false;
                    this.sectionnine = false;
                    this.sectionten = false;
                    this.sectioneleven = false;
                    this.sectiontwelve = false;
                    this.sectionthirteen = false;
                    this.sectionadditionalcustomer = false;
                    if ((this.selectedasset == 'D 28' || this.selectedasset == 'D 29' || this.selectedasset == 'D 30' || this.selectedasset == 'D 31') && this.occlocation == 'Private Land') {

                        this.isboppsflow = true;
                        this.istmaflow = false;
                        this.isnormalflow = false;
                        this.sectionfive = true;
                        this.sectionsix = false;
                        this.sectionseven = false;
                        if (this.isEdit == true && this.isboppsflow == true) {
                            this.clearalltmanoticedetailsvalues();
                            this.clearallnormalscreenvalues();
                        }
                    } else {
                        this.isboppsflow = false;
                        this.sectionfive = false;
                        this.sectionsix = false;
                        this.sectionseven = true;
                    }

                    this.savesectionfourvalues();
                } else {
                    //stop the flow at Asset screen and do not allow user to proceed to gold sketch 
                    this.createDCFrecord();
                }
            }
            else {
                console.log('error in secfour')
            }

        } else if (this.sectionfive) {
            this.savesectiononevalues();
            if (this.issharedsupply == 'Yes' || this.sharedsupplyyes == 'true') {
                this.retaincustomertablevalues();
            }
            this.handlesectionfivevalidation();
            if (this.isvalidscreenfive) {
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = false;
                if (this.issharedsupply == 'Yes' || this.sharedsupplyyes == 'true') {
                    this.sectionadditionalcustomer = true;
                    this.sectionsix = false;
                } else {
                    this.sectionadditionalcustomer = false;
                    this.sectionsix = true;
                }
            } else {
                console.log('error in section 5')
            }
        }
        else if (this.sectionadditionalcustomer) {
            this.errormessages = [];
            this.savesectiononevalues();
            this.handleadditionalcustvalidation();
            if (this.isvalidadditionalcustomer) {
                if (this.issharedsupply == 'Yes') {
                    this.saveCustomerLineitems();
                }
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionadditionalcustomer = false;
                this.sectionsix = true;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = false;
            } else {
                console.log('error in section additional customer');
            }
        }
        else if (this.sectionsix) {
            this.errormessages = [];
            this.handlesectionsixvalidation();
            this.savesectiononevalues();
            if (this.isvalidscreensix) {
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                //if bopps flow end the form here and go to photocapture
                if (this.isboppsflow || ((this.selectedasset == 'D 28' || this.selectedasset == 'D 29' || this.selectedasset == 'D 30' || this.selectedasset == 'D 31') && this.occlocation == 'Private Land')) {
                    this.sendvaluestofsmfurtherworkrequest();
                    this.sectionsix = false;
                    this.sectionseven = false;
                    this.sectioneight = false;
                    this.sectionnine = false;
                    this.sectionten = false;
                    this.sectioneleven = false;
                    this.sectiontwelve = false;
                    this.sectionthirteen = false;
                    this.sectionadditionalcustomer = false;
                } else {
                    this.isboppsflow = false;
                    this.istmaflow = false;
                    this.isnormalflow = true;
                    this.sectionsix = false;
                    this.sectionseven = true;
                    this.sectioneight = false;
                    this.sectionnine = false;
                    this.sectionten = false;
                    this.sectioneleven = false;
                    this.sectiontwelve = false;
                    this.sectionthirteen = false;
                    this.sectionadditionalcustomer = false;
                }
            } else {
                console.log('error in section six');
            }

        } else if (this.sectionseven) {
            const sendvaluestotmacmp = JSON.parse(JSON.stringify(this.submitValues));
            this.senddatatotmacmp = sendvaluestotmacmp;
            this.savesectiononevalues();
            this.handlesectionsevenvalidation();
            if (this.isvalidscreenseven) {
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
                this.sectionadditionalcustomer = false;
                if (this.occlocation == 'Public Highway') {
                    this.isboppsflow = false;
                    this.istmaflow = true;
                    this.isnormalflow = false;
                    this.sectioneight = true;
                    this.sectionnine = false;
                    this.sectionten = false;
                    this.sectioneleven = false;
                    this.sectiontwelve = false;
                    this.sectionthirteen = false;
                    if (this.isEdit == true && this.istmaflow == true) {
                        this.clearallboppssectionvariables();
                        //this.clearallnormalscreenvalues();
                    }
                } else {
                    this.isboppsflow = false;
                    this.istmaflow = false;
                    this.isnormalflow = true;
                    // this.clearalltmanoticedetailsvalues();
                    this.sectioneight = false;
                    this.sectionnine = true;
                    this.sectionten = false;
                    this.sectioneleven = false;
                    this.sectiontwelve = false;
                    this.sectionthirteen = false;
                }
            } else {
                console.log('error in section seven');
            }
        } else if (this.sectioneight) {
            this.savesectiononevalues();
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = true;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false; //return;
        } else if (this.sectionnine) {
            this.savesectiononevalues();
            this.handlesectionninevalidation();
            if (this.isvalidscreennine) {
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = true;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = false;
                this.sectionadditionalcustomer = false;
            } else {
                console.log('error in section nine');
            }
        } else if (this.sectionten) {
            this.savesectiononevalues();
            this.handlesectiontenvalidation();
            if (this.isvalidsectionten) {
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = true;
                this.sectiontwelve = false;
                this.sectionthirteen = false;
                this.sectionadditionalcustomer = false;
            } else {
                console.log('error in section ten')
            }
        } else if (this.sectioneleven) {
            this.handlesectionelevenvalidation();
            this.savesectiononevalues();
            this.retaintablevalues();
            if (this.isvalidscreeneleven) {
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = true;
                this.sectionthirteen = false;
                this.sectionadditionalcustomer = false;
                if (this.isshutoff == 'No') {
                    this.sendvaluestofsmfurtherworkrequest();
                    this.sectiontwelve = false;
                    this.sectionthirteen = false;
                }
            }
        } else if (this.sectiontwelve) {
            this.handlesectiontwelvevalidation();
            if (this.isvalidsectiontwelve) {
                this.saveData();
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = false;
                this.sectionseven = false;
                this.sectioneight = false;
                this.sectionnine = false;
                this.sectionten = false;
                this.sectioneleven = false;
                this.sectiontwelve = false;
                this.sectionthirteen = true;
                this.sectionadditionalcustomer = false;
            } else {
                console.log('error in section twelve')
            }
        } else if (this.sectionthirteen) {
            return;
        }
    }
    get isEnableNext() {
        if (this.sectionone == true || this.sectiontwo == true || this.sectionthree == true || this.sectionfour == true || this.sectionfive == true || this.sectionadditionalcustomer == true || this.sectionsix == true || this.sectionseven == true || this.sectionnine == true || this.sectionten == true || this.sectioneleven == true || this.sectiontwelve == true) {
            return true;
        }
        else {
            return false;
        }
    }
    //added as part of sfs-5312
    //This method checks if the combinations of dependant picklist selected by user should allow user to proceed to gold sketch or not
    checkConditions() {
        
        if ((this.selectedasset == 'D 28' && this.selectedtechnique == '59' && this.seltask == 'D 18' && this.selmaterial == '99' && this.selsize == '99') && (this.occlocation == 'Find and Fix location')) {
            this.stopFlow = true;
        } else if ((this.selectedasset == 'D 28' && this.selectedtechnique == '59' && this.seltask == 'D 42' && this.selmaterial == '99' && this.selsize == '99') && (this.occlocation == 'Private Land')) {
            this.stopFlow = true;
        } else if ((this.selectedasset == 'D 29' && this.selectedtechnique == '59' && this.seltask == 'D 18' && this.selmaterial == '99' && this.selsize == '99') && (this.occlocation == 'Find and Fix location')) {
            this.stopFlow = true;
        }
        else if ((this.selectedasset == 'D 28' && this.selectedtechnique == '59' && this.seltask == 'D 42' && this.selmaterial == '99' && this.selsize == '99') && (this.occlocation == 'Find and Fix location')) {
            this.stopFlow = true;
        } // Added by Monica on 01/09/2025 as part of Origin No Dig task FS-5149
        else if (((this.selectedasset == 'D 5' || this.selectedasset == 'D 6') && this.seltask == 'D 2' && this.selectedtechnique == '76' && this.selmaterial == '99' && this.selsize == '99') && (this.occlocation == 'Find and Fix location' || this.occlocation == 'Private Land')) {
            this.stopFlow = true;
        }else {
            this.stopFlow = false;
        }
        console.log(this.stopFlow)
    }
    get isEnablePrev() {
        if (this.sectiontwo == true || this.sectionthree == true || this.sectionfour == true || this.sectionadditionalcustomer == true || this.sectionfive == true || this.sectionsix == true || this.sectionseven == true || this.sectionnine == true || this.sectionten == true || this.sectioneleven == true || this.sectiontwelve == true) {
            return true;
        }
        else {
            return false;
        }
    }
    handleaddresschange(event) {
        this.isdiffaddrr = event.detail.checked;
        this.ischeckeddiffaddr = this.isdiffaddrr;
        if (this.isdiffaddrr) {
            this.isnotatdiffadrr = true;
        } else {
            this.isnotatdiffadrr = false;
            // this.occname = '';
            // this.occtelno = '';
            // this.occcity = '';
            // this.occlocation = '';
            // this.occpostcode = '';
            // this.occstown = '';
            // this.occstreet = '';
            // this.occhsename = '';
            // this.occhseno = '';
        }
    }
    handleaccessissueschange(event) {
        this.accessissues = event.detail.checked;
        this.isaccesschecked = this.accessissues;
    }
    handlelocationchange(event) {
        this.occlocation = event.detail.value;
    }
    ShowToastEvent(error) {
        const event = new ShowToastEvent({
            title: 'Please fill in appropriate details',
            message: `${error}\n111\n2222\n3333`,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    sendvaluestofsmfurtherworkrequest() {
        this.dataloaded = true;
        if (this.isEdit == true && this.isnormalflow == true) {
            this.clearallboppssectionvariables();
            this.clearalltmanoticedetailsvalues();
        }
        console.log('inside sendvaluestofsmfurtherworkrequest', this.hasRun, this.hasRunWired);
        if ((this.ischangedboppsflow != this.isboppsflow) && this.isboppsflow == false && this.ischangedboppsflow == true) {
            console.log('blank out bops section fields');
            this.clearallboppssectionvariables();
        } else if ((this.ischangedtmaflow != this.istmaflow) && this.istmaflow == false && this.ischangedtmaflow == true) {
            console.log('blank out tma section fields');
            this.clearalltmanoticedetailsvalues();
        } else if ((this.ischangednormalflow != this.isnormalflow) && this.isnormalflow == false && this.ischangednormalflow == true && this.istmaflow == false) {
            console.log('blank out normal section fields');
            this.clearallnormalscreenvalues();
        } else {
            console.log('do nothing');
        }
        if (!!JSON.stringify(this.dcfinfrarecorddata)) {

            const finalarr = { ...this.dcfinfrarecorddata, ...this.submitValues }
            console.log('finalarr', JSON.stringify(this.finalarr), 'submitValues', JSON.stringify(this.submitValues), 'dcfinfrarecorddata ', JSON.stringify(this.dcfinfrarecorddata));
            //if BOPP's flow is selected send customer line item data
            if (this.isboppsflow) {
                const event = new CustomEvent('finalsubmit', {
                    detail: { dcfdata: finalarr, customerlineitems: this.addcustomerlineitemdata, isboppsflow: this.isboppsflow, istmaflow: this.istmaflow, isnormalflow: this.isnormalflow, hasexecutedwire: this.hasRun, hasexecutedlineitems: this.hasRunWired }
                });
                this.dispatchEvent(event);
            } else {
                const event = new CustomEvent('finalsubmit', {
                    detail: { dcfdata: finalarr, dcflineitemdata: this.dcflineitemdata, isboppsflow: this.isboppsflow, istmaflow: this.istmaflow, isnormalflow: this.isnormalflow, hasexecutedwire: this.hasRun, hasexecutedlineitems: this.hasRunWired }
                });
                this.dispatchEvent(event);
            }

        } else {
            if (this.isboppsflow) {
                console.log('submitValues', this.submitValues);
                const event = new CustomEvent('finalsubmit', {
                    detail: { dcfdata: this.submitValues, customerlineitems: this.addcustomerlineitemdata, isboppsflow: this.isboppsflow, istmaflow: this.istmaflow, isnormalflow: this.isnormalflow, hasexecutedwire: this.hasRun, hasexecutedlineitems: this.hasRunWired }
                });
                this.dispatchEvent(event);
            }
            else {
                const event = new CustomEvent('finalsubmit', {
                    detail: { dcfdata: this.submitValues, dcflineitemdata: this.dcflineitemdata, isboppsflow: this.isboppsflow, istmaflow: this.istmaflow, isnormalflow: this.isnormalflow, hasexecutedwire: this.hasRun, hasexecutedlineitems: this.hasRunWired }
                });
                this.dispatchEvent(event);
            }
        }
    }

    handlepreviousfromchild(event) {
        this.submitValues = { ...this.submitValues, ...event.detail }
        this.retainvaluestochild = { ...event.detail }
        this.enablesecsixofchild = false;
        this.sectioneight = false;
        this.sectionseven = true;
        this.dontloadgetrec = event.detail.isvisited;
    }
    //on next from tma notice details section
    handlenextfromfsmnotice(event) {
        console.log('inside handlenextfromfsmnotice');
        this.submitValues = { ...this.submitValues, ...event.detail }
        this.retainvaluestochild = { ...event.detail }
        this.sectioneight = false;
        this.sectionnine = true;
    }
    @wire(getObjectInfo, { objectApiName: FSM_DCFDependantPicklist__c })
    objectInfo;
    //dev 0122z000002cefnAAA
    //qa 0122z000002d76PAAQ
    @wire(getPicklistValuesByRecordType, { objectApiName: 'FSM_DataCaptureFormInfra__c', recordTypeId: '012000000000000AAA' })
    dcfinfrapicklistvalues({ error, data }) {
        if (data) {
            this.permissionoptions = data.picklistFieldValues.FSM_PermissionToDigRequired__c.values;
            this.digoptions = data.picklistFieldValues.FSM_PermissionToDig__c.values;
            this.locationoptions = data.picklistFieldValues.FSM_Location__c.values;
            this.typeofleakoptions = data.picklistFieldValues.FSM_TypeOfLeak__c.values;
            this.reinstatementoptions = data.picklistFieldValues.FSM_ReasonForFirstTimeReinstatement__c.values;
            this.letterwarnoptions = data.picklistFieldValues.FSM_LetterWarn__c.values;
            this.customeroptions = data.picklistFieldValues.FSM_SensitiveCustomer__c.values;
            this.optionscommsmethod = data.picklistFieldValues.FSM_CommsMethod__c.values;
            this.surfacetypeoptions = data.picklistFieldValues.FSM_SurfaceType__c.values;
            this.leakquantifiedoptions = data.picklistFieldValues.FSM_HasLeakBeenQuantified__c.values;
            this.leaklocaoptions = data.picklistFieldValues.FSM_LeakLocation__c.values;
            this.visibleleakoptions = data.picklistFieldValues.FSM_VisibleLeak__c.values;
            this.aquapeausedoptions = data.picklistFieldValues.FSM_AquaPeaUsed__c.values;
            this.pipeMicoptions = data.picklistFieldValues.FSM_PipeMIC__c.values;
            this.gassingptions = data.picklistFieldValues.FSM_Gassing__c.values;
            this.valvefittedoptions = data.picklistFieldValues.FSM_FlowValveFitted__c.values;
            this.sharedsupplyoptions = data.picklistFieldValues.FSM_IsThisASharedSupply__c.values;
            //added as part of sfs-6575
            this.residentstatusoptions = data.picklistFieldValues.FSM_ResidentialStatus__c.values;
        }

    }
    handleChangepermissiontodigreq(event) {
        this.permissiontodigreq = event.detail.value;
        if (this.permissiontodigreq == "Yes") {
            this.isyesptd = true;
        } else {
            this.isyesptd = false;
        }
    }
    //added as part of sfs-6575
    handleChangeResidantStatus(event) {
        this.residentstatus = event.detail.value;
    }
    handleChangelocation(event) {
        this.occlocation = event.detail.value;
    }

    handleChangedig(event) {
        this.permissiondig = event.detail.value;
    }

    handlecontaminationchange(event) {
        let contaminationval = event.detail.value;
        this.contamination = contaminationval;
        if (contaminationval == 'Yes') {
            this.iscontaminationyes = true;
        } else {
            this.iscontaminationyes = false;
        }
    }
    handlepollutionchange(event) {
        let pollutionval = event.detail.value;
        this.pollution = pollutionval;

        if (pollutionval == 'Yes') {
            this.ispollutionyes = true;
            this.ifnoconfirmedpollution = false;
        } else {
            this.ispollutionyes = false;
            this.ifnoconfirmedpollution = true;
        }
    }
    handlechangeshutoffoperation(event) {
        this.selshutoffoperation = event.target.value;
        this.isshutoff = this.selshutoffoperation;
        if (this.selshutoffoperation == 'Yes') {
            this.isshutofforvalvesel = true;
        } else {
            this.isshutofforvalvesel = false;
        }
    }

    //table functions
    handleInputChange(event) {
        const index = event.target.dataset.index;
        const field = event.target.dataset.field;
        const value = event.target.value;
        this.data[index][field] = value;
    }

    handleCustomerInputChange(event) {
        const index = event.target.dataset.index;
        const field = event.target.dataset.field;
        const value = event.target.value;
        this.customerdata[index][field] = value;
    }

    handleAddRow() {
        const newRow = {
            id: this.data.length + 1,
            recordId: '',
            FSM_ValvesIDIdentifiedOnSketch__c: '',
            FSM_ProposedOp__c: '',
            FSM_ValveChecked__c: '',
            FSM_GridRefX__c: '',
            FSM_GridRefY__c: '',
            FSM_CommentsForAllValves__c: ''
        };
        this.data = [...this.data, newRow];
    }

    handleAddRowCustomerTable() {
        const newRow = {
            id: this.customerdata.length + 1,
            recordId: '',
            FSM_CustomerName__c: '',
            FSM_ResidentialStatus__c: '',
            FSM_Address__c: '',
            FSM_ContactNumber__c: '',
            FSM_ContactWithCustomer__c: '',
            FSM_CanISTBeIsolated__c: ''
        };
        this.customerdata = [...this.customerdata, newRow];
    }
    handleDelete(event) {

        const index = event.target.dataset.index;

        if (this.isEdit == true) {
            let rectodel = this.data[index].recordId;

            if (rectodel) {

                this.deletedcflineitem(rectodel);
            }

        }
        this.data.splice(index, 1);
        this.data = [...this.data];
    }

    async deletedcflineitem(recid) {
        try {
            await deleteRecord(recid);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: 'Error while deleting line item',
                    variant: 'error'
                })
            );
        }
    }
    handleDeleteRowCustomerTable(event) {
        const index = event.target.dataset.index;
        if (this.isEdit == true) {
            let rectodel = this.customerdata[index].recordId;
            if (rectodel) {
                this.deletedcflineitem(rectodel);
            }
        }
        this.customerdata.splice(index, 1);
        this.customerdata = [...this.customerdata];
    }
    //store values when navigating from section sectionadditionalcustomer to section five
    handlepreviousfromcustomertable() {
        this.storecustomertabledata = JSON.parse(JSON.stringify(this.customerdata));
    }
    // display the values stored while navigating from section five to section sectionadditionalcustomer
    retaincustomertablevalues() {
        if (this.storecustomertabledata == undefined) {
        } else {
            this.storecustomertabledata.forEach(record => {

                if (!this.customerdata.some(item => item.id == record.id))
                    this.customerdata.push(record)

            });
        }
    }
    retaintcustomerlineitemfromsecsix() {
        if (this.addcustomerlineitemdata == undefined) {
        } else {
            this.customerdata = JSON.parse(JSON.stringify(this.addcustomerlineitemdata));

        }
    }
    //retain values while navigating from section 12 to section 11
    handlepreviousfromtable() {
        this.storetabledata = JSON.parse(JSON.stringify(this.data));
    }
    retaintablevalues() {
        if (this.storetabledata == undefined) {
        } else {
            this.storetabledata.forEach(record => {

                if (!this.data.some(item => item.id == record.id))
                    this.data.push(record)
            });
        }
    }

    retaindcflineitemvalues() {
        if (this.data.length > 0) {
            this.datastoredtable.forEach(record => {
                this.data.push(record)
            });
        }
    }
    saveData() {
        this.dcflineitemdata = JSON.parse(JSON.stringify(this.data))
        this.sendvaluestofsmfurtherworkrequest();
    }
    handlesectiontwelvevalidation() {
        console.log('inside validation section twelve');
        this.isvalidsectiontwelve = true;
        this.errormessages = [];
        this.data.forEach(record => {
            if (record.FSM_GridRefX__c == null || record.FSM_GridRefX__c == undefined || record.FSM_GridRefX__c == ''
                || record.FSM_GridRefY__c == '' || record.FSM_GridRefY__c == null || record.FSM_GridRefY__c == undefined ||
                record.FSM_CommentsForAllValves__c == '' || record.FSM_ValvesIDIdentifiedOnSketch__c == '' || record.FSM_ValvesIDIdentifiedOnSketch__c == undefined ||
                record.FSM_CommentsForAllValves__c == null || record.FSM_CommentsForAllValves__c == undefined || record.FSM_ValvesIDIdentifiedOnSketch__c == null ||
                record.FSM_ProposedOp__c == '' || record.FSM_ProposedOp__c == null || record.FSM_ProposedOp__c == undefined || record.FSM_ProposedOp__c == '--None--' ||
                record.FSM_ValveChecked__c == '' || record.FSM_ValveChecked__c == null || record.FSM_ValveChecked__c == undefined || record.FSM_ValveChecked__c == '--None--') {
                this.isvalidsectiontwelve = false;
                this.errormessages.push("Please fill all fields marked mandatory.");
            }
            if (record.FSM_GridRefX__c < 240000 || record.FSM_GridRefX__c > 550000) {
                this.isvalidsectiontwelve = false;
                this.errormessages.push('Grid X should lie between 240000 and 550000');
            }
            if (record.FSM_GridRefY__c < 170000 || record.FSM_GridRefY__c > 440001) {
                this.isvalidsectiontwelve = false;
                this.errormessages.push('Grid Y should lie between 170000 and 440000');
            }
        });
        console.log('end validation section twelve', this.isvalidsectiontwelve);
    }
    //save customer table data and send it to next component
    saveCustomerLineitems() {
        this.addcustomerlineitemdata = JSON.parse(JSON.stringify(this.customerdata));
        // this.sendvaluestofsmfurtherworkrequest();
    }

    //0122z000002d76OAAQ----->qa
    //0122z000002chGzAAI------->dev

    @wire(getPicklistValuesByRecordType, { objectApiName: FSM_DCFLineItemInfraOBJECT, recordTypeId: '012000000000000AAA' })
    tablepicklistValues({ error, data }) {
        if (data) {
            this.error = null;
            let proposedoptions = [{ label: '--None--', value: '--None--' }];
            let valveoptions = [{ label: '--None--', value: '--None--' }];
            let sharedsupplyarr = [{ label: '--None--', value: '--None--' }];
            let residentialstatusarr = [];
            let contactcustomerarr = [];
            let istisolatedarr = [];
            data.picklistFieldValues.FSM_ProposedOp__c.values.forEach(key => {
                proposedoptions.push({
                    label: key.label,
                    value: key.value
                })

            })
            this.proposedoparr = proposedoptions;
            data.picklistFieldValues.FSM_ValveChecked__c.values.forEach(key => {
                valveoptions.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.valvescheckedarr = valveoptions;
            data.picklistFieldValues.FSM_ResidentialStatus__c.values.forEach(key => {
                residentialstatusarr.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.residentialstatusoptions = residentialstatusarr;
            //added as part of sfs-5312
            data.picklistFieldValues.FSM_CanISTBeIsolated__c.values.forEach(key => {
                istisolatedarr.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.canistbeisolatedoptions = istisolatedarr;
            data.picklistFieldValues.FSM_ContactWithCustomer__c.values.forEach(key => {
                contactcustomerarr.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.contactcustomeroptions = contactcustomerarr;
        }
    }
    savesectionfourvalues() {
        let assetvalue = this.template.querySelector(".assetcls");
        let taskvalue = this.template.querySelector(".taskcls");
        let techniquevalue = this.template.querySelector(".techniquecls");
        let sizevalue = this.template.querySelector(".sizecls");
        let materialvalue = this.template.querySelector(".materialcls");
        this.submitValues.FSM_Asset__c = assetvalue.value;
        this.submitValues.FSM_Task__c = taskvalue.value;
        this.submitValues.FSM_Technique__c = techniquevalue.value;
        this.submitValues.FSM_AssetSize__c = sizevalue.value;
        this.submitValues.FSM_AssetMaterial__c = materialvalue.value;

    }
    @api handlepreviousfromfwr(dcfrecorddata) {
        this.dependentRecordsLoaded = true;
        this.dataloaded = true;
        const dcfforminput = JSON.parse(JSON.stringify(dcfrecorddata));
        this.retainvaluestochild = dcfforminput.dcfdata;
        this.dcfinfralineitemdata = dcfforminput.dcflineitemdata;
        this.dcfinfrarecorddata = dcfforminput.dcfdata;
        this.addcustomerlineitemdata = dcfforminput.customerlineitems;
        this.ischangedboppsflow = dcfforminput.isboppsflow;
        this.ischangednormalflow = dcfforminput.isnormalflow;
        this.ischangedtmaflow = dcfforminput.istmaflow;
        this.isboppsflow = dcfforminput.isboppsflow;
        this.isnormalflow = dcfforminput.isnormalflow;
        this.istmaflow = dcfforminput.istmaflow;
        this.hasRun = dcfforminput.hasexecutedwire;
        this.hasRunWired = dcfforminput.hasexecutedlineitems;
        console.log('this.dcfinfrarecorddata', this.dcfinfrarecorddata);

        if (this.dcfinfrarecorddata.FSM_IsShutOffOrValveOperationRequired__c == 'Yes' && this.isboppsflow == false) {
            this.isshutofforvalvesel = true;
            this.sectionone = false;
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = true;
            this.sectionthirteen = false;
            this.sectionadditionalcustomer = false;
            this.data = JSON.parse(JSON.stringify(this.dcfinfralineitemdata));
        } else if ((this.dcfinfrarecorddata.FSM_Asset__c == 'D 28' || this.dcfinfrarecorddata.FSM_Asset__c == 'D 29' || this.dcfinfrarecorddata.FSM_Asset__c == 'D 30' || this.dcfinfrarecorddata.FSM_Asset__c == 'D 31') && this.dcfinfrarecorddata.FSM_Location__c == 'Private Land') {
            this.sectionone = false;
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = true;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = false;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.isshutofforvalvesel = false;
            this.sectionadditionalcustomer = false;
        } else {
            this.sectionone = false;
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;
            this.sectionseven = false;
            this.sectioneight = false;
            this.sectionnine = false;
            this.sectionten = false;
            this.sectioneleven = true;
            this.sectiontwelve = false;
            this.sectionthirteen = false;
            this.isshutofforvalvesel = false;
            this.sectionadditionalcustomer = false;
        }
        this.gridproposedworkx = this.dcfinfrarecorddata.FSM_GridRefOfProposedWorkX__c;
        this.gridproposedworky = this.dcfinfrarecorddata.FSM_GridRefOfProposedWorkY__c;
        this.isdiffaddrr = this.dcfinfrarecorddata.FSM_SFWIsThisAtADifferentAddress__c;
        this.occname = this.dcfinfrarecorddata.FSM_OccupiersName__c;
        this.occtelno = this.dcfinfrarecorddata.FSM_OccupiersTelephoneNumber__c;
        this.occhsename = this.dcfinfrarecorddata.FSM_OccupiersHouseName__c;
        this.occhseno = this.dcfinfrarecorddata.FSM_OccupiersHouseNo__c;
        this.occstreet = this.dcfinfrarecorddata.FSM_OccupiersStreet__c;
        if (this.isdiffaddrr == true) {
            this.ischeckeddiffaddr = true;
            this.isnotatdiffadrr = true;
        } else {
            this.ischeckeddiffaddr = false;
            this.isnotatdiffadrr = false;
        }
        this.occstown = this.dcfinfrarecorddata.FSM_OccupiersTown__c;
        this.occcity = this.dcfinfrarecorddata.FSM_OccupiersCity__c;
        this.occpostcode = this.dcfinfrarecorddata.FSM_OccupiersPostcode__c;
        this.occlocation = this.dcfinfrarecorddata.FSM_Location__c;
        this.permissiontodigreq = this.dcfinfrarecorddata.FSM_PermissionToDigRequired__c;
        if (this.permissiontodigreq == 'Yes') {
            this.isyesptd = true;
        } else {
            this.isyesptd = false;
        }
        this.proformasigned = this.dcfinfrarecorddata.FSM_WhichProformaSigned__c;
        this.permissiondig = this.dcfinfrarecorddata.FSM_PermissionToDig__c;
        this.assetuuid = this.dcfinfrarecorddata.FSM_AssetUID__c;
        this.dependentRecordsLoaded = true;
        this.selectedasset = this.dcfinfrarecorddata.FSM_Asset__c;
        this.handleAssetChange();
        this.seltask = this.dcfinfrarecorddata.FSM_Task__c;
        this.handleTaskChange();
        this.selectedtechnique = this.dcfinfrarecorddata.FSM_Technique__c;
        this.handleTechniqueChange();
        this.selsize = this.dcfinfrarecorddata.FSM_AssetSize__c;
        this.handleSizeChange();
        this.selmaterial = this.dcfinfrarecorddata.FSM_AssetMaterial__c;
        this.estloc = this.dcfinfrarecorddata.FSM_ESTLocation__c;
        this.leakquant = this.dcfinfrarecorddata.FSM_LeakQuantified__c;
        this.meterserial = this.dcfinfrarecorddata.FSM_MeterSerial__c;
        this.meterreading = this.dcfinfrarecorddata.FSM_MeterReading__c;
        this.accessissues = this.dcfinfrarecorddata.FSM_AccessRestricted__c;
        this.isaccesschecked = this.dcfinfrarecorddata.FSM_AccessRestricted__c;
        this.mon = this.dcfinfrarecorddata.FSM_Monday__c;
        this.ismonchecked = this.dcfinfrarecorddata.FSM_Monday__c;
        this.tues = this.dcfinfrarecorddata.FSM_Tuesday__c;
        this.istuechecked = this.dcfinfrarecorddata.FSM_Tuesday__c;
        this.wed = this.dcfinfrarecorddata.FSM_Wednesday__c;
        this.iswedchecked = this.dcfinfrarecorddata.FSM_Wednesday__c;
        this.thurs = this.dcfinfrarecorddata.FSM_Thursday__c;
        this.isthurschecked = this.dcfinfrarecorddata.FSM_Thursday__c;
        this.fri = this.dcfinfrarecorddata.FSM_Friday__c;
        this.isfrichecked = this.dcfinfrarecorddata.FSM_Friday__c;
        this.sat = this.dcfinfrarecorddata.FSM_Saturday__c;
        this.issatchecked = this.dcfinfrarecorddata.FSM_Saturday__c;
        this.sun = this.dcfinfrarecorddata.FSM_Sunday__c;
        this.issunchecked = this.dcfinfrarecorddata.FSM_Sunday__c;
        this.amval = this.dcfinfrarecorddata.FSM_AM__c;
        this.pmval = this.dcfinfrarecorddata.FSM_PM__c;
        this.nightval = this.dcfinfrarecorddata.FSM_Night__c;
        this.isamchecked = this.dcfinfrarecorddata.FSM_AM__c;
        this.ispmchecked = this.dcfinfrarecorddata.FSM_PM__c;
        this.isnightchecked = this.dcfinfrarecorddata.FSM_Night__c;
        this.powerlines = this.dcfinfrarecorddata.FSM_OverheadPowerLinesWithin10m__c;
        this.excavation = this.dcfinfrarecorddata.FSM_IsExcavationRequired__c;
        this.leaktype = this.dcfinfrarecorddata.FSM_TypeOfLeak__c;
        this.reason = this.dcfinfrarecorddata.FSM_ReasonForFirstTimeReinstatement__c;
        this.trailer = this.dcfinfrarecorddata.FSM_TrailerTeam__c;
        this.letterwarn = this.dcfinfrarecorddata.FSM_LetterWarn__c;
        this.sensitivecustomer = this.dcfinfrarecorddata.FSM_SensitiveCustomer__c;
        this.sitecomm = this.dcfinfrarecorddata.FSM_SiteComments__c;
        this.overheadpowerlines = this.dcfinfrarecorddata.FSM_OverheadPowerLinesWithin10m__c;
        this.lampsupport = this.dcfinfrarecorddata.FSM_LampSupportRemovalRequired__c;
        this.confinedspace = this.dcfinfrarecorddata.FSM_ConfinedSpaceWorking__c;
        this.contamination = this.dcfinfrarecorddata.FSM_Contamination__c;
        this.contaminationcomm = this.dcfinfrarecorddata.FSM_ContaminationComments__c;
        this.pollution = this.dcfinfrarecorddata.FSM_IsThereConfirmedPollution__c;
        if (this.pollution == 'Yes') {
            this.ispollutionyes = true;
            this.ifnoconfirmedpollution = false;
            this.risk = '';
        } else {
            this.ifnoconfirmedpollution = true;
            this.risk = this.dcfinfrarecorddata.FSM_IsThereARiskOfPollutionOccurring__c;
        }
        this.pollutioncomm = this.dcfinfrarecorddata.FSM_ConfirmedPollutionComments__c;

        this.riskenv = this.dcfinfrarecorddata.FSM_RiskToAnEnvironmentalSite__c;
        this.isshutoff = this.dcfinfrarecorddata.FSM_IsShutOffOrValveOperationRequired__c;
        this.estimatedproperties = this.dcfinfrarecorddata.FSM_EstimatedNoOfPropertiesAffected__c;
        this.altsupplies = this.dcfinfrarecorddata.FSM_AlternativeSuppliesRequired__c;
        this.sensitivecustonshuttdown = this.dcfinfrarecorddata.FSM_SensitiveCustomersOnShutdown__c;
        this.thirdpartydmge = this.dcfinfrarecorddata.FSM_ThirdPartyDamageOccurOnThisSite__c;
        this.commmethod = this.dcfinfrarecorddata.FSM_CommsMethod__c;
        this.libext = this.dcfinfrarecorddata.FSM_LibraryTimeExtensions__c;
        this.planninginfo = this.dcfinfrarecorddata.FSM_PlanningInfoAndComms__c;
        this.surfacetype = this.dcfinfrarecorddata.FSM_SurfaceType__c;
        this.estXloc = this.dcfinfrarecorddata.FSM_ESTLocationX__c;
        this.estYloc = this.dcfinfrarecorddata.FSM_ESTLocationY__c;
        this.leakloc = this.dcfinfrarecorddata.FSM_LeakLocation__c;
        this.visibleleak = this.dcfinfrarecorddata.FSM_VisibleLeak__c;
        this.leakquantified = this.dcfinfrarecorddata.FSM_HasLeakBeenQuantified__c;
        this.aquapeaused = this.dcfinfrarecorddata.FSM_AquaPeaUsed__c;
        this.postaquapea = this.dcfinfrarecorddata.FSM_PostAquaPea__c;
        this.valvefitted = this.dcfinfrarecorddata.FSM_FlowValveFitted__c;
        this.postflowvalve = this.dcfinfrarecorddata.FSM_PostFlowValve__c;
        this.gassing = this.dcfinfrarecorddata.FSM_Gassing__c;
        this.pipeMic = this.dcfinfrarecorddata.FSM_PipeMIC__c;
        this.issharedsupply = this.dcfinfrarecorddata.FSM_IsThisASharedSupply__c;
        this.residentstatus = this.dcfinfrarecorddata.FSM_ResidentialStatus__c;
        if (this.issharedsupply == 'Yes') {
            this.sharedsupplyyes = true;
        } else {
            this.sharedsupplyyes = false;
        }
    }
    @track assetRecords = [];
    @track taskRecords = [];
    @track techniqueRecords = [];
    @track sizeRecords = [];
    @track materialRecords = [];
    //collect all picklist options for asset ,task,technique,matierial,size from FSM_DCFDependantPicklist__c
    @wire(getAssetList)
    wiredAssetList({ data, error }) {
        if (data) {
            this.assetRecords = data.assetList;
            this.taskRecords = data.taskList;
            this.techniqueRecords = data.techniqueList;
            this.sizeRecords = data.sizeList;
            this.materialRecords = data.materialList;
        } else if (error) {
            console.error('Error asset ', error);
        }
    }
    selectedasset;
    seltask;
    selectedtechnique;
    selmaterial;
    selsize;
    @track filteredTask = [];
    @track filteredTechnique = [];
    @track filteredSize = [];
    @track filteredMaterial = [];
    handleAssetChange(event) {
        this.filteredTechnique = [];
        this.filteredSize = [];
        this.filteredMaterial = [];
        if (event) {
            this.selectedasset = event.detail.value;
        }
        if (this.allRecords) {
            let dataObj = JSON.parse(this.allRecords);
            let dupTaskCheck = [];
            let filteredTaskOps = [];
            dataObj.forEach(record => {
                if (this.selectedasset === record.FSM_Asset__c && !dupTaskCheck.includes(record.FSM_Task__c)) {
                    let exists = this.taskRecords.find(obj => obj.value === record.FSM_Task__c);
                    filteredTaskOps.push(exists);
                    dupTaskCheck.push(record.FSM_Task__c);
                }
            });
            this.filteredTask = filteredTaskOps;
        }

    }
    handleTaskChange(event) {
        this.filteredSize = [];
        this.filteredMaterial = [];
        if (event) {
            this.seltask = event.detail.value;
        }
        if (this.allRecords) {
            let dataObj = JSON.parse(this.allRecords);
            let dupTechniqueCheck = [];
            let filteredTechniqueOps = [];
            dataObj.forEach(record => {
                if (this.selectedasset === record.FSM_Asset__c && this.seltask === record.FSM_Task__c && !dupTechniqueCheck.includes(record.FSM_Technique__c)) {
                    let exists = this.techniqueRecords.find(obj => obj.value === record.FSM_Technique__c);
                    filteredTechniqueOps.push(exists);
                    dupTechniqueCheck.push(record.FSM_Technique__c);
                }
            });
            this.filteredTechnique = filteredTechniqueOps;
        }
    }
    handleTechniqueChange(event) {
        this.filteredMaterial = [];
        if(this.isEdit ===false || this.isEdit === undefined ||this.isEdit === null ){
            console.log('inside if 2414 ',this.isEdit);
            this.selsize = '';
        }
       
        if (event) {
            this.selectedtechnique = event.detail.value;
        }
        if (this.allRecords) {
            let dataObj = JSON.parse(this.allRecords);
            let dupSizeCheck = [];
            let filteredSizeOps = [];
            dataObj.forEach(record => {
                if (this.selectedasset === record.FSM_Asset__c && this.seltask === record.FSM_Task__c && this.selectedtechnique === record.FSM_Technique__c && !dupSizeCheck.includes(record.FSM_Size__c)) {
                    let exists = this.sizeRecords.find(obj => obj.value === record.FSM_Size__c);
                    filteredSizeOps.push(exists);
                    dupSizeCheck.push(record.FSM_Size__c);
                }
            });
            this.filteredSize = filteredSizeOps;
        
        }
    }

    handleSizeChange(event) {
        if (event) {
            this.selsize = event.detail.value;
        }
        if (this.allRecords) {
            let dataObj = JSON.parse(this.allRecords);
            let dupMaterialCheck = [];
            let filteredMaterialOps = [];
            dataObj.forEach(record => {
                if (this.selectedasset === record.FSM_Asset__c && this.seltask === record.FSM_Task__c && this.selectedtechnique === record.FSM_Technique__c && this.selsize === record.FSM_Size__c && !dupMaterialCheck.includes(record.FSM_Material__c)) {
                    let exists = this.materialRecords.find(obj => obj.value === record.FSM_Material__c);
                    filteredMaterialOps.push(exists);
                    dupMaterialCheck.push(record.FSM_Material__c);
                }
            });
            this.filteredMaterial = filteredMaterialOps;
        }
    }
    handleMaterialChange(event) {
        this.selmaterial = event.detail.value;

    }
    handlegridxchange(event) {
        this.gridproposedworkx = event.detail.value;
    }
    handlegridychange(event) {
        this.gridproposedworky = event.detail.value;
    }
    handleoccunamechange(event) {
        this.occname = event.detail.value;
    }
    handleocctelnochange(event) {
        this.occtelno = event.detail.value;

    }


    handlehsenamechange(event) {
        this.occhsename = event.detail.value;
    }
    handlehsenochange(event) {
        this.occhseno = event.detail.value;
    }
    handleoccstreetchange(event) {
        this.occstreet = event.detail.value;
    }
    handlecitychange(event) {
        this.occcity = event.detail.value;
    }
    handlepostcodechange(event) {
        this.occpostcode = event.detail.value;
    }

    handleproformasignedchange(event) {
        this.proformasigned = event.detail.value;
    }
    handleAssetUidChange(event) {
        this.assetuuid = event.detail.value;
    }
    handleocctownchange(event) {
        this.occstown = event.detail.value;
    }
    handleestlocchange(event) {
        this.estloc = event.detail.value;
    }
    handleleakquantchange(event) {
        this.leakquant = event.detail.value;
    }
    handlechangemeterserial(event) {
        this.meterserial = event.detail.value;
    }
    handlechangemetereading(event) {
        this.meterreading = event.detail.value;
    }
    handleoverheadpowerlineChange(event) {
        this.powerlines = event.detail.value;
    }
    handlesunchange(event) {
        this.sun = event.target.checked;
        this.issunchecked = this.sun;
    }
    handlesatchange(event) {
        this.sat = event.target.checked;
        this.issatchecked = this.sat;
    }
    handlefrichange(event) {
        this.fri = event.target.checked;
        this.isfrichecked = this.fri;
    }
    handlethurschange(event) {
        this.thurs = event.target.checked;
        this.isthurschecked = this.thurs;
    }
    handlewedchange(event) {
        this.wed = event.target.checked;
        this.iswedchecked = this.wed;
    }
    handletueschange(event) {
        this.tues = event.target.checked;
        this.istuechecked = this.tues;
    }
    handlemondaychange(event) {
        this.mon = event.target.checked;
        this.ismonchecked = this.mon;
    }
    handleeisexcavationreqChange(event) {
        this.excavation = event.detail.value;
    }
    handletypeofleakChange(event) {
        this.leaktype = event.detail.value;
    }
    handlereinstatementChange(event) {
        this.reason = event.detail.value;
    }
    handletrailerChange(event) {
        this.trailer = event.detail.value;
    }
    handleletterChange(event) {
        this.letterwarn = event.detail.value;
    }
    handlecustomerChange(event) {
        this.sensitivecustomer = event.detail.value;
    }
    handlelsitecommchange(event) {
        this.sitecomm = event.detail.value;
    }
    handleoverpowerlineChange(event) {
        this.overheadpowerlines = event.detail.value;
    }
    handlelampsupportclsChange(event) {
        this.lampsupport = event.detail.value;
    }
    handleconfinedspaceChange(event) {
        this.confinedspace = event.detail.value;
    }

    handlecontaminationcommchange(event) {
        this.contaminationcomm = event.detail.value;
    }

    handlepollutioncommchange(event) {
        this.pollutioncomm = event.detail.value;
    }
    handleriskofpollutionchange(event) {
        this.risk = event.detail.value;
    }
    handlechangerisktoenv(event) {
        this.riskenv = event.detail.value;
    }
    handlechangenumofproperties(event) {
        this.estimatedproperties = event.detail.value;
    }
    handlechangealtsupplies(event) {
        this.altsupplies = event.detail.value;
    }
    handlechangecustomeronshutdown(event) {
        this.sensitivecustonshuttdown = event.detail.value;
    }
    handlechangethirdparty(event) {
        this.thirdpartydmge = event.detail.value;

    }
    handleplanninginfochange(event) {
        this.planninginfo = event.detail.value;
    }
    handlechangelibext(event) {
        this.libext = event.detail.value;
    }
    handleAmchange(event) {
        this.amval = event.target.checked;
        this.isamchecked = this.amval;
    }
    handlePmchange(event) {
        this.pmval = event.target.checked;
        this.ispmchecked = this.pmval;
    }
    handleNightchange(event) {
        this.nightval = event.target.checked;
        this.isnightchecked = this.nightval;
    }
    handlesurfacetypechange(event) {
        this.surfacetype = event.detail.value;
    }
    handleestXlocchange(event) {
        this.estXloc = event.detail.value;
    }
    handleestYlocchange(event) {
        this.estYloc = event.detail.value;
    }
    handleLeaklocChange(event) {
        this.leakloc = event.detail.value;
    }
    handlevisibleleakChange(event) {
        this.visibleleak = event.detail.value;
    }
    handleLeakquantifiedChange(event) {
        this.leakquantified = event.detail.value;
        if (this.leakquantified == 'Check meter' || this.leakquantified == 'Estimated' || this.leakquantified == 'N/A') {
            this.meterserial = 'NA';
            this.meterreading = 0;
        } else {
            this.meterserial = '';
            this.meterreading = '';
        }
    }
    handleChangeaquapeaused(event) {
        this.aquapeaused = event.detail.value;
    }
    handleChangePostaquapea(event) {
        this.postaquapea = event.detail.value;
    }
    handleChangeValvefitted(event) {
        this.valvefitted = event.detail.value;
    }
    handleChangePostflowvalve(event) {
        this.postflowvalve = event.detail.value;
    }
    handleChangegassing(event) {
        this.gassing = event.detail.value;
    }
    handleChangepipeMic(event) {
        this.pipeMic = event.detail.value;
    }
    handleChangeSharedSupply(event) {
        this.issharedsupply = event.detail.value;
        if (this.issharedsupply == 'Yes') {
            this.sharedsupplyyes = true;
        } else {
            this.sharedsupplyyes = false;
        }
    }
    //upload proforma photos functions
    handleProformaPhotoSelect(event) {
        const fileCount = event.target.files.length + this.proformaImageData.length;
        this.proformaimg = false;
        //this.proformaImageData = [];
        this.selectedProformaPhotos(event);

    }
    // commented by brajesh due addition of compression logic
    // async selectedProformaPhotos(event) {
    //     const dfiles = event.target.files;
    //     const numFiles = dfiles.length;
    //     for (let i = 0; i < numFiles; i++) {
    //         let dfile = dfiles[i];
    //         let data = await this.readFile(dfile);
    //         let metadata = await this.readMetadata(dfile);
    //         this.proformaImageData.push({
    //             id: this.nextId++,
    //             data: data,
    //             metadata: metadata,
    //             className: ''
    //         });
    //     }
    //     if (this.proformaImageData) {
    //         this.proformaimg = true;
    //     }
    //     //pass the image details to parent component
    //     this.dispatchEvent(
    //         new CustomEvent("proformaphotocapture", {
    //             detail: this.proformaImageData
    //         })
    //     );

    // }


    async selectedProformaPhotos(event) {
        const maxFileSize = 6 * 1024 * 1024; // 6MB in bytes
        const validFiles = [];
        let removedFiles = [];
        const dfiles = event.target.files;
        const numFiles = dfiles.length;

        for (let i = 0; i < numFiles; i++) {
            let dfile = dfiles[i];
            const compressedBlob = await this.compressImage(dfile);
            if (compressedBlob.size <= maxFileSize) {
                validFiles.push(dfile); // Keep files <= 6MB
                const data = await this.blobToDataURL(compressedBlob);
                let metadata = await this.readFileMetadata(dfile);
                this.proformaImageData.push({
                    id: this.nextId++,
                    data: data,
                    metadata: metadata,
                    className: ''
                });
            } else {
                removedFiles.push(dfile); // Track files that are too large
            }

        }
        // Notify the user about removed files
        if (removedFiles.length > 0) {
            this.showToast(
                'Files Too Large',
                `Exceed the 6MB size limit and were removed.`,
                'error'
            );
        }
        // 

        if (this.proformaImageData) {
            this.proformaimg = true;
        }
        //pass the image details to parent component
        if (validFiles.length > 0) {
            this.dispatchEvent(
                new CustomEvent("proformaphotocapture", {
                    detail: this.proformaImageData
                })
            );
        }

    }

    compressImage(file) {
        return new Promise((resolve, reject) => {
            const img = new Image();
            const reader = new FileReader();

            reader.onload = () => {
                img.onload = () => {
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');
                    const MAX_WIDTH = 800; // Max width for compression
                    const MAX_HEIGHT = 800; // Max height for compression

                    let width = img.width;
                    let height = img.height;

                    // Scale image to fit within the max width and height
                    if (width > height) {
                        if (width > MAX_WIDTH) {
                            height *= MAX_WIDTH / width;
                            width = MAX_WIDTH;
                        }
                    } else {
                        if (height > MAX_HEIGHT) {
                            width *= MAX_HEIGHT / height;
                            height = MAX_HEIGHT;
                        }
                    }

                    canvas.width = width;
                    canvas.height = height;

                    ctx.drawImage(img, 0, 0, width, height);

                    canvas.toBlob((blob) => {
                        const compressedFile = new File([blob], file.name, {
                            type: file.type,
                            lastModified: file.lastModified
                        });
                        resolve(compressedFile);
                    }, file.type, 0.6); // Adjust compression quality (0.7 is 70%)
                };
                img.src = reader.result;
            };

            reader.readAsDataURL(file);
        });
    }

    async readFileMetadata(file) {
        const fullFileName = file.name;
        const ext = fullFileName.slice(
            (Math.max(0, fullFileName.lastIndexOf(".")) || Infinity) + 1
        );
        return {
            name: file.name,
            size: file.size,
            type: file.type,
            ext: ext,
            edited: false
        };
    }

    // Convert Blob to Base64 data URL
    blobToDataURL(blob) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result); // Base64 data URL
            reader.onerror = reject;
            reader.readAsDataURL(blob);
        });
    }

    readFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = (ev) => {
                resolve(ev.target.result);
            };
            reader.onerror = () => {
                reject(
                    `There was an error reading file: '${file.name}', error: ${reader.error}`
                );
            };

            try {
                reader.readAsDataURL(file);
            } catch (err) {
                reject(new Error("Unable to read the input data."));
            }
        });
    }
    //reads the file name and extension
    readMetadata(file) {
        return new Promise((resolve) => {

            const fullFileName = file.name;
            const ext = fullFileName.slice(
                (Math.max(0, fullFileName.lastIndexOf(".")) || Infinity) + 1
            );
            const fileNameWithoutExt = fullFileName.substring(
                0,
                fullFileName.length - ext.length - (ext ? 1 : 0)
            );

            const metadata = {
                fileName: fileNameWithoutExt,
                ext: ext,
                edited: false
            };

            resolve(metadata);
        });
    }
    // Toggle the 'selected' property when an image is clicked
    handleImageClick(event) {
        const fileIdToSelect = event.currentTarget.dataset.id;
        for (let i = 0; i < this.proformaImageData.length; i++) {
            const imgD = this.proformaImageData[i].id;

            if (imgD == fileIdToSelect) {
                this.proformaImageData[i].className = 'selected';
            } else {
                this.proformaImageData[i].className = '';
            }
        }
    }

    handleDeleteClick(event) {
        const fileIdToDelete = event.currentTarget.dataset.id;
        const newImgSet = [];
        for (let i = 0; i < this.proformaImageData.length; i++) {
            const imgD = this.proformaImageData[i].id;

            if (imgD != fileIdToDelete) {
                newImgSet.push(this.proformaImageData[i]);
            }
        }
        this.proformaImageData = newImgSet;
    }
    async createDCFrecord() {
        console.log('Hi')
        this.isDone = false;
        this.dcfrecdata.FSM_GridRefOfProposedWorkX__c = this.gridproposedworkx;
        this.dcfrecdata.FSM_GridRefOfProposedWorkY__c = this.gridproposedworky;
        this.dcfrecdata.FSM_SFWIsThisAtADifferentAddress__c = this.isdiffaddrr;
        this.dcfrecdata.FSM_OccupiersName__c = this.occname;
        this.dcfrecdata.FSM_OccupiersTelephoneNumber__c = this.occtelno;
        this.dcfrecdata.FSM_OccupiersHouseName__c = this.occhsename;
        this.dcfrecdata.FSM_OccupiersHouseNo__c = this.occhseno;
        this.dcfrecdata.FSM_OccupiersStreet__c = this.occstreet;
        this.dcfrecdata.FSM_OccupiersTown__c = this.occstown;
        this.dcfrecdata.FSM_OccupiersCity__c = this.occcity;
        this.dcfrecdata.FSM_OccupiersPostcode__c = this.occpostcode;
        this.dcfrecdata.FSM_Location__c = this.occlocation;
        this.dcfrecdata.FSM_PermissionToDigRequired__c = this.permissiontodigreq;
        this.dcfrecdata.FSM_WhichProformaSigned__c = this.proformasigned;
        this.dcfrecdata.FSM_PermissionToDig__c = this.permissiondig;
        this.dcfrecdata.FSM_AssetUID__c = this.assetuuid;
        this.dcfrecdata.FSM_Asset__c = this.selectedasset;
        this.dcfrecdata.FSM_Task__c = this.seltask;
        this.dcfrecdata.FSM_Technique__c = this.selectedtechnique;
        this.dcfrecdata.FSM_AssetSize__c = this.selsize;
        this.dcfrecdata.FSM_AssetMaterial__c = this.selmaterial;
        this.dcfrecdata.FSM_DetailsOfProposedWork__c = 'Gassing';
        this.dcfrecdata.FSM_TaskType__c = 'D';
        this.dcfrecdata.FSM_FormType__c = "Infra Follow On Work Request";
        this.dcfrecdata.RecordTypeId = this.dcfrectypid;
        const dataToInsert = JSON.parse(JSON.stringify(this.dcfrecdata));
        const fields = dataToInsert;
        if (this.isEdit == true) {
            const recordInput = { fields }
            await updateRecord(recordInput).then(() => {
                this.updateworkstepfield(this.recordId);
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });

        } else {
            //update records
            const recordInput = { apiName: DCFINFRA_OBJECT.objectApiName, fields };
            this.infraRecid = await createRecord(recordInput);
            this.updateworkstepfield(this.infraRecid.id);
        }
    }
    //update status and workstep of dcf infra records
    async updateworkstepfield(dcfrecid) {
        const fields = {};
        fields['Id'] = dcfrecid; //populate it with current record Id
        fields['FSM_WorkStep__c'] = this.recordId;
        fields['FSM_Status__c'] = 'Completed';
        //populate any fields which you want to update like this
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            if (JSON.stringify(this.proformaImageData) != '[]' || this.proformaImageData != []) {
                this.createcontentversion(dcfrecid)
            } else {
                this.updateworkstepcomplete();
            }
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record with proforma',
                    message: error.body,
                    variant: 'error'
                })
            );
        });
        this.isDone = true;
        this.sectionfour = false;
        this.isCompleted = true;
    }

    createcontentversion(dcfinraid) {

        this.proformaImageData.forEach((element, index) => {
            const proformaphotostoinsert = JSON.stringify(element.data);
            const filecontentdata = proformaphotostoinsert.split(',')[1];
            const removeLast3 = filecontentdata.slice(0, -1);
            //const metadata=element.metadata.fileName;
            const fileext = element.metadata.ext;
            this.filesData.push({ 'fileName': 'Proforma ' + index + '.' + fileext, 'fileContent': removeLast3 });
        });
        let allcvtoinsert = [];
        for (var i = 0; i < this.filesData.length; i++) {
           
                    const fileData = {
                    Title: this.filesData[i].fileName,
                    PathOnClient: this.filesData[i].fileName,
                    VersionData: this.filesData[i].fileContent,
                    FSM_RelatedrecordId__c: dcfinraid,
                    FSM_Sketch_Additional_Images__c: true,
                    FSM_Do_not_send_to_SAP__c:true
                    }  
            allcvtoinsert.push(fileData);
        }

        this.cvinsert(allcvtoinsert, dcfinraid);
    }
    //insert content version
    cvinsert(cvarr, dcfrecordid) {
        let promises = [];
        cvarr.forEach(version => {
            let recordInput = { apiName: 'ContentVersion', fields: version };
            promises.push(createRecord(recordInput));
        });
        Promise.all(promises)
            .then(results => {
                // Handle successful insertion
                this.updateworkstepcomplete();
                this.filesData = [];
                // Optionally, reset form or perform other actions
            })
            .catch(error => {
                // Handle error
                console.error('Error inserting content versions:', error);
            });
    }
    //added as part of sfs-6880
    updateworkstepcomplete() {
        const fields = {};
        fields['Id'] = this.recordId; //populate it with current record Id
        //console.log('what is this record id ==='+this.recordId);
        fields['Status'] = 'Completed';
        fields['FSM_IsCompleted__c'] = true;
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            this.isDone = true;
            this.sectionfour = false;
            this.isCompleted = true;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating workstep status',
                    message: error.body,
                    variant: 'error'
                })
            );
        });
    }
}
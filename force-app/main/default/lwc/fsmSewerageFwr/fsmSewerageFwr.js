/****************************************************************************************
    - Description  : Created for DCF Sewerage Further Work Request , SFS-3010
    - Created Date : 11th Dec 2023
    - Modified By  : Brajesh
****************************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getAllSWRRecords from '@salesforce/apex/FSM_DependantPicklistcls.getAllSWRRecords';
import getSWRTaskList from '@salesforce/apex/FSM_DependantPicklistcls.getSWRTaskList';
import LOCATION from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_Location__c';
import PERMISSIONTODIG from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_PermissionToDig__c';
import REQUESTEDEQUIPMENT from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_SFWRequestedEquipment__c';
import PRIORITY from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_SFWPriority__c';
import ACTIVITYTYPE from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_INFRAFWRActivityType__c';
import SURFACETYPE from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_SurfaceType__c';
import PEDESTRIANWALKWAY from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRPedestrianWalkway__c';
import ROADTYPE from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRRoadType__c';
import PEDESTRIANLIGHTS from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRPedestrianLights__c';
import VISBILITYMENATWORK from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRVisibilityToMenAtWork__c';
import TRAINORTRAM from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRTrainOrTram__c';
import BUS from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRBus__c';
import CYCLE from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRCycle__c';
import SPECIALFEATURE from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRSpecialFeature__c';
import COMMSMETHOD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRCommsMethod__c';
import COMMSTYPE from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRCommsType__c';
import METHODOFWORK from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FWRMethodOfWork__c'; //SFS-6005
import ROADSPEED from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_Speed__c';
import TRAFFICSENSITIVE from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_IsTheLocationTrafficSensitive__c';
import JOBURGENT from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_IsTheJobUrgent__c';
import WAITINGCONES from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_AreNoWaitingConesRequired__c';
import FOOTWATCLOSURE from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_FootwayClosure__c';
import CARRIAGEWAYRESTRICION from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_CarriagewayRestriction__c';
import GRID_X from "@salesforce/schema/WorkStep.WorkOrder.FSM_Easting__c"; //SFL-1053
import GRID_Y from "@salesforce/schema/WorkStep.WorkOrder.FSM_Northing__c"; //SFL-1053
import STREET from "@salesforce/schema/WorkStep.WorkOrder.Street";
import CITY from "@salesforce/schema/WorkStep.WorkOrder.City";
import POST_CODE from "@salesforce/schema/WorkStep.WorkOrder.PostalCode";

const fieldname = ["WorkStep.FSM_ContactPhoneNumber__c"];


// Fields that need to be retrieved from the FSM_InfraDataCaptureForm2__c object
const FIELDS = [
    // screen 1
    "FSM_InfraDataCaptureForm2__c.FSM_Status__c",
    "FSM_InfraDataCaptureForm2__c.FSM_WorkStep__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OccupiersName__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OccupiersHouseName__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OccupiersHouseNo__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OccupiersStreet__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OccupiersTown__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OccupiersCity__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OccupiersPostcode__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OccupiersTelephoneNumber__c",
    // screen2
    "FSM_InfraDataCaptureForm2__c.FSM_SFWXcoordinate__c",
    "FSM_InfraDataCaptureForm2__c.FSM_SFWYcoordinate__c",
    "FSM_InfraDataCaptureForm2__c.FSM_SFWUIDOfProposedWork__c",
    "FSM_InfraDataCaptureForm2__c.FSM_SFWIsThisAtADifferentAddress__c",
    "FSM_InfraDataCaptureForm2__c.FSM_SFWUpdateAddressOnOrder__c",
    //screen3
    "FSM_InfraDataCaptureForm2__c.FSM_OwnersName__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OwnersHouseName__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OwnersHouseNo__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OwnersStreet__c",
    "FSM_InfraDataCaptureForm2__c.FSM_OwnersTown__c",
    'FSM_InfraDataCaptureForm2__c.FSM_OwnersCity__c',
    'FSM_InfraDataCaptureForm2__c.FSM_OwnersPostcode__c',
    'FSM_InfraDataCaptureForm2__c.FSM_OwnersTelephoneNumber__c',
    //screen4
    'FSM_InfraDataCaptureForm2__c.FSM_Location__c',
    //screen5
    'FSM_InfraDataCaptureForm2__c.FSM_PermissionToDig__c',
    //screen6
    'FSM_InfraDataCaptureForm2__c.FSM_SWRAsset__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SWRTask__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SWRJobRecipient__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SWRJobScope__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SWRTransferredAsset__c',
    //screen8
    'FSM_InfraDataCaptureForm2__c.FSM_SFWRequestedEquipment__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWManholeRef__c',
    'FSM_InfraDataCaptureForm2__c.FSM_RepairLength__c',
    'FSM_InfraDataCaptureForm2__c.FSM_RepairDepth__c',
    'FSM_InfraDataCaptureForm2__c.FSM_DetailsOfProposedWork__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWPriority__c',
    //screen9
    'FSM_InfraDataCaptureForm2__c.FSM_Monday__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Tuesday__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Wednesday__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Thursday__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Friday__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Saturday__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Sunday__c',
    'FSM_InfraDataCaptureForm2__c.FSM_AM__c',
    'FSM_InfraDataCaptureForm2__c.FSM_PM__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Night__c',
    //screen10
    'FSM_InfraDataCaptureForm2__c.FSM_JobTracedAndMarked__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWManholesSewersAccessible__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWAnyHandDig__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWOverpumpingRequired__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWOPIfYesDetails__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWTankerSupportRequired__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWTSIfYesDetails__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWOtherSupportOperations__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SFWSOIfYesDetails__c',
    // screen11
    'FSM_InfraDataCaptureForm2__c.FSM_INFRAFWRActivityType__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SurfaceType__c',
    // screen12
    'FSM_InfraDataCaptureForm2__c.FSM_FWRMethodOfWork__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Carriageway__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Verge__c',
    'FSM_InfraDataCaptureForm2__c.FSM_BridlewayFootpath__c',
    'FSM_InfraDataCaptureForm2__c.FSM_PrivateLand__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Footway__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Cycleway__c',
    'FSM_InfraDataCaptureForm2__c.FSM_PedestrianZone__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRPedestrianWalkway__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRRoadType__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRPedestrianLights__c',
    'FSM_InfraDataCaptureForm2__c.FSM_Speed__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRVisibilityToMenAtWork__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRFootwayWidth__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRCarriagewayWidth__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRTrafficFlow__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SpecialistTreatment__c',
    'FSM_InfraDataCaptureForm2__c.FSM_SpecialistTreatmentComments__c',
    'FSM_InfraDataCaptureForm2__c.FSM_RoadMarkings__c',
    'FSM_InfraDataCaptureForm2__c.FSM_RoadMarkingsComments__c',
    'FSM_InfraDataCaptureForm2__c.FSM_TrafficLightsLessThan50m__c',
    'FSM_InfraDataCaptureForm2__c.FSM_TrafficLightRestriction__c',
    'FSM_InfraDataCaptureForm2__c.FSM_IsTheLocationTrafficSensitive__c',
    // screen13
    'FSM_InfraDataCaptureForm2__c.FSM_IsTheJobUrgent__c',
    'FSM_InfraDataCaptureForm2__c.FSM_AreNoWaitingConesRequired__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FootwayClosure__c',
    'FSM_InfraDataCaptureForm2__c.FSM_ParkingSuspension__c',
    'FSM_InfraDataCaptureForm2__c.FSM_CarriagewayRestriction__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRTrainOrTram__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRBus__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRCycle__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRSpecialFeature__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRCommsMethod__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRCommsType__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRSiteComments__c',
    'FSM_InfraDataCaptureForm2__c.FSM_FWRPlanningInformation__c',
    // screen14
    'FSM_InfraDataCaptureForm2__c.FSM_SFWPotentialEnvironmentalImpact__c',
    'FSM_InfraDataCaptureForm2__c.FSM_EnvImpactComments__c',
    'FSM_InfraDataCaptureForm2__c.FSM_RiskToAnEnvironmentalSite__c',
    // screen15
    'FSM_InfraDataCaptureForm2__c.FSM_OverheadPowerLinesWithin10m__c',
    'FSM_InfraDataCaptureForm2__c.FSM_LampSupportRemovalRequired__c',
    'FSM_InfraDataCaptureForm2__c.FSM_ConfinedSpaceWorking__c',
    'FSM_InfraDataCaptureForm2__c.FSM_DetailsSafetyInformation__c',
];


export default class FsmSewerageFwr extends LightningElement {
    @api recordId;
    @api woid;
    @api recid;
    @api objname;
    //
    isDone = false;
    hasRendered = false;
    dcfinfrarecorddata;

    //----Active Screens and its Validation----
    @track Screen1 = true;
    @track Screen2 = false;
    @track Screen3 = false;
    @track Screen4 = false;
    @track Screen5 = false;
    @track Screen6 = false;
    @track Screen8 = false;
    @track Screen9 = false;
    @track Screen10 = false;
    @track Screen11 = false;
    @track Screen12 = false;
    @track Screen13 = false;
    @track Screen14 = false;
    @track Screen15 = false;
    //------Check Screen Validations-------
    isValidScreen1 = true;
    isValidScreen2 = true;
    isValidScreen3 = true;
    isValidScreen4 = true;
    isValidScreen5 = true;
    isValidScreen6 = true;
    isValidScreen8 = true;
    isValidScreen10 = true;
    isValidScreen11 = true;
    isValidScree12 = true;
    isValidScreen13 = true;
    isValidScreen14 = true;
    isValidScreen15 = true;
    //-------------------------------------
    @api objectname;
    @api objectApiName;
    errormessages = [];//To Display Error Message
    isValidScreenOne = true; // To Check Validity of Screen 1
    submitValues = {};//To store data for creating DCF record
    Options = [{ label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }];
    ValuesCheck = { 'overheadPowerlines': false, 'tankerSupportRequired': false, 'overPumpingRequired': false, 'otherSupportOperations': false, 'specialistTreatment': false, 'roadMarking': false, 'envImpact': false }//Screen Conditions check
    //----Screen 1 Values-----
    occupiersName;
    occupiersHouseName;
    occupiersHouseNo;
    occupiersStreet;
    occupiersTown;
    occupiersCity;
    occupiersPostalCode;
    occupiersTelephone;
    //----Screen 2 Values-----
    xCoordinate;
    yCoordinate;
    uidProposedWork;
    FWDifferentAddress = false;
    orderAddressUpdate = false;
    //----Screen 3 Values-----
    ownersName;
    ownersHouseName;
    ownersHouseNo;
    ownersStreet;
    ownersTown;
    ownersCity;
    ownersPostalCode;
    ownersTelephone;
    //----Screen 4 Values-----
    Location = [];
    selectedLocation;
    selectedPermissionToDig;
    //----Screen 5 Values-----
    permissionToDig = [];
    selectedPermissionToDig;
    //----Screen 6 Values-----
    allRecords;
    taskRecords = [];
    assetRecords = [];
    jobScopeRecords = [];
    trAssetRecords = [];
    jobRecepientRecords = [];
    selectedTask;
    selectedAsset;
    selectedJobScope;
    selectedTrAsset;
    selectedJobRecepient;
    filteredAsset = [];
    filteredJobScope = [];
    filteredTransferredAsset = [];
    filteredJobRecepient = [];
    //----Screen 7 Values-----

    //----Screen 8 Values-----
    reqEquipment = [];
    selectedReqEquipment;
    manholeRef;
    repairLength;
    repairDepth;
    proposedWrkDetails;
    priority = [];
    selectedPriority;
    //----Screen 9 Values-----
    Monday = false;
    Tuesday = false;
    Wednesday = false;
    Thursday = false;
    Friday = false;
    Saturday = false;
    Sunday = false;
    RestrictedTimeAM = false;
    RestrictedTimePM = false;
    RestrictedTimeNight = false;
    //----Screen 10 Values-----
    isJobTracedMarked;
    manholesSewersAccessible;
    anyHandDig;
    overPumpingRequired;
    overPumpingComments;
    tankerSupportRequired;
    tankerSupportComments;
    otherSupportOperations;
    otherSupportComments;
    //----Screen 11 Values-----
    activityType = [];
    selectedActivity;
    surfaceType = [];
    selectedSurfaceType;
    PedestrianWalkway = []; //SFS-6005 
    selectedPedestrianWalkway; //SFS-6005 
    RoadType = [];
    selectedRoadType;
    PedestrianLights = [];
    selectedPedestrianLights;
    VisibilityMenWork = [];
    selectedVisibilityMenWork;
    VisibilityMenWork = [];
    selectedVisibilityMenWork;
    selectedFootwayWidth;
    selectedCarriagewayWidth;
    selectedTrafficFlow;
    specialistTreatment;
    specialistTreatmentComments;

    //----Screen 12 Values-----
    MethodOfWork = []; //SFS-6005
    selectedMethodOfWork; //SFS-6005

    Carriageway = false;
    Verge = false;
    BridlewayFootpath = false;
    PrivateLand = false;
    Footway = false;
    Cycleway = false;
    PedestrianisedZone = false;

    speed = [];
    selectedSpeed;
    trafficSensitive = [];
    trafficLightRestriction;
    selectedTrafficSensitive;
    specialistTreatment;
    specialistTreatmentComments;
    roadMarking;
    roadMarkingComments;
    trafficLights50mm;
    carriageway = false;//Condition dependency check
    //----Screen 13 Values-----
    jobUrgent = [];
    selectedJobUrgent;
    waitingCones = [];
    selectedWaitingCones;
    footwayClosure = [];
    selectedFootwayClosure;
    parkingSuspension;
    carriagewayRestriction = [];
    selCarriagewayRestriction;
    trainOrTram = [];
    selectedTrainOrTram;
    Bus = [];
    selectedBus;
    Cycle = [];
    selectedCycle;
    SpecialFeature = [];
    selectedSpecialFeature;
    CommsMethod = [];
    selectedCommsMethod;
    CommsType = [];
    commTypeValue;
    selectedCommsType;
    selectedSiteComments;
    selectedPlanningInfo;


    //----Screen 14 Values-----
    envImpact;
    envImpactComments;
    evnImpSite;
    //----Screen 15 Values-----
    overheadPowerlines;
    @track isOverheadPowerlines = false;
    lampSupport;
    confinedSpace;
    additionalSafetyInfo;
    // isEdit Form Variables 
    @track dcf2RecordStatus;
    @track isEditOnProgress = false;
    @track isFirstTimeCalled = true;
    isEdit
    dcfRec;
    workstepId;
    dcfData;
    //------------------------------------
    @api isprevfromnextcmp;
    //  added as part of SFL-588
    @wire(getRecord, { recordId: '$recid', fields: fieldname })
    record({ error, data }) {
        if (error) {
            console.error('No address preset on workorder ', error);

        } else if (data) {
            this.ownersTelephone = this.occupiersTelephone = data.fields.FSM_ContactPhoneNumber__c.value;
        }
    }
    //Method to add work order values to pre-populate in form// SFL-1053
    @wire(getRecord, { recordId: '$recid', fields: [GRID_X,GRID_Y,STREET,CITY,POST_CODE]})
        WO_values({ error, data }){
            if(data){
                console.log(data)
                this.xCoordinate = getFieldValue(data, GRID_X)
                this.yCoordinate = getFieldValue(data, GRID_Y)
                this.occupiersPostalCode = getFieldValue(data, POST_CODE)
                this.occupiersCity = getFieldValue(data, CITY)
                this.occupiersStreet = getFieldValue(data, STREET)
            }else if (error) {
                console.error('Error:', error); // Debugging log
            }
        }

    // Method to fetch Picklist values of Location
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: LOCATION
    }) locValues({ error, data }) {
        if (data) {
            this.Location = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    // Method to fetch Picklist values of permissionToDig
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: PERMISSIONTODIG
    }) ptdValues({ error, data }) {
        if (data) {
            this.permissionToDig = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }


    // Method to fetch Picklist values of requested Equipment
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: REQUESTEDEQUIPMENT
    }) reqEqValues({ error, data }) {
        if (data) {
            this.reqEquipment = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Method to fetch Picklist values of Priority
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: PRIORITY
    }) priorityValues({ error, data }) {
        if (data) {
            this.priority = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Method to fetch Picklist values of Activity Type
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: ACTIVITYTYPE
    }) activityValues({ error, data }) {
        if (data) {
            this.activityType = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Method to fetch Picklist values of Surface Type
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: SURFACETYPE
    }) surfaceValues({ error, data }) {
        if (data) {
            this.surfaceType = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    //SFS-6005
    // Method to fetch Picklist values of Pedestrian Walkway
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: PEDESTRIANWALKWAY
    }) pedestrianValues({ error, data }) {
        if (data) {
            this.PedestrianWalkway = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    //SFS-6005
    // Method to fetch Picklist values of Road Type
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: ROADTYPE
    }) roadTypeValues({ error, data }) {
        if (data) {
            this.RoadType = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    //SFS-6005
    // Method to fetch Picklist values of Pedestrian Lights
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: PEDESTRIANLIGHTS
    }) pedestrianLightsValues({ error, data }) {
        if (data) {
            this.PedestrianLights = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }


    //SFS-6005
    // Method to fetch Picklist values of Visibility Men at Work
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: VISBILITYMENATWORK
    }) visibilityMenWorkValues({ error, data }) {
        if (data) {
            this.VisibilityMenWork = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }



    //SFS-6005
    // Method to fetch Picklist values of FOOTWAY WIDTH (m)
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: TRAINORTRAM
    }) trainOrTramValues({ error, data }) {
        if (data) {
            this.trainOrTram = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }



    // Method to fetch Picklist values of BUS
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: BUS
    }) busValues({ error, data }) {
        if (data) {
            this.Bus = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    // Method to fetch Picklist values of Cycle
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: CYCLE
    }) cycleValues({ error, data }) {
        if (data) {
            this.Cycle = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    // Method to fetch Picklist values of Special Feature
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: SPECIALFEATURE
    }) specialFeatureValues({ error, data }) {
        if (data) {
            this.SpecialFeature = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });

        } else if (error) {
            console.error(error);
        }
    }

    // Method to fetch Picklist values of Special Feature
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: COMMSMETHOD
    }) commsMethodFeatureValues({ error, data }) {
        if (data) {
            this.CommsMethod = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    // Method to fetch Picklist values of Special Feature
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: COMMSTYPE
    }) commsTypeValues({ error, data }) {
        if (data) {
            this.CommsType = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }


    // SFS-6005 START REMOVE COMMENT
    // Method to fetch Picklist values of Surface Type
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: METHODOFWORK
    }) MethodOfWorkValues({ error, data }) {
        if (data) {
            this.MethodOfWork = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }


    // Method to fetch Picklist values of Road Speed
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: ROADSPEED
    }) speedValues({ error, data }) {
        if (data) {
            this.speed = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Method to fetch Picklist values of Traffic Sensitive
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: TRAFFICSENSITIVE
    }) trafficValues({ error, data }) {
        if (data) {
            this.trafficSensitive = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Method to fetch Picklist values of Job Urgent
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: JOBURGENT
    }) jobValues({ error, data }) {
        if (data) {
            this.jobUrgent = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Method to fetch Picklist values of Waiting Cones
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: WAITINGCONES
    }) conesValues({ error, data }) {
        if (data) {
            this.waitingCones = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Method to fetch Picklist values of Footway Closure
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: FOOTWATCLOSURE
    }) closureValues({ error, data }) {
        if (data) {
            this.footwayClosure = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Method to fetch Picklist values of Carriageway Restriction
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: CARRIAGEWAYRESTRICION
    }) restricValues({ error, data }) {
        if (data) {
            this.carriagewayRestriction = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    // retriving values when form is launch from DCF Record
    @wire(getRecord, { recordId: '$recid', fields: FIELDS })
    dcfRecords({ data, error }) {
        if (data && this.isFirstTimeCalled === true) {
            this.dcfData = data.fields;
            this.workstepId = this.dcfData.FSM_WorkStep__c.value;
            if (!!this.workstepId) {
                this.isEdit = true;
            } else {
                this.isEdit = false;
            }
            this.dispatchEvent(new CustomEvent('dcfworkstepid', { detail: this.workstepId }));
            this.dcf2RecordStatus = this.dcfData.FSM_Status__c.value;
            if (this.dcf2RecordStatus != 'In Progress') {
                this.isEditOnProgress = true;
                this.Screen1 = false;
            } else {
                this.isEditOnProgress = false;
                this.Screen1 = true;
            }
            // screen 1	
            this.occupiersName = this.dcfData.FSM_OccupiersName__c.value;
            this.occupiersHouseName = this.dcfData.FSM_OccupiersHouseName__c.value;
            this.occupiersHouseNo = this.dcfData.FSM_OccupiersHouseNo__c.value;
            this.occupiersStreet = this.dcfData.FSM_OccupiersStreet__c.value;
            this.occupiersTown = this.dcfData.FSM_OccupiersTown__c.value;
            this.occupiersCity = this.dcfData.FSM_OccupiersCity__c.value;
            this.occupiersPostalCode = this.dcfData.FSM_OccupiersPostcode__c.value;
            this.occupiersTelephone = this.dcfData.FSM_OccupiersTelephoneNumber__c.value;
            // screen2
            this.xCoordinate = this.dcfData.FSM_SFWXcoordinate__c.value;
            this.yCoordinate = this.dcfData.FSM_SFWYcoordinate__c.value;
            this.uidProposedWork = this.dcfData.FSM_SFWUIDOfProposedWork__c.value;
            this.FWDifferentAddress = this.dcfData.FSM_SFWIsThisAtADifferentAddress__c.value;
            this.orderAddressUpdate = this.dcfData.FSM_SFWUpdateAddressOnOrder__c.value;
            //screen3
            this.ownersName = this.dcfData.FSM_OwnersName__c.value;
            this.ownersHouseName = this.dcfData.FSM_OwnersHouseName__c.value;
            this.ownersHouseNo = this.dcfData.FSM_OwnersHouseNo__c.value;
            this.ownersStreet = this.dcfData.FSM_OwnersStreet__c.value;
            this.ownersTown = this.dcfData.FSM_OwnersTown__c.value;
            this.ownersCity = this.dcfData.FSM_OwnersCity__c.value;
            this.ownersPostalCode = this.dcfData.FSM_OwnersPostcode__c.value;
            this.ownersTelephone = this.dcfData.FSM_OwnersTelephoneNumber__c.value;
            //screen4
            this.selectedLocation = this.dcfData.FSM_Location__c.value;
            //screen5
            this.selectedPermissionToDig = this.dcfData.FSM_PermissionToDig__c.value;
            //screen6
            this.selectedTask = this.dcfData.FSM_SWRTask__c.value;
            // this.handleTaskChange();
            this.selectedAsset = this.dcfData.FSM_SWRAsset__c.value;
            // this.handleAssetChange();
            this.selectedJobScope = this.dcfData.FSM_SWRJobScope__c.value;
            // this.handleJobScopeChange();
            this.selectedTrAsset = this.dcfData.FSM_SWRTransferredAsset__c.value;
            // this.handleTransferredAssetChange();
            this.selectedJobRecepient = this.dcfData.FSM_SWRJobRecipient__c.value;
            //screen8
            this.selectedReqEquipment = this.dcfData.FSM_SFWRequestedEquipment__c.value;
            this.manholeRef = this.dcfData.FSM_SFWManholeRef__c.value;
            this.repairLength = this.dcfData.FSM_RepairLength__c.value;
            this.repairDepth = this.dcfData.FSM_RepairDepth__c.value;
            this.proposedWrkDetails = this.dcfData.FSM_DetailsOfProposedWork__c.value;
            this.selectedPriority = this.dcfData.FSM_SFWPriority__c.value;
            //screen9
            this.Monday = this.dcfData.FSM_Monday__c.value;
            this.Tuesday = this.dcfData.FSM_Tuesday__c.value;
            this.Wednesday = this.dcfData.FSM_Wednesday__c.value;
            this.Thursday = this.dcfData.FSM_Thursday__c.value;
            this.Friday = this.dcfData.FSM_Friday__c.value;
            this.Saturday = this.dcfData.FSM_Saturday__c.value;
            this.Sunday = this.dcfData.FSM_Sunday__c.value;
            this.RestrictedTimeAM = this.dcfData.FSM_AM__c.value;
            this.RestrictedTimePM = this.dcfData.FSM_PM__c.value;
            this.RestrictedTimeNight = this.dcfData.FSM_Night__c.value;
            //screen10
            this.isJobTracedMarked = this.dcfData.FSM_JobTracedAndMarked__c.value;
            this.manholesSewersAccessible = this.dcfData.FSM_SFWManholesSewersAccessible__c.value;
            this.anyHandDig = this.dcfData.FSM_SFWAnyHandDig__c.value;
            this.overPumpingRequired = this.dcfData.FSM_SFWOverpumpingRequired__c.value;
            this.handleOverPumpingChange();
            this.overPumpingComments = this.dcfData.FSM_SFWOPIfYesDetails__c.value;
            this.tankerSupportRequired = this.dcfData.FSM_SFWTankerSupportRequired__c.value;
            this.handleTankerSupportChange();
            this.tankerSupportComments = this.dcfData.FSM_SFWTSIfYesDetails__c.value;
            this.otherSupportOperations = this.dcfData.FSM_SFWOtherSupportOperations__c.value;
            this.handleOtherSupportOperationsChange();
            this.otherSupportComments = this.dcfData.FSM_SFWSOIfYesDetails__c.value;
            // screen11
            this.selectedActivity = this.dcfData.FSM_INFRAFWRActivityType__c.value;
            this.selectedSurfaceType = this.dcfData.FSM_SurfaceType__c.value;
            // screen12
            this.selectedMethodOfWork = this.dcfData.FSM_FWRMethodOfWork__c.value;
            this.Carriageway = this.dcfData.FSM_Carriageway__c.value;
            this.Verge = this.dcfData.FSM_Verge__c.value;
            this.BridlewayFootpath = this.dcfData.FSM_BridlewayFootpath__c.value;
            this.PrivateLand = this.dcfData.FSM_PrivateLand__c.value;
            this.Footway = this.dcfData.FSM_Footway__c.value;
            this.Cycleway = this.dcfData.FSM_Cycleway__c.value;
            this.PedestrianisedZone = this.dcfData.FSM_PedestrianZone__c.value;
            this.selectedPedestrianWalkway = this.dcfData.FSM_FWRPedestrianWalkway__c.value;
            this.selectedRoadType = this.dcfData.FSM_FWRRoadType__c.value;
            this.selectedPedestrianLights = this.dcfData.FSM_FWRPedestrianLights__c.value;
            this.selectedSpeed = this.dcfData.FSM_Speed__c.value;
            this.selectedVisibilityMenWork = this.dcfData.FSM_FWRVisibilityToMenAtWork__c.value;
            this.selectedFootwayWidth = this.dcfData.FSM_FWRFootwayWidth__c.value;
            this.selectedCarriagewayWidth = this.dcfData.FSM_FWRCarriagewayWidth__c.value;
            this.selectedTrafficFlow = this.dcfData.FSM_FWRTrafficFlow__c.value;
            this.specialistTreatment = this.dcfData.FSM_SpecialistTreatment__c.value;
            this.handleSpecialistTreatmentChange();

            this.specialistTreatmentComments = this.dcfData.FSM_SpecialistTreatmentComments__c.value;
            this.roadMarking = this.dcfData.FSM_RoadMarkings__c.value;
            this.handleRoadMarkingChange();
            this.roadMarkingComments = this.dcfData.FSM_RoadMarkingsComments__c.value;
            this.trafficLights50mm = this.dcfData.FSM_TrafficLightsLessThan50m__c.value;
            this.trafficLightRestriction = this.dcfData.FSM_TrafficLightRestriction__c.value;
            this.selectedTrafficSensitive = this.dcfData.FSM_IsTheLocationTrafficSensitive__c.value;
            // screen13
            this.selectedJobUrgent = this.dcfData.FSM_IsTheJobUrgent__c.value;
            this.selectedWaitingCones = this.dcfData.FSM_AreNoWaitingConesRequired__c.value;
            this.selectedFootwayClosure = this.dcfData.FSM_FootwayClosure__c.value;
            this.parkingSuspension = this.dcfData.FSM_ParkingSuspension__c.value;
            this.selCarriagewayRestriction = this.dcfData.FSM_CarriagewayRestriction__c.value;
            this.selectedTrainOrTram = this.dcfData.FSM_FWRTrainOrTram__c.value;
            this.selectedBus = this.dcfData.FSM_FWRBus__c.value;
            this.selectedCycle = this.dcfData.FSM_FWRCycle__c.value;
            this.selectedSpecialFeature = this.dcfData.FSM_FWRSpecialFeature__c.value;
            this.selectedCommsMethod = this.dcfData.FSM_FWRCommsMethod__c.value;
            if (!!this.dcfData.FSM_FWRCommsType__c.value) {
                this.selectedCommsType = this.dcfData.FSM_FWRCommsType__c.value.split(';');
            }

            this.selectedSiteComments = this.dcfData.FSM_FWRSiteComments__c.value;
            this.selectedPlanningInfo = this.dcfData.FSM_FWRPlanningInformation__c.value;
            // screen14
            this.envImpact = this.dcfData.FSM_SFWPotentialEnvironmentalImpact__c.value;
            this.handleEnvImpactChange();
            this.envImpactComments = this.dcfData.FSM_EnvImpactComments__c.value;
            this.evnImpSite = this.dcfData.FSM_RiskToAnEnvironmentalSite__c.value;
            // screen15
            this.overheadPowerlines = this.dcfData.FSM_OverheadPowerLinesWithin10m__c.value;
            this.handleOverheadPowerlinesChange();
            this.lampSupport = this.dcfData.FSM_LampSupportRemovalRequired__c.value;
            this.confinedSpace = this.dcfData.FSM_ConfinedSpaceWorking__c.value;
            this.additionalSafetyInfo = this.dcfData.FSM_DetailsSafetyInformation__c.value;
        } else if (error) {
            console.error('retains value:', error);
        }
    }

    @wire(getAllSWRRecords)
    wiredAllRecords({ data, error }) {
        if (data) {
            this.allRecords = JSON.stringify(data);
        } else if (error) {
            console.error('Error while fetching all Dependant Picklists ', error);
        }
    }

    //To fetch Task picklist Values
    @wire(getSWRTaskList)
    wiredSWRTaskList({ data, error }) {
        if (data) {
            this.taskRecords = data.taskList;
            this.assetRecords = data.assetList;
            this.jobScopeRecords = data.jobScopeList;
            this.transferredAssetRecords = data.transferredAssetList;
            this.jobRecepientRecords = data.jobRecepientList;
        } else if (error) {
            console.error('Error while fetching SWR Task ', error);
        }
    }

    //To Handle Task Picklist Change
    handleTaskChange(event) {
        this.filteredJobScope = [];
        this.filteredJobRecepient = [];
        this.filteredTransferredAsset = [];
        let dupAssetCheck = [];
        let filteredAssetOps = [];
        if (event) {
            this.selectedTask = event.detail.value;
        }
        let dataObj = JSON.parse(this.allRecords);
        dataObj.forEach(record => {
            if (this.selectedTask === record.FSM_SWRTask__c && !dupAssetCheck.includes(record.FSM_SWRAsset__c)) {
                let exists = this.assetRecords.find(obj => obj.value === record.FSM_SWRAsset__c);
                filteredAssetOps.push(exists);
                dupAssetCheck.push(record.FSM_SWRAsset__c);
            }
        });
        this.filteredAsset = filteredAssetOps;


    }

    //To Handle Asset Picklist Change
    handleAssetChange(event) {
        this.filteredTransferredAsset = [];
        this.filteredJobRecepient = [];
        let dupJobScopeCheck = [];
        let filteredJobScopeOps = [];

        // this.selectedAsset = event.detail.value;
        if (event) {
            this.selectedAsset = event.target.value;
        }
        let dataObj = JSON.parse(this.allRecords);

        dataObj.forEach(record => {
            if (this.selectedTask === record.FSM_SWRTask__c && this.selectedAsset === record.FSM_SWRAsset__c && !dupJobScopeCheck.includes(record.FSM_SWRJobScope__c)) {
                let exists = this.jobScopeRecords.find(obj => obj.value === record.FSM_SWRJobScope__c);
                filteredJobScopeOps.push(exists);
                dupJobScopeCheck.push(record.FSM_SWRJobScope__c);
            }
        });

        this.filteredJobScope = filteredJobScopeOps;
    }

    //To Handle JobScope Picklist Change
    handleJobScopeChange(event) {
        this.filteredJobRecepient = [];
        let dupTransferredAssetCheck = [];
        let filteredTransferredAssetOps = [];

        if (event) {
            this.selectedJobScope = event.detail.value;
        }

        let dataObj = JSON.parse(this.allRecords);

        dataObj.forEach(record => {
            if (this.selectedTask === record.FSM_SWRTask__c && this.selectedAsset === record.FSM_SWRAsset__c && this.selectedJobScope === record.FSM_SWRJobScope__c && !dupTransferredAssetCheck.includes(record.FSM_SWRTransferredAsset__c)) {
                let exists = this.transferredAssetRecords.find(obj => obj.value === record.FSM_SWRTransferredAsset__c);
                filteredTransferredAssetOps.push(exists);
                dupTransferredAssetCheck.push(record.FSM_SWRTransferredAsset__c);
            }
        });

        this.filteredTransferredAsset = filteredTransferredAssetOps;
    }

    //To Handle TransferredAsset Picklist Change
    handleTransferredAssetChange(event) {
        if (event) {
            this.selectedTrAsset = event.detail.value;
        }
        let dataObj = JSON.parse(this.allRecords);
        let dupJobRecepientCheck = [];
        let filteredJobRecepientOps = [];

        dataObj.forEach(record => {
            if (this.selectedTask === record.FSM_SWRTask__c && this.selectedAsset === record.FSM_SWRAsset__c && this.selectedJobScope === record.FSM_SWRJobScope__c && this.selectedTrAsset === record.FSM_SWRTransferredAsset__c && !dupJobRecepientCheck.includes(record.FSM_SWRJobRecipient__c)) {
                let exists = this.jobRecepientRecords.find(obj => obj.value === record.FSM_SWRJobRecipient__c);
                filteredJobRecepientOps.push(exists);
                dupJobRecepientCheck.push(record.FSM_SWRJobRecipient__c);
            }
        });
        this.filteredJobRecepient = filteredJobRecepientOps;
    }

    //To Handle JobRecepient Picklist Change
    handleJobRecepientChange(event) {
        if (event) {
            this.selectedJobRecepient = event.detail.value;
        }
    }
    /**
     * 
      Scrolls the page to bring the element with the specified `data-id` attribute into view.
     */
    handleScrollClick(dataId) {
        const targetDiv = this.template.querySelector(`[data-id="${dataId}"]`);
        if (targetDiv) {
            targetDiv.scrollIntoView();
        } else {
            console.warn(`No element found with data-id="${dataId}"`);
        }
    }
    // Description : Method to handle next screen navigations on Button Click
    handleNext() {
        if (this.Screen1) {
            if (this.isEdit === true) {
                this.handleTaskChange();
                this.handleAssetChange();
                this.handleJobScopeChange();
                this.handleTransferredAssetChange();
            }
            this.saveScreenOneValues();
            this.handleSection1Validation();
            if (this.isValidScreen1) {
                this.Screen2 = true;
                this.Screen3 = this.Screen1 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
        } else if (this.Screen2) {
            this.saveScreenTwoValues();
            this.handleSection2Validation();
            if (this.isValidScreen2) {
                if (this.FWDifferentAddress == true) {
                    this.Screen3 = true;
                    this.Screen1 = this.Screen2 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                    this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
                }
                else {
                    this.Screen4 = true;
                    this.Screen1 = this.Screen2 = this.Screen3 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                    this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
                }
            }
        }
        else if (this.Screen3) {
            this.saveScreenThreeValues();
            this.handleSection3Validation();
            if (this.isValidScreen3) {
                this.Screen4 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
            // if (this.isValidScreen3) {
            //     this.Screen4 = true;
            //     this.Screen1 = this.Screen2 = this.Screen3 = this.Screen5 = this.Screen6 = this.Screen8 = false;
            //     this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;

            // }

        }
        else if (this.Screen4) {
            this.saveScreenFourValues();
            this.handleSection4Validation();
            if (this.isValidScreen4) {
                if (this.selectedLocation == 'Private Land') {
                    this.Screen5 = true;
                    this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen6 = this.Screen8 = false;
                    this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
                }
                else {
                    this.Screen6 = true;
                    this.selectedPermissionToDig = '';
                    this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen8 = false;
                    this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
                }
            }
        }
        else if (this.Screen5) {
            this.saveScreenFiveValues();
            this.handleSection5Validation();
            if (this.isValidScreen5) {
                this.Screen6 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
        }
        else if (this.Screen6) {
            this.saveScreenSixValues();
            this.handleSection6Validation();
            if (this.isValidScreen6) {
                this.Screen8 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
        }
        else if (this.Screen8) {
            this.saveScreenEightValues();
            this.handleSection8Validation();
            if (this.isValidScreen8) {
                this.Screen9 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = false;
                this.Screen8 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
        }
        else if (this.Screen9) {
            this.saveScreenNineValues();
            this.Screen10 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = false;
            this.Screen8 = this.Screen9 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen10) {
            this.saveScreenTenValues();
            this.handleSection10Validation();
            if (this.isValidScreen10) {
                if (this.selectedLocation == 'On Highway') {
                    this.Screen11 = true;
                    this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = false;
                    this.Screen8 = this.Screen9 = this.Screen10 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
                }
                else {
                    this.Screen14 = true;
                    this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                    this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen15 = false;
                }
            }
        }
        else if (this.Screen11) {
            this.saveScreenElevenValues();
            this.handleSection11Validation();
            if (this.isValidScreen11) {
                this.Screen12 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
        }
        else if (this.Screen12) {
            this.saveScreenTwelveValues();
            this.handleSection12Validation();
            if (this.isValidScreen12) {
                this.Screen13 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen14 = this.Screen15 = false;
                setTimeout(() => {
                    this.handleScrollClick('nav-screen13');
                }, 50);

            }
        }
        else if (this.Screen13) {
            this.saveScreenThirteenValues();
            this.handleSection13Validation();
            if (this.isValidScreen13) {
                this.Screen14 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen15 = false;
            }
        }
        else if (this.Screen14) {
            this.saveScreenFourteenValues();
            this.handleSection14Validation();
            if (this.isValidScreen14) {
                this.Screen15 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = false;
            }
        }
        else if (this.Screen15) {
            this.saveScreenFifteenValues();
            this.handleSection15Validation();
            if (this.isValidScreen15) {
                this.sendvaluestofsmfurtherworkrequest();
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
        }
    }


    clearTmaSection() {
        this.selectedActivity = '';
        this.selectedSurfaceType = '';
        this.selectedMethodOfWork = '';
        this.Carriageway = false;
        this.Verge = false;
        this.BridlewayFootpath = false;
        this.PrivateLand = false;
        this.Footway = false;
        this.Cycleway = false;
        this.PedestrianisedZone = false;
        this.selectedPedestrianWalkway = '';
        this.selectedRoadType = '';
        this.selectedPedestrianLights = '';
        this.selectedSpeed = '';
        this.selectedVisibilityMenWork = '';
        this.selectedFootwayWidth = '';
        this.selectedCarriagewayWidth = '';
        this.selectedTrafficFlow = '';
        this.specialistTreatment = '';
        this.specialistTreatmentComments = '';
        this.roadMarking = '';
        this.roadMarkingComments = '';
        this.trafficLights50mm = '';
        this.trafficLightRestriction = '';
        this.selectedTrafficSensitive = '';
        this.selectedJobUrgent = '';
        this.selectedWaitingCones = '';
        this.selectedFootwayClosure = '';
        this.parkingSuspension = '';
        this.selCarriagewayRestriction = '';
        this.selectedTrainOrTram = '';
        this.selectedBus = '';
        this.selectedCycle = '';
        this.selectedSpecialFeature = '';
        this.selectedCommsMethod = '';
        this.selectedCommsType = '';
        this.selectedSiteComments = '';
        this.selectedPlanningInfo = '';
    }


    // Send Values to Parent Component
    sendvaluestofsmfurtherworkrequest() {
        if (!!JSON.stringify(this.dcfinfrarecorddata)) {
            const finalarr = { ...this.dcfinfrarecorddata, ...this.submitValues }
            const event = new CustomEvent('finalsubmit', {
                detail: { dcfdata: finalarr }
            });
            this.dispatchEvent(event);
        } else {
            const event = new CustomEvent('finalsubmit', {

                detail: { dcfdata: this.submitValues }
            });
            this.dispatchEvent(event);
        }

    }

    // Description : Method to handle previous navigations on button click
    handlePrevious() {
        if (this.Screen1) {
            return;
        } else if (this.Screen2) {
            this.errormessages = [];
            this.saveScreenTwoValues();
            this.Screen1 = true;
            this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
            this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen3) {
            this.errormessages = [];
            this.saveScreenThreeValues();
            this.Screen2 = true;
            this.Screen1 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
            this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen4) {
            this.errormessages = [];
            this.saveScreenFourValues();
            if (this.FWDifferentAddress == true) {
                this.Screen3 = true;
                this.Screen1 = this.Screen2 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            } else {
                this.Screen2 = true;
                this.Screen1 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
        }
        else if (this.Screen5) {
            this.errormessages = [];
            this.saveScreenFiveValues();
            this.Screen4 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen5 = this.Screen6 = this.Screen8 = false;
            this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen6) {
            this.errormessages = [];
            this.saveScreenSixValues();
            if (this.selectedLocation == 'Private Land') {
                this.Screen5 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            } else {
                this.Screen4 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            }
        }
        else if (this.Screen8) {
            this.errormessages = [];
            this.saveScreenEightValues();
            this.handleTaskChange();
            this.handleAssetChange();
            this.handleJobScopeChange();
            this.handleTransferredAssetChange();
            this.Screen6 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen8 = false;
            this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen9) {
            this.errormessages = [];
            this.saveScreenNineValues();
            this.Screen8 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = false;
            this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen10) {
            this.errormessages = [];
            this.saveScreenTenValues();
            this.Screen9 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = false;
            this.Screen8 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen11) {
            this.errormessages = [];
            this.saveScreenElevenValues();
            this.Screen10 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
            this.Screen9 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen12) {
            this.errormessages = [];
            this.saveScreenTwelveValues();
            this.Screen11 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
            this.Screen9 = this.Screen10 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;
        }
        else if (this.Screen13) {
            this.errormessages = [];
            this.saveScreenThirteenValues();
            this.Screen12 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
            this.Screen9 = this.Screen10 = this.Screen11 = this.Screen13 = this.Screen14 = this.Screen15 = false;
            setTimeout(() => {
                this.handleScrollClick('nav-screen12');
            }, 50);


        }
        else if (this.Screen14) {
            this.errormessages = [];
            this.saveScreenFourteenValues();
            if (this.selectedLocation == 'On Highway') {
                this.Screen13 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen14 = this.Screen15 = false;

            }
            else {
                this.Screen10 = true;
                this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
                this.Screen9 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = this.Screen15 = false;

            }
        }
        else if (this.Screen15) {
            this.errormessages = [];
            this.saveScreenFifteenValues();
            this.Screen14 = true;
            this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
            this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen15 = false;
        }

    }

    //previous from parent Component
    connectedCallback() {
        if (!!JSON.stringify(this.isprevfromnextcmp)) {
            this.handlepreviousfromfwr(this.isprevfromnextcmp);
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

    // handle Previous
    @api handlepreviousfromfwr(dcfrecorddata) {
        this.isFirstTimeCalled = false;
        const dcfforminput = JSON.parse(JSON.stringify(dcfrecorddata));
        this.retainvaluestochild = dcfforminput.dcfdata;
        this.dcfinfrarecorddata = dcfforminput.dcfdata;
        this.Screen15 = true;
        this.Screen1 = this.Screen2 = this.Screen3 = this.Screen4 = this.Screen5 = this.Screen6 = this.Screen8 = false;
        this.Screen9 = this.Screen10 = this.Screen11 = this.Screen12 = this.Screen13 = this.Screen14 = false;
        // screen 1	
        this.woid = this.submitValues.FSM_WorkOrder__c;
        this.occupiersName = this.dcfinfrarecorddata.FSM_OccupiersName__c;
        this.occupiersHouseName = this.dcfinfrarecorddata.FSM_OccupiersHouseName__c;
        this.occupiersHouseNo = this.dcfinfrarecorddata.FSM_OccupiersHouseNo__c;
        this.occupiersStreet = this.dcfinfrarecorddata.FSM_OccupiersStreet__c;
        this.occupiersTown = this.dcfinfrarecorddata.FSM_OccupiersTown__c;
        this.occupiersCity = this.dcfinfrarecorddata.FSM_OccupiersCity__c;
        this.occupiersPostalCode = this.dcfinfrarecorddata.FSM_OccupiersPostcode__c;
        this.occupiersTelephone = this.dcfinfrarecorddata.FSM_OccupiersTelephoneNumber__c;
        // screen2
        this.xCoordinate = this.dcfinfrarecorddata.FSM_SFWXcoordinate__c;
        this.yCoordinate = this.dcfinfrarecorddata.FSM_SFWYcoordinate__c;
        this.uidProposedWork = this.dcfinfrarecorddata.FSM_SFWUIDOfProposedWork__c;
        this.FWDifferentAddress = this.dcfinfrarecorddata.FSM_SFWIsThisAtADifferentAddress__c;
        this.orderAddressUpdate = this.dcfinfrarecorddata.FSM_SFWUpdateAddressOnOrder__c;
        // //screen3
        this.ownersName = this.dcfinfrarecorddata.FSM_OwnersName__c;
        this.ownersHouseName = this.dcfinfrarecorddata.FSM_OwnersHouseName__c;
        this.ownersHouseNo = this.dcfinfrarecorddata.FSM_OwnersHouseNo__c;
        this.ownersStreet = this.dcfinfrarecorddata.FSM_OwnersStreet__c;
        this.ownersTown = this.dcfinfrarecorddata.FSM_OwnersTown__c;
        this.ownersCity = this.dcfinfrarecorddata.FSM_OwnersCity__c;
        this.ownersPostalCode = this.dcfinfrarecorddata.FSM_OwnersPostcode__c;
        this.ownersTelephone = this.dcfinfrarecorddata.FSM_OwnersTelephoneNumber__c;
        // //screen4
        this.selectedLocation = this.dcfinfrarecorddata.FSM_Location__c;
        // //screen5
        this.selectedPermissionToDig = this.dcfinfrarecorddata.FSM_PermissionToDig__c;
        // //screen6
        this.selectedTask = this.dcfinfrarecorddata.FSM_SWRTask__c;
        this.selectedAsset = this.dcfinfrarecorddata.FSM_SWRAsset__c;
        this.selectedJobScope = this.dcfinfrarecorddata.FSM_SWRJobScope__c;
        this.selectedTrAsset = this.dcfinfrarecorddata.FSM_SWRTransferredAsset__c;
        this.selectedJobRecepient = this.dcfinfrarecorddata.FSM_SWRJobRecipient__c;
        // //screen8
        this.selectedReqEquipment = this.dcfinfrarecorddata.FSM_SFWRequestedEquipment__c;
        this.manholeRef = this.dcfinfrarecorddata.FSM_SFWManholeRef__c;
        this.repairLength = this.dcfinfrarecorddata.FSM_RepairLength__c;
        this.repairDepth = this.dcfinfrarecorddata.FSM_RepairDepth__c;
        this.proposedWrkDetails = this.dcfinfrarecorddata.FSM_DetailsOfProposedWork__c;
        this.selectedPriority = this.dcfinfrarecorddata.FSM_SFWPriority__c;
        // //screen9
        this.Monday = this.dcfinfrarecorddata.FSM_Monday__c;
        this.Tuesday = this.dcfinfrarecorddata.FSM_Tuesday__c;
        this.Wednesday = this.dcfinfrarecorddata.FSM_Wednesday__c;
        this.Thursday = this.dcfinfrarecorddata.FSM_Thursday__c;
        this.Friday = this.dcfinfrarecorddata.FSM_Friday__c;
        this.Saturday = this.dcfinfrarecorddata.FSM_Saturday__c;
        this.Sunday = this.dcfinfrarecorddata.FSM_Sunday__c;
        this.RestrictedTimeAM = this.dcfinfrarecorddata.FSM_AM__c;
        this.RestrictedTimePM = this.dcfinfrarecorddata.FSM_PM__c;
        this.RestrictedTimeNight = this.dcfinfrarecorddata.FSM_Night__c;
        // //screen10
        this.isJobTracedMarked = this.dcfinfrarecorddata.FSM_JobTracedAndMarked__c;
        this.manholesSewersAccessible = this.dcfinfrarecorddata.FSM_SFWManholesSewersAccessible__c;
        this.anyHandDig = this.dcfinfrarecorddata.FSM_SFWAnyHandDig__c;
        this.overPumpingRequired = this.dcfinfrarecorddata.FSM_SFWOverpumpingRequired__c;
        this.handleOverPumpingChange();
        this.overPumpingComments = this.dcfinfrarecorddata.FSM_SFWOPIfYesDetails__c;
        this.tankerSupportRequired = this.dcfinfrarecorddata.FSM_SFWTankerSupportRequired__c;
        this.handleTankerSupportChange();
        if (this.tankerSupportRequired == 'Yes') {
            this.tankerSupportComments = this.dcfinfrarecorddata.FSM_SFWTSIfYesDetails__c; // error on this field
        } else {
            this.tankerSupportComments = '';
        }
        this.otherSupportOperations = this.dcfinfrarecorddata.FSM_SFWOtherSupportOperations__c;
        this.handleOtherSupportOperationsChange();
        this.otherSupportComments = this.dcfinfrarecorddata.FSM_SFWSOIfYesDetails__c;
        // // screen11
        this.selectedActivity = this.dcfinfrarecorddata.FSM_INFRAFWRActivityType__c;
        this.selectedSurfaceType = this.dcfinfrarecorddata.FSM_SurfaceType__c;
        // screen12
        this.selectedMethodOfWork = this.dcfinfrarecorddata.FSM_FWRMethodOfWork__c;
        this.Carriageway = this.dcfinfrarecorddata.FSM_Carriageway__c;
        this.Verge = this.dcfinfrarecorddata.FSM_Verge__c;
        this.BridlewayFootpath = this.dcfinfrarecorddata.FSM_BridlewayFootpath__c;
        this.PrivateLand = this.dcfinfrarecorddata.FSM_PrivateLand__c;
        this.Footway = this.dcfinfrarecorddata.FSM_Footway__c;
        this.Cycleway = this.dcfinfrarecorddata.FSM_Cycleway__c;
        this.PedestrianisedZone = this.dcfinfrarecorddata.FSM_PedestrianZone__c;
        this.selectedPedestrianWalkway = this.dcfinfrarecorddata.FSM_FWRPedestrianWalkway__c;
        this.selectedRoadType = this.dcfinfrarecorddata.FSM_FWRRoadType__c;
        this.selectedPedestrianLights = this.dcfinfrarecorddata.FSM_FWRPedestrianLights__c;
        this.selectedSpeed = this.dcfinfrarecorddata.FSM_Speed__c;
        this.selectedVisibilityMenWork = this.dcfinfrarecorddata.FSM_FWRVisibilityToMenAtWork__c;
        this.selectedFootwayWidth = this.dcfinfrarecorddata.FSM_FWRFootwayWidth__c;
        this.selectedCarriagewayWidth = this.dcfinfrarecorddata.FSM_FWRCarriagewayWidth__c;
        this.selectedTrafficFlow = this.dcfinfrarecorddata.FSM_FWRTrafficFlow__c;
        this.specialistTreatment = this.dcfinfrarecorddata.FSM_SpecialistTreatment__c;
        this.handleSpecialistTreatmentChange();
        this.specialistTreatmentComments = this.dcfinfrarecorddata.FSM_SpecialistTreatmentComments__c;
        this.roadMarking = this.dcfinfrarecorddata.FSM_RoadMarkings__c;
        this.handleRoadMarkingChange();
        this.roadMarkingComments = this.dcfinfrarecorddata.FSM_RoadMarkingsComments__c;
        this.trafficLights50mm = this.dcfinfrarecorddata.FSM_TrafficLightsLessThan50m__c;
        this.trafficLightRestriction = this.dcfinfrarecorddata.FSM_TrafficLightRestriction__c;
        this.selectedTrafficSensitive = this.dcfinfrarecorddata.FSM_IsTheLocationTrafficSensitive__c;
        // screen13
        this.selectedJobUrgent = this.dcfinfrarecorddata.FSM_IsTheJobUrgent__c;
        this.selectedWaitingCones = this.dcfinfrarecorddata.FSM_AreNoWaitingConesRequired__c;
        this.selectedFootwayClosure = this.dcfinfrarecorddata.FSM_FootwayClosure__c;
        this.parkingSuspension = this.dcfinfrarecorddata.FSM_ParkingSuspension__c;
        this.selCarriagewayRestriction = this.dcfinfrarecorddata.FSM_CarriagewayRestriction__c;
        this.selectedTrainOrTram = this.dcfinfrarecorddata.FSM_FWRTrainOrTram__c;
        this.selectedBus = this.dcfinfrarecorddata.FSM_FWRBus__c;
        this.selectedCycle = this.dcfinfrarecorddata.FSM_FWRCycle__c;
        this.selectedSpecialFeature = this.dcfinfrarecorddata.FSM_FWRSpecialFeature__c;
        this.selectedCommsMethod = this.dcfinfrarecorddata.FSM_FWRCommsMethod__c;
        this.selectedCommsType = this.dcfinfrarecorddata.FSM_FWRCommsType__c;
        this.selectedSiteComments = this.dcfinfrarecorddata.FSM_FWRSiteComments__c;
        this.selectedPlanningInfo = this.dcfinfrarecorddata.FSM_FWRPlanningInformation__c;
        // screen14
        this.envImpact = this.dcfinfrarecorddata.FSM_SFWPotentialEnvironmentalImpact__c;
        this.handleEnvImpactChange();
        this.envImpactComments = this.dcfinfrarecorddata.FSM_EnvImpactComments__c;
        this.evnImpSite = this.dcfinfrarecorddata.FSM_RiskToAnEnvironmentalSite__c;
        // screen15
        this.overheadPowerlines = this.dcfinfrarecorddata.FSM_OverheadPowerLinesWithin10m__c;
        this.handleOverheadPowerlinesChange();
        this.lampSupport = this.dcfinfrarecorddata.FSM_LampSupportRemovalRequired__c;
        this.confinedSpace = this.dcfinfrarecorddata.FSM_ConfinedSpaceWorking__c;
        this.additionalSafetyInfo = this.dcfinfrarecorddata.FSM_DetailsSafetyInformation__c;

    }

    //---------Start of Saving Screen Values Methods---------
    saveScreenOneValues() {
        this.submitValues.FSM_WorkOrder__c = this.woid;
        this.submitValues.FSM_FormType__c = 'Sewerage-Further Work Request (SCM)';
        this.submitValues.FSM_OccupiersName__c = this.occupiersName;
        this.submitValues.FSM_OccupiersHouseName__c = this.occupiersHouseName;
        this.submitValues.FSM_OccupiersHouseNo__c = this.occupiersHouseNo;
        this.submitValues.FSM_OccupiersStreet__c = this.occupiersStreet;
        this.submitValues.FSM_OccupiersTown__c = this.occupiersTown;
        this.submitValues.FSM_OccupiersCity__c = this.occupiersCity;
        this.submitValues.FSM_OccupiersPostcode__c = this.occupiersPostalCode;
        this.submitValues.FSM_OccupiersTelephoneNumber__c = this.occupiersTelephone;
    }
    saveScreenTwoValues() {
        this.submitValues.FSM_SFWXcoordinate__c = this.xCoordinate;
        this.submitValues.FSM_SFWYcoordinate__c = this.yCoordinate;
        this.submitValues.FSM_SFWUIDOfProposedWork__c = this.uidProposedWork;
        this.submitValues.FSM_SFWIsThisAtADifferentAddress__c = this.FWDifferentAddress;
        this.submitValues.FSM_SFWUpdateAddressOnOrder__c = this.orderAddressUpdate;

    }
    saveScreenThreeValues() {
        this.submitValues.FSM_OwnersName__c = this.ownersName;
        this.submitValues.FSM_OwnersHouseName__c = this.ownersHouseName;
        this.submitValues.FSM_OwnersHouseNo__c = this.ownersHouseNo;
        this.submitValues.FSM_OwnersStreet__c = this.ownersStreet;
        this.submitValues.FSM_OwnersTown__c = this.ownersTown;
        this.submitValues.FSM_OwnersCity__c = this.ownersCity;
        this.submitValues.FSM_OwnersPostcode__c = this.ownersPostalCode;
        this.submitValues.FSM_OwnersTelephoneNumber__c = this.ownersTelephone;
    }
    saveScreenFourValues() {
        this.submitValues.FSM_Location__c = this.selectedLocation;
    }
    saveScreenFiveValues() {
        this.submitValues.FSM_PermissionToDig__c = this.selectedPermissionToDig;
    }
    saveScreenSixValues() {
        this.submitValues.FSM_SWRTask__c = this.selectedTask;
        this.submitValues.FSM_SWRAsset__c = this.selectedAsset;
        this.submitValues.FSM_SWRJobScope__c = this.selectedJobScope;
        this.submitValues.FSM_SWRTransferredAsset__c = this.selectedTrAsset;
        this.submitValues.FSM_SWRJobRecipient__c = this.selectedJobRecepient;
    }

    saveScreenEightValues() {
        this.submitValues.FSM_SFWRequestedEquipment__c = this.selectedReqEquipment;
        this.submitValues.FSM_SFWManholeRef__c = this.manholeRef;
        this.submitValues.FSM_RepairLength__c = this.repairLength;
        this.submitValues.FSM_RepairDepth__c = this.repairDepth;
        this.submitValues.FSM_DetailsOfProposedWork__c = this.proposedWrkDetails;
        this.submitValues.FSM_SFWPriority__c = this.selectedPriority;
    }
    saveScreenNineValues() {
        this.submitValues.FSM_Monday__c = this.Monday;
        this.submitValues.FSM_Tuesday__c = this.Tuesday;
        this.submitValues.FSM_Wednesday__c = this.Wednesday;
        this.submitValues.FSM_Thursday__c = this.Thursday;
        this.submitValues.FSM_Friday__c = this.Friday;
        this.submitValues.FSM_Saturday__c = this.Saturday;
        this.submitValues.FSM_Sunday__c = this.Sunday;
        this.submitValues.FSM_AM__c = this.RestrictedTimeAM;
        this.submitValues.FSM_PM__c = this.RestrictedTimePM;
        this.submitValues.FSM_Night__c = this.RestrictedTimeNight;

    }
    saveScreenTenValues() {
        this.submitValues.FSM_JobTracedAndMarked__c = this.isJobTracedMarked;
        this.submitValues.FSM_SFWManholesSewersAccessible__c = this.manholesSewersAccessible;
        this.submitValues.FSM_SFWAnyHandDig__c = this.anyHandDig;
        this.submitValues.FSM_SFWOverpumpingRequired__c = this.overPumpingRequired;
        this.submitValues.FSM_SFWOPIfYesDetails__c = this.overPumpingComments;
        this.submitValues.FSM_SFWTankerSupportRequired__c = this.tankerSupportRequired;
        this.submitValues.FSM_SFWTSIfYesDetails__c = this.tankerSupportComments;
        this.submitValues.FSM_SFWOtherSupportOperations__c = this.otherSupportOperations;
        this.submitValues.FSM_SFWSOIfYesDetails__c = this.otherSupportComments;
    }
    saveScreenElevenValues() {
        this.submitValues.FSM_INFRAFWRActivityType__c = this.selectedActivity;
        this.submitValues.FSM_SurfaceType__c = this.selectedSurfaceType;
    }
    saveScreenTwelveValues() {
        // SFS-6005
        this.submitValues.FSM_FWRMethodOfWork__c = this.selectedMethodOfWork;
        this.submitValues.FSM_Carriageway__c = this.Carriageway;
        this.submitValues.FSM_Verge__c = this.Verge;
        this.submitValues.FSM_BridlewayFootpath__c = this.BridlewayFootpath;
        this.submitValues.FSM_PrivateLand__c = this.PrivateLand;
        this.submitValues.FSM_Footway__c = this.Footway;
        this.submitValues.FSM_Cycleway__c = this.Cycleway;
        this.submitValues.FSM_PedestrianZone__c = this.PedestrianisedZone;
        this.submitValues.FSM_FWRPedestrianWalkway__c = this.selectedPedestrianWalkway;
        this.submitValues.FSM_FWRRoadType__c = this.selectedRoadType;
        this.submitValues.FSM_FWRPedestrianLights__c = this.selectedPedestrianLights;
        this.submitValues.FSM_Speed__c = this.selectedSpeed;
        this.submitValues.FSM_FWRVisibilityToMenAtWork__c = this.selectedVisibilityMenWork;
        this.submitValues.FSM_FWRFootwayWidth__c = this.selectedFootwayWidth;
        this.submitValues.FSM_FWRCarriagewayWidth__c = this.selectedCarriagewayWidth;
        this.submitValues.FSM_FWRTrafficFlow__c = this.selectedTrafficFlow;
        this.submitValues.FSM_SpecialistTreatment__c = this.specialistTreatment;
        this.submitValues.FSM_SpecialistTreatmentComments__c = this.specialistTreatmentComments;
        this.submitValues.FSM_RoadMarkings__c = this.roadMarking;
        this.submitValues.FSM_RoadMarkingsComments__c = this.roadMarkingComments;
        this.submitValues.FSM_TrafficLightsLessThan50m__c = this.trafficLights50mm;
        this.submitValues.FSM_TrafficLightRestriction__c = this.trafficLightRestriction;
        this.submitValues.FSM_IsTheLocationTrafficSensitive__c = this.selectedTrafficSensitive;
    }
    saveScreenThirteenValues() {
        this.submitValues.FSM_IsTheJobUrgent__c = this.selectedJobUrgent;
        this.submitValues.FSM_AreNoWaitingConesRequired__c = this.selectedWaitingCones;
        this.submitValues.FSM_FootwayClosure__c = this.selectedFootwayClosure;
        this.submitValues.FSM_ParkingSuspension__c = this.parkingSuspension;
        this.submitValues.FSM_CarriagewayRestriction__c = this.selCarriagewayRestriction;
        this.submitValues.FSM_FWRTrainOrTram__c = this.selectedTrainOrTram;
        this.submitValues.FSM_FWRBus__c = this.selectedBus;
        this.submitValues.FSM_FWRCycle__c = this.selectedCycle;
        this.submitValues.FSM_FWRSpecialFeature__c = this.selectedSpecialFeature;
        this.submitValues.FSM_FWRCommsMethod__c = this.selectedCommsMethod;
        this.submitValues.FSM_FWRCommsType__c = this.selectedCommsType;
        this.submitValues.FSM_FWRSiteComments__c = this.selectedSiteComments;
        this.submitValues.FSM_FWRPlanningInformation__c = this.selectedPlanningInfo;

    }
    saveScreenFourteenValues() {
        this.submitValues.FSM_SFWPotentialEnvironmentalImpact__c = this.envImpact;
        this.submitValues.FSM_EnvImpactComments__c = this.envImpactComments;
        this.submitValues.FSM_RiskToAnEnvironmentalSite__c = this.evnImpSite;
    }
    saveScreenFifteenValues() {
        this.submitValues.FSM_OverheadPowerLinesWithin10m__c = this.overheadPowerlines;
        this.submitValues.FSM_LampSupportRemovalRequired__c = this.lampSupport;
        this.submitValues.FSM_ConfinedSpaceWorking__c = this.confinedSpace;
        this.submitValues.FSM_DetailsSafetyInformation__c = this.additionalSafetyInfo;
    }

    //  Validation of Screen Values
    handleSection1Validation() {
        this.errormessages = [];
        this.isValidScreen1 = true;
        if ((this.occupiersHouseNo == '' || this.occupiersHouseNo == null) &&
            (this.occupiersStreet == '' || this.occupiersStreet == null) &&
            (this.occupiersCity == '' || this.occupiersCity == null) &&
            (this.occupiersPostalCode == '' || this.occupiersPostalCode == null)) {
            this.errormessages.push('Please enter data in all the required fields');
            this.isValidScreen1 = false;
        }
        else if (this.occupiersName != null && String(this.occupiersName).length > 80) {
            this.errormessages.push("Occupier's Name must not exceed 80 characters.");
            this.isValidScreen1 = false;
        }
        else if (this.occupiersHouseName != null && String(this.occupiersHouseName).length > 80) {
            this.errormessages.push("House Name must not exceed 80 characters.");
            this.isValidScreen1 = false;
        }
        else if ((this.occupiersHouseNo == '' || this.occupiersHouseNo == null) || String(this.occupiersHouseNo).length > 10) {
            if (String(this.occupiersHouseNo).length > 10) {
                this.errormessages.push("House Number must not exceed 10 characters.");
            } else {
                this.errormessages.push('Please enter value in House Number');
            }
            this.isValidScreen1 = false;
        }
        else if ((this.occupiersStreet == '' || this.occupiersStreet == null) || String(this.occupiersStreet).length > 80) {
            if (String(this.occupiersStreet).length > 80) {
                this.errormessages.push("Street details must not exceed 80 characters.");
            } else {
                this.errormessages.push('Please enter value in Street details');
            }
            this.isValidScreen1 = false;
        }
        else if (this.occupiersTown != null && String(this.occupiersTown).length > 80) {
            this.errormessages.push('Town details must not exceed 80 characters.');
            this.isValidScreen1 = false;
        }
        else if ((this.occupiersCity == '' || this.occupiersCity == null) || String(this.occupiersCity).length > 80) {
            if (String(this.occupiersCity).length > 80) {
                this.errormessages.push("City details must not exceed 80 characters.");
            } else {
                this.errormessages.push('Please enter value in value in City details');
            }
            this.isValidScreen1 = false;
        }
        else if ((this.occupiersPostalCode == '' || this.occupiersPostalCode == null) || String(this.occupiersPostalCode).length > 80) {
            if (String(this.occupiersPostalCode).length > 80) {
                this.errormessages.push("Postal Code details must not exceed 80 characters.");
            } else {
                this.errormessages.push('Please enter value in Postal Code details');
                this.isValidScreen1 = false;
            }
        }
        else if (this.occupiersTelephone != null && String(this.occupiersTelephone).length > 30) {
            this.errormessages.push('Please enter a valid Telephone Number.');
            this.isValidScreen1 = false;
        }
        else {
            this.isValidScreen1 = true;
        }
    }
    handleSection2Validation() {
        this.errormessages = [];
        this.isValidScreen2 = true;
        if ((this.xCoordinate == '' || this.xCoordinate == null) &&
            (this.yCoordinate == '' || this.yCoordinate == null) &&
            (this.uidProposedWork == '' || this.uidProposedWork == null)) {
            this.errormessages.push('Please enter data in all the required fields');
            this.isValidScreen2 = false;
        }
        else if (this.xCoordinate < 240000 || this.xCoordinate > 550000 || this.xCoordinate == '' || this.xCoordinate == null) {
            this.errormessages.push('Grid Ref X needs to be between 240000 and 550000');
            this.isValidScreen2 = false;
        } else if (this.yCoordinate < 170000 || this.yCoordinate > 440000 || this.yCoordinate == '' || this.yCoordinate == null) {
            this.errormessages.push('Grid Ref Y needs to be between 170000 and 440000');
            this.isValidScreen2 = false;

        } else if (String(this.uidProposedWork).length > 10 || (this.uidProposedWork == '' || this.uidProposedWork == null)) {
            if (String(this.uidProposedWork).length > 10) {
                this.errormessages.push("UID of Proposed Work must not exceed 10 characters.");
            } else {
                this.errormessages.push('Please enter value in UID of Proposed Work details');
            }
            this.isValidScreen2 = false;
        } else {
            this.isValidScreen2 = true;
        }
    }
    handleSection3Validation() {
        this.errormessages = [];
        this.isValidScreen3 = true;
        if (this.ownersName != null && String(this.ownersName).length > 80) {
            this.errormessages.push("Owner's Name must not exceed 80 characters.");
            this.isValidScreen3 = false;
        }
        else if (this.ownersHouseName != null && String(this.ownersHouseName).length > 80) {
            this.errormessages.push("House Name must not exceed 80 characters.");
            this.isValidScreen3 = false;
        }
        else if (this.ownersHouseNo != null && String(this.ownersHouseNo).length > 10) {
            this.errormessages.push("House Number must not exceed 10 characters.");
            this.isValidScreen3 = false;
        }
        else if (this.ownersStreet != null && String(this.ownersStreet).length > 80) {
            this.errormessages.push("Street must not exceed 80 characters.");
            this.isValidScreen3 = false;
        }
        else if (this.ownersTown != null && String(this.ownersTown).length > 80) {
            this.errormessages.push("Town must not exceed 80 characters.");
            this.isValidScreen3 = false;
        }
        else if (this.ownersCity != null && String(this.ownersCity).length > 80) {
            this.errormessages.push("City must not exceed 80 characters.");
            this.isValidScreen3 = false;
        }
        else if (this.ownersPostalCode != null && String(this.ownersPostalCode).length > 80) {
            this.errormessages.push("Postal Code must not exceed 80 characters.");
            this.isValidScreen3 = false;
        }
        // brajesh
        else if (this.ownersTelephone != null && String(this.ownersTelephone).length > 30) {
            this.errormessages.push('Please enter a valid Telephone Number.');
            this.isValidScreen3 = false;
        }
        else {
            this.isValidScreen3 = true;
        }
    }
    handleSection4Validation() {
        this.errormessages = [];
        this.isValidScreen4 = true;
        if (this.selectedLocation == '' || this.selectedLocation == null) {
            this.errormessages.push('Please select a value in Location');
            this.isValidScreen4 = false;
        } else {
            this.isValidScreen4 = true;
        }
    }
    handleSection5Validation() {
        this.errormessages = [];
        this.isValidScreen5 = true;
        if (this.selectedPermissionToDig == '' || this.selectedPermissionToDig == null) {
            this.errormessages.push('Please select a value in Permission To Dig');
            this.isValidScreen5 = false;
        } else {
            this.isValidScreen5 = true;
        }
    }
    handleSection6Validation() {
        this.errormessages = [];
        this.isValidScreen6 = true;
        if ((this.selectedAsset == '' || this.selectedAsset == null) &&
            (this.selectedJobRecepient == '' || this.selectedJobRecepient == null) &&
            (this.selectedJobScope == '' || this.selectedJobScope == null) &&
            (this.selectedTask == '' || this.selectedTask == null) &&
            (this.selectedTrAsset == '' || this.selectedTrAsset == null)) {
            this.errormessages.push('Please enter data in all the required fields');
            this.isValidScreen6 = false;
        }
        else if (this.selectedTask == '' || this.selectedTask == null) {
            this.errormessages.push('Please select a value in Task');
            this.isValidScreen6 = false;
        }
        else if (this.selectedAsset == '' || this.selectedAsset == null) {
            this.errormessages.push('Please select a value in Asset');
            this.isValidScreen6 = false;
        }
        else if (this.selectedJobScope == '' || this.selectedJobScope == null) {
            this.errormessages.push('Please select a value in Job Scope');
            this.isValidScreen6 = false;
        }
        else if (this.selectedTrAsset == '' || this.selectedTrAsset == null) {

            this.errormessages.push('Please select a value in Transferred Asset');
            this.isValidScreen6 = false;
        }
        else if (this.selectedJobRecepient == '' || this.selectedJobRecepient == null) {

            this.errormessages.push('Please select a value in Job Recepient');

            this.isValidScreen6 = false;
        }
        else {
            this.isValidScreen6 = true;
        }
    }
    handleSection8Validation() {

        this.errormessages = [];
        this.isValidScreen8 = true;
        if (this.manholeRef != null && String(this.manholeRef).length > 80) {
            this.errormessages.push("Manhole ref must not exceed 80 characters.");
            this.isValidScreen8 = false;
        }
        else if (this.repairLength != null && String(this.repairLength).length > 10) {
            this.errormessages.push("Repair Length (m) must not exceed 10 characters.");
            this.isValidScreen8 = false;
        }
        else if (this.repairDepth != null && String(this.repairDepth).length > 10) {
            this.errormessages.push("Repair Depth (m) must not exceed 10 characters.");
            this.isValidScreen8 = false;
        }
        else if (this.proposedWrkDetails != null && String(this.proposedWrkDetails).length > 255) {
            this.errormessages.push("Details of proposed work must not exceed 255 characters.");
            this.isValidScreen8 = false;
        }
        else if (this.selectedPriority == '' || this.selectedPriority == null) {
            this.errormessages.push('Please select a value in Priority');
            this.isValidScreen8 = false;
        }
        else {
            this.isValidScreen8 = true;
        }
    }

    handleSection10Validation() {
        this.errormessages = [];
        this.isValidScreen10 = true;
        if (this.overPumpingComments != null && String(this.overPumpingComments).length > 255) {
            this.errormessages.push('Overpumping details must not exceed 255 characters.');
            this.isValidScreen10 = false;
        }
        else if (this.tankerSupportComments != null && String(this.tankerSupportComments).length > 255) {
            this.errormessages.push("Tanker support details must not exceed 255 characters.");
            this.isValidScreen10 = false;
        }
        else {
            this.isValidScreen10 = true;
        }
    }
    handleSection11Validation() {
        this.errormessages = [];
        this.isValidScreen11 = true;
        if (this.selectedActivity == null && this.selectedSurfaceType == null) {
            this.errormessages.push('Please select a value in all the required fields');
            this.isValidScreen11 = false;
        } else if (this.selectedActivity == '' || this.selectedActivity == null) {
            this.errormessages.push('Please select a value in Activity Type');
            this.isValidScreen11 = false;
        } else if (this.selectedSurfaceType == '' || this.selectedSurfaceType == null) {
            this.errormessages.push('Please select a value in Surface Type');
            this.isValidScreen11 = false;
        }
        else {
            this.isValidScreen11 = true;
        }
    }

    validateInputFormat(value, digitsBefore, digitsAfter) {
        const regex = new RegExp(`^\\d{1,${digitsBefore}}(\\.\\d{1,${digitsAfter}})?$`);
        return regex.test(value);
    }
    handleSection12Validation() {
        this.errormessages = [];
        this.isValidScreen12 = true;
        let isValidFootwidthValue = this.validateInputFormat(this.selectedFootwayWidth, 2, 2);
        let isValidCarriagewayWidth = this.validateInputFormat(this.selectedCarriagewayWidth, 2, 2);
        if (this.selectedMethodOfWork == '' || this.selectedMethodOfWork == null) {
            this.errormessages.push('Please select a value in Method of work');
            this.isValidScreen12 = false;
        }
        else if (this.selectedRoadType == '' || this.selectedRoadType == null) {
            this.errormessages.push('Please select a value in Road Type');
            this.isValidScreen12 = false;
        }
        else if (this.selectedPedestrianLights == '' || this.selectedPedestrianLights == null) {
            this.errormessages.push('Please select a value in Pedestrian lights');
            this.isValidScreen12 = false;
        }
        else if (this.carriageway == true && (this.selectedSpeed == '' || this.selectedSpeed == null)) {
            this.errormessages.push('Please select a value in Road Speed (mph)');
            this.isValidScreen12 = false;
        }
        else if (this.selectedVisibilityMenWork == '' || this.selectedVisibilityMenWork == null) {
            this.errormessages.push('Please select a value in Visibility to Men at Work - Traffic light Head');
            this.isValidScreen12 = false;
        }

        else if ((this.selectedFootwayWidth == '' || this.selectedFootwayWidth == null) || isValidFootwidthValue === false) {
            if (isValidFootwidthValue === false) {
                this.errormessages.push("Invalid input for Footway Width (m). Use up to 2 digits before and 2 digits after the decimal.");
                this.isValidScreen12 = false;
            }
            else if (this.selectedFootwayWidth == '' || this.selectedFootwayWidth == null) {
                this.errormessages.push('Please enter value in Footway Width (m)');
                this.isValidScreen12 = false;
            }
        }

        else if ((this.selectedCarriagewayWidth == '' || this.selectedCarriagewayWidth == null) || isValidCarriagewayWidth === false) {
            if (isValidCarriagewayWidth === false) {
                this.errormessages.push("Invalid input for Carriageway width (m). Use up to 2 digits before and 2 digits after the decimal.");
                this.isValidScreen12 = false;
            }
            else if (this.selectedCarriagewayWidth == '' || this.selectedCarriagewayWidth == null) {
                this.errormessages.push('Please enter value in Carriageway width (m)');
                this.isValidScreen12 = false;
            }

        }
        else if ((this.selectedTrafficFlow == '' || this.selectedTrafficFlow == null) || String(this.selectedTrafficFlow).length > 255) {
            if (String(this.selectedTrafficFlow).length > 18) {
                this.errormessages.push("Traffic Flow must not exceed 18 characters.");
            }
            else {
                this.errormessages.push('Please enter value in Traffic Flow');
            }
            this.isValidScreen12 = false;
        }
        else if ((this.specialistTreatment == 'Yes' && (this.specialistTreatmentComments == '' || this.specialistTreatmentComments == null)) || String(this.specialistTreatmentComments).length > 500) {
            if (String(this.specialistTreatmentComments).length > 500) {
                this.errormessages.push("Specialist Treatment details must not exceed 500 characters.");
            }
            else {
                this.errormessages.push("Please enter value in Specialist Treatment details");
            }
            this.isValidScreen12 = false;
        }
        else if ((this.roadMarking == 'Yes' && (this.roadMarkingComments == '' || this.roadMarkingComments == null)) || String(this.roadMarkingComments).length > 500) {
            if (String(this.roadMarkingComments).length > 500) {
                this.errormessages.push("Road Markings details must not exceed 500 characters.");
            }
            else {
                this.errormessages.push("Please enter value in Road Markings details");
            }
            this.isValidScreen12 = false;
        }
        else if (this.trafficLightRestriction != null && String(this.trafficLightRestriction).length > 255) {
            this.errormessages.push("Traffic Light Restriction must not exceed 255 characters.");
            this.isValidScreen12 = false;
        }
        else {
            this.isValidScreen12 = true;
        }
    }
    handleSection13Validation() {
        this.errormessages = [];
        this.isValidScreen13 = true;
        if (this.selectedJobUrgent == '' || this.selectedJobUrgent == null) {
            this.errormessages.push('Please select a value in "Is the job Urgent ?"');
            this.isValidScreen13 = false;
        } else if (this.carriagewayRestriction == '' || this.carriagewayRestriction == null) {
            this.errormessages.push('Please select a value in "Carriageway Restrictions"');
            this.isValidScreen13 = false;
        }
        else if (this.selectedTrainOrTram == '' || this.selectedTrainOrTram == null) {
            this.errormessages.push('Please select a value in Train or Tram');
            this.isValidScreen13 = false;
        }
        else if (this.selectedBus == '' || this.selectedBus == null) {
            this.errormessages.push('Please select a value in Bus');
            this.isValidScreen13 = false;
        }
        else if (this.selectedCycle == '' || this.selectedCycle == null) {
            this.errormessages.push('Please select a value in Cycle');
            this.isValidScreen13 = false;
        }
        else if (this.selectedSpecialFeature == '' || this.selectedSpecialFeature == null) {
            this.errormessages.push('Please select a value in Special Feature');
            this.isValidScreen13 = false;
        }
        else if (this.selectedCommsMethod == '' || this.selectedCommsMethod == null) {
            this.errormessages.push("Please select a value in Comm's Method ");
            this.isValidScreen13 = false;
        }
        else if (this.selectedCommsType == '' || this.selectedCommsType == null) {
            this.errormessages.push("Please select a value in Comm's Type");
            this.isValidScreen13 = false;
        }
        else {
            this.isValidScreen13 = true;
        }
    }
    handleSection14Validation() {
        this.errormessages = [];
        this.isValidScreen14 = true;
        if ((this.envImpact == 'Yes' && (this.envImpactComments == '' || this.envImpactComments == null || this.envImpactComments == undefined)) || String(this.envImpactComments).length > 255) {
            if (String(this.envImpactComments).length > 255) {
                this.errormessages.push('Potential Environmental Impact details must not exceed 255 characters.');
            }
            else {
                this.errormessages.push('Please enter value in Potential Environmental Impact details');
            }
            this.isValidScreen14 = false;
        } else if (this.evnImpSite == '' || this.evnImpSite == null) {
            this.errormessages.push('Please enter value in Is there a risk to an environmental important site?');
            this.isValidScreen14 = false;
        } else {
            this.isValidScreen14 = true;
        }
    }
    handleSection15Validation() {
        this.errormessages = [];
        this.isValidScreen15 = true;
        if ((this.additionalSafetyInfo == '' || this.additionalSafetyInfo == null) || String(this.additionalSafetyInfo).length > 500) {
            if (String(this.additionalSafetyInfo).length > 500) {
                this.errormessages.push('Details and any additional safety information must not exceed 500 characters.');
            } else {
                this.errormessages.push('Please enter value in Details and any additional safety information');
            }
            this.isValidScreen15 = false;
        } else {
            this.isValidScreen15 = true;
        }
    }


    //Handle Change events 
    handleOccupiersNameChange(event) {
        this.occupiersName = event.detail.value;
    }
    handleOccupiersHouseNameChange(event) {
        this.occupiersHouseName = event.detail.value;
    }
    handleOccupiersHouseNoChange(event) {
        this.occupiersHouseNo = event.detail.value;
    }
    handleOccupiersStreetChange(event) {
        this.occupiersStreet = event.detail.value;
    }
    handleOccupiersTownChange(event) {
        this.occupiersTown = event.detail.value;
    }
    handleOccupiersCityChange(event) {
        this.occupiersCity = event.detail.value;
    }
    handleOccupiersPostalCodeChange(event) {
        this.occupiersPostalCode = event.detail.value;
    }
    handleOccupiersTelephoneChange(event) {
        this.occupiersTelephone = event.detail.value;
    }
    handlexCoordinateChange(event) {
        this.xCoordinate = event.detail.value;
    }
    handleyCoordinateChange(event) {
        this.yCoordinate = event.detail.value;
    }
    handleUidProposedWorkChange(event) {
        this.uidProposedWork = event.detail.value;
    }
    handleFWDifferentAddressChange(event) {
        this.FWDifferentAddress = event.detail.checked;
        if (this.FWDifferentAddress == true) {
            this.orderAddressUpdate = false;
        } else if (this.FWDifferentAddress == false) {
            this.ownersName = '';
            this.ownersHouseName = '';
            this.ownersHouseNo = '';
            this.ownersStreet = '';
            this.ownersTown = '';
            this.ownersCity = '';
            this.ownersPostalCode = '';
            this.ownersTelephone = '';
        }

    }
    handleOrderAddressUpdateChange(event) {
        this.orderAddressUpdate = event.detail.checked;
    }
    handleOwnersNameChange(event) {
        this.ownersName = event.detail.value;
    }
    handleOwnersHouseNameChange(event) {
        this.ownersHouseName = event.detail.value;
    }
    handleOwnersHouseNoChange(event) {
        this.ownersHouseNo = event.detail.value;
    }
    handleOwnersStreetChange(event) {
        this.ownersStreet = event.detail.value;
    }
    handleOwnersTownChange(event) {
        this.ownersTown = event.detail.value;
    }
    handleOwnersCityChange(event) {
        this.ownersCity = event.detail.value;
    }
    handleOwnersPostalCodeChange(event) {
        this.ownersPostalCode = event.detail.value;
    }
    handleOwnersTelephoneChange(event) {
        this.ownersTelephone = event.detail.value;
    }
    handleLocationChange(event) {
        this.selectedLocation = event.detail.value;

        if (this.selectedLocation != 'On Highway') {
            this.clearTmaSection();
        }

    }
    handlePermissionToDigChange(event) {
        this.selectedPermissionToDig = event.detail.value;
    }


    handleReqEquipmentChange(event) {
        this.selectedReqEquipment = event.detail.value;
    }
    handleManholeRefChange(event) {
        this.manholeRef = event.detail.value;
    }

    handleRepairLengthChange(event) {
        this.repairLength = event.detail.value;
    }
    handleRepairDepthChange(event) {
        this.repairDepth = event.detail.value;
    }

    handleProposedWrkDetailsChange(event) {
        this.proposedWrkDetails = event.detail.value;
    }
    handlePriorityChange(event) {
        this.selectedPriority = event.detail.value;
    }
    handleMondayChange(event) {
        this.Monday = event.detail.checked;
    }
    handleTuesdayChange(event) {
        this.Tuesday = event.detail.checked;
    }
    handleWednesdayChange(event) {
        this.Wednesday = event.detail.checked;
    }
    handleThursdayChange(event) {
        this.Thursday = event.detail.checked;
    }
    handleFridayChange(event) {
        this.Friday = event.detail.checked;
    }
    handleSaturdayChange(event) {
        this.Saturday = event.detail.checked;
    }
    handleSundayChange(event) {
        this.Sunday = event.detail.checked;
    }
    handleRestrictedTimeAMChange(event) {
        this.RestrictedTimeAM = event.detail.checked;
    }
    handleRestrictedTimePMChange(event) {
        this.RestrictedTimePM = event.detail.checked;
    }
    handleRestrictedTimeNightChange(event) {
        this.RestrictedTimeNight = event.detail.checked;
    }

    handleJobTracedChange(event) {
        this.isJobTracedMarked = event.detail.value;
    }
    handleManholesSewersChange(event) {
        this.manholesSewersAccessible = event.detail.value;
    }

    handleHandDigChange(event) {
        this.anyHandDig = event.detail.value;
    }
    handleOverPumpingChange(event) {
        if (event) {
            this.overPumpingRequired = event.detail.value;
        }
        this.ValuesCheck.overPumpingRequired = this.overPumpingRequired == 'Yes';
        if (this.overPumpingRequired == 'No') {
            this.overPumpingComments = '';
        }

    }
    handleOverPumpingCommentsChange(event) {
        this.overPumpingComments = event.detail.value;
    }
    handleTankerSupportChange(event) {
        if (event) {
            this.tankerSupportRequired = event.detail.value;
        }
        this.ValuesCheck.tankerSupportRequired = this.tankerSupportRequired == 'Yes';
        if (this.tankerSupportRequired == 'No') {
            this.tankerSupportComments = '';
        }
    }
    handleTankerSupportCommentsChange(event) {
        this.tankerSupportComments = event.detail.value;
    }
    handleOtherSupportOperationsChange(event) {
        if (event) {
            this.otherSupportOperations = event.detail.value;
        }
        this.ValuesCheck.otherSupportOperations = this.otherSupportOperations == 'Yes';
        if (this.otherSupportOperations == 'No') {
            this.otherSupportComments = '';
        }
    }
    handleOtherSupportCommentsChange(event) {
        this.otherSupportComments = event.detail.value;
    }
    handleActivityTypeChange(event) {
        this.selectedActivity = event.detail.value;
    }
    handleSurfaceTypeChange(event) {
        this.selectedSurfaceType = event.detail.value;
    }

    handlePedestrianWalkwayChange(event) {
        this.selectedPedestrianWalkway = event.detail.value;
    }

    handleRoadTypeChange(event) {
        this.selectedRoadType = event.detail.value;
    }

    handlePedestrianLightsChange(event) {
        this.selectedPedestrianLights = event.detail.value;
    }

    handleVisibilityMenWorkChange(event) {
        this.selectedVisibilityMenWork = event.detail.value;
    }

    handleFootwayWidthChange(event) {
        this.selectedFootwayWidth = event.detail.value;
    }

    handleCarriagewayWidthChange(event) {
        this.selectedCarriagewayWidth = event.detail.value;
    }
    handleTrafficFlowChange(event) {
        this.selectedTrafficFlow = event.detail.value;
    }

    handleselectedTrafficFlowChange(event) {
        this.selectedTrafficFlow = event.detail.value;
    }
    //     sfs-6005 
    handleMethodOfWorkChange(event) {
        this.selectedMethodOfWork = event.detail.value; //sfs-6005
    }

    handleCarriagewayChange(event) {
        this.Carriageway = event.detail.checked;
        if (this.Carriageway == true) {
            this.carriageway = true;
        } else {
            this.carriageway = false;
            this.selectedSpeed = '';
        }

    }
    handleVergeChange(event) {
        this.Verge = event.detail.checked;
    }
    handleBridlewayFootpathChange(event) {
        this.BridlewayFootpath = event.detail.checked;
    }
    handlePrivateLandChange(event) {
        this.PrivateLand = event.detail.checked;
    }
    handleFootwayChange(event) {
        this.Footway = event.detail.checked;
    }

    handleCyclewayChange(event) {
        this.Cycleway = event.detail.checked;
    }
    handlePedestrianisedZoneChange(event) {
        this.PedestrianisedZone = event.detail.checked;
    }
    // sfs-6005 end

    handleSpeedChange(event) {
        this.selectedSpeed = event.detail.value;
    }
    handleSpecialistTreatmentChange(event) {
        if (event) {
            this.specialistTreatment = event.detail.value;
        }
        this.ValuesCheck.specialistTreatment = this.specialistTreatment == 'Yes';
        if (this.specialistTreatment == 'No') {
            this.specialistTreatmentComments = '';
        }
    }
    handleSpecialistTreatmentCommentsChange(event) {
        this.specialistTreatmentComments = event.detail.value;
    }
    handleRoadMarkingChange(event) {
        if (event) {
            this.roadMarking = event.detail.value;
        }
        this.ValuesCheck.roadMarking = this.roadMarking == 'Yes';
        if (this.roadMarking == 'No') {
            this.roadMarkingComments = '';
        }
    }
    handleRoadMarkingCommentsChange(event) {
        this.roadMarkingComments = event.detail.value;
    }
    handleTrafficLights50mmChange(event) {
        this.trafficLights50mm = event.detail.value;
    }
    handletrafficLightRestrictionChange(event) {
        this.trafficLightRestriction = event.detail.value;
    }
    handleTrafficSensitiveChange(event) {
        this.selectedTrafficSensitive = event.detail.value;
    }
    handleJobUrgentChange(event) {
        this.selectedJobUrgent = event.detail.value;
    }
    handleWaitingConesChange(event) {
        this.selectedWaitingCones = event.detail.value;
    }
    handleFootwayClosureChange(event) {
        this.selectedFootwayClosure = event.detail.value;
    }
    handleParkingSuspensionChange(event) {
        this.parkingSuspension = event.detail.value;
    }
    handleCarriagewayRestrictionChange(event) {
        this.selCarriagewayRestriction = event.detail.value;
    }
    handletrainOrTramChange(event) {
        this.selectedTrainOrTram = event.detail.value;
    }

    handleBusChange(event) {
        this.selectedBus = event.target.value;
    }

    handleCycleChange(event) {
        this.selectedCycle = event.target.value;
    }

    handleSpecialFeatureChange(event) {
        this.selectedSpecialFeature = event.target.value;
    }

    handleCommsMethodChange(event) {
        this.selectedCommsMethod = event.target.value;
    }

    handleCommsTypeChange(event) {
        this.selectedCommsType = event.detail.value;
    }
    handleSiteCommentsChange(event) {
        this.selectedSiteComments = event.target.value;
    }

    handlePlanningInfoChange(event) {
        this.selectedPlanningInfo = event.target.value;
    }

    handleEnvImpactChange(event) {
        if (event) {
            this.envImpact = event.detail.value;
        }
        this.ValuesCheck.envImpact = this.envImpact == 'Yes';
        if (this.envImpact == 'No') {
            this.envImpactComments = '';
        }
    }
    handleEnvImpactCommentsChange(event) {
        this.envImpactComments = event.detail.value;
    }
    handleEvnImpSiteChange(event) {
        this.evnImpSite = event.detail.value;
    }
    handleOverheadPowerlinesChange(event) {
        if (event) {
            this.overheadPowerlines = event.detail.value;
        }
        this.ValuesCheck.overheadPowerlines = this.overheadPowerlines == 'Yes';
    }
    handleLampSupportChange(event) {
        this.lampSupport = event.detail.value;
    }
    handleConfinedSpaceChange(event) {
        this.confinedSpace = event.detail.value;
    }
    handleAdditionalSafetyInfoChange(event) {
        this.additionalSafetyInfo = event.detail.value;
    }


    get isEnableNext() {
        if (this.Screen1 == true || this.Screen2 == true || this.Screen3 == true || this.Screen4 == true || this.Screen5 == true || this.Screen6 == true ||
            this.Screen8 == true || this.Screen9 == true || this.Screen10 == true || this.Screen11 == true || this.Screen12 == true || this.Screen13 == true || this.Screen14 == true || this.Screen15 == true) {
            return true;
        }
        else {
            return false;
        }
    }
    get isLastScreen() {
        if (this.Screen16 == true) {
            return true;
        }
        else {
            return false;
        }
    }
    get isEnablePrev() {
        if (this.Screen2 == true || this.Screen3 == true || this.Screen4 == true || this.Screen5 == true || this.Screen6 == true || this.Screen8 == true ||
            this.Screen9 == true || this.Screen10 == true || this.Screen11 == true || this.Screen12 == true || this.Screen13 == true || this.Screen14 == true || this.Screen15 == true || this.Screen16 == true) {
            return true;
        }
        else {
            return false;
        }

    }
}
import { LightningElement, api, track, wire } from 'lwc';
import DCFINFRA_OBJECT from '@salesforce/schema/FSM_DataCaptureFormInfra__c';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';

const fieldnames = ["FSM_DataCaptureFormInfra__c.FSM_INFRAFWRActivityType__c", "FSM_DataCaptureFormInfra__c.FSM_RoadType__c", "FSM_DataCaptureFormInfra__c.FSM_MethodOfWork__c", "FSM_DataCaptureFormInfra__c.FSM_Speed__c", "FSM_DataCaptureFormInfra__c.FSM_FootwayWidth__c", "FSM_DataCaptureFormInfra__c.FSM_CarriagewayWidth__c",
    "FSM_DataCaptureFormInfra__c.FSM_VergeM__c", "FSM_DataCaptureFormInfra__c.FSM_VehicleRequirements__c", "FSM_DataCaptureFormInfra__c.FSM_VehiclePosition__c", "FSM_DataCaptureFormInfra__c.FSM_TrafficFlow__c", "FSM_DataCaptureFormInfra__c.FSM_SpecialFeature__c", "FSM_DataCaptureFormInfra__c.FSM_PedestrianWalkway__c",
    "FSM_DataCaptureFormInfra__c.FSM_VisibilityToMenAtWork__c", "FSM_DataCaptureFormInfra__c.FSM_PedestrianLights__c", "FSM_DataCaptureFormInfra__c.FSM_TrainOrTram__c", "FSM_DataCaptureFormInfra__c.FSM_Bus__c",
    "FSM_DataCaptureFormInfra__c.FSM_Cycle__c", "FSM_DataCaptureFormInfra__c.FSM_CarriagewayRestriction__c", "FSM_DataCaptureFormInfra__c.FSM_CarriagewaySpecification__c",
    "FSM_DataCaptureFormInfra__c.FSM_SurfaceType__c", "FSM_DataCaptureFormInfra__c.FSM_FootpathClosed__c", "FSM_DataCaptureFormInfra__c.FSM_SpecialistTreatment__c",
    "FSM_DataCaptureFormInfra__c.FSM_SpecialistTreatmentComments__c", "FSM_DataCaptureFormInfra__c.FSM_RoadMarkings__c",
    "FSM_DataCaptureFormInfra__c.FSM_RoadMarkingsComments__c", "FSM_DataCaptureFormInfra__c.FSM_IsTheLocationTrafficSensitive__c", "FSM_DataCaptureFormInfra__c.FSM_IsTheJobUrgent__c",
    "FSM_DataCaptureFormInfra__c.FSM_AreNoWaitingConesRequired__c", "FSM_DataCaptureFormInfra__c.FSM_ParkingSuspension__c", "FSM_DataCaptureFormInfra__c.FSM_TrafficLightsLessThan50m__c", "FSM_DataCaptureFormInfra__c.FSM_CommentsForTheGangs__c",
    "FSM_DataCaptureFormInfra__c.FSM_SchedulingCommentsBox__c", "FSM_DataCaptureFormInfra__c.FSM_Carriageway__c", "FSM_DataCaptureFormInfra__c.FSM_Verge__c",
    "FSM_DataCaptureFormInfra__c.FSM_BridlewayFootpath__c", "FSM_DataCaptureFormInfra__c.FSM_PrivateLand__c", "FSM_DataCaptureFormInfra__c.FSM_Footway__c",
    "FSM_DataCaptureFormInfra__c.FSM_Cycleway__c", "FSM_DataCaptureFormInfra__c.FSM_PedestrianZone__c"];


export default class Fsmtmanoticedetails extends LightningElement {
    sectionone = true;
    // sectiontwo=false;
    sectionthree = false;
    sectionfour = false;
    sectionfive = false;
    sectionsix = false;
    enableprev = true;
    datatochild = true;
    @api isEdit;
    @api recordId;
    @api executeonce;
    vergeval;
    cspec;
    ischeckedpedestrianisedzone = false;
    ischeckedcycleway = false;
    ischeckedfootway = false;
    ischeckedprivateland = false;
    ischeckedbridleway = false;
    ischeckedverge = false;
    ischeckedcarriageway = false;
    @api sectionsixenablefromparent;
    isvalidscreenone = true;
    isvalidscreentwo = true;
    isvalidscreenthree = true;
    isvalidscreenfour = true;
    isvalidscreenfive = true;
    isvalidscreensix = true;
    filteredsurftypeoptions;
    showspecialistcomments = false;
    showroadmarkingcomments = false;
    objectApiName = DCFINFRA_OBJECT;
    errormessages = [];
    savetmavalues = {};
    @api retainvalues;
    @api retainprevsecdatatma;
    activity;
    roadtype;
    methodofwork;
    speed;
    footwaywidth;
    carriagewidth;
    verge;
    vehiclereq;
    vehposition;
    //loctype;
    trafficflow;
    specialfeature;
    pedestrianwalkway;
    visibility;
    train;
    pedlights;
    bus;
    cycle;
    crestriction;
    // cspec1;
    // cspec2;
    surftype;
    footpathclosed;
    specialtreatment;
    treatment;
    roadmarkings;
    markingscomments;
    locationtraffic;
    joburgent;
    conesreq;
    parkingsuspension;
    trafficlights;
    cspec1disabled = true;
    cspec2disabled = true;
    activityoptions;
    roadtypeoptions;
    methodofworkoptions;
    speedoptions;
    vehiclereqoptions;
    vehpositionoptions;
    // loctypeoptions;
    trafficflowoptions;
    specialfeatureoptions;
    pedestrianwalkwayoptions;
    visibilityoptions;
    pedlightsoptions;
    trainoptions;
    busoptions;
    cycleoptions;
    crestrictionoptions;
    // cspec1options;
    // cspec2options;
    // cspec3options;
    surftypeoptions;
    joburgentoptions;
    coneoptions;
    //added as part of sfs-6000
    carriageaway = false;
    @track isCarriagewaySpecifVisible = false;
    // verge;
    bridleaway = false;
    privateland = false;
    footway = false;
    cycleway = false;
    pedestrianizedzone = false;
    //  gangcomm;
    //  schedulingcomm;
    vergeval = false;

    connectedCallback() {

        this.sectionsix = this.sectionsixenablefromparent;
        if (this.sectionsix == true) {
            this.sectionone = false;
        } else {
            this.sectionone = true
        }
        if (JSON.stringify(this.retainvalues) == undefined) {
            // alert('inside if')
        }
        else {
            console.log('inside connected callback tma', JSON.stringify(this.retainvalues), JSON.stringify(this.retainprevsecdatatma));
            this.retainvalues = { ...this.retainvalues, ...this.retainprevsecdatatma }
            this.activity = this.retainvalues.FSM_INFRAFWRActivityType__c;
            this.roadtype = this.retainvalues.FSM_RoadType__c;
            this.methodofwork = this.retainvalues.FSM_MethodOfWork__c;
            this.speed = this.retainvalues.FSM_Speed__c;
            this.footwaywidth = this.retainvalues.FSM_FootwayWidth__c;
            this.carriagewidth = this.retainvalues.FSM_CarriagewayWidth__c;
            this.verge = this.retainvalues.FSM_VergeM__c;
            this.vehiclereq = this.retainvalues.FSM_VehicleRequirements__c;
            this.vehposition = this.retainvalues.FSM_VehiclePosition__c;
            // this.loctype=this.retainvalues.FSM_LocationType__c;
            this.trafficflow = this.retainvalues.FSM_TrafficFlow__c;
            this.specialfeature = this.retainvalues.FSM_SpecialFeature__c;
            this.pedestrianwalkway = this.retainvalues.FSM_PedestrianWalkway__c;
            this.visibility = this.retainvalues.FSM_VisibilityToMenAtWork__c;
            this.pedlights = this.retainvalues.FSM_PedestrianLights__c;
            this.train = this.retainvalues.FSM_TrainOrTram__c;
            this.bus = this.retainvalues.FSM_Bus__c;
            this.cycle = this.retainvalues.FSM_Cycle__c;
            this.crestriction = this.retainvalues.FSM_CarriagewayRestriction__c;
            this.cspec = this.retainvalues.FSM_CarriagewaySpecification__c;
            console.log('cspec', this.cspec);
            //this.cspec1=this.retainvalues.FSM_CarriagewaySpecification1__c;
            //this.cspec2=this.retainvalues.FSM_CarriagewaySpecification2__c;
            this.surftype = this.retainvalues.FSM_SurfaceType__c;
            console.log('surftype', this.surftype);
            this.footpathclosed = this.retainvalues.FSM_FootpathClosed__c;
            this.specialtreatment = this.retainvalues.FSM_SpecialistTreatment__c;
            this.treatment = this.retainvalues.FSM_SpecialistTreatmentComments__c;
            this.roadmarkings = this.retainvalues.FSM_RoadMarkings__c;
            this.markingscomments = this.retainvalues.FSM_RoadMarkingsComments__c;
            this.locationtraffic = this.retainvalues.FSM_IsTheLocationTrafficSensitive__c;
            this.joburgent = this.retainvalues.FSM_IsTheJobUrgent__c;
            this.conesreq = this.retainvalues.FSM_AreNoWaitingConesRequired__c;
            this.parkingsuspension = this.retainvalues.FSM_ParkingSuspension__c;
            this.trafficlights = this.retainvalues.FSM_TrafficLightsLessThan50m__c;
            // this.gangcomm=this.retainvalues.FSM_CommentsForTheGangs__c;
            // this.schedulingcomm=this.retainvalues.FSM_SchedulingCommentsBox__c;

            //added as part of sfs-6000
            // let carriageawaychecked = this.template.querySelector(".carriageawaycls");
            // let vergechecked = this.template.querySelector(".vergeselectcls");
            // let bridleawaychecked = this.template.querySelector(".bridleawaycls");
            // let privatelandchecked = this.template.querySelector(".privatelandcls");
            // let footwaychecked = this.template.querySelector(".footwaycls");
            // let cyclewaychecked = this.template.querySelector(".cyclewaycls");
            // let pedestrianizedzonechecked = this.template.querySelector(".pedestrianizedzonecls");
            this.carriageaway = this.retainvalues.FSM_Carriageway__c;
            this.vergeval = this.retainvalues.FSM_Verge__c;
            this.bridleaway = this.retainvalues.FSM_BridlewayFootpath__c;
            this.privateland = this.retainvalues.FSM_PrivateLand__c;
            this.footway = this.retainvalues.FSM_Footway__c;
            this.cycleway = this.retainvalues.FSM_Cycleway__c;
            this.pedestrianizedzone = this.retainvalues.FSM_PedestrianZone__c;
            //update checkboxes as per values 
            this.ischeckedcarriageway = this.retainvalues.FSM_Carriageway__c;
            this.ischeckedverge = this.retainvalues.FSM_Verge__c;
            this.ischeckedbridleway = this.retainvalues.FSM_BridlewayFootpath__c;
            this.ischeckedprivateland = this.retainvalues.FSM_PrivateLand__c;
            this.ischeckedfootway = this.retainvalues.FSM_Footway__c;
            this.ischeckedcycleway = this.retainvalues.FSM_Cycleway__c;
            this.ischeckedpedestrianisedzone = this.retainvalues.FSM_PedestrianZone__c;
            console.log('pedestrian zone value', this.pedestrianizedzone);
            // carriageawaychecked.checked=this.retainvalues.FSM_Carriageway__c;
            // vergechecked.checked=this.retainvalues.FSM_Verge__c;
            // bridleawaychecked.checked=this.retainvalues.FSM_BridlewayFootpath__c;
            // privatelandchecked.checked=this.retainvalues.FSM_PrivateLand__c;
            // footwaychecked.checked=this.retainvalues.FSM_Footway__c;
            // cyclewaychecked.checked=this.retainvalues.FSM_Cycleway__c;
            // pedestrianizedzonechecked.checked=this.retainvalues.FSM_PedestrianZone__c;

        }



    }

    @wire(getRecord, { recordId: '$recordId', fields: fieldnames })
    tmadata({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('inside tma wire1', this.executeonce);
            if (!this.executeonce) {
                console.log('inside tma wire2', this.executeonce);
                this.activity = data.fields.FSM_INFRAFWRActivityType__c.value;
                this.roadtype = data.fields.FSM_RoadType__c.value;
                this.methodofwork = data.fields.FSM_MethodOfWork__c.value;
                this.speed = data.fields.FSM_Speed__c.value;
                this.footwaywidth = data.fields.FSM_FootwayWidth__c.value;
                this.carriagewidth = data.fields.FSM_CarriagewayWidth__c.value;
                this.verge = data.fields.FSM_VergeM__c.value;
                this.vehiclereq = data.fields.FSM_VehicleRequirements__c.value;
                this.vehposition = data.fields.FSM_VehiclePosition__c.value;
                this.trafficflow = data.fields.FSM_TrafficFlow__c.value;
                this.specialfeature = data.fields.FSM_SpecialFeature__c.value;
                this.pedestrianwalkway = data.fields.FSM_PedestrianWalkway__c.value;
                this.visibility = data.fields.FSM_VisibilityToMenAtWork__c.value;
                this.pedlights = data.fields.FSM_PedestrianLights__c.value;
                this.train = data.fields.FSM_TrainOrTram__c.value;
                this.bus = data.fields.FSM_Bus__c.value;
                this.cycle = data.fields.FSM_Cycle__c.value;
                this.crestriction = data.fields.FSM_CarriagewayRestriction__c.value;
                console.log('commented----->', this.crestriction);
                // this.cspecfilteredoptions=this.cspecoptions;
                // this.handleChangecarriagewayrestriction();

                this.cspec = data.fields.FSM_CarriagewaySpecification__c.value;
                console.log('cspec----->', this.cspec);

                this.surftype = data.fields.FSM_SurfaceType__c.value;
                console.log('surftype-------->', this.surftype);
                this.footpathclosed = data.fields.FSM_FootpathClosed__c.value;
                this.specialtreatment = data.fields.FSM_SpecialistTreatment__c.value;
                this.treatment = data.fields.FSM_SpecialistTreatmentComments__c.value;
                this.roadmarkings = data.fields.FSM_RoadMarkings__c.value;
                this.markingscomments = data.fields.FSM_RoadMarkingsComments__c.value;
                this.locationtraffic = data.fields.FSM_IsTheLocationTrafficSensitive__c.value;
                this.joburgent = data.fields.FSM_IsTheJobUrgent__c.value;
                this.conesreq = data.fields.FSM_AreNoWaitingConesRequired__c.value;
                this.parkingsuspension = data.fields.FSM_ParkingSuspension__c.value;
                this.trafficlights = data.fields.FSM_TrafficLightsLessThan50m__c.value;
                // this.gangcomm=data.fields.FSM_CommentsForTheGangs__c.value;
                // this.schedulingcomm=data.fields.FSM_SchedulingCommentsBox__c.value;
                this.carriageaway = data.fields.FSM_Carriageway__c.value;
                this.vergeval = data.fields.FSM_Verge__c.value;
                this.bridleaway = data.fields.FSM_BridlewayFootpath__c.value;
                this.privateland = data.fields.FSM_PrivateLand__c.value;
                this.footway = data.fields.FSM_Footway__c.value;
                this.cycleway = data.fields.FSM_Cycleway__c.value;
                this.pedestrianizedzone = data.fields.FSM_PedestrianZone__c.value;
                // //update checkboxes as per values 
                this.ischeckedcarriageway = data.fields.FSM_Carriageway__c.value;
                this.ischeckedverge = data.fields.FSM_Verge__c.value;
                this.ischeckedbridleway = data.fields.FSM_BridlewayFootpath__c.value;
                this.ischeckedprivateland = data.fields.FSM_PrivateLand__c.value;
                this.ischeckedfootway = data.fields.FSM_Footway__c.value;
                this.ischeckedcycleway = data.fields.FSM_Cycleway__c.value;
                this.ischeckedpedestrianisedzone = data.fields.FSM_PedestrianZone__c.value;

            }
        }
    }


    //0122z000002cefnAAA dev

    @wire(getPicklistValuesByRecordType, { objectApiName: 'FSM_DataCaptureFormInfra__c', recordTypeId: '012000000000000AAA' })
    dcfinfrapicklistvalues({ error, data }) {
        if (data) {
            this.activityoptions = data.picklistFieldValues.FSM_INFRAFWRActivityType__c.values;
            this.roadtypeoptions = data.picklistFieldValues.FSM_RoadType__c.values;
            this.methodofworkoptions = data.picklistFieldValues.FSM_MethodOfWork__c.values;
            this.speedoptions = data.picklistFieldValues.FSM_Speed__c.values;
            this.vehiclereqoptions = data.picklistFieldValues.FSM_VehicleRequirements__c.values;
            this.vehpositionoptions = data.picklistFieldValues.FSM_VehiclePosition__c.values;
            // this.loctypeoptions=data.picklistFieldValues.FSM_LocationType__c.values;
            this.trafficflowoptions = data.picklistFieldValues.FSM_TrafficFlow__c.values;
            this.specialfeatureoptions = data.picklistFieldValues.FSM_SpecialFeature__c.values;
            this.pedestrianwalkwayoptions = data.picklistFieldValues.FSM_PedestrianWalkway__c.values;
            this.visibilityoptions = data.picklistFieldValues.FSM_VisibilityToMenAtWork__c.values;
            this.pedlightsoptions = data.picklistFieldValues.FSM_PedestrianLights__c.values;
            this.trainoptions = data.picklistFieldValues.FSM_TrainOrTram__c.values;
            this.busoptions = data.picklistFieldValues.FSM_Bus__c.values;
            this.cycleoptions = data.picklistFieldValues.FSM_Cycle__c.values;
            this.crestrictionoptions = data.picklistFieldValues.FSM_CarriagewayRestriction__c.values;
            this.cspecoptions = data.picklistFieldValues.FSM_CarriagewaySpecification__c.values;
            //this.cspec2options=data.picklistFieldValues.FSM_CarriagewaySpecification2__c.values;
            this.surftypeoptions = data.picklistFieldValues.FSM_SurfaceType__c.values;
            //this.filteredsurftypeoptions=[...this.surftypeoptions];
            this.joburgentoptions = data.picklistFieldValues.FSM_IsTheJobUrgent__c.values;
            this.coneoptions = data.picklistFieldValues.FSM_AreNoWaitingConesRequired__c.values;

        }

    }


    savesectiononevalues() {


        this.savetmavalues.FSM_INFRAFWRActivityType__c = this.activity;
        this.savetmavalues.FSM_RoadType__c = this.roadtype;
        this.savetmavalues.FSM_MethodOfWork__c = this.methodofwork;
        this.savetmavalues.FSM_Speed__c = this.speed;
        this.savetmavalues.FSM_FootwayWidth__c = this.footwaywidth;
        this.savetmavalues.FSM_CarriagewayWidth__c = this.carriagewidth;
        this.savetmavalues.FSM_VergeM__c = this.verge;
        this.savetmavalues.FSM_VehicleRequirements__c = this.vehiclereq;
        this.savetmavalues.FSM_VehiclePosition__c = this.vehposition;
        //this.savetmavalues.FSM_LocationType__c=this.loctype;
        this.savetmavalues.FSM_TrafficFlow__c = this.trafficflow;
        this.savetmavalues.FSM_SpecialFeature__c = this.specialfeature;
        this.savetmavalues.FSM_PedestrianWalkway__c = this.pedestrianwalkway;
        this.savetmavalues.FSM_VisibilityToMenAtWork__c = this.visibility;
        this.savetmavalues.FSM_PedestrianLights__c = this.pedlights;
        this.savetmavalues.FSM_TrainOrTram__c = this.train;
        this.savetmavalues.FSM_Bus__c = this.bus;
        this.savetmavalues.FSM_Cycle__c = this.cycle;
        this.savetmavalues.FSM_CarriagewayRestriction__c = this.crestriction;
        this.savetmavalues.FSM_CarriagewaySpecification__c = this.cspec;
        // this.savetmavalues.FSM_CarriagewaySpecification1__c=this.cspec1;
        // this.savetmavalues.FSM_CarriagewaySpecification2__c=this.cspec2;
        this.savetmavalues.FSM_SurfaceType__c = this.surftype;
        this.savetmavalues.FSM_FootpathClosed__c = this.footpathclosed;
        this.savetmavalues.FSM_SpecialistTreatment__c = this.specialtreatment;
        this.savetmavalues.FSM_SpecialistTreatmentComments__c = this.treatment;
        this.savetmavalues.FSM_RoadMarkings__c = this.roadmarkings;
        this.savetmavalues.FSM_RoadMarkingsComments__c = this.markingscomments;
        this.savetmavalues.FSM_IsTheLocationTrafficSensitive__c = this.locationtraffic;
        this.savetmavalues.FSM_IsTheJobUrgent__c = this.joburgent;
        this.savetmavalues.FSM_AreNoWaitingConesRequired__c = this.conesreq;
        this.savetmavalues.FSM_ParkingSuspension__c = this.parkingsuspension;
        this.savetmavalues.FSM_TrafficLightsLessThan50m__c = this.trafficlights;
        //added as part of sfs-6000
        this.savetmavalues.FSM_Carriageway__c = this.carriageaway;

        this.savetmavalues.FSM_Verge__c = this.vergeval;
        //this.savetmavalues.FSM_Verge__c=this.vergeval;
        this.savetmavalues.FSM_BridlewayFootpath__c = this.bridleaway;
        this.savetmavalues.FSM_PrivateLand__c = this.privateland;
        this.savetmavalues.FSM_Footway__c = this.footway;
        this.savetmavalues.FSM_Cycleway__c = this.cycleway;
        this.savetmavalues.FSM_PedestrianZone__c = this.pedestrianizedzone;
        // this.savetmavalues.FSM_CommentsForTheGangs__c=this.gangcomm;
        // this.savetmavalues.FSM_SchedulingCommentsBox__c=this.schedulingcomm;


    }



    handlePrevious() {
        if (this.sectionone) {
            this.savesectiononevalues();
            this.passToParent();

            // return; // already at the first component, do nothing
            // } else if (this.sectiontwo) {
            //     this.savesectiononevalues();
            //     this.errormessages=[];
            //     this.sectionone = true;
            //     this.sectiontwo = false;
            //     this.sectionthree=false;
            //     this.sectionfour=false;
            //     this.sectionfive=false;
            //     this.sectionsix=false;

        } else if (this.sectionthree) {
            this.savesectiononevalues();
            this.errormessages = [];
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = true;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;

        } else if (this.sectionfour) {
            this.savesectiononevalues();
            this.errormessages = [];
            this.sectiontwo = false;
            this.sectionthree = true;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = false;
            this.sectionsix = false;

        } else if (this.sectionfive) {
            //this.nextdisabled=true;
            this.savesectiononevalues();
            this.errormessages = [];
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = true;
            this.sectionfive = false;
            this.sectionsix = false;

        } else if (this.sectionsix) {
            console.log('inside handle prev 6', this.isEdit);
            if (this.isEdit) {
                //this.handleChangecarriagewayrestriction();
                //  this.cspecfilteredoptions=this.cspecoptions;
                console.log('isEdit inside tma 1----->', this.crestriction);
                if (this.crestriction == 'Stop-go boards (2 way control - 3 way control - 4 way control)') {
                    this.isCarriagewaySpecifVisible = true;
                    this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                        // Example: Return options that include either 'value1' or 'value2' in their value
                        return option.value.includes('2 way control') || option.value.includes('3 way control') || option.value.includes('4 way control');
                    })

                } else if (this.crestriction == 'Lane closure (Speed up to 40mph - Speed over 40mph)') {
                    this.isCarriagewaySpecifVisible = true;
                    this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                        // Example: Return options that include either 'value1' or 'value2' in their value
                        return option.value.includes('speed upto 40 mph') || option.value.includes('speed over 40 mph');
                    })
                    // this.cspec2disabled=false;
                    // this.cspec1disabled=true;
                    // this.cspec1='';
                } else if (this.crestriction == 'Road closure (20 diversion signs - 60 Diversion signs)') {
                    this.isCarriagewaySpecifVisible = true;
                    this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                        return option.value.includes('20 diversion signs') || option.value.includes('60 diversion signs');
                    })

                } else {
                    this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                        return option.value == 'Null';
                    })

                }

                this.filteredsurftypeoptions = this.surftypeoptions;

                // this.cspecfilteredoptions=this.cspecoptions;
                // this.filteredsurftypeoptions=this.surftypeoptions;
            }

            this.errormessages = [];
            this.savesectiononevalues();
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone = false;
            this.sectionfour = false;
            this.sectionfive = true;
            this.sectionsix = false;

        }
    }

    handleNext() {
        if (this.sectionone) {
            this.savesectiononevalues();
            //this.validateFields();
            this.sectioneonevalid();

            if (this.isvalidscreenone) {

                this.sectionone = false;
                this.sectiontwo = false;
                this.sectionthree = true;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = false;


            } else {
                console.log('error in sec one');
                //this.ShowToastEvent("test error");
            }

            //    }else if(this.sectiontwo){

            //     this.sectiontwovalid();

            //   if(this.isvalidscreentwo){
            //     console.log('inside handlenext this.isvalidscreentwo',this.isvalidscreentwo);

            //     this.sectionthree = true;
            //     this.sectiontwo = false;
            //     this.sectionone = false;
            //     this.sectionfour=false;
            //     this.sectionfive=false;
            //     this.sectionsix=false;

            //     this.savesectiononevalues();
            //     }else{
            //         console.log('error in sec two');
            //     }
            //   
        } else if (this.sectionthree) {
            this.savesectiononevalues();
            this.sectionthreevalid();
            if (this.isvalidscreenthree) {
                this.sectionthree = false;
                this.sectiontwo = false;
                this.sectionone = false;
                this.sectionfour = true;
                this.sectionfive = false;
                this.sectionsix = false;
            } else {
                console.log('error in sec three');
            }

        } else if (this.sectionfour) {
            this.savesectiononevalues();
            this.sectionfourvalid();
            console.log('isEdit inside tma next----->', this.isEdit);
            if (this.isEdit) {
                //this.handleChangecarriagewayrestriction();
                //  this.cspecfilteredoptions=this.cspecoptions;
                console.log('isEdit inside tma 1----->', this.crestriction);
                if (this.crestriction == 'Stop-go boards (2 way control - 3 way control - 4 way control)') {
                    this.isCarriagewaySpecifVisible = true;
                    this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                        // Example: Return options that include either 'value1' or 'value2' in their value
                        return option.value.includes('2 way control') || option.value.includes('3 way control') || option.value.includes('4 way control');
                    })

                } else if (this.crestriction == 'Lane closure (Speed up to 40mph - Speed over 40mph)') {
                    this.isCarriagewaySpecifVisible = true;
                    this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                        // Example: Return options that include either 'value1' or 'value2' in their value
                        return option.value.includes('speed upto 40 mph') || option.value.includes('speed over 40 mph');
                    })
                    // this.cspec2disabled=false;
                    // this.cspec1disabled=true;
                    // this.cspec1='';
                } else if (this.crestriction == 'Road closure (20 diversion signs - 60 Diversion signs)') {
                    this.isCarriagewaySpecifVisible = true;
                    this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                        return option.value.includes('20 diversion signs') || option.value.includes('60 diversion signs');
                    })

                } else {

                    this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                        return option.value == 'Null';
                    })

                }

                this.filteredsurftypeoptions = this.surftypeoptions;
            }

            if (this.isvalidscreenfour) {
                this.filtersurfactypeoptions();
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = true;
                this.sectionsix = false;
            } else {


            }

        } else if (this.sectionfive) {

            this.savesectiononevalues();
            this.sectionfivevalid();
            if (this.isvalidscreenfive) {
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone = false;
                this.sectionfour = false;
                this.sectionfive = false;
                this.sectionsix = true;
            }



        }
        else if (this.sectionsix) {
            this.savesectiononevalues();
            this.sectionsixvalid();
            if (this.isvalidscreensix) {
                this.enablesectionnineofparent();
            }
            else {

            }

        }

        // this.issubmitenable=true;


    }
    get isEnableNext() {

        return true;

    }
    validateInputFormat(value, digitsBefore, digitsAfter) {
        const regex = new RegExp(`^\\d{1,${digitsBefore}}(\\.\\d{1,${digitsAfter}})?$`);
        return regex.test(value);
    }

    sectioneonevalid() {
        this.isvalidscreenone = true;
        let footwayvalid = this.template.querySelector(".footwaywidthcls");
        let activitytyp = this.template.querySelector(".activitycls");
        let methodofwrkval = this.template.querySelector(".methodofworkcls");
        let speedval = this.template.querySelector(".speedcls");
        let roadtypeval = this.template.querySelector(".roadtypecls");
        let carraiagevalid = this.template.querySelector(".carriagewidthcls");
        let vergevalid = this.template.querySelector(".vergecls");
        let isValidCarriagewayWidth = this.validateInputFormat(carraiagevalid.value, 2, 2);
        let isValidFootwidthValue = this.validateInputFormat(footwayvalid.value, 2, 2);
        let isValidVergeValue = this.validateInputFormat(vergevalid.value, 2, 2);
        this.errormessages = [];
        if (activitytyp.value == null || methodofwrkval.value == null || speedval.value == null || roadtypeval.value == null ||
            activitytyp.value == '' || methodofwrkval.value == '' || speedval.value == '' || roadtypeval.value == '') {
            this.errormessages.push('Please fill in all fields marked mandatory');
            this.isvalidscreenone = false;
        }

        else if (footwayvalid.value < 0 || footwayvalid.value > 25 || footwayvalid.value == '' || footwayvalid.value == null) {
            this.errormessages.push('Footway width should lie between 0 and 25');
            this.isvalidscreenone = false;
        }
        else if (isValidFootwidthValue === false) {
            this.errormessages.push("Invalid input for Footway Width (m). Use up to 2 digits before and 2 digits after the decimal.");
            this.isvalidscreenone = false;
        }
        
        else if (carraiagevalid.value < 0 || carraiagevalid.value > 25 || carraiagevalid.value == '' || carraiagevalid.value == null) {
            this.errormessages.push('Carriageway width should lie between 0 and 25');
            this.isvalidscreenone = false;
        }
        else if (isValidCarriagewayWidth === false) {
            this.errormessages.push("Invalid input for Carriageway width (m). Use up to 2 digits before and 2 digits after the decimal.");
            this.isvalidscreenone = false;
        }

        else if (vergevalid.value < 0 || vergevalid.value > 27 || vergevalid.value == '' || vergevalid.value == null ||isValidVergeValue === false) {
            if (isValidVergeValue === false) {
                this.errormessages.push("Invalid input for Verge (M). Use up to 2 digits before and 2 digits after the decimal.");
                this.isvalidscreenone = false;
            }
            else{
                this.errormessages.push('Verge should lie between 0 and 27');
                this.isvalidscreenone = false;
            }
            
        }
        
    }
    sectiontwovalid() {
        //alert('inside validate second section');
        //isvalidscreentwo=true;
        let carraiagevalid = this.template.querySelector(".carriagewidthcls");
        let isValidCarriagewayWidth = this.validateInputFormat(carraiagevalid.value, 2, 2);
        let vergevalid = this.template.querySelector(".vergecls");
        this.errormessages = [];
        if (carraiagevalid.value < 0 || carraiagevalid.value > 25 || carraiagevalid.value == '' || carraiagevalid.value == null || isValidCarriagewayWidth === false) {
            if (isValidCarriagewayWidth === false) {
                this.errormessages.push("Invalid input for Carriageway width (m). Use up to 2 digits before and 2 digits after the decimal.");
                this.isvalidscreentwo = false;
            }
            else {
                this.errormessages.push('Carriageway width should lie between 0 and 25');
                this.isvalidscreentwo = false;
            }

        }


        else {
            this.isvalidscreentwo = true;
        }
        if (vergevalid.value < 0 || vergevalid.value > 27 || vergevalid.value == '' || vergevalid.value == null) {
            this.errormessages.push('Verge should lie between 0 and 27');
            this.isvalidscreentwo = false;
        } else {
            this.isvalidscreentwo = true;
        }
        console.log('inside validation function', this.isvalidscreentwo);
    }

    sectionthreevalid() {
        this.isvalidscreenthree = true;
        this.errormessages = [];
        let vehpositionval = this.template.querySelector(".vehpositioncls");
        // let locval = this.template.querySelector(".loctypecls");
        let trafficflowval = this.template.querySelector(".trafficflowcls");
        let specialfeatureval = this.template.querySelector(".specialfeaturecls");
        if (vehpositionval.value == null || trafficflowval.value == null || specialfeatureval.value == null ||
            vehpositionval.value == '' || trafficflowval.value == '' || specialfeatureval.value == '') {
            this.errormessages.push('Please fill in all fields marked mandatory');
            this.isvalidscreenthree = false;
        }
    }
    sectionfourvalid() {
        this.isvalidscreenfour = true;
        this.errormessages = [];
        let pedestrianwalkwayval = this.template.querySelector(".pedestrianwalkwaycls");
        let visibilityval = this.template.querySelector(".visibilitycls");
        let pedlightsval = this.template.querySelector(".pedlightscls");
        let trainval = this.template.querySelector(".traincls");
        let busval = this.template.querySelector(".buscls");
        let cycleval = this.template.querySelector(".cyclecls");
        if (busval.value == null || cycleval.value == null || pedestrianwalkwayval.value == null || visibilityval.value == null || pedlightsval.value == null || trainval.value == null ||
            pedestrianwalkwayval.value == '' || visibilityval.value == '' || busval.value == '' || cycleval.value == '' || pedlightsval.value == '' || trainval.value == '') {
            this.errormessages.push('Please fill in all fields marked mandatory');
            this.isvalidscreenfour = false;
        }
    }

    sectionfivevalid() {
        this.isvalidscreenfive = true;
        this.errormessages = [];
        let crestrictionval = this.template.querySelector(".crestrictioncls");
        let surftypeval = this.template.querySelector(".surftypecls");
        let footpathclosedval = this.template.querySelector(".footpathclosedcls");
        if (crestrictionval.value == null || surftypeval.value == null || footpathclosedval.value == null ||
            crestrictionval.value == '' || surftypeval.value == '' || footpathclosedval.value == '') {
            this.errormessages.push('Please fill in all fields marked mandatory');
            this.isvalidscreenfive = false;
        }

    }

    sectionsixvalid() {
        this.isvalidscreensix = true;
        this.errormessages = [];
        let specialtreatmentval = this.template.querySelector(".specialtreatmentcls");
        let roadmarkingval = this.template.querySelector(".roadmarkingscls");
        let locationtrafficval = this.template.querySelector(".locationtrafficcls");
        let joburgentval = this.template.querySelector(".joburgentcls");
        let conesreqval = this.template.querySelector(".conesreqcls");
        let parkingsuspensionval = this.template.querySelector(".parkingsuspensioncls");
        let trafficlightsval = this.template.querySelector(".trafficlightscls");
        if (specialtreatmentval.value == null || trafficlightsval.value == null || roadmarkingval.value == null || locationtrafficval.value == null || joburgentval.value == null || conesreqval.value == null || parkingsuspensionval.value == null ||
            specialtreatmentval.value == '' || trafficlightsval.value == '' || roadmarkingval.value == '' || locationtrafficval.value == '' || joburgentval.value == '' || conesreqval.value == '' || parkingsuspensionval.value == '') {
            this.errormessages.push('Please fill in all fields marked mandatory');
            this.isvalidscreensix = false;
        }
    }
    handleChangecarriagewayrestriction(event) {
        if (event) {
            console.log('inside if cres', this.cspec);
            this.carraigeawayselect = event.target.value;

            this.crestriction = event.target.value;


            if (this.carraigeawayselect == 'Stop-go boards (2 way control - 3 way control - 4 way control)') {
                this.isCarriagewaySpecifVisible = true;
                this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                    // Example: Return options that include either 'value1' or 'value2' in their value
                    return option.value.includes('2 way control') || option.value.includes('3 way control') || option.value.includes('4 way control');
                })

            } else if (this.carraigeawayselect == 'Lane closure (Speed up to 40mph - Speed over 40mph)') {
                this.isCarriagewaySpecifVisible = true;
                this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                    // Example: Return options that include either 'value1' or 'value2' in their value
                    return option.value.includes('speed upto 40 mph') || option.value.includes('speed over 40 mph');
                })
                // this.cspec2disabled=false;
                // this.cspec1disabled=true;
                // this.cspec1='';
            } else if (this.carraigeawayselect == 'Road closure (20 diversion signs - 60 Diversion signs)') {
                this.isCarriagewaySpecifVisible = true;
                this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                    return option.value.includes('20 diversion signs') || option.value.includes('60 diversion signs');
                })

            } else {
                this.isCarriagewaySpecifVisible = false;
                this.cspec = null;
                this.cspecfilteredoptions = this.cspecoptions.filter(option => {
                    return option.value == 'Null';
                })

            }
        }
        else {
            console.log('inside else cres', this.cspec);
        }
    }

    specialtreatmentchange(event) {

        this.specialvalue = event.target.value;
        this.specialtreatment = this.specialvalue;
        if (this.specialvalue == 'Yes') {
            this.showspecialistcomments = true;
        }
        if (this.specialvalue == 'No') {
            this.showspecialistcomments = false;
        }
    }

    roadmarkingchange(event) {

        this.roadmarkingvalue = event.target.value;
        this.roadmarkings = event.target.value;
        if (this.roadmarkingvalue == 'Yes') {
            this.showroadmarkingcomments = true;
        }
        if (this.roadmarkingvalue == 'No') {
            this.showroadmarkingcomments = false;
        }
    }

    passToParent() {
        console.log('edit from tma1', this.isEdit);
        if (this.isEdit) {
            console.log('edit from tma2', this.isEdit);
            this.savetmavalues.isvisited = true;
            console.log('edit from tma3', this.savetmavalues);
        }

        this.dispatchEvent(new CustomEvent('previousbutton', {
            detail: this.savetmavalues
        }));

    }

    enablesectionnineofparent() {

        this.dispatchEvent(new CustomEvent('nextbutton', {
            detail: this.savetmavalues
        }));

    }



    @api retainvaluesonprev(valuesfromparent) {
        //  alert('inside child method');

        this.retainvalues = { ...valuesfromparent }


    }

    @api prevfromphotocapture(valuesfromfwr) {
        const tmadatainp = JSON.parse(JSON.stringify(valuesfromfwr));
        this.tmadata = tmadatainp.dcfdata;

        // this.gangcomm=this.tmadata.FSM_CommentsForTheGangs__c;
        // this.schedulingcomm=this.tmadata.FSM_SchedulingCommentsBox__c;

        this.activity = this.tmadata.FSM_INFRAFWRActivityType__c;

        this.roadtype = this.tmadata.FSM_RoadType__c;

        this.methodofwork = this.tmadata.FSM_MethodOfWork__c;

        this.speed = this.tmadata.FSM_Speed__c;

        this.footwaywidth = this.tmadata.FSM_FootwayWidth__c;

        this.carriagewidth = this.tmadata.FSM_CarriagewayWidth__c;

        this.verge = this.tmadata.FSM_VergeM__c;

        this.vehiclereq = this.tmadata.FSM_VehicleRequirements__c;

        this.vehposition = this.tmadata.FSM_VehiclePosition__c;

        //  this.loctype=this.tmadata.FSM_LocationType__c;

        this.trafficflow = this.tmadata.FSM_TrafficFlow__c;

        this.specialfeature = this.tmadata.FSM_SpecialFeature__c;

        this.pedestrianwalkway = this.tmadata.FSM_PedestrianWalkway__c;

        this.visibility = this.tmadata.FSM_VisibilityToMenAtWork__c;

        this.pedlights = this.tmadata.FSM_PedestrianLights__c;

        this.train = this.tmadata.FSM_TrainOrTram__c;

        this.bus = this.tmadata.FSM_Bus__c;

        this.cycle = this.tmadata.FSM_Cycle__c;

        this.crestriction = this.tmadata.FSM_CarriagewayRestriction__c;
        console.log('picklist vals', this.cspecoptions);
        // this.handleChangecarriagewayrestriction();
        //this.cspecfilteredoptions=this.cspecoptions;

        this.cspec = this.tmadata.FSM_CarriagewaySpecification__c;



        console.log('prevfromphotocapture- tma cspec---->', this.cspec);
        //this.cspec1=this.tmadata.FSM_CarriagewaySpecification1__c;

        //this.cspec2=this.tmadata.FSM_CarriagewaySpecification2__c;

        this.surftype = this.tmadata.FSM_SurfaceType__c;
        console.log('prevfromphotocapture- tma---->', this.surftype);

        this.footpathclosed = this.tmadata.FSM_FootpathClosed__c;

        this.specialtreatment = this.tmadata.FSM_SpecialistTreatment__c;

        this.treatment = this.tmadata.FSM_SpecialistTreatmentComments__c;

        this.roadmarkings = this.tmadata.FSM_RoadMarkings__c;

        this.markingscomments = this.tmadata.FSM_RoadMarkingsComments__c;

        this.locationtraffic = this.tmadata.FSM_IsTheLocationTrafficSensitive__c;

        this.joburgent = this.tmadata.FSM_IsTheJobUrgent__c;

        this.conesreq = this.tmadata.FSM_AreNoWaitingConesRequired__c;

        this.parkingsuspension = this.tmadata.FSM_ParkingSuspension__c;

        this.trafficlights = this.tmadata.FSM_TrafficLightsLessThan50m__c;

        this.vergeval = this.tmadata.FSM_Verge__c;

    }

    handleChangeactivity(event) {
        this.activity = event.detail.value;
    }
    handleChangeroadtype(event) {
        this.roadtype = event.detail.value;
    }
    handleChangemethodofwork(event) {
        this.methodofwork = event.detail.value;

    }
    handleChangspeed(event) {
        this.speed = event.detail.value;
    }
    handlefootwaywidthchange(event) {
        this.footwaywidth = event.detail.value;
    }
    handlecarriagewidthchange(event) {
        this.carriagewidth = event.detail.value;
    }
    handlevergechange(event) {
        this.verge = event.detail.value;
    }
    handleChangevehiclereq(event) {
        this.vehiclereq = event.detail.value;
    }
    handleChangevehposition(event) {
        this.vehposition = event.detail.value;

    }
    // handleChangeloctype(event){
    //     this.loctype=event.detail.value;
    // }
    handleChangetrafficflow(event) {
        this.trafficflow = event.detail.value;
    }
    handleChangespecialfeature(event) {
        this.specialfeature = event.detail.value;
    }
    handleChangepedestrianwalkway(event) {
        this.pedestrianwalkway = event.detail.value;
    }
    handleChangevisibility(event) {
        this.visibility = event.detail.value;
    }
    handleChangepedlights(event) {
        this.pedlights = event.detail.value;
    }
    handleChangetrain(event) {
        this.train = event.detail.value;
    }
    handleChangebus(event) {
        this.bus = event.detail.value;
    }
    handleChangecycle(event) {
        this.cycle = event.detail.value;
    }

    handlecspecchange(event) {
        console.log('outside if', this.cspec);
        if (event) {
            console.log('inside if', this.cspec);
            this.cspec = event.detail.value;
        }

    }
    // handlecspec2change(event){
    //     this.cspec2=event.detail.value;
    // }
    handlesurftypechange(event) {
        this.surftype = event.detail.value;
    }
    handlefootpathclosedchange(event) {
        this.footpathclosed = event.detail.value;
    }
    get yesnooptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },

        ];
    }

    handletreatmentchange(event) {
        this.treatment = event.detail.value;
    }
    handlemarkingscommentschange(event) {
        this.markingscomments = event.detail.value;
    }
    handlelocationtrafficchange(event) {
        this.locationtraffic = event.detail.value;
    }
    handlejoburgentchange(event) {
        this.joburgent = event.detail.value;
    }
    handleconesreqchange(event) {
        this.conesreq = event.detail.value;
    }
    handleparkingsuspensionchange(event) {
        this.parkingsuspension = event.detail.value;
    }
    handletrafficlightschange(event) {
        this.trafficlights = event.detail.value;
    }
    //added as part of sfs-6000
    handleChangecarriageaway(event) {
        this.carriageaway = event.detail.checked;
        this.ischeckedcarriageway = this.carriageaway;
    }
    handleChangevergeselect(event) {
        this.vergeval = event.detail.checked;
        this.ischeckedverge = this.vergeval;
        // if(this.verge){
        //     this.surftypeoptions=this.surftypeoptions.filter(option => {

        //         return option.value=='Grass' || option.value =='Unmade';
        //     })
        // }else{
        //     this.surftypeoptions=this.surftypeoptions.filter(option => {

        //         return option.value !='Grass' || option.value !='Unmade';
        //     })
        // }
    }
    handleChangebridleaway(event) {
        this.bridleaway = event.detail.checked;
        this.ischeckedbridleway = this.bridleaway;
    }
    handleChangeprivateland(event) {
        this.privateland = event.detail.checked;
        this.ischeckedprivateland = this.privateland;
    }
    handleChangefootway(event) {
        this.footway = event.detail.checked;
        this.ischeckedfootway = this.footway;
    }
    handleChangecycleway(event) {
        this.cycleway = event.detail.checked;
        this.ischeckedcycleway = this.cycleway;
    }
    handleChangepedestrianizedzone(event) {
        this.pedestrianizedzone = event.detail.checked;
        this.ischeckedpedestrianisedzone = this.pedestrianizedzone;
    }
    // handleschcommchange(event){
    // this.schedulingcomm=event.detail.value;
    // }
    // handlegangcommchange(event){
    //     this.gangcomm=event.detail.value;
    //     }
    filtersurfactypeoptions() {
        console.log('this.vergeval', this.vergeval, this.carriageaway, this.bridleaway, this.privateland, this.footway, this.cycleway, this.pedestrianizedzone);
        if (this.vergeval == true && this.carriageaway == false && this.bridleaway == false && this.privateland == false && this.footway == false && this.cycleway == false && this.pedestrianizedzone == false) {
            console.log('inside if');
            this.filteredsurftypeoptions = this.surftypeoptions.filter(option => {

                return option.value == 'Grass' || option.value == 'Unmade';
            })
        } else {
            console.log('inside else', this.surftype);
            this.filteredsurftypeoptions = [...this.surftypeoptions];

        }
    }
}
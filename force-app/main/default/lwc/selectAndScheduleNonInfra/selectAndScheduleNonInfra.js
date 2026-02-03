import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import POST_CODE from '@salesforce/schema/ServiceAppointment.PostalCode';
import TerritoryId from '@salesforce/schema/ServiceAppointment.ServiceTerritoryId';
import WORK_ORDER_ID from '@salesforce/schema/ServiceAppointment.FSSK__FSK_Work_Order__c';
import ASSIGNED_SR from '@salesforce/schema/ServiceAppointment.FSSK__FSK_Assigned_Service_Resource__c';
import searchSA from '@salesforce/apex/FSM_SelectAndSchedule.searchSA';
import SCHEDULINGPOLICY from '@salesforce/schema/ServiceAppointment.FSL__Scheduling_Policy_Used__c';
import getServiceAppointment from '@salesforce/apex/FSM_SelectAndSchedule.getServiceAppointment';
import scheduleAndDispatchSA from '@salesforce/apex/FSM_SelectAndSchedule.scheduleAndDispatchSA';




const FIELDS = [
    POST_CODE,
    TerritoryId,
    WORK_ORDER_ID,
    ASSIGNED_SR,
    SCHEDULINGPOLICY
];


export default class SelectAndScheduleNonInfra extends LightningElement {
    @api recordId;
    appointments = []; // To store SAs of based on filter criteria
    submitValues = {}; // To store values of Resource Pref Record

    connectedCallback() {
        this.getApplyFilterScreenData();
        this.filteredAppointments;
        this.appointments;
        searchSA({ saId: this.recordId, selectedFilters: this.filterValue })
    }
    // screen 3 filtered SA for scheduling
    filteredSAforScheduling = [];
    filteredAppointments = [];
    selectedSASchd = [];
    selectedAppointmentId;
    @track selectedSAid;

    // Screen1
    postCode;
    floc;
    contactName;
    territoryId;
    woId;
    assignedResource;
    @track loading = false;
    //Screen2
    //Screen3
    @track sapOperationNumber;
    @track descp;
    @track filteredWOID;
  



    // variables to handle Screen navigation
    @track Screen1 = true;
    @track Screen2 = false;
    @track Screen3 = false;
    @track screen4 = false;
    @track noRecord = false

    // validation variables
    errormessages = [];//To Display Error Message
    isValidScreenOne = true; // To Check Validity of Screen 1
    isValidScreenTwo = true; // To Check Validity of Screen 2
    isValidScreenThree = true // To Check Validity of Screen 3


    /** Screen1 **/
    //To get data of Apply Filter Screen (Screen 1)
    getApplyFilterScreenData() {
        getServiceAppointment({ saId: this.recordId })
            .then(result => {
                //  this.postCode = result[0].PostalCode;
                this.postCode = (result[0]?.PostalCode) ? result[0].PostalCode : '';
                this.floc = (result[0]?.FSSK__FSK_Work_Order__r?.FSM_Floc__c) ? result[0]?.FSSK__FSK_Work_Order__r?.FSM_Floc__c : '';
                this.contactName = (result[0]?.FSSK__FSK_Work_Order__r?.FSM_ContactName__c) ? result[0]?.FSSK__FSK_Work_Order__r?.FSM_ContactName__c : '';
            })
    }


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    saData({ error, data }) {
        if (data) {
            this.territoryId = getFieldValue(data, TerritoryId);
            this.woId = getFieldValue(data, WORK_ORDER_ID);
            this.assignedResource = getFieldValue(data, ASSIGNED_SR);
        } 
    }

    // Check box options 
    filterValue = ['postalTrue', 'flocTrue', 'NameTrue'];
    get options() {
        return [
            { label: `Postal Code: ${this.postCode}`, value: 'postalTrue' },
            { label: `Floc: ${this.floc}`, value: 'flocTrue' },
            { label: `Contact Name:${this.contactName}`, value: 'NameTrue' },
        ];
    }
    // To handle change of CheckBox selection
    handleSAFilter(e) {
        this.filterValue = e.detail.value;
        this.selectedFilters = e.detail.value;
    }

    // To fetch data from FSM_SelectAndSchedule based on filtering criteria (Screen1)
    searchAppointments() {
        if (this.Screen1) {
            this.handleSectionOnevalidation();
            if (this.isValidScreenOne) {
                this.loading = true;
               
                searchSA({ saId: this.recordId, selectedFilters: this.filterValue })
                    .then(result => {
                        this.appointments = result;
                        this.filteredSAforScheduling = result;
                        //filter SA for Contact Name
                        const nameTrueCheck = this.filterValue.includes('NameTrue');
                        if (nameTrueCheck) {
                            this.filterAppointmentsByContactName();
                        }
                        this.loading = false;
                        if (this.appointments && this.appointments.length > 0) {
                            this.error = undefined;
                            this.Screen1 = false;
                            this.Screen2 = true;
                            this.Screen3 = false;
                            this.noRecord = false;
                        } else {
                            this.Screen1 = false;
                            this.Screen2 = false;
                            this.noRecord = true;
                            this.Screen3 = false;
                        }


                    })
                    .catch(error => {
                        this.error = error;
                        this.appointments = undefined;
                    });
            }
        } else {
            this.isValidScreenOne = true;
        }
    }


    // Filter SA based on Contact Name
    filterAppointmentsByContactName() {
        this.appointments = this.appointments.filter(appointment =>
            appointment.FSSK__FSK_Work_Order__r.FSM_ContactName__c == this.contactName
        )
    }


    /** Screen2 **/
    //select SA on Table (screen 2)
    handleSelection(event) {
        this.selectedAppointmentId = event.target.value;
        this.selectedSAid = event.target.value
    }
    handleNext() {
        if (this.Screen2) {
            this.handleSectionTwovalidation();
            if (this.isValidScreenTwo) {
                // Filter results based on SA ID
                this.filteredSAforScheduling = this.appointments.filter(appointment => appointment.Id === this.selectedAppointmentId);
                this.sapOperationNumber = (this.filteredSAforScheduling && this.filteredSAforScheduling[0]) ? this.filteredSAforScheduling[0].FSM_SAPWorkorderNumber__c : '';
                this.contactNameWo = (this.filteredSAforScheduling && this.filteredSAforScheduling[0]) ? this.filteredSAforScheduling[0].FSSK__FSK_Work_Order__r.FSM_ContactName__c : '';
                this.descp = (this.filteredSAforScheduling && this.filteredSAforScheduling[0]) ? this.filteredSAforScheduling[0].Subject : '';
                this.filteredWOID = this.filteredSAforScheduling[0].FSSK__FSK_Work_Order__c;
                this.Screen2 = false;
                this.Screen3 = true;
            }
        }
    }

    /** Screen3 **/
    //Schedule and Dispatch Job
    handleSchedule(event) {
        this.loading = true;
        //assign selected SA to Current Service Resource
        let saUpdate = {};
        saUpdate.Id = this.selectedAppointmentId;
        saUpdate.FSSK__FSK_Assigned_Service_Resource__c = this.assignedResource;
        scheduleAndDispatchSA({ saId: this.selectedAppointmentId, asgnResource: this.assignedResource })
            .then(rec => {
                if (this.isValidScreenThree) {
                    this.loading = false;
                    this.Screen1 = false;
                    this.Screen2 = false;
                    this.Screen3 = false;
                    this.noRecord = false;
                    this.screen4 = true;
                }
            }).catch(error => {
                this.isValidScreenThree = false;
                this.loading = false;
                console.log(error)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'An error occurred while assigning you this job.',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            })
    }
    // footer buttons
    get isSearchEnabled() {
        if (this.Screen1 == true) {
            return true; //todo brajesh
        } else {
            return false;
        }
    }
    get isEnablePrev() {
        if (this.noRecord == true || this.Screen2 == true || this.Screen3 == true) {
            return true
        }
        else {
            return false
        }
    }

    handlePrevious() {
        if (this.Screen1) {
            return
        }
        else if (this.noRecord) {
            this.errormessages = [];
            this.Screen1 = true;
            this.Screen2 = false;
            this.Screen3 = false;

            this.noRecord = false;
        }
        else if (this.Screen2) {
            this.errormessages = [];
            this.Screen1 = true;
            this.Screen2 = false;
            this.Screen3 = false;
            this.noRecord = false;
            this.selectedSAid = '';
        }
        else if (this.Screen3) {
            this.Screen1 = false;
            this.Screen2 = true;
            this.Screen3 = false;
            this.noRecord = false;
            this.selectedSAid = '';
        }
    }

    get isEnableNext() {
        if (this.Screen2 == true) {
            return true
        }
        else {
            return false
        }
    }


    get isEnabledSchedule() {
        if (this.Screen3 == true) {
            return true;
        }
        else {
            return false;
        }
    }


    /** validation (screen1) **/
    handleSectionOnevalidation() {
        this.errormessages = [];
        this.isValidScreenOne = true;
        if (this.filterValue && this.filterValue.length > 0) {
            this.isValidScreenOne = true;
        } else {
            this.errormessages.push('Error : Please select at least one of the following box');
            this.isValidScreenOne = false;
        }
    }

    /** validation (screen2) **/
    handleSectionTwovalidation() {
        this.errormessages = [];
        this.isValidScreenTwo = true;
        if (this.selectedSAid == '' || this.selectedSAid == null) {
            this.errormessages.push('Error : Please select one of the options');
            this.isValidScreenTwo = false;
        }
    }



}
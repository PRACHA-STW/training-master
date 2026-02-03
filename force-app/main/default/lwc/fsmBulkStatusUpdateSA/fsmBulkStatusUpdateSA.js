/****************************************************************************************
    - Description  : Created for Bulk Status Update Action, SFS-6634
    - Created By   : Brajesh Kumar
    - Created Date : 15 th July 2024
****************************************************************************************/
import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getStatusTransition from '@salesforce/apex/FSM_BulkStatusUpdateSAController.getStatusTransition';
import getRejectionDetails from '@salesforce/apex/FSM_BulkStatusUpdateSAController.getRejectionDetails';
import SA_STATUS from '@salesforce/schema/ServiceAppointment.Status';
import SA_ID from '@salesforce/schema/ServiceAppointment.Id';
import SA_REJECT_CATEGORY from '@salesforce/schema/ServiceAppointment.FSM_ReasonCategory__c';
import SA_REJECT_REASON from '@salesforce/schema/ServiceAppointment.FSM_RejectReason__c';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { gql, graphql } from "lightning/uiGraphQLApi";

// screen title
const s1Title = 'Bulk Update Status';
const s2Title = 'Choose the new status';
const errNotBundleTitle = 'Bulk Update Status Error: Not Bundled';

// An error occurred.
const rejectStatusTitle = 'Enter Rejection Details';



const FIELDS = [
    'ServiceAppointment.Status',
    'ServiceAppointment.FSM_IsBundle__c',
    'ServiceAppointment.IsBundleMember',
    'ServiceAppointment.FSM_BusinessUnit__c'
];

const GET_SERVICE_APPOINTMENT_WITH_BUNDLED_APPOINTMENTS = gql`
query getServiceAppointment($saId: ID!) {
    uiapi {
        query {
            ServiceAppointment(where: {Id: {eq: $saId}}) {
                edges {
                    node {
                        Id
                        BundledServiceAppointments(where: {IsBundleMember: {eq: true}, FSM_IsBundle__c: {eq: false}},first: 200) {
                            edges {
                                node {
                                    Id
                                    AppointmentNumber {
                                        value
                                    }
                                    FSM_WorkTypeCode__c {
                                        value
                                    }
                                    FSM_TypeofWork__c {
                                        value
                                    }
                                    Status {
                                        value
                                    }
                                    RelatedBundleId {
                                        value
                                    }
                                    IsBundleMember {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
`;

export default class FsmBulkStatusUpdateSA extends LightningElement {

    @api recordId;

    //----Active Screens and its Validation----
    @track isParentBundleOrCloseSA = true; // 
    @track Screen1 = true;
    @track Screen2 = false;
    @track isUpdateSuccess = false;
    @track isStatusToRejected = false;
    @track loading = false;

    // Screen 1 variable
    @track title = s1Title;
    @track isMultipleStatus = false; // for controlling Status Picklist
    @track isAllSelectAll = true;
    @track isDeSelectAll = false;
    @track statusOptions = [];   //Status picklist  
    @track selectedSACount = 0;
    @track isUpdateStatusDisabled = true;
    @track isSaveStatusDisabled = true;
    @track isBundle;
    @track isBundleMember;
    @track selectedStatus = '';
    @track saStatus;
    @track businessUnit;

    // screen 2 Variable
    @track statusToUpdateOptions = [];
    @track selectedStatusToUpdateValue = '';

    //screen3 variable
    @track allTransitionStatusRecords = []; // To hold all fetched records

    // Screen 4 variable
    // Screen 5 variable
    @track rejectCategories = []; // To hold unique picklist options for rejectCategories
    @track rejectReasons = []; // To hold filtered picklist options for rejectReasons
    selectedRejectCategory; // To hold the selected category
    selectedRejectReasons;
    allData = []; // To hold all fetched records
    RejectDetailData = []

    //----Active Buttons and its Validation----
    @track isUpdateStatusEnabled = true;
    @track isSaveStatusEnabled = false;
    @track isPreviousEnabled = false;
    @track isNextEnabled = false;

    //Variables to Store Data
    bundleAppointments = [];
    originalAppointments = []; // Original copy of bundleAppointments
    @track BUNDLE_RECORDS__GRAPHQL = [];
    REJECT_DETAILS_GRAPHQL = [];


    //check to Control visibility of Bundle SA records
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredSABundleInfo({ error, data }) {
        if (data) {
            this.saStatus = data?.fields?.Status?.value;
            this.businessUnit = data?.fields?.FSM_BusinessUnit__c?.value;
            this.isBundle = data?.fields?.FSM_IsBundle__c?.value;
            this.isBundleMember = data?.fields?.IsBundleMember?.value;
            if ((this.saStatus === 'Completed' || this.saStatus === 'Rejected') || (this.isBundle === false && this.isBundleMember === true) || (this.isBundle === false && this.isBundleMember === false)) {
                if (((this.saStatus === 'Completed' || this.saStatus === 'Rejected') && (this.isBundle === true && this.isBundleMember === false)) && (this.isUpdateSuccess === false)) {
                    this.isParentBundleOrCloseSA = true;
                    this.title = "Bulk Update Status Error: Not Open";
                    this.errMsg = "This feature can be launched only from an open service appointment.";
                } else if (((this.isBundle === false && this.isBundleMember === true) || (this.isBundle === false && this.isBundleMember === false)) && (this.isUpdateSuccess === false)) {
                    this.isParentBundleOrCloseSA = true;
                    this.title = errNotBundleTitle;
                    this.errMsg = "This feature can be launched only from a bundled service appointment"
                }
            } else {
                this.isParentBundleOrCloseSA = false;
            }
            this.error = undefined;
        } else if (error) {
            console.error("Failed to fetch Bundle Job Info.", error);
        }
    }

    @wire(getRejectionDetails)
    wiredRejectionDetails({ error, data }) {
        if (data) {
            this.RejectDetailData = data;
        } else if (error) {
            // Handle error
            console.error("Failed to fetch Rejection Details", error);
        }
    }

    getRejectDeatils() {
        this.allData = this.RejectDetailData.filter(item => item.FSM_BusinessUnit__c == this.businessUnit);
        this.rejectCategories = [...new Set(this.allData.map(item => item.FSM_RejectionCategory__c))]
            .map(category => {
                return { label: category, value: category };
            });
    }



    @wire(graphql, {
        query: GET_SERVICE_APPOINTMENT_WITH_BUNDLED_APPOINTMENTS,
        variables: '$variables'
    })
    wiredServiceAppointment({ error, data }) {
        if (data) {
            this.BUNDLE_RECORDS__GRAPHQL = data?.uiapi?.query?.ServiceAppointment?.edges[0]?.node;
            console.log('GraphQL Bundle Data', JSON.stringify(data.uiapi.query.ServiceAppointment.edges[0].node.BundledServiceAppointments.edges, null, 2));
            this.bundleAppointments = this.BUNDLE_RECORDS__GRAPHQL.BundledServiceAppointments.edges.map(edge => {
                const status = edge.node.Status.value;
                const isCheckBoxEnable = status !== 'Rejected' && status !== 'Completed';
                return {
                    Id: edge.node.Id,
                    Status: status,
                    AppointmentNumber: edge.node.AppointmentNumber.value,
                    checked: false, // Initial checkbox state
                    isCheckBoxEnable: isCheckBoxEnable, // Determine if checkbox should be enabled
                    TypeofWork: edge.node.FSM_TypeofWork__c.value,
                    WorkTypeCode: edge.node.FSM_WorkTypeCode__c.value
                };
            });
            this.originalAppointments = [...this.bundleAppointments];
            this.setStatusOptions();
            // setting picklist status options
            if (this.statusOptions.length > 0) {
                this.selectedStatus = this.statusOptions[0]?.value; // Setting first option as default
                if (this.selectedStatus == 'Rejected' || this.selectedStatus == 'Completed') {
                    this.isDeSelectAll = false;
                    this.isAllSelectAll = false;
                }
                this.filterBundleAppointments(); // Filter bundleAppointments initially
            }
            if (this.statusOptions.length === 1) {
                this.selectedStatus = this.statusOptions[0]?.value;
            }
            if (this.statusOptions.length > 1) {
                this.isMultipleStatus = true;
            }
        } else if (error) {
            console.error('Failed to fetch Bundle Job', error)
            this.BUNDLE_RECORDS__GRAPHQL = undefined;
        }
    }

    get variables() {
        return { saId: this.recordId };
    }


    // Screen 1 action    
    setStatusOptions() {
        // Use a Set to store unique status values
        const statusSet = new Set();
        this.bundleAppointments.forEach(item => {
            statusSet.add(item.Status); // Assuming 'status' is the field name
        });
        // Convert Set values to array of objects compatible with lightning-combobox options
        this.statusOptions = Array.from(statusSet).map(Status => {
            return { label: Status, value: Status };
        });

    }

    handleStatusChange(event) {
        this.selectedStatus = event?.detail?.value; // Update selectedStatus on combobox change
        // Reset checked property to false for all records
        this.bundleAppointments = this.bundleAppointments.map(item => ({
            ...item,
            checked: false
        }));
        this.updateSelectedIds();
        this.filterBundleAppointments(); // Filter bundleAppointments when status changes
        if (this.selectedStatus == 'Rejected' || this.selectedStatus == 'Completed') {
            this.isAllSelectAll = this.isDeSelectAll = false;
        } else {
            this.isDeSelectAll = false;
            this.isAllSelectAll = true;
        }
    }
    filterBundleAppointments() {
        if (!this.selectedStatus) {
            // If no status is selected, show all original appointments
            this.bundleAppointments = [...this.originalAppointments]; // Restore original data
        } else {
            // Filter appointments based on selected status
            this.bundleAppointments = this.originalAppointments.filter(item => {
                return item.Status === this.selectedStatus;
            });
        }
    }

    // control select all Button 
    handleSelectAll() {
        this.bundleAppointments = this.bundleAppointments.map(item => {
            return { ...item, checked: true };
        });
        this.isAllSelectAll = false;
        this.isDeSelectAll = true;
        this.updateSelectedIds();
    }
    // control Deselect all Button 
    handleDeselectAll() {
        this.bundleAppointments = this.bundleAppointments.map(item => {
            return { ...item, checked: false };
        });
        this.isDeSelectAll = false;
        this.isAllSelectAll = true;
        this.updateSelectedIds();
    }
    // Handle checkbox change on SA
    handleCheckboxChange(event) {
        const itemId = event.target.dataset.id;
        this.bundleAppointments = this.bundleAppointments.map(item => {
            if (item.Id === itemId) {
                return { ...item, checked: event.target.checked };
            }
            return item;
        });
        this.updateSelectedIds();
        if (this.selectedSACount === this.bundleAppointments.length) {
            this.isDeSelectAll = true;
            this.isAllSelectAll = false;
        }
        if (this.selectedSACount === 0) {
            this.isDeSelectAll = false;
            this.isAllSelectAll = true;
        }
    }

    updateSelectedIds() {
        const selectedIds = this.bundleAppointments.filter(item => item.checked).map(item => item.Id);
        this.selectedSACount = selectedIds.length;
        if (this.selectedSACount === 0) {
            this.isAllSelectAll = true;
        }
        if (this.selectedSACount > 0) {
            this.isUpdateStatusDisabled = false;
        }
        if (this.selectedSACount <= 0) {
            this.isUpdateStatusDisabled = true;
        }
        return selectedIds;
    }


    @wire(getStatusTransition)
    wiredAllRecords({ data, error }) {
        if (data) {
            this.allTransitionStatusRecords = data;
        } else if (error) {
            console.error('Failed to fetch the status transition record', error);
        }
    }

    handleUpdateStatus() {
        this.loading = true;
        this.statusToUpdateOptions = this.allTransitionStatusRecords.filter(item => item.FSM_CurrentStatus__c === this.selectedStatus).map(item => ({
            label: item.FSM_StatusToUpdate__c,
            value: item.FSM_StatusToUpdate__c
        }));

        if (this.statusToUpdateOptions == 0) {
            this.Screen1 = this.Screen2 = this.isUpdateStatusEnabled = this.isSaveStatusEnabled = this.loading = false;
        } else {
            this.title = s2Title;
            this.Screen1 = this.isUpdateStatusEnabled = this.loading = false;
            this.Screen2 = this.isSaveStatusEnabled = true;
        }
        this.isSaveStatusDisabled = true;
    }


    // handle Click on Screen2 (Select status to update)
    handleStatusToUpdateChange(event) {
        this.selectedStatusToUpdateValue = event.detail.value;
        this.isSaveStatusDisabled = false;
    }

    handleCategoryChange(event) {
        this.selectedRejectCategory = event.detail.value;
        this.rejectReasons = this.allData.filter(item => item.FSM_RejectionCategory__c === this.selectedRejectCategory)
            .map(item => {
                return { label: item.FSM_RejectionReason__c, value: item.FSM_SAPName__c };
            });

    }

    handleReasonChange(event) {
        this.selectedRejectReasons = event.detail.value;
        this.isSaveStatusDisabled = false;
    }
    // -----
    async handleSaveStatus() {
        this.loading = true;
        const filteredAppointments = this.bundleAppointments.filter(appointment => appointment.checked);
        if (this.selectedStatusToUpdateValue === 'Rejected' && (this.selectedRejectCategory == '' || this.selectedRejectCategory == null || this.selectedRejectReasons == '' || this.selectedRejectReasons == null)) {
            this.getRejectDeatils();
            this.isStatusToRejected = this.isSaveStatusDisabled = this.isPreviousEnabled = this.isSaveStatusEnabled = true;
            this.title = rejectStatusTitle;
            this.Screen1 = this.Screen2 = this.isUpdateStatusEnabled = this.loading = false;
        }
        else if (this.selectedStatusToUpdateValue && filteredAppointments.length > 0) {
            let recordsToUpdate;
            if (this.selectedStatusToUpdateValue === 'Rejected') {
                recordsToUpdate = filteredAppointments.map(appointment => {
                    return {
                        fields: {
                            [SA_ID.fieldApiName]: appointment.Id,
                            [SA_STATUS.fieldApiName]: this.selectedStatusToUpdateValue,
                            [SA_REJECT_CATEGORY.fieldApiName]: this.selectedRejectCategory,
                            [SA_REJECT_REASON.fieldApiName]: this.selectedRejectReasons
                        }
                    };
                });
            } else {
                recordsToUpdate = filteredAppointments.map(appointment => {
                    return {
                        fields: {
                            [SA_ID.fieldApiName]: appointment.Id,
                            [SA_STATUS.fieldApiName]: this.selectedStatusToUpdateValue
                        }
                    };
                });
            }
            const promises = recordsToUpdate.map((record,index,arr)=>{
                if (index=== arr.length-1){
                
                    return Promise.resolve();
                
                
                } else{
                   return updateRecord(record);
                
                }
     
     
     });

            await Promise.all(promises)
            .then(() => {
                return new Promise((resolve, reject) => {
                    setTimeout(() => {
                        updateRecord(recordsToUpdate[recordsToUpdate.length - 1])
                            .then(resolve)
                            .catch(reject);
                    }, 1);
                });
            })
            .then(() => {
                    this.showToast('Success', 'Status updated successfully', 'success');
                    this.isParentBundleOrCloseSA = false;
                    this.isUpdateSuccess = true;
                    this.title = "Update Confirmation";
                    if (this.selectedStatusToUpdateValue != 'Rejected') {
                        this.loading = this.Screen1 = this.isUpdateStatusEnabled = this.Screen2 = this.isSaveStatusEnabled = this.isStatusToRejected = this.isPreviousEnabled = false;
                    }
                    //when reject status
                    else if (this.selectedStatusToUpdateValue === 'Rejected') {
                        this.loading = this.Screen1 = this.isUpdateStatusEnabled = this.Screen2 = this.isStatusToRejected = this.isSaveStatusEnabled = this.isNextEnabled = this.isPreviousEnabled = false;
                    }

                })
                .catch(error => {
                    this.showToast('Error', 'Error updating status: ' + error?.body?.message, 'error');
                    console.error("Error Updating Status", error);
                    this.loading = this.Screen2 = this.isSaveStatusEnabled = false;
                    this.Screen1 = this.isUpdateStatusEnabled = true;
                });

            this.loading = false;
        }
    }


    // screen 5 action
    handlePrevious() {
        this.isStatusToRejected = this.isSaveStatusEnabled = this.Screen2 = this.isUpdateSuccess = this.isPreviousEnabled = this.isNextEnabled = false;
        this.Screen1 = this.isUpdateStatusEnabled = true;
        this.title = s1Title;
        this.selectedRejectCategory = this.selectedRejectReasons = this.selectedStatusToUpdateValue = ''
        if (this.selectedStatus == 'Rejected' || this.selectedStatus == 'Completed') {
            this.isDeSelectAll = this.isAllSelectAll = false;
        }
    }


    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
   
}
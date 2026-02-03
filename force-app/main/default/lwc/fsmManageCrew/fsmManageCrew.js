import { LightningElement, api, wire, track } from 'lwc';
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';
import getActiveResources from '@salesforce/apex/Fsm_ManageCrew.getActiveResources';
import getCurrentUserServiceResourceId from '@salesforce/apex/Fsm_ManageCrew.getCurrentUserServiceResourceId';
import { gql, graphql } from 'lightning/uiGraphQLApi';


// valid status which allows this action to be performed
const VALID_STATUSES = ['Dispatched', 'En-Route', 'Onsite', 'On Hold', 'Return to Site'];



export default class FsmManageCrew extends LightningElement {
    @api recordId;

    // Screen Navigation Toggle
    isHeaderVisible = true;
    isAddRemoveResource = false;
    isShowError = false;
    isSearchResource = false;
    isSuccessScreen = false;
    isRemoveResource = false;
    isCriticalErrorScreen = false;
    @track criticalErrorMessage = '';
    //UI Text
    @track headerText = 'Manage Crew';
    //Assigned resource 
    @track assignedResources = [];
    currentUserServiceResourceId;
    // service appointment variables
    serviceAppointmentStatus;
    serviceAppointmentBusinessUnit;
    saExternalId;
    // wire methods variables
    @track usersWithActiveTerritory = [];
    @track userDataFromApex = []
    @track searchKey = '';
    @track users = [];
    @track allUsers = [];
    @track selectedUserIds = [];
    @track selectedAssignedResourceIds = [];
    error;
    @track addErrorMessage = '';
    @track isLoading = false;
    @track isErrorScreenLoad = false
    connectedCallback() {
        this.isErrorScreenLoad = true;
        setTimeout(() => {
            this.isErrorScreenLoad = false;
        }, 5000);
    }

    // Fetch Service Appointment details
    serviceAppointmentQuery = gql`
    query GetServiceAppointment($recordId: ID!) {
        uiapi {
            query {
                ServiceAppointment(where: { Id: { eq: $recordId } }) {
                    edges {
                        node {
                            Id
                            Status { value }
                            FSM_BusinessUnit__c { value }
                            FSM_ExternalId__c { value }
                        }
                    }
                }
            }
        }
    }
`;
    @wire(graphql, {
        query: '$serviceAppointmentQuery',
        variables: '$serviceAppointmentVariables'
    })
    wiredServiceAppointment({ error, data }) {

        if (data) {
            const node = data.uiapi.query.ServiceAppointment.edges[0]?.node;
            if (node) {
                this.serviceAppointmentStatus = node?.Status?.value;
                this.saExternalId = node.FSM_ExternalId__c.value;
                const isValidServiceStatus = VALID_STATUSES.includes(this.serviceAppointmentStatus);
                // Only show add/remove screen if no other screen is active
                if (
                    isValidServiceStatus &&
                    !this.isSuccessScreen &&
                    !this.isRemoveResource &&
                    !this.isSearchResource &&
                    !this.isShowError &&
                    !this.isCriticalErrorScreen
                ) {
                    this.isAddRemoveResource = true;
                }
                this.isShowError = !isValidServiceStatus;
            }
        } else if (error) {
            console.error('Error Fetching Service Appointment:', error);
        }
    }

    get serviceAppointmentVariables() {
        return { recordId: this.recordId };
    }

    // to Fetch Active Resources
    @wire(getActiveResources)
    wiredResources({ error, data }) {
        if (data) {
            const initialLimit = 10; // Set initial limit for users displayed
            this.allUsers = data.map(user => {
                return {
                    id: user.Id,
                    name: user.Name,
                    workCenterId: user.FSM_WorkCentreExternalId__c,
                    ganttLabel: user.FSL__GanttLabel__c,
                };
            });
            this.usersWithActiveTerritory = this.allUsers;
            this.usersWithActiveTerritory = this.allUsers.slice(0, initialLimit);
            this.error = undefined;
        } else if (error) {
            this.users = [];
            this.allUsers = [];
        }
    }

    // UI handlers to Add Members to Crew
    handleAddCrew() {
        this.isHeaderVisible = true;
        this.headerText = 'Search & Assign Member';
        this.filterOutAssignedUsers();
        this.isSearchResource = true;
        this.isAddRemoveResource = this.isShowError = false;
    }

    // use wire method to fetch current logged in user Id
    @wire(getCurrentUserServiceResourceId)
    wiredCurrentUserServiceResourceId({ error, data }) {
        if (data) {
            this.currentUserServiceResourceId = data;
        }
    }
    // UI handler to Remove Crew Member Clicked
    handleRemoveCrew() {
        this.isHeaderVisible = true;
        this.headerText = 'Remove Member';
        // Mark isCurrentUser in assignedResources
        this.assignedResources = this.assignedResources.map(res => ({
            ...res,
            isCurrentUser: res.serviceResourceId === this.currentUserServiceResourceId
        }));
        this.isRemoveResource = true;
        this.isAddRemoveResource = this.isSearchResource = this.isShowError = false;
    }
    // Checkbox change handler for user selection
    handleCheckboxChange(event) {
        const userId = event.target.name;
        const checked = event.target.checked;
        if (checked) {
            if (!this.selectedUserIds.includes(userId)) {
                this.selectedUserIds = [...this.selectedUserIds, userId];
            }
        } else {
            this.selectedUserIds = this.selectedUserIds.filter(id => id !== userId);
        }

        this.allUsers = this.allUsers.map(user => {
            if (user.id === userId) {
                return { ...user, selected: checked }; // true or false
            }
            return user;
        });

    }
    // Handle back button click
    handleBack() {
        this.headerText = 'Manage Crew';
        this.isAddRemoveResource = true;
        this.isSearchResource = this.isShowError = this.isRemoveResource = false;
    }


    // Handle search input change
    handleSearchInput(event) {
        const initialLimit = 100;
        const query = event.target.value?.trim().toLowerCase() || '';
        const assignedIds = new Set(this.assignedResources.map(res => res.serviceResourceId));
        this.usersWithActiveTerritory = this.allUsers.filter(user =>
            user.name &&
            !assignedIds.has(user.id) &&
            user.name.toLowerCase().includes(query)
        );
        this.usersWithActiveTerritory = this.usersWithActiveTerritory.slice(0, initialLimit);
    }



    // to add service resource to the job
    handleAdd() {
        if (this.selectedUserIds.length === 0) {
            this.addErrorMessage = 'Please select at least one Service Resource to add to the job.';
            clearTimeout(this._errorTimeout);
            this._errorTimeout = setTimeout(() => {
                this.addErrorMessage = '';
            }, 3000);
            return;
        }
        this.isLoading = true;
        const minLoadingTime = 2000;
        const loadingStart = Date.now();
        // create AssignedResource records
        const createAssignedResourcePromises = this.selectedUserIds.map(serviceResourceId => {
            const fields = {
                ServiceAppointmentId: this.recordId,
                ServiceResourceId: serviceResourceId
            };
            const recordInput = { apiName: 'AssignedResource', fields };
            return createRecord(recordInput);
        });
        // After all STM records are created, create AssignedResource records
        Promise.all(createAssignedResourcePromises)
            .then(() => {
                const elapsed = Date.now() - loadingStart;
                const remaining = minLoadingTime - elapsed;
                setTimeout(() => {
                    this.isLoading = false;
                    this.addErrorMessage = '';
                    this.isHeaderVisible = false;
                    this.successMessage = 'Service Resource has been added to the job successfully.';
                    this.isSuccessScreen = true;
                    this.isAddRemoveResource = false;
                    this.isSearchResource = false;
                    this.isShowError = false;
                }, remaining > 0 ? remaining : 0);
            })
            .catch(error => {
                this.isAddRemoveResource = false;
                this.isCriticalErrorScreen = true;
                this.headerText = 'Error Encountered'
                this.isRemoveResource = false;
                this.isSearchResource = false;
                this.criticalErrorMessage = 'An unexpected error occurred while assigning resources. Please try again later.';
                // --- Create error log record on failure ---
                const errorFields = {
                    FSM_ClassFlowName__c: 'fsmManageCrew (LWC)',
                    FSM_MethodName__c: 'handleAdd',
                    FSM_ExternalId__c: this.saExternalId,
                    FSM_Type__c: 'Field Service',
                    FSM_StackTrace__c: JSON.stringify(error),
                    FSM_ErrorMessage__c: JSON.stringify(error),
                };
                const errorRecordInput = { apiName: 'FSM_ErrorLog__c', fields: errorFields };
                createRecord(errorRecordInput)
                    .then(() => {
                    })
                    .catch(err => {
                        console.error('Failed to create error log record:', err);
                    });
            });
    }
    // Handle error close button click
    handleErrorClose() {
        this.addErrorMessage = '';
    }

    // assigned Resource for removal GraphQL query for AssignedResource
    assignedResourceQuery = gql`
        query AssignedResources($recordId: ID!) {
            uiapi {
                query {
                    AssignedResource(
                        where: {
                            ServiceAppointmentId: { eq: $recordId }
                            ServiceResource: { ResourceType: { ne: "C" } }
                        },
                        first: 100
                    ) {
                        edges {
                            node {
                                Id
                                ServiceResource {
                                    Id
                                    Name { value }
                                    FSM_WorkCentreExternalId__c { value }
                                    FSL__GanttLabel__c { value }
                                }
                            }
                        }
                    }
                }
            }
        }
    `;
    @wire(graphql, {
        query: '$assignedResourceQuery',
        variables: '$assignedResourceVariables'
    })
    wiredAssignedResources({ error, data }) {
        if (data && data.uiapi && data.uiapi.query && data.uiapi.query.AssignedResource) {
            this.assignedResources = data?.uiapi?.query?.AssignedResource?.edges.map(edge => ({
                id: edge?.node?.Id,
                name: edge?.node?.ServiceResource?.Name?.value,
                workCenterId: edge?.node?.ServiceResource?.FSM_WorkCentreExternalId__c?.value,
                ganttLabel: edge?.node?.ServiceResource?.FSL__GanttLabel__c?.value,
                serviceResourceId: edge?.node?.ServiceResource?.Id
            }));
            // Filter users after assignedResources is loaded
        } else if (error) {
            console.error('Unable to Get Assigned Resource', error);
        }
    }

    get assignedResourceVariables() {
        return { recordId: this.recordId };
    }
    // Handle checkbox change for removing assigned resources
    handleRemoveCheckboxChange(event) {
        const assignedResourceId = event.target.name; // This should be the AssignedResource Id
        const checked = event.target.checked;

        if (checked) {
            if (!this.selectedAssignedResourceIds.includes(assignedResourceId)) {
                this.selectedAssignedResourceIds = [...this.selectedAssignedResourceIds, assignedResourceId];
            }
        } else {
            this.selectedAssignedResourceIds = this.selectedAssignedResourceIds.filter(id => id !== assignedResourceId);
        }
    }
    // Handle back button click for removing resources
    handleRemove() {
        if (this.selectedAssignedResourceIds.length === 0) {
            this.addErrorMessage = 'Please select at least one crew member to remove.';
            clearTimeout(this._errorTimeout);
            this._errorTimeout = setTimeout(() => {
                this.addErrorMessage = '';
            }, 3000);
            return;
        }
        this.isLoading = true;
        const minLoadingTime = 2000;
        const loadingStart = Date.now();

        const deletePromises = this.selectedAssignedResourceIds.map(id => deleteRecord(id));

        Promise.all(deletePromises)
            .then(() => {
                const elapsed = Date.now() - loadingStart;
                const remaining = minLoadingTime - elapsed;
                setTimeout(() => {
                    this.isLoading = false;
                    this.isRemoveResource = false;
                    this.isHeaderVisible = false;
                    this.isSuccessScreen = true;
                    this.successMessage = 'Service Resource has been removed from the job successfully.';
                    this.selectedAssignedResourceIds = [];
                    // Optionally refresh assignedResources here
                }, remaining > 0 ? remaining : 0);
            })
            .catch(error => {
                this.isLoading = false;
                this.addErrorMessage = 'Error removing crew member(s): ' + (error.body && error.body.message ? error.body.message : error.message);
            });
    }
    // remove resources who are already assigned to the job
    filterOutAssignedUsers() {
        const assignedIds = this.assignedResources.map(res => res.serviceResourceId);
        this.usersWithActiveTerritory = this.usersWithActiveTerritory.filter(user => !assignedIds.includes(user.id));
    }
    // Get user grid class based on the number of users:Adding css Dynamically
    get userGridClass() {
        return `user-grid${this.usersWithActiveTerritory.length <= 2 ? ' few-users' : ''}`;
    }



}
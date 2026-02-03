/****************************************************************************************
    - Description  : Created for DCF Distribution Feedback Form
    - Created Date : 13th October 2023
    - Created By  : 6th Dec, 2023 by Brajesh Kumar & Arnob Dey - SFS-3778,Updated SFS-4979
****************************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getAllRecords from '@salesforce/apex/FSM_DependantPicklistcls.getAllRecords';
import getAssetList from '@salesforce/apex/FSM_DependantPicklistcls.getAssetList';
import DCFINFRAOBJECT from '@salesforce/schema/FSM_DataCaptureFormInfra__c';
import GSSPAYABLE_FIELD from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_GSSPayable__c';
import ILLEGALUSEREASON_FIELD from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_IllegalUseReason__c';
import ISTHERECONFIRMEDPOLLUTION_FIELD from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_IsThereConfirmedPollution__c';
import ISTHEREARISKOFPOLLUTIONOCCURRING_FIELD from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_IsThereARiskOfPollutionOccurring__c';
import RISKTOENVIRONMENTALSITE_FIELD from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_RiskToAnEnvironmentalSite__c';
import ILLEGALUSE_FIELD from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_IllegalUse__c';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasDCFLimitReached from '@salesforce/apex/FSM_InvocableDcfConfiguration.hasDCFLimitReached';


export default class FsmDistributionFeedback extends LightningElement {
    @api recordId;
    //----Active Screens----
    @track Screen1 = true;
    @track Screen2 = false;
    @track Screen3 = false;
    @track Screen4 = false;
    @track Screen5 = false;
    //----------------------
    errormessages = [];//To Display Error Message
    isValidScreenOne = true; // To Check Validity of Screen 1
    isValidScreenTwo = true; // To Check Validity of Screen 2
    isValidScreenFour = true // To Check Validity of Screen 4


    submitValues = {}; // To store values of all Screens

    //dcfdependentpicklist1;//To store all records values from Dependent Picklist Object
    @track objectApiName = DCFINFRAOBJECT; // To store object API name to fetch input variables

    //-----Screen1 values-----   
    @track selectedAsset;
    @track selectedTask;
    @track selectedTechnique;
    @track selectedSize;
    @track selectedMaterial;
    @track assetuuid;
    @track depthOfCover;
    //-----Screen2 values-----
    @track selectedIsThereConfirmedPollutionfield;
    @track selectedIsThereARiskOfPollutionOccurringfield;
    @track selectedRiskToAnEnvironmentalSitefield;
    // To STore Conditional rendering screen 2
    isConfirmed = true;
    //-----Screen3 values-----
    @track selectedGssfield;
    @track gssPayements;
    @track selectedIllegalUsefield;
    //-----Screen4 values-----
    @track illegalUserName;
    @track houseName;
    @track houseNumber;
    @track street;
    @track town;
    @track city;
    @track postCode;
    @track telephone;
    @track selectedIllegalUseReasonfield;
    @track illegalLocation;
    @track standpipeNum;
    @track hireDate;
    //--------To Store Picklist Values---------
    // screen 1
    @track assetRecords = [];
    @track taskRecords = [];
    @track techniqueRecords = [];
    @track sizeRecords = [];
    @track materialRecords = [];
    // screen 2
    @track isThereConfirmedPollutionOptions = [];
    @track isThereARiskOfPollutionOccurringOptions = [];
    @track riskToAnEnvironmentalSiteOptions = [];
    // screen 3
    @track gssPayableOptions = [];
    @track IllegalUseOptions = [];
    // screen 4
    @track illegalUseReasonOptions = [];



    /**  ------------To Store Help Text values------------  **/
    /***  screen 2 ***/
    // Is there confirmed pollution
    confirmedPollutionHelpText = 'If there is a risk of an environmental impact please contact Network Control immediately to mitigate any risk to the environment - Please carry out your impact assessment and feedback to your supervisor and assess mitigation options';
    //Is there a risk of pollution occurring
    pollutionRiskHelpText = 'If yes, please escalate to the relevant supervisor and assess '
    
    hasMaxLimitReached = false;
    showSpinner = false;

    connectedCallback() {
        this.maxLimitCheck();
    }

    //if maximum number of allowed DCF forms completed, prevent the user from creating new DCF records.
    async maxLimitCheck() {
        try {
            this.showSpinner = true;
            this.hasMaxLimitReached = await hasDCFLimitReached({ workstepId : this.recordId });
            console.log('hasMaxLimitReached', this.hasMaxLimitReached);
        } catch (error) {
            console.error('An error has occured while fetching max instance', error);
        } finally{
            this.showSpinner = false;
        }
    }



    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: GSSPAYABLE_FIELD
    }) gssValues({ error, data }) {
        if (data) {
            this.gssPayableOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleChangegssPayableReason(event) {
        this.selectedGssfield = event.detail.value;
    }


    @track selectedIllegalUseReasonfield;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: ILLEGALUSEREASON_FIELD
    }) illegalUseReasonValues({ error, data }) {
        if (data) {
            this.illegalUseReasonOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleChangeIllegalUseReason(event) {
        this.selectedIllegalUseReasonfield = event.detail.value;
    }



    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: ISTHERECONFIRMEDPOLLUTION_FIELD
    }) isThereConfirmedPollutionValues({ error, data }) {
        if (data) {
            this.isThereConfirmedPollutionOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    // To dynamically mark 'FSM_IsThereConfirmedPollution__c' field 'required' on Screen4
    handleConfirmedPollution(event) {
        this.selectedIsThereConfirmedPollutionfield = event.detail.value;
        if (this.selectedIsThereConfirmedPollutionfield == 'Yes') {
            this.isConfirmed = false;
        } else if (this.selectedIsThereConfirmedPollutionfield == 'No') {
            this.isConfirmed = true;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: ISTHEREARISKOFPOLLUTIONOCCURRING_FIELD
    }) isThereARiskOfPollutionOccurringValues({ error, data }) {
        if (data) {
            this.isThereARiskOfPollutionOccurringOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handlePollutionRiskChange(event) {
        this.selectedIsThereARiskOfPollutionOccurringfield = event.detail.value;
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: RISKTOENVIRONMENTALSITE_FIELD
    }) selectedRiskToAnEnvironmentalSiteValues({ error, data }) {
        if (data) {
            this.riskToAnEnvironmentalSiteOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleEnvSiteRisk(event) {
        this.selectedRiskToAnEnvironmentalSitefield = event.detail.value;
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: ILLEGALUSE_FIELD
    }) selectedIllegalUseValues({ error, data }) {
        if (data) {
            this.IllegalUseOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleIllegalUseRisk(event) {
        this.selectedIllegalUsefield = event.detail.value;
       
    }

    @wire(getAllRecords)
    wiredAllRecords({ data, error }) {
        if (data) {
            this.allRecords = JSON.stringify(data);
        } else if (error) {
            console.error('Error allrecords ', error);
        }
    }

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

    @track filteredTask = [];
    @track filteredTechnique = [];
    @track filteredSize = [];
    @track filteredMaterial = [];

    handleAssetChange(event) {

        this.filteredTechnique = [];
        this.filteredSize = [];
        this.filteredMaterial = [];

        this.selectedAsset = event.detail.value;
        let dataObj = JSON.parse(this.allRecords);

        let dupTaskCheck = [];
        let filteredTaskOps = [];
        dataObj.forEach(record => {

            if (this.selectedAsset === record.FSM_Asset__c && !dupTaskCheck.includes(record.FSM_Task__c)) {
                let exists = this.taskRecords.find(obj => obj.value === record.FSM_Task__c);

                filteredTaskOps.push(exists);
                dupTaskCheck.push(record.FSM_Task__c);
            }
        });

        this.filteredTask = filteredTaskOps;
        this.selectedTask = '';

    }

    handleTaskChange(event) {
        this.filteredSize = [];
        this.filteredMaterial = [];

        this.selectedTask = event.detail.value;
        let dataObj = JSON.parse(this.allRecords);

        let dupTechniqueCheck = [];
        let filteredTechniqueOps = [];

        dataObj.forEach(record => {

            if (this.selectedAsset === record.FSM_Asset__c && this.selectedTask === record.FSM_Task__c && !dupTechniqueCheck.includes(record.FSM_Technique__c)) {
                let exists = this.techniqueRecords.find(obj => obj.value === record.FSM_Technique__c);

                filteredTechniqueOps.push(exists);
                dupTechniqueCheck.push(record.FSM_Technique__c);
            }
        });

        this.filteredTechnique = filteredTechniqueOps;
        this.selectedTechnique = '';
    }

    handleTechniqueChange(event) {

        this.filteredMaterial = [];

        this.selectedTechnique = event.detail.value;

        let dataObj = JSON.parse(this.allRecords);
        let dupSizeCheck = [];
        let filteredSizeOps = [];

        dataObj.forEach(record => {
            if (this.selectedAsset === record.FSM_Asset__c && this.selectedTask === record.FSM_Task__c && this.selectedTechnique === record.FSM_Technique__c && !dupSizeCheck.includes(record.FSM_Size__c)) {
                let exists = this.sizeRecords.find(obj => obj.value === record.FSM_Size__c);

                filteredSizeOps.push(exists);
                dupSizeCheck.push(record.FSM_Size__c);
            }
        });

        this.filteredSize = filteredSizeOps;
        this.selectedSize = '';
    }

    handleSizeChange(event) {

        this.selectedSize = event.detail.value;

        let dataObj = JSON.parse(this.allRecords);
        let dupMaterialCheck = [];
        let filteredMaterialOps = [];

        dataObj.forEach(record => {

            if (this.selectedAsset === record.FSM_Asset__c && this.selectedTask === record.FSM_Task__c && this.selectedTechnique === record.FSM_Technique__c && this.selectedSize === record.FSM_Size__c && !dupMaterialCheck.includes(record.FSM_Material__c)) {
                let exists = this.materialRecords.find(obj => obj.value === record.FSM_Material__c);

                filteredMaterialOps.push(exists);
                dupMaterialCheck.push(record.FSM_Material__c);
            }
        });

        this.filteredMaterial = filteredMaterialOps;
        this.selectedMaterial = '';
    }

    handleMaterialChange(event) {

        this.selectedMaterial = event.detail.value;
    }
    //---------Start of OnChange handler methods--------------------
    handleHireDateChange(event) {
        this.hireDate = new Date(event.detail.value).toISOString();
    }

    handleAssetUidChange(event) {
        this.assetuuid = event.detail.value;
    }

    handleDepthChange(event) {
        this.depthOfCover = event.detail.value;
    }

    handleGssPaymentChange(event) {
        this.gssPayements = event.detail.value;
    }
    handleIllegalUNameChange(event) {
        this.illegalUserName = event.detail.value;
    }
    handleHouseNameChange(event) {
        this.houseName = event.detail.value;
    }
    handleHouseNumChange(event) {
        this.houseNumber = event.detail.value;
    }
    handleStreetChange(event) {
        this.street = event.detail.value;
    }
    handleTownChange(event) {
        this.town = event.detail.value;
    }
    handleCityChange(event) {
        this.city = event.detail.value;
    }
    handlePostalChange(event) {
        this.postCode = event.detail.value;
    }
    handleTelephoneChange(event) {
        this.telephone = event.detail.value;
    }
    handleIllegalLocationChange(event) {
        this.illegalLocation = event.detail.value;
    }
    handleStandpipeChange(event) {
        this.standpipeNum = event.detail.value;
    }

    //---------Start of Saving Screen Values Methods-----------
    saveScreenOneValues() {
        this.submitValues.FSM_Asset__c = this.selectedAsset;
        this.submitValues.FSM_Task__c = this.selectedTask;
        this.submitValues.FSM_Technique__c = this.selectedTechnique;
        this.submitValues.FSM_AssetSize__c = this.selectedSize;
        this.submitValues.FSM_AssetMaterial__c = this.selectedMaterial;
        this.submitValues.FSM_AssetUID__c = this.assetuuid;
        this.submitValues.FSM_DepthOfCover__c = this.depthOfCover;
    }
    saveScreenTwoValues() {
        this.submitValues.FSM_IsThereConfirmedPollution__c = this.selectedIsThereConfirmedPollutionfield;
        this.submitValues.FSM_IsThereARiskOfPollutionOccurring__c = this.selectedIsThereARiskOfPollutionOccurringfield;
        this.submitValues.FSM_RiskToAnEnvironmentalSite__c = this.selectedRiskToAnEnvironmentalSitefield;
    }

    saveScreenThreeValues() {
        this.submitValues.FSM_GSSPayable__c = this.selectedGssfield;
        this.submitValues.FSM_GSSPayments__c = this.gssPayements;
        this.submitValues.FSM_IllegalUse__c = this.selectedIllegalUsefield
    }

    saveScreenFourValues() {
        this.submitValues.FSM_IllegalUserName__c = this.illegalUserName;
        this.submitValues.FSM_HouseName__c = this.houseName;
        this.submitValues.FSM_HouseNo__c = this.houseNumber;
        this.submitValues.FSM_Street__c = this.street;
        this.submitValues.FSM_Town__c = this.town;
        this.submitValues.FSM_City__c = this.city;
        this.submitValues.FSM_PostCode__c = this.postCode;
        this.submitValues.FSM_TelephoneNumber__c = this.telephone;
        this.submitValues.FSM_IllegalUseReason__c = this.selectedIllegalUseReasonfield;
        this.submitValues.FSM_IllegalLocation__c = this.illegalLocation;
        this.submitValues.FSM_StandpipeNo__c = this.standpipeNum;
        this.submitValues.FSM_DateHire__c = this.hireDate;

    }
    //---------End of Saving Screen Values Methods-----------

    // Description : Method to check validation of Screen 1
    handleSectionOnevalidation() {
        this.errormessages = [];
        this.isValidScreenOne = true;

        if ((this.selectedMaterial == '' || this.selectedMaterial == null) &&
            (this.selectedSize == '' || this.selectedSize == null) &&
            (this.selectedTask == '' || this.selectedTask == null) &&
            (this.selectedTechnique == '' || this.selectedTechnique == null) &&
            (this.selectedAsset == '' || this.selectedAsset == null) &&
            (this.assetuuid == null || this.assetuuid.length == 0) &&
            (this.depthOfCover == null || this.depthOfCover == '')) {

            this.errormessages.push('Please enter data in all the required fields');
            this.isValidScreenOne = false;
        }
        else if (this.selectedAsset == '' || this.selectedAsset == null) {

            this.errormessages.push('Please select a value in Asset');

            this.isValidScreenOne = false;
        }
        else if (this.selectedTask == '' || this.selectedTask == null) {

            this.errormessages.push('Please select a value in Task');

            this.isValidScreenOne = false;
        }
        else if (this.selectedTechnique == '' || this.selectedTechnique == null) {

            this.errormessages.push('Please select a value in Technique');

            this.isValidScreenOne = false;
        }
        else if (this.selectedSize == '' || this.selectedSize == null) {

            this.errormessages.push('Please select a value in Size');

            this.isValidScreenOne = false;
        }
        else if (this.selectedMaterial == '' || this.selectedMaterial == null) {

            this.errormessages.push('Please select a value in Material');

            this.isValidScreenOne = false;
        }
        else if (this.assetuuid == '' || this.assetuuid == null || this.assetuuid.length > 40) {

            this.errormessages.push('Asset UID should be 40 Max characters');

            this.isValidScreenOne = false;
        }
        else if (this.depthOfCover == null || this.depthOfCover == '') {

            this.errormessages.push('Please enter value in Depth of Cover');

            this.isValidScreenOne = false;
        } else {
            this.isValidScreenOne = true;
        }
    }
    // Description : Method to check validation of Screen 2 
    handleSectionTwovalidation() {

        this.errormessages = [];
        this.isValidScreenTwo = true;
        if (this.selectedIsThereConfirmedPollutionfield == '' || this.selectedIsThereConfirmedPollutionfield == null) {
            this.errormessages.push('Please enter data in Is there confirmed pollution');
            this.isValidScreenTwo = false;
        }
        if (this.selectedIsThereConfirmedPollutionfield == 'No' && (this.selectedIsThereARiskOfPollutionOccurringfield == '' || this.selectedIsThereARiskOfPollutionOccurringfield == null || this.selectedRiskToAnEnvironmentalSitefield == '' || this.selectedRiskToAnEnvironmentalSitefield == null)) {
            this.errormessages.push('Please enter data in the required field');
            this.isValidScreenTwo = false;
        }
        if (this.selectedIsThereConfirmedPollutionfield == 'Yes' && (this.selectedRiskToAnEnvironmentalSitefield == '' || this.selectedRiskToAnEnvironmentalSitefield == null)) {
            this.errormessages.push('Please enter data in the required field');
            this.isValidScreenTwo = false;
        }
    }
// Description : Method to check validation of Screen 4
handleSectionFourvalidation() {
 
    this.errormessages = [];
    this.isValidScreenFour = true;
    // console.log("telephone :",this.telephone);
    // console.log("length :",String(this.telephone).length);
    // console.log("TypeOf Telephone No :",typeof this.telephone);
    // if (this.telephone != null && this.telephone != undefined && String(this.telephone).length != 11) {
    //     this.errormessages.push('Telephone Number must be 11 digits. Please enter a valid number.');
    //     this.isValidScreenFour = false;
    // }
    
}


    // Description : Method to save and create DCF records
    handleSave(event) {
    // Perform Section 4 validation
    this.handleSectionFourvalidation();

    // Check if Section 4 validation passed
    if (this.isValidScreenFour) {
        this.showSpinner = true;
        // Prepare the submitValues object
        this.submitValues.FSM_WorkStep__c = this.recordId;
        this.submitValues.FSM_Status__c = 'Completed';
        this.submitValues.FSM_FormType__c = 'Distribution Feedback';
        this.submitValues.FSM_Asset__c = this.selectedAsset;
        this.submitValues.FSM_Task__c = this.selectedTask;
        this.submitValues.FSM_Technique__c = this.selectedTechnique;
        this.submitValues.FSM_AssetSize__c = this.selectedSize;
        this.submitValues.FSM_AssetMaterial__c = this.selectedMaterial;
        this.submitValues.FSM_AssetUID__c = this.assetuuid;
        this.submitValues.FSM_DepthOfCover__c = this.depthOfCover;
        this.submitValues.FSM_IsThereConfirmedPollution__c = this.selectedIsThereConfirmedPollutionfield;
        this.submitValues.FSM_IsThereARiskOfPollutionOccurring__c = this.selectedIsThereARiskOfPollutionOccurringfield;
        this.submitValues.FSM_RiskToAnEnvironmentalSite__c = this.selectedRiskToAnEnvironmentalSitefield;
        this.submitValues.FSM_GSSPayable__c = this.selectedGssfield;
        this.submitValues.FSM_GSSPayments__c = this.gssPayements;
        this.submitValues.FSM_IllegalUse__c = this.selectedIllegalUsefield;
        this.submitValues.FSM_IllegalUserName__c = this.illegalUserName;
        this.submitValues.FSM_HouseName__c = this.houseName;
        this.submitValues.FSM_HouseNo__c = this.houseNumber;
        this.submitValues.FSM_Street__c = this.street;
        this.submitValues.FSM_Town__c = this.town;
        this.submitValues.FSM_City__c = this.city;
        this.submitValues.FSM_PostCode__c = this.postCode;
        this.submitValues.FSM_TelephoneNumber__c = this.telephone;
        this.submitValues.FSM_IllegalUseReason__c = this.selectedIllegalUseReasonfield;
        this.submitValues.FSM_IllegalLocation__c = this.illegalLocation;
        this.submitValues.FSM_StandpipeNo__c = this.standpipeNum;
        this.submitValues.FSM_DateHire__c = this.hireDate;
        
        // Create the record
        const recordInput = { apiName: DCFINFRAOBJECT.objectApiName, fields: this.submitValues };
        createRecord(recordInput)
            .then(record => {
                console.log('inside create rec');
                let workStep = {};
                workStep.Id = this.recordId;
                workStep.FSM_IsCompleted__c = true;
                workStep.Status = 'Completed';
                updateRecord({ fields: workStep })
                    .then(r => {
                        console.log('inside update rec');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'WorkStep Completed!',
                                variant: 'success',
                            }),
                        )
                    }).then(j => {
                        if (this.selectedIllegalUsefield == 'No' && this.Screen3 == true) {
                           
                            this.showSpinner = false;
                            this.Screen3 = false;
                            this.Screen5 = true;
                        } else {
                            
                            this.showSpinner = false;
                            this.Screen4 = false;
                            this.Screen5 = true;
                        }
                    })
                    .catch(e => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error while creating WorkStep',
                                message: e.body.message,
                                variant: 'error',
                            }),
                        );
                    })
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while creating DCF Record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
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
            this.Screen2 = false;
            this.Screen3 = false;
            this.Screen4 = false;
            this.Screen5 = false;
        }
        else if (this.Screen3) {
            this.errormessages = [];
            this.saveScreenThreeValues();
            this.Screen1 = false;
            this.Screen2 = true;
            this.Screen3 = false;
            this.Screen4 = false;
            this.Screen5 = false;
        }
        else if (this.Screen4) {
            this.errormessages = [];
            this.Screen1 = false;
            this.Screen2 = false;
            this.Screen3 = true;
            this.Screen4 = false;
            this.Screen5 = false;
        }
    }


    // Description : Method to handle next screen navigations on Button Click
    handleNext() {
        
        if (this.Screen1) {   
            this.saveScreenOneValues();
            this.handleSectionOnevalidation();
            if (this.isValidScreenOne) {
        
                this.Screen1 = false;
                this.Screen2 = true;
                this.Screen3 = false;
                this.Screen4 = false;
                this.Screen5 = false;
            }
        } else if (this.Screen2) {
            this.saveScreenTwoValues();
            this.handleSectionTwovalidation();
            if (this.isValidScreenTwo) {
                this.Screen1 = false;
                this.Screen2 = false;
                this.Screen3 = true;
                this.Screen4 = false;
                this.Screen5 = false;
            }

        }
        else if (this.Screen3) {
            this.saveScreenThreeValues();
            this.Screen1 = false;
            this.Screen2 = false;
            this.Screen3 = false;
            if (this.selectedIllegalUsefield == 'Yes') {
                this.Screen4 = true;
                this.Screen5 = false;
            } else {
                //modified if condition as part of SFS-7838
                this.handleSave();
                this.Screen4 = false;
                //this.Screen5 = true;
            }

        }
        else if (this.Screen4) {
            this.saveScreenFourValues();
            this.Screen1 = false;
            this.Screen2 = false;
            this.Screen3 = false;
            this.Screen4 = false;
            this.Screen5 = true;
        }
    
}

    get isEnableNext() {
       
        if (this.selectedIllegalUsefield == 'No' && this.Screen3 == true) {
            return false;
        }
        if (this.Screen1 == true || this.Screen2 == true || this.Screen3 == true) {
            return true;
        }
        else {
            return false;
        }
    }
    get isLastScreen() {
        
        if (this.selectedIllegalUsefield == 'No' && this.Screen3 == true) {
            return true;
        }
        if (this.Screen4 == true) {
            return true;
        }
        else {
            return false;
        }
    }
    get isEnablePrev() {
        if (this.Screen2 == true || this.Screen3 == true || this.Screen4 == true) {
            return true;
        }
        else {
            return false;
        }

    }
}
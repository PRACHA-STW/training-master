import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { gql, graphql } from "lightning/uiGraphQLApi";

// import getAllRecords from '@salesforce/apex/FSM_DependantPicklistcls.getAllSWRRecords';
// import getSWRAssetList from '@salesforce/apex/FSM_DependantPicklistcls.getSWRAssetList';

import getAllRecords from '@salesforce/apex/FSM_DependantPicklistcls.getAllSWRJobRecords';
import getSWRAssetList from '@salesforce/apex/FSM_DependantPicklistcls.getSWRJobAssetList';
import DCFINFRAOBJECT from '@salesforce/schema/FSM_InfraDataCaptureForm2__c';
import SWRTRANSASSET_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_SWRTransferredAsset__c';
import MAPPINGREQD_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_SIRFurtherMappingRequired__c';
import EQUIPMENTUSED_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_EquipmentUsed__c';
import JOBCOMPLETED_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_JobCompleted__c';
import PIPEDIAMETER_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_PipeDiameter__c';
import PIPEMATERIAL_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_PipeMaterial__c';
import EVNIMPSITE_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_RiskToAnEnvironmentalSite__c';
import SEWERSTATUS_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_SewerStatus__c';
import SEWERTYPE_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_SewerType__c';
import REASONFORREPAIR_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_ReasonForRepair__c';
import THIRDPARTYDAMAGE_FIELD from '@salesforce/schema/FSM_InfraDataCaptureForm2__c.FSM_ThirdPartyDamage__c';
import { createRecord, updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasDCFLimitReached from '@salesforce/apex/FSM_InvocableDcfConfiguration.hasDCFLimitReached';
import GRID_X from "@salesforce/schema/WorkStep.WorkOrder.FSM_Easting__c";
import GRID_Y from "@salesforce/schema/WorkStep.WorkOrder.FSM_Northing__c";


const GET_DCF = gql`
  query getDCF($workstepId: ID!) {
    uiapi {
      query {
        FSM_InfraDataCaptureForm2__c(
          where: {
            FSM_WorkStep__c: { eq: $workstepId },
            FSM_Status__c: { eq: "Completed" }
          }
        ) {
          edges {
            node {
              Id
              FSM_WorkStep__r {
                FSM_MaxInstance__c {
                  value
                }
              }
            }
          }
        }
      }
    }
  }
`;

export default class FsmSewerageJobFeedback extends LightningElement {
    
    //----Active Screens----
    @track Screen1 = true;
    @track Screen2 = false;
    @track Screen3 = false;
    @track Screen4 = false;
    @track Screen5 = false;
    @track Screen6 = false;
    @track Screen7 = false;
    //----------------------
    errormessages = [];//To Display Error Message
    isValidScreenOne = true; // To Check Validity of Screen 1
    isValidScreenTwo = true; // To Check Validity of Screen 2
    isValidScreenThree = true; // To Check Validity of Screen 3
    isValidScreenFour = true; // To Check Validity of Screen 4
    isValidScreenFive = true; // To Check Validity of Screen 5


    submitValues = {}; // To store values of all Screens

    //-----Screen1 values-----
    selectedasset;
    //-----Screen4 values-----
    ifNoGiveReason = false;
    //-----Screen6 values-----
    pipeDiameterOther = false;
    // Loader screen
    // @track isLoading = false;

    //To store all records values from Dependent Picklist Object
    @track objectApiName = DCFINFRAOBJECT; // To store object API name to fetch input variables
    @track dcfid;  // To store Id of DCF2 Record

    @track imageDataBefore = [];
    @track imageDataDuring = [];
    @track imageDataAfter = [];
    @track imageDataSite = [];
    @track imageDataAdditional = [];
    @track nextId = 0;
    @api selectedimgs;
    filesUploaded = [];
    hasMaxLimitReached = false;
    showSpinner = false;
    //dependency change
    isrepairjobs = false;
    isblockage = false;
    isnormal = false;
    connectedCallback() {
        // this.maxLimitCheck();
    }


    @track maxInstance
    querySize;
    @api recordId;
    get variables() {
        return { workstepId: this.recordId };
    }
    @wire(graphql, { query: GET_DCF, variables: '$variables' })
    dataCaptureFormInfra({ error, data }) {
        if (data) {
            if (data.uiapi.query.FSM_InfraDataCaptureForm2__c && data.uiapi.query.FSM_InfraDataCaptureForm2__c.edges) {
                data.uiapi.query.FSM_InfraDataCaptureForm2__c.edges.forEach(edge => {
                    this.querySize = data.uiapi.query.FSM_InfraDataCaptureForm2__c.edges.length; // Store the size of the returned query
                    this.maxInstance = edge.node.FSM_WorkStep__r.FSM_MaxInstance__c.value; // Store the value
                    // Check if max limit is reached
                    if (this.maxInstance <= this.querySize) {
                        this.hasMaxLimitReached = true;
                    } else {
                        
                        this.hasMaxLimitReached = false;
                    }
                });
            }
        } else if (error) {
            console.error('Error:', error); // Debugging log
        }
    }
    // Mrthod is added to get work order values and pre-populate them on form.== SFL-1053
    @wire(getRecord, { recordId: '$recordId', fields: [GRID_X,GRID_Y]})
    WO_values({ error, data }){
        if(data){
            console.log("test after adding string")
            console.log(data)
            this.gridreferencex = getFieldValue(data, GRID_X).toString(); 
            this.gridreferencey = getFieldValue(data, GRID_Y).toString(); 
        }else if (error) {
            console.error('Error:', error); // Debugging log
        }
    }


    //if maximum number of allowed DCF forms completed, prevent the user from creating new DCF records.
    async maxLimitCheck() {
        try {
            this.showSpinner = true;
            this.hasMaxLimitReached = await hasDCFLimitReached({ workstepId: this.recordId });
            console.log('hasMaxLimitReached', this.hasMaxLimitReached);
        } catch (error) {
            console.error('An error has occured while fetching max instance', error);
        } finally {
            this.showSpinner = false;
        }
    }


    //Logic to select 'Before work photos' - method called from HTML
    handleBeforeWorkPhotoSelect(event) {
        const fileCount = event.target.files.length + this.imageDataBefore.length;
        console.log('fileCount--->', fileCount);
        if (fileCount < 1) {
            // Do Nothing
        } else {
            this.imageCompressAndValidation(event, this.imageDataBefore);
        }
    }


    //Logic to read and preview the selected 'Before work photos' - method called from handleBeforeWorkPhotoSelect() method within .js file
    // async beforeWorkSelectedPhotos(event) {
    //     // 
    //     const maxFileSize = 6 * 1024 * 1024; // 6MB in bytes
    //     const validFiles = [];
    //     let removedFiles = [];
    //     const dfiles = event.target.files;
    //     const numFiles = dfiles.length;

    //     for (let i = 0; i < numFiles; i++) {
    //         let dfile = dfiles[i];
    //         const compressedBlob = await this.compressImage(dfile);
    //         if (compressedBlob.size <= maxFileSize) {
    //             validFiles.push(dfile); // Keep files <= 6MB
    //             const data = await this.blobToDataURL(compressedBlob);
    //             let metadata = await this.readFileMetadata(dfile);
    //             this.imageDataBefore.push({
    //                 id: this.nextId++,
    //                 data: data,
    //                 metadata: metadata,
    //                 className: ''
    //             });

    //         } else {
    //             removedFiles.push(dfile); // Track files that are too large
    //         }
    //     }
    //     // Notify the user about removed files
    //     if (removedFiles.length > 0) {
    //         this.showToast(
    //             'Files Too Large',
    //             `Exceed the 6MB size limit and were removed.`,
    //             'error'
    //         );
    //     }
    // }


    async imageCompressAndValidation(event, arr) {
        // 
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
                arr.push({
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
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
    // // Function to compress the image using a canvas
    // compressImage(file) {
    //     // console.log('file--->', file);
    //     // console.log('photos arr--->', JSON.stringify(this.imageData.size));
    //     return new Promise((resolve, reject) => {
    //         const reader = new FileReader();
    //         reader.onload = (event) => {
    //             const img = new Image();
    //             img.onload = () => {
    //                 const canvas = document.createElement('canvas');
    //                 const ctx = canvas.getContext('2d');

    //                 // Define max dimensions for the image
    //                 const maxWidth = 800;
    //                 const maxHeight = 800;
    //                 let width = img.width;
    //                 let height = img.height;

    //                 // Adjust image size based on max dimensions while maintaining the aspect ratio
    //                 if (width > height) {
    //                     if (width > maxWidth) {
    //                         height = (height * maxWidth) / width;
    //                         width = maxWidth;
    //                     }
    //                 } else {
    //                     if (height > maxHeight) {
    //                         width = (width * maxHeight) / height;
    //                         height = maxHeight;
    //                     }
    //                 }

    //                 canvas.width = width;
    //                 canvas.height = height;
    //                 ctx.drawImage(img, 0, 0, width, height);

    //                 // Convert the canvas to a Blob with a specific image quality
    //                 canvas.toBlob(
    //                     (blob) => {
    //                         if (blob) {
    //                             resolve(blob);
    //                         } else {
    //                             reject(new Error('Image compression failed'));
    //                         }
    //                     },
    //                     'image/*', // Image format
    //                     0.9 // Compression quality (70%)
    //                 );
    //             };
    //             img.onerror = reject;
    //             img.src = event.target.result;
    //         };
    //         reader.onerror = reject;
    //         reader.readAsDataURL(file);
    //     });
    // }
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
                    }, file.type, 0.7); // Adjust compression quality (0.7 is 70%)
                };
                img.src = reader.result;
            };

            reader.readAsDataURL(file);
        });
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

    async readFileMetadata(file) {
        // console.log('file--->',file.name);
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

    //Toggle the 'selected' property when 'Before work photos' are clicked - method called from HTML
    handleBeforeWorkImageClick(event) {
        const fileIdToSelect = event.currentTarget.dataset.id;
        for (let i = 0; i < this.imageDataBefore.length; i++) {
            const imgD = this.imageDataBefore[i].id;
            if (imgD == fileIdToSelect) {
                this.imageDataBefore[i].className = 'selected';
            } else {
                this.imageDataBefore[i].className = '';
            }
        }
    }

    //Logic to delete 'Before work photos' after selecting - method called from HTML
    handleBeforeWorkDeleteClick(event) {
        const fileIdToDelete = event.currentTarget.dataset.id;

        const newImgSet = [];
        for (let i = 0; i < this.imageDataBefore.length; i++) {
            const imgD = this.imageDataBefore[i].id;

            if (imgD != fileIdToDelete) {
                newImgSet.push(this.imageDataBefore[i]);
            }
        }
        this.imageDataBefore = newImgSet;
    }

    //Logic to select 'During work photos' - method called from HTML
    handleDuringWorkPhotoSelect(event) {
        const fileCount = event.target.files.length + this.imageDataDuring.length;
        console.log('fileCount-->', fileCount)
        if (fileCount < 1) {
            // Do Nothing
        } else {
            this.imageCompressAndValidation(event, this.imageDataDuring);
        }
    }

    //Logic to read and preview the selected 'During work photos' - method called from duringWorkSelectedPhotos() method within .js file
    async duringWorkSelectedPhotos(event) {
        const dfiles = event.target.files;
        const numFiles = dfiles.length;

        for (let i = 0; i < numFiles; i++) {
            let dfile = dfiles[i];

            let data = await this.readFile(dfile);
            let metadata = await this.readMetadata(dfile);

            this.imageDataDuring.push({
                id: this.nextId++,
                data: data,
                metadata: metadata,
                className: ''
            });
        }
    }

    // Toggle the 'selected' property when 'During work photos' are clicked - method called from HTML
    handleDuringWorkImageClick(event) {
        const fileIdToSelect = event.currentTarget.dataset.id;
        for (let i = 0; i < this.imageDataDuring.length; i++) {
            const imgD = this.imageDataDuring[i].id;

            if (imgD == fileIdToSelect) {
                this.imageDataDuring[i].className = 'selected';
            } else {
                this.imageDataDuring[i].className = '';
            }
        }
    }

    //Logic to delete 'During work photos' after selecting - method called from HTML
    handleDuringWorkImageDeleteClick(event) {
        const fileIdToDelete = event.currentTarget.dataset.id;

        const newImgSet = [];
        for (let i = 0; i < this.imageDataDuring.length; i++) {
            const imgD = this.imageDataDuring[i].id;

            if (imgD != fileIdToDelete) {
                newImgSet.push(this.imageDataDuring[i]);
            }
        }
        this.imageDataDuring = newImgSet;
    }

    //Logic to select 'After work photos' - method called from HTML
    handleAfterWorkPhotoSelect(event) {
        const fileCount = event.target.files.length + this.imageDataAfter.length;
        if (fileCount < 1) {
            // Do Nothing
        } else {
            this.imageCompressAndValidation(event, this.imageDataAfter);
        }
    }

    //Logic to read and preview the selected 'After work photos' - method called from handleAfterWorkPhotoSelect() method within .js file
    async afterWorkSelectedPhotos(event) {
        const dfiles = event.target.files;
        const numFiles = dfiles.length;

        for (let i = 0; i < numFiles; i++) {
            let dfile = dfiles[i];

            let data = await this.readFile(dfile);
            let metadata = await this.readMetadata(dfile);

            this.imageDataAfter.push({
                id: this.nextId++,
                data: data,
                metadata: metadata,
                className: ''
            });
        }
    }

    //Toggle the 'selected' property when 'After work photos' are clicked - method called from HTML
    handleAfterWorkImageClick(event) {
        const fileIdToSelect = event.currentTarget.dataset.id;
        for (let i = 0; i < this.imageDataAfter.length; i++) {
            const imgD = this.imageDataAfter[i].id;

            if (imgD == fileIdToSelect) {
                this.imageDataAfter[i].className = 'selected';
            } else {
                this.imageDataAfter[i].className = '';
            }
        }
    }

    //Logic to delete 'After work photos' after selecting - method called from HTML
    handleAfterWorkImageDeleteClick(event) {
        const fileIdToDelete = event.currentTarget.dataset.id;

        const newImgSet = [];
        for (let i = 0; i < this.imageDataAfter.length; i++) {
            const imgD = this.imageDataAfter[i].id;

            if (imgD != fileIdToDelete) {
                newImgSet.push(this.imageDataAfter[i]);
            }
        }
        this.imageDataAfter = newImgSet;
    }

    //Logic to select 'Photos of site as left' - method called from HTML
    handleSitePhotoSelect(event) {
        const fileCount = event.target.files.length + this.imageDataSite.length;
        if (fileCount < 1) {
            // Do Nothing
        } else {
            this.imageCompressAndValidation(event, this.imageDataSite);
        }
    }

    //Logic to read and preview the selected 'Photos of site as left' - method called from handleSitePhotoSelect() method within .js file
    async siteSelectedPhotos(event) {
        const dfiles = event.target.files;
        const numFiles = dfiles.length;

        for (let i = 0; i < numFiles; i++) {
            let dfile = dfiles[i];

            let data = await this.readFile(dfile);
            let metadata = await this.readMetadata(dfile);

            this.imageDataSite.push({
                id: this.nextId++,
                data: data,
                metadata: metadata,
                className: ''
            });
        }
    }

    //Toggle the 'selected' property when 'Photos of site as left' are clicked - method called from HTML
    handleSiteImageClick(event) {
        const fileIdToSelect = event.currentTarget.dataset.id;
        for (let i = 0; i < this.imageDataSite.length; i++) {
            const imgD = this.imageDataSite[i].id;

            if (imgD == fileIdToSelect) {
                this.imageDataSite[i].className = 'selected';
            } else {
                this.imageDataSite[i].className = '';
            }
        }
    }

    //Logic to delete 'Photos of site as left' after selecting - method called from HTML
    handleSiteImageDeleteClick(event) {
        const fileIdToDelete = event.currentTarget.dataset.id;

        const newImgSet = [];
        for (let i = 0; i < this.imageDataSite.length; i++) {
            const imgD = this.imageDataSite[i].id;

            if (imgD != fileIdToDelete) {
                newImgSet.push(this.imageDataSite[i]);
            }
        }
        this.imageDataSite = newImgSet;
    }

    //Logic to select 'Any additional photos for further FOW' - method called from HTML
    handleAdditionalPhotoSelect(event) {
        const fileCount = event.target.files.length + this.imageDataAdditional.length;
        this.imageCompressAndValidation(event, this.imageDataAdditional);
    }

    //Logic to read and preview the selected 'Any additional photos for further FOW' - method called from handleAdditionalPhotoSelect() method within .js file
    async additionalSelectedPhotos(event) {
        const dfiles = event.target.files;
        const numFiles = dfiles.length;

        for (let i = 0; i < numFiles; i++) {
            let dfile = dfiles[i];

            let data = await this.readFile(dfile);
            let metadata = await this.readMetadata(dfile);

            this.imageDataAdditional.push({
                id: this.nextId++,
                data: data,
                metadata: metadata,
                className: ''
            });
        }
    }

    //Toggle the 'selected' property when 'Any additional photos for further FOW' are clicked - method called from HTML
    handleAdditionalImageClick(event) {
        const fileIdToSelect = event.currentTarget.dataset.id;
        for (let i = 0; i < this.imageDataAdditional.length; i++) {
            const imgD = this.imageDataAdditional[i].id;

            if (imgD == fileIdToSelect) {
                this.imageDataAdditional[i].className = 'selected';
            } else {
                this.imageDataAdditional[i].className = '';
            }
        }
    }

    //Logic to delete 'Any additional photos for further FOW' after selecting - method called from HTML
    handleAdditionalImageDeleteClick(event) {
        const fileIdToDelete = event.currentTarget.dataset.id;

        const newImgSet = [];
        for (let i = 0; i < this.imageDataAdditional.length; i++) {
            const imgD = this.imageDataAdditional[i].id;

            if (imgD != fileIdToDelete) {
                newImgSet.push(this.imageDataAdditional[i]);
            }
        }
        this.imageDataAdditional = newImgSet;
    }

    // Read image data from a file selected in a browser
    // This is standard JavaScript, not unique to LWC
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


    // Photo Upload  start
    @track filesData = [];
    createcontentversion(dcfrecordid) {

        //Photo to upload imageDataBefore
        if (JSON.stringify(this.imageDataBefore) != '[]') {
            this.imageDataBefore.forEach((element, index) => {
                const imageDataBeforeupload = JSON.stringify(element.data);

                const filecontentdata = imageDataBeforeupload.split(',')[1];
                const removeLast3 = filecontentdata.slice(0, -1);

                const metadata = element.metadata.fileName;
                const fileext = element.metadata.ext;

                //  const filenamewithext=metadata+'.'+fileext;
                this.filesData.push({ 'fileName': 'BeforeWork Photo' + (index + 1) + '.' + fileext, 'fileContent': removeLast3 });
            });
        }
        //Photo to upload imageDataDuring
        if (JSON.stringify(this.imageDataDuring) != '[]') {
            this.imageDataDuring.forEach((element, index) => {
                const imageDataDuringupload = JSON.stringify(element.data);

                const filecontentdata = imageDataDuringupload.split(',')[1];
                const removeLast3 = filecontentdata.slice(0, -1);

                const metadata = element.metadata.fileName;
                const fileext = element.metadata.ext;

                //  const filenamewithext=metadata+'.'+fileext;
                this.filesData.push({ 'fileName': 'DuringWork Photo' + (index + 1) + '.' + fileext, 'fileContent': removeLast3 });
            });
        }
        //Photo to upload imageDataAfter
        if (JSON.stringify(this.imageDataAfter) != '[]') {
            this.imageDataAfter.forEach((element, index) => {
                const imageDataAfterupload = JSON.stringify(element.data);

                const filecontentdata = imageDataAfterupload.split(',')[1];
                const removeLast3 = filecontentdata.slice(0, -1);

                const metadata = element.metadata.fileName;
                const fileext = element.metadata.ext;

                //  const filenamewithext=metadata+'.'+fileext;
                this.filesData.push({ 'fileName': 'AfterWork Photo' + (index + 1) + '.' + fileext, 'fileContent': removeLast3 });
            });
        }
        //Photo to upload imageDataSite
        if (JSON.stringify(this.imageDataSite) != '[]') {
            this.imageDataSite.forEach((element, index) => {
                const imageDataSiteupload = JSON.stringify(element.data);

                const filecontentdata = imageDataSiteupload.split(',')[1];
                const removeLast3 = filecontentdata.slice(0, -1);

                const metadata = element.metadata.fileName;
                const fileext = element.metadata.ext;

                //  const filenamewithext=metadata+'.'+fileext;
                this.filesData.push({ 'fileName': 'SiteAsLeft Photo' + (index + 1) + '.' + fileext, 'fileContent': removeLast3 });
            });
        }
        //Photo to upload imageDataAdditional
        if (JSON.stringify(this.imageDataAdditional) != '[]') {
            this.imageDataAdditional.forEach((element, index) => {
                const imageDataAdditionalupload = JSON.stringify(element.data);

                const filecontentdata = imageDataAdditionalupload.split(',')[1];
                const removeLast3 = filecontentdata.slice(0, -1);

                const metadata = element.metadata.fileName;
                const fileext = element.metadata.ext;

                //  const filenamewithext=metadata+'.'+fileext;
                this.filesData.push({ 'fileName': 'Additional Photo' + (index + 1) + '.' + fileext, 'fileContent': removeLast3 });
            });
        }
        let allcvtoinsert = [];

        if (this.filesData.length == 0) {

            this.showToast('Error!', 'error', 'Select files for upload');
            return;
        } else {

            for (var i = 0; i < this.filesData.length; i++) {

                const fileData = {
                    Title: this.filesData[i].fileName,
                    PathOnClient: this.filesData[i].fileName,
                    VersionData: this.filesData[i].fileContent,
                    FSM_RelatedrecordId__c: dcfrecordid

                }
                allcvtoinsert.push(fileData);

            }

            this.cvinsert(allcvtoinsert, dcfrecordid);
        }


    }

    cvinsert(cvarr, dcfrecordid) {
        cvarr.forEach((record, index) => {

            const payload = { apiName: 'ContentVersion', fields: record };

            createRecord(payload).then(cversion => {
                this.cvid = cversion.id;
                if (index == cvarr.length - 1) {
                    this.filesData = [];
                }
            }).catch(error => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                this.error = error;
            });



        });
    }
    @wire(getAllRecords)
    wiredAllRecords({ data, error }) {
        if (data) {
            this.allRecords = JSON.stringify(data);
        } else if (error) {
            console.error('Error allrecords ', error);
        }
    }

    @track assetRecords = [];
    @track taskRecords = [];
    @track recipientRecords = [];

    @track selectedAsset;
    @track selectedTask;
    @track selectedTaskLabel;
    @track selectedRecipient;
    @track uIDAssetWorkedOn;
    @track gridreferencex;
    @track gridreferencey;
    @track pipeLengthCCTV;
    @track pipeLenCleasedRootCut;
    @track repairLength;
    @track pipeDiameterOtherValue;
    @track noIfNoWhy;
    @track repairDepth;
    @track comment;


    @wire(getSWRAssetList)
    wiredAssetList({ data, error }) {
        if (data) {
            this.assetRecords = data.assetList;
            this.taskRecords = data.taskList;
            this.recipientRecords = data.recipientList;

        } else if (error) {
            console.error('Error asset ', error);
        }
    }

    @track filteredTask = [];
    @track filteredRecipient = [];

    handleAssetChange(event) {

        this.filteredTechnique = [];

        this.selectedAsset = event.detail.value;
        console.log('selectedAsset', this.selectedAsset);
        let dataObj = JSON.parse(this.allRecords);

        let dupTaskCheck = [];
        let filteredTaskOps = [];


        dataObj.forEach(record => {

            if (this.selectedAsset === record.FSM_SFAsset__c && !dupTaskCheck.includes(record.FSM_SFTask__c)) {
                let exists = this.taskRecords.find(obj => obj.value === record.FSM_SFTask__c);
                let exitsLabel = this.taskRecords.find(obj => obj.label === record.FSM_SFTask__c);
                filteredTaskOps.push(exists);
                dupTaskCheck.push(record.FSM_SFTask__c);
            }
        });
        this.filteredTask = filteredTaskOps;
    }




    handleTaskChange(event) {
        this.selectedTask = event.detail.value;
        console.log('selectedTask', this.selectedTask);
        let dataObj = JSON.parse(this.allRecords);

        let dupRecipientCheck = [];
        let filteredRecipientOps = [];

        dataObj.forEach(record => {

            if (this.selectedAsset === record.FSM_SFAsset__c && this.selectedTask === record.FSM_SFTask__c && !dupRecipientCheck.includes(record.FSM_SFJob__c)) {
                let exists = this.recipientRecords.find(obj => obj.value === record.FSM_SFJob__c);

                filteredRecipientOps.push(exists);
                dupRecipientCheck.push(record.FSM_SFJob__c);
            }
        });

        this.filteredRecipient = filteredRecipientOps;
        this.getLabelByValue(this.selectedTask);

    }
    getLabelByValue(selectedTaskValue) {
        for (const item of this.taskRecords) {
            if (item.value === selectedTaskValue) {
                this.selectedTaskLabel = item.label.toLowerCase();
            }
        }
    }

    handleRecipientChange(event) {

        this.selectedRecipient = event.detail.value;
    }

    // onChange Handler
    handleUIDAssetWorkedChange(event) {
        this.uIDAssetWorkedOn = event.detail.value;
    }

    handlegridxchange(event) {
        this.gridreferencex = event.detail.value;
    }

    handlegridychange(event) {
        this.gridreferencey = event.detail.value;
    }
    handlepipeLengthCCTVChange(event) {
        this.pipeLengthCCTV = event.detail.value;
    }
    handlepipeLenCleansedRootChange(event) {
        this.pipeLenCleasedRootCut = event.detail.value;
    }

    handlerepairLengthChange(event) {
        this.repairLength = event.detail.value;
    }

    handleRepairDepthChange(event) {
        this.repairDepth = event.detail.value;
    }
    handleCommentchange(event) {
        this.comment = event.detail.value;
    }

    handlepipeDiameterOtherChange(event) {
        this.pipeDiameterOtherValue = event.detail.value;
    }

    handlenoIfNoWhyChange(event) {
        this.noIfNoWhy = event.detail.value;
    }



    //Arnob - Description : To fetch Picklist values of 'SWR Transferred Asset' from DCF Infra Object
    @track swrTransferredAssetOptions = [];
    @track selectedSWRTransferredAsset;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: SWRTRANSASSET_FIELD
    }) swrTransAsstValues({ error, data }) {
        if (data) {
            this.swrTransferredAssetOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleChangeSWRTransferredAsset(event) {
        this.selectedSWRTransferredAsset = event.detail.value;
    }

    //Description : To fetch Picklist values of 'FSM_SIRFurtherMappingRequired__c' from DCF Infra Object2
    @track swrFurtherMappingReqOptions = [];
    @track selectedFurtherMappingReq;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: MAPPINGREQD_FIELD
    }) swrFurtherMappingValues({ error, data }) {
        if (data) {
            this.swrFurtherMappingReqOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleChangeFurtherMappingReq(event) {
        this.selectedFurtherMappingReq = event.detail.value;
    }

    //Description : To fetch Picklist values of 'Equipment Used' from DCF Infra Object 2
    @track equipmentUsedOptions = [];
    @track selectedEquipmentaUsed;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: EQUIPMENTUSED_FIELD
    }) equipmentUsedValues({ error, data }) {
        if (data) {
            this.equipmentUsedOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Handle Change Method
    handleEquipmentUsedChange(event) {
        this.selectedEquipmentaUsed = event.detail.value;
    }

    //Description : To fetch Picklist values of 'Equipment Used' from DCF Infra Object 2
    @track jobCompletedOptions = [];
    @track selectedjobCompleted;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: JOBCOMPLETED_FIELD
    }) jobCompletedsValues({ error, data }) {
        if (data) {
            this.jobCompletedOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Handle Change Method
    handlejobCompletedChanges(event) {
        this.selectedjobCompleted = event.detail.value;
        if (this.selectedjobCompleted == 'No') {
            this.ifNoGiveReason = true;
        }
        else if (this.selectedjobCompleted == 'Yes') {
            this.ifNoGiveReason = false;
        }
    }


    //Description : To fetch Picklist values of 'Job Completed' from DCF Infra Object 2
    @track jobCompletedOptions = [];
    @track jobCompleted;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: JOBCOMPLETED_FIELD
    }) jobCompletedValues({ error, data }) {
        if (data) {
            this.jobCompletedOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Handle Change Method
    handleJobCompletedChange(event) {
        this.jobCompleted = event.detail.value;
    }

    //   Is there a risk to an environmental important site? 
    @track evnImpSiteOptions = [];
    @track evnImpSite;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: EVNIMPSITE_FIELD
    }) evnImpSiteValues({ error, data }) {
        if (data) {
            this.evnImpSiteOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    handleEvnImpSiteChange(event) {
        this.evnImpSite = event.detail.value;
    }

    //   Pipe Diameter 
    @track pipeDiameterOptions = [];
    @track selectedPipeDiameter;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: PIPEDIAMETER_FIELD
    }) pipeDiameterValues({ error, data }) {
        if (data) {
            this.pipeDiameterOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    handlePipeDiameterChange(event) {
        this.selectedPipeDiameter = event.detail.value;
        if (this.selectedPipeDiameter == 'Other (Please Specify)') {
            this.pipeDiameterOther = true;
        }
        else if (this.selectedPipeDiameter != 'Other (Please Specify)') {
            this.pipeDiameterOther = false;
        }
    }

    //  To get Pipe Material Picklist value
    @track pipeMaterialOption = [];
    @track selectedPipeMaterial;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: PIPEMATERIAL_FIELD
    }) pipeMaterialValues({ error, data }) {
        if (data) {
            this.pipeMaterialOption = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    handlePipeMaterialChange(event) {
        this.selectedPipeMaterial = event.detail.value;
    }


    //Description : To fetch Picklist values of 'Sewer Status' from DCF Infra2 Object 
    @track sewerStatusOptions = [];
    @track selectedSewerStatus;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: SEWERSTATUS_FIELD
    }) sewerStatusValues({ error, data }) {
        if (data) {
            this.sewerStatusOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Handle Change Method
    handleSewerStatusChange(event) {
        this.selectedSewerStatus = event.detail.value;
    }
    //Description : To fetch Picklist values of 'Sewer Type' from DCF Infra2 Object 
    @track sewerTypeOption = [];
    @track selectedSewerType;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: SEWERTYPE_FIELD
    }) sewerTypeValues({ error, data }) {
        if (data) {
            this.sewerTypeOption = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    // Handle Change Method
    handleSewerTypeChange(event) {
        this.selectedSewerType = event.detail.value;
    }


    //Description : To fetch Picklist values of 'Sewer Type' from DCF Infra Object
    @track reasonForRepairOption = [];
    @track selectedReasonForRepair;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: REASONFORREPAIR_FIELD
    }) reasonForRepairValues({ error, data }) {
        if (data) {
            this.reasonForRepairOption = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleReasonForRepairChange(event) {
        this.selectedReasonForRepair = event.detail.value;
    }


    //Description : To fetch Picklist values of 'Sewer Type' from DCF Infra Object
    @track thirdPartyDamageOption = [];
    @track selectedThirdPartyDamage;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: THIRDPARTYDAMAGE_FIELD
    }) thirdPartyDamageValues({ error, data }) {
        if (data) {
            this.thirdPartyDamageOption = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleThirdPartyDamageChange(event) {
        this.selectedThirdPartyDamage = event.detail.value;
    }

    // Description : Method to check validation of Screen 1
    handleSectionOnevalidation() {
        this.errormessages = [];
        this.isValidScreenOne = true;
        if (this.imageDataBefore.length == 0 || this.imageDataDuring.length == 0 ||
            this.imageDataAfter.length == 0 || this.imageDataSite.length == 0) {
            this.errormessages.push('Please select at least 1 photo.');
            this.isValidScreenOne = false;
        }


    }

    // Description : Method to check validation of Screen 2
    handleSectionTwovalidation() {
        this.errormessages = [];
        this.isValidScreenTwo = true;

        if ((this.selectedAsset == '' || this.selectedAsset == null) &&
            (this.selectedTask == '' || this.selectedTask == null) &&
            (this.selectedRecipient == '' || this.selectedRecipient == null) &&
            (this.selectedSWRTransferredAsset == '' || this.selectedSWRTransferredAsset == null) &&
            (this.uIDAssetWorkedOn == null || this.uIDAssetWorkedOn.length == 0) &&
            (this.gridreferencex == null || this.gridreferencex.length == 0) &&
            (this.gridreferencey == null || this.gridreferencey.length == 0) &&
            (this.selectedFurtherMappingReq == '' || this.selectedFurtherMappingReq == null) &&
            (this.depthOfCover == null || this.depthOfCover == '')) {

            this.errormessages.push('Please enter data in all the required fields');
            this.isValidScreenTwo = false;
        }
        else if (this.selectedAsset == '' || this.selectedAsset == null) {

            this.errormessages.push('Please select a value in Asset');

            this.isValidScreenTwo = false;
        }
        else if (this.selectedTask == '' || this.selectedTask == null) {

            this.errormessages.push('Please select a value in Task');

            this.isValidScreenTwo = false;
        }
        else if (this.selectedRecipient == '' || this.selectedRecipient == null) {

            this.errormessages.push('Please select a value in Recipient');

            this.isValidScreenTwo = false;
        }
        else if (this.selectedSWRTransferredAsset == '' || this.selectedSWRTransferredAsset == null) {

            this.errormessages.push('Please select a value in Transferred Asset');

            this.isValidScreenTwo = false;
        }
        else if (this.uIDAssetWorkedOn == null || this.uIDAssetWorkedOn.length == 0) {

            this.errormessages.push('Please select a value in UID OF ASSET THAT WAS WORKED ON');

            this.isValidScreenTwo = false;
        }
        else if (this.gridreferencex == '' || this.gridreferencex == null || this.gridreferencex < 240000 || this.gridreferencex > 550000) {

            this.errormessages.push('GRID REFERENCE X should lie between 240000 and 550000');

            this.isValidScreenTwo = false;
        }
        else if (this.gridreferencey == '' || this.gridreferencey == null || this.gridreferencey < 170000 || this.gridreferencey > 440000) {

            this.errormessages.push('GRID REFERENCE Y should lie between 170000 and 440000');

            this.isValidScreenTwo = false;
        }
        else if (this.selectedFurtherMappingReq == '' || this.selectedFurtherMappingReq == null) {

            this.errormessages.push('Please enter value in IS FURTHUR MAPPING REQUIRED');

            this.isValidScreenTwo = false;
        } else {
            this.isValidScreenTwo = true;
        }
    }

    // Description : Method to check validation of Screen 3
    handleSectionThreevalidation() {
        this.errormessages = [];
        this.isValidScreenThree = true;
        if ((this.selectedEquipmentaUsed == '' || this.selectedEquipmentaUsed == null) &&
            (this.pipeLengthCCTV == null || this.pipeLengthCCTV.length == 0) &&
            (this.pipeLenCleasedRootCut == null || this.pipeLenCleasedRootCut.length == 0)) {

            this.errormessages.push('Please enter data in all the required fields');
            this.isValidScreenThree = false;
        }
        else if (this.selectedEquipmentaUsed == '' || this.selectedEquipmentaUsed == null) {

            this.errormessages.push('Please select a value in Equipment Used');
            this.isValidScreenThree = false;
        }
        else if (this.selectedjobCompleted == 'No' && (this.noIfNoWhy == null || this.noIfNoWhy.length == 0)) {
            this.errormessages.push('Please select a value in No- If no why?');
            this.isValidScreenThree = false;
        }
        else if (this.pipeLengthCCTV == '' || this.pipeLengthCCTV == null) {

            this.errormessages.push('Please enter a value in Pipe Length CCTV’d (m)');
            this.isValidScreenThree = false;
        }
        else if (this.pipeLenCleasedRootCut == '' || this.pipeLenCleasedRootCut == null) {

            this.errormessages.push('Please enter a value in Pipe Length Cleansed/Root cut (m)');
            this.isValidScreenThree = false;
        }
        else {
            this.isValidScreenThree = true;
        }

    }

    // Description : Method to check validation of Screen 4
    handleSectionFourvalidation() {
        this.errormessages = [];
        this.isValidScreenFour = true;
        if ((this.evnImpSite == '' || this.evnImpSite == null)) {
            this.errormessages.push('Please enter data in Is there a risk to an environmental important site?');
            this.isValidScreenFour = false;
        }
        else {
            this.isValidScreenFour = true;
        }
    }
    // Description : Method to check validation of Screen 5
    handleSectionFivevalidation() {
        this.errormessages = [];
        this.isValidScreenFive = true;
        if (this.selectedPipeDiameter == 'Other (Please Specify)' && (this.pipeDiameterOtherValue == null || this.pipeDiameterOtherValue.length == 0)) {
            this.errormessages.push('Please enter a value in Pipe diameter other');
            this.isValidScreenFive = false;
        }
        else {
            this.isValidScreenFive = true;
        }
    }

    // Description : Method to save and create DCF records
    async handleSave(event) {
        console.log('which flow', this.isnormal, 'r ', this.isrepairjobs, 'b ', this.isblockage);
        this.submitValues.FSM_WorkStep__c = this.recordId;
        this.submitValues.FSM_Status__c = 'Completed';
        this.submitValues.FSM_FormType__c = 'Sewerage-Job Feedback';
        this.submitValues.FSM_AssetSewerage__c = this.selectedAsset;
        this.submitValues.FSM_TaskSewerage__c = this.selectedTask;
        this.submitValues.FSM_SWRJobRecipient__c = this.selectedRecipient;
        this.submitValues.FSM_SWRTransferredAsset__c = this.selectedSWRTransferredAsset;
        this.submitValues.FSM_UIDOfAsset__c = this.uIDAssetWorkedOn;
        this.submitValues.FSM_GridsReferenceX__c = this.gridreferencex;
        this.submitValues.FSM_GridsReferenceY__c = this.gridreferencey;
        this.submitValues.FSM_SIRFurtherMappingRequired__c = this.selectedFurtherMappingReq;
        //blockage start
        if (this.isblockage == true) {
            console.log('inside if blockage');
            this.submitValues.FSM_EquipmentUsed__c = this.selectedEquipmentaUsed;
            this.submitValues.FSM_JobCompleted__c = this.selectedjobCompleted;
            this.submitValues.FSM_NoGiveReason__c = this.noIfNoWhy;
            this.submitValues.FSM_PipeLengthCCTVd__c = this.pipeLengthCCTV;
            this.submitValues.FSM_PipeLengthCleansedRootcut__c = this.pipeLenCleasedRootCut;
        } else {
            console.log('inside else blockage');
            this.submitValues.FSM_EquipmentUsed__c = '';
            this.submitValues.FSM_JobCompleted__c = '';
            this.submitValues.FSM_NoGiveReason__c = '';
            this.submitValues.FSM_PipeLengthCCTVd__c = '';
            this.submitValues.FSM_PipeLengthCleansedRootcut__c = '';
        }

        //blockage end

        this.submitValues.FSM_RiskToAnEnvironmentalSite__c = this.evnImpSite;
        //repair jobs start
        if (this.isrepairjobs == true) {
            console.log('inside if repair');
            this.submitValues.FSM_RepairLength__c = this.repairLength;
            this.submitValues.FSM_PipeDiameter__c = this.selectedPipeDiameter;
            this.submitValues.FSM_PipeDiameterOther__c = this.pipeDiameterOtherValue;
            this.submitValues.FSM_PipeMaterial__c = this.selectedPipeMaterial;
            this.submitValues.FSM_SewerStatus__c = this.selectedSewerStatus;
            this.submitValues.FSM_RepairDepth__c = this.repairDepth;
            this.submitValues.FSM_SewerType__c = this.selectedSewerType;
            this.submitValues.FSM_ReasonForRepair__c = this.selectedReasonForRepair;
            this.submitValues.FSM_ThirdPartyDamage__c = this.selectedThirdPartyDamage;
        } else {
            console.log('inside else repair');
            this.submitValues.FSM_RepairLength__c = '';
            this.submitValues.FSM_PipeDiameter__c = '';
            this.submitValues.FSM_PipeDiameterOther__c = '';
            this.submitValues.FSM_PipeMaterial__c = '';
            this.submitValues.FSM_SewerStatus__c = '';
            this.submitValues.FSM_RepairDepth__c = '';
            this.submitValues.FSM_SewerType__c = '';
            this.submitValues.FSM_ReasonForRepair__c = '';
            this.submitValues.FSM_ThirdPartyDamage__c = '';
        }

        //repair jobs end
        this.submitValues.FSM_Comments__c = this.comment;

        const recordInput = { apiName: DCFINFRAOBJECT.objectApiName, fields: this.submitValues };
        this.dcfid = await createRecord(recordInput).catch(error => {
            console.log('error', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while creating DCF Record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
        this.updateWorkStep(this.dcfid.id);
    }


    //update the workstep field of dcf infra record
    async updateWorkStep(dcfid) {
        let workStep = {};
        workStep.Id = this.recordId;
        workStep.FSM_IsCompleted__c = true;
        workStep.Status = 'Completed';
        updateRecord({ fields: workStep }).then(() => {
            this.createcontentversion(this.dcfid.id);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'WorkStep Completed!',
                    variant: 'success',
                }),
            )
        }).then(j => {
            this.Screen6 = false;
            this.Screen7 = true;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    //---------Start of Saving Screen Values Methods-----------
    saveScreenTwoValues() {
        this.submitValues.FSM_AssetSewerage__c = this.selectedAsset;
        this.submitValues.FSM_TaskSewerage__c = this.selectedTask;
        this.submitValues.FSM_SWRJobRecipient__c = this.selectedRecipient;
        this.submitValues.FSM_SWRTransferredAsset__c = this.selectedSWRTransferredAsset;
        this.submitValues.FSM_UIDOfAsset__c = this.uIDAssetWorkedOn;
        this.submitValues.FSM_GridsReferenceX__c = this.gridreferencex;
        this.submitValues.FSM_GridsReferenceY__c = this.gridreferencey;
        this.submitValues.FSM_SIRFurtherMappingRequired__c = this.selectedFurtherMappingReq;
    }

    saveScreenThreeValues() {
        this.submitValues.FSM_EquipmentUsed__c = this.selectedEquipmentaUsed;
        this.submitValues.FSM_JobCompleted__c = this.selectedjobCompleted;
        this.submitValues.FSM_NoGiveReason__c = this.noIfNoWhy;
        this.submitValues.FSM_PipeLengthCCTVd__c = this.pipeLengthCCTV;
        this.submitValues.FSM_PipeLengthCleansedRootcut__c = this.pipeLenCleasedRootCut;

    }

    saveScreenFourValues() {
        this.submitValues.FSM_RiskToAnEnvironmentalSite__c = this.evnImpSite;
    }

    saveScreenFiveValues() {
        this.submitValues.FSM_RepairLength__c = this.repairLength;
        this.submitValues.FSM_PipeDiameter__c = this.selectedPipeDiameter;
        this.submitValues.FSM_PipeDiameterOther__c = this.pipeDiameterOtherValue;
        this.submitValues.FSM_PipeMaterial__c = this.selectedPipeMaterial;
        this.submitValues.FSM_SewerStatus__c = this.selectedSewerStatus;
        this.submitValues.FSM_RepairDepth__c = this.repairDepth;
        this.submitValues.FSM_SewerType__c = this.selectedSewerType;
        this.submitValues.FSM_ReasonForRepair__c = this.selectedReasonForRepair;
        this.submitValues.FSM_ThirdPartyDamage__c = this.selectedThirdPartyDamage;
    }
    //---------End of Saving Screen Values Methods-----------
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
            this.Screen6 = false;
        }
        else if (this.Screen3) {
            this.errormessages = [];
            this.saveScreenThreeValues();
            this.Screen1 = false;
            this.Screen2 = true;
            this.Screen3 = false;
            this.Screen4 = false;
            this.Screen5 = false;
            this.Screen6 = false;
        }
        else if (this.Screen4) {
            this.errormessages = [];
            if (this.selectedTask == 'S 08' || this.selectedTask == 'S 09' || this.selectedTask == 'S 10' || this.selectedTask == 'S 11'
                || this.selectedTask == 'S 12' || this.selectedTask == 'S 13' || this.selectedTask == 'S 14' || this.selectedTask == 'S 15'
                || this.selectedTask == 'S 17' || this.selectedTask == 'S 19' || this.selectedTask == 'S 20' || this.selectedTask == 'S 24' || this.selectedTask == 'S 27') {
                this.Screen1 = false;
                this.Screen2 = false;
                this.Screen3 = true;
                this.Screen4 = false;
                this.Screen5 = false;
                this.Screen6 = false;
            } else {
                this.Screen1 = false;
                this.Screen2 = true;
                this.Screen3 = false;
                this.Screen4 = false;
                this.Screen5 = false;
                this.Screen6 = false;
            }

        }
        else if (this.Screen5) {
            this.errormessages = [];
            this.Screen1 = false;
            this.Screen2 = false;
            this.Screen3 = false;
            this.Screen4 = true;
            this.Screen5 = false;
            this.Screen6 = false;
        }
        else if (this.Screen6) {
            this.errormessages = [];
            if (this.selectedTask == 'S 01' || this.selectedTask == 'S 02' || this.selectedTask == 'S 03'
                || this.selectedTask == 'S 04' || this.selectedTask == 'S 05' || this.selectedTask == 'S 06' || this.selectedTask == 'S 07') {
                this.Screen1 = false;
                this.Screen2 = false;
                this.Screen3 = false;
                this.Screen4 = false;
                this.Screen5 = true;
                this.Screen6 = false;
            } else {
                this.Screen1 = false;
                this.Screen2 = false;
                this.Screen3 = false;
                this.Screen4 = true;
                this.Screen5 = false;
                this.Screen6 = false;
            }
        }
    }

    // Description : Method to handle next screen navigations on Button Click
    handleNext() {
        if (this.Screen1) {
            this.handleSectionOnevalidation();
            if (this.isValidScreenOne) {
                this.Screen1 = false;
                this.Screen2 = true;
                this.Screen3 = false;
                this.Screen4 = false;
                this.Screen5 = false;
                this.Screen6 = false;
                this.Screen7 = false;
            }
        } else if (this.Screen2) {
            this.saveScreenTwoValues();
            this.handleSectionTwovalidation();
            if (this.isValidScreenTwo) {
                //check task values for blockage,cleansing,cctv screen 
                if (this.selectedTask == 'S 08' || this.selectedTask == 'S 09' || this.selectedTask == 'S 10' || this.selectedTask == 'S 11'
                    || this.selectedTask == 'S 12' || this.selectedTask == 'S 13' || this.selectedTask == 'S 14' || this.selectedTask == 'S 15'
                    || this.selectedTask == 'S 17' || this.selectedTask == 'S 19' || this.selectedTask == 'S 20' || this.selectedTask == 'S 24' || this.selectedTask == 'S 27') {

                    this.isrepairjobs = false;
                    this.isblockage = true;
                    this.isnormal = false;

                    this.Screen1 = false;
                    this.Screen2 = false;
                    this.Screen3 = true;
                    this.Screen4 = false;
                    this.Screen5 = false;
                    this.Screen6 = false;
                } else {
                    this.isrepairjobs = false;
                    this.isblockage = false;
                    this.isnormal = true;

                    this.Screen1 = false;
                    this.Screen2 = false;
                    this.Screen3 = false;
                    this.Screen4 = true;
                    this.Screen5 = false;
                    this.Screen6 = false;
                }
                // this.Screen1 = false;
                // this.Screen2 = false;
                // this.Screen3 = true;
                // this.Screen4 = false;
                // this.Screen5 = false;
                // this.Screen6 = false;
                // this.Screen7 = false;
            }
            console.log('which flow1', this.isnormal, 'r ', this.isrepairjobs, 'b ', this.isblockage);
        }
        else if (this.Screen3) {
            this.handleSectionThreevalidation();
            if (this.isValidScreenThree) {
                this.Screen1 = false;
                this.Screen2 = false;
                this.Screen3 = false;
                this.Screen4 = true;
                this.Screen5 = false;
                this.Screen6 = false;
                this.Screen7 = false;
            }
        }
        else if (this.Screen4) {
            this.handleSectionFourvalidation();
            if (this.isValidScreenFour) {
                //check task values for repair jobs screen 
                if (this.selectedTask == 'S 01' || this.selectedTask == 'S 02' || this.selectedTask == 'S 03'
                    || this.selectedTask == 'S 04' || this.selectedTask == 'S 05' || this.selectedTask == 'S 06' || this.selectedTask == 'S 07') {

                    this.isrepairjobs = true;
                    this.isblockage = false;
                    this.isnormal = false;

                    this.Screen1 = false;
                    this.Screen2 = false;
                    this.Screen3 = false;
                    this.Screen4 = false;
                    this.Screen5 = true;
                    this.Screen6 = false;
                    this.Screen7 = false;
                } else {
                    this.Screen1 = false;
                    this.Screen2 = false;
                    this.Screen3 = false;
                    this.Screen4 = false;
                    this.Screen5 = false;
                    this.Screen6 = true;
                    this.Screen7 = false;
                }
            }
            console.log('which flow2', this.isnormal, 'r ', this.isrepairjobs, 'b ', this.isblockage);
        }
        else if (this.Screen5) {
            this.saveScreenFiveValues();
            this.handleSectionFivevalidation();
            if (this.isValidScreenFive) {
                this.Screen1 = false;
                this.Screen2 = false;
                this.Screen3 = false;
                this.Screen4 = false;
                this.Screen5 = false;
                this.Screen6 = true;
                this.Screen7 = false;
            }
            console.log('which flow3', this.isnormal, 'r ', this.isrepairjobs, 'b ', this.isblockage);
        }
        else if (this.Screen6) {
            this.Screen1 = false;
            this.Screen2 = false;
            this.Screen3 = false;
            this.Screen4 = false;
            this.Screen5 = false;
            this.Screen6 = false;
            this.Screen7 = true;
        }
    }

    get isEnableNext() {
        if (this.Screen1 == true || this.Screen2 == true || this.Screen3 == true || this.Screen4 == true || this.Screen5 == true) {
            return true;
        }
        else {
            return false;
        }
    }

    get isLastScreen() {
        if (this.Screen6 == true) {
            return true;
        }
        else {
            return false;
        }
    }
    get isEnablePrev() {
        if (this.Screen2 == true || this.Screen3 == true || this.Screen4 == true || this.Screen5 == true || this.Screen6 == true) {
            return true;
        }
        else {
            return false;
        }

    }


}
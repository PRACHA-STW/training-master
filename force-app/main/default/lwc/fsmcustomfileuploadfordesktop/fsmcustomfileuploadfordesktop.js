import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import uploadFiles from '@salesforce/apex/FSMFileUploaderClass.uploadFiles';
const MAX_FILE_SIZE = 6000000;
import { createRecord } from 'lightning/uiRecordApi';

export default class Fsmcustomfileuploadfordesktop extends LightningElement {
    @api recordId;
    @track filesData = [];
    @track fileData = false; // for conditional rendering of File upload
    @track imgFile = false;
    @track docFile = false;
    showSpinner = false;
    cvid;
    error;
    handleFileUploaded(event) {
        if (event.target.files.length > 0) {
            for (var i = 0; i < event.target.files.length; i++) {
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
                    return;
                }
                let file = event.target.files[i];
                console.log('file name', file.name);
                const fileext = file.name.split('.').pop();
                let baseName = file.name.split('.')[0];
                // 
                const isImage = file.name.includes(fileext);
                //
                console.log('fileext', fileext);
                if (fileext == 'pdf' || fileext == 'csv' || fileext == 'doc' || fileext == 'docx' || fileext == 'gif' || fileext == 'html' || fileext == 'htm'
                    || fileext == 'jpg' || fileext == 'jpeg' || fileext == 'txt' || fileext == 'xls' || fileext == 'xlsb' || fileext == 'xlsx') {

                    let reader = new FileReader();
                    reader.onload = e => {
                        var fileContents = reader.result.split(',')[1]
                        this.filesData.push({ 'fileName': file.name, 'fileContent': fileContents, 'fileData': reader.result, 'baseName': baseName, 'fileExt': fileext ,'isImage':isImage});
                        console.log('filecontents------>', fileContents);
                        console.log('this.filesData',this.filesData)
                    };
                    reader.readAsDataURL(file);
                } else {

                    this.showToast('Error!', 'error', 'File type not allowed');
                    return;
                }
                
            }
        }
        this.fileData = true;
    }

    handleImageError(event){
        const errorImageUrl = event.target.src; // Get the URL of the image that failed to load
        console.error('Failed to load image:', errorImageUrl);
        // Find the parent container of the image (div in this case)
        const parentContainer = event.target.parentElement;
        // Remove the img tag from the parent container
        parentContainer.removeChild(event.target);
        // Create a new p tag to display alternative text
        const alternateText = document.createElement('p');
        alternateText.textContent = 'No preview available for this file';
        // Add CSS class to style the alternative text
        alternateText.classList.add('alternative-text');
        // Append the alternative text to the parent container
        parentContainer.appendChild(alternateText);
    }
    


   

    handlefilenameChange(event) {
        console.log('event', event.target.id)
        const index = event.target.id;
        const beforeDash = index.split('-')[0];
        const newFileName = event.target.value;
        console.log('index', index, "newFileName", newFileName)
        // Update the file name in the filesData array
        if (beforeDash !== undefined) {
            this.filesData = this.filesData.map((file, idx) => {
                if (idx === parseInt(beforeDash, 10)) {
                    return { ...file, baseName: newFileName };
                }
                return file;
            });
        }
    }

    // uploadFiles() {
    //     if(this.filesData == [] || this.filesData.length == 0) {
    //         this.showToast('Error', 'error', 'Please select files first'); return;
    //     }
    //     this.showSpinner = true;
    //     uploadFiles({
    //         recordId : this.recordId,
    //         filedata : JSON.stringify(this.filesData)
    //     })
    //     .then(result => {
    //         console.log(result);
    //         if(result && result == 'success') {
    //             this.filesData = [];
    //             this.showToast('Success', 'success', 'Files Uploaded successfully.');
    //         } else {
    //             this.showToast('Error', 'error', result);
    //         }
    //     }).catch(error => {
    //         if(error && error.body && error.body.message) {
    //             this.showToast('Error', 'error', error.body.message);
    //         }
    //     }).finally(() => this.showSpinner = false );
    // }

    removeReceiptImage(event) {
        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
        if (this.filesData.length === 0) {
            this.fileData = false;
        }
    }

    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }

    createcontentversion() {
        console.log('inside cv create', JSON.stringify(this.filesData));
        let allcvtoinsert = [];
        if (this.filesData.length == 0) {
            this.showToast('Error!', 'error', 'Select files for upload');
            return;
        } else {
            for (var i = 0; i < this.filesData.length; i++) {
                const fileData = {
                    Title: this.filesData[i].baseName,
                    PathOnClient: this.filesData[i].fileName,
                    VersionData: this.filesData[i].fileContent,
                    FSM_RelatedrecordId__c: this.recordId

                }
                allcvtoinsert.push(fileData);

            }
            this.cvinsert(allcvtoinsert);
        }


    }

    cvinsert(cvarr) {
        console.log('cvid------->', JSON.stringify(cvarr));


        cvarr.forEach((record) => {

            const payload = { apiName: 'ContentVersion', fields: record };
            console.log('phto upload payload', JSON.stringify(payload));
            createRecord(payload).then(cversion => {
                this.cvid = cversion.id;

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
        if (this.error == undefined || this.error == null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Files uploaded successfully',
                    variant: 'success',
                }),
            );
        }
        this.fileData = false;
        this.filesData = [];


    }
}
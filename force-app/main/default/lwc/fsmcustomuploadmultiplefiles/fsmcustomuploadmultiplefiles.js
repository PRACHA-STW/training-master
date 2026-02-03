import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import uploadFiles from '@salesforce/apex/FSMFileUploaderClass.uploadFiles';
const MAX_FILE_SIZE = 6000000;
import { createRecord } from 'lightning/uiRecordApi';

export default class Fsmcustomuploadmultiplefiles extends LightningElement {

    @api recordId;
    @track filesData = [];
    @track fileData = false; // for conditional rendering of File upload
    showSpinner = false;
    cvid;
    error;
    // handleFileUploaded(event) {
    //     // console.log('event', event.target.files)
    //     if (event.target.files.length > 0) {
    //         for (var i = 0; i < event.target.files.length; i++) {
    //             if (event.target.files[i].size > MAX_FILE_SIZE) {
    //                 this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
    //                 return;
    //             }
    //             let file = event.target.files[i];
    //             console.log('file name', file.name);
    //             const fileext = file.name.split('.').pop();
    //             let baseName = file.name.split('.')[0];
    //             console.log('fileext', fileext);
    //             if (fileext == 'pdf' || fileext == 'csv' || fileext == 'doc' || fileext == 'docx' || fileext == 'gif' || fileext == 'html' || fileext == 'htm'
    //                 || fileext == 'jpg' || fileext == 'jpeg' || fileext == 'txt' || fileext == 'xls' || fileext == 'xlsb' || fileext == 'xlsx') {

    //                 let reader = new FileReader();
    //                 reader.onload = e => {
    //                     var fileContents = reader.result.split(',')[1]
    //                     this.filesData.push({ 'fileName': file.name, 'fileContent': fileContents, 'fileData': reader.result, 'baseName': baseName, 'fileExt': fileext});
    //                 };
    //                 reader.readAsDataURL(file);
    //             } else {
    //                 this.showToast('Error!', 'error', 'File type not allowed');
    //                 return;
    //             }

    //         }
    //     }
    //     this.fileData = true
    // }

    handleFileUploaded(event) {
        if (event.target.files.length > 0) {
            for (let i = 0; i < event.target.files.length; i++) {
                let file = event.target.files[i];
    
                let fileext = file.name.split('.').pop().toLowerCase();
                let baseName = file.name.split('.')[0];
                console.log('file name', file.name);
                console.log('fileext', fileext);
    
                // Allowed file types
                if (fileext === 'pdf' || fileext === 'csv' || fileext === 'doc' || fileext === 'docx' ||
                    fileext === 'gif' || fileext === 'html' || fileext === 'htm' || fileext === 'jpg' ||
                    fileext === 'jpeg' || fileext === 'txt' || fileext === 'xls' || fileext === 'xlsb' ||
                    fileext === 'xlsx') {
    
                    // If it's an image, handle compression
                    if (fileext === 'jpg' || fileext === 'jpeg' || fileext === 'png' || fileext === 'gif') {
                        this.compressImage(file).then(compressedFile => {
                            // Validate the size of the compressed image (6MB = 6 * 1024 * 1024 bytes)
                            if (compressedFile.size > 6 * 1024 * 1024) {
                                this.showToast('Error!', 'error', 'Compressed image size exceeds the 6MB limit.');
                                return;
                            }
    
                            // Continue processing the compressed file
                            let reader = new FileReader();
                            reader.onload = () => {
                                var fileContents = reader.result.split(',')[1];
                                this.filesData.push({
                                    'fileName': compressedFile.name,
                                    'fileContent': fileContents,
                                    'fileData': reader.result,
                                    'baseName': baseName,
                                    'fileExt': fileext
                                });
                            };
                            reader.readAsDataURL(compressedFile);
                        }).catch(error => {
                            this.showToast('Error!', 'error', 'Image compression failed.');
                        });
                    } else {
                        // Handle other file types directly
                        let reader = new FileReader();
                        reader.onload = e => {
                            var fileContents = reader.result.split(',')[1];
                            this.filesData.push({
                                'fileName': file.name,
                                'fileContent': fileContents,
                                'fileData': reader.result,
                                'baseName': baseName,
                                'fileExt': fileext
                            });
                        };
                        reader.readAsDataURL(file);
                    }
    
                } else {
                    this.showToast('Error!', 'error', 'File type not allowed');
                    return;
                }
            }
        }
        this.fileData = true;
    }
    
    // Function to compress image using Canvas API
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
        if(this.filesData.length===0){
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
        this.showSpinner = true
        console.log('inside cv create');
        let allcvtoinsert = [];

        if (this.filesData.length == 0) {
            this.showSpinner = false;
            this.showToast('Error!', 'error', 'Select files for upload');
            return;
        } else {
            for (var i = 0; i < this.filesData.length; i++) {
                const fileData = {
                    Title: this.filesData[i].baseName,
                    PathOnClient: this.filesData[i].fileName,
                    // PathOnClient: this.filesData[i].baseName,
                    VersionData: this.filesData[i].fileContent,
                    FSM_RelatedrecordId__c: this.recordId

                }
                allcvtoinsert.push(fileData);

            }
            this.cvinsert(allcvtoinsert);
        }

    }

    cvinsert(cvarr) {
        console.log('cvid------->');


        cvarr.forEach((record) => {

            const payload = { apiName: 'ContentVersion', fields: record };
            createRecord(payload).then(cversion => {
                this.cvid = cversion.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Files uploaded successfully',
                        variant: 'success',
                    }),
                );
                this.showSpinner= false;

            }).catch(error => {
console.log('error',error);
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
        //    if(this.error== undefined || this.error ==null)
        //    {
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Success',
        //             message: 'Files uploaded successfully',
        //             variant: 'success',
        //         }),
        //     );
        //    }
        this.fileData = false;
        this.filesData = [];


    }
}
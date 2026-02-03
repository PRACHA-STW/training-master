import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from "lightning/uiRecordApi";
import WONUMBER_FIELD from "@salesforce/schema/WorkOrder.FSM_ExternalId__c";
import ORDERNUMBER_FIELD from "@salesforce/schema/WorkOrder.FSM_OrderNumber__c";
import OPERATIONNUMBER_FIELD from "@salesforce/schema/WorkOrder.FSM_OperationNumber__c";
import GENERATEPDF_FIELD from "@salesforce/schema/WorkOrder.FSM_GeneratePDF__c";

import FORM_FACTOR from '@salesforce/client/formFactor';
const fields = [WONUMBER_FIELD, GENERATEPDF_FIELD, ORDERNUMBER_FIELD, OPERATIONNUMBER_FIELD];

export default class Fsm_simpleSketch extends LightningElement {
    @api recordId;

    selimgs;
    sitedataicon;
    sketchiconimages;
    mapdata;
    textoneditor;
    imagesoneditor;
    shapesoneditor;
    preloaddata;
    @api userinputs = {};
    imagesdata;
    shapesdata;
    textdata;
    //dcf record Id
    @track dcfId;
    @track openEditor = false;
    @track openFileUploader = true;
    deviceType;

    @track photoCaptureImageList = [];
    closewindow = false;
    openbasemap = false;



    get woId() {
        return this.recordId;
    }

    woExternalId;
    fieldsForFileName;
    @wire(getRecord, { recordId: "$recordId", fields })
    workorderdetails({ error, data }) {
        console.log("data ", data)
        console.log('loadFields, recordId: ', this.recordId);
        if (error) {
            console.log('error', JSON.parse(JSON.stringify(error)));
        } else if (data) {
            this.woExternalId = data.fields.FSM_ExternalId__c.value;
            this.fieldsForFileName = {
                externalId: data.fields.FSM_ExternalId__c.value,
                orderNumber: data.fields.FSM_OrderNumber__c.value,
                operationNumber: data.fields.FSM_OperationNumber__c.value
            };
            //added as part of sfs-5402
            const generatepdfval = getFieldValue(data, GENERATEPDF_FIELD);
            if (generatepdfval == true) {
                this.updateworkorderflag(this.recordId);
            }


        }
    }
    //added as part of sfs-5402
    async updateworkorderflag(recId) {
        const fields = {};
        fields['Id'] = recId; //populate it with current record Id
        fields['FSM_GeneratePDF__c'] = false; //populate any fields which you want to update like this


        const recordInput = { fields };

        await updateRecord(recordInput).then(() => {
            console.log('successfully updated record');


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

    get woNum() {
        console.log("woNum", this.workorderdetails.data, WONUMBER_FIELD)
        return getFieldValue(this.workorderdetails.data, WONUMBER_FIELD);
    }

    connectedCallback() {
        console.log('inside connected callback');
        //check if users device type
        if (FORM_FACTOR === 'Large') {
            //do something here
            this.deviceType = 'Desktop';
        } else if (FORM_FACTOR === 'Medium') {
            this.deviceType = 'Tablet';
        } else {
            this.deviceType = 'Mobile'
        }

        // console.log('rec id in lwc',this.recordId);
    }


    //go to map and site icon upload screen
    handleClickNext(event) {

        this.openFileUploader = false;
        this.openEditor = false;
        this.closewindow = false;
        this.openbasemap = true;
        console.log('site---', JSON.stringify(this.draggableImageData), 'sketch-----', JSON.stringify(this.sketchImageData), 'base------', JSON.stringify(this.baseImageData));
        if (!!JSON.stringify(this.draggableImageData)) {
            this.sitedataicon = JSON.parse(JSON.stringify(this.draggableImageData));
        }
        if (!!JSON.stringify(this.sketchImageData)) {
            this.sketchiconimages = JSON.parse(JSON.stringify(this.sketchImageData));
        }
        if (!!JSON.stringify(this.baseImageData)) {
            this.mapdata = JSON.parse(JSON.stringify(this.baseImageData));
        }




        // this.photoCaptureImageList=JSON.parse(JSON.stringify(event.detail.image));
        // if(!!JSON.stringify(event.detail.selbsemap)){
        //     this.mapdata=JSON.parse(JSON.stringify(event.detail.selbsemap));
        //     this.sitedataicon=JSON.parse(JSON.stringify(event.detail.siteicon));
        //     this.sketchiconimages=JSON.parse(JSON.stringify(event.detail.sketchimg));


        //     if(!!JSON.stringify(event.detail.shapes)){
        //         this.imagesdata=JSON.parse(JSON.stringify(event.detail.imageeditor));
        //         this.shapesdata=JSON.parse(JSON.stringify(event.detail.shapes));
        //          this.textdata=JSON.parse(JSON.stringify(event.detail.text));
        //          this.pretextdata=JSON.parse(JSON.stringify(event.detail.pretext));



        //     }



        // }



    }

    handlePhotoCaptureImages(event) {
        //images from photocapture screen
        this.photoCaptureImageList = event.detail;
    }

    // return to photocapture screen
    handleprevformbase(event) {

        let data = event.detail;
        console.log('data', JSON.stringify(data));

        if (!!JSON.stringify(this.photoCaptureImageList)) {

            this.selimgs = this.photoCaptureImageList;
            console.log('data', JSON.stringify(this.selimgs), ' type', typeof this.selimgs);
        }

        this.openFileUploader = true;
        this.openEditor = false;
        this.openbasemap = false;
        this.closewindow = false;
    }

    //open editor screen onclick of next from base map screen
    handlenextformbase(event) {
        this.openEditor = true;
        this.openbasemap = false;
        this.closewindow = false;
        this.openfileuploader = false;

    }


    async handleImagesSelected(event) {

        this.baseImageData = event.detail;
    }

    async handleDraggableImages(event) {

        this.draggableImageData = event.detail;
        //this.siteicon=[...this.draggableImageData];
    }

    async handlesketchimages(event) {

        this.sketchImageData = event.detail;
        //this.sketchimagesdata=[...this.sketchImageData];

    }



    // prev from sketch editor

    opensketchfileuploader(event) {
        console.log('inside opensketchfileuploader', JSON.stringify(this.baseImageData), '---', JSON.stringify(this.draggableImageData), '------', JSON.stringify(this.sketchImageData));
        if (!!JSON.stringify(this.baseImageData)) {
            this.mapdata = JSON.parse(JSON.stringify(this.baseImageData));
        }
        if (!!JSON.stringify(this.draggableImageData)) {
            this.sitedataicon = JSON.parse(JSON.stringify(this.draggableImageData));
        }
        if (!!JSON.stringify(this.sketchImageData)) {
            this.sketchiconimages = JSON.parse(JSON.stringify(this.sketchImageData));
        }

        //canvas arrays
        this.textoneditor = JSON.parse(JSON.stringify(event.detail.textarr));
        this.imagesoneditor = JSON.parse(JSON.stringify(event.detail.imgarr));
        this.shapesoneditor = JSON.parse(JSON.stringify(event.detail.shapesarr));
        //this.preloaddata=JSON.parse(JSON.stringify(event.detail.preloaddata));
        this.openEditor = false;
        this.openbasemap = true;
        this.closewindow = false;
        this.openfileuploader = false;
    }

    handlecloseform(event) {
        console.log('close window', JSON.stringify(event.detail));
        if (!!event.detail) {
            this.openEditor = false;
            this.openfileuploader = false;
            this.closewindow = true;

            this.openbasemap = false;
        }
    }

}
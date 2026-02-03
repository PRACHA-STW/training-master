import { LightningElement, track, wire, api } from 'lwc';
import DCFINFRA_OBJECT from '@salesforce/schema/FSM_InfraDataCaptureForm2__c';
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WORKORDER from '@salesforce/schema/WorkStep.WorkOrderId';
import FORM_FACTOR from '@salesforce/client/formFactor';
const fields = [WORKORDER];
import { getRecord } from 'lightning/uiRecordApi';


const FIELDS = [
    "FSM_InfraDataCaptureForm2__c.FSM_WorkStep__c",
    "FSM_InfraDataCaptureForm2__c.FSM_WorkOrder__c",
    "FSM_InfraDataCaptureForm2__c.FSM_Status__c"]

export default class FsmSewerageFurtherWorkRequest extends LightningElement {
    @api recordId;
    //  Screen Navigation variables
    @track openRecordPage = true;
    @track openFileUploader = false;
    @track continuetogoldsketch = false;
    datafromfwr;
    formtype = "sewerageFWR";
    @track photoCaptureImageList = [];
    @track successmessagewindow = false;
    dcfinraid;
    dcfinfrarecordfields;
    @track workOrderid;
    @track workStepId;
    @track dcf2RecordStatus;
    sitedataicon;
    @track filesData = [];
    @track sketchText = [];
    deviceType;
    @track isEdit;

    //sketch
    sketchiconimages;
    tmasketchiconimages;
    mapdata;
    editorimgarr;
    editortxtarr;
    editorshapesarr;
    editorpreload;
    imagesdata;
    shapesdata;
    textdata;
    @api objectApiName;


    //Passing Object Name to Child
    objName = DCFINFRA_OBJECT.objectApiName;


    connectedCallback() {
        if (FORM_FACTOR === 'Large') {
            //do something here
            this.deviceType = 'Desktop';
        } else if (FORM_FACTOR === 'Medium') {
            this.deviceType = 'Tablet';
        } else {
            this.deviceType = 'Mobile'
        }
    }

    get woId() {
        return this.recordId;
    }
    get objCurrentName() {
        return this.objectApiName;
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    dcfRecords({ data, error }) {
        if (data) {
            this.workOrderid = data.fields.FSM_WorkOrder__c.value;
            this.workStepId = data.fields.FSM_WorkStep__c.value;
            this.dcf2RecordStatus = data.fields.FSM_Status__c.value;
        }
    }



    @wire(getRecord, { recordId: '$recordId', fields })
    workorderid({ error, data }) {
        if (data) {
            this.workOrderid = data.fields.WorkOrderId.value;
        }
    };


    //fwr record form
    handlefinalsubmit(event) {
        this.datafromfwr = JSON.parse(JSON.stringify(event.detail));
        let dcfinfrarec = this.datafromfwr.dcfdata;
        // console.log('dcfinfrarec in fsm fwr', dcfinfrarec.FSM_GridRefOfProposedWorkX__c, 'FSM_GridRefOfProposedWorkY__c', dcfinfrarec.FSM_GridRefOfProposedWorkY__c);
        const gridRefVal = 'X:' + dcfinfrarec.FSM_SFWXcoordinate__c + ',Y:' + dcfinfrarec.FSM_SFWYcoordinate__c;
        // this.sketchText.push(gridRefVal);
        //const gridRefVal = 'X:'+dcfinfrarec.FSM_GridRefOfProposedWorkX__c + ',Y:'+dcfinfrarec.FSM_GridRefOfProposedWorkY__c;
        if (dcfinfrarec.FSM_FWRSiteComments__c == null || dcfinfrarec.FSM_FWRSiteComments__c == undefined || dcfinfrarec.FSM_FWRSiteComments__c == '') {
            this.sketchText = [];
            this.sketchText.push(gridRefVal);
        } else {
            this.sketchText = [];
            this.sketchText.push(gridRefVal, dcfinfrarec.FSM_FWRSiteComments__c);
        }
        console.log('sketchText109 ----> ', JSON.stringify(this.sketchText));
        this.selimgs = JSON.parse(JSON.stringify(this.photoCaptureImageList));
        if (!!this.workStepId) {
            this.isEdit = true;
        } else {
            this.isEdit = false;
        }
        this.openFileUploader = true;
        this.openRecordPage = false;

    }


    //go to map and site icon upload screen
    handleClickNext(event) {
        // this.formType = 'sewerageFWR';
        this.openFileUploader = false;
        this.datafromfwr = JSON.parse(JSON.stringify(event.detail.data));
        this.photoCaptureImageList = JSON.parse(JSON.stringify(event.detail.image));
        if (!!JSON.stringify(event.detail.selbsemap)) {
            this.mapdata = JSON.parse(JSON.stringify(event.detail.selbsemap));
            this.sitedataicon = JSON.parse(JSON.stringify(event.detail.siteicon));
            this.sketchiconimages = JSON.parse(JSON.stringify(event.detail.sketchimg));
            this.tmasketchiconimages = JSON.parse(JSON.stringify(event.detail.tmaimg));
            if (!!JSON.stringify(event.detail.shapes)) {
                this.imagesdata = JSON.parse(JSON.stringify(event.detail.imageeditor));
                this.shapesdata = JSON.parse(JSON.stringify(event.detail.shapes));
                this.textdata = JSON.parse(JSON.stringify(event.detail.text));
                this.pretextdata = JSON.parse(JSON.stringify(event.detail.pretext));

                // console.log('next from photocapture editor data', JSON.stringify(event.detail.imageeditor), 'text', JSON.stringify(event.detail.shapes));

            }
        }
        this.continuetogoldsketch = true;
        // this.openEditor = true;
    }

    handlePrevfromphotocapture(event) {
        let ip = this.template.querySelector('c-fsm-sewerage-fwr');
        if (ip == undefined || ip == null) {
            this.openFileUploader = false;
            this.openlastpageofform = JSON.parse(JSON.stringify(event.detail.data));
            // console.log('prev from photo capture', this.openlastpageofform);

            this.openRecordPage = true;

        } else {

            this.openFileUploader = false;
            this.openlastpageofform = JSON.parse(JSON.stringify(event.detail.data));
            // console.log('prev from photo capture', this.openlastpageofform);
            ip.handlepreviousfromfwr(this.openlastpageofform);
        }

    }

    handlePhotoCaptureImages(event) {
        this.photoCaptureImageList = event.detail;
    }

    handlePrevfromsketchmaincmp(event) {
        // console.log('inside handle prev from sketch main');
        this.openFileUploader = true;
        this.openEditor = false;
        this.openRecordPage = false;
        this.openlastpageofform = JSON.parse(JSON.stringify(event.detail.datatophotocapture));
        // console.log('inside handle prev fsm fwr', this.openlastpageofform);
        this.selimgs = JSON.parse(JSON.stringify(event.detail.selphotos));
        if (!!JSON.stringify(event.detail.basemapdata)) {
            this.mapdata = JSON.parse(JSON.stringify(event.detail.basemapdata));
            this.sitedataicon = JSON.parse(JSON.stringify(event.detail.icondata));
            this.sketchiconimages = JSON.parse(JSON.stringify(event.detail.sketchicondata));
            this.tmasketchiconimages = JSON.parse(JSON.stringify(event.detail.tmasketchicondata));
            // console.log('inside fsmfwrhandleprevformsketchmain', JSON.stringify(this.sketchiconimages), '======', JSON.stringify(this.tmasketchiconimages));

        }
        // this.mapdata=JSON.parse(JSON.stringify(event.detail.basemapdata));
        // this.sitedataicon=JSON.parse(JSON.stringify(event.detail.icondata));
        if (!!JSON.stringify(event.detail.shape)) {
            // console.log('inside handle prev fsm fwr editor data');
            this.editorimgarr = JSON.parse(JSON.stringify(event.detail.img));
            this.editortxtarr = JSON.parse(JSON.stringify(event.detail.txt));
            this.editorshapesarr = JSON.parse(JSON.stringify(event.detail.shape));
            this.editorpreload = JSON.parse(JSON.stringify(event.detail.preloadtext));
        }


        // console.log('1--->',JSON.stringify(this.editorimgarr),'2----->',JSON.stringify(this.editorshapesarr),'3------>',JSON.stringify(this.editortxtarr));
    }

    handleClickYes() {
        this.continuetogoldsketch = false;
        this.openEditor = true;
    }
    //method to end the form at photo capture and create dcf record
    handleClickNo() {
        this.openEditor = false;
        this.continuetogoldsketch = false;
        // console.log('Inside handleClickNo --->')
        this.createdcfinfrarecord();

    }
    //if no selected create dcf infra record with photos from photocapture screen attached
    async createdcfinfrarecord() {
        this.isLoading = true;
        const datafrom = JSON.parse(JSON.stringify(this.datafromfwr));
        this.dcfinfrarecordfields = datafrom.dcfdata;
        if (JSON.stringify(this.dcfinfrarecordfields.FSM_FWRCommsType__c) != undefined) {
            //add values to multiselect picklist
            const arr = this.dcfinfrarecordfields.FSM_FWRCommsType__c.join(";");
            // console.log('arr------->',arr);
            this.dcfinfrarecordfields.FSM_FWRCommsType__c = arr;
        }

        // console.log('dcfinfrarecordfields----->json----->', JSON.stringify(this.dcfinfrarecordfields));
        if (this.isEdit === true) {
            // console.log("this.isEdit === true 1")
            this.dcfinfrarecordfields.Id = this.recordId;
        }
        const fields = this.dcfinfrarecordfields;
        const recordInput = { apiName: DCFINFRA_OBJECT.objectApiName, fields };

        if (this.isEdit === true) {
            //update
            // console.log("this.isEdit test---->")
            const recordInput1 = { fields };
            // console.log('recordInput1--->',recordInput1)
            await updateRecord(recordInput1).then(() => {
                // if (!!this.photoCaptureImageList || this.photoCaptureImageList.length != 0) {
                if (this.photoCaptureImageList.length !== 0) {
                    // console.log('Inside photoCaptureImageList--->',this.photoCaptureImageList ,'lenght' ,this.photoCaptureImageList.length === 0 )
                    this.createcontentversion(this.recordId)
                    this.isLoading = false;
                } else {
                    this.successmessagewindow = true;
                    this.isLoading = false;
                }
            }).catch(error => {
                console.error('Error Update Record', error)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error?.body?.message,
                        variant: 'error'
                    })
                );
            });
        }
        else {
            this.dcfinraid = await createRecord(recordInput);
            this.updateworkstepfield(this.dcfinraid.id);

        }
    }
    dcfWorkStepId;
    handleDcfWorkStepId(event) {
        this.dcfWorkStepId = event.detail;
    }

    //update status and workstep of dcf infra records
    async updateworkstepfield(dcfrecid) {


        const fields = {};
        fields['Id'] = dcfrecid; //populate it with current record Id
        if (this.dcfWorkStepId != null) {
            fields['FSM_WorkStep__c'] = this.dcfWorkStepId;
        }
        fields['FSM_WorkStep__c'] = this.recordId;
        fields['FSM_Status__c'] = 'In Progress';
        //populate any fields which you want to update like this

        // Update workstep
        let workStep = {};
        workStep.Id = this.recordId;
        workStep.Status = '	In Progress';
        await updateRecord({ fields: workStep })
        //populate any fields which you want to update like this
        //


        const recordInput = { fields };

        updateRecord(recordInput).then(() => {
            this.createcontentversion(this.dcfinraid.id)
            this.isLoading = false;

        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body,
                    variant: 'error'
                })
            );
        });
    }


    //create content version records to be inserted        
    createcontentversion(dcfrecordid) {
        this.photoCaptureImageList.forEach((element, index) => {
            const photostoupload = JSON.stringify(element.data);
            const filecontentdata = photostoupload.split(',')[1];
            const removeLast3 = filecontentdata.slice(0, -1);
            //const metadata=element.metadata.fileName;
            const fileext = element.metadata.ext;
            this.filesData.push({ 'fileName': 'Photo ' + index + '.' + fileext, 'fileContent': removeLast3 });
        });
        let allcvtoinsert = [];
        // console.log('files data length', this.filesData.length);
        if (this.filesData.length == 0) {
            // this.showToast('Error!', 'error', 'Select files for upload');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Select files for upload',
                    variant: 'error'
                })
            );
            return;
        } else {

            for (var i = 0; i < this.filesData.length; i++) {
                const fileData = {
                    Title: this.filesData[i].fileName,
                    PathOnClient: this.filesData[i].fileName,
                    VersionData: this.filesData[i].fileContent,
                    FSM_RelatedrecordId__c: dcfrecordid,
                    FSM_Sketch_Additional_Images__c: true,
                    FSM_Do_not_send_to_SAP__c: true

                }
                allcvtoinsert.push(fileData);
            }

            this.cvinsert(allcvtoinsert, dcfrecordid);
        }
    }
    //insert content version
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
                        title: 'Error',
                        message: 'Error creating content version',
                        variant: 'error',
                    }),
                );
                this.error = error;
            });



        });
        this.successmessagewindow = true;
        this.isLoading = false;
    }

}
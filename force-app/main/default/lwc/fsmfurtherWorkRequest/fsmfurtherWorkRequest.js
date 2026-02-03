import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SAWORKORDER_FIELD from '@salesforce/schema/ServiceAppointment.ParentRecordId';
import WORKORDER from '@salesforce/schema/WorkStep.WorkOrderId';
const fields = [WORKORDER];
import FSM_DCFLineItemInfraOBJECT from '@salesforce/schema/FSM_DCFLineItemInfra__c';
import DCFINFRA_OBJECT from '@salesforce/schema/FSM_DataCaptureFormInfra__c';
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import FORM_FACTOR from '@salesforce/client/formFactor';
import workstep from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_WorkStep__c';
import status from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_Status__c';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
export default class FsmfurtherWorkRequest extends LightningElement {
    @api recordId;
    @track filesData = [];
    openlastpageofform;
    retainproformaimgs;
    imgfromfileuploader;
    isEdit;
    formtype = 'Infra Follow on Work Request';
    addcustdcfinfralineitemrectypeid;
    selimgs;
    deviceType;
    dcflineitenid;
    isLoading = false;
    dcfinfralineitems;
    customerlineitemstoinsert;
    isboppsflow;
    //dcfid;
    dcfinraid;
    dcfinfrarecordfields;
    isboppsflow;
    istmaflow;
    isnormalflow;
    sitedataicon;
    photocapured;
    senddatatofwr;
    sketchiconimages;
    tmasketchiconimages;
    mapdata;
    dcfinfralineitemrectypeid;
    continuetogoldsketch = false;
    @api userinputs = {};
    dcfformdata;
    dcflineitemrecdata;
    datafromfwr;
    editorimgarr;
    editortxtarr;
    editorshapesarr;
    editorpreload;
    imagesdata;
    shapesdata;
    @track textdata;
    formalreadycomplete = false;
    wireExecuted;
    wireLineitemsexecuted;
    //dcf record Id
    @track dcfId;
    @track openEditor = false;
    @track openFileUploader = false;
    @track openRecordPage = true;
    successmessagewindow = false;
    @track sketchText = [];
    @track photoCaptureImageList = [];
    proformaPhotoCaptureImageList = [];

    //@api iseditform;
    @wire(getRecord, { recordId: '$recordId', fields })
    workorderid;


    get woId() {
        //return getFieldValue(this.workorderid.data, WORKORDER);
        return this.recordId;
    }


    connectedCallback() {
        //this.workOrderField = ''
        // console.log('form type',this.formtype);
        if (FORM_FACTOR === 'Large') {
            //do something here
            this.deviceType = 'Desktop';
        } else if (FORM_FACTOR === 'Medium') {
            this.deviceType = 'Tablet';
        } else {
            this.deviceType = 'Mobile'
        }

    }
    @wire(getRecord, { recordId: '$recordId', fields: [workstep, status] })
    dcfinfradata({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            // console.log('userDetails---->',data)
            if (data.fields.FSM_WorkStep__c.value != null) {
                this.workstep = data.fields.FSM_WorkStep__c.value;
                //  console.log('workstep',this.workstep);

                this.isEdit = true;

            } else {
                this.isEdit = false;
            }
            // console.log('device type in wire',data.fields.FSM_Status__c.value );
            if (data.fields.FSM_Status__c.value != null && data.fields.FSM_Status__c.value == 'Completed') {
                this.formalreadycomplete = true;
                this.openRecordPage = false;

            } else {
                this.formalreadycomplete = false;
            }

        }
    }
    //method to move from dcf form component to photo capture component
    handlefinalsubmit(event) {


        this.datafromfwr = JSON.parse(JSON.stringify(event.detail));
        let dcfinfrarec = this.datafromfwr.dcfdata;
        let customerlineitemdata = this.datafromfwr.customerlineitems;
        this.isboppsflow = this.datafromfwr.isboppsflow;
        this.istmaflow = this.datafromfwr.istmaflow;
        this.isnormalflow = this.datafromfwr.isnormalflow;
        this.wireExecuted = this.datafromfwr.hasexecutedwire;
        this.wireLineitemsexecuted = this.datafromfwr.hasexecutedlineitems;
        console.log('this.wireExecuted fsmfwr', this.wireExecuted);
        //console.log('flags from fsmfwr bopps',this.isboppsflow,this.istmaflow,this.isnormalflow);
        //console.log('dcfinfrarec in fsm fwr',dcfinfrarec.FSM_GridRefOfProposedWorkX__c,'FSM_GridRefOfProposedWorkY__c',dcfinfrarec.FSM_GridRefOfProposedWorkY__c);
        const gridRefVal = 'X:' + dcfinfrarec.FSM_GridRefOfProposedWorkX__c + ',Y:' + dcfinfrarec.FSM_GridRefOfProposedWorkY__c;
        if (dcfinfrarec.FSM_SiteComments__c == null || dcfinfrarec.FSM_SiteComments__c == undefined || dcfinfrarec.FSM_SiteComments__c == '') {
            this.sketchText = [];
            this.sketchText.push(gridRefVal);
        } else {
            this.sketchText = [];
            this.sketchText.push(gridRefVal, dcfinfrarec.FSM_SiteComments__c, dcfinfrarec.FSM_SchedulingCommentsBox__c);
        }
        console.log('sketchText142 ----> ', JSON.stringify(this.sketchText));
        this.selimgs = JSON.parse(JSON.stringify(this.photoCaptureImageList));
        this.proformaimgs = JSON.parse(JSON.stringify(this.proformaPhotoCaptureImageList));
        //    console.log('proforma images when next from photocapture',JSON.stringify(this.proformaimgs));  
        this.openFileUploader = true;
    }
    @track pretextdata;
    //go to map and site icon upload screen
    handleClickNext(event) {

        this.openFileUploader = false;
        this.datafromfwr = JSON.parse(JSON.stringify(event.detail.data));
        console.log('insidehandle next in fwr------>', this.datafromfwr);
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

                // console.log('next from photocapture editor data',JSON.stringify(event.detail.imageeditor),'text',JSON.stringify(event.detail.shapes));

            }


            //console.log('1 next',JSON.stringify(this.imagesdata),'2 next----->',JSON.stringify(this.shapesdata),'3------>',JSON.stringify(this.textdata));
        }
        this.continuetogoldsketch = true;
        // this.openEditor = true;
    }
    //method to continue with gold sketch
    handleClickYes() {
        console.log('click yes', this.datafromfwr);
        this.continuetogoldsketch = false;
        this.openEditor = true;
    }
    //method to end the form at photo capture and create dcf record
    handleClickNo() {
        this.openEditor = false;
        this.continuetogoldsketch = false;
        if (this.isEdit == true) {
            this.updatedcfinrarecord();
        } else {
            this.createdcfinfrarecord();
        }


    }
    //if form is in edit mode
    async updatedcfinrarecord() {
        console.log('record id in fsmfwr', this.recordId);

        this.isLoading = true;
        const datafrom = JSON.parse(JSON.stringify(this.datafromfwr));
        this.dcfinfrarecordfields = datafrom.dcfdata;
        this.dcfinfrarecordfields.Id = this.recordId;
        console.log(' this.dcfinfrarecordfields update record', JSON.stringify(this.dcfinfrarecordfields));
        delete this.dcfinfrarecordfields.isvisited;
        console.log(' this.dcfinfrarecordfields update record', JSON.stringify(this.dcfinfrarecordfields));
        //multiselect
        if (JSON.stringify(this.dcfinfrarecordfields.FSM_LetterWarn__c) != undefined) {
            //add values to multiselect picklist
            const arr = this.dcfinfrarecordfields.FSM_LetterWarn__c.join(";");

            this.dcfinfrarecordfields.FSM_LetterWarn__c = arr;
        }

        const fields = this.dcfinfrarecordfields;
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            console.log('success');
            this.createcontentversion(this.recordId);


        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in updating dcf record',
                    message: error.body,
                    variant: 'error'
                })
            );
        });



        //this.updateworkstepfield(this.dcfinraid.id);



    }
    //if no selected create dcf infra record with photos from photocapture screen attached
    async createdcfinfrarecord() {

        this.isLoading = true;
        const datafrom = JSON.parse(JSON.stringify(this.datafromfwr));
        this.dcfinfrarecordfields = datafrom.dcfdata;
        console.log('surface type', this.dcfinfrarecordfields.FSM_LetterWarn__c);
        //multiselect
        console.log('dcfinfrarecordfields----->json----->', JSON.stringify(this.dcfinfrarecordfields.FSM_LetterWarn__c), '---', JSON.stringify(this.dcfinfrarecordfields));
        if (JSON.stringify(this.dcfinfrarecordfields.FSM_LetterWarn__c) != undefined) {
            //add values to multiselect picklist
            const arr = this.dcfinfrarecordfields.FSM_LetterWarn__c.join(";");

            this.dcfinfrarecordfields.FSM_LetterWarn__c = arr;
        }


        const fields = this.dcfinfrarecordfields;
        const recordInput = { apiName: DCFINFRA_OBJECT.objectApiName, fields };
        this.dcfinraid = await createRecord(recordInput);



        this.updateworkstepfield(this.dcfinraid.id);


    }
    //update status and workstep of dcf infra records
    async updateworkstepfield(dcfrecid) {

        const fields = {};
        fields['Id'] = dcfrecid; //populate it with current record Id
        fields['FSM_WorkStep__c'] = this.recordId;
        fields['FSM_Status__c'] = 'In Progress';
        //populate any fields which you want to update like this

        const recordInput = { fields };

        updateRecord(recordInput).then(() => {

            this.createcontentversion(this.dcfinraid.id)


        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body,
                    variant: 'error'
                })
            );
        });

        const datafromlineitem = JSON.parse(JSON.stringify(this.datafromfwr));
        this.dcfinfralineitems = datafromlineitem.dcflineitemdata;
        this.customerlineitemstoinsert = datafromlineitem.customerlineitems;

        if (JSON.stringify(this.customerlineitemstoinsert) != undefined) {
            // console.log('line item creation',JSON.stringify(this.customerlineitemstoinsert),dcfrecid);
            this.customerlineitemstoinsert.forEach((record) => {
                this.createDcfcustomerlineitemrecord(record, dcfrecid);
            });
        }
        //if this.bopps then customer line item will be inserted here
        if (JSON.stringify(this.dcfinfralineitems) != undefined) {

            // "No Of Line Items Eforms Of Same Type" field using count var as a part of SFI-1721........
            // Developer Name: Nishant Kumar
            let count = 0;
            this.dcfinfralineitems.forEach((record) => {
                count += 1;

                this.createDcflineitemrecord(record, dcfrecid, count);

            });

        } else {

            this.isdisable = false;
        }
    }

    async createDcfcustomerlineitemrecord(submitValues, parentdcfid) {
        const dcfcustlineitemdata = {
            FSM_CustomerName__c: submitValues.FSM_CustomerName__c,
            FSM_ContactNumber__c: submitValues.FSM_ContactNumber__c,
            FSM_ResidentialStatus__c: submitValues.FSM_ResidentialStatus__c,
            FSM_ContactWithCustomer__c: submitValues.FSM_ContactWithCustomer__c,
            FSM_CanISTBeIsolated__c: submitValues.FSM_CanISTBeIsolated__c,
            FSM_Address__c: submitValues.FSM_Address__c,
            RecordTypeId: this.addcustdcfinfralineitemrectypeid,
            FSM_DataCaptureFormInfra__c: parentdcfid,
            FSM_SectionType__c: 'Additional Customer'
        }
        const dcfcustlineitemdatainsert = JSON.parse(JSON.stringify(dcfcustlineitemdata))

        const recordInput = { apiName: FSM_DCFLineItemInfraOBJECT.objectApiName, fields: dcfcustlineitemdatainsert };

        createRecord(recordInput)
            .then((custlineitem) => {
                this.dcfcustlineitemid = custlineitem.id;
                // console.log('this.dcfcustlineitemid ',this.dcfcustlineitemid );
                submitValues = {};
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error creating customer line item record",
                        message: error,
                        variant: "error"
                    })
                );
            })
            .finally(() => {
                //this.isLoading = false;
            });


    }
    async updateCustomerlineitemrecord(submitValues) {
        const dcfcustlineitemdata = {
            FSM_CustomerName__c: submitValues.FSM_CustomerName__c,
            FSM_ContactNumber__c: submitValues.FSM_ContactNumber__c,
            FSM_ResidentialStatus__c: submitValues.FSM_ResidentialStatus__c,
            FSM_ContactWithCustomer__c: submitValues.FSM_ContactWithCustomer__c,
            FSM_CanISTBeIsolated__c: submitValues.FSM_CanISTBeIsolated__c,
            FSM_Address__c: submitValues.FSM_Address__c,
            Id: submitValues.recordId
        }
        const dcfcustlineitemdatainsert = JSON.parse(JSON.stringify(dcfcustlineitemdata))


        const fields = dcfcustlineitemdatainsert;
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            this.successmessagewindow = true;
            this.isLoading = false;



        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in updating customer line item record',
                    message: error.body,
                    variant: 'error'
                })
            );
        });

    }
    async createDcflineitemrecord(submitValues, parentdcfid, count) {
        console.log('inside createdcflineitems');
        const dcflineitemdata = {
            FSM_ValvesIDIdentifiedOnSketch__c: submitValues.FSM_ValvesIDIdentifiedOnSketch__c,
            FSM_ProposedOp__c: submitValues.FSM_ProposedOp__c,
            FSM_ValveChecked__c: submitValues.FSM_ValveChecked__c,
            FSM_GridRefX__c: submitValues.FSM_GridRefX__c,
            FSM_GridRefY__c: submitValues.FSM_GridRefY__c,
            FSM_CommentsForAllValves__c: submitValues.FSM_CommentsForAllValves__c,
            FSM_NoOfLineItemsEformsOfSameType__c: count,
            RecordTypeId: this.dcfinfralineitemrectypeid,
            FSM_DataCaptureFormInfra__c: parentdcfid,
            FSM_SectionType__c: 'Proposed Valve Operation'
        }

        const dcflineitemdatainsert = JSON.parse(JSON.stringify(dcflineitemdata))

        const recordInput = { apiName: FSM_DCFLineItemInfraOBJECT.objectApiName, fields: dcflineitemdatainsert };

        createRecord(recordInput)
            .then((dcflineitem) => {
                this.dcflineitenid = dcflineitem.id;

                submitValues = {};
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error creating record",
                        message: error,
                        variant: "error"
                    })
                );
            })
            .finally(() => {
                //this.isLoading = false;
            });

        //console.log('submitvalues',JSON.stringify(submitValues));


    }

    //update valves line item record
    async updateDcflineitemrecord(submitValues) {
        // console.log('submitValues.recordId',submitValues.recordId)
        const dcflineitemdata = {
            FSM_ValvesIDIdentifiedOnSketch__c: submitValues.FSM_ValvesIDIdentifiedOnSketch__c,
            FSM_ProposedOp__c: submitValues.FSM_ProposedOp__c,
            FSM_ValveChecked__c: submitValues.FSM_ValveChecked__c,
            FSM_GridRefX__c: submitValues.FSM_GridRefX__c,
            FSM_GridRefY__c: submitValues.FSM_GridRefY__c,
            FSM_CommentsForAllValves__c: submitValues.FSM_CommentsForAllValves__c,
            Id: submitValues.recordId
        }

        const dcflineitemdatainsert = JSON.parse(JSON.stringify(dcflineitemdata));
        const fields = dcflineitemdatainsert;
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            this.successmessagewindow = true;
            this.isLoading = false;



        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in updating dcf line item record',
                    message: error.body,
                    variant: 'error'
                })
            );
        });


    }

    //fetch dcf infra recordtypeid
    @wire(getObjectInfo, { objectApiName: FSM_DCFLineItemInfraOBJECT })
    getobjdata({ data, error }) {
        if (data) {
            let recmap = JSON.parse(JSON.stringify(data.recordTypeInfos));

            this.dcfinfralineitemrectypeid = Object.keys(recmap).find(recTyp => recmap[recTyp].name === 'Proposed Valve Operation');
            this.addcustdcfinfralineitemrectypeid = Object.keys(recmap).find(recTyp => recmap[recTyp].name === 'Additional Customer');
            //   console.log('this.addcustdcfinfralineitemrectypeid',this.addcustdcfinfralineitemrectypeid);
        }
    }

    //create content version records to be inserted        
    createcontentversion(dcfrecordid) {
        console.log('inside conetent version', this.photoCaptureImageList.length);
        if (this.photoCaptureImageList.length > 0) {
            console.log('inside', this.photoCaptureImageList.length);
            this.photoCaptureImageList.forEach((element, index) => {
                const photostoupload = JSON.stringify(element.data);

                const filecontentdata = photostoupload.split(',')[1];
                const removeLast3 = filecontentdata.slice(0, -1);

                //const metadata=element.metadata.fileName;
                const fileext = element.metadata.ext;


                this.filesData.push({ 'fileName': 'Photo ' + index + '.' + fileext, 'fileContent': removeLast3 });
            });
        }


        //proforma Image Data
        // if(JSON.stringify(this.proformaPhotoCaptureImageList) != '[]' || JSON.stringify(this.proformaPhotoCaptureImageList) != undefined || this.proformaPhotoCaptureImageList.length > 0){
        if (this.proformaPhotoCaptureImageList.length > 0) {
            console.log('inside proforma fwr', this.proformaPhotoCaptureImageList);
            this.proformaPhotoCaptureImageList.forEach((element, index) => {
                const proformaphotostoinsert = JSON.stringify(element.data);

                const filecontentdata = proformaphotostoinsert.split(',')[1];
                const removeLast3 = filecontentdata.slice(0, -1);

                //const metadata=element.metadata.fileName;
                const fileext = element.metadata.ext;


                this.filesData.push({ 'fileName': 'Proforma ' + index + '.' + fileext, 'fileContent': removeLast3 });
            });
        }


        //end of proforma img data
        let allcvtoinsert = [];
        // console.log('files data length',this.filesData.length);
        if (this.filesData.length == 0 && this.isEdit == true) {
            console.log('inside filesdata edit true', this.isEdit);
            this.insertlineitems(dcfrecordid);

        } else if (this.filesData.length == 0 && (this.isEdit == false || this.isEdit == undefined)) {
            this.showToast('Error!', 'error', 'Select files for upload');
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
                console.log('all cvinsert', allcvtoinsert);

            }

            this.cvinsert(allcvtoinsert, dcfrecordid);


        }
    }
    //insert content version
    cvinsert(cvarr, dcfrecordid) {

        console.log('dcfrecordid', dcfrecordid);
        // cvarr.forEach((record,index) => {

        //     const payload={apiName:'ContentVersion',fields:record};

        //     createRecord(payload).then(cversion => {
        //         this.cvid = cversion.id;


        //     if (index == cvarr.length-1) {

        //     this.filesData = [];
        //     }
        //     }).catch(error => {

        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Error',
        //                 message: 'Error creating content version',
        //                 variant: 'error',
        //             }),
        //         );
        //         this.error=error;
        //     });



        //     }); 
        //     this.successmessagewindow=true;
        // this.isLoading=false;

        let promises = [];

        cvarr.forEach(version => {
            let recordInput = { apiName: 'ContentVersion', fields: version };
            promises.push(createRecord(recordInput));
        });

        Promise.all(promises)
            .then(results => {
                // Handle successful insertion
                console.log('Content versions inserted successfully:', results);
                // this.insertlineitems(dcfrecordid);
                this.filesData = [];
                // Optionally, reset form or perform other actions
            })
            .catch(error => {
                // Handle error
                console.error('Error inserting content versions:', error);
            });
        this.successmessagewindow = true;
        this.isLoading = false;

    }

    insertlineitems(dcfrecordid) {
        console.log('line item creation');
        const datafromlineitem = JSON.parse(JSON.stringify(this.datafromfwr));
        if (datafromlineitem.customerlineitems != undefined) {


            if (JSON.stringify(this.customerlineitemstoinsert) != undefined) {

                this.customerlineitemstoinsert = datafromlineitem.customerlineitems;
                //  console.log('line item creation',JSON.stringify(this.customerlineitemstoinsert));
                this.customerlineitemstoinsert.forEach((record) => {
                    if (record.recordId == '') {
                        this.createDcfcustomerlineitemrecord(record, dcfrecordid);
                    } else {
                        this.updateCustomerlineitemrecord(record);
                    }
                });
            }
        }
        //if this.bopps then customer line item will be inserted here
        if (datafromlineitem.dcflineitemdata != undefined) {
            console.log('lineitem');
            this.dcfinfralineitems = datafromlineitem.dcflineitemdata;
            if (JSON.stringify(this.dcfinfralineitems) != undefined) {
                console.log('dcfinfralineitems', this.dcfinfralineitems);
                // "No Of Line Items Eforms Of Same Type" field using count var as a part of SFI-1721........
                // Developer Name: Nishant Kumar
                let count = 0;
                this.dcfinfralineitems.forEach((record) => {
                    count += 1;
                    if (record.recordId == '') {
                        this.createDcflineitemrecord(record, dcfrecordid, count);
                    } else {
                        this.updateDcflineitemrecord(record);
                    }

                });
            }
        }
        this.successmessagewindow = true;
        this.isLoading = false;

    }

    handlePhotoCaptureImages(event) {
        this.photoCaptureImageList = event.detail;
    }
    // open dcf form from photocapture
    handlePrevfromphotocapture(event) {
        // let ip =this.template.querySelector('c-fsm-followonworkrequest-infra');

        let ip = this.template.querySelector('c-fsmfurtherworkrequestofflineform');
        if (ip == undefined || ip == null) {
            this.openFileUploader = false;
            this.openlastpageofform = JSON.parse(JSON.stringify(event.detail.data));
            console.log('handle prev1', this.openlastpageofform);
            if (JSON.stringify(this.proformaPhotoCaptureImageList) != '[]' || JSON.stringify(this.isprevfromnextcmp) != undefined) {
                this.retainproformaimgs = JSON.parse(JSON.stringify(this.proformaPhotoCaptureImageList));
                // console.log('prev from photo capture proformaPhotoCaptureImageList',JSON.stringify(this.retainproformaimgs));
            }
            //this.retainproformaimgs=JSON.parse(JSON.stringify(this.proformaPhotoCaptureImageList));


            this.openRecordPage = true;

        } else {

            this.openFileUploader = false;
            this.openlastpageofform = JSON.parse(JSON.stringify(event.detail.data));
            console.log('handle prev2', this.openlastpageofform);
            if (JSON.stringify(this.proformaPhotoCaptureImageList) != '[]' || JSON.stringify(this.isprevfromnextcmp) != undefined) {
                this.retainproformaimgs = JSON.parse(JSON.stringify(this.proformaPhotoCaptureImageList));
                //console.log('prev from photo capture proformaPhotoCaptureImageList',JSON.stringify(this.retainproformaimgs));
            }

            ip.handlepreviousfromfwr(this.openlastpageofform);


        }

    }
    handlePrevfromsketchmaincmp(event) {
        // console.log('inside handle prev from sketch main');
        this.openFileUploader = true;
        this.openEditor = false;
        this.openRecordPage = false;
        this.openlastpageofform = JSON.parse(JSON.stringify(event.detail.datatophotocapture));
        //  console.log('inside handle prev fsm fwr',this.openlastpageofform);
        this.selimgs = JSON.parse(JSON.stringify(event.detail.selphotos));
        //this.proformaimgs=JSON.parse(JSON.stringify(event.detail.proformaphoto));

        if (!!JSON.stringify(event.detail.basemapdata)) {
            this.mapdata = JSON.parse(JSON.stringify(event.detail.basemapdata));
            this.sitedataicon = JSON.parse(JSON.stringify(event.detail.icondata));
            this.sketchiconimages = JSON.parse(JSON.stringify(event.detail.sketchicondata));
            this.tmasketchiconimages = JSON.parse(JSON.stringify(event.detail.tmasketchicondata));
            console.log('inside tmasketchiconimages');

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
    //method to handle event dispatched when proforma photos are selected
    handleproformaphotoselect(event) {

        this.proformaPhotoCaptureImageList = event.detail;
        // console.log('proforma photos',JSON.stringify(this.proformaPhotoCaptureImageList));

    }

}
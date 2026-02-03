import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class sketchMainComp extends LightningElement {

    @track openEditor = false;
    closewindow = false;
    openfileuploader = true;
    @track baseImageData;
    @track draggableImageData = [];
    @track sketchImageData = [];
    @track tmasketchImageData = [];
    @api recordId;
    @api formdata;
    @api isMobile;
    @api dcflineitem;
    @api woId;
    @api isEdit;
    @api sketchText;
    @api photoImages;
    @api wirexecuted;
    @api wirelineitemsexecuted;
    @api formtype;
    @api proformaImages;
    @api siteicon;
    @api selbsemap;
    @api sketchimagesdata;
    @api tmasketchimagesdata;
    @api isboppsflow;
    @api istmaflow;
    @api isnormalflow;
    // @api finaleditorimg;
    @api textoneditor = [];
    @api imagesoneditor = [];
    @api shapesoneditor = [];
    @api preloaddata = [];

    //siteicon;
    // selbsemap;
    connectedCallback() {
        console.log('inside sketch main connected callback');
        console.log('wirexecuted', this.wirexecuted);
        console.log('inside if connected callback sketch main', JSON.stringify(this.proformaImages));
        
        if(this.tmasketchimagesdata != undefined){
            console.log('inside if 321');
            this.tmasketchImageData=[this.tmasketchimagesdata];
        }
        
        
        if (!!JSON.stringify(this.selbsemap)) {

            this.baseImageData = this.selbsemap;
        }
    }
    handleEditor() {
        //console.log('inside handle editor',JSON.stringify(this.selbsemap),JSON.stringify(this.baseImageData));
        //console.log('TMA Sketch', JSON.stringify(this.tmasketchImageData));
        //console.log('Base Map Sketch', JSON.stringify(this.baseImageData));
        if (!!JSON.stringify(this.baseImageData) || JSON.stringify(this.tmasketchImageData) != '[]') {
            console.log('Inside CHECKING baseImageData tmasketchImageData');
            console.log('this.baseImageData--> ' ,this.baseImageData.length);
             if (!!JSON.stringify(this.baseImageData)) {
                console.log('Inside CHECKING baseImageData EXIST');
                //console.log('tma sjetch images',JSON.stringify(this.tmasketchimagesdata));
                console.log('inside handle editor if one -------->');
                if ((JSON.stringify(this.tmasketchImageData) == '[]' || this.tmasketchimagesdata.length === 0)) {
                    console.log('checking TMA Image exist');
                    //if (JSON.stringify(this.tmasketchImageData) != '[]') {

                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select a TMA Banner',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);


                } else {



                    if (JSON.stringify(this.selbsemap) && JSON.stringify(this.baseImageData)) {
                        console.log('inside handle editor if1', JSON.stringify(this.tmasketchimagesdata));
                        this.baseImageData = this.selbsemap;
                        if (JSON.stringify(this.siteicon) != '[]') {

                            this.draggableImageData = [...this.siteicon];
                        }
                        if (JSON.stringify(this.sketchimagesdata) != '[]') {

                            this.sketchImageData = [...this.sketchimagesdata];
                        }
                        // if (JSON.stringify(this.tmasketchimagesdata) != '[]' || JSON.stringify(this.tmasketchimagesdata) != 'undefined') {
                        //     console.log('tma sjetch images', JSON.stringify(this.tmasketchimagesdata));
                        //     this.tmasketchImageData = [...this.tmasketchimagesdata];
                        //     console.log('tma sjetch tmasketchImageData', JSON.stringify(this.tmasketchImageData));
                        // }


                        if (JSON.stringify(this.tmasketchimagesdata) != '[]' || JSON.stringify(this.tmasketchimagesdata) != 'undefined') {
                            console.log('tma sjetch images');
                            this.tmasketchImageData = [...this.tmasketchimagesdata];
                            console.log('tma sjetch tmasketchImageData');
                        }
                        console.log('text main comp---> ',JSON.stringify(this.textoneditor));
                        // if(JSON.stringify(this.shapesoneditor) !='[]' || JSON.stringify(this.shapesoneditor) != 'undefined' ){
                        if (Array.isArray(this.shapesoneditor)) {
                            //console.log('type of', typeof this.shapesoneditor, '-------', typeof this.imagesoneditor, '----', typeof this.preloaddata);
                            //console.log('handleeditor-------------->', JSON.stringify(this.textoneditor), '-- imagesoneditor--', JSON.stringify(this.imagesoneditor), '--shapesoneditor--', JSON.stringify(this.shapesoneditor), 'preloadinnextsketchmain', JSON.stringify(this.preloaddata));
                            if (JSON.stringify(this.textoneditor) != '[]' || JSON.stringify(this.textoneditor) != 'undefined') {
                                this.textoneditor = JSON.parse(JSON.stringify(this.textoneditor));
                            }
                            if (JSON.stringify(this.imagesoneditor) != '[]' || JSON.stringify(this.imagesoneditor) != 'undefined') {
                                this.imagesoneditor = JSON.parse(JSON.stringify(this.imagesoneditor));
                            }
                            if (JSON.stringify(this.shapesoneditor) != '[]' || JSON.stringify(this.shapesoneditor) != 'undefined') {
                                this.shapesoneditor = JSON.parse(JSON.stringify(this.shapesoneditor));
                            }
                            if (JSON.stringify(this.preloaddata) != '[]' || JSON.stringify(this.preloaddata) != 'undefined') {
                                this.preloaddata = JSON.parse(JSON.stringify(this.preloaddata));
                            }


                        }


                    }

                    this.openEditor = true;
                    this.openfileuploader = false;


                }
            } else {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a Base Map',
                    variant: 'error',
                });
                this.dispatchEvent(event);
            }

        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please select a Base Map and TMA Banner',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }

    }

    async handleImagesSelected(event) {
        console.log('parent calles...');
        this.baseImageData = event.detail;
    }

    async handleDraggableImages(event) {
        console.log('parent calles draggable images...', this.draggableImageData);
        this.draggableImageData = event.detail;
        this.siteicon = [...this.draggableImageData];
    }

    async handlesketchimages(event) {

        this.sketchImageData = event.detail;
        this.sketchimagesdata = [...this.sketchImageData];
        // console.log('parent calles sketch images...', JSON.stringify(this.sketchImageData));
    }
    async handletmasketchimages(event) {

        this.tmasketchImageData = event.detail;
        this.tmasketchimagesdata = [...this.tmasketchImageData];
        // console.log('parent calles tma images...', JSON.stringify(this.tmasketchImageData));
    }

    handleproformaimages(event) {
        this.proformaImages = event.detail;
        // console.log('proforma images from handleproformaimages', Json.stringify(this.proformaImages));
    }

    //previous from file uploader screen

    handlePrevious() {
        this.openEditor = false;
        this.openfileuploader = false;
        const datatoparentfsmcmp = JSON.parse(JSON.stringify(this.formdata));
        console.log('inside previous sketch main i.e file uploader', datatoparentfsmcmp);

        const photossel = JSON.parse(JSON.stringify(this.photoImages));
        // const proformaimg=JSON.parse(JSON.stringify(this.proformaImages));

        if (!!JSON.stringify(this.baseImageData) && (JSON.stringify(this.shapesoneditor) == undefined || JSON.stringify(this.textoneditor) == undefined || JSON.stringify(this.imagesoneditor) == undefined)) {
            //console.log('inside if sketch main',JSON.stringify(this.sketchImageData),'----->',JSON.stringify(this.tmasketchImageData));
            console.log('inside if sketch main');
            const basemapdata = JSON.parse(JSON.stringify(this.baseImageData));
            const icondata = JSON.parse(JSON.stringify(this.draggableImageData));
            const sketchicondata = JSON.parse(JSON.stringify(this.sketchImageData));
            const tmasketchicondata = JSON.parse(JSON.stringify(this.tmasketchImageData));
            console.log('inside if sketch main');
            this.dispatchEvent(
                new CustomEvent("prev", {

                    detail: { datatophotocapture: datatoparentfsmcmp, selphotos: photossel, basemapdata: basemapdata, icondata: icondata, sketchicondata: sketchicondata, tmasketchicondata: tmasketchicondata }
                })
            );

        } else if (!!JSON.stringify(this.shapesoneditor) || !!JSON.stringify(this.textoneditor) || !!JSON.stringify(this.imagesoneditor)) {
            console.log('inside else if sketch main');
            const basemapdata = JSON.parse(JSON.stringify(this.baseImageData));
            const icondata = JSON.parse(JSON.stringify(this.draggableImageData));
            const sketchicondata = JSON.parse(JSON.stringify(this.sketchImageData));
            const tmasketchicondata = JSON.parse(JSON.stringify(this.tmasketchImageData));
            const textfrmeditor = JSON.parse(JSON.stringify(this.textoneditor));
            const imgsfrmeditor = JSON.parse(JSON.stringify(this.imagesoneditor));
            const shapesfrmeditor = JSON.parse(JSON.stringify(this.shapesoneditor));
             const preloadtextfromeditor = JSON.parse(JSON.stringify(this.preloaddata));
            //  const preloadtextfromeditor = 'Testing text added by brajesh';

            this.dispatchEvent(
                new CustomEvent("prev", {
                    // detail:{data:datatofileuploadercmp,image:this.imageData,siteicon:this.siteicon,selbsemap:this.selbsemap}
                    detail: { datatophotocapture: datatoparentfsmcmp, selphotos: photossel, basemapdata: basemapdata, icondata: icondata, sketchicondata: sketchicondata, tmasketchicondata: tmasketchicondata, img: imgsfrmeditor, txt: textfrmeditor, shape: shapesfrmeditor, preloadtext: preloadtextfromeditor }
                })
            );
        } else {

            console.log('inside else sketch main');
            this.dispatchEvent(
                new CustomEvent("prev", {

                    detail: { datatophotocapture: datatoparentfsmcmp, selphotos: photossel }
                })
            );


        }

    }

    handlecloseform(event) {
        console.log('close window', JSON.stringify(event.detail));
        if (!!event.detail) {
            this.openEditor = false;
            this.openfileuploader = false;
            this.closewindow = true;
        }
    }
    opensketchfileuploader(event) {
        console.log('Main comp 244---> ',JSON.stringify(event.detail.preloaddata));
        console.log('Main comp 245---> ',JSON.stringify(event.detail.textarr));
        this.selbsemap = JSON.parse(JSON.stringify(event.detail.mapimg));
        console.log('base map on prev from editor', this.selbsemap);
        this.siteicon = JSON.parse(JSON.stringify(event.detail.icons));
        this.textoneditor = JSON.parse(JSON.stringify(event.detail.textarr));
        this.imagesoneditor = JSON.parse(JSON.stringify(event.detail.imgarr));
        this.shapesoneditor = JSON.parse(JSON.stringify(event.detail.shapesarr));
        this.preloaddata = JSON.parse(JSON.stringify(event.detail.preloaddata));
        this.sketchimagesdata = JSON.parse(JSON.stringify(event.detail.sketchimgretain));
        this.tmasketchimagesdata = JSON.parse(JSON.stringify(event.detail.tmaimgretain));
        // this.finaleditorimg=JSON.parse(JSON.stringify(event.detail.finalimg));
        //console.log('finaleditorarr',JSON.stringify(this.textoneditor),'-- images--',JSON.stringify(this.imagesoneditor),'--shapes--',JSON.stringify(this.shapesoneditor));
        // console.log('finaleditorarrobj',this.textoneditor,'-- images--',this.imagesoneditor,'--shapes--',this.shapesoneditor);
        this.openEditor = false;
        this.openfileuploader = true;
    }



}
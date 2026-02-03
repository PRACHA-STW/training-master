import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class sketchFileUploader extends LightningElement {
    @track imageData;
    @track draggableImageData =[];
    @track sketchImageData =[];
    @track tmasketchData=[];
    @track movableImageData =[];
    @api recordId;
    @api objectApiName;
@api dcfformdata;
@api retainbasemap;
@api retainsiteicon;
@api retainsketchimg;
@api retaintmaimg;
@api textsarr;
@api shapesarr;
@api imagesarr;
@api isboppsflow;
@api isnormalflow;
@api istmaflow;
//@api retaineditor
@api preloadedtextprevarr;


   // nextId = 0;
    
    connectedCallback(){
        console.log('dcfformdata in file textsarr',JSON.stringify(this.textsarr),'shapesarr',JSON.stringify(this.shapesarr),'preloadinfileuploader',JSON.stringify(this.preloadedtextprevarr));
        if(!!JSON.stringify(this.retainbasemap)){
            this.imageData=JSON.parse(JSON.stringify(this.retainbasemap));
        }
        if(!!JSON.stringify(this.retainsiteicon)){
            this.draggableImageData=JSON.parse(JSON.stringify(this.retainsiteicon));
        }
        if(!!JSON.stringify(this.retainsketchimg)){
            this.sketchImageData=JSON.parse(JSON.stringify(this.retainsketchimg));
        }
        if(!!JSON.stringify(this.retaintmaimg)){
            this.tmasketchData=JSON.parse(JSON.stringify(this.retaintmaimg));
        }
            console.log('dcfformdata in file uploader',this.dcfformdata);
       
       
    }
    get isEditor() {
        return this.imageData != null;
    }
    handleDeletetmasketchClick(event){
        const fileIdToDelete = event.currentTarget.dataset.id;
        //  console.log('event.target.dataset -- ', fileIdToDelete);
          //this.uploadedFiles = this.uploadedFiles.filter(file => file.id !== fileIdToDelete);
    
          const newImgSet = [];
          for(let i=0; i< this.tmasketchData.length; i++){
            const imgD = this.tmasketchData[i].id;
              
              if(imgD != fileIdToDelete){
                newImgSet.push( this.tmasketchData[i]) ;
              }
          }
          this.tmasketchData = newImgSet;

          this.dispatchEvent(
            new CustomEvent("tmasketchimages", {
            detail: this.tmasketchData
            })
        );
        // this.dispatchEvent(
        //     new CustomEvent("draggableimages", {
        //     detail: this.draggableImageData
        //     })
        // );
        // this.dispatchEvent(
        //     new CustomEvent("sketchimages", {
        //     detail: this.sketchImageData
        //     })
        // );
        // this.dispatchEvent(
        //     new CustomEvent("selectimages", {
        //     detail: this.imageData
        //     })
        // );
        

    }

    handleDeletesiteiconsClick(event){
        const fileIdToDelete = event.currentTarget.dataset.id;
          const newImgSet = [];
          for(let i=0; i< this.draggableImageData.length; i++){
            const imgD = this.draggableImageData[i].id;
              
              if(imgD != fileIdToDelete){
                newImgSet.push( this.draggableImageData[i]) ;
              }
          }
          this.draggableImageData = newImgSet;
          console.log('draggableImageData lenght del',this.draggableImageData.length);
          
          this.dispatchEvent(
            new CustomEvent("draggableimages", {
            detail: this.draggableImageData
            })
        );
    //     this.dispatchEvent(
    //         new CustomEvent("tmasketchimages", {
    //         detail: this.tmasketchData
    //         })
    //     );

    //    this.dispatchEvent(
    //         new CustomEvent("sketchimages", {
    //         detail: this.sketchImageData
    //         })
    //     ); 
    //     this.dispatchEvent(
    //         new CustomEvent("selectimages", {
    //         detail: this.imageData
    //         })
    //     );
        

    }


    handleDeletesketchiconsClick(event){
        const fileIdToDelete = event.currentTarget.dataset.id;
        const newImgSet = [];
        for(let i=0; i< this.sketchImageData.length; i++){
          const imgD = this.sketchImageData[i].id;
            
            if(imgD != fileIdToDelete){
              newImgSet.push( this.sketchImageData[i]) ;
            }
        }
        this.sketchImageData = newImgSet;
        this.dispatchEvent(
          new CustomEvent("sketchimages", {
          detail: this.sketchImageData
          })
      );

    //   this.dispatchEvent(
    //     new CustomEvent("draggableimages", {
    //     detail: this.draggableImageData
    //     })
    // );
    // this.dispatchEvent(
    //     new CustomEvent("tmasketchimages", {
    //     detail: this.tmasketchData
    //     })
    // );
    // this.dispatchEvent(
    //     new CustomEvent("selectimages", {
    //     detail: this.imageData
    //     })
    // );
    

    }

    async handlebaseFilesSelected(event){
        const files = event.target.files;
        console.log('file 1');

        let data = await this.readFile(files[0]);
        console.log('file 2');
        let metadata = await this.readMetadata(files[0]);

        this.imageData = {
            data: data,
            metadata: metadata
        }

        //pass the image details to parent component
        this.dispatchEvent(
            new CustomEvent("selectimages", {
            detail: this.imageData
            })
        );
        
    }

    //handle site Icons
    async handledraggableFilesSelected(event){
        const dfiles = event.target.files;
        const numFiles = dfiles.length;
        let nextId = 0;
        let totalInformIcons = 0;
        if(this.draggableImageData.length>0){
            let sitelen=this.draggableImageData.length;
            nextId=sitelen;
            totalInformIcons = this.draggableImageData.length + numFiles;
        }else{
            totalInformIcons = numFiles;
        }
        
        if(totalInformIcons > 6){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'You cannot select more than 6 inform icons',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }else{
        
            for (let i = 0; i < numFiles; i++) {
            let dfile = dfiles[i];
            
            let data = await this.readFile(dfile);
            let metadata = await this.readMetadata(dfile);
            
            this.draggableImageData.push({
                id: nextId++,
                data: data,
                metadata: metadata
            });
        }

        //pass the image details to parent component
        this.dispatchEvent(
            new CustomEvent("draggableimages", {
            detail: this.draggableImageData
            })
        );
    }
        
    }

//handle sketch images
    async handlesketchFilesSelected(event){
        const dfiles = event.target.files;
        const numFiles = dfiles.length;
        // if(this.sketchImageData.length > 0)
        //     {
        //         console.log('nextId inside if',this.sketchImageData.length);  
        //         let lengthofarr=this.sketchImageData.length;
        //         this.nextId=lengthofarr;
        //         console.log('nextId inside if',this.nextId);  
        //     }
        let nextId = 0;
        let totalSketchhIcons = 0;
        if(this.sketchImageData.length>0){
            let sketchlen=this.sketchImageData.length;
            nextId=sketchlen;
            totalSketchhIcons = this.sketchImageData.length + numFiles;
        }else{
            totalSketchhIcons = numFiles;
        }
        if(totalSketchhIcons > 10){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'You cannot select more than 10 sketch icons',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }else{
        for (let i = 0; i < numFiles; i++) {
            let dfile = dfiles[i];
            
            let data = await this.readFile(dfile);
            let metadata = await this.readMetadata(dfile);
            console.log('length',this.sketchImageData.length); 
            
            this.sketchImageData.push({
                id: nextId++,
                data: data,
                metadata: metadata
            });
          //  console.log('INSIDE HANDLE SKETCH SELECT',JSON.stringify(this.sketchImageData),'length',this.sketchImageData.length);
        }
        this.dispatchEvent(
            new CustomEvent("sketchimages", {
            detail: this.sketchImageData
            })
        );
    }
    }


     //handle site Icons
     async handletmasketchSelected(event){
        const dfiles = event.target.files;
        const numFiles = dfiles.length;
        console.log('TMA Sketch Images Count: ', numFiles);
        let nextId = 0;
        if(this.tmasketchData.length>0){
            let tmalen=this.tmasketchData.length;
            nextId=tmalen;
        }
        for (let i = 0; i < numFiles; i++) {            
            let dfile = dfiles[i];
            
            let data = await this.readFile(dfile);
            let metadata = await this.readMetadata(dfile);
            
            this.tmasketchData.push({
                id: nextId++,
                data: data,
                metadata: metadata
            });
          //  console.log('INSIDE HANDLE tma SKETCH SELECT',JSON.stringify(this.tmasketchData));
        }

        //pass the image details to parent component
        this.dispatchEvent(
            new CustomEvent("tmasketchimages", {
            detail: this.tmasketchData
            })
        );
        
    }

    //handle movable Icons
    async handleMovableFilesSelected(event){
        const dfiles = event.target.files;
        const numFiles = dfiles.length;

        for (let i = 0; i < numFiles; i++) {
            let dfile = dfiles[i];
            
            let data = await this.readFile(dfile);
            let metadata = await this.readMetadata(dfile);
            
            this.movableImageData.push({
                id: this.nextId++,
                data: data,
                metadata: metadata
            });
        }

        //pass the image details to parent component
        this.dispatchEvent(
            new CustomEvent("movableimages", {
            detail: this.movableImageData
            })
        );
        
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
          console.log('read metadata');
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
          console.log('###');
          //console.log('Metadata for..'+'${fullFileName}');
          //console.log(`Metadata for '${fullFileName}': ${JSON.stringify(metadata)}`);
          resolve(metadata);
        });
    }
}
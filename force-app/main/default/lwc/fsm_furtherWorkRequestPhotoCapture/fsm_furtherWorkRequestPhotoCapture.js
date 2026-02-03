import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Fsm_furtherWorkRequestPhotoCapture extends LightningElement {

  @track imageData = [];
  @api sketchText;
  @track nextId = 0;
  opendcfform = false;
  opensketcheditor = false;
  @api formdata
  @api selectedimgs;
  @api siteicon;
  @api selbsemap;
  @api imgsarreditor;
  @api txtarreditor;
  @api shapearreditor;
  @api preloadedtxt;
  @api sketchimagesdata;
  @api tmasketchimagesdata;
  @api isboppsflow;
  @api istmaflow;
  @api isnormalflow;
  @api isEdit; // brajesh
  connectedCallback() {
    console.log("isEdit--->", this.isEdit);
    if (!!JSON.stringify(this.selectedimgs)) {
      this.imageData = JSON.parse(JSON.stringify(this.selectedimgs))

    }
  }
  // handlePhotoSelect(event) {

  //   const fileCount = event.target.files.length + this.imageData.length;


  //   //if(fileCount > 3 || fileCount < 3){

  //   //show error message
  //   /*const event = new ShowToastEvent({
  //     title: 'Error',
  //     message: 'Please select exactly 3 photos',
  //     variant: 'error',
  //   });
  //   this.dispatchEvent(event);*/

  //   //  }else{
  //   this.selectedPhotos(event);
  //   //}


  // }
  async handlePhotoSelect(event) {
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
        this.imageData.push({
          id: this.nextId++,
          data: data,
          metadata: metadata,
          className: ''
        });
      } else {
        removedFiles.push(dfile); // Track files that are too large
      }

    }
    // Handle the valid files
    if (validFiles.length > 0) {
      this.dispatchEvent(
        new CustomEvent("photocapture", {
          detail: this.imageData
        })
      );
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



// compress brajesh
// Function to compress the image using a canvas
// compressImage(file) {
//   return new Promise((resolve, reject) => {
//       const reader = new FileReader();
//       reader.onload = (event) => {
//           const img = new Image();
//           img.onload = () => {
//               const canvas = document.createElement('canvas');
//               const ctx = canvas.getContext('2d');

//               // Define max dimensions for the image
//               const maxWidth = 800;
//               const maxHeight = 800;
//               let width = img.width;
//               let height = img.height;

//               // Adjust image size based on max dimensions while maintaining the aspect ratio
//               if (width > height) {
//                   if (width > maxWidth) {
//                       height = (height * maxWidth) / width;
//                       width = maxWidth;
//                   }
//               } else {
//                   if (height > maxHeight) {
//                       width = (width * maxHeight) / height;
//                       height = maxHeight;
//                   }
//               }

//               canvas.width = width;
//               canvas.height = height;
//               ctx.drawImage(img, 0, 0, width, height);

//               // Convert the canvas to a Blob with a specific image quality
//               canvas.toBlob(
//                   (blob) => {
//                       if (blob) {
//                           resolve(blob);
//                       } else {
//                           reject(new Error('Image compression failed'));
//                       }
//                   },
//                   'image/*', // Image format
//                   0.9 // Compression quality (70%)
//               );
//           };
//           img.onerror = reject;
//           img.src = event.target.result;
//       };
//       reader.onerror = reject;
//       reader.readAsDataURL(file);
//   });
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
              }, file.type, 0.6); // Adjust compression quality (0.7 is 70%)
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



  async selectedPhotos(event) {
    // const dfiles = event.target.files;
    // const numFiles = dfiles.length;

    // for (let i = 0; i < numFiles; i++) {
    //   let dfile = dfiles[i];

    //   // let data = await this.readFile(dfile);
    //   // let metadata = await this.readMetadata(dfile);

    //   const compressedBlob = await this.compressImage(dfile);

    //   // Convert the compressed image to Base64 data
    //   const data = await this.blobToDataURL(compressedBlob);
      
    //   let metadata = await this.readFileMetadata(dfile);
    //   this.imageData.push({
    //     id: this.nextId++,
    //     data: data,
    //     metadata: metadata,
    //     className: ''
    //   });
    // }

    //pass the image details to parent component
    // this.dispatchEvent(
    //   new CustomEvent("photocapture", {
    //     detail: this.imageData
    //   })
    // );

  }

  //go to dcf form
  handlePrev() {
    this.opendcfform = true;
    const datatoparentcmp = JSON.parse(JSON.stringify(this.formdata));
    console.log('data in photo capture prev', datatoparentcmp);
    this.dispatchEvent(
      new CustomEvent("prevbtn", {
        detail: { data: datatoparentcmp, image: this.imageData, }
      })
    );

  }

  //go to sketch editor
  handleClick() {
    if (this.imageData.length == 0 && this.isEdit == true) {
      const datatofileuploadercmp = JSON.parse(JSON.stringify(this.formdata));
      console.log('editor items null', JSON.stringify(this.imgsarreditor));
      this.opensketcheditor = true;
      if (!!this.siteicon && JSON.stringify(this.shapearreditor) == undefined) {
        console.log('inside if1');
        this.dispatchEvent(
          new CustomEvent("nextbtn", {
            detail: { data: datatofileuploadercmp, image: this.imageData, siteicon: this.siteicon, selbsemap: this.selbsemap, sketchimg: this.sketchimagesdata, tmaimg: this.tmasketchimagesdata }
            //detail:{data:datatofileuploadercmp,image:this.imageData,siteicon:this.siteicon,selbsemap:this.selbsemap,imageeditor:this.imgsarreditor,shapes:this.shapearreditor,text:this.txtarreditor}
          })
        );
      } else if (!!JSON.stringify(this.shapearreditor)) {
        console.log('inside else if1');
        this.dispatchEvent(
          new CustomEvent("nextbtn", {
            // detail:{data:datatofileuploadercmp,image:this.imageData,siteicon:this.siteicon,selbsemap:this.selbsemap}
            detail: { data: datatofileuploadercmp, image: this.imageData, siteicon: this.siteicon, selbsemap: this.selbsemap, sketchimg: this.sketchimagesdata, tmaimg: this.tmasketchimagesdata, imageeditor: this.imgsarreditor, shapes: this.shapearreditor, text: this.txtarreditor, pretext: this.preloadedtxt }
          })
        );
      }
      else {
        console.log('inside else1');
        this.dispatchEvent(
          new CustomEvent("nextbtn", {
            detail: { data: datatofileuploadercmp, image: this.imageData }
          })
        );
      }

    } else {


      if (!!this.imageData && this.imageData.length != 3) {
        console.log('length photocapture', this.imageData.length);
        const event = new ShowToastEvent({
          title: 'Error',
          message: 'Please select exactly 3 photos',
          variant: 'error',
        });
        this.dispatchEvent(event);
      } else {

        const datatofileuploadercmp = JSON.parse(JSON.stringify(this.formdata));
        console.log('editor items null', JSON.stringify(this.imgsarreditor));
        this.opensketcheditor = true;
        if (!!this.siteicon && JSON.stringify(this.shapearreditor) == undefined) {
          console.log('inside if1');
          this.dispatchEvent(
            new CustomEvent("nextbtn", {
              detail: { data: datatofileuploadercmp, image: this.imageData, siteicon: this.siteicon, selbsemap: this.selbsemap, sketchimg: this.sketchimagesdata, tmaimg: this.tmasketchimagesdata }
              //detail:{data:datatofileuploadercmp,image:this.imageData,siteicon:this.siteicon,selbsemap:this.selbsemap,imageeditor:this.imgsarreditor,shapes:this.shapearreditor,text:this.txtarreditor}
            })
          );
        } else if (!!JSON.stringify(this.shapearreditor)) {
          console.log('inside else if1');
          this.dispatchEvent(
            new CustomEvent("nextbtn", {
              // detail:{data:datatofileuploadercmp,image:this.imageData,siteicon:this.siteicon,selbsemap:this.selbsemap}
              detail: { data: datatofileuploadercmp, image: this.imageData, siteicon: this.siteicon, selbsemap: this.selbsemap, sketchimg: this.sketchimagesdata, tmaimg: this.tmasketchimagesdata, imageeditor: this.imgsarreditor, shapes: this.shapearreditor, text: this.txtarreditor, pretext: this.preloadedtxt }
            })
          );
        }
        else {
          console.log('inside else1');
          this.dispatchEvent(
            new CustomEvent("nextbtn", {
              detail: { data: datatofileuploadercmp, image: this.imageData }
            })
          );
        }

      }
    }





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

  // Toggle the 'selected' property when an image is clicked
  handleImageClick(event) {

    const fileIdToSelect = event.currentTarget.dataset.id;
    //  console.log('### delete file id', fileIdToSelect);

    for (let i = 0; i < this.imageData.length; i++) {
      const imgD = this.imageData[i].id;

      if (imgD == fileIdToSelect) {
        this.imageData[i].className = 'selected';
        //   console.log('imgD', imgD);
      } else {
        this.imageData[i].className = '';
      }
    }
  }

  handleDeleteClick(event) {
    //  console.log('event.target.dataset -- ', event.currentTarget.dataset);
    const fileIdToDelete = event.currentTarget.dataset.id;
    //  console.log('event.target.dataset -- ', fileIdToDelete);
    //this.uploadedFiles = this.uploadedFiles.filter(file => file.id !== fileIdToDelete);

    const newImgSet = [];
    for (let i = 0; i < this.imageData.length; i++) {
      const imgD = this.imageData[i].id;

      if (imgD != fileIdToDelete) {
        newImgSet.push(this.imageData[i]);
      }
    }
    this.imageData = newImgSet;
  }



}
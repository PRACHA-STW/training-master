import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import saveCanvas from '@salesforce/apex/FSM_sketchCls.saveCanvas';
import FSM_DCFLineItemInfraOBJECT from '@salesforce/schema/FSM_DCFLineItemInfra__c';
import DCFINFRA_OBJECT from '@salesforce/schema/FSM_DataCaptureFormInfra__c';
import DCFINFRA2_OBJECT from '@salesforce/schema/FSM_InfraDataCaptureForm2__c';
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import SAP_WorkOrderNumber from "@salesforce/schema/WorkStep.FSM_SAP_Order_Operation_Number__c";
import workstep from '@salesforce/schema/FSM_DataCaptureFormInfra__c.FSM_WorkStep__c';

export default class sketchEditor extends NavigationMixin(LightningElement) {
  // Component properties
  @api recordId;
  @api isEdit;
  @track dcfid;
  sapnumber;
  @api editorImage;

  iscreatepdfclicked = false;
  isdisable = false;
  @track isLoading = false;
  @api isboppsflow;
  @api istmaflow;
  @api isnormalflow;
  @api proformaImages;
  @api formtype;
  dcfinfralineitems;
  createdrecordid;
  dcfinfrarecordfromparent;
  @track images = [];
  @api baseImage;
  @api siteImage;
  @api sketchImage;
  @api tmasketchImage;
  @api sketchTextFields;
  @api photoImages;
  @api dcfrecorddata;
  retaincanvasonrefresh;
  //@api dcflineitemrecdata;
  @track texts = [];
  handleSize = 20;
  selectedIcons = [];
  // Canvas dimensions and tracking variables
  // @track canvasWidth = 400;
  // @track canvasHeight = 500;
  @track selectedImageIndex = -1;
  selectedPreloadedText = null;
  isOnload = true;
  @track isDrawing = false;
  drawStartX; //Added by Alagar
  drawStartY; //Added by Alagar
  drawEndX; //Added by Alagar
  drawEndY; //Added by Alagar
  resizeStartX;
  resizeStartY;
  @api deviceType;

  // @track dragOffsetX = 0;
  // @track dragOffsetY = 0;
  @track onImageEditor = false;
  @track selectedShapes;
  @track imageContext;

  @track selectedTextIndex = -1;
  @track selectedTextpos = -1
  @track isDraggingText = false;
  // @track isDraggingPreloadedText = false;

  @track isResizing = false;
  @track resizeHandleIndex = -1;

  // Other variables

  @track selectedShapeIndex = -1;
  @track selectedShape = '';
  @track isDragging = false;
  @track dragOffsetX = 0;
  @track dragOffsetY = 0;


  startPosX;
  startPosY;
  @track buttonClassLine = '';
  @track buttonClassCircle = '';
  @track buttonClassRectangle = '';
  @track buttonClassArrow = '';
  shapes = [];

  // Add these properties to keep track of initial size while resizing
  @track initialWidth = 0;
  @track initialHeight = 0;

  @track history = [];
  @track lastDrawnItem = '';
  drawnItems = [];
  // property to track the visibility of the text input

  isAddingText = false;
  isAddingIcons = false;
  selectedTextSize = '10px';
  // @track selectedShapeThickness = '2px';
  dcfinfrarecord;
  @track textValue = '';
  @track dragStartX = 0;
  @track dragStartY = 0;
  @track dragTextOffsetX;
  @track dragTextOffsetY;
  addcustdcfinfralineitemrectypeid;
  // dragOffsetX = 0;
  // dragOffsetY = 0;
  textPositionClass = 'text-input-container';
  textPosition = '';
  colorValue = '';
  canvasElement;
  isDraggingShape = false;
  dcfinfralineitemrectypeid;
  // Text drag variables
  // dragTextOffsetX;
  // dragTextOffsetY;
  // Variables for shape dragging
  draggingShape = false;
  draggedShapeIndex = -1;
  initialDragOffsetX = 0;
  initialDragOffsetY = 0;
  // @track isResizing = false;
  @track initialShapeDimensions = null;
  @track initialResizeHandlePosition = null;
  @track initialTextDimensions = null;

  @track isShapeDragged = false;

  preloadedText = [];
  text3;
  // isRendered property to track whether the template has rendered
  @track isRendered = false;
  @api textfromsketchmain;
  @api shapesfromsketchmain;
  @api imagesfromsketchmain;
  isokclicked = false;
  @api preloadedtextprev;
  text1;
  text2;
  customerlineitemstoinsert;
  // Executed after the component is rendered on the page
  @wire(getRecord, { recordId: '$recordId', fields: [workstep] })
  dcfinfradata({ error, data }) {
    if (error) {
      this.error = error;
    } else if (data) {

      if (data.fields.FSM_WorkStep__c.value != null) {
        // console.log('isEdit---->',this.isEdit)
        this.isEdit = true;

      } else {
        this.isEdit = false;
      }
    }
  }
  isTextNotRendered = true
  isLoadFirstTime = true;
  renderedCallback() {
    this.selectedIcons = [];
    if (this.isRendered || this.isokclicked || this.isAddingText) {
      return true;
    }

    if (!!JSON.stringify(this.textfromsketchmain)) {
      this.shapes = JSON.parse(JSON.stringify(this.shapesfromsketchmain));
      this.texts = JSON.parse(JSON.stringify(this.textfromsketchmain));
      this.images = JSON.parse(JSON.stringify(this.imagesfromsketchmain));
    }
    // Get the canvas element and its 2D context
    let canvas = this.template.querySelector('canvas');
    this.imageContext = canvas.getContext('2d');
    // canvas.width = this.canvasWidth;
    // canvas.height = this.canvasHeight;

    canvas.width = canvas.parentElement.offsetWidth;
    canvas.height = canvas.parentElement.offsetHeight;

    // Calculate canvas dimensions based on the smaller dimension of the parent container
    const canvasWidth = canvas.width;
    const canvasHeight = canvas.height;


    // Adjust the text position for mobile screens
    const textYPercentage = 0.98;
    const textY = canvasHeight * textYPercentage;

    // Draw base image
    const baseImageObj = new Image();
    baseImageObj.src = this.baseImage.data;
    baseImageObj.width = 360;
    baseImageObj.height = 400;
    baseImageObj.parent = this;

    baseImageObj.onload = function () {
      this.imageContext.drawImage(baseImageObj, 0, 0, canvas.width, canvas.height);

    };
    

    if (this.sketchTextFields) {
      this.text1 = this.sketchTextFields[0];
      this.text2 = this.sketchTextFields[1];
      this.text3 = this.sketchTextFields[2];
      //   console.log('text3',this.text3);
    }
    // if (this.preloadedtextprev) {
    if (Array.isArray(this.preloadedtextprev) && this.preloadedtextprev.length > 0) {
      this.isLoadFirstTime = false;
      this.preloadedText = JSON.parse(JSON.stringify(this.preloadedtextprev));
    } else {
      this.isLoadFirstTime = true;
      if (this.text1 && this.isTextNotRendered) {
        this.preloadedText = [];
        this.preloadedText.push({
          id: 'text1',
          x: 1,
          y: canvas.height - 25,
          width: 150,
          height: 15,
          text: this.text1,
          font: '12px Arial',
          textColor: 'black',
          backgroundColor: 'white',
          borderColor: 'red',

        });
      }

      if (this.text2 && this.isTextNotRendered) {
        this.preloadedText.push({
          id: 'text2',
          x: 50,
          y: 100,
          width: 200,
          height: 20,
          

          text: this.text2,
          textColor: 'black',
          backgroundColor: 'white',
          borderColor: 'red',

        });
      }

      if (this.text3 && this.isTextNotRendered) {
        this.preloadedText.push({
          id: 'text3',
          x: 50,
          y: 50,
          width: 200,
          height: 20,
          text: this.text3,
          textColor: 'black',
          backgroundColor: 'white',
          borderColor: 'red',

        });
      }
      this.isTextNotRendered = false;
    }


    // Add event listeners for mouse interaction
    canvas.addEventListener('mousedown', this.onMouseDown.bind(this));
    canvas.addEventListener('mouseup', this.onMouseUp.bind(this));
    canvas.addEventListener('mousemove', this.onMouseMove.bind(this));
    //events for mobile
    canvas.addEventListener('touchstart', (event) => {
      event.preventDefault();
      this.onMouseDown(event.touches[0]);
    });

    canvas.addEventListener('touchend', (event) => {
      event.preventDefault();
      this.onMouseUp(event.changedTouches[0]);
    });

    canvas.addEventListener('touchmove', (event) => {
      event.preventDefault();
      this.onMouseMove(event.touches[0]);
    });

    // Initialize the canvas with the base image and text

    if (Array.isArray(this.preloadedtextprev) && this.preloadedtextprev.length > 0) {
      this.redrawCanvas(this.images, this.shapes, this.texts);
    }
    else {
      this.redrawCanvas(this.images, this.shapes, this.preloadedText);
    }
  }


  adjustPreloadedTextSizes(addtextWord) {
    let textArr = addtextWord;
    let counter = 0;
    let padding = 5; //Added by Brajesh
    textArr.forEach((rect) => {
      // Set the background color to white
      this.imageContext.fillStyle = rect.backgroundColor;

      // Calculate the initial font size 
      const minFontSize = 16;  //Added by Brajesh  #Dhavi
      // const maxFontSize = 14;
      const maxFontSize = 40;
      // let fontSize = this.calculateFontSize(rect.text, rect.width, rect.height, minFontSize, maxFontSize);
      let fontSize = this.calculateFontSize(rect.text, rect.width - 2 * padding, rect.height - 2 * padding, minFontSize, maxFontSize); //Added by Brajesh
      // Update font size
      if (rect.font === null || rect.font === undefined || rect.font === '') { // added by Brajesh
        this.imageContext.font = `${fontSize}px Arial`;
      } else {
        this.imageContext.font = rect.font;
      }

      // Measure text height
      // const textHeight = this.measureWrappedText(rect.text, rect.width, fontSize, counter);
      const textHeight = this.measureWrappedText(rect.text, rect.width - 2 * padding, fontSize, counter);  //Added by Brajesh
      // Update box height based on text height
      // rect.height = textHeight;
      rect.height = textHeight + 2 * padding; //Added by Brajesh

      // Draw a white-filled rectangle
      this.imageContext.fillRect(rect.x, rect.y, rect.width, rect.height);

      this.imageContext.strokeStyle = rect.borderColor; // Set the border color
      this.imageContext.lineWidth = 2; // Set the border width
      this.imageContext.strokeRect(rect.x, rect.y, rect.width, rect.height);

      this.imageContext.fillStyle = rect.textColor;

      // Wrap text
      // this.wrapText(rect.text, rect.x, rect.y + fontSize, rect.width, fontSize);
      this.wrapText(rect.text, rect.x + padding, rect.y + padding + fontSize, rect.width - 2 * padding, fontSize); //Added by Brajesh
      counter++;
    });

    this.isOnload = false;
  }

  calculateFontSize(text, boxWidth, boxHeight, minFontSize, maxFontSize) {
    let fontSize = maxFontSize;
    this.imageContext.font = `${fontSize}px Arial`;
    let textHeight = this.measureWrappedText(text, boxWidth, fontSize, 0);

    // Decrease font size if the text doesn't fit
    while (textHeight > boxHeight && fontSize > minFontSize) {
      fontSize--;
      this.imageContext.font = `${fontSize}px Arial`;
      textHeight = this.measureWrappedText(text, boxWidth, fontSize, 0);
    }

    // Increase font size if there is extra space, up to a maximum font size
    while (textHeight < boxHeight && fontSize < maxFontSize) {
      fontSize++;
      this.imageContext.font = `${fontSize}px Arial`;
      textHeight = this.measureWrappedText(text, boxWidth, fontSize, 0);
    }

    // Return the final font size that fits within the box
    return fontSize;
  }

  ensureTextWithinBounds(text) {
    const context = this.template.querySelector('canvas').getContext('2d');
    context.font = `normal ${text.fontSize} Arial`;
    const textWidth = context.measureText(text.text).width;
    const textHeight = this.measureWrappedText(text.text, text.width, parseInt(text.fontSize, 10), 0);

    console.log('Text width:', textWidth, 'Text height:', textHeight);

    if (textWidth > text.width) {
      // Adjust text width if it exceeds the box width
      text.width = textWidth;
      console.log('Adjusted width:', text.width);
    }

    if (textHeight > text.height) {
      // Adjust text height if it exceeds the box height
      text.height = textHeight;
      console.log('Adjusted height:', text.height);
    }
  }

  measureWrappedText(text, maxWidth, lineHeight) {
    const words = text.split(' ');
    let line = '';
    let textHeight = 0;

    for (let n = 0; n < words.length; n++) {
      const testLine = line + words[n] + ' ';
      const metrics = this.imageContext.measureText(testLine);
      const testWidth = metrics.width;

      if (testWidth > maxWidth && n > 0) {
        line = words[n] + ' ';
        textHeight += lineHeight;
      } else {
        line = testLine;
      }
    }

    textHeight += lineHeight; // Account for the last line
    // console.log(`Final Text Height: ${textHeight}`);

    return textHeight;
  }


  wrapText(text, x, y, maxWidth, lineHeight) {
    const words = text.split(' ');
    let line = '';

    for (let n = 0; n < words.length; n++) {
      const testLine = line + words[n] + ' ';
      const metrics = this.imageContext.measureText(testLine);
      const testWidth = metrics.width;

      if (testWidth > maxWidth && n > 0) {
        this.imageContext.fillText(line, x, y);
        line = words[n] + ' ';
        y += lineHeight;
      } else {
        line = testLine;
      }
    }

    this.imageContext.fillText(line, x, y);
  }

  //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
  @track isModalOpen = false;
  openModal() {
    // to open modal set isModalOpen tarck value as true
    this.isModalOpen = true;
  }
  closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.isModalOpen = false;

  }

  drawRectangle() {
    this.selectedShapes = 'Rectangle';
  }

  drawLine() {
    this.selectedShapes = 'Line';
  }

  drawCircle() {
    this.selectedShapes = 'Circle';
  }

  drawArrow() {
    this.selectedShapes = 'Arrow';
  }
  shapeOptions = [
    { label: '--Select shape--', value: '' },
    { label: 'Line', value: 'Line' },
    { label: 'Rectangle', value: 'Rectangle' },
    { label: 'Arrow', value: 'Arrow' }
  ];
  // Add an attribute to store the available text size options
  textSizeOptions = [
    { label: '8', value: '8px' },
    { label: '10', value: '10px' },
    { label: '12', value: '12px' },
    { label: '14', value: '14px' },
    { label: '16', value: '16px' },
    { label: '18', value: '18px' },
    { label: '20', value: '20px' },
    { label: '22', value: '22px' },
    { label: '24', value: '24px' },
    { label: '26', value: '26px' },
    { label: '28', value: '28px' },
    { label: '30', value: '30px' },
    { label: '32', value: '32px' }
  ];

  // Handler for the text size selection change
  handleTextSizeChange(event) {
    this.selectedTextSize = event.detail.value;
  }
  @track shapeThicknessOptions = [
    { label: 'Thin', value: '2px' },
    { label: 'Thick', value: '5px' }
  ];
  handleShapeThicknessChange(event) {
    this.selectedShapeThickness = event.detail.value;
  }
  connectedCallback() {
    //  console.log('form type',this.formtype);
    this.drawShape();
    this.shapes = [];
    this.selectedShapes = '';
  }
  handleShapeChange(event) {
    this.selectedShape = event.detail.value;
    this.selectedShapeIndex = -1;
    this.isDrawing = false;
    if (this.selectedShape) {
      this.selectedHandle = null;
      this.redrawCanvas(this.images, this.shapes, this.texts);
    }
  }

  resetSelectedShape() {
    this.selectedShape = '';
    this.selectedShapes = '';
  }

  drawShape() {
    if (this.selectedShape === 'Line') {
      this.drawLine();
    } else if (this.selectedShape === 'Circle') {
      this.drawCircle();
    } else if (this.selectedShape === 'Rectangle') {
      this.drawRectangle();
    } else if (this.selectedShape === 'Arrow') {
      this.drawArrow();
    }
    // Reset the selected shape to null
    this.selectedShape = '';
    setTimeout(() => {
      this.selectedShape = '';
    }, 100);
  }

  // Event handler for mouse down event
  onMouseDown(event) {
    console.log('mouse --> down');
    const canvas = this.template.querySelector('canvas');
    const canvasRect = canvas.getBoundingClientRect();//std func
    const isTouchEvent = event.type === 'touchstart';
    const touch = isTouchEvent ? event.touches[0] : null;
    const startX = isTouchEvent ? ((touch.clientX - canvasRect.left) / (canvasRect.right - canvasRect.left)) * canvas.width : event.clientX - canvasRect.left;
    const startY = isTouchEvent ? ((touch.clientY - canvasRect.top) / (canvasRect.bottom - canvasRect.top)) * canvas.height : event.clientY - canvasRect.top;
    //console.log('startX 365:', startX, startY);
    if (isTouchEvent && event.preventDefault) {
      event.preventDefault();
    }

    this.startPosX = startX;
    this.startPosY = startY;
    this.isDragging = false;
    this.selectedTextpos = -1;
    this.selectedImageIndex = -1;

    //this.isDrawing = true; - Alagar commented
    // if (this.texts) {
    //   console.log('Clicked on text:', this.selectedTextIndex);
    //   this.selectedTextpos = this.texts.findIndex((rect) => {
    //     return (
    //       startX >= rect.x &&
    //       startX <= rect.x + rect.width &&
    //       startY >= rect.y &&
    //       startY <= rect.y + rect.height
    //     );
    //   });

    //   this.selectedTextIndex = this.texts.find((rect) => {
    //     return (
    //       startX >= rect.x &&
    //       startX <= rect.x + rect.width &&
    //       startY >= rect.y &&
    //       startY <= rect.y + rect.height
    //     );
    //   });

    //   //console.log('Clicked on text524:', this.selectedTextIndex);
    //   if (this.selectedTextIndex) {
    //     this.isDraggingText = true;
    //     this.dragOffsetX = this.selectedTextIndex.x - startX;
    //     this.dragOffsetY = this.selectedTextIndex.y - startY;
    //   }
    // }
    if (this.texts) {
      // console.log('Clicked on texts box:', this.selectedTextIndex);
      this.selectedTextIndex = this.texts.findIndex((text, index) => {
        // Skip the first text item (text1)
        // if (index === 0) return false;

        // Identify if mouse position is on text
        const isInText = (
          startX >= text.x &&
          startX <= text.x + text.width &&
          startY >= text.y &&
          startY <= text.y + text.height
        );

        // Identify if mouse position is on text handles
        const textX = text.x;
        const textY = text.y;
        const textWidth = text.width;
        const textHeight = text.height;

        const handles = [
          { x: textX, y: textY }, // Top-left handle
          { x: textX + textWidth, y: textY }, // Top-right handle
          { x: textX, y: textY + textHeight }, // Bottom-left handle
          { x: textX + textWidth, y: textY + textHeight } // Bottom-right handle
        ];

        let isOnHandle = false;
        const handleSize = 20; // Adjust handle size as needed

        for (let i = 0; i < handles.length; i++) {
          const handle = handles[i];
          //  console.log(`Checking handle ${i}:`, handle);
          if (
            startX >= handle.x - handleSize / 2 &&
            startX <= handle.x + handleSize / 2 &&
            startY >= handle.y - handleSize / 2 &&
            startY <= handle.y + handleSize / 2
          ) {
            this.resizeHandleTextIndex = i;
            isOnHandle = true;
            //  console.log('Click is on text handle:', i);
            break;
          }
        }

        // Return true if mouse is in text or on handle
        return isInText || isOnHandle;
      });

      console.log('Clicked on text:628--> ', this.selectedTextIndex);

      // If clicked on text, set dragging state and calculate drag offsets
      if (this.selectedTextIndex >= 0 && this.selectedTextIndex < this.texts.length) {
        const selectedText = this.texts[this.selectedTextIndex];
        // console.log('Clicked on text handle:', this.resizeHandleTextIndex);

        if (this.resizeHandleTextIndex !== null && this.resizeHandleTextIndex !== undefined) {
          // console.log('resizeHandleTextIndex 605:', this.resizeHandleTextIndex);
          // Start resizing text
          this.isResizing = true;
          this.initialTextDimensions = { width: selectedText.width, height: selectedText.height };
          this.initialResizeHandleTextPosition = { x: startX, y: startY };
        } else {
          // Start dragging text
          this.isDraggingText = true;
          this.dragOffsetX = startX - selectedText.x;
          this.dragOffsetY = startY - selectedText.y;
        }
      }
    }

    // Handle preloaded text selection and dragging
    if (this.preloadedText) {
      this.selectedPreloadedTextIndex = this.preloadedText.findIndex((text, index) => {
        if (index === 0) return false;
        const isInText = (
          startX >= text.x &&
          startX <= text.x + text.width &&
          startY >= text.y &&
          startY <= text.y + text.height
        );

        const handles = [
          { x: text.x, y: text.y },
          { x: text.x + text.width, y: text.y },
          { x: text.x, y: text.y + text.height },
          { x: text.x + text.width, y: text.y + text.height }
        ];

        let isOnHandle = false;
        const handleSize = 20;

        for (let i = 0; i < handles.length; i++) {
          const handle = handles[i];
          if (
            startX >= handle.x - handleSize / 2 &&
            startX <= handle.x + handleSize / 2 &&
            startY >= handle.y - handleSize / 2 &&
            startY <= handle.y + handleSize / 2
          ) {
            this.resizeHandlePreloadedTextIndex = i;
            isOnHandle = true;
            break;
          }
        }

        return isInText || isOnHandle;
      });

      if (this.selectedPreloadedTextIndex >= 0 && this.selectedPreloadedTextIndex < this.preloadedText.length) {
        const selectedPreloadedText = this.preloadedText[this.selectedPreloadedTextIndex];
        if (this.resizeHandlePreloadedTextIndex !== null && this.resizeHandlePreloadedTextIndex !== undefined) {
          this.isResizing = true;
          this.initialPreloadedTextDimensions = { width: selectedPreloadedText.width, height: selectedPreloadedText.height };
          this.initialResizeHandlePreloadedTextPosition = { x: startX, y: startY };
        } else {
          this.isDraggingText = true;
          this.dragOffsetX = startX - selectedPreloadedText.x;
          this.dragOffsetY = startY - selectedPreloadedText.y;
        }
      }
    }

    // End - Check if the mouse click is inside any of the preloadedtext

    //console.log('selectedPreloadedText --> ', this.selectedPreloadedText);
    if (this.images) {
      //console.log('Clicked on images:', this.selectedImageIndex);
      this.selectedImageIndex = this.images.findIndex((image) => {
        // console.log('image.width:', image.width);
        // console.log('image.height:', image.height);
        // console.log('startX,Y: ', startX, '-', startY);
        // console.log('image.pos:', image.posX, '-', image.posY);
        // Identify if mouse position is on image
        const isInImage = (
          startX >= image.posX &&
          startX <= image.posX + image.width &&
          startY >= image.posY &&
          startY <= image.posY + image.height
        );
        // Identify if mouse position is on image handles
        const imageX = image.posX;
        const imageY = image.posY;
        const imageWidth = image.width;
        const imageHeight = image.height;
        const handles = [
          { x: imageX, y: imageY }, // Top-left handle
          { x: imageX + imageWidth, y: imageY }, // Top-right handle
          { x: imageX, y: imageY + imageHeight }, // Bottom-left handle
          { x: imageX + imageWidth, y: imageY + imageHeight } // Bottom-right handle
        ];
        let isOnHandle = false;
        const handleSize = 20;
        for (let i = 0; i < handles.length; i++) {
          const handle = handles[i];
          // console.log(`Checking handle ${i}:`, handle);
          if (
            startX >= handle.x - handleSize / 2 &&
            startX <= handle.x + handleSize / 2 &&
            startY >= handle.y - handleSize / 2 &&
            startY <= handle.y + handleSize / 2
          ) {
            this.resizeHandleIndex = i;
            isOnHandle = true;
            console.log('Click is on handle:', i);
            break;
          }
        }

        // Return true if mouse is in image or on handle
        return isInImage || isOnHandle;

      });
      // console.log('Clicked on images618:', this.selectedImageIndex);
      //if clicked on image    If an image is selected, set dragging state and calculate drag offsets
      if (this.selectedImageIndex >= 0 && this.selectedImageIndex < this.images.length) {
        const selectedImage = this.images[this.selectedImageIndex];
        this.resizeHandleIndex = this.getResizeHandleImageIndex(startX, startY, selectedImage);
        //  console.log('Clicked on image handle 584:', this.resizeHandleIndex);
        if (this.resizeHandleIndex !== null) {
          this.isResizing = true;
          this.initialImageDimensions = { width: selectedImage.width, height: selectedImage.height };
          this.initialResizeHandlePosition = { x: startX, y: startY };
          //  console.log('Clicked on image handle:', this.resizeHandleIndex);
        } else {
          this.isDragging = true;
          this.dragOffsetX = startX - selectedImage.posX;
          this.dragOffsetY = startY - selectedImage.posY;
        }
      }

    }

    // Check if the mouse down event occurred on a shape
    const shapesFound = false;
    const shapeCounter = -1;
    //console.log('this.shapes::: ', this.shapes);
    this.selectedShapeIndex = this.shapes.findIndex((shape) => {

      const shapeType = shape.type;
      let isInLine = false;
      let isInLineHandle = false;
      if (shapeType === 'Line' || shapeType === 'Arrow') {
        //check if mouse position is on line -- Brajesh
        const line = { x1: shape.startX, y1: shape.startY, x2: shape.endX, y2: shape.endY };
        const pos = { x: startX, y: startY };
        // if (this.isPointOnLine(startX, startY, shape.startX, shape.startY, shape.endX, shape.endY)) {
        if (this.isPointOnLine(line, pos)) {
          //this.selectedShape = shapeType;
          isInLine = true;
          isInLineHandle = false;
        }

        //check if mouse position is on handle
        if (this.isPointOnHandle(startX, startY, shape.startX, shape.startY) ||
          this.isPointOnHandle(startX, startY, shape.endX, shape.endY)) {

          isInLineHandle = true;
          isInLine = false;
        }

        if (isInLine || isInLineHandle) {
          return true;
        }

      } else {

        //identify if mouse position is on rectangle @commenting old formula 
        // const isInRect = (startX >= shape.startX &&
        //   startX <= shape.startX + (shape.endX - shape.startX) &&
        //   startY >= shape.startY &&
        //   startY <= shape.startY + (shape.endY - shape.startY));

         // Normalize the flipped rectangle coordinates
         const normalizedStartX = Math.min(shape.startX, shape.endX);
         const normalizedEndX = Math.max(shape.startX, shape.endX);
         const normalizedStartY = Math.min(shape.startY, shape.endY);
         const normalizedEndY = Math.max(shape.startY, shape.endY);
 
         // Check if the point (startX, startY) is inside the normalized rectangle
         const isInRect = (
           startX >= normalizedStartX &&
           startX <= normalizedEndX &&
           startY >= normalizedStartY &&
           startY <= normalizedEndY
         );

        // console.log('Is mouse in rectangle:', isInRect);
        //identify if mouse position is on rectangle handles
        const shapeX = shape.startX;
        const shapeY = shape.startY;
        const shapeWidth = shape.endX - shape.startX;
        const shapeHeight = shape.endY - shape.startY;

        const handles = [
          { shapeX, shapeY }, // Top-left handle
          { shapeX: shapeX + shapeWidth, shapeY }, // Top-right handle
          { shapeX, shapeY: shapeY + shapeHeight }, // Bottom-left handle
          { shapeX: shapeX + shapeWidth, shapeY: shapeY + shapeHeight } // Bottom-right handle
        ];

        let isOnHandle = false;
        for (let i = 0; i < handles.length; i++) {
          //console.log('onmousemove handles -', handles[i]);
          const handle = handles[i];
          // const hSize = 25; // Handle size must match the size used in drawHandle function
          let hSize =25;
          // if (this.deviceType = 'Desktop') {
          //   hSize = 25;
          // } else {
          //   hSize = 30;
          // }

          // console.log(`Mouse position: (${startX}, ${startY}), Handle position: (${handle.shapeX}, ${handle.shapeY})`);
          if (
            startX >= handle.shapeX - hSize / 2 &&
            startX <= handle.shapeX + hSize / 2 &&
            startY >= handle.shapeY - hSize / 2 &&
            startY <= handle.shapeY + hSize / 2
          ) {
            // Handle clicked, identify the position
            //this.selectedHandle = i;
            //   console.log(`onmousemove Handle ${i + 1} clicked`);
            isOnHandle = true;
            break;
          }
        }
        //   console.log('After handle loop. isOnHandle:', isOnHandle);
        if (isInRect || isOnHandle) {
          return true;
        }

      }

    });

    //console.log('this.selectedShapeIndex ... ', this.selectedShapeIndex); 

    if (this.selectedShapeIndex !== -1) {

      this.resizeHandleIndex = this.getResizeHandleIndex(startX, startY, this.shapes[this.selectedShapeIndex]);
      // console.log('this.resizeHandleIndex ... ', this.resizeHandleIndex);
      // console.log('this.selectedShape ... ', this.selectedShape);

      if (this.resizeHandleIndex !== null) {
        this.isResizing = true;
      }

      if (this.isResizing) {

        // console.log('Resizing... ');
        this.resizeStartX = startX;
        this.resizeStartY = startY;
        this.selectedHandle = this.resizeHandleIndex;
        // console.log('this.selectedHandle...');

        // The initial dimensions for resizing
        this.initialShapeDimensions = { ...this.shapes[this.selectedShapeIndex] };

        // Initialize initialResizeHandlePosition here
        this.initialResizeHandlePosition = { x: startX, y: startY };
      } else {

        // console.log('shape drag onmousedown... ');
        this.draggingShape = true;

        const draggedShape = this.shapes[this.selectedShapeIndex];
        this.draggedShapeIndex = this.selectedShapeIndex;
        this.initialDragOffsetX = startX - draggedShape.startX;
        this.initialDragOffsetY = startY - draggedShape.startY;
      }
    } else {
      // Clicked outside of any shape, so deselect the current selection
      this.selectedShapeIndex = -1;
      // this.isResizing = false;
      // this.isDragging = false;
      // this.draggingShape = false;
      // this.selectedHandle = null;
    }

    //Added by Alagar
    if (this.selectedShape) {
      this.isDrawing = true;
      // console.log(' isDrawing down-- ');
      //  console.log('this.selectedShapes -- ', this.selectedShape);
      this.drawStartX = startX
      this.drawStartY = startY;
    } else {
      this.isDrawing = false;
      // console.log(' No drawing... ');
    }
    //this.redrawCanvas(this.images, this.shapes, this.texts);
    //console.log('redraw -->', this.selectedTextpos);
    // console.log('redraw -->', this.selectedImageIndex);
    if (this.selectedTextpos !== -1 || this.selectedImageIndex !== -1) {
      //console.log('redraw  1 -->');
      this.redrawCanvas(this.images, this.shapes, this.texts);
    } else if (this.selectedImageIndex == -1 && this.selectedShapeIndex == -1 && this.selectedTextpos == -1 && this.isDrawing == false) {
      //  console.log('redraw  2 -->');
      this.selectedHandle = null;
      this.redrawCanvas(this.images, this.shapes, this.texts);
    }//added by venkata
  }
  isPointInRectangle(x, y, x1, y1, x2, y2) {
    return x >= Math.min(x1, x2) && x <= Math.max(x1, x2) && y >= Math.min(y1, y2) && y <= Math.max(y1, y2);
  }

  isPointInBounds(x, y, x1, y1, x2, y2) {
    return x >= x1 && x <= x2 - x1 && y >= y1 && y <= y2 - y1;
  }

  // isPointOnLine(x, y, x1, y1, x2, y2, tolerance = 0) {
  //   //const threshold = 10;
  //     return (
  //         x >= Math.min(x1, x2) - tolerance &&
  //         x <= Math.max(x1, x2) + tolerance &&
  //         y >= Math.min(y1, y2) - tolerance &&
  //         y <= Math.max(y1, y2) + tolerance
  //     );
  // }
  // isPointOnLine(x, y, x1, y1, x2, y2, tolerance = 10) {
  //   // Check if the point is exactly on the line
  //   const dist = Math.abs((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1) / Math.sqrt(Math.pow(y2 - y1, 2) + Math.pow(x2 - x1, 2));
  //   return dist <= tolerance;
  // }
  // Anchoring point issue -  Brajesh
  // isPointOnLine( line, pos, boundsTolerance = 4) {
  isPointOnLine(line, pos, boundsTolerance = 10) {
    const { x1, y1, x2, y2 } = line;
    const { x, y } = pos;
    // Calculate the perpendicular distance from the point to the infinite line
    const distance = Math.abs((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1) /
      Math.sqrt((y2 - y1) ** 2 + (x2 - x1) ** 2);

    // Check if the point is close enough to the line (within 5px tolerance)
    if (distance > 5) {
      return false;
    }

    // Bounds check with tolerance
    const withinXBounds = (x >= Math.min(x1, x2) - boundsTolerance && x <= Math.max(x1, x2) + boundsTolerance);
    const withinYBounds = (y >= Math.min(y1, y2) - boundsTolerance && y <= Math.max(y1, y2) + boundsTolerance);

    return withinXBounds && withinYBounds;
  }


  drawAllTexts(canvas, imageContext) {
    // Clear the canvas-
    // imageContext.clearRect(0, 0, canvas.width, canvas.height);

    // Redraw the shapes
    this.shapes.forEach((shape) => {
      imageContext.strokeStyle = shape.color;
      imageContext.beginPath();
      if (shape.type === 'Rectangle') {
        imageContext.rect(shape.startX, shape.startY, shape.endX - shape.startX, shape.endY - shape.startY);
      } else if (shape.type === 'Line') {
        imageContext.moveTo(shape.startX, shape.startY);
        imageContext.lineTo(shape.endX, shape.endY);
      } else if (shape.type === 'Circle') {
        const radius = Math.sqrt(Math.pow(shape.endX - shape.startX, 2) + Math.pow(shape.endY - shape.startY, 2));
        imageContext.arc(shape.startX, shape.startY, radius, 0, 2 * Math.PI);
      } else if (shape.type === 'Arrow') {
        // Draw arrow shape (implement this function)
        this.drawArrowShape(imageContext, shape.startX, shape.startY, shape.endX, shape.endY);
      }
      imageContext.stroke();
    });
    // Redraw the texts
    this.texts.forEach(text => {
      imageContext.font = text.fontSize + " Arial";
      imageContext.fillStyle = text.color;
      imageContext.fillText(text.content, text.x, text.y);
    });

  }


  // Event handler for mouse move event
  onMouseMove(event) {

    // console.log('mouse --> move');
    const canvas = this.template.querySelector('canvas');
    const canvasRect = canvas.getBoundingClientRect();
    const isTouchEvent = event.type === 'touchmove';
    const touch = isTouchEvent ? event.touches[0] : null;
    const currentX = isTouchEvent ? ((touch.clientX - canvasRect.left) / (canvasRect.right - canvasRect.left)) * canvas.width : event.clientX - canvasRect.left;
    const currentY = isTouchEvent ? ((touch.clientY - canvasRect.top) / (canvasRect.bottom - canvasRect.top)) * canvas.height : event.clientY - canvasRect.top;

    // console.log('isResizingText : 905 ', this.isResizingText);
    // console.log('selectedTextIndex : 906 ', this.selectedTextIndex);
    // console.log('isDraggingText : 907 ', this.isDraggingText);
    if (this.isDragging && this.selectedImageIndex >= 0 && this.selectedImageIndex < this.images.length) {
      // console.log('dragging image --> image');
      const selectedImage = this.images[this.selectedImageIndex];
      selectedImage.posX = currentX - this.dragOffsetX;
      selectedImage.posY = currentY - this.dragOffsetY;
    } else if (this.isDraggingText && this.selectedTextIndex !== -1) {
      const selectedText = this.texts[this.selectedTextIndex];
      selectedText.x = currentX - this.dragOffsetX;
      selectedText.y = currentY - this.dragOffsetY;
    } else if (this.isDragging && this.selectedPreloadedTextIndex !== -1) {
      const selectedPreloadedText = this.preloadedText[this.selectedPreloadedTextIndex];
      selectedPreloadedText.x = currentX - this.dragOffsetX;
      selectedPreloadedText.y = currentY - this.dragOffsetY;
    } else if (this.isResizing && this.selectedPreloadedTextIndex !== -1) {
      this.resizePreloadedText(currentX, currentY);
    } else if (this.isResizing) {
      //console.log('resize on mouse move..');
      // Handle the resizing operation
      const shape = this.shapes[this.selectedShapeIndex];
      const handle = this.resizeHandleIndex;
      const initialPosition = this.initialResizeHandlePosition;
      this.selectedShape = this.shapes[this.selectedShapeIndex];
      //this.selectedHandle = 'top-right';
      //this.selectedHandle = 'end';
      if (this.selectedShapeIndex >= 0) {
        this.resizeSelectedShape(currentX, currentY);
      }
      if (this.selectedImageIndex >= 0) {
        this.resizeSelectedImage(currentX, currentY);
      }
      if (this.selectedTextIndex >= 0) {
        this.resizeSelectedText(currentX, currentY);
      }
      if (this.selectedPreloadedTextIndex >= 0) {
        this.resizePreloadedText(currentX, currentY);
      }
    } else if (this.draggingShape && this.draggedShapeIndex >= 0 && this.draggedShapeIndex < this.shapes.length) {
      // console.log('dragging draggingShape --> draggingShape', this.draggedShapeIndex);
      const draggedShape = this.shapes[this.draggedShapeIndex];
      const deltaX = currentX - this.initialDragOffsetX - draggedShape.startX;
      const deltaY = currentY - this.initialDragOffsetY - draggedShape.startY;
      //  console.log('1111.....', deltaX, ',',deltaX,',',draggedShape.startX);
      draggedShape.startX += deltaX;
      // console.log('22222.....');
      draggedShape.endX += deltaX;
      draggedShape.startY += deltaY;
      draggedShape.endY += deltaY;
    } else if (this.isDrawing) {
      this.isDrawingOnMove = true
      this.drawEndX = currentX;
      this.drawEndY = currentY;
    }

    if (this.isDrawing || this.isDragging || this.draggingShape || this.isDraggingText || this.isResizing) {
      //console.log('redrawCanvas onmove');
      this.redrawCanvas(this.images, this.shapes, this.texts);
    }
  }

  // Event handler for mouse up event
  onMouseUp(event) {
    // console.log('mouse --> up');
    const canvas = this.template.querySelector('canvas');
    const context = canvas.getContext('2d');
    const isTouchEvent = event.type === 'touchend';
    const touch = isTouchEvent ? event.changedTouches[0] : null;
    const canvasRect = canvas.getBoundingClientRect();

    const endX = isTouchEvent ? ((touch.clientX - canvasRect.left) / (canvasRect.right - canvasRect.left)) * canvas.width : event.clientX - canvasRect.left;
    const endY = isTouchEvent ? ((touch.clientY - canvasRect.top) / (canvasRect.bottom - canvasRect.top)) * canvas.height : event.clientY - canvasRect.top;

    // console.log('startPosX -->', this.startPosX);
    // console.log('startPosY -->', this.startPosY);
    // console.log('endX -->', endX);
    // console.log('endY -->', endY);
    //console.log('Selected Shape Thickness:', this.selectedShapeThickness);
    if (this.isDragging && this.selectedImageIndex >= 0 && this.selectedImageIndex < this.images.length) {
      const selectedImage = this.images[this.selectedImageIndex];
      selectedImage.endX = endX;
      selectedImage.endY = endY;
      this.redrawCanvas(this.images, this.shapes, this.texts);
    } else if (this.isDrawing && this.isDrawingOnMove) {
      // Store the shape in the shapes array
      const shapeThicknessValue = this.selectedShapeThickness;
      const shapeThickness = parseInt(shapeThicknessValue, 10) || 2;

      //console.log('this.selectedShape:', this.selectedShape);
      const shapeList = ["Line", "Rectangle", "Arrow"];
      if (shapeList.includes(this.selectedShape)) {

        // swap the XY if the shape is drawn down to up
        if (
          (this.selectedShape == 'Rectangle' && this.drawStartX > this.drawEndX) ||
          (this.selectedShape == 'Rectangle' && this.drawStartY > this.drawEndY)
        ) {
          //  console.log('SWAP --');
          const statX = this.drawStartX;
          const statY = this.drawStartY;
          const edX = this.drawEndX;
          const edY = this.drawEndY;

          this.drawStartX = Math.min(edX, statX);
          this.drawStartY = Math.min(edY, statY);
          this.drawEndX = Math.max(edX, statX);
          this.drawEndY = Math.max(edY, statY);
        }
        this.shapes.push({
          type: this.selectedShape,
          startX: this.drawStartX,
          startY: this.drawStartY,
          endX: this.drawEndX,
          endY: this.drawEndY,
          color: this.shapeColor,
          thickness: shapeThickness
        });
        this.drawnItems.push('Shape');
      }

      if (this.selectedShape) {
        this.lastDrawnItem = 'Shape';
        // console.log('lastDrawnItem for shape:', this.lastDrawnItem);
        this.selectedShape = '';
        let comboboxes = this.template.querySelectorAll("[data-id='shapePicklist']");
        comboboxes.forEach(combobox => {
          combobox.value = this.selectedShape;
        });

        // Reset the selected shape thickness as well
        this.selectedShapeThickness = null;
        let thicknessComboboxes = this.template.querySelectorAll("[data-id='shapeThickness']");
        thicknessComboboxes.forEach(thicknessCombobox => {
          thicknessCombobox.value = this.selectedShapeThickness;
        });
      }

    }
    // Reset various flags and indices
    this.isDragging = false;
    // this.selectedImageIndex = -1;
    this.isDraggingText = false;
    // this.selectedTextIndex = -1;
    //this.selectedTextpos = -1;
    // this.isDraggingPreloadedText = false;
    this.selectedPreloadedTextIndex = -1;

    if ((this.draggingShape && this.draggedShapeIndex !== -1) || (this.isDrawing && this.isDrawingOnMove)) {
      //console.log('redrawCanvas mouse up');
      this.draggingShape = false;
      this.draggedShapeIndex = -1;
      this.redrawCanvas(this.images, this.shapes, this.texts);
      this.isDrawing = false;
      this.isDrawingOnMove = false;
      return;
    }

    //this.isResizing = false;
    this.draggingShape = false;
    this.draggedShapeIndex = -1;
    this.isDrawing = false;
    this.isDrawingOnMove = false;
    this.selectedRectangle = null;
    this.isResizing = false;
    this.resizeHandleTextIndex = null;
    //console.log('Mouse up:', { isDragging: this.isDragging, isResizing: this.isResizing });
    //Added by Alagar
  }

  getSelectedShape(x, y) {

    for (let i = 0; i < this.shapes.length; i++) {

      const shape = this.shapes[i];
      if (shape.type === 'line' || shape.type === 'arrow') {
        if (this.isPointOnHandle(x, y, shape.x1, shape.y1) || this.isPointOnHandle(x, y, shape.x2, shape.y2)) {
          return shape;
        }
      } else if (shape.type === 'rectangle') {
        if (
          x >= shape.x &&
          x <= shape.x + shape.width &&
          y >= shape.y &&
          y <= shape.y + shape.height
        ) {
          return shape;
        }
      }
    }
    return null;
  }

  // isPointOnHandle(x, y, handleX, handleY) {
  //   return (
  //     x >= handleX - 25 &&
  //     x <= handleX + 25 &&
  //     y >= handleY - 25 &&
  //     y <= handleY + 25
  // );
  // }
  isPointOnHandle(x, y, handleX, handleY, handleType) {
    // const handleSize = handleType === 'shape' ? 25 : 10;
    const handleSize = 35;
    return (
      x >= handleX - handleSize / 2 &&
      x <= handleX + handleSize / 2 &&
      y >= handleY - handleSize / 2 &&
      y <= handleY + handleSize / 2
    );
  }
  getResizeHandleIndex(x, y, shape) {

    if (shape.type === 'Line' || shape.type === 'Arrow') {
      //  console.log('line or Arrow handle --> :', shape.type);

      if (this.isPointOnHandle(x, y, shape.startX, shape.startY)) {
        // console.log('Handle selected: start');
        return 'start';
      } else if (this.isPointOnHandle(x, y, shape.endX, shape.endY)) {
        // console.log('Handle selected: end');
        return 'end';
      }
    } else if (shape.type === 'Rectangle') {
      const clickX = x;
      const clickY = y;
      // console.log('clickX, y -', clickX, ',', clickY);
      const shapeX = shape.startX;
      const shapeY = shape.startY;
      const shapeWidth = shape.endX - shape.startX;
      const shapeHeight = shape.endY - shape.startY;

      const handles = [
        { shapeX, shapeY }, // Top-left handle
        { shapeX: shapeX + shapeWidth, shapeY }, // Top-right handle
        { shapeX, shapeY: shapeY + shapeHeight }, // Bottom-left handle
        { shapeX: shapeX + shapeWidth, shapeY: shapeY + shapeHeight } // Bottom-right handle
      ];

      const handlePosition = [
        'top-left', // Top-left handle
        'top-right', // Top-right handle
        'bottom-left', // Bottom-left handle
        'bottom-right' // Bottom-right handle
      ];

      for (let i = 0; i < handles.length; i++) {
        console.log('handles -', handles[i]);
        const handle = handles[i];
        const hSize = 25; // Handle size must match the size used in drawHandle function
        if (
          clickX >= handle.shapeX - hSize / 2 &&
          clickX <= handle.shapeX + hSize / 2 &&
          clickY >= handle.shapeY - hSize / 2 &&
          clickY <= handle.shapeY + hSize / 2
        ) {
          // Handle clicked, identify the position
          //this.selectedHandle = i;
          //  console.log(`Handle ${i + 1} clicked`);
          return handlePosition[i];
        }
      }

    }
    return null;
  }

  isWithinRectThreshold(x, y, rthreshold) {
    return Math.abs(x - y) <= rthreshold;
  }

  resizeSelectedShape(startX, startY) {
    console.log('Before Resize:', this.selectedShape);
    // console.log('selectedShape:714' , this.selectedShape, this.selectedHandle);
    if (this.selectedShape && this.selectedHandle) {
      // console.log('718:', this.selectedShape, this.selectedHandle);
      const dx = startX - this.resizeStartX;
      const dy = startY - this.resizeStartY;
      const resizeFunction = () => {
        if (this.selectedShape.type === 'Line' || this.selectedShape.type === 'Arrow') {
          //   console.log('722:', this.selectedShape, this.selectedHandle);
          if (this.selectedHandle === 'start') {
            //  console.log('Dx:720', dx, dy);
            this.selectedShape.startX += dx;
            this.selectedShape.startY += dy;
            //  console.log('selectedShape:723', this.selectedShape);
          } else if (this.selectedHandle === 'end') {
            // console.log('899:', dx, ',', dy);
            this.selectedShape.endX += dx;
            this.selectedShape.endY += dy;
            //  console.log('903:', this.selectedShape.x2, ',', this.selectedShape.y2);

          }
        } else if (this.selectedShape.type === 'Rectangle') {
          // console.log('Before Rectangle Resize:');
          // console.log('startX:', this.selectedShape.startX);
          // console.log('startY:', this.selectedShape.startY);
          // console.log('endX:', this.selectedShape.endX);
          // console.log('endY:', this.selectedShape.endY);
          if (this.selectedHandle === 'top-left') {
            this.selectedShape.startX += dx;
            this.selectedShape.startY += dy;
            // this.selectedShape.endX -= dx;
            // this.selectedShape.endY -= dy;
          } else if (this.selectedHandle === 'top-right') {
            this.selectedShape.endX += dx;
            this.selectedShape.startY += dy;
            //this.selectedShape.endY -= dy;
          } else if (this.selectedHandle === 'bottom-left') {
            this.selectedShape.startX += dx;
            //this.selectedShape.endX -= dx;
            this.selectedShape.endY += dy;

          } else if (this.selectedHandle === 'bottom-right') {
            this.selectedShape.endX += dx;
            this.selectedShape.endY += dy;
          }
        } else {
          console.log('Unsupported shape type: ' + this.selectedShape.type);
        }

        // this.resizeStartX = startX;
        // this.resizeStartY = startY;
        this.redrawCanvas(this.images, this.shapes, this.texts);
      };
      // Use requestAnimationFrame for smoother animation
      if (!this.animationFrameId) {
        this.animationFrameId = requestAnimationFrame(() => {
          resizeFunction();
          this.animationFrameId = null;
        });
      }
      this.resizeStartX = startX;
      this.resizeStartY = startY;
    }
  }
  // Get resize handle index
  getResizeHandleImageIndex(x, y, image) {
    const handles = [
      { x: image.posX, y: image.posY, position: 'top-left' },
      { x: image.posX + image.width, y: image.posY, position: 'top-right' },
      { x: image.posX, y: image.posY + image.height, position: 'bottom-left' },
      { x: image.posX + image.width, y: image.posY + image.height, position: 'bottom-right' }
    ];

    const handleSize = 20; // Adjust the size of the handle as needed

    for (let i = 0; i < handles.length; i++) {
      const handle = handles[i];
      console.log(`Checking handle ${handle.position} at (${handle.x}, ${handle.y}) for click at (${x}, ${y})`);
      if (
        x >= handle.x - handleSize / 2 &&
        x <= handle.x + handleSize / 2 &&
        y >= handle.y - handleSize / 2 &&
        y <= handle.y + handleSize / 2
      ) {
        console.log(`Handle for Image ${i + 1} clicked: ${handle.position}`);
        return handle.position;
      }
    }

    return null;
  }



  // Resize selected image
  resizeSelectedImage(currentX, currentY) {
    const handleX = this.initialResizeHandlePosition.x;
    const handleY = this.initialResizeHandlePosition.y;
    const deltaX = currentX - handleX;
    const deltaY = currentY - handleY;
    const selectedImage = this.images[this.selectedImageIndex];

    console.log('Before Resize - Selected Image:', selectedImage);
    console.log('SelectedImage:', { currentX, currentY, handleX, handleY, deltaX, deltaY });

    switch (this.resizeHandleIndex) {
      case 'top-left':
        selectedImage.width = this.initialImageDimensions.width - deltaX;
        selectedImage.height = this.initialImageDimensions.height - deltaY;
        selectedImage.posX = handleX + deltaX;
        selectedImage.posY = handleY + deltaY;
        break;
      case 'top-right':
        selectedImage.width = this.initialImageDimensions.width + deltaX;
        selectedImage.height = this.initialImageDimensions.height - deltaY;
        selectedImage.posY = handleY + deltaY;
        break;
      case 'bottom-left':
        selectedImage.width = this.initialImageDimensions.width - deltaX;
        selectedImage.height = this.initialImageDimensions.height + deltaY;
        selectedImage.posX = handleX + deltaX;
        break;
      case 'bottom-right':
        selectedImage.width = this.initialImageDimensions.width + deltaX;
        selectedImage.height = this.initialImageDimensions.height + deltaY;
        break;
      default:
        console.log('Unknown resize handle:', this.resizeHandleIndex);
        break;
    }

    console.log('After Resize - Selected Image:', selectedImage);
  }

  getResizeHandleTextIndex(x, y, text) {
    const handles = [
      { x: text.x, y: text.y }, // Top-left handle
      { x: text.x + text.width, y: text.y }, // Top-right handle
      { x: text.x, y: text.y + text.height }, // Bottom-left handle
      { x: text.x + text.width, y: text.y + text.height } // Bottom-right handle
    ];

    const handleSize = 20; // Adjust handle size as needed
    for (let i = 0; i < handles.length; i++) {
      const handle = handles[i];
      console.log(`Checking handle in getResizeHandleTextIndex ${i}:`, handle);
      if (
        x >= handle.x - handleSize / 2 &&
        x <= handle.x + handleSize / 2 &&
        y >= handle.y - handleSize / 2 &&
        y <= handle.y + handleSize / 2
      ) {
        return i; // Return the index of the handle
      }
    }

    return null; // Return null if no handle is clicked
  }

  resizeSelectedText(currentX, currentY) {
    const selectedText = this.texts[this.selectedTextIndex];
    const initialDimensions = this.initialTextDimensions;

    // Calculate the resizing based on the handle position
    if (this.resizeHandleTextIndex === 0) { // Top-left handle
      const deltaX = currentX - this.initialResizeHandleTextPosition.x;
      const deltaY = currentY - this.initialResizeHandleTextPosition.y;

      selectedText.width = initialDimensions.width - deltaX;
      selectedText.height = initialDimensions.height - deltaY;
      selectedText.x = currentX;
      selectedText.y = currentY;
    } else if (this.resizeHandleTextIndex === 1) { // Top-right handle
      const deltaY = currentY - this.initialResizeHandleTextPosition.y;

      selectedText.width = currentX - selectedText.x;
      selectedText.height = initialDimensions.height - deltaY;
      selectedText.y = currentY;
    } else if (this.resizeHandleTextIndex === 2) { // Bottom-left handle
      const deltaX = currentX - this.initialResizeHandleTextPosition.x;

      selectedText.width = initialDimensions.width - deltaX;
      selectedText.height = currentY - selectedText.y;
      selectedText.x = currentX;
    } else if (this.resizeHandleTextIndex === 3) { // Bottom-right handle
      selectedText.width = currentX - selectedText.x;
      selectedText.height = currentY - selectedText.y;
    }

    // Ensure the text stays within the resized textbox
    const minFontSize = 8;
    const maxFontSize = 14;
    let fontSize = this.calculateFontSize(selectedText.text, selectedText.width, selectedText.height, minFontSize, maxFontSize);
    selectedText.fontSize = `${fontSize}px`;

    // Redraw the canvas to reflect the changes
    this.redrawCanvas(this.images, this.shapes, this.texts);
  }
  getResizeHandlePreloadedTextIndex(x, y, text) {
    const handles = [
      { x: text.x, y: text.y }, // Top-left handle
      { x: text.x + text.width, y: text.y }, // Top-right handle
      { x: text.x, y: text.y + text.height }, // Bottom-left handle
      { x: text.x + text.width, y: text.y + text.height } // Bottom-right handle
    ];

    const handleSize = 20; // Adjust handle size as needed
    for (let i = 0; i < handles.length; i++) {
      const handle = handles[i];
      // console.log(`Checking handle in getResizeHandlePreloadedTextIndex ${i}:`, handle);
      if (
        x >= handle.x - handleSize / 2 &&
        x <= handle.x + handleSize / 2 &&
        y >= handle.y - handleSize / 2 &&
        y <= handle.y + handleSize / 2
      ) {
        return i; // Return the index of the handle
      }
    }

    return null; // Return null if no handle is clicked
  }
  resizePreloadedText(currentX, currentY) {
    const preloadedText = this.preloadedText[this.selectedPreloadedTextIndex];
    const initialDimensions = this.initialTextDimensions;

    // Calculate the resizing based on the handle position
    if (this.resizeHandlePreloadedTextIndex === 0) { // Top-left handle
      const deltaX = currentX - this.initialResizeHandlePreloadedTextPosition.x;
      const deltaY = currentY - this.initialResizeHandlePreloadedTextPosition.y;

      preloadedText.width = initialDimensions.width - deltaX;
      preloadedText.height = initialDimensions.height - deltaY;
      preloadedText.x = currentX;
      preloadedText.y = currentY;
    } else if (this.resizeHandlePreloadedTextIndex === 1) { // Top-right handle
      const deltaY = currentY - this.initialResizeHandlePreloadedTextPosition.y;

      preloadedText.width = currentX - preloadedText.x;
      preloadedText.height = initialDimensions.height - deltaY;
      preloadedText.y = currentY;
    } else if (this.resizeHandlePreloadedTextIndex === 2) { // Bottom-left handle
      const deltaX = currentX - this.initialResizeHandlePreloadedTextPosition.x;

      preloadedText.width = initialDimensions.width - deltaX;
      preloadedText.height = currentY - preloadedText.y;
      preloadedText.x = currentX;
    } else if (this.resizeHandlePreloadedTextIndex === 3) { // Bottom-right handle
      preloadedText.width = currentX - preloadedText.x;
      preloadedText.height = currentY - preloadedText.y;
    }

    // Ensure the text stays within the resized textbox
    const minFontSize = 8;
    const maxFontSize = 14;
    let fontSize = this.calculateFontSize(preloadedText.text, preloadedText.width, preloadedText.height, minFontSize, maxFontSize);
    preloadedText.fontSize = `${fontSize}px`;

    // Redraw the canvas to reflect the changes
    this.redrawCanvas(this.images, this.shapes, this.preloadedText);

  }




  calculateDistance(x1, y1, x2, y2) {
    // Calculate the Euclidean distance between two points
    return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
  }
  // Add getShapeResizeHandles method
  getShapeResizeHandles(shape) {
    const { type, startX, startY, endX, endY } = shape;

    if (type === 'Line' || type === 'Arrow') {
      // For Line/Arrow, we need two selection handles (start and end points)
      return [
        { x: startX, y: startY }, // Start Point
        { x: endX, y: endY },     // End Point
      ];
    } else if (type === 'Rectangle') {
      // For Rectangle, we need four selection handles (corners)
      return [
        { x: startX, y: startY },         // Top-left
        { x: endX, y: startY },           // Top-right
        { x: endX, y: endY },             // Bottom-right
        { x: startX, y: endY },           // Bottom-left
      ];
    }

    return [];
  }

  //Added by Alagar
  // drawHandles(shape, context){

  //   if (shape.type === 'Line' || shape.type === 'Arrow') {
  //     // Draw handles
  //     context.fillStyle = 'red';
  //     context.fillRect(shape.startX - 5, shape.startY - 5, 10, 10);
  //     context.fillRect(shape.endX - 5, shape.endY - 5, 10, 10);
  //   }else if(shape.type === 'Rectangle'){
  //     // Draw handles
  //     context.fillStyle = 'red';
  //     context.fillRect(shape.startX - 5, shape.startY - 5, 10, 10);
  //     context.fillRect(shape.startX + (shape.endX - shape.startX) - 5, shape.startY - 5, 10, 10);
  //     context.fillRect(shape.startX - 5, shape.startY + (shape.endY - shape.startY) - 5, 10, 10);
  //     context.fillRect(shape.startX + (shape.endX - shape.startX) - 5, shape.startY + (shape.endY - shape.startY) - 5, 10, 10);
  //   }

  // }


  drawHandles(shape, context, handleSize = 25) {
    // console.log('call draw handle..', shape.type);
    if (shape.type === 'Line' || shape.type === 'Arrow') {
      // Draw handles
      context.fillStyle = 'red';
      context.fillRect(shape.startX - handleSize / 2, shape.startY - handleSize / 2, handleSize, handleSize);
      context.fillRect(shape.endX - handleSize / 2, shape.endY - handleSize / 2, handleSize, handleSize);
    } else if (shape.type === 'Rectangle') {
      // Draw handles
      context.fillStyle = 'red';
      context.fillRect(shape.startX - handleSize / 2, shape.startY - handleSize / 2, handleSize, handleSize);
      context.fillRect(shape.startX + (shape.endX - shape.startX) - handleSize / 2, shape.startY - handleSize / 2, handleSize, handleSize);
      context.fillRect(shape.startX - handleSize / 2, shape.startY + (shape.endY - shape.startY) - handleSize / 2, handleSize, handleSize);
      context.fillRect(shape.startX + (shape.endX - shape.startX) - handleSize / 2, shape.startY + (shape.endY - shape.startY) - handleSize / 2, handleSize, handleSize);
    }

  }
  drawTextHandles(text, context, handleSize = 20) {
    // Draw handles for text at the corners
    context.fillStyle = 'red';
    context.fillRect(text.x - handleSize / 2, text.y - handleSize / 2, handleSize, handleSize);
    context.fillRect(text.x + text.width - handleSize / 2, text.y - handleSize / 2, handleSize, handleSize);
    context.fillRect(text.x - handleSize / 2, text.y + text.height - handleSize / 2, handleSize, handleSize);
    context.fillRect(text.x + text.width - handleSize / 2, text.y + text.height - handleSize / 2, handleSize, handleSize);
  }

  drawImageHandles(image, context, handleSize = 20) {
    // console.log('drawing --> ', image);
    // Draw handles for text at the corners
    context.fillStyle = 'red';
    context.fillRect(image.posX - handleSize / 2, image.posY - handleSize / 2, handleSize, handleSize);
    context.fillRect(image.posX + image.width - handleSize / 2, image.posY - handleSize / 2, handleSize, handleSize);
    context.fillRect(image.posX - handleSize / 2, image.posY + image.height - handleSize / 2, handleSize, handleSize);
    context.fillRect(image.posX + image.width - handleSize / 2, image.posY + image.height - handleSize / 2, handleSize, handleSize);

  }
  // Redraw the canvas with all images and shapes
  redrawCanvas(images, shapes, texts) {
    const canvas = this.template.querySelector('canvas');
    const context = canvas.getContext('2d');

    // Assign the texts parameter to this.texts
    this.texts = texts;

    // Draw the base image if it exists
    if (this.baseImage && this.baseImage.data) {
      const baseImageObj = new Image();
      baseImageObj.src = this.baseImage.data;
      // baseImageObj.onload = () => {
      //console.log('load image' );
      // context.clearRect(0, 0, canvas.width, canvas.height);
      context.drawImage(baseImageObj, 0, 0, canvas.width, canvas.height);


      console.log('this.preloadedText -->1665 ', JSON.stringify(this.preloadedText));
      console.log('this.texts -->1666 ', JSON.stringify(this.texts));

      if (this.isLoadFirstTime || this.texts.length === 0) {
        this.adjustPreloadedTextSizes(this.preloadedText);
      }

      if (this.texts) {
        this.adjustPreloadedTextSizes(this.texts);
      }

      //     // Draw the stored texts
      //     if (texts && texts.length > 0) {
      //     texts.forEach(text => {
      //       const { content, fontSize, color, x, y, isUserAdded } = text;
      //         context.font = fontSize + ' Arial';

      //         // Set padding around the text within the background
      //         const paddingX = 7;
      //         const paddingY = 7;

      //         // Measure text dimensions
      //         const textMetrics = context.measureText(content);
      //         const textWidth = textMetrics.width;
      //         const textHeight = parseInt(fontSize, 10); 

      //         // Calculate the dimensions of the rectangle
      //         const rectWidth = textWidth + 2 * paddingX;
      //         const rectHeight = textHeight + 2 * paddingY;

      //         // Calculate the position for the rectangle
      //         const rectX = x - paddingX;
      //         const rectY = y - textHeight - paddingY;

      //         // Draw the red border only for text.content that is not user-added
      //         if (!isUserAdded && content !== this.textValue) {
      //           context.strokeStyle = "red";
      //           context.lineWidth = 2;
      //           context.strokeRect(rectX, rectY, rectWidth, rectHeight);
      //         }

      //         // Draw the background rectangle (white)
      //         context.fillStyle = 'white';
      //         context.fillRect(rectX, rectY, rectWidth, rectHeight);

      //         // Set the text color and draw the text within the rectangle
      //         context.fillStyle = color;
      //         context.fillText(content, x, y);
      //     });
      // }

      // Draw the stored texts
      if (this.texts && this.texts.length > 0) {
        //console.log('1268 text', this.texts );
        this.texts.forEach((text, index) => {
          //console.log('1270 text', index );
          //console.log('1271 text', this.selectedTextpos );
          // this.drawHandles(context, text, index === this.selectedTextIndex);
          // Check if the text is selected and draw selection handles
          if (index === this.selectedTextIndex) {
            // console.log('1275 text', text);
            this.drawTextHandles(text, context);
          }
        });
      }

      // Draw the preloaded texts (text2 and text3)
      if (this.preloadedText && this.preloadedText.length > 0 && this.isLoadFirstTime) {
        // console.log('Preloaded text data:', this.preloadedText);
        this.preloadedText.forEach((text, index) => {
          // Check if the text type is text2 or text3
          if (index === this.selectedPreloadedTextIndex && index > 0) {
            console.log('Drawing handles for preloaded text:', text);
            this.drawTextHandles(text, context);
          }
        });
      }

      // Draw the stored shapes
      if (this.shapes && this.shapes.length > 0) {
        this.shapes.forEach(shape => {
          const { type, startX, startY, endX, endY, color, thickness } = shape;
          context.beginPath();
          context.lineWidth = thickness;
          // context.lineWidth = 2;
          context.strokeStyle = color;

          if (type === 'Rectangle') {
            context.rect(shape.startX, shape.startY, shape.endX - shape.startX, shape.endY - shape.startY);
          } else if (type === 'Line') {
            context.moveTo(startX, startY);
            context.lineTo(endX, endY);
          } else if (type === 'Circle') {
            const radius = Math.sqrt(Math.pow(endX - startX, 2) + Math.pow(endY - startY, 2));
            context.arc(startX, startY, radius, 0, 2 * Math.PI);
          } else if (type === 'Arrow') {
            const dx = endX - startX;
            const dy = endY - startY;
            const angle = Math.atan2(dy, dx);
            const arrowLength = Math.sqrt(dx * dx + dy * dy) / 10;

            // Draw the line
            context.moveTo(startX, startY);
            context.lineTo(endX, endY);

            // Draw the arrowhead
            context.lineTo(endX - arrowLength * Math.cos(angle - Math.PI / 6), endY - arrowLength * Math.sin(angle - Math.PI / 6));
            context.moveTo(endX, endY);
            context.lineTo(endX - arrowLength * Math.cos(angle + Math.PI / 6), endY - arrowLength * Math.sin(angle + Math.PI / 6));
          }

          context.stroke();
          context.closePath();
          // Check if the shape is selected and draw selection handles
          if (this.selectedShapeIndex === this.shapes.indexOf(shape)) {
            this.drawHandles(shape, context);
          }
        });
      }
      // };
    }


    // console.log('redraw images' );


    console.log('Redrawing images 1813-->  ', this.images, 'length-->', this.images.length);
    // Draw the remaining images if they exist
    if (this.images && this.images.length > 0) {
      this.images.forEach((image, index) => {
        const img = new Image();
        img.src = image.src;
        // img.onload = () => {
        context.drawImage(img, image.posX, image.posY, image.width, image.height);
        // Draw rectangle border around the selected image
        if (index === this.selectedImageIndex) {
          context.strokeStyle = 'red'; // Set border color
          context.lineWidth = 2; // Set border width
          context.strokeRect(image.posX, image.posY, image.width, image.height);
          this.drawImageHandles(image, context);
        }

        // };
      });
    }
    // Save the current canvas state to history
    // this.saveCanvasStateToHistory();

    //drawing mode
    //console.log('<--drawing line -->', this.isDrawing, ' ', this.selectedShape);
    if (this.isDrawing) {
      if (this.selectedShape === 'Line') {
        // console.log('drawing line -->');
        this.drawLineShape(this.drawStartX, this.drawStartY, this.drawEndX, this.drawEndY);
      } else if (this.selectedShape === 'Arrow') {
        // console.log('drawing Arrow -->');
        this.drawArrowShapes(this.drawStartX, this.drawStartY, this.drawEndX, this.drawEndY);
      } else if (this.selectedShape === 'Rectangle') {
        //    console.log('drawing rectangle -->');
        this.drawRectangleShape(this.drawStartX, this.drawStartY, this.drawEndX, this.drawEndY);
      }
    }
  }

  // new property for storing the shape color
  shapeColor = '#FF0000';

  // Handle color change event from the color picker
  handleColorChange(event) {
    const colorValue = event.target.dataset.value;
    this.shapeColor = colorValue;
    // Remove 'selected' class from all color buttons
    this.template.querySelectorAll('.color-button').forEach(button => {
      button.classList.remove('selected');
    });

    // Add 'selected' class to the clicked color button
    event.target.classList.add('selected');
  }
  // Handle color change event from the color picker
  handleColorPickerChange(event) {
    const colorValue = event.target.value;
    this.shapeColor = colorValue;
    // Remove 'selected' class from all color buttons
    this.template.querySelectorAll('.color-button').forEach(button => {
      button.classList.remove('selected');
    });
  }

  openColorPicker(event) {
    const colorPickerInput = this.template.querySelector('.color-picker');
    colorPickerInput.click();
    event.stopPropagation();

    // Retrieve the color value from the color picker input
    const colorValue = colorPickerInput.value;
    this.shapeColor = colorValue;
  }
  // Draw a rectangle shape on the canvas
  drawRectangleShape(startX, startY, endX, endY) {
    const canvas = this.template.querySelector('canvas');
    const context = canvas.getContext('2d');

    context.beginPath();
    context.lineWidth = 2;
    context.strokeStyle = this.shapeColor;
    context.rect(startX, startY, endX - startX, endY - startY);
    context.stroke();
    context.closePath();
  }



  // Draw a line shape on the canvas
  drawLineShape(startX, startY, endX, endY) {
    this.imageContext.beginPath();
    this.imageContext.lineWidth = 2;
    this.imageContext.strokeStyle = this.shapeColor;
    this.imageContext.moveTo(startX, startY);
    this.imageContext.lineTo(endX, endY);
    this.imageContext.stroke();
    this.imageContext.closePath();
  }

  // Draw a circle shape on the canvas
  drawCircleShape(startX, startY, endX, endY) {
    const radius = Math.sqrt(
      Math.pow(endX - startX, 2) + Math.pow(endY - startY, 2)
    );

    this.imageContext.beginPath();
    this.imageContext.lineWidth = 2;
    this.imageContext.strokeStyle = this.shapeColor;
    this.imageContext.arc(startX, startY, radius, 0, 2 * Math.PI);
    this.imageContext.stroke();
    this.imageContext.closePath();
  }

  // Draw an arrow shape on the canvas
  drawArrowShapes(startX, startY, endX, endY) {
    // Calculate the angle and arrow length
    const dx = endX - startX;
    const dy = endY - startY;
    const angle = Math.atan2(dy, dx);
    const arrowLength = Math.sqrt(dx * dx + dy * dy) / 10;

    // Draw the line
    this.imageContext.moveTo(startX, startY);
    this.imageContext.lineTo(endX, endY);

    // Draw the arrowhead
    this.imageContext.lineTo(endX - arrowLength * Math.cos(angle - Math.PI / 6), endY - arrowLength * Math.sin(angle - Math.PI / 6));
    this.imageContext.moveTo(endX, endY);
    this.imageContext.lineTo(endX - arrowLength * Math.cos(angle + Math.PI / 6), endY - arrowLength * Math.sin(angle + Math.PI / 6));
  }

  // Draw an arrow shape on the canvas
  drawArrowShape(context, startX, startY, endX, endY) {
    // Calculate the angle and arrow length
    const dx = endX - startX;
    const dy = endY - startY;
    const angle = Math.atan2(dy, dx);
    const arrowLength = Math.sqrt(dx * dx + dy * dy) / 10;

    // Draw the line
    context.moveTo(startX, startY);
    context.lineTo(endX, endY);

    // Draw the arrowhead
    context.lineTo(endX - arrowLength * Math.cos(angle - Math.PI / 6), endY - arrowLength * Math.sin(angle - Math.PI / 6));
    context.moveTo(endX, endY);
    context.lineTo(endX - arrowLength * Math.cos(angle + Math.PI / 6), endY - arrowLength * Math.sin(angle + Math.PI / 6));
  }

  // Handle the clear button click event
  handleClear() {
    if (this.drawnItems.length > 0) {
      this.undoLastDrawnItem();
      this.lastDrawnItem = '';
    }
  }
  // Event handler for the Remove button click
  handleRemove() {
    console.log('Selected Shape Index:', this.selectedShapeIndex);
    console.log('Selected Image Index:', this.selectedImageIndex);
    console.log('Selected Text Index:', this.selectedTextIndex);
    console.log('Selected Preloaded Text Index:', this.selectedPreloadedTextIndex);

    // Handle the removal logic based on the selected items
    if (this.selectedShapeIndex !== -1) {
      console.log('Removing shape at index:', this.selectedShapeIndex);
      this.shapes.splice(this.selectedShapeIndex, 1);
      this.selectedShapeIndex = -1; // Reset the selected index after removal
    }
    if (this.selectedImageIndex !== -1) {
      console.log('Removing image at index:', this.selectedImageIndex);
      this.images.splice(this.selectedImageIndex, 1);
      this.selectedImageIndex = -1; // Reset the selected index after removal
    }
    console.log('Removing text at index 1812:', this.selectedTextIndex);
    if (this.selectedTextIndex !== -1) {
      // Ensure the index is valid before attempting removal
      if (this.selectedTextIndex >= 0 && this.selectedTextIndex < this.texts.length) {
        console.log('Removing text at index:', this.selectedTextIndex);
        this.texts.splice(this.selectedTextIndex, 1);
        this.selectedTextIndex = -1; // Reset the selected index after removal
      } else {
        console.warn('Selected text index is out of bounds');
      }
    } else {
      console.warn('No text item selected for removal');
    }
    // Redraw the canvas with the updated state
    this.redrawCanvas(this.images, this.shapes, this.texts);
  }
  undoLastDrawnItem() {

    const lastDrawnType = this.drawnItems.pop();

    switch (lastDrawnType) {
      case 'Shape':
        this.shapes.pop();
        break;
      case 'Image':
        this.images.pop();
        break;
      case 'Text':
        this.texts.pop();
        break;
      default:
        break;
    }
    // Redraw the canvas with the updated state
    this.redrawCanvas(this.images, this.shapes, this.texts);
  }

  // Handle the save action---commented by ash
  // handleSave() {
  //   const canvas = this.template.querySelector('canvas');
  //   const image = canvas.toDataURL('image/png');
  //   const base64Image = image.split(',')[1];

  //   saveCanvas({ recordId: this.recordId, base64Image: base64Image })
  //     .then(result => {
  //       if (result) {
  //         this.dispatchEvent(
  //           new ShowToastEvent({
  //             title: 'Success',
  //             message: 'Canvas saved successfully',
  //             variant: 'success'
  //           })
  //         );
  //       } else {
  //         this.dispatchEvent(
  //           new ShowToastEvent({
  //             title: 'Error',
  //             message: 'Failed to save canvas',
  //             variant: 'error'
  //           })
  //         );
  //       }
  //     })
  //     .catch(error => {
  //       console.error('Save Canvas Error:', error);
  //       this.dispatchEvent(
  //         new ShowToastEvent({
  //           title: 'Error',
  //           message: 'An error occurred while saving the canvas',
  //           variant: 'error'
  //         })
  //       );
  //     });
  // }
  handleClick(event) {
    // Get the clicked image source
    const src = event.target.src;

    // Check if the clicked icon is already selected
    const isSelected = this.selectedIcons.some(icon => icon.src === src);
    // If the icon is already selected, remove it from the selectedIcons array
    if (isSelected) {
      this.selectedIcons = this.selectedIcons.filter(icon => icon.src !== src);
      // Remove the 'selected-icon' class from the clicked icon for visual indication
      event.target.classList.remove('selected-icon');
    } else {
      // If not selected, add it to the selectedIcons array
      this.selectedIcons.push({ src });
      // Apply CSS class to the clicked icon for visual indication
      event.target.classList.add('selected-icon');

    }
    
    // Trigger canvas redraw after icon selection
    // this.redrawCanvas(this.images, this.shapes, this.texts);
  }

  // Update handleOKClick method to draw selected icons on canvas
  handleIconsOKClick() {
    const canvas = this.template.querySelector('canvas');
    const context = canvas.getContext('2d');

    // Check if canvas and context are available
    // if (!canvas || !context) {
    //   console.error('Canvas or context is not available.');
    //   return;
    // }

    // Clear the canvas
    // context.clearRect(0, 0, canvas.width, canvas.height);
    // console.log('Selected icons:', this.selectedIcons);
    // console.log('Images before adding new icons:', JSON.parse(JSON.stringify(this.images)));

    // Define initial position for the icons
    let posX = 20;
    let posY = 20;

    // Iterate over the selected icons and add them to the canvas
    this.selectedIcons.forEach((icon, index) => {
      const newImage = {
        src: icon.src,
        posX: posX,
        posY: posY,
        width: 50, // Adjust as needed
        height: 50 // Adjust as needed
      };

      // Create new Image instance
      const image = new Image();
      image.src = icon.src;

      // Handle image load
      image.onload = () => {
        // Draw image on canvas
        context.drawImage(image, newImage.posX, newImage.posY, newImage.width, newImage.height);
        //  console.log(`Drawing new image ${index} at (${newImage.posX}, ${newImage.posY})`);

        // Push new image to images array
        this.images.push(newImage);
        // console.log('New image added to images array:', newImage);

        // Ensure to redraw any selected style if needed
        if (index === this.selectedImageIndex) {
          context.strokeStyle = 'red';
          context.lineWidth = 2;
          context.strokeRect(newImage.posX, newImage.posY, newImage.width, newImage.height);
          // Also draw any handles or additional styles
          this.drawImageHandles(newImage, context);
        }
        // Redraw the canvas with updated images, shapes, and texts
        this.redrawCanvas(this.images, this.shapes, this.texts);
      };

      // Update position for the next icon
      posX += 70; // Increase X position for next icon
      if (posX > canvas.width - 70) { // Check if next icon will exceed canvas width
        posX = 20; // Reset X position to start a new row
        posY += 70; // Increase Y position to start a new row
      }
    });

    // Log updated images array
    //  console.log('Images array after adding new icons:', [...this.images]);

    // Clear selectedIcons array after adding images
    this.selectedIcons = [];

    // Close the popup or reset UI state
    this.isAddingIcons = false;
    this.isokclicked = true;
    // Redraw the canvas with updated images, shapes, and texts
    // this.redrawCanvas(this.images, this.shapes, this.texts);
  }


  // Update handleOkcancelClick method to close the popup without adding icons
  handleIconsCancelClick() {
    // console.log('Cancel button clicked');

    // Log the selected icons array before resetting
    // console.log('Selected icons before reset:', this.selectedIcons);

    // Reset selected icons array
    this.selectedIcons = [];

    // Close the popup by setting isAddingIcons to false
    this.isAddingIcons = false;
  }


  // Event handler for the "AddText" button click
  handleAddText() {
    this.isAddingText = true;
  }
  // Event handler for the "AddText" button click
  handleIcons() {
    this.isAddingIcons = true;
  }
  // Event handler for input value change
  handleInputChange(event) {
    this.textValue = event.target.value;
  }
  get canvas() {
    return this.canvasElement;
  }
  handleOKClick() {
    if (this.textValue !== '') {
      const MIN_HEIGHT = 30;
      let textArr =
      {
        x: 30,
        y: 210,
        width: 200,
        height: MIN_HEIGHT, // Initially set to 0
        text: this.textValue,
        textColor: 'black',
        backgroundColor: 'white',
        borderColor: 'red',
      }
      // The initial height based on the content
      //  const initialHeight = this.measureWrappedText(this.textValue, textArr.width - 20, 24);
      //  textArr.height = initialHeight;\
      const initialHeight = this.measureWrappedText(this.textValue, textArr.width - 10, 10);
      textArr.height = Math.max(initialHeight, MIN_HEIGHT);

      this.texts.push(textArr);
      this.textValue = '';

    }
    this.isokclicked = true;
    this.isAddingText = false; // Close the text input field
    this.redrawCanvas(this.images, this.shapes, this.texts);
  }


  handleKeyDown(event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      event.target.blur();
    }
  }




  async createDcfrecord() {
    this.selectedPreloadedTextIndex = false;
    this.selectedImageIndex = false;
    this.resizeHandleIndex = false;
    this.selectedShapeIndex = false;
    this.isDrawing = false;
    this.selectedHandle = null;


    //console.log("isEdit---->",this.isEdit)
    console.log('inside createDcfrecord1');
    this.isLoading = true;
    this.isdisable = true;
    let recordInput;

    const datafrom = JSON.parse(JSON.stringify(this.dcfrecorddata));
    this.dcfinfrarecordfromparent = datafrom.dcfdata;


    console.log('dcfinfrarecordfromparent----->json--------', JSON.stringify(this.dcfinfrarecordfromparent));
    if (this.isEdit === true) {
      //  console.log("this.isEdit === true 1")
      this.dcfinfrarecordfromparent.Id = this.recordId;
      delete this.dcfinfrarecordfromparent.isvisited;
      // console.log("dcfinfrarecordfromparent.Id", this.dcfinfrarecordfromparent.Id)

    }

    const fields = this.dcfinfrarecordfromparent;

    if (this.formtype === 'sewerageFWR') {
      if (JSON.stringify(this.dcfinfrarecordfromparent.FSM_FWRCommsType__c) != undefined) {
        //add values to multiselect picklist
        const arr = this.dcfinfrarecordfromparent.FSM_FWRCommsType__c.join(";");
        // console.log('arr------->',arr);
        this.dcfinfrarecordfromparent.FSM_FWRCommsType__c = arr;
      }
      //console.log("createDcfrecord fields -->",fields)
      recordInput = { apiName: DCFINFRA2_OBJECT.objectApiName, fields };
    } else {

      if (JSON.stringify(this.dcfinfrarecordfromparent.FSM_LetterWarn__c) != undefined) {
        //add values to multiselect picklist
        const arr = this.dcfinfrarecordfromparent.FSM_LetterWarn__c.join(";");

        this.dcfinfrarecordfromparent.FSM_LetterWarn__c = arr;
      }

      recordInput = { apiName: DCFINFRA_OBJECT.objectApiName, fields };
      console.log('infra FWR', recordInput)
    }
    if (this.isEdit === true) {
      //update
      //  console.log("this.isEdit test---->")
      const recordInput1 = { fields };
      await updateRecord(recordInput1).then(() => {
        console.log('workstep updateRecord4');
        this.createcontentversion(this.recordId)
      }).catch(error => {
        console.log('catch---->', error)
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error updating dcf infra record',
            message: error.body.message,
            variant: 'error'
          })
        );
      });
    } else {
      console.log("inside else", recordInput)
      this.dcfid = await createRecord(recordInput);

      this.updateworkstepfield(this.dcfid.id);
    }
  }



  //update the wirkstep field of dcf infra record
  async updateworkstepfield(dcfrecid) {
    console.log('inside updateworkstepfield3');
    const fields = {};
    fields['Id'] = dcfrecid; //populate it with current record Id
    fields['FSM_WorkStep__c'] = this.recordId; //populate any fields which you want to update like this
    // fields['FSM_Status__c'] = 'Completed';
    const recordInput = { fields };
    //  console.log('recordInput updte workstep', JSON.stringify(recordInput));
    updateRecord(recordInput).then(() => {
      console.log('workstep updateRecord4');
      this.createcontentversion(this.dcfid.id)


    }).catch(error => {
      console.log('catch---->', error)
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error creating record',
          message: error.body.message,
          variant: 'error'
        })
      );
    });
    if (this.formtype != 'sewerageFWR') {
      //create dcflineitems
      const datafromlineitem = JSON.parse(JSON.stringify(this.dcfrecorddata));
      this.dcfinfralineitems = datafromlineitem.dcflineitemdata;
      this.customerlineitemstoinsert = datafromlineitem.customerlineitems;
      //console.log('dcfinfrarecordfromparent');
      if (JSON.stringify(this.customerlineitemstoinsert) != undefined) {
        // console.log('line item creation', JSON.stringify(this.customerlineitemstoinsert), dcfrecid);
        this.customerlineitemstoinsert.forEach((record) => {

          this.createDcfcustomerlineitemrecord(record, dcfrecid);

        });

      }
      if (JSON.stringify(this.dcfinfralineitems) != undefined) {

        // "No Of Line Items Eforms Of Same Type" field using count var as a part of SFI-1721........
        // Developer Name: Nishant Kumar
        let count = 0;
        this.dcfinfralineitems.forEach((record) => {
          count += 1;

          this.createDcflineitemrecord(record, dcfrecid, count);


        });
        // this.isLoading=false;
        //this.createcontentversion();

      } else {
        //this.isLoading=false;
        this.isdisable = false;
      }
    }


  }
  //method to insert Proposed valve operation dcf line item 
  async createDcflineitemrecord(submitValues, parentdcfid, count) {

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
    // console.log('recordInput DCF LINEITEM', JSON.stringify(recordInput));
    createRecord(recordInput)
      .then((dcf) => {
        this.dcfid = dcf.id;
        submitValues = {};
      })
      .catch((error) => {
        console.log('catch---->', error)
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

  }
  //method to insert Additional customer dcf line item 
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
    // console.log('recordInput updte CUSTOMER LINEITEm', JSON.stringify(recordInput));
    createRecord(recordInput)
      .then((custlineitem) => {
        this.dcfcustlineitemid = custlineitem.id;
        //  console.log('this.dcfcustlineitemid ', this.dcfcustlineitemid);
        submitValues = {};
      })
      .catch((error) => {
        console.log('catch---->', error)
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
  async updatedcflineitems(submitValues) {
    // console.log('inside update valve ');
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
      // this.successmessagewindow=true;
      // this.isLoading=false;
      this.generatepdfsketch(this.recordId);


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

  async updatecustomerlineitems(submitValues) {
    const dcfcustlineitemdata = {
      FSM_CustomerName__c: submitValues.FSM_CustomerName__c,
      FSM_ContactNumber__c: submitValues.FSM_ContactNumber__c,
      FSM_ResidentialStatus__c: submitValues.FSM_ResidentialStatus__c,
      FSM_ContactWithCustomer__c: submitValues.FSM_ContactWithCustomer__c,
      FSM_CanISTBeIsolated__c: submitValues.FSM_CanISTBeIsolated__c,
      FSM_Address__c: submitValues.FSM_Address__c,
      Id: submitValues.recordId
    }
    const dcfcustlineitemdatainsert = JSON.parse(JSON.stringify(dcfcustlineitemdata));
    const fields = dcfcustlineitemdatainsert;
    const recordInput = { fields };
    updateRecord(recordInput).then(() => {
      // this.successmessagewindow=true;
      // this.isLoading=false;
      this.generatepdfsketch(this.recordId);
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
  //fetch dcf infra recordtypeid
  @wire(getObjectInfo, { objectApiName: FSM_DCFLineItemInfraOBJECT })
  getobjdata({ data, error }) {
    if (data) {
      let recmap = JSON.parse(JSON.stringify(data.recordTypeInfos));

      this.dcfinfralineitemrectypeid = Object.keys(recmap).find(recTyp => recmap[recTyp].name === 'Proposed Valve Operation');
      this.addcustdcfinfralineitemrectypeid = Object.keys(recmap).find(recTyp => recmap[recTyp].name === 'Additional Customer');
    }
  }


  handlePrev() {
    if (!!JSON.stringify(this.texts) || !!JSON.stringify(this.images) || !!JSON.stringify(this.shapes) || !!JSON.stringify(this.preloadedText)) {
      console.log('Going inside IF 2503');
      this.dispatchEvent(
        new CustomEvent("preveditor", {
          detail: { mapimg: this.baseImage, icons: this.siteImage, textarr: this.texts, imgarr: this.images, shapesarr: this.shapes, preloaddata: this.preloadedText, sketchimgretain: this.sketchImage, tmaimgretain: this.tmasketchImage }
        })
      );

    } else {
      console.log('Going inside ELSE 2511');
      //  console.log('inside else handle prev from sketch editor');
      this.dispatchEvent(
        new CustomEvent("preveditor", {
          detail: { mapimg: this.baseImage, icons: this.siteImage, sketchimgretain: this.sketchImage, tmaimgretain: this.tmasketchImage }
        })
      );

    }
    // this.preloadedtextprev=[];
    // this.preloadedText = [];
    // this.texts = [];
    console.log('This text----> ', JSON.stringify(this.texts));
    console.log('preloaded text----> ', JSON.stringify(this.preloadedText));

  }


  closesketcheditorwindow() {
    const event = new CustomEvent('pdfcreation', {

      detail: "true"
    });
    this.dispatchEvent(event);
  }

  gotorecordpage() {
    // console.log('inside editor record page navigate', this.recordId);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "WorkOrder",
        actionName: "view"
      }
    });
  }


  gotothankyouscreen() {
    console.log('inside thank you function 9');
    const event = new CustomEvent('endscreen', {

      detail: "true"
    });
    this.dispatchEvent(event);
  }

  @track filesData = [];




  createcontentversion(dcfrecordid) {

    //console.log('dcf id', dcfrecordid, 'inside createcontentversion5');

    const canvas = this.template.querySelector('canvas');
    const finalImageSrc = canvas.toDataURL('image/jpeg');



    const sketchcontentdata = finalImageSrc.split(',')[1];

    this.filesData.push({ 'fileName': 'sketch.jpeg', 'fileContent': sketchcontentdata })
    //photos
    if (!!this.photoImages) {
      this.photoImages.forEach((element, index) => {
        const photostoupload = JSON.stringify(element.data);

        const filecontentdata = photostoupload.split(',')[1];
        const removeLast3 = filecontentdata.slice(0, -1);

        const metadata = element.metadata.fileName;
        const fileext = element.metadata.ext;


        this.filesData.push({ 'fileName': 'Photo ' + index + '.' + fileext, 'fileContent': removeLast3 });
      });
    }

    //site icons
    //console.log('siteimage check', JSON.stringify(this.siteImage), '------', JSON.stringify(this.tmasketchImage));
    if (JSON.stringify(this.siteImage) != '[]') {
      this.siteImage.forEach((element, index) => {
        const siteImageupload = JSON.stringify(element.data);

        const filecontentdata = siteImageupload.split(',')[1];
        const removeLast3 = filecontentdata.slice(0, -1);

        const metadata = element.metadata.fileName;
        const fileext = element.metadata.ext;

        //  const filenamewithext=metadata+'.'+fileext;
        this.filesData.push({ 'fileName': 'Site ' + index + '.' + fileext, 'fileContent': removeLast3 });
      });
    }


    //banner
    if (JSON.stringify(this.tmasketchImage) != '[]') {
      this.tmasketchImage.forEach((element, index) => {
        const bannerupload = JSON.stringify(element.data);

        const filecontentdata = bannerupload.split(',')[1];
        const removeLast3 = filecontentdata.slice(0, -1);

        const metadata = element.metadata.fileName;
        const fileext = element.metadata.ext;

        // const filenamewithext=metadata+'.'+fileext;
        this.filesData.push({ 'fileName': 'Banner ' + index + '.' + fileext, 'fileContent': removeLast3 });
      });

    }
    if (this.formtype != 'sewerageFWR') {
      //proforma Image Data
      if (JSON.stringify(this.proformaImages) != '[]' || JSON.stringify(this.proformaImages) != undefined) {
        this.proformaImages.forEach((element, index) => {
          const proformaphotostoinsert = JSON.stringify(element.data);

          const filecontentdata = proformaphotostoinsert.split(',')[1];
          const removeLast3 = filecontentdata.slice(0, -1);

          //const metadata=element.metadata.fileName;
          const fileext = element.metadata.ext;


          this.filesData.push({ 'fileName': 'Proforma ' + index + '.' + fileext, 'fileContent': removeLast3 });
        });
      }
    }

    //end proforma Image Data
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
          FSM_RelatedrecordId__c: dcfrecordid,
          FSM_Sketch_Additional_Images__c: true,
          FSM_Do_not_send_to_SAP__c: this.filesData[i].fileName.includes('Proforma ')?false:true

        }
        console.log(' sketch editor files insde the loop ofcreatecontentversion   === '+this.filesData[i].fileName+'FSM_Do_not_send_to_SAP__c  == '+fileData.FSM_Do_not_send_to_SAP__c);  
        allcvtoinsert.push(fileData);

      }

      this.cvinsert(allcvtoinsert, dcfrecordid);
    }


  }

  cvinsert(cvarr, dcfrecordid) {

    console.log('inside cvinsert6');
    // cvarr.forEach((record, index) => {
    //   console.log('record', JSON.stringify(record));
    //   const payload = { apiName: 'ContentVersion', fields: record };

    //   createRecord(payload).then(cversion => {
    //     this.cvid = cversion.id;
    //     console.log('content vrsion ids', this.cvid);
    //     if (index == cvarr.length - 1) {
    //       this.generatepdfsketch(dcfrecordid);
    //       this.filesData = [];
    //     }
    //   }).catch(error => {
    //     console.log('catch---->', error)
    //     this.dispatchEvent(
    //       new ShowToastEvent({
    //         title: 'Error creating content version',
    //         message: error.body.message,
    //         variant: 'error',
    //       }),
    //     );
    //     this.error = error;
    //   });



    // });


    let promises = [];

    cvarr.forEach(version => {
      let recordInput = { apiName: 'ContentVersion', fields: version };
      promises.push(createRecord(recordInput));
    });

    Promise.all(promises)
      .then(results => {
        // Handle successful insertion
        console.log('Content versions inserted successfully:', results, this.isEdit);

        if (this.isEdit == true && this.formtype != 'sewerageFWR') {
          console.log('inside line item', this.formtype);

          const datafromlineitem = JSON.parse(JSON.stringify(this.dcfrecorddata));
          console.log('inside datafromlineitem', datafromlineitem);
          console.log('inside line item', datafromlineitem.dcflineitemdata, '----->', datafromlineitem.customerlineitems);


          //console.log('dcfinfrarecordfromparent');
          if (datafromlineitem.customerlineitems != undefined) {

            console.log('inside datafromlineitem.customerlineitems');
            this.customerlineitemstoinsert = datafromlineitem.customerlineitems;
            if (JSON.stringify(this.customerlineitemstoinsert) != undefined) {
              console.log('line item creation', JSON.stringify(this.customerlineitemstoinsert));
              this.customerlineitemstoinsert.forEach((record) => {

                if (record.recordId == '') {
                  this.createDcfcustomerlineitemrecord(record, this.recordId);

                } else {
                  this.updatecustomerlineitems(record);
                }

              });
              console.log('outside for cust line');
              this.generatepdfsketch(dcfrecordid);
            }

          } else if (datafromlineitem.dcflineitemdata) {
            console.log('inside datafromlineitem.dcflineitemdata');
            this.dcfinfralineitems = datafromlineitem.dcflineitemdata;
            if (JSON.stringify(this.dcfinfralineitems) != undefined) {
              let count = 0;
              this.dcfinfralineitems.forEach((record) => {

                if (record.recordId == '') {
                  count += 1;
                  this.createDcflineitemrecord(record, this.recordId, count);

                } else {
                  this.updatedcflineitems(record);
                }
              });
              console.log('outside for dcf line');
              this.generatepdfsketch(dcfrecordid);
            }

          } else {
            console.log('inside else generatepdfsketch');
            this.generatepdfsketch(dcfrecordid);
          }

        } else {
          console.log('Content versions inserted generatepdfsketch');
          this.generatepdfsketch(dcfrecordid);
        }
        this.filesData = [];
        // Optionally, reset form or perform other actions
      })
      .catch(error => {
        // Handle error
        console.error('Error inserting content versions:', error);
      });

    // this.isLoading = false;


  }

  // update generate pdf field of dcf infra record so that trigger will call the vf page

  async generatepdfsketch(dcfrecid) {
    console.log('inside generatepdfsketch7');
    const fields = {};
    fields['Id'] = dcfrecid; //populate it with current record Id
    fields['FSM_Generate_PDF__c'] = true; //populate any fields which you want to update like this
    fields['FSM_DeviceType__c'] = this.deviceType;


    const recordInput = { fields };

    await updateRecord(recordInput).then(() => {
      // console.log('inside updateRecord8 generaterecord8');
      this.gotothankyouscreen();

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


  handleOkcancelClick() {
    this.isAddingText = false;
  }

  handleModalClose() {
    this.isAddingIcons = false;
    this.isAddingText = false;
  }

}
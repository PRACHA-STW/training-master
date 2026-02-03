/**
 * @description Lightning web component to display Job history response and Job Notification response
 */
import { LightningElement,api,track } from 'lwc';
import fetchWorkOrderRecord from '@salesforce/apex/FSM_AssetRetreiveHistory.getWorkOrderRecord';
import sendJobDetails from '@salesforce/apex/FSM_JobHistoryRetrieve.getWorkOrderReport';
import sendJobNotification from '@salesforce/apex/FSM_JobHistoryRetrieve.getNotificationLongText';
import checkToggle from '@salesforce/apex/FSM_JobHistoryRetrieve.checkToggle';

import checkAssetToggle from '@salesforce/apex/FSM_AssetRetreiveHistory.checkToggle';

import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DataRetrievalComp extends LightningElement {

    @track Screen1 = true;
    @track Screen2 = false;
    @track Screen3 = false;
    @track Screen4 = false;
    @api recordId;
		isOnline = navigator.onLine;
    @api SArecID;
    WorkorderFields = {};
    @track selectedOption = 'None';
    firstFiveCharacters;
    remainingCharacters;
    @track showError = false; 
    @api errorMessage
    workOrderReports=[];
    wo;
    @track isLoadingScreen = true;
    @track longTextFieldValue='KJSDKJDSLDKDSJDS';
    @track space=' ';
		assetFlag=false;
        spining=false;
        spining1=false;
        togglejobHistory;

        
get addSpace(){
   return '\xa0\xa0\xa0'+'Job  History'+'\xa0\xa0\xa0';
}
    customPicklistOptions = [
        { label: 'None', value: 'None' },
        { value: 'ZPM1', label: 'Unplanned Maintenance Order' },
        { value: 'ZPM3', label: 'Telemetry Alarm Order' },
        { value: 'ZPM4', label: 'Netbase Order' },
        { value:'ZPM6', label:'Capital Scheme Order'},
        { value:'ZSM1', label:'Customer Order'},
        { value:'ZSM2', label:'Dev Services Water Order'},
        { value:'ZSM3', label:'Dev Services Waste Water Order'},
        { value:'ZSM5', label:'Metering Maintenance Order'},
        { value:'ZSM6', label:'Metering FROPT Order'}
    ];

    connectedCallback() {
				window.addEventListener('online', this.handleOnline);
        window.addEventListener('offline', this.handleOffline);
        console.log('Current Record ID1:', this.SArecID);
				console.log('remaining characters-->'+this.remainingCharacters);
				console.log('first five haracters--> '+this.firstFiveCharacters);
        this.fetchWOData();
			
				
    }
disconnectedCallback() {
        window.removeEventListener('online', this.handleOnline);
        window.removeEventListener('offline', this.handleOffline);
    }
handleOnline = () => {
        this.isOnline = true;
    };
 
    handleOffline = () => {
        this.isOnline = false;
        this.showToast('Error', 'Your mobile data is offline.');
    };
 
    showToast(title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error',
						mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
 
 
    fetchWOData() {
        console.log('Current Record ID1:', this.SArecID);
				 console.log('Current Record ID1 rec :', this.recordId); 
        fetchWorkOrderRecord({ recordId: this.recordId })
            .then(result => {
                this.WorkorderFields = result;
                if (this.WorkorderFields.FSM_DMADA__c) {
                    this.firstFiveCharacters = this.WorkorderFields.FSM_DMADA__c.substring(0, 5);
                    this.remainingCharacters = this.WorkorderFields.FSM_DMADA__c.substring(5);
                }
            })
            .catch(error => {
                const evt = new ShowToastEvent
												({
																title: 'Error',
																message:error.body.message,
																variant: 'Error',
																mode: 'sticky'
												});
												this.dispatchEvent(evt);
            });
    }

    handleChange(event){
        const fieldName = event.target.name;
        this.WorkorderFields = { ...this.WorkorderFields, [fieldName]: event.target.value };
    }

    handleCustomPicklistChange(event) {
        this.selectedOption = event.detail.value;
        console.log('Selected Picklist Value:', this.selectedOption);
    }

    dmaChange(event) {
        this.firstFiveCharacters = event.target.value;
    }

    daChange(event) {
        this.remainingCharacters = event.target.value;
    }

    postcodeChange(event){
        this.WorkorderFields = { ...this.WorkorderFields, PostalCode: event.target.value};
    }

    flocChange(event){
        this.WorkorderFields = { ...this.WorkorderFields, FSM_Floc__c: event.target.value };
    }

    disconnectedCallback()
		{  
				localStorage.clear()
		}

    searchJob(event)
	  {
        const { PostalCode, FSM_Floc__c } = this.WorkorderFields;
        const selectedPicklistValue = this.selectedOption;
				if ((PostalCode===null||PostalCode===undefined ||PostalCode=='') && (this.firstFiveCharacters===null||this.firstFiveCharacters===undefined||this.firstFiveCharacters=='') && 
						(this.remainingCharacters===null||this.remainingCharacters===undefined||this.remainingCharacters==''))
				{
								const evt1 = new ShowToastEvent({
										title: 'Info',
										message: 'Please fill at least one of the Post Code, DMA, or Drainage Area fields.',
										variant: 'info',
										mode: 'sticky'
						});
						this.dispatchEvent(evt1);
						return;
       }
    	if(localStorage.getItem('Responsedata')===null || localStorage.getItem('Responsedata')===undefined){
        this.spining=true;
        sendJobDetails({
                postCode: PostalCode,
                dma: this.firstFiveCharacters,
                drainageArea: this.remainingCharacters,
                floc: FSM_Floc__c,
                orderType: selectedPicklistValue
            })
            .then(data=>{
                if(data.length > 0){
                 this.spining=false;
                this.workOrderReports=data;
                localStorage.setItem('Responsedata', JSON.stringify(this.workOrderReports));
                }
                else{
                    this.spining=false;
                const evt = new ShowToastEvent
												({
																title: 'Error',
																message:'No Results Found!',
																variant: 'Error',
																mode: 'sticky'
												});
												this.dispatchEvent(evt);

                }
                
            })
            .catch(error=>{
                this.spining=false;
                const evt = new ShowToastEvent
												({
																title: 'Error',
																message:error.body.message,
																variant: 'Error',
																mode: 'sticky'
												});
												this.dispatchEvent(evt);
            });
        }
        else{
            this.workOrderReports=JSON.parse(localStorage.getItem('Responsedata'));
        }
            if(this.Screen2===true){
            this.workOrderReports=undefined;
            this.Screen2=false;
            this.Screen3=true;
           }
           if(this.Screen4===true){
            localStorage.clear();
             this.Screen3=true;
               this.Screen4=false;
               this.spining=false;
            }

            
   }

    viewNotificationLongText(event) {
        event.preventDefault();
    }

    renderedCallback() {
        const container = this.template.querySelector('.container');
        if(container) {
            container.style.backgroundColor = 'white';
        }
    }

    handleBackClick(event){
        if(this.Screen2===true){
            this.Screen1=true;
            this.Screen2=false;
}
    }

    handleRedirect(event){
      

        checkToggle().then(data=>{
						console.log('resonse'+data);
            this.togglejobHistory=data.Active__c;
            if(!this.togglejobHistory)
						{
                const evt = new ShowToastEvent
												({
																title: 'Info',
																message:'Job History interface not active!',
																variant: 'info',
																mode: 'sticky'
												});
												this.dispatchEvent(evt);
            }
						else{
											
											if(this.Screen1===true){
														this.Screen2=true;
														this.Screen1=false;
											}
											if(this.Screen3===true){
														localStorage.clear()
														this.Screen2=true; 
														this.Screen3=false;
											}
								}

        })
        .catch(error=>{
            const evt = new ShowToastEvent
            ({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'Error',
                            mode: 'sticky'
            });
            this.dispatchEvent(evt);
        })
       

    }

    viewNotificationLongText(event){
        const serviceNotificationId = event.target.dataset.id;
       
        if(localStorage.getItem('Responsedata2')===null || localStorage.getItem('Responsedata2')===undefined){
            this.spining1=true;
            const { FSM_Floc__c,FSM_NotificationNumber__c } = this.WorkorderFields;
            sendJobNotification({
                notificationNumber: serviceNotificationId
            })
            .then(data=>{
                if(data.length > 0){
                 this.spining1=false;
                this.wo=data;
                
                localStorage.setItem('Responsedata2', JSON.stringify(this.wo));
                }
                else{
                    this.spining1=false;
                    
                    const evt = new ShowToastEvent
												({
																title: 'Error',
																message:'No Results Found!',
																variant: 'Error',
																mode: 'sticky'
												});
												this.dispatchEvent(evt);
                }
            })
            .catch(error=>{
                
                this.spining1=false;
                this.spining=false;
                const evt = new ShowToastEvent
												({
																title: 'Error',
																message:error.body.message,
																variant: 'Error',
																mode: 'sticky'
												});
												this.dispatchEvent(evt);
            });
        }
        

        
        event.preventDefault();
        const workOrderId = event.target.dataset.id;

        this.Screen3=false;
        this.Screen4=true;
        
    }
    // Handler for Asset Search Button on Screen 1 SFI-1811
		handleClick(event)
		{
				 checkAssetToggle().then(data=>{
						
            if(!data)
						{
                const evt = new ShowToastEvent
												({
																title: 'Information',
																message:'Asset Search interface is not active !',
																variant: 'info',
																mode: 'sticky'
												});
												this.dispatchEvent(evt);
            }
						else{
								this.assetFlag=true;
						}

        })
        .catch(error=>{

        })
       
		}

        handleFinish() {
            // Close the Quick Action
            
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        
}
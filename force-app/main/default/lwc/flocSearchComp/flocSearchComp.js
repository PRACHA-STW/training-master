import { LightningElement,api } from 'lwc';
import fetchWorkOrderRecord from '@salesforce/apex/FSM_AssetRetreiveHistory.getWorkOrderRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FlocSearchComp extends LightningElement
{
		//Property declaration
		@api recordData;
		WorkorderFieldValue='';
		descriptionValue1='';
		returnedData=[];
		Screen1=false;
		Screen3=false;
    
		//making call to auraEnabled apex method
	  connectedCallback(){
				
        this.fetchWOData();
    }
		
		//call to apex controller method to fetch data 
		fetchWOData() 
		{
        //this method calls external system
        fetchWorkOrderRecord({ recordId: this.recordData })
            .then(response => {
                this.WorkorderFieldValue = response.FSM_Floc__c.slice(0,5);
						
            })
            .catch(error => {
                // Handle error
            });
    }
		
		
		//Floc input 
		inputFlocValue(event){
			this.WorkorderFieldValue=event.target.value;
		}
		
		// Floc Description input
		inputDescriptionValue(event){
			this.descriptionValue1=event.target.value;
		}
		
		 // Handle back click
		 handleBackClick(event){
			this.Screen1=true;
		}

		
		//Search for asset data
	  handleSearchClick(event)
		{
							if(this.descriptionValue1.length>2)
							{ 
								
									if(!this.WorkorderFieldValue || this.WorkorderFieldValue.length<5 || !/^\d+$/.test(this.WorkorderFieldValue))
									{
												const evt = new ShowToastEvent({
												title: 'Error',
												message: 'FLOC value must be at least 5 numeric characters long',
												variant: 'error',
												mode: 'sticky'
												});
												this.dispatchEvent(evt);
									}
									else{
												this.Screen3=true;
											
											}
									
								
												
						  }
						  else if(this.descriptionValue1.trim().length>0 && this.descriptionValue1.length < 3){
								
							const evt = new ShowToastEvent({
										title: 'Error',
										message: 'Please ensure you populate with minimum 3 characters in the description input e.g., Pump, Tank etc…',
										variant: 'error',
										mode: 'sticky'
										});
										this.dispatchEvent(evt);

								 }
								 else if((this.WorkorderFieldValue.length===0 || this.WorkorderFieldValue.length<5 || !/^\d+$/.test(this.WorkorderFieldValue)) && this.descriptionValue1.length===0){
									const evt = new ShowToastEvent({
										title: 'Error',
										message: 'FLOC value must be at least 5 numeric characters long',
										variant: 'error',
										mode: 'sticky'
										});
										this.dispatchEvent(evt);
								 }
								 else{
									this.Screen3=true;
								 }
		}
		
		
		
}
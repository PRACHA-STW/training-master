import { LightningElement ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AssetRecordDisplay extends LightningElement
{
				//Property declaration
				@api currentRecordName;
				@api currentRecordDescription;
				WorkorderFieldValue='';
				flocValue1='';
				descriptionValue1='';
				returnedData=[];
				errorText='';
				backToScreen3=false;
				screen5=false;
		
	  		/*connectedCallback(){this.apexDatacall();}
					apexDatacall(){}*/
			
				// getter to pass read only floc value 
				get flocValue(){
						return 'FLOC : '+ this.currentRecordName;
				}
				//Input Despcription value
				inputDescriptionValue(event){
						this.currentRecordDescription=event.target.value;
				}
		
			 //Back to Screen 3 
			 handleBackClick(event){
						this.backToScreen3=true;
			 }
	
			 //Search for level 6 flocs 
		   handleSearchClick(event)
			 {
									if(this.currentRecordDescription.length>2 || this.currentRecordDescription.length===0){
											this.screen5=true;
									}
									else{
												const evt = new ShowToastEvent({
														title: 'Error',
														message: 'Please ensure you populate with minimum 3 characters in the description input e.g., Pump, Tank etc…',
														variant: 'error',
														mode: 'dismissable'
												});
												this.dispatchEvent(evt);

											}
		   }
}
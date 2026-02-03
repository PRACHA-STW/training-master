import { LightningElement,api } from 'lwc';
import calloutFromApex from '@salesforce/apex/FSM_AssetRetreiveHistory.level6Callout';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class FsmFlocLevelSixList extends LightningElement
{
			//Property declaration
			@api flocData;
			@api flocDescription;
			allRecords;
			backToScreen4=false;
			spining=false;
			recordSize=10;
			currenPage=1;
			totalpage;
			visibleRecords;
		  closeAction=false;
		
		//call to imperative method 
		connectedCallback(){
			 this.spining=true;
			 this.apexDatacall();
		}
				
		apexDatacall()
		{
				// callout to external system via imperative method
				 console.log('calling'+this.flocData);
				
								 console.log('calling 2'+this.flocDescription);

			   calloutFromApex({ floc: this.flocData , SubUnitDesc:this.flocDescription})
            		.then(response => {
													this.spining=false;
													this.allRecords =response;
													this.allRecords=response;
						 console.log('level 6 response data --> '+JSON.stringify(this.allRecords));
													this.visibleRecords=this.allRecords.slice(0,this.recordSize);
													this.totalpage=Math.ceil(this.allRecords.length/this.recordSize);
						 							
						 							// handling response returned from imperative method and callout 
													if(response.length==0|| response.length<1 || response==undefined || response==null)
													{							
															  const evt1 = new ShowToastEvent({
																				title: 'Error',
																				message: 'Not all results have been returned from SAP. If asset is not in list, please try different search criteria',
																				variant: 'error',
																				mode: 'dismissable'
																});
																this.dispatchEvent(evt1);
													}
								}).catch(error => {
						 							this.spining=false;
                					const evt = new ShowToastEvent({
																title: 'Error',
																message: error.body.message,
																variant: 'error',
																mode: 'dismissable'
													});
												  this.dispatchEvent(evt);
            	 });
			
		
		}
		//Getter pagination to left
		get leftarrow(){
				return '<<';
		}
		//Getter pagination to right
		get rightarrow(){
			  return '>>';
		}
		
		//Handle Right Pagination 
		handlePagiRight(event)
		{
				if(this.currenPage<this.totalpage)
				{
						this.currenPage=this.currenPage+1;
						const start =(this.currenPage-1)* this.recordSize;
						const end=(this.currenPage*this.recordSize);
						this.visibleRecords=this.allRecords.slice(start,end);
				}
		 }
		
		//Handle Left Pagination 
		handlePagiLeft(event)
		{
				if(this.currenPage>1)
				{
						this.currenPage=this.currenPage-1;
						const start =(this.currenPage-1)* this.recordSize;
						const end=(this.currenPage*this.recordSize);
						this.visibleRecords=this.allRecords.slice(start,end);
				}
		}
		
		
		//Handle Back to screen 4
		handleBack(event){
			this.backToScreen4=true;
		}
		
		//Handle Finish
		handleFinish(event){
				this.closeAction=true;
		}
		
		

}
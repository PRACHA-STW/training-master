import { LightningElement ,api} from 'lwc';
import calloutFromApex from '@salesforce/apex/FSM_AssetRetreiveHistory.level4Callout';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AssetRecordData extends LightningElement
{
		 
		// Property declaration
		@api descriptionData;
		@api flocData;
		errorFlag=false;
	  rowFloc;
		rowDescrip;
	  allRecords;
		flocScreen=false;
		clickedRowFloc;
		clickedRowDesp;
		flag=false;
    Screen4=false;
		spining=false;
		recordSize=10;
		currenPage=1;
		totalpage;
		visibleRecords;
		closeAction=false;
    
		//Callout and data storage for previous button
		connectedCallback(){
			  //	this.spining=true;
				if(localStorage.getItem('Responsedata')===null || localStorage.getItem('Responsedata')===undefined)
				{
						this.spining=true;
						this.apexDatacall();
				}
				else if(localStorage.getItem('Responsedata')){
						
						this.allRecords=JSON.parse(localStorage.getItem('Responsedata'))
						 //this.spining=false;
						this.visibleRecords=this.allRecords.slice(0,this.recordSize);
						
						this.totalpage=Math.ceil(this.allRecords.length/this.recordSize);
				}
				
		}
		
		//Disconnected callback to clear local storage
		disconnectedCallback()
		{  
				localStorage.clear()
		}
		
		//getter's for pagination symbol
		get leftarrow(){
				return '<<';
		}
		get rightarrow(){
				return '>>';
		}
				
		//Js method making callout to apex  method
		apexDatacall()
		{
							 if(!localStorage.getItem('Responsedata'))
							 {
										//apex method for Making callout to external system
										 calloutFromApex({ floc: this.flocData , description:this.descriptionData})
										 .then(response => {
															
												 			//Apex callout response/error handler
															if(response.length==0|| response.length<1 || response==undefined || response==null)
															{
																	 this.spining=false;
																	 const evt1 = new ShowToastEvent({
																				title: 'Error',
																				message: 'Unable to find a result please try a different search criteria',
																				variant: 'error',
																				mode: 'sticky'
																		});
																		this.dispatchEvent(evt1);

															}
															else{
																console.log('111111111111111111'+JSON.stringify(response))
																		 this.spining=false;
																		 this.allRecords=response;
																	  console.log('all records list '+ JSON.stringify(this.allRecords));
																		 this.visibleRecords=this.allRecords.slice(0,this.recordSize);
															    console.log('22222222222222222'+this.visibleRecords);
																		 this.totalpage=Math.ceil(this.allRecords.length/this.recordSize);
																		 localStorage.setItem('Responsedata', JSON.stringify(this.allRecords));

																	}


											 }).catch(error =>{
												
																this.spining=false;
																const evt = new ShowToastEvent
																({
																				title: 'Error',
																				message: error.body.message,
																				variant: 'Error',
																				mode: 'sticky'
																});
																this.dispatchEvent(evt);

											});
							}
							else{
										this.spining=false;
										const evt2 = new ShowToastEvent({
																title: 'Error',
																message: error.body.message,
																variant: 'error',
																mode: 'sticky'
													});
										this.dispatchEvent(evt2);

									}
    }
		
		//Action Click button
		handleClick(event)
		{

				    console.log('dta ste --> '+event.currentTarget.dataset.value)
						const rowIdva=event.currentTarget.dataset.value;
					  console.log('rwo id --> '+rowIdva);
		
					for (let i = 0; i < this.allRecords.length; i++)
					{
						
									if (this.allRecords[i].streamId==rowIdva)
									{
											this.clickedRowFloc=this.allRecords[i].streamId;
											this.clickedRowDesp=this.allRecords[i].flocDesp;
											this.flag=true;

									}
									if(this.flag===true)
										break;
				 }
				if(this.flag===true){
					 this.Screen4=true;
				}
			
						
    }
		
		//Handle back button
		handleBack(event)
		{
			localStorage.clear()
			this.flocScreen=true;
			
		}
		
		//Handle Finish Button
		handleFinish(){
		 this.closeAction=true;
		}
		
		//Handle right pagination
		handlePagiRight(event)
		{
				if(this.currenPage<this.totalpage)
				{
						this.currenPage=this.currenPage +1;
						const start =(this.currenPage-1)* this.recordSize;
						const end=(this.currenPage*this.recordSize);
						this.visibleRecords=this.allRecords.slice(start,end);
				}
		   
		
		}
		
		//Handle Left pagination
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
		
		
		
				
		
}
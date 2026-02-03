import { LightningElement, api, track, wire } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DCFINFRA_OBJECT from '@salesforce/schema/FSM_DataCaptureFormInfra__c';



export default class InfraFollowonWorkRequest extends LightningElement {
map;
@track objectInfo;
errormessage;
submitValues = {};
errormessages=[];
isdiffaddrr;
@track gridproposedworkx;
lastpage=false;
@track gridproposedworky;
landcomm;
diffaddr;
occname;
location;
occtelno;
occhseno;
occstreet;
occstown;
occcity;
occpostcode;
occlocation;
proformasigned;
permissiondig;
assetinp;
taskinp;
techniqueinp;
sizeinp;
materialinp;
assetuuid;
gridxerror;
gridyerror;
diffaddress;
permissiontodigreq;
isvalidscreenone=true;
isnotatdiffadrr=true;
sectionone=true;
sectiontwo=false;
sectionthree=false;
sectionfour=false;
sectionfive=false;
prevdisabled=true;
nextdisabled=false;
isvalidscreentwo=true;
isvalidscreenfour=true;
islocrestrictedland=true;
objectApiName=DCFINFRA_OBJECT;
isInputsoneCorrect;

savesectiononevalues() {
            
    var inp=this.template.querySelectorAll("lightning-input-field");
   inp.forEach(element => {
   // console.log(JSON.stringify(element))
    // if(element.fieldName=="FSM_GridRefOfProposedWorkX__c"){
    //                 this.gridproposedworkx=element.value;
    //                 this.submitValues.FSM_GridRefOfProposedWorkX__c=this.gridproposedworkx;
    //                 console.log('SUBMITVALUES '+JSON.stringify(this.submitValues));
    // }
  
//     inp.forEach(function(element, index){
//      console.log("inp --->> ",typeof element.fieldName,index)
//             console.log(element.fieldName + " = " + element.value);
//             const key = element.fieldName
//             try {
//                 this.obj.test = "test"
//                 this.obj.abc = element.value
//             } catch (error) {
//                 console.log(error)
//             }

            
          
        if(element.fieldName=="FSM_GridRefOfProposedWorkX__c"){
            this.gridproposedworkx=element.value;
             this.submitValues.FSM_GridRefOfProposedWorkX__c=this.gridproposedworkx;
            //this.submitValues.FSM_GridRefOfProposedWorkX__c=element.value;
        } else if(element.fieldName=="FSM_GridRefOfProposedWorkY__c"){
        this.gridproposedworky=element.value;
        this.submitValues.FSM_GridRefOfProposedWorkY__c=this.gridproposedworky;
        }else if(element.fieldName=="FSM_SFWIsThisAtADifferentAddress__c"){
            this.diffaddress=element.value;
            this.submitValues.FSM_SFWIsThisAtADifferentAddress__c=this.diffaddress;
        }else if(element.fieldName=="FSM_OccupiersName__c"){
                this.occname=element.value;
                this.submitValues.FSM_OccupiersName__c=this.occname;
        }else if(element.fieldName=="FSM_OccupiersTelephoneNumber__c"){
        this.occtelno=element.value;
        this.submitValues.FSM_OccupiersTelephoneNumber__c=this.occtelno;
        }else if(element.fieldName=="FSM_OccupiersHouseNo__c"){
        this.occhseno=element.value;
        this.submitValues.FSM_OccupiersHouseNo__c=this.occhseno;
        }else if(element.fieldName=="FSM_OccupiersStreet__c"){
        this.occstreet=element.value;
        this.submitValues.FSM_OccupiersStreet__c=this.occstreet;
        }else if(element.fieldName=="FSM_OccupiersTown__c"){
        this.occstown=element.value;
        this.submitValues.FSM_OccupiersTown__c=this.occstown;
        }else if(element.fieldName=="FSM_OccupiersCity__c"){
        this.occcity=element.value;
        this.submitValues.FSM_OccupiersCity__c=this.occcity;
        }else if(element.fieldName=="FSM_OccupiersPostcode__c"){
        this.occpostcode=element.value;
        this.submitValues.FSM_OccupiersPostcode__c=this.occpostcode;
        }else if(element.fieldName=="FSM_Location__c"){
        this.occlocation=element.value;
        this.submitValues.FSM_LandComments__c=this.occlocation;
        }else if(element.fieldName=="FSM_LandComments__c"){
            this.landcomm=element.value;
            this.submitValues.FSM_LandComments__c=this.landcomm;
            }else if(element.fieldName=="FSM_PermissionToDigRequired__c"){
        this.permissiontodigreq=element.value;
        this.submitValues.FSM_PermissionToDigRequired__c=this.permissiontodigreq;
        }else if(element.fieldName=="FSM_WhichProformaSigned__c"){
        this.proformasigned=element.value;
        this.submitValues.FSM_WhichProformaSigned__c=this.proformasigned;
        }else if(element.fieldName=="FSM_PermissionToDig__c"){
        this.permissiondig=element.value;
        this.submitValues.FSM_PermissionToDig__c=this.permissiondig;
        }else if(element.fieldName=="FSM_AssetUID__c"){
            this.assetuuid=element.value;
            this.submitValues.FSM_AssetUID__c=this.assetuuid;
            
            }else if(element.fieldName=="FSM_Asset__c"){
                this.assetinp=element.value;
                this.submitValues.FSM_Asset__c=this.assetinp;
                }else if(element.fieldName=="FSM_Task__c"){
                    this.taskinp=element.value;
                    this.submitValues.FSM_Task__c=this.taskinp;
                    }else if(element.fieldName=="FSM_Technique__c"){
                    this.techniqueinp=element.value;
                    this.submitValues.FSM_Technique__c=this.techniqueinp;
                    }else if(element.fieldName=="FSM_AssetSize__c"){
                    this.sizeinp=element.value;
                    this.submitValues.FSM_AssetSize__c=this.sizeinp;
                    }else if(element.fieldName=="FSM_AssetMaterial__c"){
                        this.materialinp=element.value;
                        this.submitValues.FSM_AssetMaterial__c=this.materialinp;
                        }
        //console.log('object '+this.submitValues);
        console.log('string '+JSON.stringify(this.submitValues));
});
//     });
//    console.log('new obj',this.obj);
    //this.handlesectiononevalidation();
   
 //   this.dispatchEvent(evt);

}
handlesectiononevalidation(){
    this.isvalidscreenone=true;
    let gridxvalid = this.template.querySelector(".gridx");
    let gridyvalid = this.template.querySelector(".gridy");
    this.errormessages=[];
  
   if(gridxvalid.value < 240000 || gridxvalid.value > 550000 || gridxvalid.value=='' || gridxvalid.value==null){
    console.log('inside gridxvalue');
        this.gridxerror = 'Validations for following fields have failed. Please fill it appropriately. Grid X should lie between 240000 and 550000';
        this.errormessages.push(this.gridxerror);
        this.isvalidscreenone=false;
        
        //console.log('gridxvalid.value'+gridxvalid.value+' '+this.gridxerror);
       // this.submitValues.FSM_GridRefOfProposedWorkX__c=gridxvalid.value;
       // console.log('SUBMITVALUES in validation'+JSON.stringify(this.submitValues));
   // gridxvalid.reportValidity();
    }
    //else{
//     this.isvalidscreenone=true;
//    }
   if(gridyvalid.value < 170000 || gridyvalid.value > 440001 || gridyvalid.value=='' || gridxvalid.value==null){
    
    this.gridyerror = 'Validations for following fields have failed. Please fill it appropriately.Grid Y should lie between 170000 and 440000';
    //console.log('inside gridyvalue'+this.gridyerror);
    this.errormessages.push(this.gridyerror);
    this.isvalidscreenone=false;
    console.log('error array '+this.errormessages);
   }
//    else{
//     this.isvalidscreenone=true;
//    }
   console.log('error array '+this.errormessages);
}

handlesectiontwovalidation(){
    this.isvalidscreentwo=true;
    this.errormessages=[];
    
    let occname = this.template.querySelector(".occname");
    let occtelno = this.template.querySelector(".occtelno");
    let occhseno = this.template.querySelector(".occhseno");
    let occstreet = this.template.querySelector(".occstreet");
    let occtown = this.template.querySelector(".occtown");
    let occcity = this.template.querySelector(".occcity");
    let occpostcode = this.template.querySelector(".occpostcode");
    let proformasigned=this.template.querySelector(".proformasigned");
    let oname=occname.value;
    if(oname?.length >80)
    {
        this.errormessages.push('Occupers name should be 80 - characters max');
        this.isvalidscreentwo=false;
    }else {
      //  this.isvalidscreentwo=true;
    }
    
    if(occtelno.value.length>11 ||occtelno.value.length<11 ){
        this.isvalidscreentwo=false;
        this.errormessages.push('Occupiers telephone no should be Min 11 Max 11 numbers');
    }else{
       // this.isvalidscreentwo=true;
    } 
    
    if(occhseno.value.length>10){
        this.isvalidscreentwo=false;
        this.errormessages.push('Occupiers house number should be Max 10 numbers');
    }else{
        //this.isvalidscreentwo=true;
    }
     if(occstreet.value.length>60 || occstreet.value=='' || occstreet.value==null){
        this.isvalidscreentwo=false;
        this.errormessages.push('Occupiers Street should be 60 Max characters');
    }else
    {
       // this.isvalidscreentwo=true;
    } if(occtown.value.length>40 || occtown.value=='' || occtown.value==null){
        this.isvalidscreentwo=false;
        this.errormessages.push('Occupiers Town should be 40 Max characters');
    }else
    {
       // this.isvalidscreentwo=true;
    } if(occcity.value.length>40 || occcity.value=='' || occcity.value==null){
        this.isvalidscreentwo=false;
        this.errormessages.push('Occupiers City should be 40 Max characters');
    }else{
       // this.isvalidscreentwo=true;
    } if(occpostcode.value.length>10 || occpostcode.value=='' ||  occpostcode.value==null){
        this.isvalidscreentwo=false;
        this.errormessages.push('Occupiers postcode should be 10 Max characters');
    }else{
        //this.isvalidscreentwo=true;
    } if(proformasigned.value.length>20 || proformasigned.value=='' || proformasigned.value==null){
        this.isvalidscreentwo=false;
        this.errormessages.push('20 Max characters allowed for field proformasigned');
    }else{
       // this.isvalidscreentwo=true;
    }
   
    
}
handlesectionfourvalidation(){
    this.errormessages=[];
    this.isvalidscreenfour=true;
    this.errormessages=[];
    let uid = this.template.querySelector(".assetuidcls");
    let size = this.template.querySelector(".sizecls");
    let task = this.template.querySelector(".taskcls");
    let technique = this.template.querySelector(".techniquecls");
    let asset = this.template.querySelector(".assetcls");
    let material = this.template.querySelector(".materialcls");

    if(material.value=='' ||  material.value==null){
       
        this.errormessages.push('Please select a value in Material');
        console.log('this.errormessages'+this.errormessages);
        this.isvalidscreenfour=false;
    }
    if(size.value=='' ||  size.value==null){
    
        this.errormessages.push('Please select a value in Size');
        console.log('this.errormessages'+this.errormessages);
        this.isvalidscreenfour=false;
    }
    if(task.value=='' ||  task.value==null){
        
        this.errormessages.push('Please select a value in Task');
        console.log('this.errormessages'+this.errormessages);
        this.isvalidscreenfour=false;
    }
    if(technique.value=='' ||  technique.value==null){
        
        this.errormessages.push('Please select a value in Technique');
        console.log('this.errormessages'+this.errormessages);
        this.isvalidscreenfour=false;
    }
    if(asset.value=='' ||  asset.value==null){
        
        this.errormessages.push('Please select a value in Asset');
        console.log('this.errormessages'+this.errormessages);
        this.isvalidscreenfour=false;
    }if(uid.value != null && uid.value.length > 40){
        
        this.errormessages.push('Asset UID should be 40 Max characters');
        console.log('this.errormessages'+this.errormessages);
        this.isvalidscreenfour=false;
    }
    console.log('this.errormessages'+this.errormessages);
}
handlePrevious() {
    if (this.sectionone) {
       
        return; // already at the first component, do nothing
    } else if (this.sectiontwo) {
        this.savesectiononevalues();
        this.errormessages=[];
        this.sectionone = true;
        this.sectiontwo = false;
        this.sectionthree=false;
        this.sectionfour=false;
        this.sectionfive=false;
    } else if (this.sectionthree) {
        this.savesectiononevalues();
        this.errormessages=[];
        this.sectiontwo = true;
        this.sectionthree = false;
        this.sectionone=false;
        this.sectionfour=false;
        this.sectionfive=false;
       }else if(this.sectionfour){
        this.errormessages=[];
        this.sectiontwo = false;
        this.sectionthree = true;
        this.sectionone=false;
        this.sectionfour=false;
        this.sectionfive=false;
       }else if(this.sectionfive){
        //this.nextdisabled=true;
        this.errormessages=[];
        this.sectiontwo = false;
        this.sectionthree = false;
        this.sectionone=false;
        this.sectionfour=true;
        this.sectionfive=false;
       }
   }

   handleNext() {
    if (this.sectionone) {
        this.savesectiononevalues();
        //this.validateFields();
        this.handlesectiononevalidation();
        
        if(this.isvalidscreenone){
            
            this.sectionone = false;
            this.sectiontwo = true;
            this.sectionthree=false;
            this.sectionfour=false;
            this.sectionfive=false;
            
        }else{
            console.log('error in sec one');
            //this.ShowToastEvent("test error");
        }
       
       } else if (this.sectiontwo) {
       // let workatdiffaddr = this.template.querySelector(".occname");
       this.savesectiononevalues();
       console.log('isdiffaddrr'+this.isdiffaddrr);
       if(this.isdiffaddrr)
       {
        this.handlesectiontwovalidation();

       }else{
        this.isvalidscreentwo=true;
       }
       if(this.isvalidscreentwo){
        
        this.sectionthree = true;
        this.sectiontwo = false;
        this.sectionone = false;
        this.sectionfour=false;
        this.sectionfive=false;
        this.savesectiononevalues();
        }else{
            console.log('error in sec two');
        }
       } else if (this.sectionthree) {
        this.savesectiononevalues();
       
    
            this.sectionthree = false;
            this.sectiontwo = false;
            this.sectionone = false;
            this.sectionfour=true;
            this.sectionfive=false;
       
      }else if(this.sectionfour){
        this.savesectiononevalues();
        this.handlesectionfourvalidation();
        if(this.isvalidscreenfour)
        {
            
            this.sectiontwo = false;
            this.sectionthree = false;
            this.sectionone=false;
            this.sectionfour=false;
            this.sectionfive=true;
            this.lastpage=true;
           // this.sendvaluestophotocapture();
        }
    else{
        console.log('error in secfour')
    }
        
       }else if(this.sectionfive){
        //this.nextdisabled=true;
       
        return;
       }
  }
  get isEnableNext(){
    if(this.sectionfive != true){
        return true;
    }
    else{
        return false;
    }
}
get isEnablePrev(){
    if(this.sectionone != true){
        return true;
    }
    else{
        return false;
    }

}

handleaddresschange(event){
    this.isdiffaddrr = event.detail.checked;
    console.log('is diff address'+this.isdiffaddrr);
    if(this.isdiffaddrr)
    {
        this.isnotatdiffadrr=false;
    }else{
        this.isnotatdiffadrr=true;
        this.occname='';
        this.occtelno='';
        this.occcity='';
        this.occhseno='';
        this.occlocation='';
        this.occpostcode='';
        this.occstown='';
        this.occstreet='';
        
    }
}
handlelocationchange(event){
    this.location = event.detail.value;
    if(this.location=='Restricted Land')
    {
        this.islocrestrictedland=false;
    }
else{
    this.islocrestrictedland=true;
}
}
ShowToastEvent(error) {
    const event = new ShowToastEvent({
        title: 'Please fill in appropriate details',
        message: `${error}\n111\n2222\n3333`,
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(event);
    

}
handleassetchange(){

}
handletaskchange(){

}
handletechniquechange(){
    
}
handlesizechange(){
    
}
handlematerialchange(){
    
}
validateFields() {
    return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
        // Return whether all fields up to this point are valid and whether current field is valid
        // reportValidity returns validity and also displays/clear message on element based on validity
        field.reportValidity();
        return validSoFar && field.checkValidity();
        //return (validSoFar && field.reportValidity());
    }, true);
}
sendvaluestophotocapture(){
    const event = new CustomEvent('finalsubmit', {
    // detail contains only primitives
    detail: this.submitValues
    });
    this.dispatchEvent(event);
    }
    handleclose(e) {
        // Close the modal window and display a success toast
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Opportunity Record Updated!',
                variant: 'success'
            })
        );
   }

}
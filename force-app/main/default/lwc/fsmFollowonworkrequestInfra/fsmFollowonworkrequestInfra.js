import { LightningElement,api, track, wire } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DCFINFRA_OBJECT from '@salesforce/schema/FSM_DataCaptureFormInfra__c';
import FSM_DCFLineItemInfraOBJECT from '@salesforce/schema/FSM_DCFLineItemInfra__c';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FSM_DCFDependantPicklist__c from '@salesforce/schema/FSM_DCFDependantPicklist__c';
import getdependentpicklistRecord from '@salesforce/apex/FSM_DependantPicklistcls.getDependentPicklistrecord';
//import senddatatoapex from '@salesforce/apex/checkrecordsoffline.datafromlwc';


export default class InfraFollowonWorkRequest extends LightningElement {
   
        map;
        @api recordId;
        isDone = false;
        retainvaluestochild;
        storetabledata;
        isLoading = false;
        senddatatotmacmp;
        @track objectInfo;
        errormessage;
        submitValues = {};
        errormessages=[];
        datastoredtable=[];
        isdiffaddrr;
        occhsename;
        @track gridproposedworkx;
        lastpage=false;
        @track gridproposedworky;
        landcomm;
        diffaddr;
        occname;
        location;
        occtelno;
        dcflineitemrectypid;
        occhseno;
        occstreet;
        occstown;
        occcity;
        retainchildvalues;
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
        enablesecsixofchild=false;
        isnotatdiffadrr=true;
        sectionone=true;
        sectiontwo=false;
        sectionthree=false;
        sectionfour=false;
        sectionfive=false;
        sectionsix=false;
        sectionseven=false;
        sectioneight=false;
        sectionnine=false;
        sectionten=false;
        sectioneleven=false;
        sectiontwelve=false;
        sectionthirteen=false;
        sectionboppsone=false;
        sectionboppstwo=false;
        prevdisabled=true;
        nextdisabled=false;
        isvalidscreentwo=true;
        isvalidscreenfour=true;
        isvalidscreenfive=true;
        isvalidscreensix=true;
        isvalidscreenseven=true;
        isvalidscreennine=true;
        isvalidsectionten=true;
        islocrestrictedland=true;
        issubmitenable=false;
        iscontaminationyes=false;
        ispollutionyes=false;
        isshutoff;
        estimatedproperties;
        altsupplies;
        sensitivecustonshuttdown;
        thirdpartydmge='No';
        objectApiName=DCFINFRA_OBJECT;
        isInputsoneCorrect;
        estloc;
        leakquant;
        meterserial;
        meterreading;
        accessissues;
        mon;
        tues;
        wed;
        thurs;
        fri;
        sat;
        sun;
        restrictedtime;
        powerlines;
        boopsteam;
        disabledboopsteam;
        excavation;
        leaktype;
        reason;
        trailer;
        letterwarn;
        sensitivecustomer;
        gangcomm;
        isaccessissuesyes=false;
        overheadpowerlines='No';
        lampsupport='No';
        confinedspace='No';
        additionalinfo;
        schedulingcomm;
        contamination;
        contaminationcomm;
        pollution;
        pollutioncomm;
        risk;
        riskenv;
        selshutoffoperation;
        isshutofforvalvesel=false;
        @api objectName = 'FSM_DCFDependantPicklist__c';
        @track fieldLabel;
        @api recordTypeId;
        @api value;
        @track optionsasset;
        @track optionstask;
        @track optionsmaterial;
        @track optionstechnique;
        @track optionssize;
        @track assetvaluesarr = [];
        @track taskvaluesarr = [];
        @track techvaluesarr = [];
        @track sizevaluesarr = [];
        @track materialvaluesarr = [];
        @track alltaskvaluesarr = [];
        @track allTechValuesArr = [];
        @track allSizeValuesArr = [];
        @track allMaterialValuesArr = [];
        sourceList = []
        selectedasset;
        seltask;
        selectedtechnique;
        selmaterial;
        selsize;
        dcfdependentpicklist1;
        dcfrectypid;
        arrFilteredRecords = []
    
        apiFieldName;
        @track error;
        @api isprevfromnextcmp;
        //table variables
        @track data = [{ id: 1, FSM_ValvesIDIdentifiedOnSketch__c: '', FSM_ProposedOp__c: '',FSM_ValveChecked__c:'',FSM_GridRefX__c:'',FSM_GridRefY__c:'',FSM_CommentsForAllValves__c:'' }];
        @track proposedoparr = [];
        @track valvescheckedarr = [];
        isValid=true;
        dcflineitemdata;
        retainparentdcfdata;
        dcfinfralineitemdata;
        dcfinfrarecorddata;
        hasRendered=false;
//fetch dcf infra recordtypeid
        @wire(getObjectInfo, { objectApiName: DCFINFRA_OBJECT })
        getobjdata({data,error}){
            if(data){
                let recmap=JSON.parse(JSON.stringify(data.recordTypeInfos));
                
                this.dcfrectypid=Object.keys( recmap ).find( recTyp => recmap[ recTyp ].name === 'Infra Follow On Work Request' );
            }
        }

        //fetch dcf line item infra recordtypeid
        @wire(getObjectInfo, { objectApiName: FSM_DCFLineItemInfraOBJECT })
        getdcflineitemobjdata({data,error}){
            if(data){
                let recmaplineitem=JSON.parse(JSON.stringify(data.recordTypeInfos));
                
                this.dcflineitemrectypid=Object.keys( recmaplineitem ).find( recTyp => recmaplineitem[ recTyp ].name === 'Proposed Valve Operation' );
                
            }
        }

        connectedCallback(){
         console.log('inside connected callback fsmfwr');
       
            if(!!JSON.stringify(this.isprevfromnextcmp))
            {
                console.log('data in connected callback parent fwr',JSON.stringify(this.isprevfromnextcmp));
                this.handlepreviousfromfwr(this.isprevfromnextcmp); 
                this.hasRendered=true;
                this.isDone=true;
                
            }
        }
        renderedCallback(){
            if(this.hasRendered)
            {
                return;
            }
            setTimeout(() => {
                this.isDone=true;
                this.hasRendered = true;
            }, 2000);
           
            
        }
       
        savesectiononevalues() {
                    
            var inp=this.template.querySelectorAll("lightning-input-field");
           inp.forEach(element => {
         
                if(element.fieldName=="FSM_GridRefOfProposedWorkX__c"){
                    this.gridproposedworkx=element.value;
                     this.submitValues.FSM_GridRefOfProposedWorkX__c=this.gridproposedworkx;
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
                this.submitValues.FSM_OccupiersName__c=this.occname;
            }else if(element.fieldName=="FSM_OccupiersHouseName__c"){
            this.occhsename=element.value;
            this.submitValues.FSM_OccupiersHouseName__c=this.occhsename;
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
                this.selectedasset=element.value;
                this.submitValues.FSM_Asset__c=this.selectedasset;
               }else if(element.fieldName=="FSM_ESTLocation__c"){
                    this.estloc=element.value;
                    this.submitValues.FSM_ESTLocation__c=this.estloc;
                }else if(element.fieldName=="FSM_LeakQuantified__c"){
                    this.leakquant=element.value;
                    this.submitValues.FSM_LeakQuantified__c=this.leakquant;
                }else if(element.fieldName=="FSM_MeterSerial__c"){
                        this.meterserial=element.value;
                        this.submitValues.FSM_MeterSerial__c=this.meterserial;
                }else if(element.fieldName=="FSM_MeterReading__c"){
                    this.meterreading=element.value;
                    this.submitValues.FSM_MeterReading__c=this.meterreading;
                }else if(element.fieldName=="FSM_AccessRestricted__c"){
                    this.accessissues=element.value;
                    this.submitValues.FSM_AccessRestricted__c=this.accessissues;
                }else if(element.fieldName=="FSM_Monday__c"){
                    this.mon=element.value;
                    this.submitValues.FSM_Monday__c=this.mon;
                }else if(element.fieldName=="FSM_Tuesday__c"){
                    this.tues=element.value;
                    this.submitValues.FSM_Tuesday__c=this.tues;
                }else if(element.fieldName=="FSM_Wednesday__c"){
                    this.wed=element.value;
                    this.submitValues.FSM_Wednesday__c=this.wed;
                }else if(element.fieldName=="FSM_Thursday__c"){
                    this.thurs=element.value;
                    this.submitValues.FSM_Thursday__c=this.thurs;
                }else if(element.fieldName=="FSM_Friday__c"){
                    this.fri=element.value;
                    this.submitValues.FSM_Friday__c=this.fri;
                }else if(element.fieldName=="FSM_Saturday__c"){
                    this.sat=element.value;
                    this.submitValues.FSM_Saturday__c=this.sat;
                }else if(element.fieldName=="FSM_Sunday__c"){
                    this.sun=element.value;
                    this.submitValues.FSM_Sunday__c=this.sun;
                }else if(element.fieldName=="FSM_RestrictedTime__c"){
                    this.restrictedtime=element.value;
                    this.submitValues.FSM_RestrictedTime__c=this.restrictedtime;
                }else if(element.fieldName=="FSM_OverheadPowerLinesWithin10m__c"){
                    this.powerlines=element.value;
                    this.submitValues.FSM_OverheadPowerLinesWithin10m__c=this.powerlines;
                }else if(element.fieldName=="FSM_CommentsForBoppsTeam__c"){
                    this.boopsteam=element.value;
                    this.submitValues.FSM_CommentsForBoppsTeam__c=this.boopsteam;
                }else if(element.fieldName=="FSM_IsExcavationRequired__c"){
                    this.excavation=element.value;
                    this.submitValues.FSM_IsExcavationRequired__c=this.excavation;
                }else if(element.fieldName=="FSM_TypeOfLeak__c"){
                    this.leaktype=element.value;
                    this.submitValues.FSM_TypeOfLeak__c=this.leaktype;
                }else if(element.fieldName=="FSM_ReasonForFirstTimeReinstatement__c"){
                    this.reason=element.value;
                    this.submitValues.FSM_ReasonForFirstTimeReinstatement__c=this.reason;
                }else if(element.fieldName=="FSM_TrailerTeam__c"){
                    this.trailer=element.value;
                    this.submitValues.FSM_TrailerTeam__c=this.trailer;
                }else if(element.fieldName=="FSM_LetterWarn__c"){
                    this.letterwarn=element.value;
                    this.submitValues.FSM_LetterWarn__c=this.letterwarn;
                }else if(element.fieldName=="FSM_SensitiveCustomer__c"){
                    this.sensitivecustomer=element.value;
                    this.submitValues.FSM_SensitiveCustomer__c=this.sensitivecustomer;
                }else if(element.fieldName=="FSM_CommentsForTheGangs__c"){
                    this.gangcomm=element.value;
                    this.submitValues.FSM_CommentsForTheGangs__c=this.gangcomm;
                    }else if(element.fieldName=="FSM_OverheadPowerLinesWithin10m__c"){
                    this.overheadpowerlines=element.value;
                    this.submitValues.FSM_OverheadPowerLinesWithin10m__c=this.overheadpowerlines;
                    }else if(element.fieldName=="FSM_LampSupportRemovalRequired__c"){
                    this.lampsupport=element.value;
                    this.submitValues.FSM_LampSupportRemovalRequired__c=this.lampsupport;
                }else if(element.fieldName=="FSM_ConfinedSpaceWorking__c"){
                    this.confinedspace=element.value;
                    this.submitValues.FSM_ConfinedSpaceWorking__c=this.confinedspace;
                    }else if(element.fieldName=="FSM_DetailsSafetyInformation__c"){
                    this.additionalinfo=element.value;
                    this.submitValues.FSM_DetailsSafetyInformation__c=this.additionalinfo;
                    }else if(element.fieldName=="FSM_SchedulingCommentsBox__c"){
                    this.schedulingcomm=element.value;
                    this.submitValues.FSM_SchedulingCommentsBox__c=this.schedulingcomm;
                }

                else if(element.fieldName=="FSM_Contamination__c"){
                    this.contamination=element.value;
                    this.submitValues.FSM_Contamination__c=this.contamination;
                }else if(element.fieldName=="FSM_ContaminationComments__c"){
                    this.contaminationcomm=element.value;
                    this.submitValues.FSM_ContaminationComments__c=this.contaminationcomm;
                }else if(element.fieldName=="FSM_IsThereConfirmedPollution__c"){
                    this.pollution=element.value;
                    this.submitValues.FSM_IsThereConfirmedPollution__c=this.pollution;
                }else if(element.fieldName=="FSM_ConfirmedPollutionComments__c"){
                    this.pollutioncomm=element.value;
                    this.submitValues.FSM_ConfirmedPollutionComments__c=this.pollutioncomm;
                }else if(element.fieldName=="FSM_IsThereARiskOfPollutionOccurring__c"){
                    this.risk=element.value;
                    this.submitValues.FSM_IsThereARiskOfPollutionOccurring__c=this.risk;
                }else if(element.fieldName=="FSM_RiskToAnEnvironmentalSite__c"){
                    this.riskenv=element.value;
                    this.submitValues.FSM_RiskToAnEnvironmentalSite__c=this.riskenv;
                }else if(element.fieldName=="FSM_IsShutOffOrValveOperationRequired__c"){
                    this.isshutoff=element.value;
                    this.submitValues.FSM_IsShutOffOrValveOperationRequired__c=this.isshutoff;
                }else if(element.fieldName=="FSM_EstimatedNoOfPropertiesAffected__c"){
                    this.estimatedproperties=element.value;
                    this.submitValues.FSM_EstimatedNoOfPropertiesAffected__c=this.estimatedproperties;
                }else if(element.fieldName=="FSM_AlternativeSuppliesRequired__c"){
                    this.altsupplies=element.value;
                    this.submitValues.FSM_AlternativeSuppliesRequired__c=this.altsupplies;
                }else if(element.fieldName=="FSM_SensitiveCustomersOnShutdown__c"){
                    this.sensitivecustonshuttdown=element.value;
                    this.submitValues.FSM_SensitiveCustomersOnShutdown__c=this.sensitivecustonshuttdown;
                }else if(element.fieldName=="FSM_ThirdPartyDamageOccurOnThisSite__c"){
                    this.thirdpartydmge=element.value;
                    this.submitValues.FSM_ThirdPartyDamageOccurOnThisSite__c=this.thirdpartydmge;
                }
                    this.submitValues.RecordTypeId= this.dcfrectypid;
                    this.submitValues.FSM_WorkOrder__c=this.recordId;
                    
        });
   
        }

        passdatatoapex(){
        //     let datatoapex=JSON.parse(JSON.stringify(this.submitValues));
         
        //     senddatatoapex({dcfdataobj:datatoapex})
        // .then(result => {
          
        // }) .catch(error => {
          
        //     this.error = error;
        // }); 
    }




        handlesectiononevalidation(){
            this.isvalidscreenone=true;
            let gridxvalid = this.template.querySelector(".gridx");
            let gridyvalid = this.template.querySelector(".gridy");
            this.errormessages=[];
          
           if(gridxvalid.value < 240000 || gridxvalid.value > 550000 || gridxvalid.value=='' || gridxvalid.value==null){
          
                this.gridxerror = 'Grid X should lie between 240000 and 550000';
                this.errormessages.push(this.gridxerror);
                this.isvalidscreenone=false;

            }
        
           if(gridyvalid.value < 170000 || gridyvalid.value > 440001 || gridyvalid.value=='' || gridxvalid.value==null){
            
            this.gridyerror = 'Grid Y should lie between 170000 and 440000';

            this.errormessages.push(this.gridyerror);
            this.isvalidscreenone=false;
           }
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
            let locvalue=this.template.querySelector(".locationcls")
            let preq=this.template.querySelector(".permissionreq");
            let pdig=this.template.querySelector(".permissiontodig");
         
           
             if(occstreet.value==null || occstreet.value.length>60 || occstreet.value==''){
              
                this.isvalidscreentwo=false;
                this.errormessages.push('Occupiers Street should be 60 Max characters');

            }
        
             if(occcity.value==null || occcity.value.length>40 || occcity.value==''){
                this.isvalidscreentwo=false;
                this.errormessages.push('Occupiers City should be 40 Max characters');
            }
             if(occpostcode.value==null || occpostcode.value.length>10){
                this.isvalidscreentwo=false;
                this.errormessages.push('Occupiers postcode should be 10 Max characters');
            }
             if(proformasigned.value==null || proformasigned.value.length>20 || proformasigned.value=='' ){
                this.isvalidscreentwo=false;
                this.errormessages.push('20 Max characters allowed for field proformasigned');
            }
            if(locvalue.value==null || locvalue.value==''){
                this.isvalidscreentwo=false;
                this.errormessages.push('Please fill in value in Location');
            }

            if(pdig.value==null || pdig.value==''){
                this.isvalidscreentwo=false;
                this.errormessages.push('Please fill in value in Permission to dig');
        }
            
            if(preq.value==null || preq.value=='' || preq.value=='--None--'){
                this.isvalidscreentwo=false;
                this.errormessages.push('Please fill in value in Permission to required');
            }
            if(oname?.length >80)
            {
                this.errormessages.push('Occupers name should be 80 - characters max');
                this.isvalidscreentwo=false;
                
            }
            
            if(occtelno.value.length >11 ||occtelno.value.length < 11 ){
                this.isvalidscreentwo=false;
                this.errormessages.push('Occupiers telephone no should be Min 11 Max 11 numbers');
            }
            if(occhseno.value.length>10){
                this.isvalidscreentwo=false;
                this.errormessages.push('Occupiers house number should be Max 10 numbers');
            }

        
        }
        handlesectionfourvalidation(){
            this.errormessages=[];
            this.isvalidscreenfour=true;
           // this.errormessages=[];
            let uid = this.template.querySelector(".assetuidcls");
            let size = this.template.querySelector(".sizecls");
            let task = this.template.querySelector(".taskcls");
            let technique = this.template.querySelector(".techniquecls");
            let asset = this.template.querySelector(".assetcls");
            let material = this.template.querySelector(".materialcls");
        
            if(material.value=='' ||  material.value==null){
               
                this.errormessages.push('Please select a value in Material');
               
                this.isvalidscreenfour=false;
            }
            if(size.value=='' ||  size.value==null){
            
                this.errormessages.push('Please select a value in Size');
               
                this.isvalidscreenfour=false;
            }
            if(task.value=='' ||  task.value==null){
                
                this.errormessages.push('Please select a value in Task');
               
                this.isvalidscreenfour=false;
            }
            if(technique.value=='' ||  technique.value==null){
                
                this.errormessages.push('Please select a value in Technique');
               
                this.isvalidscreenfour=false;
            }
            if(asset.value=='' ||  asset.value==null){
                
                this.errormessages.push('Please select a value in Asset');
               
                this.isvalidscreenfour=false;
            }if(uid.value != null && uid.value.length > 40){
                
                this.errormessages.push('Asset UID should be 40 Max characters');
               
                this.isvalidscreenfour=false;
            }
           
        }

        handlesectionfivevalidation()
        {  
            this.errormessages=[];
            this.isvalidscreenfive=true;
            
        let location = this.template.querySelector(".estloccls");
        let leakqty = this.template.querySelector(".leakquantcls");
        let serial = this.template.querySelector(".meterserialcls");
        let meterread = this.template.querySelector(".meterreadingcls");
          
            if (location.value==null || location.value.length != 6 || location.value==''){
                this.errormessages.push('EST Location should be 6 digits');
                this.isvalidscreenfive=false;
            }
            if (leakqty.value==null || leakqty.value.length != 6 || leakqty.value=='' ){
                this.errormessages.push('Leak Quantified should be 6 digits');
                this.isvalidscreenfive=false;
            }
            if (serial.value==null || serial.value.length != 15 || serial.value=='' ){
                this.errormessages.push('Meter Serial should contain 15 characters');
                this.isvalidscreenfive=false;
            }
            if (meterread.value==null || meterread.value.length != 15 || meterread.value==''){
                this.errormessages.push('Leak Quantified should contain 15 characters');
                this.isvalidscreenfive=false;
            }

        }

        handlesectionsevenvalidation()
        {
            this.errormessages=[];
            this.isvalidscreenseven=true;
            let excavation = this.template.querySelector(".excavationcls");
            let ltype = this.template.querySelector(".leaktypecls");
            let trailerval = this.template.querySelector(".trailercls");
            let letterval = this.template.querySelector(".letterwarncls");
            let gangcomments = this.template.querySelector(".gangcommcls");
            if(excavation.value=='' || excavation.value==null || ltype.value=='' || ltype.value==null ||
            trailerval.value=='' || trailerval.value==null ||letterval.value=='' || letterval.value==null ||gangcomments.value=='' || gangcomments.value==null){
                this.errormessages.push('Please fill in all mandatory fields');
                this.isvalidscreenseven=false;
            }

        }
        handlesectionninevalidation(){
          
            this.isvalidscreennine=true;
            this.errormessages=[];
        let schcomm = this.template.querySelector(".schedulingcommcls");
        let powerlines = this.template.querySelector(".overheadpowerlinescls");
        let lampsupport = this.template.querySelector(".lampsupportcls");
        let confinedspace =this.template.querySelector(".confinedspacecls");
        let additionalinfo =this.template.querySelector(".additionalinfocls");
        if(schcomm.value== null || powerlines.value == null || lampsupport.value == null ||  confinedspace.value==null || additionalinfo.value==null 
            ||  schcomm.value== undefined || powerlines.value == undefined || lampsupport.value == undefined ||  confinedspace.value==undefined || additionalinfo.value==undefined){
                this.isvalidscreennine=false;
                this.errormessages.push('Please fill in mandatory fields');
        }else{
            if(schcomm.value.length > 150){
                this.isvalidscreennine=false;
                this.errormessages.push('Scheduling comments box should have 150 Max characters');
              
            }else{
                this.isvalidscreennine=true;
            }

        }
        

        }
        handlesectiontenvalidation(){
           
            this.isvalidsectionten=true;
            this.errormessages=[];
        let contaminationcomments = this.template.querySelector(".contaminationcommcls");
        let pollutionsel = this.template.querySelector(".pollutioncls");
        let polltncomm = this.template.querySelector(".pollutioncommcls");
        let riskoccur = this.template.querySelector(".riskoccurringcls");
        let envrisk = this.template.querySelector(".riskenvcls");

        if(pollutionsel.value == '' || pollutionsel.value==null || envrisk.value==''|| envrisk.value==null){

            this.isvalidsectionten=false;
            this.errormessages.push('Please fill in values in the fields marked as required');
           
        }
        if(this.iscontaminationyes==true && (contaminationcomments.value==null || contaminationcomments.value=='')){

            this.isvalidsectionten=false;
            this.errormessages.push('Please fill in value in Contamination Comments');
           
        }
        if(this.ispollutionyes==true && (polltncomm.value==null || polltncomm.value=='' || riskoccur.value=='' || riskoccur.value==null)){

            this.isvalidsectionten=false;
            this.errormessages.push('Please fill in value in Confirmed Pollution Comments');
           
        }


        }

        handlesectionelevenvalidation(){
        this.isvalidscreeneleven=true;
        this.errormessages=[];
        let estimatedpropertiesval = this.template.querySelector(".estimatedpropertiescls");
        let altsuppliesval = this.template.querySelector(".altsuppliescls");
        let sensitivecustonshuttdownval = this.template.querySelector(".sensitivecustonshuttdowncls");
        let thirdpartydmgeval = this.template.querySelector(".thirdpartydmgecls");
        let shutoffvalve=this.template.querySelector(".isshutoffcls");
        console.log('shutoffvalve---->',shutoffvalve.value);
      if(!!shutoffvalve.value){
        console.log('shutoffvalve1---->',shutoffvalve.value);
        if(this.isshutoff=='Yes'){
            if(estimatedpropertiesval.value=='' || altsuppliesval.value==null || sensitivecustonshuttdownval.value=='' ||
            estimatedpropertiesval.value==null || altsuppliesval.value=='' ||sensitivecustonshuttdownval.value==null){
             this.isvalidscreeneleven=false; 
             this.errormessages.push('Please fill all fields marked mandatory'); 
            }
        }else if(this.isshutoff=='No'){
            if(thirdpartydmgeval.value==null || thirdpartydmgeval.value=='' ){
                this.isvalidscreeneleven=false;  
                this.errormessages.push('Please fill all fields marked mandatory'); 
            }
        }else{

            this.isvalidscreeneleven=true;  
        }
      }else{
        this.isvalidscreeneleven=false; 
        this.errormessages.push('Please fill all fields marked mandatory'); 
      }
       


        }
       
        
        handlePrevious() {
            if (this.sectionone) {
               
                return; 
            } else if (this.sectiontwo) {
                this.savesectiononevalues();
                this.errormessages=[];
                this.sectionone = true;
                this.sectiontwo = false;
                this.sectionthree=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
            } else if (this.sectionthree) {
                this.savesectiononevalues();
                this.errormessages=[];
                this.sectiontwo = true;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectionfour){
                this.savesectiononevalues();
                this.savesectionfourvalues();
                this.errormessages=[];
                this.sectiontwo = false;
                this.sectionthree = true;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectionfive){
               
                this.savesectiononevalues();
                this.errormessages=[];
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=true;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectionsix){
                this.errormessages=[];
                this.savesectiononevalues();
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=true;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectionseven){
                this.savesectiononevalues();
                this.errormessages=[];
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
                
                if(this.selectedasset=='D 28' || this.selectedasset=='D 29' || this.selectedasset=='D 30' || this.selectedasset=='D 31')
                { this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=true;
                this.sectionseven=false;
                }else{
                        this.sectionfour=true;
                        this.sectionfive=false;
                        this.sectionsix=false;
                        this.sectionseven=false;
                }
                
               }else if(this.sectioneight){
                this.errormessages=[];
                this.savesectiononevalues();
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=true;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectionnine){
                this.errormessages=[];
                this.savesectiononevalues();
                this.enablesecsixofchild=true;
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=true;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectionten){
                this.errormessages=[];
                this.savesectiononevalues();
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=true;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectioneleven){
                this.errormessages=[];
                this.savesectiononevalues();
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=true;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectiontwelve){
                this.errormessages=[];
                this.savesectiononevalues();
                this.handlepreviousfromtable();
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=true;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else if(this.sectionthirteen){
                this.errormessages=[];
                this.savesectiononevalues();
                this.saveData();
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=true;
                this.sectionthirteen=false;
            }
           }
        
           handleNext() {
            if (this.sectionone) {
                this.savesectiononevalues();
                this.handlesectiononevalidation();
                
                if(this.isvalidscreenone){
                    
                    this.sectionone = false;
                    this.sectiontwo = true;
                    this.sectionthree=false;
                    this.sectionfour=false;
                    this.sectionfive=false;
                    this.sectionsix=false;
                    this.sectionseven=false;
                    this.sectioneight=false;
                    this.sectionnine=false;
                    this.sectionten=false;
                    this.sectioneleven=false;
                    this.sectiontwelve=false;
                    this.sectionthirteen=false;
                }else{
                    console.log('error in sec one');
                }
               
               } else if(this.sectiontwo) {
              
               this.savesectiononevalues();
              
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
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
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
                    this.sectionsix=false;
                    this.sectionseven=false;
                    this.sectioneight=false;
                    this.sectionnine=false;
                    this.sectionten=false;
                    this.sectioneleven=false;
                    this.sectiontwelve=false;
                    this.sectionthirteen=false;
               
              }else if(this.sectionfour){
                this.savesectiononevalues();
                this.handlesectionfourvalidation();

                if(this.isvalidscreenfour)
                {
                    
                    this.sectiontwo = false;
                    this.sectionthree = false;
                    this.sectionone=false;
                    this.sectionfour=false;
                    this.sectioneight=false;
                    this.sectionnine=false;
                    this.sectionten=false;
                    this.sectioneleven=false;
                    this.sectiontwelve=false;
                    this.sectionthirteen=false;
                   
                       
                    if(this.selectedasset=='D 28' || this.selectedasset=='D 29' || this.selectedasset=='D 30' || this.selectedasset=='D 31')
                    {
                        this.sectionfive=true;
                        this.sectionsix=false;
                        this.sectionseven=false;
                    }else{
                        this.sectionfive=false;
                        this.sectionsix=false;
                        this.sectionseven=true;
                    }
                    this.savesectionfourvalues();
               }
            else{
                console.log('error in secfour')
            }
                
               }else if(this.sectionfive){
               this.savesectiononevalues();
               this.handlesectionfivevalidation();
                if(this.isvalidscreenfive){
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=true;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
              
            }else{
                console.log('error in section 5')
            }  
               }
               else if(this.sectionsix){
                this.savesectiononevalues();
                this.errormessages=[];
                let commforbopps=this.template.querySelector(".boopsteamcls");
                
             
                if((this.isaccessissuesyes ==true) && (commforbopps.value == '' || commforbopps.value == null))
                {
                    console.log('error in section six');
                    this.errormessages.push('Please fill Comments for Bopps team');
  
                }else{
                        this.sectiontwo = false;
                        this.sectionthree = false;
                        this.sectionone=false;
                        this.sectionfour=false;
                        this.sectionfive=false;
                        this.sectionsix=false;
                        this.sectionseven=true;
                        this.sectioneight=false;
                        this.sectionnine=false;
                        this.sectionten=false;
                        this.sectioneleven=false;
                        this.sectiontwelve=false;
                        this.sectionthirteen=false;
                }
                
               
               } else if(this.sectionseven){
                const sendvaluestotmacmp=JSON.parse(JSON.stringify(this.submitValues));
                this.senddatatotmacmp=sendvaluestotmacmp;
                this.savesectiononevalues();
              this.handlesectionsevenvalidation();
              if(this.isvalidscreenseven){
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=true;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
            }else{
                console.log('error in section seven');
            }
               
               }else if(this.sectioneight){
                this.savesectiononevalues();
        
                 this.sectiontwo = false;
                 this.sectionthree = false;
                 this.sectionone=false;
                 this.sectionfour=false;
                 this.sectionfive=false;
                 this.sectionsix=false;
                 this.sectionseven=false;
                 this.sectioneight=false;
                 this.sectionnine=true;
                 this.sectionten=false;
                 this.sectioneleven=false;
                 this.sectiontwelve=false;
                 this.sectionthirteen=false;

                //return;
               }else if(this.sectionnine){
                this.savesectiononevalues();
                this.handlesectionninevalidation();
               if(this.isvalidscreennine){
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=true;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               }else{
                console.log('error in section nine');
               }
             
                
              
               }else if(this.sectionten){
                this.savesectiononevalues();
                this.handlesectiontenvalidation();
              if(this.isvalidsectionten){
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=true;
                this.sectiontwelve=false;
                this.sectionthirteen=false;
               
              }else{
                console.log('error in section ten')
              }
           
                
               
               }else if(this.sectioneleven){
                this.handlesectionelevenvalidation();
                this.savesectiononevalues();
              this.retaintablevalues();
              if(this.isvalidscreeneleven){
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=true;
                this.sectionthirteen=false;
                if(this.isshutoff=='No'){
                    this.sendvaluestofsmfurtherworkrequest();
                    this.sectiontwelve=false;
                    this.sectionthirteen=false;
                 }
               
              }

               }else if(this.sectiontwelve){
                
                this.saveData();
                
                this.sectiontwo = false;
                this.sectionthree = false;
                this.sectionone=false;
                this.sectionfour=false;
                this.sectionfive=false;
                this.sectionsix=false;
                this.sectionseven=false;
                this.sectioneight=false;
                this.sectionnine=false;
                this.sectionten=false;
                this.sectioneleven=false;
                this.sectiontwelve=false;
                this.sectionthirteen=true;
                
    
               }else if(this.sectionthirteen){
                
                
                return;
               }
          }
          get isEnableNext(){
            if(this.sectionone==true || this.sectiontwo == true || this.sectionthree == true || this.sectionfour == true || this.sectionfive == true || this.sectionsix == true || this.sectionseven == true || this.sectionnine==true || this.sectionten==true || this.sectioneleven==true || this.sectiontwelve==true){
                return true;
            }
            else{
                return false;
            }
        }
        get isEnablePrev(){
            if(this.sectiontwo == true || this.sectionthree == true || this.sectionfour == true || this.sectionfive == true || this.sectionsix == true || this.sectionseven == true || this.sectionnine ==true || this.sectionten==true || this.sectioneleven==true || this.sectiontwelve==true){
                return true;
            }
            else{
                return false;
            }
        
        }
        
        handleaddresschange(event){
            this.isdiffaddrr = event.detail.checked;
            
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
                this.occhsename='';
                
            }
        }

        handleaccessissueschange(event){
            this.accessissueschecked = event.detail.checked;
            if(this.accessissueschecked){
                this.isaccessissuesyes=true;
            }else{
                this.isaccessissuesyes=false;
                
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
       
        validateFields() {
            return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
               
                field.reportValidity();
                return validSoFar && field.checkValidity();
               
            }, true);
        }
        sendvaluestofsmfurtherworkrequest(){
            if(!!JSON.stringify(this.dcfinfrarecorddata)){
               
                const finalarr={...this.submitValues,...this.dcfinfrarecorddata}
              
                const event = new CustomEvent('finalsubmit', {
           
                    detail:{dcfdata:finalarr,dcflineitemdata:this.dcflineitemdata} 
                    });
                    this.dispatchEvent(event);
            }else{
                const event = new CustomEvent('finalsubmit', {
           
                    detail:{dcfdata:this.submitValues,dcflineitemdata:this.dcflineitemdata} 
                    });
                    this.dispatchEvent(event);
            }
           
           
            }
           


        handlepreviousfromchild(event){
           this.submitValues={...this.submitValues, ...event.detail}
            this.retainvaluestochild={...event.detail}
            this.enablesecsixofchild=false;
            this.sectioneight=false;
            this.sectionseven=true;
          
        }

        handlenextfromfsmnotice(event){
            this.submitValues={...this.submitValues, ...event.detail}
            this.retainvaluestochild={...event.detail}
            this.sectioneight=false;
            this.sectionnine=true;
        }

        @wire(getObjectInfo, { objectApiName: FSM_DCFDependantPicklist__c })
    objectInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: FSM_DCFDependantPicklist__c, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    dependentPicklistValues({ error, data }) {
        if (data) {
            this.error = null;
            let assetoptions = [{ label: '--None--', value: '--None--' }];
            let taskoptions = [{ label: '--None--', value: '--None--' }];

            data.picklistFieldValues.FSM_Asset__c.values.forEach(key => {
                assetoptions.push({
                    label: key.label,
                    value: key.value
                })

            });
            this.assetvaluesarr = assetoptions;
            data.picklistFieldValues.FSM_Task__c.values.forEach(key => {
        
                taskoptions.push({
                    label: key.label,
                    value: key.value
                })
            });

            this.alltaskvaluesarr = taskoptions;
           
            

            // //Technique
            let techniqueoptions = [{label:'--None--', value:'--None--'}];
            data.picklistFieldValues.FSM_Technique__c.values.forEach(key => {
                techniqueoptions.push({
            label : key.label,
            value: key.value
            })

            });
            this.allTechValuesArr = techniqueoptions;

            // //Material
            let materialoptions = [{label:'--None--', value:'--None--'}];
            data.picklistFieldValues.FSM_Material__c.values.forEach(key => {
                materialoptions.push({
            label : key.label,
            value: key.value
            })

            });
            this.allMaterialValuesArr = materialoptions;

            // //Size
            let sizeoptions = [{label:'--None--', value:'--None--'}];
            data.picklistFieldValues.FSM_Size__c.values.forEach(key => {
                sizeoptions.push({
            label : key.label,
            value: key.value
            })

            });
            this.allSizeValuesArr = sizeoptions;


        }
    }


    handleChangeasset(event) {
        try {
            this.selectedasset=event.detail.value;
            this.seltask='';
            this.selectedtechnique='';
            this.selmaterial='';
            this.selsize='';

            const unique = new Set();
            this.dcfdependentpicklist1?.forEach(r => {
                if (r.FSM_Asset__c == event.detail.value) {
                    unique.add(r.FSM_Task__c);
                }
            });
            const arr = []
            this.alltaskvaluesarr.forEach(r => {
                unique.forEach(item => {
                    if (item == r.value) {
                        arr.push(r)
                    }
                })
            })
            this.taskvaluesarr = arr;
        } catch (error) {
            conslog.log(error)
        }
    }

    handleChangetask(event) {
        this.seltask = event.detail.value;
        this.selectedtechnique='';
            this.selmaterial='';
            this.selsize='';
        try {
            const uniquetechnique = new Set();
            this.dcfdependentpicklist1?.forEach(r => {
                if (r.FSM_Asset__c == this.selectedasset && r.FSM_Task__c== this.seltask) {
                    uniquetechnique.add(r.FSM_Technique__c);
                }
            });
            const arr = []
            this.allTechValuesArr.forEach(r => {
                uniquetechnique.forEach(item => {
                    if (item == r.value) {
                        arr.push(r)
                    }
                })
            })
            this.techvaluesarr = arr;
        } catch (error) {
            conslog.log(error)
        }
    }
    handleChangetech(event) {
        this.selectedtechnique = event.detail.value;
      
            this.selmaterial='';
            this.selsize='';
        try {
            const uniquematerial = new Set();
            this.dcfdependentpicklist1?.forEach(r => {
                if (r.FSM_Asset__c == this.selectedasset && r.FSM_Task__c== this.seltask && r.FSM_Technique__c==this.selectedtechnique) {
                    uniquematerial.add(r.FSM_Material__c);
                }
            });
            const arr = []
            this.allMaterialValuesArr.forEach(r => {
                uniquematerial.forEach(item => {
                    if (item == r.value) {
                        arr.push(r)
                    }
                })
            })
            this.materialvaluesarr = arr;
        } catch (error) {
            conslog.log(error)
        }
    }
    handleChangematerial(event) {
        this.selmaterial = event.detail.value;
        this.selsize='';
        try {
            const uniquesize = new Set();
            this.dcfdependentpicklist1?.forEach(r => {
                if (r.FSM_Asset__c == this.selectedasset && r.FSM_Task__c== this.seltask && r.FSM_Technique__c==this.selectedtechnique && r.FSM_Material__c==this.selmaterial) {
                    uniquesize.add(r.FSM_Size__c);
                }
            });
            const arr = []
            this.allSizeValuesArr.forEach(r => {
                uniquesize.forEach(item => {
                    if (item == r.value) {
                        arr.push(r)
                    }
                })
            })
            this.sizevaluesarr = arr;
        } catch (error) {
            conslog.log(error)
        }
    }

    handleChangesize(event) {
        this.selsize = event.detail.value;
    }
    handlecontaminationchange(event){
        let contaminationval=event.detail.value;
        if(contaminationval == 'Yes')
        {
            this.iscontaminationyes=true;
        }else{
            this.iscontaminationyes=false;
        }
       
    }

    handlepollutionchange(event){
        let pollutionval=event.detail.value;
       
        if(pollutionval == 'Yes')
        {
            this.ispollutionyes=true;
        }else{
            this.ispollutionyes=false;
        }
    }

    handlechangeshutoffoperation(event){
     this.selshutoffoperation=event.target.value;
     this.isshutoff=this.selshutoffoperation;
    
        if(this.selshutoffoperation == 'Yes'){
            this.isshutofforvalvesel=true;
        }else{
            this.isshutofforvalvesel=false;
        }
    }

    @wire(getdependentpicklistRecord)
    wiredAccount({ error, data }) {
        if (data) {
            this.dcfdependentpicklist1 = data;
            this.valuestodisplay = JSON.parse(JSON.stringify(this.dcfdependentpicklist1));
   
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }

    //table functions

    handleInputChange(event) {

        const index = event.target.dataset.index;
        
        const field = event.target.dataset.field;
        
        const value = event.target.value;
        
        this.data[index][field] = value;
        
        
        }
        
        handleAddRow() {
        
        const newRow = {
        
        id: this.data.length + 1,
        
        FSM_ValvesIDIdentifiedOnSketch__c: '', 
        FSM_ProposedOp__c: '',
        FSM_ValveChecked__c:'',
        FSM_GridRefX__c:'',
        FSM_GridRefY__c:'',
        FSM_CommentsForAllValves__c:'' 
        
        };
        
        this.data = [...this.data, newRow];
        
        }
        
        handleDelete(event) {
        
        const index = event.target.dataset.index;
        
        this.data.splice(index, 1);
        
        this.data = [...this.data];
        
        }
//retain values while navigating from section 12 to section 11
        handlepreviousfromtable(){
            
            this.storetabledata=JSON.parse(JSON.stringify(this.data));
            
          
        }
        retaintablevalues(){
           
            if(this.storetabledata == undefined)
            {
                
            }else{
                this.storetabledata.forEach(record=>{

                    if (!this.data.some(item => item.id == record.id))
                        this.data.push(record)
    
                });
        
            }
           
            
        }

        retaindcflineitemvalues(){
            if(this.data.length > 0){
                this.datastoredtable.forEach(record=>{
                    this.data.push(record)
    
                });

            }
          

        }
        
        saveData() {
       
       const datavalid= this.validateData();
        
        if(datavalid) {
        this.dcflineitemdata=JSON.parse(JSON.stringify(this.data))
       
        this.sendvaluestofsmfurtherworkrequest();
      
        
        
        } else {
        
        console.log('Validation failed. Please correct errors.');
        
        }
        
        }
        
        validateData() {
        
         this.isValid = true;
        
        this.data.forEach( (record, index) => {
        
        this.errormessages=[];
        
        if(record.FSM_GridRefX__c < 240000 || record.FSM_GridRefX__c > 550000 || record.FSM_GridRefX__c=='' || record.FSM_GridRefX__c==null){
        
            this.errormessages.push('Grid X should lie between 240000 and 550000');
            this.isValid=false;
        
        }
        
        if(record.FSM_GridRefY__c < 170000 || record.FSM_GridRefY__c > 440001 || record.FSM_GridRefY__c=='' || record.FSM_GridRefY__c==null){
        this.errormessages.push('Grid Y should lie between 170000 and 440000');
        this.isValid=false;
        }
        
        if(record.FSM_CommentsForAllValves__c=='' || record.FSM_ValvesIDIdentifiedOnSketch__c==''||
        record.FSM_CommentsForAllValves__c==null|| record.FSM_ValvesIDIdentifiedOnSketch__c==null){
            this.errormessages.push('Please fill in mandatory fields');
            this.isValid=false;
        }
        
        
        const comboboxvalid = [...this.template.querySelectorAll("lightning-combobox")].reduce((validSoFar,field) => {
            field.reportValidity();
            return validSoFar && field.checkValidity();
           
        }, true);
        
        this.isValid=comboboxvalid;
        });
        
        //await Promise.all(validationPromises);
        
        return this.isValid;
        
        }
        //0122z000002d76OAAQ----->qa
        //0122z000002chGzAAI------->dev
        
        @wire(getPicklistValuesByRecordType, { objectApiName: FSM_DCFLineItemInfraOBJECT, recordTypeId:'0122z000002d76OAAQ' })
        tablepicklistValues({ error, data }) {
            if (data) {
                this.error = null;
                let proposedoptions = [{ label: '--None--', value: '--None--' }];
                let valveoptions = [{ label: '--None--', value: '--None--' }];
        
                data.picklistFieldValues.FSM_ProposedOp__c.values.forEach(key => {
                    proposedoptions.push({
                        label: key.label,
                        value: key.value
                    })
        
                })
                this.proposedoparr = proposedoptions;
                data.picklistFieldValues.FSM_ValveChecked__c.values.forEach(key => {
                   
                    valveoptions.push({
                        label: key.label,
                        value: key.value
                    })
                });
        
                this.valvescheckedarr = valveoptions;
        
            }
        }
        
       savesectionfourvalues(){
        
        let assetvalue = this.template.querySelector(".assetcls");
        let taskvalue = this.template.querySelector(".taskcls");
        let techniquevalue = this.template.querySelector(".techniquecls");
        let sizevalue = this.template.querySelector(".sizecls");
        let materialvalue = this.template.querySelector(".materialcls");
        this.submitValues.FSM_Asset__c=assetvalue.value;
        this.submitValues.FSM_Task__c=taskvalue.value;
        this.submitValues.FSM_Technique__c=techniquevalue.value;
        this.submitValues.FSM_AssetSize__c=sizevalue.value;
        this.submitValues.FSM_AssetMaterial__c=materialvalue.value;
        

       }

       @api handlepreviousfromfwr(dcfrecorddata){
        //alert('inside fwr',);
  
        const dcfforminput=JSON.parse(JSON.stringify(dcfrecorddata));
        this.retainvaluestochild=dcfforminput.dcfdata;
        
        this.dcfinfralineitemdata=dcfforminput.dcflineitemdata;
        this.dcfinfrarecorddata=dcfforminput.dcfdata;
      
        this.isshutofforvalvesel=true;
       
       if(this.dcfinfrarecorddata.FSM_IsShutOffOrValveOperationRequired__c == 'Yes')
       {   console.log('data in dcfinfralineitemdata fwr',JSON.stringify(this.dcfinfralineitemdata));
        this.sectionone = false;
        this.sectiontwo = false;
        this.sectionthree=false;
        this.sectionfour=false;
        this.sectionfive=false;
        this.sectionsix=false;
        this.sectionseven=false;
        this.sectioneight=false;
        this.sectionnine=false;
        this.sectionten=false;
        this.sectioneleven=false;
        this.sectiontwelve=true;
        this.sectionthirteen=false;    

        this.dcfinfralineitemdata.forEach(record=>{
            console.log('data',JSON.stringify(this.data));
       console.log('dcfinfralineitemdata in table',JSON.stringify(this.dcfinfralineitemdata));
            if (!this.data.some(item => item.id == record.id))
            {  console.log('data in if',JSON.stringify(this.data[0].FSM_GridRefX__c));
                this.data.push(record);
                //this.data={...this.data,...record}
                
            }
            // else{
            //     console.log('data in else',JSON.stringify(this.data));
            //     console.log('data in dcfinfralineitemdata',JSON.stringify(this.dcfinfralineitemdata));
            //     //
            //     //this.data={...this.data,...record}
            //     this.data.splice(0, 1);
        
            //     this.data = [...this.data];
            //     this.data.unshift(record);
                
             
            // }
                

        });
     
       }else{
        this.sectionone = false;
        this.sectiontwo = false;
        this.sectionthree=false;
        this.sectionfour=false;
        this.sectionfive=false;
        this.sectionsix=false;
        this.sectionseven=false;
        this.sectioneight=false;
        this.sectionnine=false;
        this.sectionten=false;
        this.sectioneleven=true;
        this.sectiontwelve=false;
        this.sectionthirteen=false; 
        this.isshutofforvalvesel=false;   
       }
       

       this.gridproposedworkx= this.dcfinfrarecorddata.FSM_GridRefOfProposedWorkX__c;
       this.gridproposedworky=this.dcfinfrarecorddata.FSM_GridRefOfProposedWorkY__c;
        this.diffaddress=this.dcfinfrarecorddata.FSM_SFWIsThisAtADifferentAddress__c;
        this.occname=this.dcfinfrarecorddata.FSM_OccupiersName__c;
        this.occtelno= this.dcfinfrarecorddata.FSM_OccupiersTelephoneNumber__c;
        this.occhsename=this.dcfinfrarecorddata.FSM_OccupiersHouseName__c;
        this.occhseno=this.dcfinfrarecorddata.FSM_OccupiersHouseNo__c;
        this.occstreet=this.dcfinfrarecorddata.FSM_OccupiersStreet__c;
        this.occstown=this.dcfinfrarecorddata.FSM_OccupiersTown__c;
        this.occcity=this.dcfinfrarecorddata.FSM_OccupiersCity__c;
        this.occpostcode=this.dcfinfrarecorddata.FSM_OccupiersPostcode__c;
        this.occlocation=this.dcfinfrarecorddata.FSM_LandComments__c;
        this.landcomm=this.dcfinfrarecorddata.FSM_LandComments__c;
        this.permissiontodigreq=this.dcfinfrarecorddata.FSM_PermissionToDigRequired__c;
        this.proformasigned=this.dcfinfrarecorddata.FSM_WhichProformaSigned__c;
        this.permissiondig=this.dcfinfrarecorddata.FSM_PermissionToDig__c;
        this.assetuuid=this.dcfinfrarecorddata.FSM_AssetUID__c;
        this.selectedasset=this.dcfinfrarecorddata.FSM_Asset__c;
        this.estloc=this.dcfinfrarecorddata.FSM_ESTLocation__c;
        this.leakquant=this.dcfinfrarecorddata.FSM_LeakQuantified__c;
        this.meterserial=this.dcfinfrarecorddata.FSM_MeterSerial__c;
        this.meterreading=this.dcfinfrarecorddata.FSM_MeterReading__c;
        this.accessissues=this.dcfinfrarecorddata.FSM_AccessRestricted__c;
        this.mon=this.dcfinfrarecorddata.FSM_Monday__c;
        this.tues=this.dcfinfrarecorddata.FSM_Tuesday__c;
        this.wed=this.dcfinfrarecorddata.FSM_Wednesday__c;
        this.thurs=this.dcfinfrarecorddata.FSM_Thursday__c;
        this.fri=this.dcfinfrarecorddata.FSM_Friday__c;
        this.sat=this.dcfinfrarecorddata.FSM_Saturday__c;
        this.sun=this.dcfinfrarecorddata.FSM_Sunday__c;
        this.restrictedtime=this.dcfinfrarecorddata.FSM_RestrictedTime__c;
        this.powerlines=this.dcfinfrarecorddata.FSM_OverheadPowerLinesWithin10m__c;
        this.boopsteam=this.dcfinfrarecorddata.FSM_CommentsForBoppsTeam__c;
        this.excavation=this.dcfinfrarecorddata.FSM_IsExcavationRequired__c;
        this.leaktype=this.dcfinfrarecorddata.FSM_TypeOfLeak__c;
        this.reason=this.dcfinfrarecorddata.FSM_ReasonForFirstTimeReinstatement__c;
        this.trailer=this.dcfinfrarecorddata.FSM_TrailerTeam__c;
        this.letterwarn=this.dcfinfrarecorddata.FSM_LetterWarn__c;
        this.sensitivecustomer=this.dcfinfrarecorddata.FSM_SensitiveCustomer__c;
        this.gangcomm=this.dcfinfrarecorddata.FSM_CommentsForTheGangs__c;
        this.overheadpowerlines=this.dcfinfrarecorddata.FSM_OverheadPowerLinesWithin10m__c;
        this.lampsupport=this.dcfinfrarecorddata.FSM_LampSupportRemovalRequired__c;
        this.confinedspace=this.dcfinfrarecorddata.FSM_ConfinedSpaceWorking__c;
        this.additionalinfo=this.dcfinfrarecorddata.FSM_DetailsSafetyInformation__c;
        this.schedulingcomm=this.dcfinfrarecorddata.FSM_SchedulingCommentsBox__c;
        this.contamination=this.dcfinfrarecorddata.FSM_Contamination__c;
        this.contaminationcomm=this.dcfinfrarecorddata.FSM_ContaminationComments__c;
       this.pollution=this.dcfinfrarecorddata.FSM_IsThereConfirmedPollution__c;
        this.pollutioncomm=this.dcfinfrarecorddata.FSM_ConfirmedPollutionComments__c;
        this.risk=this.dcfinfrarecorddata.FSM_IsThereARiskOfPollutionOccurring__c;
        this.riskenv=this.dcfinfrarecorddata.FSM_RiskToAnEnvironmentalSite__c;
        this.isshutoff=this.dcfinfrarecorddata.FSM_IsShutOffOrValveOperationRequired__c;
        this.estimatedproperties=this.dcfinfrarecorddata.FSM_EstimatedNoOfPropertiesAffected__c;
        this.altsupplies=this.dcfinfrarecorddata.FSM_AlternativeSuppliesRequired__c;
        this.sensitivecustonshuttdown=this.dcfinfrarecorddata.FSM_SensitiveCustomersOnShutdown__c;
        this.thirdpartydmge=this.dcfinfrarecorddata.FSM_ThirdPartyDamageOccurOnThisSite__c;
       
       }
        
}
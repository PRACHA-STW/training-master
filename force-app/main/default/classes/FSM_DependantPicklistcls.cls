/****************************************************************************************
    - Description  : Created for DCF Distribution Feedback Form
    - Created By   : Aishwarya Bhosale
    - Created Date : 12 Nov, 2023
    - Modified By  : 6th Dec, 2023 by Brajesh Kumar & Arnob Dey - SFS-3778
                     26th Dec, 2023 by Leena - SFS-3010
					 4th Jan, 2024 by Arnob - SFS-3007
					 16th Sept,2024 by Aishwarya Bhosale SFS-7045
****************************************************************************************/
public without sharing class FSM_DependantPicklistcls {
    @AuraEnabled(cacheable = true)
    public static List<FSM_DCFDependantPicklist__c> getDependentPicklistrecord(){
        List<FSM_DCFDependantPicklist__c> pickvalues=[SELECT id, FSM_Size__c, FSM_Task__c,FSM_Technique__c,FSM_Asset__c, FSM_Material__c FROM FSM_DCFDependantPicklist__c WITH SECURITY_ENFORCED];
        return pickvalues;
    }

    
    /*Leena Changes - Start - SFS-3010 */

    //return all dependant Picklists records of Sewerage FWR Form
    @AuraEnabled(cacheable=true)
    public static List<FSM_DCFDependantPicklist__c> getAllSWRRecords() {
        return [SELECT Id,FSM_SWRTask__c, FSM_SWRAsset__c, FSM_SWRJobScope__c, FSM_SWRTransferredAsset__c, FSM_SWRJobRecipient__c FROM FSM_DCFDependantPicklist__c where FSM_Type__c='Sewerage Further Work' WITH SECURITY_ENFORCED];
    }

    //Task Picklist
    @AuraEnabled(cacheable=true)
    public static swrWrapperCls getSWRTaskList() {

        Set<String> swrTask = new Set<string>();

        for(FSM_DCFDependantPicklist__c pickvalues: [SELECT Id, FSM_SWRTask__c, FSM_SWRAsset__c, FSM_SWRJobScope__c, FSM_SWRTransferredAsset__c, FSM_SWRJobRecipient__c FROM FSM_DCFDependantPicklist__c where FSM_Type__c='Sewerage Further Work' WITH SECURITY_ENFORCED]){
            swrTask.add(pickvalues.FSM_SWRTask__c);
        }
        //Fetch SWR Task 
        List<PicklistOption> taskPicklistOptions = new List<PicklistOption>();
        
        // Describe the field on the object
        Schema.DescribeFieldResult taskFieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SWRTask__c').getDescribe();

        // Retrieve picklist values
        List<Schema.PicklistEntry> taskPicklistEntries = taskFieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : taskPicklistEntries) {
            if(swrTask.contains(entry.getValue())){
                taskPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
        }

        //Fetch SWR Asset 
        List<PicklistOption> assetPicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult assetFieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SWRAsset__c').getDescribe();

        List<Schema.PicklistEntry> assetPicklistEntries = assetFieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : assetPicklistEntries) {
            assetPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        
        //Fetch SWR JobScope 
        List<PicklistOption> jsPicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult jsfieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SWRJobScope__c').getDescribe();

        List<Schema.PicklistEntry> jspicklistEntries = jsfieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : jspicklistEntries) {
            jsPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }

        //Fetch SWR Transferred Asset 
        List<PicklistOption> taPicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult tafieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SWRTransferredAsset__c').getDescribe();

        List<Schema.PicklistEntry> tapicklistEntries = tafieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : tapicklistEntries) {
            taPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }

        //Fetch SWR Job Recepient 
        List<PicklistOption> jrPicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult jrfieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SWRJobRecipient__c').getDescribe();

        List<Schema.PicklistEntry> jrpicklistEntries = jrfieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : jrpicklistEntries) {
            jrPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }

        swrWrapperCls swr = new swrWrapperCls(taskPicklistOptions, assetPicklistOptions, jsPicklistOptions, taPicklistOptions, jrPicklistOptions );
        
        //return picklistOptions;
        return swr;
    }


    //wrapper Class for SWR
    public class SWRWrapperCls {

        @AuraEnabled
        public List<PicklistOption> taskList { get; set; }
        @AuraEnabled
        public List<PicklistOption> assetList { get; set; }
        @AuraEnabled
        public List<PicklistOption> jobScopeList { get; set; }
        @AuraEnabled
        public List<PicklistOption> transferredAssetList { get; set; }
        @AuraEnabled
        public List<PicklistOption> jobRecepientList { get; set; }

        public SWRWrapperCls(List<PicklistOption> task,List<PicklistOption> asset, List<PicklistOption> jobScope, List<PicklistOption> transferredAsset, List<PicklistOption> jobRecepient) {
            this.taskList = task;
            this.assetList = asset;
            this.jobScopeList = jobScope;
            this.transferredAssetList = transferredAsset;
            this.jobRecepientList = jobRecepient;
        }
    }

    /*Leena Changes - End */

   
     /*Arnob Changes - Start - #SFS-3007*/

    //SWR Asset Picklist  
    @AuraEnabled(cacheable=true)
    public static SWRFeedbackWrapperCls getSWRAssetList() {

        //Unique SWR Asset
        Set<String> uniAsset = new Set<string>();

        for(FSM_DCFDependantPicklist__c pickvalues: [SELECT id, FSM_SWRAsset__c, FSM_SWRTask__c, FSM_SWRJobRecipient__c FROM FSM_DCFDependantPicklist__c WITH SECURITY_ENFORCED]){
            uniAsset.add(pickvalues.FSM_SWRAsset__c);
        }

        List<PicklistOption> picklistOptions = new List<PicklistOption>();
        
        // Describe the field on the object
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SWRAsset__c').getDescribe();

        // Retrieve picklist values
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            if(uniAsset.contains(entry.getValue())){
                picklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
        }

        //SWR Task - start
        List<PicklistOption> taskpicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult taskfieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SWRTask__c').getDescribe();

        List<Schema.PicklistEntry> taskpicklistEntries = taskfieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : taskpicklistEntries) {
            taskpicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        //SWR Task - end
        
        //SWR Recipient - start
        List<PicklistOption> jrPicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult jrFieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SWRJobRecipient__c').getDescribe();

        List<Schema.PicklistEntry> jrPicklistEntries = jrFieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : jrPicklistEntries) {
            jrPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        //SWR Recipient - end

        SWRFeedbackWrapperCls wrp = new SWRFeedbackWrapperCls(picklistOptions, taskpicklistOptions, jrPicklistOptions);
        return wrp;
    }
    //Wrapper Class for Sewer Feedback Form 
     public class SWRFeedbackWrapperCls {

        @AuraEnabled
        public List<PicklistOption> assetList { get; set; }
        @AuraEnabled
        public List<PicklistOption> taskList { get; set; }
        @AuraEnabled
        public List<PicklistOption> recipientList { get; set; }       

        public SWRFeedbackWrapperCls(List<PicklistOption> asst,List<PicklistOption> tasks, List<PicklistOption> recpt) {
            this.assetList = asst;
            this.taskList = tasks;
            this.recipientList = recpt;          
        }
    }
     /*Arnob Changes - End - #SFS-3007 */

    /* Brajesh & Arnob changes - Start - SFS-3778*/
    //return all dcf records
    @AuraEnabled(cacheable=true)
    public static List<FSM_DCFDependantPicklist__c> getAllRecords() {
        return [SELECT Id,FSM_Asset__c, FSM_Task__c, FSM_Technique__c, FSM_Size__c, FSM_Material__c FROM FSM_DCFDependantPicklist__c where FSM_Asset__c != NULL WITH SECURITY_ENFORCED];
    }

    //Asset Picklist
    @AuraEnabled(cacheable=true)
    public static WrapperCls getAssetList() {

        //Unique Asset
        Set<String> uniAsset = new Set<string>();

        for(FSM_DCFDependantPicklist__c pickvalues: [SELECT id, FSM_Size__c, FSM_Task__c,FSM_Technique__c,FSM_Asset__c, FSM_Material__c FROM FSM_DCFDependantPicklist__c WITH SECURITY_ENFORCED]){
            uniAsset.add(pickvalues.FSM_Asset__c);
        }

        List<PicklistOption> picklistOptions = new List<PicklistOption>();
        
        // Describe the field on the object
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_Asset__c').getDescribe();

        // Retrieve picklist values
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            if(uniAsset.contains(entry.getValue())){
                picklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
        }

        //Task - start
        List<PicklistOption> taskpicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult taskfieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_Task__c').getDescribe();

        List<Schema.PicklistEntry> taskpicklistEntries = taskfieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : taskpicklistEntries) {
            taskpicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        //Task - end
        
        //Technique - start
        List<PicklistOption> tPicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult tfieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_Technique__c').getDescribe();

        List<Schema.PicklistEntry> tpicklistEntries = tfieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : tpicklistEntries) {
            tPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        //Technique - end

        //Size - start
        List<PicklistOption> sizePicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult sizefieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_Size__c').getDescribe();

        List<Schema.PicklistEntry> sizepicklistEntries = sizefieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : sizepicklistEntries) {
            sizePicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        //Size - end

        //Material - start
        List<PicklistOption> materialPicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult materialfieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_Material__c').getDescribe();

        List<Schema.PicklistEntry> materialpicklistEntries = materialfieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : materialpicklistEntries) {
            materialPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        //Material - end

        WrapperCls wrp = new WrapperCls(picklistOptions, taskpicklistOptions, tPicklistOptions, sizePicklistOptions, materialPicklistOptions );
        
        //return picklistOptions;
        return wrp;
    }

    public class WrapperCls {

        @AuraEnabled
        public List<PicklistOption> assetList { get; set; }
        @AuraEnabled
        public List<PicklistOption> taskList { get; set; }
        @AuraEnabled
        public List<PicklistOption> techniqueList { get; set; }
        @AuraEnabled
        public List<PicklistOption> sizeList { get; set; }
        @AuraEnabled
        public List<PicklistOption> materialList { get; set; }

        public WrapperCls(List<PicklistOption> asst,List<PicklistOption> tasks, List<PicklistOption> techq, List<PicklistOption> sze, List<PicklistOption> material) {
            this.assetList = asst;
            this.taskList = tasks;
            this.techniqueList = techq;
            this.sizeList = sze;
            this.materialList = material;
        }
    }

    public class PicklistOption {

        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    /* Brajesh & Arnob changes - End - SFS-3778*/
    
    // Added as part of sfs-7256
    //return all dependant Picklists records of Sewerage Job feedback Form
    @AuraEnabled(cacheable=true)
    public static List<FSM_DCFDependantPicklist__c> getAllSWRJobRecords() {
        return [SELECT Id,FSM_SFAsset__c, FSM_SFTask__c,FSM_SFJob__c,FSM_Type__c,FSM_SWRTransferredAsset__c FROM FSM_DCFDependantPicklist__c where FSM_Type__c='Sewerage Job Feedback' WITH SECURITY_ENFORCED];
    }
    
    //SWR Asset Picklist  
    @AuraEnabled(cacheable=true)
    public static SWRJobFeedbackWrapperCls getSWRJobAssetList() {

        //Unique SWR Asset
        Set<String> uniAsset = new Set<string>();

        for(FSM_DCFDependantPicklist__c pickvalues: [SELECT id, FSM_SFAsset__c, FSM_SFTask__c,FSM_SFJob__c,FSM_Type__c FROM FSM_DCFDependantPicklist__c where FSM_Type__c='Sewerage Job Feedback' ]){
            uniAsset.add(pickvalues.FSM_SFAsset__c);
        }

        List<PicklistOption> picklistOptions = new List<PicklistOption>();
        
        // Describe the field on the object
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SFAsset__c').getDescribe();

        // Retrieve picklist values
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            if(uniAsset.contains(entry.getValue())){
                picklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
        }

        //SWR Task - start
        List<PicklistOption> taskpicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult taskfieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SFTask__c').getDescribe();

        List<Schema.PicklistEntry> taskpicklistEntries = taskfieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : taskpicklistEntries) {
            taskpicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        //SWR Task - end
        
        //SWR Recipient - start
        List<PicklistOption> jrPicklistOptions = new List<PicklistOption>();
        Schema.DescribeFieldResult jrFieldDescribe = Schema.getGlobalDescribe().get('FSM_DCFDependantPicklist__c').getDescribe().fields.getMap().get('FSM_SFJob__c').getDescribe();

        List<Schema.PicklistEntry> jrPicklistEntries = jrFieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : jrPicklistEntries) {
            jrPicklistOptions.add(new PicklistOption(entry.getLabel(), entry.getValue()));
        }
        //SWR Recipient - end

        SWRJobFeedbackWrapperCls wrp = new SWRJobFeedbackWrapperCls(picklistOptions, taskpicklistOptions, jrPicklistOptions);
        return wrp;
    }
    //Wrapper Class for Sewer Feedback Form 
     public class SWRJobFeedbackWrapperCls {

        @AuraEnabled
        public List<PicklistOption> assetList { get; set; }
        @AuraEnabled
        public List<PicklistOption> taskList { get; set; }
        @AuraEnabled
        public List<PicklistOption> recipientList { get; set; }       

        public SWRJobFeedbackWrapperCls(List<PicklistOption> asst,List<PicklistOption> tasks, List<PicklistOption> recpt) {
            this.assetList = asst;
            this.taskList = tasks;
            this.recipientList = recpt;          
        }
    }
    
    
}
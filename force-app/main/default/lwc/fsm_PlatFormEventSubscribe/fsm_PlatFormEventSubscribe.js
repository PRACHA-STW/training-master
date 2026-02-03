/********************************************************************************************************
@Author      : Himanshu Dobriyal
@description : Component created as part of SFI-1002.
@Date        : 03-November-2023
********************************************************************************************************/
import { LightningElement, wire } from 'lwc';
import { subscribe, onError } from 'lightning/empApi';
import templateOne from "./fsm_PlatFormEventSubscribe.html";
import templateTwo from "./fsm_PlatFormEventSubscribe1.html";
import getPicklistOptions from '@salesforce/apex/FSM_PlatformEventControllerPicklist.getCustomSettingPicklistValues';
import getIsvalidLoggedInUser from '@salesforce/apex/FSM_PlatformEventControllerPicklist.isCurrentUserValidToSeeComponent';

export default class Fsm_PlatFormEventSubscribe extends LightningElement {
    subscription = null;
    selectedValue;
    subscribedChannel;
    channelName = '/event/';
    eventPayload = '';
    previousPayload ='';
    picklistOptions = [];
    collectedResponse=[];
    isValidUserToSeeComponent=null;
    connectedCallback() {
        this.isValidUserToSeeComponent=null;   
    }
    //To retrive user profile information from apex
    @wire(getIsvalidLoggedInUser)
    wiredgetIsvalidLoggedInUser({data,error}){
        if(data){
            this.isValidUserToSeeComponent =data;
        }
        else if (error) {
            
        }
    }

    //This fumction is used to get Platform event information from Apex
    @wire(getPicklistOptions)
    wiredPlatformEvents({ data, error }) {
        if (data) {
            // Process the retrieved data to create picklist options
            this.picklistOptions = data.map(record => {
                return {
                    label: record.Label,
                    value: record.FSM_EventApiName__c
                };
            });
        } else if (error) {
            
        }
    }


    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log('New message received : ', JSON.stringify(response));
            // Response contains the payload of the new message received
            this.collectedResponse.push(JSON.stringify(response));
            // Example of processing all payloads
this.collectedResponse.forEach(payload => {
    // Your logic here
    this.eventPayload = this.previousPayload + payload;
    this.previousPayload = this.eventPayload + 'Next payload: ';
});
this.previousPayload='';
        };
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscribedChannel= JSON.stringify(response.channel);
        });
    }

    // Handles picklist change
    handlePicklistChange(event) {
        // Update the selectedValue property when the picklist value changes
        this.selectedValue = event.detail.value;
        this.channelName = '/event/' + this.selectedValue;
        this.handleSubscribe();
    }

    //Rendering template based on boolan value
    render() {
        return this.isValidUserToSeeComponent ? templateOne : templateTwo;
      }
    
      
}
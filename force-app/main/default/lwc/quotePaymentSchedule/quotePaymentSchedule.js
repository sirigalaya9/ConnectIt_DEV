import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { generateGUID, reduceErrors } from 'c/ldsUtils';
import { publish, MessageContext } from 'lightning/messageService';
import ESTIMATE_CLIENT_PAYMENT_SCHEDULE_CHANNEL from '@salesforce/messageChannel/Estimate_Client_Payment_Schedule__c';
import getItems from '@salesforce/apex/QuotePaymentScheduleController.getItems';
import saveItems from '@salesforce/apex/QuotePaymentScheduleController.saveItems';

export default class QuotePaymentSchedule extends LightningElement {

    parentId;
    _total;

    @api 
    get recordId()
    {
        return this.parentId;
    }
    set recordId(value)
    {
        this.parentId = value;
        this.getItems();
    }

    @track
    items = [];

    @wire(MessageContext)
    messageContext;    
        
    showSpinner = false;
    idsToDelete = [];

    get total() {
        if (this.items)
        {            
            let total = this._total;
            this.items.forEach(item => {
                if (item.Payment__c)
                    total -= parseFloat(item.Payment__c);
            });     
            return total;       
        }
        else
            return this._total;
    }

    connectedCallback() {
        console.log('connectedCallback');               
    }  

    renderItems(result) {
        this.items = result.items;
        this._total = result.total;
        publish(this.messageContext, ESTIMATE_CLIENT_PAYMENT_SCHEDULE_CHANNEL, this.items);      
    }    

    getItems() {
        getItems({recordId: this.parentId}).then(result => {
            console.log(result);                
            this.renderItems(result);
        }).catch(error => {
            console.log(error);
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: reduceErrors(error).toString(),
                    variant: 'error'
                })
            );            
        });
    }

    addItem(event) {
        console.log('addItem');        
        let item = {};
        item.Id = generateGUID();
        this.items.push(item);        
    }

    removeItem(event) {
        console.log('removeItem');        
        let id = event.target.dataset.id;
        console.log(id);        
        let index = this.items.findIndex(i => i.Id === id);        
        this.items.splice(index, 1);
        this.idsToDelete.push(id);        
    }  

    handleTriggerChanged(event) {
        console.log('handleTriggerChanged');
        let value = event.target.value;
        console.log(value);        
        let id = event.target.dataset.id;
        console.log(id);        
        let item = this.items.find(i => i.Id === id);         
        item.Trigger__c = value;
    }

    handlePaymentChanged(event) {
        console.log('handlePaymentChanged');
        let value = event.target.value;
        console.log(value);        
        let id = event.target.dataset.id;
        console.log(id);        
        let item = this.items.find(i => i.Id === id);         
        item.Payment__c = value;
    }

    @api
    resetItems() {
        console.log('resetItems');
        this.getItems();
        this.idsToDelete = [];
    }
    
    @api
    saveItems() {
        console.log('saveItems');    
        if (this.total < 0)
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Payment Schedule Error',
                    message: 'Allocation has exceed total',
                    variant: 'error'
                })
            );  
            return;            
        }    
        this.showSpinner = true;        
        saveItems({recordId: this.parentId, items: this.items, idsToDelete: this.idsToDelete}).then(result => {
            console.log(result);
            this.renderItems(result);
            this.showSpinner = false;
        }).catch(error => {
            console.log(error);
            this.idsToDelete = [];
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: reduceErrors(error).toString(),
                    variant: 'error'
                })
            );            
        });
    }
}
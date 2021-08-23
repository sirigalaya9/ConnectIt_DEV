import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { generateGUID, reduceErrors } from 'c/ldsUtils';
import { publish, MessageContext } from 'lightning/messageService';
import ESTIMATE_CLIENT_PAYMENT_SCHEDULE_CHANNEL from '@salesforce/messageChannel/Estimate_Client_Payment_Schedule__c';
import getItems from '@salesforce/apex/QuotePaymentScheduleController.getItems';
import saveItems from '@salesforce/apex/QuotePaymentScheduleController.saveItems';

export default class QuotePaymentSchedule extends LightningElement {

    parentId;
    totalAmount = 0;
    totalPercentage = 100;

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
    @track
    breakdowns = [];    

    @wire(MessageContext)
    messageContext;    
        
    showSpinner = false;
    idsToDelete = [];
    next = false;

    get totalAmountAllocated() {
        if (this.items)
        {            
            let total = 0;
            this.items.forEach(item => {
                if (item.Payment__c)
                    total += parseFloat(item.Payment__c);
            });     
            return total;       
        }
        else
            return 0;
    }

    get totalPercentageAllocated() {
        if (this.totalAmountAllocated)
        {
            let percentage = this.totalAmountAllocated / this.totalAmount * 100;
            return percentage;
        }
        else
            return 0;
    }    

    get totalAmountRemaining() {
        if (this.totalAmountAllocated)
        {
            let total = this.totalAmount - this.totalAmountAllocated;
            return total;
        }
        else
            return this.totalAmount;
    }

    get totalPercentageRemaining() {
        if (this.totalPercentageAllocated)
        {
            let percentage = this.totalPercentage - this.totalPercentageAllocated;
            return percentage;
        }
        else
            return this.totalPercentage;
    }    

    get amountRemainingStyle() {
        if (this.totalAmountRemaining < 0)
        {
            return 'redFont';
        }
        else
            return '';
    }

    connectedCallback() {
        console.log('connectedCallback');               
    }  

    renderItems(result) {
        console.log('renderItems');
        this.items = result.items;        
        this.totalAmount = result.total;
        this.breakdowns = result.breakdowns;
        this.items.forEach(item => {
            if (item.Payment__c)
                item.percentage = (item.Payment__c / this.totalAmount * 100).toFixed(2);
        });                        
        publish(this.messageContext, ESTIMATE_CLIENT_PAYMENT_SCHEDULE_CHANNEL, this.items);      
    }    

    getItems() {
        console.log('getItems');
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
        item.percentage = (value / this.totalAmount * 100).toFixed(2);
    }

    handlePercentageChanged(event) {
        console.log('handlePercentageChanged');
        let value = event.target.value;
        console.log(value);        
        let id = event.target.dataset.id;
        console.log(id);        
        let item = this.items.find(i => i.Id === id);         
        item.percentage = value;
        item.Payment__c = (value / 100 * this.totalAmount).toFixed(2);
    }    

    @api
    resetItems() {
        console.log('resetItems');
        this.getItems();
        this.idsToDelete = [];
    }

    @api
    saveItemsAndNext() {
        this.next = true;
        this.saveItems();
    }    
    
    @api
    saveItems() {
        console.log('saveItems');    
        if (this.totalAmountRemaining < 0)
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
            if (this.next)       
                this.dispatchEvent(new CustomEvent('save'));
            this.next = false;
        }).catch(error => {
            console.log(error);            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: reduceErrors(error).toString(),
                    variant: 'error'
                })
            );            
        }).finally(() => { 
            this.idsToDelete = [];
            this.showSpinner = false;
        });;
    }
}
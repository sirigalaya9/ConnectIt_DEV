import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { generateGUID, reduceErrors } from 'c/ldsUtils';
import { publish, MessageContext } from 'lightning/messageService';
import ESTIMATE_CHECKLIST_CHANNEL from '@salesforce/messageChannel/Estimate_Checklist__c';
import getItems from '@salesforce/apex/QuoteChecklistController.getItems';
import saveItems from '@salesforce/apex/QuoteChecklistController.saveItems';
import UTILITIES_FIELD from '@salesforce/schema/Opportunity.Utilities__c';
import AREAS_FIELD from '@salesforce/schema/Estimate_Checklist__c.Area__c';

const FIELDS = [UTILITIES_FIELD];

export default class QuoteChecklist extends LightningElement {

    _recordId;
    record;
    areaPicklist;
    activeSectionName = 'Responsibilities';    
    showSpinner = false;
    idsToDelete = [];

    @track
    areas = [{name: 'Responsibilities', items: []}];    
    @track
    items;    

    next = false;

    @api 
    get recordId()
    {
        return this._recordId;
    }
    set recordId(value)
    {
        this._recordId = value;
        this.getItems();
    }      

    @wire(MessageContext)
    messageContext;    

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: AREAS_FIELD })  
    wiredPicklistValues({ error, data }) {
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message: reduceErrors(error),
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.areaPicklist = data;
            this.renderItems();
        }    
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message: reduceErrors(error),
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.record = data;
            this.renderItems();
        }
    }

    connectedCallback() {
        console.log('connectedCallback');               
    }    

    renderItems() {        
        console.log('renderItems');
        if (this.record && this.areaPicklist && this.items)
        {
            console.log(this.areaPicklist);
            let utilities = getFieldValue(this.record, UTILITIES_FIELD);
            if (utilities)
            {
                let utilityItems = utilities.split(';');
                if (utilityItems)
                {
                    this.areas = [{name: 'Responsibilities', items: []}];
                    console.log(this.areaPicklist);
                    utilityItems.forEach(item => {
                        let areaName = item;
                        if (areaName === 'Electric')
                        {
                            areaName = 'Electricity'
                        }
                        this.areaPicklist.values.forEach(picklistItem => {
                            if (picklistItem.value === areaName)
                            {
                                let area = {name: areaName, items: []};                        
                                this.areas.push(area);                            
                            }
                        });
                    });
                }
                
            }        
            this.areas.forEach( item => {
                item.items = [];            
                this.items.forEach(i => {
                    if (item.name === i.Area__c) //Group by Area
                    {
                        item.items.push(i);
                    }
                });                                                                
            });
            publish(this.messageContext, ESTIMATE_CHECKLIST_CHANNEL, this.areas); 
        }     
    }

    getItems() {
        this.showSpinner = true;
        getItems({recordId: this.recordId}).then(result => {
            console.log(result);
            this.items = result;
            this.renderItems();
        }).catch(error => {
            console.log(error);            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: reduceErrors(error),
                    variant: 'error'
                })
            );            
        }).finally(() => { 
            this.showSpinner = false;
        });
    }

    handleToggleSection(event) {
        console.log('handleToggleSection');
    }

    addItem(event) {
        console.log('addItem');
        let areaName = event.target.dataset.area;
        console.log(areaName);
        let area = this.areas.find(item => item.name === areaName);
        let item = {};
        item.Id = generateGUID();
        area.items.push(item);
        //console.log(this.areas);
    }

    removeItem(event) {
        console.log('removeItem');
        let areaName = event.target.dataset.area;
        let id = event.target.dataset.id;
        console.log(areaName + '|' + id);
        let area = this.areas.find(item => item.name === areaName);
        let index = area.items.findIndex(i => i.Id === id);        
        area.items.splice(index, 1);
        this.idsToDelete.push(id);
        //console.log(this.areas);
    }  

    handleTitleChanged(event) {
        console.log('handleTitleChanged');
        let value = event.target.value;
        console.log(value);
        let areaName = event.target.dataset.area;
        let id = event.target.dataset.id;
        console.log(areaName + '|' + id);
        let area = this.areas.find(item => item.name === areaName);
        let item = area.items.find(i => i.Id === id);         
        item.Title__c = value;
    }

    handleResponsibilityChanged(event) {
        console.log('handleResponsibilityChanged');
        let value = event.target.value;
        console.log(value);
        let areaName = event.target.dataset.area;
        let id = event.target.dataset.id;
        console.log(areaName + '|' + id);
        let area = this.areas.find(item => item.name === areaName);
        let item = area.items.find(i => i.Id === id);         
        item.Responsibility__c = value;
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
        this.showSpinner = true;
        let items = [];
        this.areas.forEach(item => {            
            item.items.forEach(i => {
                i.Area__c = item.name;
                items.push(i);
            });            
        });
        saveItems({recordId: this.recordId, items: items, idsToDelete: this.idsToDelete}).then(result => {
            console.log(result);
            this.items = result;
            this.renderItems();   
            if (this.next)       
                this.dispatchEvent(new CustomEvent('save'));
            this.next = false;
        }).catch(error => {
            console.log(error);                        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: reduceErrors(error),
                    variant: 'error'
                })
            );            
        }).finally(() => { 
            this.idsToDelete = [];
            this.showSpinner = false;
        });
    }
}
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { generateGUID, reduceErrors } from 'c/ldsUtils';
import { publish, MessageContext } from 'lightning/messageService';
import ESTIMATE_CHECKLIST_CHANNEL from '@salesforce/messageChannel/Estimate_Checklist__c';
import getItems from '@salesforce/apex/QuoteChecklistController.getItems';
import saveItems from '@salesforce/apex/QuoteChecklistController.saveItems';

export default class QuoteChecklist extends LightningElement {

    parentId;

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
    areas = [{name: 'Responsibilities', items: []},{name: 'Electricity', items: []},{name: 'Gas', items: []},{name: 'Water', items: []}];    

    @wire(MessageContext)
    messageContext;    
    
    activeSectionName = 'Responsibilities';    
    showSpinner = false;
    idsToDelete = [];

    connectedCallback() {
        console.log('connectedCallback');               
    }  

    renderItems(result) {        
        this.areas.forEach( item => {
            item.items = [];            
            result.forEach(i => {
                if (item.name === i.Area__c) //Group by Area
                {
                    item.items.push(i);
                }
            });                                                                
        });
        publish(this.messageContext, ESTIMATE_CHECKLIST_CHANNEL, this.areas);      
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
        saveItems({recordId: this.parentId, items: items, idsToDelete: this.idsToDelete}).then(result => {
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
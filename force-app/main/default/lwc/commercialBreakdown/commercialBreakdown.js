import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { generateGUID, reduceErrors } from 'c/ldsUtils';
import { publish, MessageContext } from 'lightning/messageService';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { createRecord } from 'lightning/uiRecordApi';

import SCHEME_TYPE_BREAKDOWN_OBJECT from "@salesforce/schema/Scheme_Type_Breakdown__c";

import saveSchemeBreakdown from "@salesforce/apex/NewQuoteEstimateController.saveSchemeBreakdown";
import query from '@salesforce/apex/NewQuoteEstimateController.query';

const columns = [
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'KVA', fieldName: 'KVA__c', type: 'number' }
];

export default class CommercialBreakdown extends LightningElement {


    @api schemeTypeName;
    @api utilityType;

    @api
    get parentId() {
        return this._parentId;
    }
    set parentId(value) {
        this._parentId = value;
        this.initital();
    }

    @api
    get numberOfPlot() {
        return this._numberOfPlot;
    }
    set numberOfPlot(value) {
        this._numberOfPlot = value;
        //this.initital();
    }

    @track schemeTypes = [];

    columns = columns;
    rowOffset = 0;
    typeName;
    isCommercial = false;
    isLandlords = false;
    isSubstation = false;
    _numberOfPlot;
    _parentId;
    rtis;
    existingBreakdown = [];
    typeColName;
    showSpinner = false;

    connectedCallback() {
        console.log('connectedCallback');
        this.initital();
    }

    @wire(getObjectInfo, { objectApiName: SCHEME_TYPE_BREAKDOWN_OBJECT })
    ObjectInfo(result, error) {
        if (result.data) {
            //console.log(JSON.stringify(result.data));
            this.siteSchemeInfo = result;
            if (result.data.recordTypeInfos) {
                this.rtis = this.siteSchemeInfo.data.recordTypeInfos;
                console.log("recordTypeInfos");
                this.initital();
            }
        }
        if (error) {
            console.error(error);
        }

    }


    get showType() {
        if (this.schemeTypeName == 'Commercial' || this.schemeTypeName == 'Landlords') 
        {
            if(this.utilityType == 'Electric')
            {
                this.typeColName = 'Phase Type';
            }
            else if(this.utilityType == 'Water')
            {
                this.typeColName = 'Supply Type';
            }
            
            return true;
        }
        else return false;
    }

    get showKVA() {
        if (this.schemeTypeName == 'Commercial' || this.schemeTypeName == 'Substation') return true;
        else return false;
    }
    get showQuantity() {
        if (this.schemeTypeName == 'Landlords') return true;
        else return false;
    }
    get disableSave() {
        if (typeof this._parentId == 'undefined' || this._parentId == '' || this._parentId == null) return true;
        else return false;
    }


    inputChanged(event) {
        console.log('inputChanged');
        console.log(this.schemeTypes);
        let name = event.target.name;
        if (typeof event.target.name == 'undefined' && event.target.fieldName)
            name = event.target.fieldName;

        let value = event.target.value;
        let index = event.target.dataset.index;
        let schemetype = event.target.dataset.schemetype;
        let item;

        item = this.schemeTypes.find(item => item.index == index);
        item[name] = value;

        const customEventCheck = new CustomEvent("update", {        
            detail: this.schemeTypes /* here is the problem */
        });
        this.dispatchEvent(customEventCheck); 

    }


    initital() {
        if (this.rtis) {
            if (this.schemeTypeName && this.utilityType && this.existingBreakdown.length == 0) {
                if (this._parentId) {
                    query({
                        q: "SELECT Id, RecordTypeId, RecordType.Name, KVA__c,Utility_Type__c,Quantity__c,Type__c,Site_Scheme__c  FROM Scheme_Type_Breakdown__c WHERE Site_Scheme__c = '" + this._parentId + "' AND RecordType.Name = '" + this.schemeTypeName + "' AND Utility_Type__c ='" + this.utilityType + "' ORDER BY Name "
                    })
                        .then((result) => {
                            this.existingBreakdown = result;
                            console.log(this.existingBreakdown);

                            if (this.schemeTypeName == 'Commercial') {

                                if (this.existingBreakdown.length > 0) {
                                    this.schemeTypes = [];
                                    if (this._numberOfPlot >= this.existingBreakdown.length) {
                                        for (let i = 0; i < this.existingBreakdown.length; i++) {
                                            let schemeType = {};
                                            schemeType.index = i + 1;
                                            schemeType.Id = this.existingBreakdown[i].Id;
                                            schemeType.RecordTypeId = this.existingBreakdown[i].RecordTypeId;
                                            schemeType.Site_Scheme__c = this.existingBreakdown[i].Site_Scheme__c;
                                            schemeType.Utility_Type__c = this.existingBreakdown[i].Utility_Type__c;
                                            schemeType.Type__c = this.existingBreakdown[i].Type__c;
                                            schemeType.KVA__c = this.existingBreakdown[i].KVA__c;
                                            schemeType.schemeTypeName = this.schemeTypeName;
                                            this.schemeTypes.push(schemeType);
                                        }


                                        for (let i = 0; i < this._numberOfPlot - this.existingBreakdown.length; i++) {
                                            let schemeType = {};
                                            schemeType.index = this.schemeTypes.length + 1;
                                            schemeType.RecordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                                            schemeType.Site_Scheme__c = this._parentId;
                                            schemeType.Utility_Type__c = this.utilityType;
                                            schemeType.KVA__c = 0;
                                            schemeType.schemeTypeName = this.schemeTypeName;
                                            this.schemeTypes.push(schemeType);
                                        }
                                    }
                                    else if (this._numberOfPlot < this.existingBreakdown.length) {

                                        for (let i = 0; i < this.existingBreakdown.length; i++) {
                                            if (i < this._numberOfPlot) {
                                                let schemeType = {};
                                                schemeType.index = i + 1;
                                                schemeType.Id = this.existingBreakdown[i].Id;
                                                schemeType.RecordTypeId = this.existingBreakdown[i].RecordTypeId;
                                                schemeType.Site_Scheme__c = this.existingBreakdown[i].Site_Scheme__c;
                                                schemeType.Utility_Type__c = this.existingBreakdown[i].Utility_Type__c;
                                                schemeType.Type__c = this.existingBreakdown[i].Type__c;
                                                schemeType.KVA__c = this.existingBreakdown[i].KVA__c;
                                                schemeType.schemeTypeName = this.schemeTypeName;
                                                this.schemeTypes.push(schemeType);
                                            }
                                        }


                                    }
                                }
                                else {
                                    this.initialCommercial();
                                }
                                this.isCommercial = true;
                            }
                            else if (this.schemeTypeName == 'Landlords') {
                                if (this.existingBreakdown.length > 0) {
                                    this.schemeTypes = [];
                                    for (let i = 0; i < this.existingBreakdown.length; i++) {
                                        let schemeType = {};
                                        schemeType.index = i + 1;
                                        schemeType.Id = this.existingBreakdown[i].Id;
                                        schemeType.RecordTypeId = this.existingBreakdown[i].RecordTypeId;
                                        schemeType.Site_Scheme__c = this.existingBreakdown[i].Site_Scheme__c;
                                        schemeType.Utility_Type__c = this.existingBreakdown[i].Utility_Type__c;
                                        schemeType.Type__c = this.existingBreakdown[i].Type__c;
                                        schemeType.Quantity__c = this.existingBreakdown[i].Quantity__c;
                                        schemeType.schemeTypeName = this.schemeTypeName;
                                        this.schemeTypes.push(schemeType);
                                    }
                                }
                                else {
                                    this.initialLandlords();
                                }

                                this.isLandlords = true;

                            }
                            else if (this.schemeTypeName == 'Substation') {
                                if (this.existingBreakdown.length > 0) {
                                    this.schemeTypes = [];
                                    if (this._numberOfPlot >= this.existingBreakdown.length) {
                                        for (let i = 0; i < this.existingBreakdown.length; i++) {
                                            let schemeType = {};
                                            schemeType.index = i + 1;
                                            schemeType.Id = this.existingBreakdown[i].Id;
                                            schemeType.RecordTypeId = this.existingBreakdown[i].RecordTypeId;
                                            schemeType.Site_Scheme__c = this.existingBreakdown[i].Site_Scheme__c;
                                            schemeType.Utility_Type__c = this.existingBreakdown[i].Utility_Type__c;
                                            //schemeType.Type__c = this.existingBreakdown[i].Type__c;
                                            schemeType.KVA__c = this.existingBreakdown[i].KVA__c;
                                            schemeType.schemeTypeName = this.schemeTypeName;
                                            this.schemeTypes.push(schemeType);
                                        }


                                        for (let i = 0; i < this._numberOfPlot - this.existingBreakdown.length; i++) {
                                            let schemeType = {};
                                            schemeType.index = this.schemeTypes.length + 1;
                                            schemeType.RecordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                                            schemeType.Site_Scheme__c = this._parentId;
                                            schemeType.Utility_Type__c = this.utilityType;
                                            schemeType.KVA__c = 0;
                                            schemeType.schemeTypeName = this.schemeTypeName;
                                            this.schemeTypes.push(schemeType);
                                        }
                                    }
                                    else if (this._numberOfPlot < this.existingBreakdown.length) {

                                        for (let i = 0; i < this.existingBreakdown.length; i++) {
                                            if (i < this._numberOfPlot) {
                                                let schemeType = {};
                                                schemeType.index = i + 1;
                                                schemeType.Id = this.existingBreakdown[i].Id;
                                                schemeType.RecordTypeId = this.existingBreakdown[i].RecordTypeId;
                                                schemeType.Site_Scheme__c = this.existingBreakdown[i].Site_Scheme__c;
                                                schemeType.Utility_Type__c = this.existingBreakdown[i].Utility_Type__c;
                                                //schemeType.Type__c = this.existingBreakdown[i].Type__c;
                                                schemeType.KVA__c = this.existingBreakdown[i].KVA__c;
                                                schemeType.schemeTypeName = this.schemeTypeName;
                                                this.schemeTypes.push(schemeType);
                                            }
                                        }
                                    }
                                }
                                else {

                                    this.initialSubstation();
                                }
                                this.isSubstation = true;

                            }
                        });
                }
                else {
                    if (this.schemeTypeName == 'Commercial') {
                        this.initialCommercial();
                    }
                    else if (this.schemeTypeName == 'Landlords') {
                        this.initialLandlords();
                    }
                    else if (this.schemeTypeName == 'Substation') {
                        this.initialSubstation();
                    }
                }
            }
        }
    }


    initialCommercial() {
        //this.schemeTypes = [];
        if (this.schemeTypes.length == 0) {
            for (let i = 0; i < this._numberOfPlot; i++) {
                let schemeType = {};
                schemeType.index = i + 1;
                schemeType.RecordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                schemeType.Site_Scheme__c = this._parentId;
                schemeType.Utility_Type__c = this.utilityType;
                schemeType.KVA__c = 0;
                schemeType.schemeTypeName = this.schemeTypeName;
                this.schemeTypes.push(schemeType);
            }
        }
        else if (this.schemeTypes.length == this._numberOfPlot && this._parentId) {
            this.schemeTypes.forEach(item => {
                item.Site_Scheme__c = this._parentId;
            });


        }
        console.log('initialCommercial');
        console.log(this.schemeTypes);

    }

    initialLandlords() {
        if (this.schemeTypes.length == 0) 
        {
            for (let i = 0; i < 2; i++) {
                let schemeType = {};
                schemeType.index = i + 1;
                schemeType.RecordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                schemeType.Site_Scheme__c = this._parentId;
                if (this.utilityType == 'Electric')
                {
                    if(schemeType.index == 1)
                        schemeType.Type__c = '1 Phase';
                    else
                        schemeType.Type__c = '3 Phase';
                } 
                else if (this.utilityType == 'Water') 
                {
                    if(schemeType.index == 1)
                        schemeType.Type__c = '25 mm';
                    else
                        schemeType.Type__c = '32 mm';
                }
                schemeType.Utility_Type__c = this.utilityType;
                schemeType.Quantity__c = 0;
                schemeType.schemeTypeName = this.schemeTypeName;
                this.schemeTypes.push(schemeType);
            }
        }
        else if (this.schemeTypes.length > 0 && this._parentId) {
            this.schemeTypes.forEach(item => {
                item.Site_Scheme__c = this._parentId;
            });
        }

        this.isLandlords = true;
        console.log('initialLandlords');
        console.log(this.schemeTypes);

    }

    initialSubstation() {
        if (this.schemeTypes.length == 0) 
        {
            for (let i = 0; i < this._numberOfPlot; i++) {
                let schemeType = {};
                schemeType.index = i + 1;
                schemeType.RecordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                schemeType.Site_Scheme__c = this._parentId;
                schemeType.Utility_Type__c = this.utilityType;
                schemeType.KVA__c = 0;
                schemeType.schemeTypeName = this.schemeTypeName;
                this.schemeTypes.push(schemeType);
            }
        }
        else if (this.schemeTypes.length > 0 && this._parentId) {
            this.schemeTypes.forEach(item => {
                item.Site_Scheme__c = this._parentId;
            });
        }

        console.log('initialSubstation');
        console.log(this.schemeTypes);

    }

    save(event) {
        event.preventDefault();
        this.showSpinner = true;
        let schemeTypeBreakdowns = [];
        let allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        let totalQuantity = 0;
        let validQuantity = false;

        let quantity = [...this.template.querySelectorAll('.quantity')]
        quantity.forEach(item => {
            console.log(item.value);
            totalQuantity += parseInt(item.value);
        });

        if (totalQuantity > parseInt(this._numberOfPlot)) {
            //quantity.setCustomValidity("Quantity cannot more than No of Landlord");
            //quantity.reportValidity(); 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: "Quantity cannot more than No of Landlord",
                    variant: 'error',
                }),
            );
        }
        else
            validQuantity = true;

        if (allValid && validQuantity) {
            this.schemeTypes.forEach(item => {
                //if (item.Product2Id__r.Id) {
                let schemeTypeBreakdown = {};
                schemeTypeBreakdown.Id = item.Id;
                schemeTypeBreakdown.RecordTypeId = item.RecordTypeId;
                schemeTypeBreakdown.Site_Scheme__c = item.Site_Scheme__c;
                schemeTypeBreakdown.Utility_Type__c = item.Utility_Type__c;
                schemeTypeBreakdown.Type__c = item.Type__c;
                if (item.Quantity__c != null && item.Quantity__c != '' && item.Quantity__c > 0)
                    schemeTypeBreakdown.Quantity__c = parseFloat(item.Quantity__c);
                if (item.KVA__c != null && item.KVA__c != '' && item.KVA__c > 0)
                    schemeTypeBreakdown.KVA__c = parseFloat(item.KVA__c);
                schemeTypeBreakdowns.push(schemeTypeBreakdown);
                //}

            });
            console.log(schemeTypeBreakdowns);
        }

        saveSchemeBreakdown({
            parentId: this._parentId,
            schemeBreakdown: schemeTypeBreakdowns,
            recordTypeName: this.schemeTypeName,
            utilityType: this.utilityType,
            numberOfPlot: this._numberOfPlot
        })
            .then(result => {
                if (result && result.length !== 0) {
                    console.log(result);
                    this.showSpinner = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: "Scheme Breakdown has been created",
                            variant: 'success',
                        }),
                    );

                }
            })
            .catch(error => {
                console.log('Error in save: ' + JSON.stringify(error));
                let errorMessage = (error && error.body && error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].message) || '';
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body,
                });
                this.dispatchEvent(event);
                this.showSpinner = false;
            });
    }
}
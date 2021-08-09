import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { generateGUID, reduceErrors } from 'c/ldsUtils';
import { publish, MessageContext } from 'lightning/messageService';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { createRecord } from 'lightning/uiRecordApi';

import SCHEME_TYPE_BREAKDOWN_OBJECT from "@salesforce/schema/Scheme_Type_Breakdown__c";

import saveSchemeBreakdown from "@salesforce/apex/NewQuoteEstimateController.saveSchemeBreakdown";
import ParentId from '@salesforce/schema/Account.ParentId';

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
        this.initital();
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

    connectedCallback() {
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
        if (this.schemeTypeName == 'Commercial' || this.schemeTypeName == 'Landlords') return true;
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
        if (schemetype == 'Commercial') {

            //item.Quantity__c = item.Quantity__c || 0;

        }
        else if (this.schemeTypeName == 'Landlords') {

        }
        else if (this.schemeTypeName == 'Substation') {

        }
    }


    initital() {

        if (this.rtis) {

            query({
                q: "SELECT Id FROM Scheme_Type_Breakdown__c WHERE Site_Scheme__c = '" + this._parentId + "' AND RecordType.Name = '" + this.schemeTypeName + "' AND Utility_Type__c ='" + this.utilityType + "'"
            })
                .then((result) => {
                    if (result && result.length !== 0) {
                        console.log(result);
                    }
                });


            if (this.schemeTypeName == 'Commercial') {
                this.schemeTypes = [];
                for (let index = 0; index < this._numberOfPlot; index++) {
                    let schemeType = {};
                    schemeType.index = index + 1;
                    schemeType.recordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                    schemeType.Site_Scheme__c = this._parentId;
                    schemeType.Utility_Type__c = this.utilityType;
                    schemeType.KVA__c = 0;
                    schemeType.schemeTypeName = this.schemeTypeName;
                    this.schemeTypes.push(schemeType);
                }
                this.isCommercial = true;
            }
            else if (this.schemeTypeName == 'Landlords') {
                this.schemeTypes = [];
                let schemeType = {};
                schemeType.index = 1;
                schemeType.recordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                schemeType.Site_Scheme__c = this._parentId;
                if (this.utilityType == 'Electric') schemeType.Type__c = '1 Phase';
                else if (this.utilityType == 'Water') schemeType.Type__c = '25 mm';
                schemeType.Utility_Type__c = this.utilityType;
                schemeType.Quantity__c = 0;
                schemeType.schemeTypeName = this.schemeTypeName;
                this.schemeTypes.push(schemeType);

                schemeType = {};
                schemeType.index = 2;
                schemeType.recordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                schemeType.Site_Scheme__c = this._parentId;
                if (this.utilityType == 'Electric') schemeType.Type__c = '3 Phase';
                else if (this.utilityType == 'Water') schemeType.Type__c = '32 mm';
                schemeType.Utility_Type__c = this.utilityType;
                schemeType.Quantity__c = 0;
                schemeType.schemeTypeName = this.schemeTypeName;
                this.schemeTypes.push(schemeType);

                this.isLandlords = true;

            }
            else if (this.schemeTypeName == 'Substation') {

                this.schemeTypes = [];
                for (let index = 0; index < this.numberOfPlot; index++) {
                    let schemeType = {};
                    schemeType.index = index + 1;
                    schemeType.recordTypeId = Object.keys(this.rtis).find(rti => this.rtis[rti].name === this.schemeTypeName);
                    schemeType.Site_Scheme__c = this._parentId;
                    schemeType.Utility_Type__c = this.utilityType;
                    schemeType.KVA__c = 0;
                    schemeType.schemeTypeName = this.schemeTypeName;
                    this.schemeTypes.push(schemeType);
                }
                this.isSubstation = true;

            }
        }
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

        if(totalQuantity > parseInt(this._numberOfPlot))
        {
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
                schemeTypeBreakdown.RecordTypeId = item.recordTypeId;
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
            utilityType: this.utilityType
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
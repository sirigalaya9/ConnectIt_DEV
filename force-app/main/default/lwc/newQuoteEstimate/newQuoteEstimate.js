import { LightningElement, api, wire, track } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue, createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getRecordCreateDefaults } from 'lightning/uiRecordApi';


import OPPORTUNITY_OBJECT from "@salesforce/schema/Opportunity";
import SITE_SCHEME_OBJECT from "@salesforce/schema/Site_Scheme__c";
import SITE from "@salesforce/schema/Opportunity.Site__c";
import SITE_NAME from "@salesforce/schema/Opportunity.Site__r.Name";
import PROJECT from "@salesforce/schema/Opportunity.Project__c";
import ClOSEDATE from "@salesforce/schema/Opportunity.CloseDate";
import TYPE from "@salesforce/schema/Opportunity.Type";
import PROPERTYTYPE from "@salesforce/schema/Opportunity.Property_Type__c";
import UTILITIES from "@salesforce/schema/Opportunity.Utilities__c";
import CONTACTNAME from "@salesforce/schema/Opportunity.Contact_Name__c";
import CREATEDDATE from "@salesforce/schema/Opportunity.CreatedDate";
import userId from "@salesforce/user/Id";

import searchProduct from "@salesforce/apex/NewQuoteEstimateController.searchProduct";
//import searchDefaultProducts from "@salesforce/apex/RuleController.getProducts";
import getInitialLineItems from "@salesforce/apex/NewQuoteEstimateController.getInitialLineItems";
import query from '@salesforce/apex/NewQuoteEstimateController.query';
import saveUtilityProducts from '@salesforce/apex/NewQuoteEstimateController.saveUtilityProducts';
import createEstimate from '@salesforce/apex/NewQuoteEstimateController.createEstimate';
import searchRule from "@salesforce/apex/NewQuoteEstimateController.searchRule";
import getrelatedRules from "@salesforce/apex/NewQuoteEstimateController.getrelatedRules";
import addCoreToUtilityProducts from "@salesforce/apex/NewQuoteEstimateController.addCoreToUtilityProducts";
import getCoreProductsByRules from "@salesforce/apex/NewQuoteEstimateController.getCoreProductsByRules";
import getExistingScheme from "@salesforce/apex/NewQuoteEstimateController.getExistingScheme";

//import getNumberOfAvailableRules from "@salesforce/apex/NewQuoteEstimateController.getNumberOfAvailableRules";



import TOTALKITSELL from "@salesforce/schema/Opportunity.Total_Kit_Sell__c";
import TOTALLABOURSELL from "@salesforce/schema/Opportunity.Total_Labour_Sell__c";
import TOTALMATERIALSELL from "@salesforce/schema/Opportunity.Total_Material_Sell__c";
import TOTALPLANTSELL from "@salesforce/schema/Opportunity.Total_Plant_Sell__c";
import TOTALCLIENTCONTRIBUTION from "@salesforce/schema/Opportunity.Total_Client_Contribution__c";

import RECORDTYPEID from "@salesforce/schema/Opportunity.RecordTypeId";
import RECORDTYPENAME from "@salesforce/schema/Opportunity.RecordType.Name";
import PRICEBOOK2ID from '@salesforce/schema/Opportunity.Pricebook2Id';

const _FIELDS = [
    RECORDTYPEID, RECORDTYPENAME, SITE, PROJECT, ClOSEDATE, TYPE, PROPERTYTYPE, UTILITIES,
    TOTALKITSELL, TOTALLABOURSELL, TOTALMATERIALSELL, TOTALPLANTSELL, TOTALCLIENTCONTRIBUTION,
    PRICEBOOK2ID, SITE_NAME, CONTACTNAME, CREATEDDATE
];

const columns = [
    { label: 'Rule Name', fieldName: 'Name', type: 'text' },
    { label: 'Description', fieldName: 'Description__c', type: 'text' }
];

/*cellAttributes: { class: 'slds-text-color_success slds-text-title_caps'}*/


export default class NewQuoteEstimate extends NavigationMixin(LightningElement) {
    @api recordId;

    @track selectedOption;
    @track options;
    @track opp_RT_Name;
    @track opp_Project;
    @track opp_Site;
    @track opp_Id;
    @track site_name;
    @track user_name;
    @track user_title;
    @track user_phone;
    @track user_email;
    @track createddate;
    @track closedate;
    @track contact_name;
    @track currentStep = '1';
    @track firstPage = true;
    @track lastPage = false;
    @track preDisabled = true;
    @track nextDisabled = false;
    @track siteSchemeInfo;
    @track electric_RTId;
    @track gas_RTId;
    @track water_RTId;
    @track eletricItems = [];
    @track waterItems = [];
    @track gasItems = [];
    @track selectedUtilityList = [];
    @track schemeItems = [];

    @track _utilityItems = [];
    @track _labourSellItems = [];
    @track _plantSellItems = [];
    @track TotalKitSell = 0;
    @track TotalLabourSell = 0;
    @track TotalMaterialSell = 0;
    @track TotalPlantSell = 0;
    @track TotalClientContribution = 0;
    @track saveDisabled = false;
    @track data; // = data;
    @track columns = columns;
    @track noOfAvailableRules = 0;
    @track noOfSeletcedRules = 0;


    _selected = [];
    showSpinner = false;
    closeWindow = false;
    activeSectionMessage = '';
    removedItems = [];
    productIdSet = [];
    showDeleteProductModal = false;
    showSelectRuleModal = false;
    productToDeleteId;
    productToDeleteIndex;
    productToDeleteParentIndex;
    currentAddedIndex;
    currentAddedNewIndex;
    rtis;
    pdfBase64Data = '';
    blob;
    _quoteId;
    _contentVersionId;
    _contentDocumentId;
    ProductFamilyScheme;
    NumberofPlots;
    rule_eletric;
    selectedRules = [];
    selectedRuleUtilityType;
    selectedRuleParentIndex;
    showSelectUtilityTypeModal = false;
    eletric_totalNumberOfPlots = 0;
    gas_totalNumberOfPlots = 0;
    water_totalNumberOfPlots = 0;
    street_totalNumberOfPlots = 0;
    isHV = false;
    isLV = false;

    showElectricCommercial = false;
    showElectricLandlords = false;
    electricCommercialNumberofPlots = 0;



    userData;
    getUserInfo() {
        console.log("UserInfo");
        console.log("userId " + userId);
        query({
            q:
                "SELECT Id, Name, Title, MobilePhone, Email, Phone FROM User WHERE Id ='" +
                userId +
                "'"
        }).then((result) => {
            if (result && result.length !== 0) {
                //this.userProfileName = result[0].Profile.Name;
                console.log(result[0]);
                this.user_name = result[0].Name;
                this.user_title = result[0].Title;
                this.user_phone = result[0].Phone;
                this.user_email = result[0].Email;
            }
        });
    }


    @wire(getObjectInfo, { objectApiName: SITE_SCHEME_OBJECT })
    ObjectInfo(result, error) {
        if (result.data) {
            //console.log(JSON.stringify(result.data));
            this.siteSchemeInfo = result;
            if (result.data.recordTypeInfos) {
                this.rtis = this.siteSchemeInfo.data.recordTypeInfos;
                console.log("recordTypeInfos");
            }
        }
        if (error) {
            console.error(error);
        }

    }

    opportunity;
    @wire(getRecord, { recordId: "$recordId", fields: _FIELDS })
    getRecord(result) {
        console.log(this.recordId);
        console.log("getRecord");
        let selectedUtility = '';
        if (result.data) {
            this.opportunity = result;
            this.opp_Id = this.recordId;
            this.opp_RT_Name = this.opportunity.data.recordTypeInfo.name;
            this.opp_Project = this.opportunity.data.fields.Project__c.value;
            this.opp_Site = this.opportunity.data.fields.Site__c.value;
            this.site_name = this.opportunity.data.fields.Site__r.value.fields.Name.value;
            this.contact_name = this.opportunity.data.fields.Contact_Name__c.value;
            this.createddate = this.opportunity.data.fields.CreatedDate.value;
            this.closedate = this.opportunity.data.fields.CloseDate.value;

            selectedUtility = this.opportunity.data.fields.Utilities__c.value;
            console.log(selectedUtility);
            this.selectedUtilityList = String(selectedUtility).split(';');
            console.log(this.opportunity);

            //this.defaultOpportunityData();
        }

    }

    connectedCallback() {
        console.log('connectedCallback');
        this.getUserInfo();
    }


    get labourSellItems() {
        console.log('labourSellItems');
        return this._labourSellItems;
    }

    get plantSellItems() {
        console.log('plantSellItems');
        return this._plantSellItems;
    }

    get utilityItems() {
        console.log('utilityItems');

        return this._utilityItems;
    }

    get contentVersionId() {
        return this._contentVersionId;
    }

    get contentDocumentId() {
        return this._contentDocumentId;
    }

    get quoteId() {
        return this._quoteId;
    }

    initialCreateScheme() {

        if (this.rtis && this.selectedUtilityList.length > 0) {

            getExistingScheme({
                oppId: this.recordId,
                selectedUtilityList: this.selectedUtilityList
            })
                .then(schemes => {
                    let schemeIdMap = new Map();
                    let schemeFieldValuesMap = new Map();
                    for (var key in schemes) {
                        schemeIdMap.set(key, schemes[key].Id);
                        schemeFieldValuesMap.set(key, schemes[key]);
                    }

                    this.schemeItems = [];
                    this.selectedUtilityList.forEach(selectedUtility => {
                        console.log('selectedUtility: ' + selectedUtility);
                        let recordTypeName;
                        if (selectedUtility == 'Street Lighting') recordTypeName = 'StreetLighting';
                        else if (selectedUtility == 'Charge Points') recordTypeName = 'Charger';
                        else recordTypeName = selectedUtility;
                        console.log('recordTypeName: ' + recordTypeName);
                        let count = this.schemeItems.length;
                        console.log('count: ' + count);

                        let utilityItem = {
                            index: count++,
                            recordId: schemeIdMap.get(recordTypeName),
                            isElectric: false,
                            isGas: false,
                            isWater: false,
                            isStreetLightning: false,
                            isCharger: false,
                            isFibre: false,
                            isHV: false,
                            showCommercial: false,
                            showLandlord: false,
                            showSubstation: false,
                            numberOfCommercial: 0,
                            numberOfLandlord: 0,
                            numberOfSubstations: 0,
                            utilityType: selectedUtility,
                            utilityRecordTypeId: Object.keys(this.rtis).find(rti => this.rtis[rti].name === recordTypeName)
                        }


                        if (selectedUtility == 'Electric') {
                            utilityItem.isElectric = true;

                            if (schemeFieldValuesMap.get(recordTypeName)) {
                                if (typeof schemeFieldValuesMap.get(recordTypeName).No_of_Commercial__c != 'undefined' &&
                                    schemeFieldValuesMap.get(recordTypeName).No_of_Commercial__c > 0) {
                                    utilityItem.showCommercial = true;
                                    utilityItem.numberOfCommercial = schemeFieldValuesMap.get(recordTypeName).No_of_Commercial__c;
                                }

                                if (typeof schemeFieldValuesMap.get(recordTypeName).No_of_Landlord__c != 'undefined' &&
                                    schemeFieldValuesMap.get(recordTypeName).No_of_Landlord__c > 0) {
                                    utilityItem.showLandlord = true;
                                    utilityItem.numberOfLandlord = schemeFieldValuesMap.get(recordTypeName).No_of_Landlord__c;
                                }

                                if (schemeFieldValuesMap.get(recordTypeName).POC__c == 'HV') {
                                    utilityItem.isHV = true;
                                    if (typeof schemeFieldValuesMap.get(recordTypeName).Number_of_Substations__c != 'undefined' &&
                                        schemeFieldValuesMap.get(recordTypeName).Number_of_Substations__c > 0) {
                                        utilityItem.showSubstation = true;
                                        utilityItem.numberOfSubstations = schemeFieldValuesMap.get(recordTypeName).Number_of_Substations__c;
                                    }
                                }

                            }
                        }
                        else if (selectedUtility == 'Water') {
                            utilityItem.isWater = true;

                            if (schemeFieldValuesMap.get(recordTypeName)) {
                                if (typeof schemeFieldValuesMap.get(recordTypeName).No_of_Commercial__c != 'undefined' &&
                                    schemeFieldValuesMap.get(recordTypeName).No_of_Commercial__c > 0) {
                                    utilityItem.showCommercial = true;
                                    utilityItem.numberOfCommercial = schemeFieldValuesMap.get(recordTypeName).No_of_Commercial__c;
                                }

                                if (typeof schemeFieldValuesMap.get(recordTypeName).No_of_Landlord__c != 'undefined' &&
                                    schemeFieldValuesMap.get(recordTypeName).No_of_Landlord__c > 0) {
                                    utilityItem.showLandlord = true;
                                    utilityItem.numberOfLandlord = schemeFieldValuesMap.get(recordTypeName).No_of_Landlord__c;
                                }
                            }
                        }
                        else if (selectedUtility == 'Gas') utilityItem.isGas = true;
                        else if (selectedUtility == 'Street Lighting') utilityItem.isStreetLightning = true;
                        else if (selectedUtility == 'Charge Points') 
                        {
                            utilityItem.isCharger = true;
                            
                            if (schemeFieldValuesMap.get(recordTypeName)) {
                                if (schemeFieldValuesMap.get(recordTypeName).POC__c == 'HV') {
                                    utilityItem.isHV = true;
                                    if (typeof schemeFieldValuesMap.get(recordTypeName).Number_of_Substations__c != 'undefined' &&
                                        schemeFieldValuesMap.get(recordTypeName).Number_of_Substations__c > 0) {
                                        utilityItem.showSubstation = true;
                                        utilityItem.numberOfSubstations = schemeFieldValuesMap.get(recordTypeName).Number_of_Substations__c;
                                    }
                                }
                            }

                        }
                        else if (selectedUtility == 'Fibre') utilityItem.isFibre = true;

                        console.log(JSON.stringify(utilityItem));
                        this.schemeItems.push(utilityItem);

                    });
                    console.log(this.schemeItems);

                });

        }

    }


    queryDefaultProducts(isNew) {
        console.log('queryDefaultProducts');
        this.showSpinner = true;
        getInitialLineItems({
            oppId: this.recordId,
            selectedUtilityList: this.selectedUtilityList,
            objectName: 'Site_Scheme__c',
            isNew: isNew
        })
            .then(result => {
                if (result && result.length !== 0) {
                    console.log(result);
                    this._utilityItems = result;

                    let parentIndex = 0;
                    this._utilityItems.forEach(utilityItem => {
                        utilityItem.index = parentIndex++;
                        utilityItem.totalKitSell = 0;
                        utilityItem.totalLabourSell = 0;
                        utilityItem.totalPlantSell = 0;
                        utilityItem.totalClientContribution = 0;
                        utilityItem.noOfAvailableRules = utilityItem.rules.length;
                        utilityItem.noOfSeletcedRules = 0;
                        let index = 0;
                        utilityItem.oppProducts.forEach(oppProduct => {
                            let item = oppProduct.oppLineItem;
                            oppProduct.productUrl = '/' + item.Product2Id__r.Id;
                            oppProduct.index = index++;
                            oppProduct.isNew = false;
                            oppProduct.errors = [];
                            oppProduct.selection = {
                                id: item.Id,
                                sObjectType: 'Product2',
                                icon: 'standard:product',
                                title: item.Name,
                                subtitle: item.Name
                            }
                            oppProduct.isRemoveable = true;
                            oppProduct.oppLineItem.Quantity__c = item.Quantity__c;
                            oppProduct.oppLineItem.Implementor__c = item.Implementor__c;
                            oppProduct.oppLineItem.Kit_Sell__c = item.Kit_Sell__c;
                            oppProduct.oppLineItem.Labour_Sell__c = item.Product2Id__r.Labour_Sell__c;
                            oppProduct.oppLineItem.Plant_Sell__c = item.Product2Id__r.Plant_Sell__c;
                            oppProduct.oppLineItem.Material_Cost__c = item.Material_Cost__c;
                            oppProduct.oppLineItem.Plant_Cost__c = item.Plant_Cost__c;
                            oppProduct.ProductType = 'Baseline';

                            return oppProduct;

                        });

                        this.calculateTotalSell(utilityItem.index);

                        //utilityItem.products.push.apply(utilityItem.products, this.getDefaultProducts(coupledItem.oppProducts));
                    });

                    console.log(this._utilityItems);

                }
                this.showSpinner = false;
            })
            .catch(error => {
                console.log('Error in query: ' + JSON.stringify(error));
                this.showSpinner = false;
            });



    }

    saveUtilityProducts() {
        let utilityProducts = [];

        this._utilityItems.forEach(utilityItem => {
            console.log(utilityItem);
            let utilityProduct = {};
            //coupledProduct.parentProduct = coupledItem.parentProduct;
            //delete coupledProduct.parentProduct.Opportunity_Product__r;

            utilityProduct.oppProducts = [];
            utilityItem.oppProducts.forEach(oppProductItem => {
                console.log(oppProductItem);
                let item = oppProductItem.oppLineItem;
                if (item.Product2Id__r.Id) {
                    let oppProduct = {}
                    oppProduct.oppLineItem = {};

                    if (typeof item.Id != 'undefined') oppProduct.oppLineItem.Id = item.Id;
                    oppProduct.oppLineItem.Quantity__c = parseFloat(item.Quantity__c);
                    oppProduct.oppLineItem.Product2Id__c = item.Product2Id__r.Id;
                    oppProduct.oppLineItem.OpportunityId__c = item.OpportunityId__c;
                    oppProduct.oppLineItem.UnitPrice__c = parseFloat(item.Kit_Sell__c);
                    oppProduct.oppLineItem.Kit_Sell__c = parseFloat(item.Kit_Sell__c);
                    //oppProduct.oppLineItem.Material_Sell__c = parseFloat(item.Material_Sell__c);
                    //oppProduct.oppLineItem.Plant_Sell__c = parseFloat(item.Plant_Sell__c);
                    oppProduct.oppLineItem.Material_Cost__c = parseFloat(item.Material_Cost__c);
                    oppProduct.oppLineItem.Plant_Cost__c = parseFloat(item.Plant_Cost__c);
                    oppProduct.oppLineItem.Implementor__c = item.Implementor__c;
                    oppProduct.oppLineItem.Utility_Type__c = utilityItem.utilityType;

                    /*if (oppProductItem.isNew)
                    {
                        oppProduct.oppLineItem.Product2Id = item.Product2Id;
                        oppProduct.oppLineItem.OpportunityId = item.OpportunityId;
                    }
                    else
                    {
                        oppProduct.oppLineItem.Id = item.Id;
                    }*/

                    utilityProduct.oppProducts.push(oppProduct);
                    console.log(utilityProduct);
                }
            });
            utilityProducts.push(utilityProduct);
            console.log(utilityProducts);

        });

        saveUtilityProducts({
            oppId: this.recordId,
            utilityProducts: utilityProducts
        })
            .then(result => {
                if (result && result.length !== 0) {
                    console.log(result);
                    this.showSpinner = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: "Opportunity Products have been created",
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


    /*queryDefaultProducts_test(utilityType) {
        let items = [];
        searchDefaultProducts({
            utilityType: utilityType,
            name: '',
            ruleId: null
        }).then((result) => {
            if (result && result.length !== 0) {
                console.log(result);

                const clone = JSON.parse(JSON.stringify(result));
                let index = 0;
                items = clone.map((item) => {
                    item.productUrl = "/" + item.Product2.Id;
                    item.index = index++;
                    item.isNew = false;
                    item.errors = [];
                    item.selection = {
                        id: item.Id,
                        sObjectType: "Product2",
                        icon: "standard:product",
                        title: item.Name,
                        subtitle: item.Name
                    };
                    item.Quantity = 0;

                    return item;
                });

                console.log(items);

            }
        })
            .catch((error) => {
                console.log("Error in query: " + JSON.stringify(error));
                //showToast(this, "error", "Error!", JSON.stringify(error.body.message));
            });
    }*/

    addNewProduct(event) {

        console.log('addNewProduct');
        let parentIndex = event.target.dataset.parentindex;
        let utilityType = event.target.dataset.utilitytype;
        console.log('utilityType: ' + utilityType);
        console.log('parentIndex: ' + parentIndex);
        console.log(this._utilityItems);

        let product = {};
        if (utilityType == 'Labour') {
            product.index = this._labourSellItems.length;
            product.isNew = true;
            product.sobjectType = "OpportunityLineItem__c";
            product.OpportunityId__c = this.recordId;
            product.Product2Id__r = {};
            product.selection = null;
            product.errors = [];
            product.Family = utilityType;
            product.placeholderLabel = "Search Product";
            product.isRemoveable = true;
            product.Quantity__c = 1;
            product.Labour_Sell__c = 0;
            product.Labour_Cost__c = null;
            this._labourSellItems.push(product);

        }
        else if (utilityType == 'Plant') {
            product.index = this._plantSellItems.length;
            product.isNew = true;
            product.sobjectType = "OpportunityLineItem__c";
            product.OpportunityId__c = this.recordId;
            product.Product2Id__r = {};
            product.selection = null;
            product.errors = [];
            product.Family = utilityType;
            product.placeholderLabel = "Search Product";
            product.isRemoveable = true;
            product.Quantity__c = 1;
            product.Plant_Sell__c = 0;
            product.Plant_Cost__c = null;
            this._plantSellItems.push(product);
        }
        else {
            let utilityItem = this._utilityItems.find(item => item.index == parentIndex);
            product.index = utilityItem.oppProducts.length;
            product.isNew = true;
            //product.sobjectType = "OpportunityLineItem";
            product.errors = [];
            product.placeholderLabel = "New Product";
            product.isRemoveable = true;

            product.oppLineItem = {};
            product.oppLineItem.OpportunityId__c = this.recordId;
            product.oppLineItem.Product2Id__r = {};
            if (utilityType == 'Electric') product.oppLineItem.Product2Id__r.Family = 'Electricity';
            else product.oppLineItem.Product2Id__r.Family = utilityType;
            product.oppLineItem.Quantity__c = 1;
            product.oppLineItem.Kit_Sell__c = 0;
            //product.oppLineItem.Material_Sell__c = 0;
            //product.oppLineItem.Plant_Sell__c = 0;

            product.selection = null;
            product.errors = [];
            product.placeholderLabel = 'Search Product';
            product.isRemoveable = true;

            utilityItem.oppProducts.push(product);
        }

        this.currentAddedNewIndex = product.index;
    }

    /*addLabourProduct(event) {

        console.log('addLabourProduct');
        let product = {};
            product.index = this._labourSellItems.length;
            product.isNew = true;
            product.sobjectType = "OpportunityLineItem";
            product.OpportunityId = this.recordId;
            product.Product2 = {};
            product.selection = {};
            product.errors = [];
            product.Family = 'Labour';
            product.placeholderLabel = "Search Product";
            product.isRemoveable = true;
            product.Quantity = 0;
            product.Labour_Sell__c = 0;
            
            this._labourSellItems.push(product);
            this.currentAddedIndex = product.index;
    }*/

    handleSearch(event) {
        console.log("handleSearch");
        console.log(event.target.dataset.index);
        let index = event.target.dataset.index;
        let searchTerm = event.detail.searchTerm;
        let utilityType = event.target.dataset.utilitytype;
        console.log('utilityType: ' + utilityType);
        // Call Apex endpoint to search for records and pass results to the lookup

        searchProduct({
            searchKeyWord: searchTerm,
            utilityType: utilityType
        })
            .then((results) => {
                console.log(results);
                this.template
                    .querySelector('c-lookup[data-index="' + index + '"][data-utilityType="' + utilityType + '"]')
                    .setSearchResults(results);
            })
            .catch((error) => {
                //this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error("Lookup error", JSON.stringify(error));
                this.errors = [error];
            });


    }

    handleProductFamilyChange(event) {
        let utilityType = event.target.dataset.utilitytype;
        //this.ProductFamilyScheme = event.target.value;
        let lookups = this.template.querySelectorAll('c-lookup[data-utilityType="' + utilityType + '"]');
        for (var i = 0; i < lookups.length; i++) {
            console.log(lookups[i]);
            lookups[i].handleClearSelection();
        }
    }

    handleNumberofPlotsChange(event) {
        //this.NumberofPlots = event.target.value;
        let utilityType = event.target.dataset.utilitytype;
        this.ProductFamilyScheme = event.target.value;
        let lookups = this.template.querySelectorAll('c-lookup[data-utilityType="' + utilityType + '"]');
        for (var i = 0; i < lookups.length; i++) {
            console.log(lookups[i]);
            lookups[i].handleClearSelection();
        }
    }

    handleSearchRule(event) {
        console.log("handleSearchRule");
        //console.log(event.target.dataset.index);
        //let index = event.target.dataset.index;
        let searchTerm = event.detail.searchTerm;
        let utilityType = event.target.dataset.utilitytype;
        console.log('utilityType: ' + utilityType);
        const inputFields = this.template.querySelectorAll('lightning-input-field[data-utilitytype="' + utilityType + '"]');
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName === "Product_Family__c") {
                    this.ProductFamilyScheme = field.value;
                }
                else if (field.fieldName === "No_of_Units__c") {
                    this.NumberofPlots = field.value;
                }
            });
        }

        console.log('ProductFamilyScheme: ' + this.ProductFamilyScheme);
        console.log('NumberofPlots: ' + this.NumberofPlots);

        // Call Apex endpoint to search for records and pass results to the lookup

        searchRule({
            searchKeyWord: searchTerm,
            utilityType: this.ProductFamilyScheme,
            numberOfPlot: this.NumberofPlots
        })
            .then((results) => {
                console.log(results);
                this.template
                    .querySelector('c-lookup[data-utilityType="' + utilityType + '"]')
                    .setSearchResults(results);
            })
            .catch((error) => {
                //this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error("Lookup error", JSON.stringify(error));
                this.errors = [error];
            });

    }

    handleSelectionRuleChange(event) {
        let utilityType = event.target.dataset.utilitytype;
        /*let selectedutility = event.target.dataset.selectedutility;
       this.schemeItems.forEach(item => {
           if (item.utilityType === selectedutility) {
               item.ruleId = event.detail[0];
           }
       });*/

        const inputFields = this.template.querySelectorAll('lightning-input-field[data-utilitytype="' + utilityType + '"]');
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName === "Rule__c") {
                    field.value = event.detail[0];
                    this.rule_eletric = event.detail[0];
                    console.log("Seleted Rule ID : " + event.detail[0]);
                }
            });
        }



    }

    handleSelectedRule(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRules = [];
        for (let i = 0; i < selectedRows.length; i++) {
            //alert("Selected Rule : " + selectedRows[i].Name +'-- Id ' +selectedRows[i].Id);
            this.selectedRules.push(selectedRows[i].Id);
        }
    }


    get TotalKitSell() {
        console.log(this.TotalKitSell);
        //console.log('TotalKitSell : ' + this.opportunity.data.fields.Total_Kit_Sell__c.displayValue);
        /*return this.opportunity && this.opportunity.data && this.opportunity.data.fields.Total_Kit_Sell__c.value ?
            this.opportunity.data.fields.Total_Kit_Sell__c.displayValue : null;*/
        return this.TotalKitSell;
    }

    get TotalLabourSell() {
        //console.log('TotalLabourSell : ' + this.opportunity.data.fields.Total_Labour_Sell__c.displayValue);
        /*return this.opportunity && this.opportunity.data && this.opportunity.data.fields.Total_Labour_Sell__c.value != null ?
            this.opportunity.data.fields.Total_Labour_Sell__c.displayValue : 0;*/
        return this.TotalLabourSell;
    }

    get TotalMaterialSell() {
        //console.log('TotalMaterialSell : ' + this.opportunity.data.fields.Total_Material_Sell__c.displayValue);
        /*return this.opportunity && this.opportunity.data && this.opportunity.data.fields.Total_Material_Sell__c.value != null ?
            this.opportunity.data.fields.Total_Material_Sell__c.displayValue : 0;*/
        return this.TotalMaterialSell;
    }

    get TotalPlantSell() {
        //console.log('TotalPlantSell : ' + this.opportunity.data.fields.Total_Plant_Sell__c.displayValue);
        /*return this.opportunity && this.opportunity.data && this.opportunity.data.fields.Total_Plant_Sell__c.value != null ?
            this.opportunity.data.fields.Total_Plant_Sell__c.displayValue : 0;*/
        return this.TotalPlantSell;

    }

    get TotalClientContribution() {
        //console.log('TotalClientContribution : ' + this.opportunity.data.fields.Total_Client_Contribution__c.displayValue);
        /*return this.opportunity && this.opportunity.data && this.opportunity.data.fields.Total_Client_Contribution__c.value != null ?
            this.opportunity.data.fields.Total_Client_Contribution__c.displayValue : 0;*/
        return this.TotalClientContribution;

    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    @track imageUrl;

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        let uploadedFileContentVersionId = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
            uploadedFileContentVersionId += uploadedFiles[i].contentVersionId;
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        );
        console.log('Content Version ' + uploadedFileContentVersionId);
        this.imageUrl = '/sfc/servlet.shepherd/version/download/' + uploadedFileContentVersionId;
    }

    renderedCallback() {

    }

    defaultOpportunityData() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields && this.opportunity && this.opportunity.data) {
            inputFields.forEach(field => {
                if (field.fieldName == 'Site__c')
                    field.value = this.opportunity.data.fields.Site__c.value;
                if (field.fieldName == 'Project__c')
                    field.value = this.opportunity.data.fields.Project__c.value;
                if (field.fieldName == 'CloseDate')
                    field.value = this.opportunity.data.fields.CloseDate.value;
                if (field.fieldName == 'Type')
                    field.value = this.opportunity.data.fields.Type.value;
                if (field.fieldName == 'Property_Type__c')
                    field.value = this.opportunity.data.fields.Property_Type__c.value;
                if (field.fieldName == 'Utilities__c')
                    field.value = this.opportunity.data.fields.Utilities__c.value;
                if (field.fieldName == 'Contact_Name__c')
                    field.value = this.opportunity.data.fields.Contact_Name__c.value;

                if (field.fieldName == 'RecordTypeId')
                    field.value = this.opportunity.data.fields.RecordTypeId.value;
            });
        }
    }

    inputChanged(event) {
        console.log('inputChanged');
        let name = event.target.name;
        let value = event.target.value;
        let parentIndex = event.target.dataset.parentindex;
        let index = event.target.dataset.index;
        let utilityType = event.target.dataset.utilitytype;
        let item;
        {
            console.log('name: ' + name);
            console.log('value: ' + value);
            console.log('parentIndex: ' + parentIndex);
            console.log('index: ' + index);
        }

        if (utilityType == 'Labour') {
            item = this._labourSellItems.find(item => item.index == index);
            item[name] = value;
            item.Quantity__c = item.Quantity__c || 0;
            {
                if (name == 'Labour_Sell__c') {
                    item.Labour_Sell__c = item.Labour_Sell__c;
                }

            }
            console.log(item);
        }
        else if (utilityType == 'Plant') {
            item = this._plantSellItems.find(item => item.index == index);
            item[name] = value;
            item.Quantity__c = item.Quantity__c || 0;
            {
                if (name == 'Plant_Sell__c') {
                    item.Plant_Sell__c = item.Plant_Sell__c;
                }

            }
            console.log(item);
        }
        else {
            let utilityItem = this._utilityItems.find(item => item.index == parentIndex);
            let oppProduct = utilityItem.oppProducts.find(item => item.index == index);
            item = oppProduct.oppLineItem;
            console.log(item);
            {
                item[name] = value;
                item.Quantity__c = item.Quantity__c || 0;
                {
                    if (name == 'Implementor__c') {
                        item.Implementor__c = item.Implementor__c;
                    }
                    else if (name == 'Kit_Sell__c') {
                        item.Kit_Sell__c = item.Kit_Sell__c;

                    }

                }
            }
        }

        this.calculateTotalSell(parentIndex);
    }

    calculatePlots(event) {
        console.log('calculatePlots');
        let utilityTypePlot = event.target.dataset.utilitytype;
        let fieldName = event.target.fieldName;
        let value = event.target.value;
        console.log(utilityTypePlot);

        let plotFields = this.template.querySelectorAll('lightning-input-field[data-utilityType="' + utilityTypePlot + '"]');
        //console.log(plotFields);

        if (plotFields) {
            var totalNumberOfPlots = 0;
            plotFields.forEach(field => {
                //console.log(field.value);
                if (field.value != null && field.value != "") {
                    totalNumberOfPlots += parseInt(field.value);
                }
            });

            let schemeItem = {};
            if (utilityTypePlot == 'electric-scheme-plot') {
                this.eletric_totalNumberOfPlots = totalNumberOfPlots;

                schemeItem = this.schemeItems.find(item => item.utilityType == 'Electric');

                /*if (fieldName == 'No_of_Commercial__c' && value > 0) {
                    this.showElectricCommercial = true;
                    this.electricCommercialNumberofPlots = value;
                    
                }
                else if (fieldName == 'No_of_Commercial__c' && (value == '' || value == null)) {
                    this.showElectricCommercial = false;
                }


                if (fieldName == 'No_of_Landlord__c' && value > 0) {
                    this.showElectricLandlords = true;
                }
                else if (fieldName == 'No_of_Landlord__c' && (value == '' || value == null)) {
                    this.showElectricLandlords = false;
                }*/
            }
            else if (utilityTypePlot == 'gas-scheme-plot')
                this.gas_totalNumberOfPlots = totalNumberOfPlots;
            else if (utilityTypePlot == 'water-scheme-plot') {
                this.water_totalNumberOfPlots = totalNumberOfPlots;
                schemeItem = this.schemeItems.find(item => item.utilityType == 'Water');
            }
            else if (utilityTypePlot == 'street-scheme-plot')
                this.street_totalNumberOfPlots = totalNumberOfPlots;

            if (schemeItem) {

                console.log('test ' + schemeItem);
                if (fieldName == 'No_of_Commercial__c' && value > 0) {
                    schemeItem.showCommercial = true;
                    schemeItem.numberOfCommercial = value;

                }
                else if (fieldName == 'No_of_Commercial__c' && (value == '' || value == null)) {
                    schemeItem.showCommercial = false;
                    schemeItem.numberOfCommercial = value;
                }


                if (fieldName == 'No_of_Landlord__c' && value > 0) {
                    schemeItem.showLandlord = true;
                    schemeItem.numberOfLandlord = value;
                }
                else if (fieldName == 'No_of_Landlord__c' && (value == '' || value == null)) {
                    schemeItem.showLandlord = false;
                    schemeItem.numberOfLandlord = value;

                }

            }

        }


    }

    pocTypeChange(event) {
        console.log('pocTypeChange');
        let utilityType = event.target.dataset.utilitytype;
        let fieldName = event.target.fieldName;
        let value = event.target.value;

        console.log(fieldName);
        console.log(value);
        console.log(utilityType);

        let schemeItem = this.schemeItems.find(item => item.utilityType == utilityType);

        if(fieldName == 'POC__c')
        {
            if (value == 'LV') {
                schemeItem.isHV = false;
                schemeItem.showSubstation = false;
            }
            else if (value == 'HV') {
                schemeItem.isHV = true;
                if(schemeItem.numberOfSubstations > 0)
                    schemeItem.showSubstation = true;
                
            }
        }
        else if(fieldName == 'Number_of_Substations__c')
        {
            schemeItem.numberOfSubstations = value;
            if(schemeItem.numberOfSubstations > 0)
                schemeItem.showSubstation = true;
            else
            schemeItem.showSubstation = false;
        }
    }


    calculateTotalSell(parentIndex) {

        if (typeof parentIndex !== 'undefined') {
            let utilityItem = this._utilityItems.find(item => item.index == parentIndex);
            utilityItem.totalKitSell = 0;
            utilityItem.totalLabourSell = 0;
            utilityItem.totalPlantSell = 0;
            utilityItem.oppProducts.forEach(oppProduct => {
                let item = oppProduct.oppLineItem;
                let totalKitSell = (item.Kit_Sell__c || 0) * (item.Quantity__c || 0);
                let totalLabourSell = (item.Labour_Sell__c || 0) * (item.Quantity__c || 0);
                let totalPlantSell = item.Plant_Sell__c || 0 * (item.Quantity__c || 0);
                utilityItem.totalKitSell += (+totalKitSell);
                utilityItem.totalLabourSell += (+totalLabourSell);
                utilityItem.totalPlantSell += (+totalPlantSell);
                //coupledItem.parentProduct.Margin__c = ((coupledItem.parentProduct.Unit_Price__c - coupledItem.parentProduct.Cost_Price__c) *100)/coupledItem.parentProduct.Unit_Price__c;
            });

        }

        this.TotalKitSell = 0;
        this.TotalLabourSell = 0;
        //this.TotalMaterialSell = 0;
        this.TotalPlantSell = 0;

        /*this._plantSellItems.forEach(item => {

            let totalPlantSell = (item.Plant_Sell__c || 0) * (item.Quantity__c || 0);
            this.TotalPlantSell += (+totalPlantSell);
        });

        this._labourSellItems.forEach(item => {
            let totalLabourSell = (item.Labour_Sell__c || 0) * (item.Quantity__c || 0);
            this.TotalLabourSell += (+totalLabourSell);
        });*/


        this._utilityItems.forEach(utilityItem => {
            this.TotalKitSell += utilityItem.totalKitSell;
            this.TotalLabourSell += utilityItem.totalLabourSell;
            this.TotalPlantSell += utilityItem.totalPlantSell;

        });

    }

    previous() {
        if (this.currentStep == '2') {
            this.firstPage = true;
            this.preDisabled = true;
            this.saveDisabled = false;
            this.currentStep = '1';
            this.template.querySelector('div.stepTwo').classList.add('slds-hide');
            this.template.querySelector('div.stepOne').classList.remove('slds-hide');
        }
        else if (this.currentStep == '3') {
            this.saveDisabled = true;
            this.currentStep = '2';
            this.template.querySelector('div.stepThree').classList.add('slds-hide');
            this.template.querySelector('div.stepTwo').classList.remove('slds-hide');
        }
        else if (this.currentStep == '4') {
            this.saveDisabled = true;
            this.currentStep = '3';
            this.template.querySelector('div.stepFour').classList.add('slds-hide');
            this.template.querySelector('div.stepThree').classList.remove('slds-hide');
            //this.queryDefaultProducts('Electric');
        }
        else if (this.currentStep == '5') {
            this.lastPage = false;
            //this.nextDisabled = false;
            this.saveDisabled = true;
            this.currentStep = '4';
            this.template.querySelector('div.stepFive').classList.add('slds-hide');
            this.template.querySelector('div.stepFour').classList.remove('slds-hide');
        }
        else if (this.currentStep == '6') {
            this.lastPage = false;
            this.nextDisabled = false;
            this.saveDisabled = true;
            this.currentStep = '5';
            this.template.querySelector('div.stepSix').classList.add('slds-hide');
            this.template.querySelector('div.stepFive').classList.remove('slds-hide');
        }
        else if (this.currentStep == '7') {
            this.lastPage = false;
            this.nextDisabled = false;
            this.saveDisabled = false;
            this.currentStep = '6';
            this.template.querySelector('div.stepSeven').classList.add('slds-hide');
            this.template.querySelector('div.stepSix').classList.remove('slds-hide');
        }


    }

    next() {
        if (this.currentStep == '1') {
            this.firstPage = false;
            this.preDisabled = false;
            this.saveDisabled = true;
            this.currentStep = '2';
            this.template.querySelector('div.stepOne').classList.add('slds-hide');
            this.template.querySelector('div.stepTwo').classList.remove('slds-hide');
            this.initialCreateScheme();
        }
        else if (this.currentStep == '2') {
            this.saveDisabled = true;
            this.currentStep = '3';
            this.template.querySelector('div.stepTwo').classList.add('slds-hide');
            this.template.querySelector('div.stepThree').classList.remove('slds-hide');

            this.queryDefaultProducts(true);
        }
        else if (this.currentStep == '3') {
            this.saveDisabled = true;
            this.currentStep = '4';
            this.template.querySelector('div.stepThree').classList.add('slds-hide');
            this.template.querySelector('div.stepFour').classList.remove('slds-hide');

            //this.saveUtilityProducts();
        }
        else if (this.currentStep == '4') {
            //this.nextDisabled = true;
            this.saveDisabled = true;
            this.currentStep = '5';
            this.template.querySelector('div.stepFour').classList.add('slds-hide');
            this.template.querySelector('div.stepFive').classList.remove('slds-hide');
        }
        else if (this.currentStep == '5') {
            this.saveDisabled = false;
            this.currentStep = '6';
            this.template.querySelector('div.stepFive').classList.add('slds-hide');
            this.template.querySelector('div.stepSix').classList.remove('slds-hide');
        }
        else if (this.currentStep == '6') {
            this.lastPage = true;
            this.nextDisabled = true;
            this.saveDisabled = true;
            this.currentStep = '7';
            this.template.querySelector('div.stepSix').classList.add('slds-hide');
            this.template.querySelector('div.stepSeven').classList.remove('slds-hide');
        }

    }


    getNumberOfAvailableRules() {
        console.log('getNumberOfAvailableRules');
        //this.selectedRuleParentIndex = event.target.dataset.parentindex;
        //let utilityType = event.target.dataset.utilitytype;
        //this.selectedRuleUtilityType = utilityType;
        //console.log('parentIndex: ' + this.selectedRuleParentIndex);
        console.log(this.selectedUtilityList);
        //var selectedUtilityList = ['Electric', 'Water', 'Gas'];
        getrelatedRules({
            oppId: this.recordId,
            selectedUtilityList: this.selectedUtilityList
        })
            .then((results) => {
                console.log(results);

                //this.noOfAvailableRules = results.length;
            })
            .catch((error) => {
                console.error("getNumberOfAvailableRules error", JSON.stringify(error));

            });
    }



    openSelectUtilityTypeModal(event) {

        this.showSelectUtilityTypeModal = true;
    }

    closeSSelectUtilityTypeModal(event) {
        this.showSelectUtilityTypeModal = false;

    }

    openSelectRuleModal(event) {
        console.log('openSelectRuleModal');
        this.selectedRuleParentIndex = event.target.dataset.parentindex;
        let utilityType = event.target.dataset.utilitytype;
        this.selectedRuleUtilityType = utilityType;
        console.log('utilityType: ' + utilityType);
        console.log('parentIndex: ' + this.selectedRuleParentIndex);

        let utilityItem = this._utilityItems.find(item => item.utilityType == utilityType);
        console.log(JSON.parse(JSON.stringify(utilityItem.rules)));
        //console.log(utilityItem.rules);
        this.data = utilityItem.rules;



        /*getrelatedRules({
            utility: utilityType,
            oppId: this.recordId
        })
            .then((results) => {
                console.log(results);
                this.data = results;
                this.noOfAvailableRules = results.length;
            })
            .catch((error) => {
                console.error("getrelatedRules error", JSON.stringify(error));
                this.errors = [error];
            });*/


        this.showSelectRuleModal = true;
    }

    saveRule(event) {
        this.showSpinner = true;
        let parentindex = event.target.dataset.parentindex;
        /*addCoreToUtilityProducts({
            utilityType: this.selectedRuleUtilityType,
            utilityProducts: this._utilityItems,
            selectedRuleIds: this.selectedRules
        })*/
        //this.noOfSeletcedRules = this.selectedRules.length;

        getCoreProductsByRules({
            oppId: this.recordId,
            utilityType: this.selectedRuleUtilityType,
            selectedRuleIds: this.selectedRules
        })
            .then((results) => {
                console.log(results);

                if (results && results.length !== 0) {

                    let utilityItem = this._utilityItems.find(item => item.index == parentindex);
                    utilityItem.noOfSeletcedRules = this.selectedRules.length;
                    let index = utilityItem.oppProducts.length;
                    console.log(utilityItem.oppProducts);

                    results.forEach(result => {
                        let oppProduct = {};
                        oppProduct.oppLineItem = {};
                        let item = result.oppLineItem;
                        console.log(item.Product2Id__r.Id);

                        oppProduct.productUrl = '/' + item.Product2Id__r.Id;
                        oppProduct.index = index++;
                        oppProduct.isNew = false;
                        oppProduct.errors = [];
                        oppProduct.selection = {
                            id: item.Product2Id__r.Id,
                            sObjectType: 'Product2',
                            icon: 'standard:product',
                            title: item.Product2Id__r.Name,
                            subtitle: item.Product2Id__r.Name
                        }

                        oppProduct.isRemoveable = true;
                        //oppProduct.oppLineItem.Implementor__c = item.Implementor__c;
                        //oppProduct.oppLineItem.Material_Cost__c = item.Material_Cost__c;
                        oppProduct.ProductType = 'Core Product';
                        oppProduct.oppLineItem = item;
                        oppProduct.oppLineItem.Quantity__c = item.Quantity__c;
                        console.log(oppProduct);
                        utilityItem.oppProducts.push(oppProduct);
                        //return utilityItem;
                        this.showSpinner = false;
                    });

                    //this.calculateTotalSell(utilityItem.index);


                }

                this.showSpinner = false;
            })
            .catch(error => {
                console.log('Error in query: ' + JSON.stringify(error));
                this.showSpinner = false;
            });

        this.showSelectRuleModal = false;
    }

    closeSelectRuleModal(event) {
        this.showSelectRuleModal = false;
        this.productToDeleteParentIndex = null;
    }



    openDeleteProductModal(event) {
        this.showDeleteProductModal = true;
        this.productToDeleteId = event.target.dataset.id;
        this.productToDeleteIndex = event.target.dataset.index;
        this.productToDeleteParentIndex = event.target.dataset.parentindex;
    }

    closeDeleteProductModal(event) {
        this.showDeleteProductModal = false;
        this.productToDeleteId = null;
        this.productToDeleteIndex = null;
        this.productToDeleteParentIndex = null;
    }

    @track isModalOpen = true;
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    deleteProduct(event) {
        console.log('deleteProduct');
        this.showDeleteProductModal = false;
        this.productToDeleteId = null;
        this.productToDeleteIndex = null;
        this.productToDeleteParentIndex = null;
        console.log(event.target.dataset.index);
        console.log(event.target.dataset.id);
        if (event.target.dataset.id) {
            this.removedItems.push({ Id: event.target.dataset.id });
        }
        let parentIndex = event.target.dataset.parentindex;
        let index = event.target.dataset.index;
        console.log('parentIndex: ' + parentIndex);
        console.log('index: ' + index);
        let utilityItem = this._utilityItems.find(item => item.index == parentIndex);
        utilityItem.oppProducts.splice(index, 1);
        let newIndex = 0;
        utilityItem.oppProducts.forEach(item => {
            item.index = newIndex++;
        });
        this.calculateCoupledProduct(parentIndex);
        //utilityItem.oppProducts.push.apply(utilityItem.oppProducts, this.getDefaultProducts(coupledItem.oppProducts));
    }

    removeProduct(event) {
        console.log('removeProduct');
        let parentIndex = event.target.dataset.parentindex;
        let index = event.target.dataset.index;
        let utilityType = event.target.dataset.utilitytype;
        console.log('parentIndex: ' + parentIndex);
        console.log('index: ' + index);
        if (utilityType == 'Labour') {
            this._labourSellItems.splice(event.target.dataset.index, 1);
            let newIndex = 0;
            this._labourSellItems.forEach((item) => {
                item.index = newIndex++;
            });

        }
        else if (utilityType == 'Plant') {
            this._plantSellItems.splice(event.target.dataset.index, 1);
            let newIndex = 0;
            this._plantSellItems.forEach((item) => {
                item.index = newIndex++;
            });

        }
        else {
            let utilityItem = this._utilityItems.find(item => item.index == parentIndex);
            utilityItem.oppProducts.splice(event.target.dataset.index, 1);
            let newIndex = 0;
            utilityItem.oppProducts.forEach(item => {
                item.index = newIndex++;
                //this.template.querySelector('c-lookup[data-index="' + item.index + '"]').handleClearSelection();
            });
        }

        this.calculateCoupledProduct(parentIndex);
    }

    generatePDFDoc(event) {
        //console.log(event.detail.blob);
        this.blob = event.detail.blob;

        var reader = new FileReader();
        reader.readAsDataURL(this.blob);
        reader.onload = () => {
            //console.log(base64data);
            var base64 = reader.result.split(',')[1]
            this.pdfBase64Data = base64;
            //console.log(this.pdfBase64Data);

        }
    }

    save(event) {
        let close = event.target.dataset.close;
        this.showSpinner = true;

        event.preventDefault();       // stop the form from submitting
        //Check your custom validation
        /* const inputFields = this.template.querySelectorAll(
             'lightning-input-field'
         );
         if (inputFields) {
             inputFields.forEach(field => {
                 if(field.fieldName == 'Name') {
                     //custom Error
                 }
             });
         }
         */

        if (this.currentStep == 1) {
            const fields = event.detail.fields;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        else if (this.currentStep != 1 && this.currentStep != 2) {
            console.log('saveUtilityProducts');
            let allValid = [...this.template.querySelectorAll('lightning-input')]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);

            if (allValid) {
                let utilityProducts = [];
                let plantSellItems = [];
                let labourSellItems = [];

                this._utilityItems.forEach(utilityItem => {
                    console.log(utilityItem);
                    let utilityProduct = {};
                    //coupledProduct.parentProduct = coupledItem.parentProduct;
                    //delete coupledProduct.parentProduct.Opportunity_Product__r;

                    utilityProduct.oppProducts = [];
                    utilityItem.oppProducts.forEach(oppProductItem => {
                        console.log(oppProductItem);
                        let item = oppProductItem.oppLineItem;
                        if (item.Product2Id__r.Id) {
                            let oppProduct = {}
                            oppProduct.oppLineItem = {};

                            if (typeof item.Id != 'undefined') oppProduct.oppLineItem.Id = item.Id;
                            oppProduct.oppLineItem.Quantity__c = parseFloat(item.Quantity__c);
                            oppProduct.oppLineItem.Product2Id__c = item.Product2Id__r.Id;
                            oppProduct.oppLineItem.OpportunityId__c = item.OpportunityId__c;
                            oppProduct.oppLineItem.UnitPrice__c = parseFloat(item.Kit_Sell__c);
                            oppProduct.oppLineItem.Kit_Sell__c = parseFloat(item.Kit_Sell__c);
                            //oppProduct.oppLineItem.Material_Sell__c = parseFloat(item.Material_Sell__c);
                            //oppProduct.oppLineItem.Plant_Sell__c = parseFloat(item.Plant_Sell__c);
                            oppProduct.oppLineItem.Material_Cost__c = parseFloat(item.Material_Cost__c);
                            oppProduct.oppLineItem.Plant_Cost__c = parseFloat(item.Plant_Cost__c);
                            oppProduct.oppLineItem.Implementor__c = item.Implementor__c;

                            /*if (oppProductItem.isNew)
                            {
                                oppProduct.oppLineItem.Product2Id = item.Product2Id;
                                oppProduct.oppLineItem.OpportunityId = item.OpportunityId;
                            }
                            else
                            {
                                oppProduct.oppLineItem.Id = item.Id;
                            }*/

                            utilityProduct.oppProducts.push(oppProduct);
                            console.log(utilityProduct);
                        }
                    });
                    utilityProducts.push(utilityProduct);
                    console.log(utilityProducts);

                    //----------------

                });


                /*console.log(JSON.parse(JSON.stringify(this._labourSellItems)));
                this._labourSellItems.forEach(item => {
                    if (item.Product2Id__r.Id) {
                        let oppProduct = {};
                        oppProduct.Quantity__c = parseFloat(item.Quantity__c);
                        oppProduct.Product2Id__c = item.Product2Id__r.Id;
                        oppProduct.Labour_Sell__c = parseFloat(item.Labour_Sell__c);
                        oppProduct.UnitPrice__c = parseFloat(item.Labour_Sell__c);
                        oppProduct.OpportunityId__c = item.OpportunityId__c;
                        labourSellItems.push(oppProduct);
                    }

                });
                console.log(labourSellItems);

                //------------------


                console.log(JSON.parse(JSON.stringify(this._plantSellItems)));
                this._plantSellItems.forEach(item => {
                    if (item.Product2Id__r.Id) {
                        let oppProduct = {};
                        oppProduct.Quantity__c = parseFloat(item.Quantity__c);
                        oppProduct.Product2Id__c = item.Product2Id__r.Id;
                        oppProduct.Plant_Sell__c = parseFloat(item.Plant_Sell__c);
                        oppProduct.UnitPrice__c = parseFloat(item.Plant_Sell__c);
                        oppProduct.OpportunityId__c = item.OpportunityId__c;
                        plantSellItems.push(oppProduct);
                    }
                });
                console.log(plantSellItems);*/


                //this.generatePDFDoc();

                console.log(this.pdfBase64Data);

                let myBlobString = '';

                if (typeof this.blob != 'undefined') {
                    myBlobString = '';
                }

                createEstimate({
                    oppId: this.recordId,
                    //utilityProducts: utilityProducts,
                    //labourSellItems: labourSellItems,
                    //plantSellItems: plantSellItems,
                    pdfBase64Data: this.pdfBase64Data
                })
                    .then(result => {
                        if (result && result.length !== 0) {
                            console.log(result);
                            this._quoteId = result.quoteId;
                            this._contentVersionId = result.contentVersionId;
                            this._contentDocumentId = result.contentDocumentId;
                            this.showSpinner = false;

                            if (close == 'true') {
                                const closeQA = new CustomEvent('close');
                                this.dispatchEvent(closeQA);

                                this[NavigationMixin.Navigate]({
                                    type: 'standard__recordPage',
                                    attributes: {
                                        recordId: this.quoteId,
                                        actionName: 'view',
                                    },
                                });
                            }
                            else {
                                try {
                                    let lookups = this.template.querySelectorAll('c-lookup');
                                    for (var i = 0; i < lookups.length; i++) {
                                        lookups[i].handleClearSelection();
                                    }
                                }
                                catch (e) {
                                    console.log(e);
                                }

                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Estimate has been created Successfully',
                                        variant: 'success',
                                    }),
                                );

                                this.queryDefaultProducts(true);
                                this.removedItems = [];
                                this._plantSellItems = [];
                                this._labourSellItems = [];

                                //this.template.querySelector('c-lookup[data-index="' + 4 + '"]').handleClearSelection();
                                //this.queryDefaultProducts(false);
                                //this.removedItems = [];

                            }
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
            else {
                this.showSpinner = false;
            }
        }
        else {
            this.showSpinner = false;
        }

        if (close == 'true') {
            this.closeWindow = true;
        }

    }

    handleSubmitScheme(event) {
        event.preventDefault();       // stop the form from submitting
        let utilityType = event.target.dataset.utilitytype;
        let selectedUtility = event.target.dataset.selectedutility;
        //const fields = event.detail.fields;
        //console.log(JSON.parse(JSON.stringify(fields)));
        //var test = JSON.parse(JSON.stringify(fields));
        //test.Rule__c = 'a3I3G00000083sLUAQ';
        //test.RecordTypeId = '0124J000000Y7Q9QAK';
        //console.log(test);

        var ruleId, recordTypeId;

        this.schemeItems.forEach(item => {
            if (item.utilityType === selectedUtility) {
                ruleId = item.ruleId;
                recordTypeId = item.utilityRecordTypeId;
            }
        });

        const inputFields = this.template.querySelectorAll(
            'lightning-input-field[data-utilitytype="' + utilityType + '"]'
        );
        if (inputFields) {
            inputFields.forEach(item => {
                console.log(item.fieldName);
                console.log(item.value);
            });

            console.log(inputFields);

            const recordInput = { apiName: 'Site_Scheme__c', fields: inputFields };
            createRecord(recordInput)
                .then(scheme => {
                    //this.accountId = account.id;
                    console.log(scheme.id);

                    /*const inputFields = this.template.querySelectorAll(
                        'lightning-input-field[data-utilityType="' + utilityType + '"]'
                    );*/

                    /*if (inputFields) {
                        inputFields.forEach(field => {
                            if (field.name != "Estimate__c" && field.name != "Site__c" && field.name != "Project__c") {
                                //field.reset();
                                field.value = null;
                                console.log(field.name + ' not reset');
                            }
                            else {
                                console.log(field.name + ' not reset');
                            }
                        });
    
                        let lookups = this.template.querySelectorAll('c-lookup');
                        for (var i = 0; i < lookups.length; i++) {
                            lookups[i].handleClearSelection();
                        }
                    }*/


                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: "Scheme has been created",
                            variant: 'success',
                        }),
                    );
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });

        }

        //this.template.querySelector('lightning-record-edit-form').submit(test);
    }

    handleSuccessCreateScheme(event) {
        /*const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.name != "Estimate__c" && field.name != "Site__c" && field.name != "Project__c") {
                    field.reset();
                    field.value = null;
                    console.log(field.name + ' not reset');
                }
                else {
                    console.log(field.name + ' not reset');
                }
            });
        }*/

        let recordTypeName;
        let utilityType;
        query({
            q: "SELECT Id, RecordTypeId, RecordType.Name FROM Site_Scheme__c WHERE Id = '" + event.detail.id + "'"
        })
            .then((result) => {
                if (result && result.length !== 0) {
                    console.log(result);
                    if (result[0].RecordType.Name == 'Charger') recordTypeName = 'Charge Points';
                    else if (result[0].RecordType.Name == 'StreetLighting') recordTypeName = 'Street Lighting';
                    else recordTypeName = result[0].RecordType.Name;
                    console.log(recordTypeName);

                    let item = this.schemeItems.find(item => item.utilityType == recordTypeName);
                    console.log(item);
                    item.recordId = event.detail.id;

                    const evt = new ShowToastEvent({
                        title: "Scheme",
                        message: recordTypeName + " scheme has been created/updated",
                        variant: "success"
                    });
                    this.dispatchEvent(evt);
                }
            });
    }

    handleSuccessUpdateOpp(event) {
        //const updatedRecordId = event.detail.id;
        // Generate a URL to a User record page
        console.log('============== Record Id', event.detail.id);
        //console.log('============== Selected Utility', JSON.stringify(event.detail));

        const event1 = new ShowToastEvent({
            variant: 'success',
            title: 'success !',
            message: 'Opportunity has been updated.',
        });
        this.dispatchEvent(event1);
        this.showSpinner = false;

        if (this.closeWindow == true) {
            const closeQA = new CustomEvent('close');
            this.dispatchEvent(closeQA);
        }

    }

    handleSelectionChange(event) {
        let parentIndex = event.target.dataset.parentindex;
        let index = event.target.dataset.index;
        let utilityType = event.target.dataset.utilitytype;
        console.log('parentIndex: ' + parentIndex);
        console.log('index: ' + index);
        console.log(event.detail[0]);
        let pricebook2Id = this.opportunity.data.fields.Pricebook2Id.value;
        let item;
        if (utilityType == 'Labour') {
            item = this._labourSellItems.find(item => item.index == index);
        }
        else if (utilityType == 'Plant') {
            item = this._plantSellItems.find(item => item.index == index);
        }
        else {
            let utilityItem = this._utilityItems.find(item => item.index == parentIndex);
            let oppProduct = utilityItem.oppProducts.find(item => item.index == index);
            item = oppProduct.oppLineItem;
        }

        {
            if (typeof event.detail[0] !== 'undefined') {

                item.Product2Id = event.detail[0];
                query({
                    q:
                        "SELECT Id, Product2.Name, Product2.ProductCode,Product2.Kit_Sell__c,Product2.Material_Sell__c,Product2.Plant_Sell__c,Product2.Labour_Sell__c, Product2.Material_Cost__c,Product2.Plant_Cost__c,Product2.Labour_Cost__c, Product2.Description, UnitPrice FROM PricebookEntry WHERE Product2Id = '" +
                        item.Product2Id +
                        "' AND Pricebook2Id = '" +
                        pricebook2Id +
                        "'"
                })
                    .then((result) => {
                        if (result && result.length !== 0) {
                            console.log(result);
                            result.map((i) => {

                                let selected = {
                                    id: event.detail[0],
                                    sObjectType: 'Product2',
                                    icon: 'standard:product',
                                    title: i.Product2.Name,
                                    subtitle: i.Product2.Name
                                }

                                if (utilityType == 'Labour') {
                                    //item.Product2 = {};
                                    item.Product2Id__r.Id = event.detail[0];
                                    item.Product2Id__r.ProductCode = i.Product2.ProductCode;
                                    item.Product2Id__r.Family = utilityType;
                                    if (typeof i.Product2.Labour_Sell__c === 'undefined') item.Labour_Sell__c = 0;
                                    else item.Labour_Sell__c = i.Product2.Labour_Sell__c;
                                    item.Labour_Cost__c = i.Product2.Labour_Cost__c;
                                    item.PricebookEntryId = i.Id;
                                    item.selection = selected;
                                }
                                else if (utilityType == 'Plant') {

                                    //item.Product2 = {};
                                    item.Product2Id__r.Id = event.detail[0];
                                    item.Product2Id__r.ProductCode = i.Product2.ProductCode;
                                    item.Product2Id__r.Family = utilityType;
                                    item.Plant_Sell__c = i.Product2.Plant_Sell__c;
                                    item.Plant_Cost__c = i.Product2.Plant_Cost__c;
                                    item.PricebookEntryId = i.Id;
                                    item.selection = selected;
                                }
                                else {
                                    //item.Product2Id__r = {};
                                    item.Product2Id__r.Id = event.detail[0];
                                    item.Product2Id__r.ProductCode = i.Product2.ProductCode;
                                    if (utilityType == 'Electric') item.Product2.Family = 'Electricity';
                                    else item.Product2Id__r.Family = utilityType;
                                    //console.log(i.Product2.Kit_Sell__c);
                                    if (typeof i.Product2.Kit_Sell__c === 'undefined') item.Kit_Sell__c = 0;
                                    else item.Kit_Sell__c = i.Product2.Kit_Sell__c;
                                    //item.Material_Sell__c = i.Product2.Material_Sell__c;
                                    //item.Plant_Sell__c = i.Product2.Plant_Sell__c;
                                    item.Material_Cost__c = i.Product2.Material_Cost__c;
                                    item.Plant_Cost__c = i.Product2.Plant_Cost__c;
                                    item.selection = selected;
                                    //item.PricebookEntryId = i.Id;
                                }


                            });
                            item.errors = [];
                            this.calculateTotalSell(parentIndex);
                        }
                    })
                    .catch((error) => {
                        console.log("Error in query: " + JSON.stringify(error));
                        const event = new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: JSON.stringify(error.body.message),
                        });
                        this.dispatchEvent(event);
                    });

            }
            else {
                item.Quantity__c = 1;
                if (utilityType == 'Labour') {
                    item.Labour_Sell__c = 0;
                    item.Labour_Cost__c = 0;

                }
                else if (utilityType == 'Plant') {
                    item.Plant_Sell__c = 0;
                    item.Plant_Cost__c = 0;

                }
                else {
                    item.Kit_Sell__c = 0;
                }

                this.calculateTotalSell(parentIndex);
            }


        }
    }

    section = '';
    handleToggleSection(event) {
        this.activeSectionMessage = 'Open section name:  ' + event.detail.openSections;
    }

    handleSetActiveSectionC() {
        const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = 'C';
    }

    queryTerm = 'Test';
    searchValue;

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        this.queryTerm = evt.target.value;
        console.log(this.queryTerm);
        if (isEnterKey) {
            console.log('Press Enter');
            this.searchValue = this.queryTerm;
            console.log(this.searchValue);

        }
    }

    handleSearchKeyword() {

        if (this.searchValue !== '') {
            getContactList({
                searchKey: this.searchValue
            })
                .then(result => {
                    // set @track contacts variable with return contact list from server  
                    this.contactsRecord = result;
                })
                .catch(error => {

                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                    // reset contacts var with null   
                    this.contactsRecord = null;
                });
        } else {
            // fire toast event if input field is blank
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Search text missing..',
            });
            this.dispatchEvent(event);
        }
    }

    callQuotePDFEditor() {
        this.template.querySelector("quote-p-d-f-editor").childFunction();
    }

    /*get options() {
        console.log(this.UTILITIES_PicklistValues);
        console.log(this.UTILITIES_PicklistValues.values);
        return this.UTILITIES_PicklistValues.values;

    }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChange(e) {
        this._selected = e.detail.value;
    }*/


    /*get electric_recordTypeId() {
        if (this.siteSchemeInfo.data && this.siteSchemeInfo.data.recordTypeInfos) {
            const rtis = this.siteSchemeInfo.data.recordTypeInfos;
            console.log(rtis);
            return Object.keys(rtis).find(rti => rtis[rti].name === 'Electric');
        }
    }

   get gas_recordTypeId() {
        if (this.siteSchemeInfo.data && this.siteSchemeInfo.data.recordTypeInfos) {
            const rtis = this.siteSchemeInfo.data.recordTypeInfos;
            console.log(rtis);
            return Object.keys(rtis).find(rti => rtis[rti].name === 'Gas');
        }
    }

    get water_recordTypeId() {
        if (this.siteSchemeInfo.data && this.siteSchemeInfo.data.recordTypeInfos) {
            const rtis = this.siteSchemeInfo.data.recordTypeInfos;
            console.log(rtis);
            return Object.keys(rtis).find(rti => rtis[rti].name === 'Water');
        }
    }*/

    /* @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
     opportunityInfo;
 
      @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: UTILITIES})
      UTILITIES_PicklistValues({error, data})
      {
          if (data) {
              this.options = data.values;
  
              if (this.selectedOption) {
                  let optionIsValid = this.options.some(function(item) {
                      return item.value === this.selectedOption;
                  }, this);
  
                  if (!optionIsValid) {
                      this.selectedOption = data.defaultValue;
                  }
              } else {
                  this.selectedOption = data.defaultValue;
              }
          } else if (error) {
              console.log(error);
          }
      }
  
      toggleActivity(event)
      {
          event.target.closest('.slds-timeline__item_expandable').classList.toggle('slds-is-open');
      }
      */

    /*navigateTo_Electric_Sch() {
      const defaultValues = encodeDefaultFieldValues({
          FirstName: 'Morag',
          LastName: 'de Fault',
          LeadSource: 'Other'
      });

      //console.log(defaultValues);

      this[NavigationMixin.Navigate]({
          type: 'standard__objectPage',
          attributes: {
              objectApiName: 'Site_Scheme__c',
              actionName: 'new'
          },
          state: {
              //defaultFieldValues: defaultValues
              recordTypeId: recordTypeId
          }
      });
  }*/



}
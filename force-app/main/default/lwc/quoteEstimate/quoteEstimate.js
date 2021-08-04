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
import searchDefaultProducts from "@salesforce/apex/RuleController.getProducts";
import getSiteScheme from "@salesforce/apex/NewQuoteEstimateController.getSiteScheme";
import query from '@salesforce/apex/NewQuoteEstimateController.query';
import saveUtilityProducts from '@salesforce/apex/NewQuoteEstimateController.saveUtilityProducts';
import searchRule from "@salesforce/apex/NewQuoteEstimateController.searchRule";
import getrelatedRules from "@salesforce/apex/NewQuoteEstimateController.getrelatedRules";
//import addCoreToUtilityProducts from "@salesforce/apex/NewQuoteEstimateController.addCoreToUtilityProducts";

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
    {label: 'Rule Name', fieldName: 'Name', type: 'text'},
    {label: 'Description', fieldName: 'Description__c', type: 'text'}
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
    //@track data = data;
    //@track columns = columns;


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

}
import { api, LightningElement, track } from 'lwc';
import getProducts from '@salesforce/apex/RuleController.getProducts';

export default class RuleQuery extends LightningElement {    

    _recordId;
    @track
    newlineItems = [];
    showSpinner = true;    

    @api
    set recordId(val) {
        console.log(val);
        this._recordId = val;
        this.getProductItems();
    }

    get recordId() {
        return this._recordId;
    }

    handleChange()
    {
        this.getProductItems();
    }

    @api
    getProductItems() {
        this.showSpinner = true;
        let fieldMap = {};
        if (this.template.querySelector('[data-name="Name"]'))
            fieldMap.Name = this.template.querySelector('[data-name="Name"]').value;
        if (this.template.querySelector('[data-name="Adopter__c"]') && this.template.querySelector('[data-name="Adopter__c"]').value)
            fieldMap.Adopter__c = this.template.querySelector('[data-name="Adopter__c"]').value;
        
        getProducts({
            utilityType: 'Electric',
            fieldMap: fieldMap,
            ruleId: this._recordId
        }).then((result) => {
            if (result && result.length !== 0) {
                console.log(result);
                console.log(JSON.stringify(result));
                this.newlineItems = result;
            }
            else {
                this.newlineItems = [];
            }
            this.showSpinner = false;
        })
        .catch((error) => {
            console.log("Error in query: " + JSON.stringify(error));
            //showToast(this, "error", "Error!", JSON.stringify(error.body.message));
            this.showSpinner = false;
        });
    }    
}
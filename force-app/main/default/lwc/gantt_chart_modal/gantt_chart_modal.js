import { LightningElement, api, track } from 'lwc';

export default class GanttChartModal extends LightningElement {
    @track title;
    @track body;
    @track success = {
        variant: 'brand'
    };

    @api delay = 500;

    showModal = false;
    isLoading = true;
    hasRendered = false;

    renderedCallback() {
        if(!this.hasRendered) {
            this.isLoading = false;
            // this.template.querySelector('.modal-body').classList.remove('slds-hide');
            this.hasRendered = true;
        }
    }

    @api
    show() {
        this.showModal = true;
        this.isLoading = true;

        if(this.delayTimeout) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            clearTimeout(this.delayTimeout);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            console.log("**inside timeout** , delay=="+this.delay);
            this.isLoading = false;
            this.template.querySelector('.modal-body').classList.remove('slds-hide');
        }, this.delay);
        // this.template.querySelector('.lwc-modal').classList.remove('slds-hide');
    }
    @api
    hide() {
        this.template.querySelector('.modal-body').classList.add('slds-hide');
        this.showModal = false;
    }

    closeModal() {
        this.hide();
        this.dispatchEvent(
            new CustomEvent("close", {
              bubbles: true,
              composed: true
            })
        );
    }
}
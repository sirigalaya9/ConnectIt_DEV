import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FilePreviewer extends NavigationMixin(LightningElement) {

    @api 
    recordId;

    @api 
    fileName;    

    @api
    navigateToFiles() {
        console.log('navigateToFiles');
        console.log(this.recordId);
        if (!this.recordId)
        {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                selectedRecordId: this.recordId
            }
        })
    }

    connectedCallback() {
        console.log('connectedCallback');
        //this.navigateToFiles();
        /*
        this.delayTimeout = setTimeout(() => {
            this.closeQuickAction();                
        }, 1000);            
        */
    }

    closeQuickAction() {
        const closeQuickAction = new CustomEvent('close');        
        this.dispatchEvent(closeQuickAction);
    }        
}
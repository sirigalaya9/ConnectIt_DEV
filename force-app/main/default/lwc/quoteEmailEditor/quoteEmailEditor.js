import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEmailRequest from '@salesforce/apex/QuoteEmailController.getEmailRequest';
import sendEmailRequest from '@salesforce/apex/QuoteEmailController.sendEmail';

export default class QuoteEmailEditor extends LightningElement {
    @api recordId;
    @api salutationText = 'Johan';
    @api emailBodyPlaceholder = 'Type in your email message here. The PDF estimate will be automatically attached to this email and sent to the client';    
    @api signatureText = 'Test';
    @api bodyText;
    @api toAddress;
    @api ccAddress;
    @api bccAddress;
    @api subject = 'Estimate';    
    @api contentDocumentId = '0693G000000LNrjQAG';
    @api contentVersionId = '0683G000000MDg4QAG';
    @api attachmentName = 'Estimate.pdf';
    @api quoteId;

    isPreview = false;
    showSpinner = false;

    connectedCallback() {
        getEmailRequest({ signatureTemplateName: 'Email_Signature'  })
        .then((result) => {
            this.signatureText = result.signatureText;            
        })
        .catch((error) => {
            console.log(error);
        });
    }

    sendEmail() {
        console.log('sendEmail');        
        sendEmailRequest(
            {recordId : this.recordId, 
            toAddress: this.template.querySelector("[data-name='toAddress']").value,
            ccAddress: this.template.querySelector("[data-name='ccAddress']").value,
            bccAddress: this.template.querySelector("[data-name='bccAddress']").value,
            subject: this.template.querySelector("[data-name='subject']").value,
            bodyText: this.template.querySelector("[data-name='bodyText']").value, 
            salutationText: this.template.querySelector("[data-name='salutationText']").value,
            signatureText: this.template.querySelector("[data-name='signatureText']").value,
            contentDocumentId: this.contentDocumentId,
            contentVersionId: this.contentVersionId,
            isPreview: this.isPreview,
            quoteId: this.quoteId
        })
        .then(result => {
            console.log(result);
            if (this.isPreview == false)
            {
                const evt = new ShowToastEvent({ title: 'Success', message: 'Email sent successfully.', variant: 'Success' });
                this.dispatchEvent(evt);                
            }
            else
            {
                //this.showPreviewModal = true;
                //this.previewContent = result;
                this.isPreview = false;
                this.showSpinner = false;
            }                
        })
        .catch(error => {
            console.log(error);
            let errorMsg = error.body ? (error.body.message) : error;
            const evt = new ShowToastEvent({ title: 'Error', message: errorMsg, variant: 'Error' });
            this.dispatchEvent(evt);    
            this.showSpinner = false;  
            //this.isPreview = false;          
        });        
    }

}
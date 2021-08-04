import { LightningElement, track, api } from "lwc";
import doExport from "@salesforce/apex/BorisPlannerOUTExportController.doExport";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ModalPopupLWC extends LightningElement {
  @track isModalOpen = false;
  @track dateFrom;
  @track dateTo;
  @api filter;

  showToast() {
    const event = new ShowToastEvent({
        variant: 'success',
        title: 'Exported',
        message: 'Batch job submitted for export.',
    });
    this.dispatchEvent(event);
}

  openModal() {
    this.isModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
  }

  async handleExport() {
    
    console.log('filter.projects=' + this.filter.projects.length);
    console.log('filter.resources=' + this.filter.resources.length);
    console.log('filter.roles=' + this.filter.roles.length);    
    console.log('filter=' + this.filter);

    var filterStr = JSON.stringify(this.filter);
    console.log('filterStr=' +filterStr);
    var projectsStr = 'test xxxx'//JSON.stringify(this.filter.projects);
    console.log('projectsStr=' +projectsStr);
    let allValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    if (this.dateFrom > this.dateTo) {
      allValid = false;
    }

    if (allValid) {

      await doExport({ dateFrom: this.dateFrom, dateTo: this.dateTo, filterStr: filterStr }).catch((err) => {
        console.log(err);
      });

      this.showToast();
      this.isModalOpen = false;
    }
  }

  onChangeDateFrom(evt) {
    this.dateFrom = evt.target.value;

    if (this.dateFrom > this.dateTo) {
      this.dateTo = "";
    }
  }

  onChangeDateTo(evt) {
    this.dateTo = evt.target.value;
  }
}
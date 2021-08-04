import { LightningElement, api, wire, track } from "lwc";

import fetchLookUpValues from "@salesforce/apex/newGanttChart.fetchLookUpValues";

export default class CustomLookup extends LightningElement {
  @api objectName;
  @api fieldName;
  // @api searchKey;
  // @api keyField;
  @api criteria;
  @api orderBy;
  @api iconName;
  @api defaultValue;

  /* @api
    get defaultValue() {
        return this._defaultValue;
    }
    set defaultValue(_defaultValue) {
        this._defaultValue = _defaultValue;
        
        this.selectedRecord = _defaultValue;
        this.selectedRecordId = _defaultValue;
        this.isSelection = true;
        //this.setSelection();
    } */

  @track options = [];
  searchValue = "";

  @track selectedRecord;
  showAccountsListFlag = false;
  isSelection = false;
  hasRendered = false;

  @wire(fetchLookUpValues, {
    searchKey: "$searchValue",
    fieldName: "$fieldName",
    ObjectName: "$objectName",
    criteria: "$criteria",
    orderBy: "$orderBy"
  })
  picklistvalues({ data, error }) {
    if (data) {
      console.log("custom lookup data==" + JSON.stringify(data));
      // let picklistOptions = [{ key: '--None--', value: '--None--' }];
      let picklistOptions = [];
      data.forEach((key) => {
        picklistOptions.push({
          key: key.Id,
          value: key[this.fieldName]
        });
      });
      this.options = picklistOptions;
    } else if (error) {
      console.error(error);
    }
  }

  renderedCallback() {
    if (!this.hasRendered) {
      console.log("this.defaultValue==" + JSON.stringify(this.defaultValue));
      if (this.defaultValue && this.defaultValue.id && this.defaultValue.name) {
        this.selectedRecord = this.defaultValue.name;
        this.selectedRecordId = this.defaultValue.id;
        this.isSelection = true;
        this.setSelection();
      }
      this.hasRendered = true;
    }
  }

  handleClick() {
    if (!this.showAccountsListFlag) {
      this.showAccountsListFlag = true;
      this.template
        .querySelector(".options-list")
        .classList.remove("slds-hide");
      this.template
        .querySelector(".slds-searchIcon")
        .classList.add("slds-hide");
      this.template
        .querySelector(".slds-icon-utility-down")
        .classList.remove("slds-hide");
    }
    this.template
      .querySelector(".slds-dropdown-trigger")
      .classList.add("slds-is-open");
  }

  handleBlur() {
    if (!this.showAccountsListFlag) {
      this.showAccountsListFlag = true;
      this.template.querySelector(".options-list").classList.add("slds-hide");
      this.template
        .querySelector(".slds-searchIcon")
        .classList.remove("slds-hide");
      this.template
        .querySelector(".slds-icon-utility-down")
        .classList.add("slds-hide");
    }
    this.template
      .querySelector(".slds-dropdown-trigger")
      .classList.remove("slds-is-open");
  }

  handleSearch(event) {
    //window.clearTimeout(this.delayTimeout);
    this.searchValue = event.target.value;
    // const searchTerm = this.searchValue.toLowerCase();
    // this.searchKey = searchTerm;
    console.log("this.searchValue==", this.searchValue);
  }

  handleKeyUp(event) {
    window.clearTimeout(this.delayTimeout);
    this.searchValue = event.target.value;
    console.log("this.searchValue==", this.searchValue);
    /* const filter = this.searchValue.toUpperCase();
        const span = this.template.querySelector('.slds-listbox_vertical').childNodes;
        for (let i = 1; i < span.length; i++) {
            const option = span[i].textContent;
            if (option.toUpperCase().indexOf(filter) > -1) {
                span[i].style.display = "";
            } else {
                span[i].style.display = "none";
            }
        } */

    // eslint-disable-next-line @lwc/lwc/no-async-operation
    /* this.searchValue = this.searchValue;
        if (this.searchValue === '') {
            this.template
                .querySelector('.options-list')
                .classList.add('slds-hide');
            this.template
                .querySelector('.slds-searchIcon')
                .classList.remove('slds-hide');
            this.template
                .querySelector('.slds-icon-utility-down')
                .classList.add('slds-hide');
            this.showAccountsListFlag = false;
        } */
  }

  handleOptionSelect(event) {
    this.selectedRecord = event.currentTarget.dataset.name;
    this.selectedRecordId = event.currentTarget.dataset.id;
    if (!this.isSelection) {
      this.isSelection = true;
    }

    this.dispatchEvent(
      new CustomEvent("select", {
        bubbles: false,
        detail: {
          // selectedRecordId: this.selectedRecordId,
          id: this.selectedRecordId,
          name: this.selectedRecord
        }
      })
    );

    this.setSelection();
  }

  setSelection() {
    console.log(this.isSelection);
    this.template
      .querySelector(".selectedOption")
      .classList.remove("slds-hide");

    this.template.querySelector(".options-list").classList.add("slds-hide");

    this.template.querySelector(".defaultClass").classList.add("slds-hide");
  }

  handleRemoveSelectedOption() {
    this.template.querySelector(".selectedOption").classList.add("slds-hide");

    this.template.querySelector(".defaultClass").classList.remove("slds-hide");

    this.template
      .querySelector(".slds-searchIcon")
      .classList.remove("slds-hide");

    this.template
      .querySelector(".slds-icon-utility-down")
      .classList.add("slds-hide");

    this.dispatchEvent(
      new CustomEvent("remove", {
        bubbles: false
      })
    );

    this.template.querySelector(".searchvalue").value = "";
    //this.searchKey = '';
    this.searchValue = "";
    this.showAccountsListFlag = false;
  }

  @api
  removeSelection() {
    this.handleRemoveSelectedOption();
  }
}
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { subscribe, MessageContext } from 'lightning/messageService';
import ESTIMATE_CHECKLIST_CHANNEL from '@salesforce/messageChannel/Estimate_Checklist__c';
import generatePDF from '@salesforce/apex/QuotePDFController.generatePDF';
import { generateGUID, reduceErrors } from 'c/ldsUtils';
import UTILITIES_FIELD from '@salesforce/schema/Opportunity.Utilities__c';

const FIELDS = [UTILITIES_FIELD];

export default class QuotePDFEditor extends LightningElement {

  content = '';
  showSpinner = false;
  //image = 'https://cius--kliqxedev--c.documentforce.com/sfc/dist/version/download/?oid=00D3G0000008njb&ids=0683G000000MCoF&d=%2Fa%2F3G0000008XWG%2FqR0TMlwWiAj7I77znky_RY5doRJyGG8UPMBHyOO.w2I&asPdf=false';
  @api recordId;
  record;
  @track utilities = [{name: 'Overview', images: []},{name: 'Electricity', images: []},{name: 'Gas', images: []},{name: 'Water', images: []}];
  @track image_overview = [];
  @track image_electricity = [];
  @track image_gas = [];
  @track image_water = [];
  @api account_name = 'Test Site';
  @api user_name = 'Tony';
  @api user_title = 'Developer';
  @api createddate = '2021-06-02';
  @api closedate = '2021-06-30';
  @api user_phone = '01489 665555';
  @api user_email = 'tony@example.com';
  @api estimate_checklists = [];  

  @wire(MessageContext)
  messageContext;

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
  wiredRecord({ error, data }) {
      if (error) {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error loading record',
                  message: reduceErrors(error),
                  variant: 'error',
              }),
          );
      } else if (data) {
        console.log('wiredRecord');  
        console.log(data);
        
          this.record = data;          
          this.utilities = [{name: 'Overview', images: []}];
          let utilities = getFieldValue(this.record, UTILITIES_FIELD);
          if (utilities)
          {
              let utilityItems = utilities.split(';');
              if (utilityItems)
              {
                utilityItems.forEach(item => {
                  let utilityName = item;
                  if (utilityName === 'Electric')
                  {
                    utilityName = 'Electricity';
                  }
                  let utility = {name: utilityName, images: []};
                  if (utilityName !== 'Temporary Building Supply' && utilityName !== 'Fibre' )
                  {
                    this.utilities.push(utility);
                  }
                });
              }
          }
          this.renderPDF();
          window.addEventListener("message", this.handleVFResponse.bind(this));
          this.subscribeToMessageChannel();
          
      }
  }  

  subscribeToMessageChannel() {
    this.subscription = subscribe(
      this.messageContext,
      ESTIMATE_CHECKLIST_CHANNEL,
      (message) => this.handleMessage(message)
    );
  }

  handleMessage(message) {
    console.log('handleMessage:');
    console.log(message);
    this.estimate_checklists = message;
  }  

  get PDF() {
    if (this.content)
      return this.content; // + '#page=2';
    else
      return null;
  }

  renderDOCX() {
    document.getElementById("pdfForm").submit();
  }

  connectedCallback() {    
    /*
    this.renderPDF();
    window.addEventListener("message", this.handleVFResponse.bind(this));
    this.subscribeToMessageChannel();
    */
  }

  handleVFResponse(message) {
    let dataURL = message.data.image;
    let type = message.data.type;
    let id = message.data.id;
    let utility = this.utilities.find(item => item.name.toLowerCase() === type.toLowerCase());
    let image = utility.images.find(item => item.id === id);
    image.data = dataURL; 
    /*
    if (type == 'overview')
    {
      let image = this.image_overview.find(item => item.id === id);
      image.data = dataURL;            
    }
    if (type == 'electricity')
    {
      let image = this.image_electricity.find(item => item.id === id);
      image.data = dataURL;      
    }          
    if (type == 'gas')
    {
      let image = this.image_gas.find(item => item.id === id);
      image.data = dataURL;      
    }   
    if (type == 'water')
    {
      let image = this.image_water.find(item => item.id === id);
      image.data = dataURL;      
    } 
    */ 
  }

  @api
  renderPDF() {        

    generatePDF({recordId: this.recordId}).then(result => {
      console.log(result);          


      let res_checklist = [];
      if (this.estimate_checklists && this.estimate_checklists[0])
      {
        res_checklist = this.estimate_checklists[0].items;
      }    
      console.log('account_name: ' + this.account_name);

      let resultObj = JSON.parse(result);
      this.utilities.forEach(item => {
        let mergeName = 'image_' + item.name.toLowerCase();
        mergeName = mergeName.replaceAll(' ','_');
        resultObj[mergeName] = item.images;
      });
      /*
      resultObj.image_overview = this.image_overview;
      resultObj.image_electricity = this.image_electricity;
      resultObj.image_gas = this.image_gas;
      resultObj.image_water = this.image_water;  
      */

      this.showSpinner = true;
      fetch('https://www.webmerge.me/merge/785245/d5ehbv?test=1&download=1', {
        headers: { "Content-Type": "application/json; charset=utf-8" },
        method: 'POST',
        body: JSON.stringify(resultObj)
      })
        .then(response => {
          console.log('response:');
          return response.blob();
        })
        .then(blob => {
          console.log('blob:');
          console.log(blob);
  
          this.dispatchEvent(new CustomEvent('pdfready', {
            detail: {
              blob: blob
            }
          }));
  
          console.log('URL:' + URL.createObjectURL(blob));
          return URL.createObjectURL(blob);
        })
        .then(uril => {
          console.log('uril:');
          console.log(uril);
          this.content = uril;
          this.showSpinner = false;
          /*
            var link = document.createElement("a");
          link.href = uril;
          link.download = "test.pdf";
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
          */
        }).catch(error => {
          this.showSpinner = false;
        });



    }).catch(error => {
        console.log(error);        
    });
  }

  renderDOCX2() {        

    generatePDF({recordId: this.recordId}).then(result => {
      console.log(result);          


      let res_checklist = [];
      if (this.estimate_checklists && this.estimate_checklists[0])
      {
        res_checklist = this.estimate_checklists[0].items;
      }    
      console.log('account_name: ' + this.account_name);

      let resultObj = JSON.parse(result);
      this.utilities.forEach(item => {
        let mergeName = 'image_' + item.name.toLowerCase();
        mergeName = mergeName.replaceAll(' ','_');
        resultObj[mergeName] = item.images;
      });
      /*      
      resultObj.image_overview = this.image_overview;
      resultObj.image_electricity = this.image_electricity;
      resultObj.image_gas = this.image_gas;
      resultObj.image_water = this.image_water;
      */

      this.showSpinner = true;
      fetch('https://www.webmerge.me/merge/758346/l2ukww?test=1&download=1', {
        headers: { "Content-Type": "application/json; charset=utf-8" },
        method: 'POST',
        body: JSON.stringify(resultObj)
      })
        .then(response => {
          console.log('response:');
          return response.blob();
        })
        .then(blob => {
          console.log('blob:');
          console.log(blob);
  /*
          this.dispatchEvent(new CustomEvent('pdfready', {
            detail: {
              blob: blob
            }
          }));
  */
          var newBlob = new Blob([blob], {type: "application/octet-stream"})
          console.log('URL:' + URL.createObjectURL(newBlob));
          return URL.createObjectURL(newBlob);
        })
        .then(uril => {          
          console.log('uril:');          
          console.log(uril);          
          //this.content = uril;                   
          
          let downloadLink = document.createElement("a");
          downloadLink.setAttribute("type", "hidden");
          downloadLink.href = uril;
          downloadLink.download = "Estimate.docx";
          document.body.appendChild(downloadLink);
          downloadLink.click();
          downloadLink.remove();

          this.showSpinner = false;          
        }).catch(error => {
          this.showSpinner = false;
        });



    }).catch(error => {
        console.log(error);        
    });
  }  

  handleImageChange(event) {

    var type = event.target.dataset.type;    
    type = type.toLowerCase();

    //this.imageUrl = null;
    //this.imageData = null;

    //var brochure = this.brochureObject;
    var files = event.target.files;
    var file = files[0];
    var canvas = document.createElement('canvas');
    var ctx = canvas.getContext('2d');
    var image = document.createElement('img');


    image.onload = () => {
      var max_size = 800;
      var width = image.width;
      var height = image.height;

      /*
      if ((width > height) && (width > max_size)) {
          height *= max_size / width;
          width = max_size;
      } else if (height > max_size) {
          width *= max_size / height;
          height = max_size;
      }
      */
      canvas.width = width;
      canvas.height = height;

      ctx.drawImage(image, 0, 0, width, height);

      var dataURL = canvas.toDataURL(file.type);

      //console.log("dataURL: ", dataURL);
      //div.innerHTML = '<img src="' + dataURL + '" width="" class="image_picker_image" />';

      var BASE64_MARKER = ';base64,';
      var parts, contentType, raw;

      parts = dataURL.split(BASE64_MARKER);
      contentType = parts[0].split(':')[1];

      var uploadedImg = parts[1];
      //console.log(uploadedImg);

      let imageObj = {};
      imageObj.id = generateGUID();
      imageObj.data = dataURL;      
      imageObj.src = '/apex/ImageEditor?type=' + type + '&id='+imageObj.id;

      let utility = this.utilities.find(item => item.name.toLowerCase() === type.toLowerCase());
      utility.images.push(imageObj);
      /*
      if (type == 'overview')      
        this.image_overview.push(imageObj);      
      if (type == 'electricity')
      this.image_electricity.push(imageObj);
      if (type == 'gas')
      this.image_gas.push(imageObj);
      if (type == 'water')
      this.image_water.push(imageObj);
      */

      //this.imageData = uploadedImg;
      /*
      this.dispatchEvent(new CustomEvent('addresschange', {
          detail: {
              address: this.brochureObject.Address__c,
              suburb: this.brochureObject.Suburb__c,
              postCode: this.brochureObject.Postcode__c,
              imageUrl: null,
              imageData: uploadedImg
          }
      }));
      */

      //this.renderPDF();
      this.delayTimeout = setTimeout(() => {
        let message = { image: dataURL, type: type,  id: imageObj.id};
        let ratio = width / height;
        let newWidth = this.template.querySelector('[data-id="' + imageObj.id + '"]').width;
        console.log(newWidth);
        this.template.querySelector('[data-id="' + imageObj.id + '"]').height = '500px';
        this.template.querySelector('[data-id="' + imageObj.id + '"]').contentWindow.postMessage(message, "*");
        console.log('here');
    }, 2000);

    };

    image.src = URL.createObjectURL(file);
    //console.log('image.src', URL.createObjectURL(file));
    /*
    let imgs = this.template.querySelectorAll('.image_picker_image');
    imgs.forEach(function (img) {
      img.classList.remove('selected');
    });
    */
  }

  handleRemoveImageClicked(event)
  {
    let type = event.target.dataset.type;
    let id = event.target.dataset.id;
    let utility = this.utilities.find(item => item.name.toLowerCase() === type.toLowerCase());
    let index = utility.images.findIndex(item => item.id === id);
    utility.images.splice(index, 1);   

    /*
    if (type == 'overview')
    {
      let index = this.image_overview.findIndex(item => item.id === id);      
      this.image_overview.splice(index, 1);      
    }
    if (type == 'electricity')
    {
      let index = this.image_electricity.findIndex(item => item.id === id);      
      this.image_electricity.splice(index, 1);      
    }
    if (type == 'gas')
    {
      let index = this.image_gas.findIndex(item => item.id === id);      
      this.image_gas.splice(index, 1);      
    }
    if (type == 'water')
    {
      let index = this.image_water.findIndex(item => item.id === id);      
      this.image_water.splice(index, 1);      
    }  
    */          
  }

}
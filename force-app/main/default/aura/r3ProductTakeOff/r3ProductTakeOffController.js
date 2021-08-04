({
  // eslint-disable-line
  init: function (cmp, event, helper) {
    var columns = [
      {
        type: "url",
        fieldName: "ProductUrl",
        label: "Product Name",
        initialWidth: 500,
        typeAttributes: {
          label: { fieldName: "ProductName" }
        }
      },
      {
        type: "text",
        fieldName: "Address",
        label: "Address",
        initialWidth: 450,
        cellAttributes: { alignment: "left" }
      },
      {
        type: "number",
        fieldName: "EstQty",
        label: "Quantity",
        initialWidth: 100,
        cellAttributes: { alignment: "left" }
      },
      {
        type: "number",
        fieldName: "OrderQuantity",
        label: "Requested",
        initialWidth: 100,
        cellAttributes: { alignment: "left" }
      },
      {
        type: "text",
        fieldName: "LeadTime",
        label: "Lead Time",
        initialWidth: 100,
        cellAttributes: { alignment: "left" }
      }
    ];
    cmp.set("v.gridColumns", columns);

    var listColumns = [
      /*{
        type: "url",
        fieldName: "ProductUrl",
        label: "Product Name",
        initialWidth: 500,
        typeAttributes: {
          label: { fieldName: "ProductName" }
        }
      },*/
      {
        type: "text",
        fieldName: "ProductName",
        label: "Product Name",
        initialWidth: 600
      },
      {
        type: "number",
        fieldName: "EstQty",
        label: "Quantity",
        initialWidth: 160,
        cellAttributes: { alignment: "center" }
      },
      {
        type: "text",
        fieldName: "LeadTime",
        label: "Lead Time",
        initialWidth: 130,
        cellAttributes: { alignment: "center" }
      },
      {
        type: "number",
        fieldName: "OrderQuantity",
        label: "Quantity To Order",
        editable: "true",
        initialWidth: 150,
        cellAttributes: { alignment: "center" }
      }
    ];

    cmp.set("v.listColumns", listColumns);

    // data
    helper.getData(cmp);

    var expandedRows = [];
    cmp.set("v.gridExpandedRows", expandedRows);

    var selectedRows = [];
    cmp.set("v.gridSelectedRows", selectedRows);

  },

  onGridRowSelected: function (cmp, event, helper) {
    console.log("onGridRowSelected");

    //selectedRows

    var selectRows = event.getParam("selectedRows");
    console.log('selectRows -> ', selectRows);

    var currentSelectedRows = cmp.get("v.gridSelectedRows");
    var gridData = cmp.get("v.gridData");
    console.log("1");

    var tempList = [];
    if (selectRows.length > 0) {
      console.log("2");
      selectRows.forEach(record => {
        tempList.push(record.Id);
      });
      console.log("3");

      // select and deselect child rows based on header row
      gridData.forEach(record => {
        console.log("3.1");
        // if header was checked and remains checked, do not add sub-rows

        // if header was not checked but is now checked, add sub-rows
        if (currentSelectedRows.includes(record.Id) && tempList.includes(record.Id)) {
          console.log("3.2");
          record.items.forEach(item => {
            console.log("3.3");
            if (!tempList.includes(item.Id)) {
              console.log("3.4");
              tempList.push(item.Id);
            }
          });
        }

        // if header was checked and is no longer checked, remove header and sub-rows
        if (currentSelectedRows.includes(record.Id) && !tempList.includes(record.Id)) {
          console.log("3.5");
          record.items.forEach(item => {
            console.log("3.6");
            const index = tempList.indexOf(item.Id);
            if (index > -1) {
              console.log("3.7");
              tempList.splice(index, 1);
            }
          });
        }

        console.log("3.8");
        // if all child rows for the header row are checked, add the header
        // else remove the header
        var allSelected = true;
        record.items.forEach(item => {
          console.log("3.9");
          if (!tempList.includes(item.Id)) {
            console.log("3.10");
            allSelected = false;
          }
        });

        console.log("3.11");
        if (allSelected && !tempList.includes(record.Id)) {
          console.log("3.12");
          tempList.push(record.Id);
        } else if (!allSelected && tempList.includes(record.Id)) {
          const index = tempList.indexOf(record.Id);
          console.log("3.13");
          if (index > -1) {
            console.log("3.14");
            tempList.splice(index, 1);
          }
        }
      });
      console.log("4");

      cmp.set("v.gridSelectedRows", tempList);
      cmp.set("v.currentSelectedRows", tempList);
      console.log("5");

      for (var i = 0; i < tempList.length; i++) {
        console.log("You selected: " + JSON.stringify(selectedRows[i]));
      }
    }
  },

  onSelected: function (component, event, helper) {

    var selectedRows = event.getParam("selectedRows");
    var currentSelectedRows = component.get("v.gridSelectedRows");
    var gridData = component.get("v.gridData");
    console.log("selectedRows ", selectedRows);
    console.log("currentSelectedRows ", currentSelectedRows);
    console.log('event ', event);

    // get selected row ids
    var selectedRowIds = [];
    if (selectedRows.length > 0) {
      selectedRows.forEach(record => {
        selectedRowIds.push(record.Key);
      });
    }
    console.log(' selectedRowIds ', selectedRowIds);

    var selectedRowRecords = helper.findRecords(selectedRowIds,gridData);
    var selectedItemWithChildren = [];
    if (selectedRowRecords.length > 0) {
      selectedItemWithChildren = helper.getChildren(selectedRowRecords, gridData);
    }
    console.log(' final return (selected) ', selectedItemWithChildren);

    var selectedIds = [];
    selectedItemWithChildren.forEach(item => {
        selectedIds.push(item.Key);
    });
    console.log(' selectedIds ', selectedIds);

    component.set('v.gridSelectedRows', selectedIds);
  },
        
          
          
  onToggle: function (component, event, helper) {
	// for some reason (ask Salesforce) we need to reset the selected rows?
    var selectedRows = component.get('v.gridSelectedRows');
    component.set('v.gridSelectedRows', selectedRows);
  },
      
          
          
  handleCreate: function (component, event, helper) {
    //var treeGridCmp = component.find("treeGrid");
    var currentSelectedRows = component.get("v.gridSelectedRows");
    var gridData = component.get("v.gridData");
    console.log('handleCreate:currentSelectedRows ',currentSelectedRows);

    // get selected row ids
    var selectedRows = [];
    if (currentSelectedRows.length > 0) {
      currentSelectedRows.forEach(record => {
        selectedRows.push(record);
      });
    }
    console.log('handleCreate:selectedRows ', selectedRows);
  
    var currentSelectedRowRecords = helper.findRecords(selectedRows, gridData);
    console.log('handleCreate:currentSelectedRowRecords ',currentSelectedRowRecords);

    //var selRows = treeGridCmp.getSelectedRows();
    if (currentSelectedRowRecords.length > 0) {
      helper.getListData(component, event, currentSelectedRowRecords);

      helper.showPopupHelper(component, "modaldialog", "slds-fade-in-");
      helper.showPopupHelper(component, "backdrop", "slds-backdrop--");
    } else {
      helper.showToast(component, "Warning", "No rows have been selected");
    }
  },

  hidePopup: function (component, event, helper) {
    helper.hidePopupHelper(component, "modaldialog", "slds-fade-in-");
    helper.hidePopupHelper(component, "backdrop", "slds-backdrop--");
  },

  handleSaveOrder: function (component, event, helper) {
    //var listDataRecords = component.find("dtTable").get("v.listData"); // no longer seems to work after last sf release
    //console.log("listDataRecords: " + JSON.stringify(listDataRecords));

    var editedRecords = component.get("v.listData");
    console.log("editedRecords" + JSON.stringify(editedRecords));
    var materialsRequest = component.find("MaterialsRequest").get("v.value");
    console.log("materialsRequest: " + JSON.stringify(materialsRequest));

    if (materialsRequest === "") {
      helper.showToast(
        component,
        "Warning",
        "Please select a materials request."
      );
    } else {
      if (editedRecords.length > 0) {
        helper.placeOrder(component, event, editedRecords);
        //helper.showToast(component, "Success", "Order Updated.");
        helper.hidePopupHelper(component, "modaldialog", "slds-fade-in-");
        helper.hidePopupHelper(component, "backdrop", "slds-backdrop--");

        // make sure that grid refresh after the new order created.
        helper.getData(component);

      } else {
        helper.showToast(
          component,
          "Warning",
          "No Order Quantities have been entered."
        );
      }
    }
  },

  showNewMaterialsRequestPopup: function (component, event, helper) {

    helper.hidePopupHelper(component, "modaldialog", "slds-fade-in-");
    helper.hidePopupHelper(component, "backdrop2", "slds-backdrop--");
    helper.showPopupHelper(component, "modaldialogCreateMaterialsRequest", "slds-fade-in-");
    helper.showPopupHelper(component, "backdrop2", "slds-backdrop--");
  },

  hideCreateMatPopup: function (component, event, helper) {

    component.find('name').reset();
    component.find('deliveryToSiteDate').reset();

    helper.hidePopupHelper(component, "modaldialogCreateMaterialsRequest", "slds-fade-in-");
    helper.hidePopupHelper(component, "backdrop2", "slds-backdrop--");
    helper.showPopupHelper(component, "modaldialog", "slds-fade-in-");
    helper.showPopupHelper(component, "backdrop", "slds-backdrop--");

  },

  handleSubmitNewMaterialsRequestForm: function (component, event, helper) {
    var draftValues = component.get("v.draftValues");
    console.log("draftValues before: " + JSON.stringify(draftValues));
    event.preventDefault();       // stop the form from submitting
    var fields = event.getParam('fields');
    fields["Project_Job__c"] = component.get("v.recordId");
    component.find('newMaterialsRequestForm').submit(fields);


  },

  handleSubmitNewMaterialsRequestFormSuccess: function (component, event, helper) {
    var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
    console.log('onsuccess: ', updatedRecord.response.id);

    component.set('v.materialRequestId', updatedRecord.response.id);
    helper.hidePopupHelper(component, "modaldialogCreateMaterialsRequest", "slds-fade-in-");
    helper.hidePopupHelper(component, "backdrop2", "slds-backdrop--");
    helper.showPopupHelper(component, "modaldialog", "slds-fade-in-");
    helper.showPopupHelper(component, "backdrop", "slds-backdrop--");
    helper.showToast(component, "Success", "Materials request created.");

    // following line make the Datatable Save & Cancel button visible always.
    var dummy =  []; 
    dummy.push({Id: "row--1",OrderQuantity: "0"});
    component.set("v.draftValues",dummy);
    var draftValues = component.get("v.draftValues");
    console.log("draftValues after: " + JSON.stringify(draftValues));

  },
  handleReset: function (component, event, helper) {
    component.find('field').forEach(function (f) {
      f.reset();
    });
  }

}); // eslint-disable-line
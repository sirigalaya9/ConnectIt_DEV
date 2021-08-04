({
  getData: function (cmp) {
    // Get the record ID attribute
    var projectId = cmp.get("v.recordId");
    console.log(projectId);

    var action = cmp.get("c.getBOMItemsTree");
    action.setParams({
      projectId: projectId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        console.log("data:");
        console.log(data);
        var temojson = JSON.parse(
          JSON.stringify(data).split("items").join("_children")
        );
        temojson = JSON.parse(
          JSON.stringify(temojson).replace(/\\"_children\\"\s*:\s*null,/g, "")
        );
        console.log("temojson:");
        console.log(temojson);
        cmp.set("v.gridData", JSON.parse(temojson));
      }
      // error handling when state is "INCOMPLETE" or "ERROR"
    });
    $A.enqueueAction(action);
  },
  placeOrder: function (cmp, event, draftValueData) {
    var projectId = cmp.get("v.recordId");
    var materialsRequest = cmp.find("MaterialsRequest").get("v.value");
    console.log("materialsRequest" + JSON.stringify(materialsRequest));
    var draftValuesRecords = event.getParam("draftValues");
    console.log("draftValuesRecords: " + JSON.stringify(draftValuesRecords));

    // draft values
    var orderData = draftValueData;
    var i = 0;

    // set the order data object type
    orderData.forEach(function (item) {
      //item.ProductId = item.Id;
      //item.Id = item.Id;
      console.log("bomItemId: " + item.bomItemId);
      item.bomItemId = item.bomItemId;
      item.sobjectType = "bomWrapper";
    });

    // update row data with draft Save Data
    var rowIndex;
    for (i = 0; i < draftValuesRecords.length; i++) {
      rowIndex = draftValuesRecords[i].Id.slice(4);
      console.log("rowIndex: " + rowIndex);
      // rowIndex -1 is a dummy item, this is used for enable/show save & cancel button visible without any datatable edit.
      if (rowIndex != -1) {
        orderData[rowIndex].OrderQuantity = draftValuesRecords[i].OrderQuantity;
      }
    }

    console.log("orderData=" + JSON.stringify(orderData));
    var action = cmp.get("c.updateBOM");
    action.setParams({
      orderData: orderData,
      materialsRequest: materialsRequest,
      projectId: projectId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        console.log("response=" + JSON.stringify(data));
        // need to fire a events
        this.showToast(cmp, "Success", "Order Updated.");
      } else if (state === "ERROR") {
        console.log("state=" + state);

        var errors = response.getError();
        console.log(errors);
        var message = "Unknown error"; // Default error message
        // Retrieve the error message sent by the server
        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }
        // Display the message
        console.error(message);

        console.log("response=" + JSON.stringify(data));
        this.showToast(cmp, state, "Save Order failed, response = " + message);
      } else {
        this.showToast(
          cmp,
          state,
          "Save Order Incomplete, please contact your System Admin."
        );
      }
    });
    $A.enqueueAction(action);
  },

  getListData: function (cmp, event, selRows) {
    var projectId = cmp.get("v.recordId");
    var gridData = cmp.get("v.gridData");
    var listData = [];
    var ldIdx = 0;
    //var ids = [];
    //var names = [];

    for (var i = 0, len = selRows.length; i < len; i++) {
      if (selRows[i].ProductId != null) {
        console.log(
          "helper.getListData productName= " + selRows[i].ProductName
        );
        console.log("helper.getListData PlotName= " + selRows[i].PlotName);
        listData[ldIdx] = {};
        listData[ldIdx].sabjId = selRows[i].sabjId;
        listData[ldIdx].bomItemId = selRows[i].bomItemId;
        listData[ldIdx].ProductId = selRows[i].ProductId;
        listData[ldIdx].ProductUrl = selRows[i].ProductUrl;
        listData[ldIdx].ProductName = selRows[i].ProductName;
        if (selRows[i].PlotName != null) {
          listData[ldIdx].ProductName += " (" + selRows[i].PlotName + ")";
        }
        listData[ldIdx].ProductCode = selRows[i].ProductCode;
        listData[ldIdx].EstQty = selRows[i].EstQty;
        listData[ldIdx].LeadTime = selRows[i].LeadTime;
        listData[ldIdx].OrderQuantity =
          selRows[i].EstQty - selRows[i].OrderQuantity;
        ldIdx++;
      }
    }

    console.log("helper.getListData listData= " + JSON.stringify(listData));
    cmp.set("v.listData", listData);

    // following line make the Datatable Save & Cancel button visible always.
    var dummy = [];
    dummy.push({ Id: "row--1", OrderQuantity: "0" });
    cmp.set("v.draftValues", dummy);

    /*var action = cmp.get("c.getSelectedBOMItems");
        action.setParams({
            projectId: projectId,
            selectedIds: ids,
            selectedNames: names
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var temojson = JSON.parse(
                    JSON.stringify(data)
                    .split("items")
                    .join("_children")
                );
                console.log(temojson);
                cmp.set("v.listData", JSON.parse(temojson));
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);*/
  },
  addGridRow: function (row, selected) {
    //
    console.log("helper.addGridRow productName= " + selRows[i].ProductName);
    console.log("helper.addGridRow PlotName= " + selRows[i].PlotName);
    listData[ldIdx] = {};
    listData[ldIdx].ProductId = gridData[i].ProductId;
    listData[ldIdx].ProductUrl = gridData[i].ProductUrl;
    listData[ldIdx].ProductName = gridData[i].ProductName;
    if (selRows[i].PlotName != null) {
      listData[ldIdx].ProductName += " (" + gridData[i].PlotName + ")";
    }
    listData[ldIdx].ProductCode = gridData[i].ProductCode;
    listData[ldIdx].EstQty = gridData[i].EstQty;
    listData[ldIdx].LeadTime = gridData[i].LeadTime;
    listData[ldIdx].OrderQuantity =
      selRows[i].EstQty - gridData[i].OrderQuantity;
    ldIdx++;
  },
  showPopupHelper: function (component, componentId, className) {
    var modal = component.find(componentId);
    $A.util.removeClass(modal, className + "hide");
    $A.util.addClass(modal, className + "open");
  },

  hidePopupHelper: function (component, componentId, className) {
    var modal = component.find(componentId);
    $A.util.addClass(modal, className + "hide");
    $A.util.removeClass(modal, className + "open");
    component.find("dtTable").set("v.draftValues", null);
    component.set("v.body", "");
  },

  showToast: function (component, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message
    });
    toastEvent.fire();
  },

  getParentRecordId: function (rowKey, data, parentRecordId) {
    console.log("getParentRecordId:rowKey ", rowKey);
    console.log("getParentRecordId:parentRecordId ", parentRecordId);
    var idx;
    for (idx = 0; idx < data.length; idx++) {
      var record = data[idx];
      if (record.Key === rowKey) {
        // found it, return parent id!
        //console.log('getParentRecordId:Found rowKey ',rowKey);
        //console.log('getParentRecordId:Found parentRecordId ',parentRecordId);
        return parentRecordId;
      } else {
        if (record._children) {
          // has child records, check there...
          var rowRec = this.getParentRecordId(
            rowKey,
            record._children,
            record.Key
          );
          if (rowRec != null) {
            // found in child record, return parent id
            //console.log('getParentRecordId:Found rowRec ',rowRec);
            return rowRec;
          }
        }
        // not found, carry on...
      }
    }
    return null; // not found!
  },

  findRecords: function (rowKeyLst, data) {
    console.log("findRecords:rowKeyLst ", rowKeyLst);
    console.log("findRecords:rowKeyLst.length ", rowKeyLst.length);
    console.log("findRecords:data ", data);

    var idx;
    var rowRecLst = [];
    for (idx = 0; idx < rowKeyLst.length; idx++) {
      console.log("findRecords:idx ", idx);
      var rowRec = this.findRecord(rowKeyLst[idx], data);
      console.log("findRecords:rowRec ", rowRec);
      if (rowRec != null) {
        rowRecLst.push(rowRec);
      }
      console.log("findRecords:rowRecLst ", rowRecLst);
    }
    console.log("findRecords:rowRecLst ", rowRecLst);
    return rowRecLst;
  },

  findRecord: function (rowKey, data) {
    //console.log('findRecord:rowKey ',rowKey);
    //console.log('findRecord:data ',data);
    var idx;
    for (idx = 0; idx < data.length; idx++) {
      var record = data[idx];
      if (record.Key === rowKey) {
        // found it!
        console.log("findRecord:Found rowKey ", rowKey);
        console.log("findRecord:record ", record);
        return record;
      } else {
        if (record._children) {
          // has child records, check there...
          var rowRec = this.findRecord(rowKey, record._children);
          if (rowRec != null) {
            // found in child record
            return rowRec;
          }
        }
        // not found, carry on...
      }
    }
    return null; // not found!
  },

  getChildren: function (curNode, data) {
    var newNode = [];

    curNode.forEach((item) => {
      newNode = [...newNode, item];
      data.forEach((currentData) => {
        if (currentData.Key === item.Key) {
          if (currentData._children) {
            newNode = [...newNode, ...currentData._children];
            currentData._children.forEach((child) => {
              newNode = [
                ...newNode,
                ...this.getChildren([child], currentData._children)
              ];
            });
          }
        } else if (currentData._children) {
          currentData._children.forEach((child) => {
            newNode = [
              ...newNode,
              ...this.getChildren([item], currentData._children)
            ];
          });
        }
      });
    });

    return newNode.reduce((unique, o) => {
      if (!unique.some((obj) => obj.Key === o.Key)) {
        unique.push(o);
      }
      return unique;
    }, []);
  }
});
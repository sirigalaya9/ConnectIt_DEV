({
   openModel: function(component, event, helper) 
   {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) 
   {
      // for Hide/Close Model,set the "isOpen" attribute to "False"  
      component.set("v.isOpen", false);
   },
 
   saveClose: function(component, event, helper) 
   {
      var recordId = component.get("v.recordId");
      var filename = component.get("v.Filename");
      var vfpage = component.get("v.VisualForcePage");
      var fileType = component.get("v.Type");
      var fileGroup = component.get("v.Group");
      if(vfpage == null)
      {
         component.find('notifLib').showToast({
            "title": "Error!",
            "variant": "error",  // info, error or warning
            "message": "VisualForce PDF document not specified - please notify your Salesforce administrator!"
        });  
      }
      var action = component.get("c.savePDF");
      action.setParams({
         "vfpage": vfpage,
         "recordId": recordId,
         "filename": filename,
         "fileType": fileType,
         "fileGroup": fileGroup
      });
      action.setCallback(this, function(response){
          var state = response.getState();
          if (state === "SUCCESS") 
          {
              //alert('File saved successfully');
              /*component.find('notifLib').showToast({
                  "title": "Success!",
                  //"variant": "info",  // info, error or warning
                  "message": "PDF file saved to record!"
              });  
             resultsToast.fire();*/
             var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                  "title": "Success!",
                  "message": "PDF file saved to record!"
              });
              toastEvent.fire();
              $A.get("e.force:closeQuickAction").fire();
              //$A.get("e.force:refreshView").fire();
         }
         else if (state === "INCOMPLETE") 
         {
            component.find('notifLib').showToast({
               "title": "Error!",
               "variant": "error",  // info, error or warning
               "message": "Failed to save PDF file!"
            });  
         }
         else if (state === "ERROR" ) 
         {
            component.find('notifLib').showToast({
               "title": "Error!",
               "variant": "error",  // info, error or warning
               "message": "Failed to save PDF file!"
            });  
            var errors = response.getError();
            if (errors) 
            {
               if (errors[0] && errors[0].message) 
               {
                  console.log("Error message: " + errors[0].message);
               }
            } 
            else 
            {
               component.find('notifLib').showToast({
                  "title": "Error!",
                  "variant": "error",  // info, error or warning
                  "message": "Failed to save PDF file!"
               });  
               console.log("Unknown error");
            }
         }
      });
      $A.enqueueAction(action);

      // Display alert message on the click on the button from Model Footer 
      component.set("v.isOpen", false);       
   },

})
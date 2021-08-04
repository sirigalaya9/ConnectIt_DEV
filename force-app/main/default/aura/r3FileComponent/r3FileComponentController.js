({   
    checkFileList: function(component, event, helper) {
    	var fileList = component.get("v.fileList");
        if(!fileList.length) {
            var fileId = component.get("v.recordId");
            var fileFilter = component.get("v.fileFilter");
            helper.getFileList(component, fileId, fileFilter);
        }
    },
    
	handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var existingFiles = component.get("v.fileList") || [];
        var newFiles = [];
        uploadedFiles.forEach(function(file) {
            newFiles.push({
                ContentDocumentId: file.documentId
            });
        })
        existingFiles.forEach(function(file) {
            newFiles.push({
                ContentDocumentId: file.ContentDocumentId
            });
        })
        var fileId = component.get("v.recordId");
        var fileFilter = component.get("v.fileFilter");
        helper.getFileList(component, fileId, fileFilter);
    },
    
    deleteFile: function(component, event, helper) {
        if(confirm('Are you sure you want to delete this file?')) {
            var fileId = event.getSource().get("v.value");
            helper.deleteFile(component, fileId);
        }
    },
    
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    }    
    
})
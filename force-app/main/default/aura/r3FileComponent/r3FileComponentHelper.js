({
    getFileList: function(component, LinkedEntityId, fileFilter) 
    {
        console.log('R3>>> getFileList');

        var action = component.get("c.getRelatedFiles");
        
        action.setParams({
            "LinkedEntityId": LinkedEntityId,
            "fileFilter": fileFilter
        });
        
        action.setCallback(this, function (response) 
        {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var fileList = response.getReturnValue();
                component.set("v.fileList", fileList);
                var groupList = this.getGroupList(fileList);
                component.set("v.groupList", groupList);
                var getFolderList = this.getFolderList(groupList,fileList);
                component.set("v.folderList", getFolderList);
            } else {
                component.find('notifLib').showToast({
                    "title": "Failed!",
                    "variant": "error",
                    "message": "Failed to fetch related files"
                });                
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getGroupList: function(component, LinkedEntityId) 
    {
        var action = component.get("c.getRelatedGroupList");
        
        action.setParams({
            "LinkedEntityId": LinkedEntityId
        });
        
        action.setCallback(this, function (response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var fileList = response.getReturnValue();
                component.set("v.groupList", fileList);
            } else {
                component.find('notifLib').showToast({
                    "title": "Failed!",
                    "variant": "error",
                    "message": "Failed to fetch related file groups"
                });                
            }
        });
        
        $A.enqueueAction(action);
    },

    
	deleteFile: function(component, ContentDocumentId) {
        var action = component.get("c.deleteContentDocument");

        action.setParams({
            "ContentDocumentId": ContentDocumentId
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var fileList = component.get("v.fileList");
                var fileList_updated = this.removeIndexByKey(fileList, 'ContentDocumentId', ContentDocumentId);
                component.set("v.fileList", fileList_updated);
                
                component.find('notifLib').showToast({
                    "title": "Success!",
                    "variant": "success",
                    "message": "File has been deleted successfully"
                });
            } else {
                component.find('notifLib').showToast({
                    "title": "Failed!",
                    "variant": "error",
                    "message": "File deletion failed"
                });                
            }
        });
        
        $A.enqueueAction(action);
	},
    
    removeIndexByKey: function (array, key, value) {
        for (var i = 0; i < array.length; i++) {
            if (array[i][key] === value) {
                array.splice(i, 1);
            }
        }
        return array;
    },
    
    getGroupList: function (fileList) 
    {
        console.log('R3>>> getGroupList');
        var groupSet = new Set();
        for (var i = 0; i < fileList.length; i++) 
        {
            if (fileList[i].LatestPublishedVersion != null) 
            {
                if(fileList[i].LatestPublishedVersion.Group__c != null)
                {
                    groupSet.add(fileList[i].LatestPublishedVersion.Group__c);
                }
                else
                {
                    groupSet.add("(none)");                   
                }
            }
        }
        
        var groupList = Array.from(groupSet);
        groupList.sort();
        console.log(groupList);
        return groupList;
    },

    getFolderList: function (groupList, fileList) 
    {
        console.log('R3>>> getFolderList');
        let folderList = [];

		// work through the folder group list        
        for (var gIdx = 0; gIdx < groupList.length; gIdx++) 
        {
            // new folder group, assign name and file list...
            let folder = {};
            folder.name = groupList[gIdx];
            folder.files = [];
            
            // loop through all related files...
            for (var fIdx = 0; fIdx < fileList.length; fIdx++) 
            {
                if (fileList[fIdx].LatestPublishedVersion != null) // shouldn't ever happen!
                {
                    // is the file in this group?
                    if(fileList[fIdx].LatestPublishedVersion.Group__c == groupList[gIdx] || 
                       (fileList[fIdx].LatestPublishedVersion.Group__c == null && groupList[gIdx] == "(none)"))  // the null group case...
                    {
                        // yes, add it to the map
                        let file = {};
                        file.id = fileList[fIdx].LatestPublishedVersionId;
                        file.contentdocumentid = fileList[fIdx].Id;
                        file.title = fileList[fIdx].Title;
                        file.type = fileList[fIdx].LatestPublishedVersion.Type__c;
                        file.group = fileList[fIdx].LatestPublishedVersion.group__c;
                        file.created = fileList[fIdx].LatestPublishedVersion.CreatedDate;
                        file.size = fileList[fIdx].LatestPublishedVersion.ContentSize;
                        if(file.size < 1000)
                            file.sizeTxt = file.size.toString()+"B";
                        else if(file.size < 1000000)
                            file.sizeTxt = (file.size/1000).toFixed(0)+"kB";
                        else
                            file.sizeTxt = (file.size/1000000).toFixed(0)+"MB";

                        //folderList[groupList[gIdx]][idx++] = fileList[fIdx].LatestPublishedVersion;
                        folder.files.push(file);
                    }
                }
            }
            folderList.push(folder);
        }
        
        console.log(folderList);
        return folderList;
    }

    
})
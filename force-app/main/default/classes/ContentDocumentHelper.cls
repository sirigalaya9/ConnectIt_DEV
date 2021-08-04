public class ContentDocumentHelper 
{
    public static void updateOpportunities(Set<Id> oppId, Set<Id> cdlExcludeIds)
    {
        // got nothing, do nothing!
        if(oppId.IsEmpty())
            return;
        
        // get all files relating to the oppIds found...
        List<ContentDocumentLink> cdlLst = [SELECT LinkedEntityId, 
                                                   ContentDocumentId, 
                                                   ContentDocument.Title, 
                                                   ContentDocument.FileType, 
                                                   ContentDocument.FileExtension, 
                                                   ContentDocument.LatestPublishedVersion.Type__c, 
                                                   ContentDocument.LatestPublishedVersion.Group__c 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId IN (SELECT Id FROM Opportunity WHERE Id IN :oppId) 
                                            ORDER BY ContentDocument.Title];
    
        // get filenames and count...
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for(ContentDocumentLink cdl :cdlLst)
        {
            // skip excluded ids...
            if(cdlExcludeIds != null && cdlExcludeIds.contains(cdl.id))
                continue;
            
            Opportunity opp;
            
            // get opportunity, or initialise new instance (with Id)...
            if(oppMap.containsKey(cdl.LinkedEntityId))
                opp = oppMap.get(cdl.LinkedEntityId);
            else
                opp = new Opportunity(Id = cdl.LinkedEntityId, File_Count__c = 0, File_Names__c = '', File_Types__c = '');
            
            // append new filename and count...
            if(opp.File_Names__c == '')
                opp.File_Names__c = cdl.ContentDocument.Title + '.' + cdl.ContentDocument.FileExtension;
            else
                opp.File_Names__c = opp.File_Names__c + '; ' + cdl.ContentDocument.Title + '.' + cdl.ContentDocument.FileExtension;
            
            String ft = cdl.ContentDocument.LatestPublishedVersion.Type__c;
            if(ft == null)
                ft = 'null';
            if(opp.File_Types__c == '')
                opp.File_Types__c = ft;
            else
                if(!opp.File_Types__c.startsWith(ft) && !opp.File_Types__c.contains('; '+ft))  // only add type if not already in list...
                	opp.File_Types__c = opp.File_Types__c + '; ' + ft;
                
            opp.File_Count__c++;
            
            // update map...
            oppMap.put(cdl.LinkedEntityId, opp);
        }
        
        // update opportunity...
        update oppMap.values();
    }
    
    public static void updateContentVersion(Set<Id> cdIdLst)
    {
        // got nothing, do nothing!
        if(cdIdLst.IsEmpty())
            return;
        
        // get latest version of files found...
        List<ContentVersion> cvToUpdate = new List<ContentVersion>();
        List<ContentDocument> cdLst = [SELECT Id, 
                                              LatestPublishedVersionId, 
                                              LatestPublishedVersion.Type__c, 
                                              LatestPublishedVersion.Group__c 
                                       FROM ContentDocument 
                                       WHERE Id IN :cdIdLst
                                         AND FileType != 'SNOTE'];     // ignore notes
        
        // get file type setting for current user
        User currentUser = [SELECT File_Type__c, Group__c FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];  
        if(currentUser.File_Type__c == null)
            currentUser.File_Type__c = 'Other';
        
        // process each file...        
        for(ContentDocument cd :cdLst)
        {
            ContentVersion cv = new ContentVersion();
            cv.id = cd.LatestPublishedVersionId;
            Boolean updated = false;
            
            // is type null?
            if(cd.LatestPublishedVersion.Type__c == null)
            {
                // yes, update type to the user setting...
                cv.Type__c = currentUser.File_Type__c;
                updated = true;
            }
            
            // is group null?
            if(cd.LatestPublishedVersion.Group__c == null)
            {
                // yes, update type to the user setting...
                cv.Group__c = currentUser.Group__c;
                updated = true;
            }

            if(updated)
                cvToUpdate.add(cv);
        }
        
        // do update
        if(!cvToUpdate.isEmpty())
            update cvToUpdate;

    }

}
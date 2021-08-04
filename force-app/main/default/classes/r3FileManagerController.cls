public class r3FileManagerController 
{
	@AuraEnabled
    public static void deleteContentDocument(Id ContentDocumentId) 
    {
        Database.delete(ContentDocumentId);
    }
    
    @AuraEnabled
    public static List<ContentDocument> getRelatedFiles(Id LinkedEntityId, String fileFilter) 
    {        
        List<String> groups;
        if(fileFilter != null)
            groups = fileFilter.split('\\s*,\\s*');
        List<ContentDocument> cds;
        //Start - WI-00249 - Filters for file component
        String filterQuery = 'SELECT Id, Title, LatestPublishedVersionId, LatestPublishedVersion.Type__c, LatestPublishedVersion.Group__c, LatestPublishedVersion.ContentSize, LatestPublishedVersion.CreatedDate'
                                       + ' FROM ContentDocument WHERE Id IN :cdIds' ;
                                            
        if(fileFilter != null && fileFilter != '')
        {
            filterQuery += ' AND ' +  fileFilter ;
        }
        system.debug('R3 Query>>> '+filterQuery);
        // get cdls, and parse these for a list of cds
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :LinkedEntityId];
        Set<Id> cdIds = new Set<Id>();
        for(ContentDocumentLink cdl :cdls)
            cdIds.add(cdl.ContentDocumentId);
        
        cds = Database.query(filterQuery);
        //End - WI-00249 
        return cds;
    }
    
    
    @AuraEnabled
    public static List<String> getRelatedGroupList(Id LinkedEntityId) 
    {
        // get cdls, and parse these for a list of cds
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :LinkedEntityId];
        Set<Id> cdIds = new Set<Id>();
        for(ContentDocumentLink cdl :cdls)
            cdIds.add(cdl.ContentDocumentId);

        // get the cds together with groups...
        List<ContentDocument> cds = [SELECT LatestPublishedVersion.Group__c FROM ContentDocument WHERE Id IN :cdIds];

        Set<String> groups = new Set<String>();
        for(ContentDocument cd :cds)
        {
            if(cd.LatestPublishedVersion.Group__c == null)
            	groups.add('-');
        	else
                groups.add(cd.LatestPublishedVersion.Group__c);
        }

        // return groups as a sorted list...
        List<String> groupList = new List<String>(groups);
        groupList.sort();
        
        return groupList;
    }
}
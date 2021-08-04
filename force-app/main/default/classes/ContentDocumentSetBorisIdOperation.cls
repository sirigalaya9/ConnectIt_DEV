public without sharing class ContentDocumentSetBorisIdOperation 
{
    private List<ContentDocument> newList;
    private List<ContentDocumentLink> links = new List<ContentDocumentLink>();
    private Set<Id> opportunityIds = new Set<Id>();
    private Set<Id> accountIds = new Set<Id>();
    private Set<Id> projectIds = new Set<Id>();
    private Map<Id, String> opportunityIdToBorisIdMap = new Map<Id, String>();
    private Map<Id, String> accountIdToBorisIdMap = new Map<Id, String>();
    private Map<Id, String> projectIdToBorisIdMap = new Map<Id, String>();
    
    public ContentDocumentSetBorisIdOperation(List<SObject> newList) 
    {
        System.debug('ContentDocumentSetBorisIdOperation constructor');
        this.newList = (List<ContentDocument>) newList;
    }
    
    public void execute() 
    {
        if (isEnabled()) 
        {
            System.debug('newList.size(): ' + newList.size());
            
            processContentDocumentLinks();
            
            System.debug('links.size(): ' + links.size());
            
            if (links.size() == 0) 
            {
                return;
            }
            
            getOpportunityIdToBorisIdMap();
            
            getAccountIdToBorisIdMap();
            
            getProjectIdToBorisIdMap();
            
            updateContentVersions();
        }
    }
    
    private void updateContentVersions() 
    {
        Map<Id, ContentVersion> toUpdate = new Map<Id, ContentVersion>();
        
        for (ContentDocumentLink link : links) 
        {
            ContentVersion doc = new ContentVersion();
            
            if (link.ContentDocument.FileType != 'SNOTE') //WI-00789
            {
                // if we already have an update for this content version, update it...
                if(toUpdate.containsKey(link.ContentDocument.LatestPublishedVersionId))
                    doc = toUpdate.get(link.ContentDocument.LatestPublishedVersionId);
                                    
                // Opportunity
                if (link.LinkedEntityID.getSObjectType() == Opportunity.SObjectType) 
                {
                    if (opportunityIdToBorisIdMap.containsKey(link.LinkedEntityID))
                    {
                        doc.id = link.ContentDocument.LatestPublishedVersionId;
                        doc.site__c = opportunityIdToBorisIdMap.get(link.LinkedEntityID);
                        doc.Estimate__c = link.LinkedEntityID;
                        toUpdate.put(doc.Id, doc);
                    }
                }
                
                // Account
                if (link.LinkedEntityID.getSObjectType() == Account.SObjectType) 
                {
                    if (accountIdToBorisIdMap.containsKey(link.LinkedEntityID)) 
                    {
                        doc.id = link.ContentDocument.LatestPublishedVersionId;
                        doc.site__c = accountIdToBorisIdMap.get(link.LinkedEntityID);
                        toUpdate.put(doc.Id, doc);
                    }
                }
                
                // Project
                if (link.LinkedEntityID.getSObjectType() == CCMI__Milestone_Project__c.SObjectType)
                {
                    if (projectIdToBorisIdMap.containsKey(link.LinkedEntityID)) 
                    {
                        doc.id = link.ContentDocument.LatestPublishedVersionId;
                        doc.site__c = projectIdToBorisIdMap.get(link.LinkedEntityID);
                        doc.Project__c = link.LinkedEntityID;
                        toUpdate.put(doc.Id, doc);
                    }
                }
            }
        }
        
        System.debug(toUpdate.size());
        
        TriggerHandler.bypass('ContentDocumentTriggerHandler');
        DatabaseHelper.logSaveResultErrors(Database.update(toUpdate.values()));
        TriggerHandler.clearBypass('ContentDocumentTriggerHandler');
        
        // create BORIS File Update OUT records...
        ContentVersionTriggerHandler.createBorisFileUpdateOutRecords(toUpdate.values());
    }
    
    private void processContentDocumentLinks() {
        for (ContentDocumentLink link : [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, LinkedEntityId,ContentDocument.FileType 
                                         FROM ContentDocumentLink 
                                         WHERE ContentDocumentId IN :getContentDocumentIds()]) 
        {
            // Opportunity
            if (link.LinkedEntityID.getSObjectType() == Opportunity.SObjectType) 
            {
                opportunityIds.add(link.LinkedEntityID);
                links.add(link);
            }
            
            // Account
            if (link.LinkedEntityID.getSObjectType() == Account.SObjectType) 
            {
                accountIds.add(link.LinkedEntityID);
                links.add(link);
            }
            
            // Project
            if (link.LinkedEntityID.getSObjectType() == CCMI__Milestone_Project__c.SObjectType) 
            {
                projectIds.add(link.LinkedEntityID);
                links.add(link);
            }
        }
    }
    
    private void getProjectIdToBorisIdMap() 
    {
        for (CCMI__Milestone_Project__c project : [SELECT Id, Site__c FROM CCMI__Milestone_Project__c WHERE Id IN :projectIds]) 
        {
            projectIdToBorisIdMap.put(project.Id, project.Site__c);
        }
    }
    
    private void getAccountIdToBorisIdMap() 
    {
        for (Account account : [SELECT Id FROM Account WHERE Id IN :accountIds]) 
        {
            accountIdToBorisIdMap.put(account.Id, account.Id);
        }
    }
    
    private void getOpportunityIdToBorisIdMap() 
    {
        for (Opportunity opportunity : [SELECT Id, Site__c FROM Opportunity WHERE Id IN :opportunityIds]) 
        {
            opportunityIdToBorisIdMap.put(opportunity.Id, opportunity.Site__c);
        }
    }
    
    private Set<Id> getContentDocumentIds() 
    {
        Set<Id> ids = new Set<Id>();
        for (ContentDocument doc : newList) 
        {
            ids.add(doc.Id);
        }
        return ids;
    }
    
    private Boolean isEnabled() 
    {
        // TODO: add switch to enable / disable trigger operation
        return true;
    }
}
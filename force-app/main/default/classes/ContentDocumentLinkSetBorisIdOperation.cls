public without sharing class ContentDocumentLinkSetBorisIdOperation 
{
    private List<ContentDocumentLink> newList;
    private List<ContentDocumentLink> links = new List<ContentDocumentLink>();
    private Set<Id> opportunityIds = new Set<Id>();
    private Set<Id> accountIds = new Set<Id>();
    private Set<Id> projectIds = new Set<Id>();

    public ContentDocumentLinkSetBorisIdOperation(List<SObject> newList) 
    {
        System.debug('ContentDocumentLinkSetBorisIdOperation constructor');
        this.newList = (List<ContentDocumentLink>) newList;
    }

    public void execute() 
    {
        if (isEnabled()) 
        {
            processContentDocumentLinks();

            System.debug(links.size());

            if (links.size() == 0) 
            {
                return;
            }

            Map<Id, String> opportunityIdToBorisIdMap = getOpportunityIdToBorisIdMap();

            Map<Id, String> accountIdToBorisIdMap = getAccountIdToBorisIdMap();

            Map<Id, String> projectIdToBorisIdMap = getProjectIdToBorisIdMap();
            Map<Id, String> estimateToProjectIdMap = getEstimateToProjectIdMap();

            Map<Id, ContentVersion> contentDocumentIdToContentVersionMap = getContentVersionMap();

            System.debug('ContentDocumentLinkSetBorisIdOperation execute contentDocumentIdToContentVersionMap: '+contentDocumentIdToContentVersionMap);

            Map<Id, ContentVersion> toUpdate = new Map<Id, ContentVersion>();

            for (ContentDocumentLink link : links) 
            {
                ContentVersion doc = new ContentVersion();
                Id cdId = link.ContentDocumentId;
                Id cvId;
                if(contentDocumentIdToContentVersionMap.containsKey(cdId))
                   cvId = contentDocumentIdToContentVersionMap.get(cdId).Id;
                else
                {
                   system.debug('R3>>> WARNING: Unable to find cdId ('+cdId+') in contentDocumentIdToContentVersionMap');
                   continue;
                }
                if(toUpdate.containsKey(cvId))
                    doc = toUpdate.get(cvId);
                doc.id = cvId;
                
                // Opportunity
                if (link.LinkedEntityID.getSObjectType() == Opportunity.SObjectType) 
                {
                    if (estimateToProjectIdMap.containsKey(link.LinkedEntityID)) 
                        doc.Project__c = estimateToProjectIdMap.get(link.LinkedEntityID);

                    if (opportunityIdToBorisIdMap.containsKey(link.LinkedEntityID)) 
                        doc.site__c = opportunityIdToBorisIdMap.get(link.LinkedEntityID);
                    doc.Estimate__c = link.LinkedEntityID;
                    
                    toUpdate.put(cvId,doc);                    
                }

                // Account
                if (link.LinkedEntityID.getSObjectType() == Account.SObjectType) 
                {
                    doc.site__c = accountIdToBorisIdMap.get(link.LinkedEntityID);
                    toUpdate.put(cvId,doc);
                }

                // Project
                if (link.LinkedEntityID.getSObjectType() == CCMI__Milestone_Project__c.SObjectType) 
                {
                    
                    if (projectIdToBorisIdMap.containsKey(link.LinkedEntityID)) 
                        doc.site__c = projectIdToBorisIdMap.get(link.LinkedEntityID);
                    doc.Project__c = link.LinkedEntityID;
                    system.debug('R3>>> ContentDocumentLinkSetBorisIdOperation cv.Id=' + doc.Id + ', ProjectId=' + doc.Project__c+ ', cv=' + doc);
                    toUpdate.put(cvId,doc);
                }
            }

            System.debug(toUpdate.size());

            TriggerHandler.bypass('ContentDocumentTriggerHandler');
            System.debug('ContentDocumentLinkSetBorisIdOperation constructor toUpdate.values()'+ toUpdate.values());
            DatabaseHelper.logSaveResultErrors(Database.update(toUpdate.values()));
            TriggerHandler.clearBypass('ContentDocumentTriggerHandler');
            
            // create BORIS File Update OUT records...
            ContentVersionTriggerHandler.createBorisFileUpdateOutRecords(toUpdate.values());


        }
    }

    private Map<Id, ContentVersion> getContentVersionMap() 
    {
        Map<Id, ContentVersion> toReturn = new Map<Id, ContentVersion>();
        List<Id> contentDocumentIds = new List<Id>();
        contentDocumentIds.addAll(getContentDocumentIds());
        System.debug('ContentDocumentLinkSetBorisIdOperation getContentVersionMap contentDocumentIds: '+contentDocumentIds);

        Set<Id> latestContentVersionIds = new Map<Id, ContentDocument>([SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id IN :contentDocumentIds]).keySet();
        List<Id> latestContentVersionIdList = new List<Id>();
        latestContentVersionIdList.addAll(latestContentVersionIds);
        System.debug('ContentDocumentLinkSetBorisIdOperation getContentVersionMap latestContentVersionIdList: '+latestContentVersionIdList);
        //List<ContentVersion> latestContentVersions = [SELECT Id, ContentDocumentId, Project__c, Site__c, Estimate__c, group__c, type__c FROM ContentVersion WHERE Id IN :latestContentVersionIdList]; // KF* Returns nothing
        List<ContentVersion> latestContentVersions = [SELECT Id, ContentDocumentId, Project__c, Site__c, Estimate__c, group__c, type__c FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds]; 
        System.debug('ContentDocumentLinkSetBorisIdOperation getContentVersionMap latestContentVersions: '+latestContentVersions);
        
        for (ContentVersion doc : latestContentVersions) 
        {
            toReturn.put(doc.ContentDocumentId, doc);
        }
        System.debug('ContentDocumentLinkSetBorisIdOperation getContentVersionMap toReturn: '+toReturn);
        return toReturn;
    }

    private Set<Id> getContentDocumentIds() 
    {
        Set<Id> ids = new Set<Id>();
        for (ContentDocumentLink link : links) 
        {
            ids.add(link.ContentDocumentId);
        }
        return ids;
    }

    private Map<Id, String> getProjectIdToBorisIdMap() 
    {
        Map<Id, String> toReturn = new Map<Id, String>();

        for (CCMI__Milestone_Project__c project : [SELECT Id, Site__c FROM CCMI__Milestone_Project__c WHERE Id IN :projectIds AND Site__r.RecordTypeId = :AccountUtil.getSiteAccountRecordTypeId]) 
        {
            //if(project.site__c != null)
	            toReturn.put(project.Id, project.Site__c);
        }
        return toReturn;
    }

    private Map<Id, String> getEstimateToProjectIdMap() 
    {
        Map<Id, String> toReturn = new Map<Id, String>();

        for (Opportunity opportunity : [SELECT Id, Project__c FROM Opportunity WHERE Id IN :opportunityIds]) 
        {
            //if(project.Project__c != null)
	            toReturn.put(opportunity.Id, opportunity.Project__c);
        }
        return toReturn;
    }

    private Map<Id, String> getAccountIdToBorisIdMap() 
    {
        Map<Id, String> toReturn = new Map<Id, String>();

        for (Account account : [SELECT Id FROM Account WHERE Id IN :accountIds AND RecordTypeId = :AccountUtil.getSiteAccountRecordTypeId]) {
            toReturn.put(account.Id, account.Id);
        }
        return toReturn;
    }

    private Map<Id, String> getOpportunityIdToBorisIdMap() 
    {
        Map<Id, String> toReturn = new Map<Id, String>();

        for (Opportunity opportunity : [SELECT Id, Site__c FROM Opportunity WHERE Id IN :opportunityIds]) {
            //if(opportunity.site__c != null)
	            toReturn.put(opportunity.Id, opportunity.Site__c);
        }
        return toReturn;
    }

    private void processContentDocumentLinks() 
    {
        for (ContentDocumentLink link : newList) 
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

    private Boolean isEnabled() {
        // TODO: add switch to enable / disable trigger operation
        return true;
    }
}
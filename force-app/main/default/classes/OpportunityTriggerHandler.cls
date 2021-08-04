public with sharing class OpportunityTriggerHandler extends TriggerHandler 
{
    public override void afterUpdate() 
    {
        // update CVs
        List<ContentVersion> docsToUpdate = new List<ContentVersion>();
        Map <id, Opportunity> oldEstimatesMap = (Map<id, Opportunity>)Trigger.oldMap;
        Map <id, Opportunity> newEstimatesMap = (Map<id, Opportunity>)Trigger.newMap;

        // Get Docs to update
        List<ContentVersion> docs = [SELECT Id, Project__c, Estimate__c  FROM ContentVersion WHERE Estimate__c IN :Trigger.newMap.keySet()]; 

        for (ContentVersion doc : docs) 
        {
            //System.debug('estimate='+estimate);
            System.debug('doc='+doc.Estimate__c);
            if (doc.Estimate__c != null) {
                Opportunity estimate = newEstimatesMap.get(doc.Estimate__c);
                if (estimate.Project__c != null) {
                    doc.Project__c = estimate.Project__c;
                    docsToUpdate.add(doc);                   
                }
            }
        }   
        
        // update docs
        if (docsToUpdate.size() > 0 ) {
            update docsToUpdate;
        }
    }
}
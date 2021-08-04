public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        new ContentDocumentLinkSetBorisIdOperation(Trigger.new).execute();

        Set<Id> toUpdate = new Set<Id>();

        for (ContentDocumentLink link : (List<ContentDocumentLink>) Trigger.new) {
            // get all links to opportunities (ignore the rest!)
            if (link.LinkedEntityID.getSObjectType() == Opportunity.SObjectType) {
                toUpdate.add(link.LinkedEntityID);
            }
        }
        ContentDocumentHelper.updateOpportunities(toUpdate, null);
    }

    public override void afterDelete() {
        // only fires for un-shares, deletion fires the ContentDocumentTrigger only!

        Set<Id> toUpdate = new Set<Id>();

        for (ContentDocumentLink link : (List<ContentDocumentLink>) Trigger.old) {
            // get all links to opportunities (ignore the rest!)
            if (link.getSObjectType() == Opportunity.SObjectType) {
                toUpdate.add(link.LinkedEntityID);
            }
        }

        ContentDocumentHelper.updateOpportunities(toUpdate, null);
    }
}
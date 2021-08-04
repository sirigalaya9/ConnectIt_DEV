public with sharing class ContentDocumentTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        new ContentDocumentSetBorisIdOperation(Trigger.new).execute();
    }

    public override void beforeDelete() {
        List<Id> cdIds = new List<Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> cdlIds = new Set<Id>();

        // When you delete a file the ContentDocumentLink trigger is not executed, so this trigger is needed to handle deletion (weird!)

        // get contentDocument
        for (ContentDocument cd : (List<ContentDocument>) Trigger.old) {
            cdIds.add(cd.Id);
        }

        // get ContentDocumentLinks related to ContentDocument (to ultimately get the object to which it is attached..)
        List<ContentDocumentLink> links = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :cdIds];

        for (ContentDocumentLink cdl : links) {
            cdlIds.add(cdl.Id);
            if (cdl.LinkedEntityId.getSObjectType() == Opportunity.SObjectType) {
                oppIds.add(cdl.LinkedEntityId); // collect the opportunity ids only
            }
        }

        ContentDocumentHelper.updateOpportunities(oppIds, cdlIds);
    }
}
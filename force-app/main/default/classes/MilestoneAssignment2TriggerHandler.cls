public without sharing class MilestoneAssignment2TriggerHandler extends TriggerHandler {
    public override void beforeDelete() {
        if(isTriggerEnabled()) {
            new AssignmentDeleteBorisPlannerOperation(Trigger.oldMap).beforeDelete();
        }
    }

    private Boolean isTriggerEnabled() {
        return true;
        // return Triggers__c.getOrgDefaults().Prescription_Trigger__c;
    }
}
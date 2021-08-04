public with sharing class AssignmentDeleteBorisPlannerOperation {

    private final Map<Id, CCMI__Milestone_Assignment2__c> newMap;

    public AssignmentDeleteBorisPlannerOperation(Map<Id, SObject> newMap) {
        this.newMap = (Map<Id, CCMI__Milestone_Assignment2__c>) newMap;
    }

    public void beforeDelete() {

        List<BORIS_Planner_OUT__c> bpoList = new List<BORIS_Planner_OUT__c>();

        // get all the assignments + lookups
        Map<Id, CCMI__Milestone_Assignment2__c> assignmentsMap = new Map<Id, CCMI__Milestone_Assignment2__c>([
            SELECT OwnerId, CCMI__Milestone_Task__r.CCMI__Milestone_Project__r.CCMI__Account__c, CCMI__Milestone_Task__r.CCMI__Milestone_Project__r.Site__c
            FROM CCMI__Milestone_Assignment2__c
            WHERE Id IN :newMap.keySet()
        ]);

        // create a "Delete" bpo record.
        for (Id assignmentId : newMap.keySet()) {
            CCMI__Milestone_Assignment2__c assignment = assignmentsMap.get(assignmentId);

            BORIS_Planner_OUT__c bpo = new BORIS_Planner_OUT__c();
            bpo.CustomerId__c = assignment.CCMI__Milestone_Task__r.CCMI__Milestone_Project__r.CCMI__Account__c;
            bpo.LocationId__c = assignment.CCMI__Milestone_Task__r.CCMI__Milestone_Project__r.Site__c;
            bpo.UserId__c = assignment.OwnerId;
            bpo.DefinitionPK__c = 'SF';
            bpo.Operation__c = 'D';
            bpoList.add(bpo);
        }
        insert bpoList;
    }
}
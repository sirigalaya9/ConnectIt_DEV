@isTest
public class AssignmentTestDataFactory {

 /*   public static CCMI__Milestone_Assignment2__c create(Id ownerId, Id taskId) {
        CCMI__Milestone_Assignment2__c assignment = new CCMI__Milestone_Assignment2__c();
        assignment.OwnerId = ownerId;
        assignment.CCMI__Milestone_Task__c = taskId;
        insert assignment;
        return assignment;
    } */
    
        public static Assignment__c create(Id ownerId, Id taskId) {
        Assignment__c assignment = new Assignment__c();
        assignment.OwnerId = ownerId;
        assignment.Assigned_To__c=ownerId;
        assignment.Project_Task__c = taskId;
        insert assignment;
        return assignment;
    }
}
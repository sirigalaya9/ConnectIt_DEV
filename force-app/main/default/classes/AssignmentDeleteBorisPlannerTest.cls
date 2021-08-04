@isTest
public class AssignmentDeleteBorisPlannerTest {


    @isTest
    public static void testDeleteBorisPlanner() {

        Id site1Id = SiteTestDataFactory.create();
        Id project1Id = ProjectTestDataFactory.create(site1Id, site1Id).Id;

        //create task
        CCMI__Milestone_Task__c task1 = TaskTestDataFactory.create(
            project1Id,
            Date.newInstance(2020, 08, 01),
            null,
            null,
            1400);

        List<CCMI__Milestone_Task__c> tasksList = [SELECT CCMI__Milestone_Project__r.CCMI__Account__c, CCMI__Milestone_Project__r.Site__c FROM CCMI__Milestone_Task__c];
        System.debug(tasksList[0].CCMI__Milestone_Project__r.Site__c);

        // create user
        User user1 = UserTestDataFactory.createUser('testUser1@email.com', 'lastname', 'System Administrator');

        // create assignment
        CCMI__Milestone_Assignment2__c assignment1 = AssignmentTestDataFactory.create(user1.Id, task1.Id);

        test.startTest();
        delete assignment1;
        test.stopTest();

        List<BORIS_Planner_OUT__c> bpoList = [SELECT Id, UserId__c, CustomerId__c, LocationId__c, DefinitionPK__c, Operation__c FROM BORIS_Planner_OUT__c];

        // One BORIS Planner OUT record should be created
        System.assertEquals(1, bpoList.size());
        System.assertEquals(user1.Id, bpoList[0].UserId__c);
        System.assertEquals(tasksList[0].CCMI__Milestone_Project__r.CCMI__Account__c, bpoList[0].CustomerId__c);
        System.assertEquals(tasksList[0].CCMI__Milestone_Project__r.Site__c, bpoList[0].LocationId__c);
        System.assertEquals('SF', bpoList[0].DefinitionPK__c);
        System.assertEquals('D', bpoList[0].Operation__c);
    }


}
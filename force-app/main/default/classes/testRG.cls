@isTest
public class testRG {
    static testMethod void test()
    {
                // Insert Project
        CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
        insert milestoneProject;
        List<String> projectIdList = new List<String>();
        projectIdList.add(milestoneProject.id);
        
        CCMI__Milestone_Task__c milestoneProjectTask1 = new CCMI__Milestone_Task__c(CCMI__Milestone_Project__c = milestoneProject.id, CCMI__Desired_Start__c = system.today(), CCMI__Duration__c = 1);
        insert milestoneProjectTask1;

        CCMI__Milestone_Task__c milestoneProjectTask2 = new CCMI__Milestone_Task__c(CCMI__Milestone_Project__c = milestoneProject.id, CCMI__Desired_Start__c = system.today(), CCMI__Duration__c = 1);
        insert milestoneProjectTask2;

        CCMI__Milestone_Task__c milestoneProjectTask3 = new CCMI__Milestone_Task__c(CCMI__Milestone_Project__c = milestoneProject.id, CCMI__Desired_Start__c = system.today(), CCMI__Duration__c = 1);
        insert milestoneProjectTask3;
        
        CCMI__Milestone_Assignment2__c assignment1 = new CCMI__Milestone_Assignment2__c(CCMI__Milestone_Task__c = milestoneProjectTask1.id);
        insert assignment1;

        CCMI__Milestone_Assignment2__c assignment2 = new CCMI__Milestone_Assignment2__c(CCMI__Milestone_Task__c = milestoneProjectTask2.id);
        insert assignment2;

        newGanttChart.getGanttChartSettings();
        newGanttChart.setGanttChartSettings('test', 'test', 'test', 'test', 'test', 'test', 'test');
        newGanttChart.getResources();
        newGanttChart.getProjects();
        newGanttChart.getGanttChartData(milestoneProject.id, 'project-overview', String.valueOf(system.now().getTime()-3600), String.valueOf(system.now().getTime()+3600), 1, 1, 10, new List<String>(), new List<String>(), new List<String>(), '', '', '', '', null);
        newGanttChart.getGanttChartData(milestoneProject.id, 'resource-overview', String.valueOf(system.now().getTime()-3600), String.valueOf(system.now().getTime()+3600), 1, 1, 10, new List<String>(), new List<String>(), new List<String>(), '', '', '', '', null);
        newGanttChart.saveTask(milestoneProjectTask2.id, milestoneProject.id, 'test', 'active', 'gas', false, false, '1', '2', '00:00', '01:00', '', '', milestoneProjectTask1.id);
        newGanttChart.saveAllocation(assignment1.id, milestoneProjectTask1.id, UserInfo.getUserId(), 'test', '2', 'active', '1', '2');
        newGanttChart.deleteAllocation(milestoneProjectTask2.id);
    }
}
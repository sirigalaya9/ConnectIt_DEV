@isTest
public class TaskTestDataFactory {

    public static CCMI__Milestone_Task__c create(Id projectId, Date desiredStartDate, Time startTime, Time endTime, Decimal duration) {
        CCMI__Milestone_Task__c task = new CCMI__Milestone_Task__c();
        task.CCMI__Milestone_Project__c = projectId;
        task.CCMI__Desired_Start__c = desiredStartDate;
        task.CCMI__Duration__c = duration;
        task.Start_Time__c = startTime;
        task.End_Time__c = endTime;
        insert task;
        return task;
    }

    public static CCMI__Milestone_Task__c createBORISJobTask(Id projectId, Date desiredStartDate, Time startTime, Time endTime, Decimal duration) {
        CCMI__Milestone_Task__c task = new CCMI__Milestone_Task__c();
        task.CCMI__Milestone_Project__c = projectId;
        task.CCMI__Desired_Start__c = desiredStartDate;
        task.CCMI__Duration__c = duration;
        task.Start_Time__c = startTime;
        task.End_Time__c = endTime;
        task.BORIS_job__c = true;
        insert task;
        return task;
    }
}
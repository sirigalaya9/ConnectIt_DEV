@isTest
private class milestoneTaskTrigger2Test 
{
    /* moved to MilestoneTaskTriggerHandlerTest 
    static Account siteAcc;
    static CCMI__Milestone_Task__c task;
    static User user1;
    static User user2;
    static Assignment__c ass1;
    static Assignment__c ass2;

    @isTest static void testInsertTask()
    {
        setupData();

        List<BORIS_Planner_OUT__c> bpos = 
            [
                SELECT Id, 
                    DefinitionPK__c,
                    DurationMins__c,
                    Integration_Status__c,
                    LocationId__c,
                    Notes__c,
                    WorkOrderDateTime__c,
                    WorkOrderId__c,
                    UserId__c,
                    Operation__c
                FROM BORIS_Planner_OUT__c
            ];

        system.debug(bpos);

        // how many bps's did we get (expecting 2)
        system.assertEquals(2, bpos.size());

        // check bps[0]...
        system.assertEquals('SF', bpos[0].DefinitionPK__c);
        system.assertEquals(1440, bpos[0].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[0].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[0].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[0].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[0].WorkOrderId__c);
        system.assertEquals(User1.Id, bpos[0].UserId__c);
        system.assertEquals('UI', bpos[0].Operation__c);

        // check bps[1]...
        system.assertEquals('SF', bpos[1].DefinitionPK__c);
        system.assertEquals(1440, bpos[1].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[1].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[1].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[1].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[1].WorkOrderId__c);
        system.assertEquals(User2.Id, bpos[1].UserId__c);
        system.assertEquals('UI', bpos[1].Operation__c);
    }

    @isTest static void testDeleteAssignment()
    {
        setupData();

        // delete bpos created from data setup...
        List<BORIS_Planner_OUT__c> bposToDelete = [ SELECT Id FROM BORIS_Planner_OUT__c ];
        delete bposToDelete;

        // delete assignment (creates bpo)
        delete ass1;

        List<BORIS_Planner_OUT__c> bpos = 
            [
                SELECT Id, 
                    DefinitionPK__c,
                    DurationMins__c,
                    Integration_Status__c,
                    LocationId__c,
                    Notes__c,
                    WorkOrderDateTime__c,
                    WorkOrderId__c,
                    UserId__c,
                    Operation__c
                FROM BORIS_Planner_OUT__c
            ];

        system.debug(bpos);

        // how many bps's did we get (expecting 1)
        system.assertEquals(1, bpos.size());

        system.assertEquals('SF', bpos[0].DefinitionPK__c);
        system.assertEquals(1440, bpos[0].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[0].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[0].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[0].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[0].WorkOrderId__c);
        system.assertEquals(User1.Id, bpos[0].UserId__c);
        system.assertEquals('D', bpos[0].Operation__c);
    }

    @isTest static void testDeleteTask()
    {
        setupData();

        // delete bpos created from data setup...
        List<BORIS_Planner_OUT__c> bposToDelete = [ SELECT Id FROM BORIS_Planner_OUT__c ];
        delete bposToDelete;

        // delete assignment (creates bpo)
        delete task;

        List<BORIS_Planner_OUT__c> bpos = 
            [
                SELECT Id, 
                    DefinitionPK__c,
                    DurationMins__c,
                    Integration_Status__c,
                    LocationId__c,
                    Notes__c,
                    WorkOrderDateTime__c,
                    WorkOrderId__c,
                    UserId__c,
                    Operation__c
                FROM BORIS_Planner_OUT__c
            ];

        system.debug(bpos);

        // how many bps's did we get (expecting 2)
        system.assertEquals(2, bpos.size());

        // check bps[0]...
        system.assertEquals('SF', bpos[0].DefinitionPK__c);
        system.assertEquals(1440, bpos[0].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[0].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[0].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[0].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[0].WorkOrderId__c);
        system.assertEquals(User1.Id, bpos[0].UserId__c);
        system.assertEquals('D', bpos[0].Operation__c);

        // check bps[1]...
        system.assertEquals('SF', bpos[1].DefinitionPK__c);
        system.assertEquals(1440, bpos[1].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[1].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[1].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[1].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[1].WorkOrderId__c);
        system.assertEquals(User2.Id, bpos[1].UserId__c);
        system.assertEquals('D', bpos[1].Operation__c);
    }

    @isTest static void testUpdateTaskNonBORIS()
    {
        setupData();

        // delete bpos created from data setup...
        List<BORIS_Planner_OUT__c> bposToDelete = [ SELECT Id FROM BORIS_Planner_OUT__c ];
        delete bposToDelete;

        // delete assignment (creates bpo)
        task.BORIS_job__c = false;
        update task;

        List<BORIS_Planner_OUT__c> bpos = 
            [
                SELECT Id, 
                    DefinitionPK__c,
                    DurationMins__c,
                    Integration_Status__c,
                    LocationId__c,
                    Notes__c,
                    WorkOrderDateTime__c,
                    WorkOrderId__c,
                    UserId__c,
                    Operation__c
                FROM BORIS_Planner_OUT__c
            ];

        system.debug(bpos);

        // how many bps's did we get (expecting 2)
        system.assertEquals(2, bpos.size());

        // check bps[0]...
        system.assertEquals('SF', bpos[0].DefinitionPK__c);
        system.assertEquals(1440, bpos[0].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[0].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[0].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[0].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[0].WorkOrderId__c);
        system.assertEquals(User1.Id, bpos[0].UserId__c);
        system.assertEquals('D', bpos[0].Operation__c);

        // check bps[1]...
        system.assertEquals('SF', bpos[1].DefinitionPK__c);
        system.assertEquals(1440, bpos[1].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[1].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[1].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[1].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[1].WorkOrderId__c);
        system.assertEquals(User2.Id, bpos[1].UserId__c);
        system.assertEquals('D', bpos[1].Operation__c);
    }

    @isTest static void testUpdateTask()
    {
        setupData();

        // delete bpos created from data setup...
        List<BORIS_Planner_OUT__c> bposToDelete = [ SELECT Id FROM BORIS_Planner_OUT__c ];
        delete bposToDelete;

        // delete assignment (creates bpo)
        task.End__c = Date.newInstance(2019, 7, 4);
        update task;

        List<BORIS_Planner_OUT__c> bpos = 
            [
                SELECT Id, 
                    DefinitionPK__c,
                    DurationMins__c,
                    Integration_Status__c,
                    LocationId__c,
                    Notes__c,
                    WorkOrderDateTime__c,
                    WorkOrderId__c,
                    UserId__c,
                    Operation__c
                FROM BORIS_Planner_OUT__c
            ];

        system.debug(bpos);

        // how many bps's did we get (expecting 1)
        system.assertEquals(2, bpos.size());

        // check bps[0]...
        system.assertEquals('SF', bpos[0].DefinitionPK__c);
        system.assertEquals(2880, bpos[0].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[0].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[0].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[0].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[0].WorkOrderId__c);
        system.assertEquals(User1.Id, bpos[0].UserId__c);
        system.assertEquals('UI', bpos[0].Operation__c);

        // check bps[1]...
        system.assertEquals('SF', bpos[1].DefinitionPK__c);
        system.assertEquals(2880, bpos[1].DurationMins__c);
        system.assertEquals(siteAcc.Id, bpos[1].LocationId__c);
        system.assertEquals(task.CCMI__Description__c, bpos[1].Notes__c);
        system.assertEquals('2019-07-03 08:00:00', bpos[1].WorkOrderDateTime__c);
        system.assertEquals(task.Id, bpos[1].WorkOrderId__c);
        system.assertEquals(User2.Id, bpos[1].UserId__c);
        system.assertEquals('UI', bpos[1].Operation__c);
    }

    private static void setupData()
    {
        Account custAcc = new Account(Name = 'customer');
        insert custAcc;

        Id RecordTypeIdAccountSite = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        siteAcc = new Account(Name = 'site', RecordTypeId = RecordTypeIdAccountSite);
        insert siteAcc;

        CCMI__Milestone_Project__c proj = new CCMI__Milestone_Project__c(Name = 'project', CCMI__Account__c = custAcc.id, Site__c = siteAcc.id);
        insert proj;

        task = new CCMI__Milestone_Task__c(
            Name = 'task 1', 
            CCMI__Milestone_Project__c = proj.id, 
            CCMI__Desired_Start__c = Date.newInstance(2019, 7, 3),
            CCMI__Duration__c = 1,
            Start__c = Date.newInstance(2019, 7, 3),
            End__c = Date.newInstance(2019, 7, 3),
            CCMI__Description__c = 'desc',
            BORIS_job__c = true);
        insert task;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        user1 = new User(Alias = 'standt1', Email='standarduser1@cius.co.uk', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@cius.co.uk');
        insert user1;

        user2 = new User(Alias = 'standt2', Email='standarduser2@cius.co.uk', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@cius.co.uk');
        insert user2;

        ass1 = new Assignment__c(
            Assigned_To__c  = user1.id,
            Project_Task__c  = task.id
        );
        insert ass1;

        ass2 = new Assignment__c(
            Assigned_To__c  = user2.id,
            Project_Task__c  = task.id
        );
        insert ass2;
    }
    */
}
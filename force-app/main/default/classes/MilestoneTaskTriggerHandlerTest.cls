@isTest
    private class MilestoneTaskTriggerHandlerTest 
    {
        @testSetup 
        static void setup()
        {
            // project start date
            Date projectStart = Date.newInstance(2019, 4, 26);
            
            // create project
            CCMI__Milestone_Project__c proj = new CCMI__Milestone_Project__c(Name = 'Test Project');
            insert proj;
            
            // insert some tasks
            List<CCMI__Milestone_Task__c> tasks = new List<CCMI__Milestone_Task__c>();
            for(Integer idx = 1; idx <= 10; idx++)
                tasks.add(new CCMI__Milestone_Task__c(Name = 'task '+idx, CCMI__Desired_Start__c = projectStart, CCMI__Duration__c = idx, CCMI__Milestone_Project__c = proj.id));
            insert tasks;
            
            // update tasks with predecessors
            for(Integer idx = 1; idx < 10; idx++)
                tasks[idx].CCMI__Parent__c = tasks[idx-1].id;
            update tasks;
            
        }
        
        static testMethod void test_checkStartEndDates()
        {
            system.debug('test_checkStartEndDates');
            List<CCMI__Milestone_Task__c> tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
            Integer idx = 0;
            for(CCMI__Milestone_Task__c task :tasks)
            {
                system.debug(task);
                system.assertEquals(task.CCMI__start__c, task.start__c);
                system.assertEquals(task.CCMI__end__c, task.end__c);
                system.assertEquals(idx+1, task.CCMI__duration__c);
                idx++;
            }
        }
    
        static testMethod void test_moveTask()
        {
            system.debug('test_moveTask');
            
            // get tasks
            List<CCMI__Milestone_Task__c> tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // update start and end date by one (Friday 17th May 2019 to Saturday 18th May 2019)
            tasks[5].start__c += 1;
            tasks[5].end__c += 1;
            update tasks[5];
    
            // reload tasks
            tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // check specific date
            system.debug(tasks[5]);
            system.assertEquals(Date.newInstance(2019, 5, 20), tasks[5].start__c);  // jumps to Monday 20th
            system.assertEquals(Date.newInstance(2019, 5, 27), tasks[5].end__c);	// jumps to Monday 27th
            system.assertEquals(6, tasks[5].CCMI__duration__c);						// remains at 6 days
            
            // check the rest...
            Integer idx = 0;
            for(CCMI__Milestone_Task__c task :tasks)
            {
                system.debug(task);
                system.assertEquals(task.CCMI__start__c, task.start__c);
                system.assertEquals(task.CCMI__end__c, task.end__c);
                system.assertEquals(idx+1, task.CCMI__duration__c);
                idx++;
            }
        }
        
        static testMethod void test_moveStartDate()
        {
            system.debug('test_moveStartDate');
            
            // get tasks
            List<CCMI__Milestone_Task__c> tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // check data is as expected
            system.assertEquals(Date.newInstance(2019, 5, 17), tasks[5].start__c);	// Friday 17th
            system.assertEquals(Date.newInstance(2019, 5, 24), tasks[5].end__c);	// Friday 24th
            system.assertEquals(6, tasks[5].CCMI__duration__c);						// 6 days
            system.assertEquals(Date.newInstance(2019, 5, 27), tasks[6].start__c);	// Monday 26th
    
            // update start one (Friday 17th May 2019 to Saturday 18th May 2019)
            tasks[5].start__c += 1;
            update tasks[5];
    
            // reload tasks
            tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // check specific dates
            system.debug(tasks[5]);
            system.assertEquals(Date.newInstance(2019, 5, 20), tasks[5].start__c);  // jumps to Monday 20th
            system.assertEquals(Date.newInstance(2019, 5, 24), tasks[5].end__c);	// remains at Friday 24th
            system.assertEquals(5, tasks[5].CCMI__duration__c);						// reduces to 5 days
    
            system.debug(tasks[6]);
            system.assertEquals(Date.newInstance(2019, 5, 27), tasks[6].start__c);	// remains at Monday 26th
        }
        
        static testMethod void test_moveEndDate()
        {
            system.debug('test_moveEndDate');
            
            // get tasks
            List<CCMI__Milestone_Task__c> tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // check data is as expected
            system.assertEquals(Date.newInstance(2019, 5, 17), tasks[5].start__c);	// Friday 17th
            system.assertEquals(Date.newInstance(2019, 5, 24), tasks[5].end__c);	// Friday 24th
            system.assertEquals(6, tasks[5].CCMI__duration__c);						// 6 days
            system.assertEquals(Date.newInstance(2019, 5, 27), tasks[6].start__c);	// Monday 27th
    
            // update end by three days (Friday 24th May 2019 to Monday 27th May 2019)
            tasks[5].end__c += 3;
            update tasks[5];
    
            // reload tasks
            tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // check specific dates
            system.debug(tasks[5]);
            system.assertEquals(Date.newInstance(2019, 5, 17), tasks[5].start__c);  // remains to Friday 17th
            system.assertEquals(Date.newInstance(2019, 5, 27), tasks[5].end__c);	// moves to Monday 27th
            system.assertEquals(7, tasks[5].CCMI__duration__c);						// increases to 7 days
    
            system.debug(tasks[6]);
            system.assertEquals(Date.newInstance(2019, 5, 28), tasks[6].start__c);	// moves to Tuesday 28th
        }
        
        static testMethod void test_moveStartDateBack()
        {
            system.debug('test_moveStartDateBack');
            
            // get tasks
            List<CCMI__Milestone_Task__c> tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // check data is as expected
            system.assertEquals(Date.newInstance(2019, 5, 17), tasks[5].start__c);	// Friday 17th
            system.assertEquals(Date.newInstance(2019, 5, 24), tasks[5].end__c);	// Friday 24th
            system.assertEquals(6, tasks[5].CCMI__duration__c);						// 6 days
            system.assertEquals(Date.newInstance(2019, 5, 27), tasks[6].start__c);	// Monday 27th
    
            // update start by minus three days (Friday 24th May 2019 to Tuesday 21th May 2019)
            tasks[5].start__c -= 3;
            update tasks[5];
    
            // reload tasks
            tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // check specific dates
            system.debug(tasks[5]);
            system.assertEquals(Date.newInstance(2019, 5, 17), tasks[5].start__c);  // remains to Friday 17th
            system.assertEquals(Date.newInstance(2019, 5, 24), tasks[5].end__c);	// remains to Friday 24th
            system.assertEquals(6, tasks[5].CCMI__duration__c);						// remains to 6 days
    
            system.debug(tasks[6]);
            system.assertEquals(Date.newInstance(2019, 5, 27), tasks[6].start__c);	// remains to Monday 27th
        }
    
        static testMethod void test_includeWeekends()
        {
            system.debug('test_includeWeekends');
            
            // get tasks
            List<CCMI__Milestone_Task__c> tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // update to include weekends (currently Friday 17th May 2019 to Friday 24th May 2019)
            tasks[5].Include_Weekends__c = true;
            update tasks[5];
    
            // reload tasks
            tasks = [SELECT Id, Name, Start__c, CCMI__Start__c, CCMI__Desired_Start__c, End__c, CCMI__End__c, CCMI__Duration__c, CCMI__Calculated_Duration__c, CCMI__Completed_Date__c, CCMI__Parent_End__c FROM CCMI__Milestone_Task__c ORDER BY Id ASC];
    
            // check specific date
            system.debug(tasks[5]);
            system.assertEquals(Date.newInstance(2019, 5, 17), tasks[5].start__c);  // remains Friday 17th
            system.assertEquals(Date.newInstance(2019, 5, 22), tasks[5].end__c);	// updated to Wednesday 22th
            system.assertEquals(6, tasks[5].CCMI__duration__c);						// remains at 6 days
            
            // check the rest...
            Integer idx = 0;
            for(CCMI__Milestone_Task__c task :tasks)
            {
                system.debug(task);
                if(idx != 5)   // for tasks including weekend (i.e. task 5) the dates may not align!
                {
                    system.assertEquals(task.CCMI__start__c, task.start__c);
                    system.assertEquals(task.CCMI__end__c, task.end__c);
                    system.assertEquals(idx+1, task.CCMI__duration__c);
                }
                idx++;
                    
            }
            
        }
        
        // Test Boris Planner Out 
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
                Sent_To_BORIS__c = true,
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
    }
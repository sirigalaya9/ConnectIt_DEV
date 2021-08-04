public with sharing class MilestoneTaskTriggerHandler extends TriggerHandler 
{

    List<BORIS_Planner_OUT__c> bpoList = new List<BORIS_Planner_OUT__c>();

    public override void beforeDelete() {

        for(CCMI__Milestone_Task__c mtask: (List<CCMI__Milestone_Task__c>)Trigger.old)
            if(mtask.Sent_To_BORIS__c) {
                List<BORIS_Planner_OUT__c> bpos = BORIS_Planner_OUT_helper.taskDelete(mtask);
                if (bpos != null && bpos.size() >= 1){
                    bpoList.addAll(bpos);
                }
            }
        if(!bpoList.isEmpty())
        insert bpoList;
    }            
    
    public override void beforeInsert() {
        // update Task Dates
        for (CCMI__Milestone_Task__c task : (List<CCMI__Milestone_Task__c>)trigger.new) 
        {
            // complete editable start/end dates (if blank)
            if(task.Start__c == null || task.End__c == null)
            {
                task.Start__c = task.CCMI__Start__c;
                task.End__c = task.CCMI__End__c;
                task.Include_Weekends__c = false;
            }
        }
    }
    
    public override void afterInsert() {
        List<BORIS_Planner_OUT__c> bpoListTemp = new List<BORIS_Planner_OUT__c>();
        // insert bpos
        for(CCMI__Milestone_Task__c mtask: (List<CCMI__Milestone_Task__c>)Trigger.new)
            if(mtask.BORIS_job__c) {

                bpoListTemp = BORIS_Planner_OUT_helper.taskUpdate(mtask);  
                if (bpoListTemp != null && bpoListTemp.size() > 0) {                      
                    bpoList.addAll(bpoListTemp);
                }
            }        
        if(!bpoList.isEmpty())
        insert bpoList;
    }

    public override void afterUpdate() 
    {
        // update Task Dates
        if(MilestoneTaskTriggerHelper.processedTasks == null)
            MilestoneTaskTriggerHelper.processedTasks = new Set<Id>();

        List<CCMI__Milestone_Task__c> tasksToUpdate = new List<CCMI__Milestone_Task__c>();
        List<BORIS_Planner_OUT__c> bpoListTemp = new List<BORIS_Planner_OUT__c>();
        Map <id, CCMI__Milestone_Task__c> oldTaskMap = (Map<id, CCMI__Milestone_Task__c>)Trigger.oldMap;

        for (CCMI__Milestone_Task__c origTask : (List<CCMI__Milestone_Task__c>)trigger.new) 
            {
            System.debug('origTask='+origTask);
            System.debug('oldTaskMap='+oldTaskMap.get(origTask.Id));
            if (!MilestoneTaskTriggerHelper.processedTasks.contains(origTask.id)) {
                // task not already processed              
                    
                CCMI__Milestone_Task__c task = origTask.clone();
                task.id = origTask.id;
                Boolean updateTask = false;
                
                // complete editable start/end dates (if blank)
                if(task.Start__c == null || task.End__c == null)
                {
                    task.Start__c = task.CCMI__Start__c;
                    task.End__c = task.CCMI__End__c;
                    task.Include_Weekends__c = false;
                    updateTask = true;
                }
                
                else if((task.Start__c != oldTaskMap.get(task.id).Start__c && task.End__c != oldTaskMap.get(task.id).End__c) ||
                        task.Include_Weekends__c != oldTaskMap.get(task.id).Include_Weekends__c)
                {
                    // both start and end date updated, assume that duration (work) remains the same => re-calculate end date in lieu of non-working days...
                    task.start__c = MilestoneTaskTriggerHelper.calcStart(task.start__c, task.CCMI__Parent_End__c, task.CCMI__Completed_Date__c, task.Include_Weekends__c);
                    task.End__c = MilestoneTaskTriggerHelper.calcEnd(task.start__c, (Integer)task.CCMI__Duration__c, task.CCMI__Completed_Date__c, task.Include_Weekends__c);
                    task.CCMI__Desired_Start__c = task.start__c;
                    updateTask = true;
                }
                else if(task.Start__c != oldTaskMap.get(task.id).Start__c)   //  only start date updated, need to adjust start date and duration
                {
                    task.start__c = MilestoneTaskTriggerHelper.calcStart(task.start__c, task.CCMI__Parent_End__c, task.CCMI__Completed_Date__c, task.Include_Weekends__c);
                    task.CCMI__Duration__c = MilestoneTaskTriggerHelper.calcWork(task.start__c, task.end__c, task.Include_Weekends__c);   // End date shouldn't change
                    task.CCMI__Desired_Start__c = task.start__c;
                    updateTask = true;
                }
                else if(task.End__c != oldTaskMap.get(task.id).End__c)   //  only end date updated, need to adjust the duration
                {
                    task.CCMI__Duration__c = MilestoneTaskTriggerHelper.calcWork(task.start__c, task.end__c, task.Include_Weekends__c);
                    task.End__c = MilestoneTaskTriggerHelper.calcEnd(task.start__c, (Integer)task.CCMI__Duration__c, task.CCMI__Completed_Date__c, task.Include_Weekends__c);
                    updateTask = true;
                }
                else if(origTask.CCMI__Start__c != oldTaskMap.get(origTask.id).CCMI__Start__c || origTask.CCMI__End__c != oldTaskMap.get(origTask.id).CCMI__End__c )
                {
                    // calculated dates updated elsewhere, mirror changes in editable dates...
                    task.Start__c = task.CCMI__start__c;
                    task.End__c = task.CCMI__End__c;
                    task.Include_Weekends__c = false;
                    updateTask = true;
                }
                
                if(updateTask)
                {
                    // update was made add task to the update list
                    tasksToUpdate.add(task);
                }
                    if(origTask.BORIS_job__c != oldTaskMap.get(origTask.Id).BORIS_job__c) {
                        bpoListTemp = BORIS_Planner_OUT_helper.taskDelete(origTask);  
                        if (bpoListTemp != null && bpoListTemp.size() > 0) {                      
                            bpoList.addAll(bpoListTemp);
                        }                

                    }    
            } else {

                /*
                // process Boris Planner Out Records
                if(origTask.BORIS_job__c)
                {
                    if(origTask.CCMI__Description__c != oldTaskMap.get(origTask.Id).CCMI__Description__c  ||
                        origTask.Start__c != oldTaskMap.get(origTask.Id).Start__c ||
                        origTask.End__c != oldTaskMap.get(origTask.Id).End__c ||
                        origTask.BORIS_job__c != oldTaskMap.get(origTask.Id).BORIS_job__c) {

                        //bpoListTemp = BORIS_Planner_OUT_helper.taskUpdate(origTask);  
                        bpoListTemp = BORIS_Planner_OUT_helper.taskUpdate(origTask); 
                        if (bpoListTemp != null && bpoListTemp.size() > 0) {                      
                            bpoList.addAll(bpoListTemp);
                        }
                    }    
                }
                else  // not BORIS job, but was it originally?... if so we need to delete it from BORIS
                {
                    if(origTask.BORIS_job__c != oldTaskMap.get(origTask.Id).BORIS_job__c) {
                        bpoListTemp = BORIS_Planner_OUT_helper.taskDelete(origTask);  
                        if (bpoListTemp != null && bpoListTemp.size() > 0) {                      
                            bpoList.addAll(bpoListTemp);
                        }                

                    }    
                }
                */

                // process Boris Planner Out Records on second update. Not ideal
                if(origTask.BORIS_job__c && origTask.Sent_To_BORIS__c)
                {
                    //System.debug('updateTask='+updateTask);
                    //System.debug('task.Start__c='+task.Start__c);
                    System.debug('origTask.Start__c='+origTask.Start__c);
                    System.debug('oldTaskMap.get(origTask.Id).Start__c='+oldTaskMap.get(origTask.Id).Start__c);
                    //if(origTask.CCMI__Description__c != oldTaskMap.get(origTask.Id).CCMI__Description__c  ||
                    //    origTask.Start__c != oldTaskMap.get(origTask.Id).Start__c ||
                    //    origTask.End__c != oldTaskMap.get(origTask.Id).End__c //||
                        //origTask.Start__c != task.Start__c ||
                        //origTask.End__c != task.End__c ||
                        //origTask.BORIS_job__c != oldTaskMap.get(origTask.Id).BORIS_job__c 
                        //|| updateTask
                    //    ) {

                        //if(updateTask) {
                            //bpoListTemp = BORIS_Planner_OUT_helper.taskDelete(origTask);  // delete old task
                        //    bpoListTemp = BORIS_Planner_OUT_helper.taskUpdate(task);  // insert new task ?
                        //} else {
                        //    bpoListTemp = BORIS_Planner_OUT_helper.taskUpdate(origTask); 
                        //}
                        bpoListTemp = BORIS_Planner_OUT_helper.taskUpdate(origTask); 

                        if (bpoListTemp != null && bpoListTemp.size() > 0) {                      
                            bpoList.addAll(bpoListTemp);
                        }
                  //  }    
                }
               // else  // not BORIS job, but was it originally?... if so we need to delete it from BORIS
                //{
                    //if(origTask.BORIS_job__c != oldTaskMap.get(origTask.Id).BORIS_job__c) {
                   // if(origTask.Sent_To_BORIS__c && !origTask.BORIS_job__c ) {
                        
                   //     bpoListTemp = BORIS_Planner_OUT_helper.taskDelete(origTask);  
                   //     if (bpoListTemp != null && bpoListTemp.size() > 0) {                      
                   //         bpoList.addAll(bpoListTemp);
                   //     }                

                  //  }    
                //}
            }
        }
        
        MilestoneTaskTriggerHelper.processedTasks.addAll(Trigger.newMap.keySet());
        // Insert Boris Planner Out records   
        System.debug('R3 ==> MilestoneTaskTriggerHandler.afterUpdate: bpoList size'+bpoList.size());     
        if(!bpoList.isEmpty())
            insert bpoList;
    
        // update tasks
        System.debug('R3 ==> MilestoneTaskTriggerHandler.afterUpdate: tasksToUpdate size'+tasksToUpdate.size());  
        if(!tasksToUpdate.isEmpty())
            update tasksToUpdate;

    }
   
}
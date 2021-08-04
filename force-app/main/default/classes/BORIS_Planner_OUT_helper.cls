public class BORIS_Planner_OUT_helper 
{
    public static BORIS_Planner_OUT__c deleteAssignment(Assignment__c massignment)
    {
        // get associated task details...
        CCMI__Milestone_Task__c mtask = getTask(massignment.Project_Task__c);

        System.debug('R3 ==> BORIS_Planner_OUT_helper.deleteAssignment mtask.BORIS_job__c = '+mtask.BORIS_job__c);  
        System.debug('R3 ==> BORIS_Planner_OUT_helper.deleteAssignment mtask.Sent_To_BORIS__c = '+mtask.Sent_To_BORIS__c);  
        // not a BORIS job or Not sent to BORIS, so don't process (abort)
        if(!mtask.BORIS_job__c || !mtask.Sent_To_BORIS__c)
            return null;

        // create (default) BORIS out record...
        BORIS_Planner_OUT__c bpo = assignBPO(massignment, mtask);
        bpo.Operation__c = 'D';  // update to delete

        return bpo;
    }

    public static BORIS_Planner_OUT__c newAssignment(Assignment__c massignment)
    {
        // get associated task details...
        CCMI__Milestone_Task__c mtask = getTask(massignment.Project_Task__c);
        System.debug('R3 ==> BORIS_Planner_OUT_helper.newAssignment mtask.BORIS_job__c = '+mtask.BORIS_job__c);  
        System.debug('R3 ==> BORIS_Planner_OUT_helper.newAssignment mtask.Sent_To_BORIS__c = '+mtask.Sent_To_BORIS__c);  
        // not a BORIS job or Not sent to BORIS, so don't process (abort)
        if(!mtask.BORIS_job__c || !mtask.Sent_To_BORIS__c)
            return null;

        // create (default) BORIS out record...
        BORIS_Planner_OUT__c bpo = assignBPO(massignment, mtask);
        
        return bpo;
    }

    public static List<BORIS_Planner_OUT__c> taskUpdate(CCMI__Milestone_Task__c thetask)
    {
        // get associated task details...
        CCMI__Milestone_Task__c mtask = getTask(thetask.Id);

        System.debug('R3 ==> BORIS_Planner_OUT_helper.taskUpdate mtask.BORIS_job__c = '+mtask.BORIS_job__c);  
        System.debug('R3 ==> BORIS_Planner_OUT_helper.taskUpdate mtask.Sent_To_BORIS__c = '+mtask.Sent_To_BORIS__c);  
        // not a BORIS job or Not sent to BORIS, so don't process (abort)
        if(!mtask.BORIS_job__c || !mtask.Sent_To_BORIS__c)
            return null;

        // get associated assignment details...
        List<Assignment__c> maList = getAssignments(mtask.Id);



        // create (default) BORIS out record...
        List<BORIS_Planner_OUT__c> bpoList = assignBPOs(maList, mtask /*, thetask */);
        
        return bpoList;
    }

    public static List<BORIS_Planner_OUT__c> taskDelete(CCMI__Milestone_Task__c thetask)
    {
        // get associated task details...
        CCMI__Milestone_Task__c mtask = getTask(thetask.Id);
        System.debug('R3 ==> BORIS_Planner_OUT_helper.taskDelete mtask.BORIS_job__c = '+mtask.BORIS_job__c);  
        System.debug('R3 ==> BORIS_Planner_OUT_helper.taskDelete mtask.Sent_To_BORIS__c = '+mtask.Sent_To_BORIS__c);  
        // not a BORIS job or Not sent to BORIS, so don't process (abort)
        if(!mtask.Sent_To_BORIS__c)
            return null;

        // get associated assignment details...
        List<Assignment__c> maList = getAssignments(mtask.Id);

        // create (default) BORIS out record...
        List<BORIS_Planner_OUT__c> bpoList = assignBPOs(maList, mtask);
        
        // update opreation to delete
        for(BORIS_Planner_OUT__c bpo: bpoList)
            bpo.Operation__c = 'D';   // delete

        return bpoList;
    }

    private static CCMI__Milestone_Task__c getTask(Id taskId)
    {
        return [SELECT Id,
                       Sent_To_BORIS__c,
                       CCMI__Description__c, 
                       CCMI__Milestone_Project__c, 
                       CCMI__Milestone_Project__r.CCMI__Account__c,
                       CCMI__Milestone_Project__r.Site__c,
                       Start__c,
                       End__c,
                       CCMI__Start__c,
                       CCMI__End__c,
                       BORIS_job__c,
                       BORIS_Codes__c, //Added as part of WI-01170
                       Name,
                       CCMI__Milestone_Project__r.Site__r.Name,
                       Start_Time__c,
                       End_Time__c
                FROM CCMI__Milestone_Task__c 
                WHERE Id = :taskId];
    }

    private static List<Assignment__c> getAssignments(Id taskId)
    {
        return [SELECT Assigned_To__c
                FROM Assignment__c 
                WHERE Project_Task__c = :taskId];
    }

    public static BORIS_Planner_OUT__c assignBPO(Assignment__c massignment, CCMI__Milestone_Task__c mtask /*, CCMI__Milestone_Task__c updTask */)
    {
        Time startTime;
        Time endTime;

        // create (default) BORIS out record...
        BORIS_Planner_OUT__c bpo = new BORIS_Planner_OUT__c();
        bpo.customerId__c = mtask.CCMI__Milestone_Project__r.CCMI__Account__c;
        bpo.DefinitionPK__c = 'SF';
        bpo.DurationMins__c = (mtask.Start__c.daysBetween(mtask.End__c) + 1) * (24 * 60);
        bpo.Integration_Status__c = 'New';
        bpo.LocationId__c = mtask.CCMI__Milestone_Project__r.Site__c;
        bpo.Notes__c = mtask.CCMI__Description__c;

        bpo.WorkOrderDateTime__c =  String.valueOf(mtask.Start__c.year() ).leftPad(2, '0')+'-'+
                                    String.valueOf(mtask.Start__c.month()).leftPad(2, '0')+'-'+
                                    String.valueOf(mtask.Start__c.day()  ).leftPad(2, '0')+' 08:00:00';            
        
        /*
        if (updTask.Start__c != null && updTask.Start__c != mtask.Start__c) {
            bpo.WorkOrderDateTime__c =  String.valueOf(updTask.Start__c.year() ).leftPad(2, '0')+'-'+
                                        String.valueOf(updTask.Start__c.month()).leftPad(2, '0')+'-'+
                                        String.valueOf(updTask.Start__c.day()  ).leftPad(2, '0')+' 08:00:00';
        } else {
            bpo.WorkOrderDateTime__c =  String.valueOf(mtask.Start__c.year() ).leftPad(2, '0')+'-'+
                                        String.valueOf(mtask.Start__c.month()).leftPad(2, '0')+'-'+
                                        String.valueOf(mtask.Start__c.day()  ).leftPad(2, '0')+' 08:00:00';            
        }
        */
        bpo.WorkOrderId__c = mtask.Id;
        bpo.UserId__c = massignment.Assigned_To__c;
        bpo.Operation__c = 'UI';
        bpo.Project_Task__c = mtask.id;
        // WI-01170 - Start
        bpo.Project_Id__c = mtask.CCMI__Milestone_Project__c != null ? mtask.CCMI__Milestone_Project__c : '';
		bpo.BORIS_Codes__c = String.isNotBlank(mtask.BORIS_Codes__c) != null ? mtask.BORIS_Codes__c : ''; 
        //WI-01170 - End
        bpo.Material_Request_Id__c = mtask.Name; //KF
        bpo.Site__c = mtask.CCMI__Milestone_Project__r.Site__r.Name; //KF

        // Set Date Time fields - orig helper stuff
        //startTime = Time.newInstance(7, 30, 0, 0);
        //endTime = Time.newInstance(16, 30, 0, 0);
        //bpo.Start_Date__c = Datetime.newInstanceGmt(mtask.CCMI__Start__c, startTime);
        //bpo.End_Date__c = Datetime.newInstanceGmt(mtask.CCMI__End__c, endTime);

        // Set Date Time fields
        if (mtask.Start_Time__c != null) {
            startTime = mtask.Start_Time__c;
        }
        else {
            startTime = Time.newInstance(7, 30, 0, 0);
        }

        if (mtask.End_Time__c != null) {
            endTime = mtask.End_Time__c;
        }
        else {
            endTime = Time.newInstance(16, 30, 0, 0);
        }
        bpo.Start_Date__c = Datetime.newInstanceGmt(mtask.CCMI__Start__c, startTime);
        bpo.End_Date__c = Datetime.newInstanceGmt(mtask.CCMI__End__c, endTime);



        System.debug('R3 ==> BORIS_Planner_OUT_helper.assignBPO bpo='+ bpo);
        return bpo;
    }

    private static List<BORIS_Planner_OUT__c> assignBPOs(List<Assignment__c> maList, CCMI__Milestone_Task__c mtask)
    {
        List<BORIS_Planner_OUT__c> bpoList = new List<BORIS_Planner_OUT__c>();

        // create (default) BORIS out records...
        for(Assignment__c ma: maList)
        {
            BORIS_Planner_OUT__c bpo = assignBPO(ma, mtask);
            bpoList.add(bpo);
        }

        return bpoList;
    }


}
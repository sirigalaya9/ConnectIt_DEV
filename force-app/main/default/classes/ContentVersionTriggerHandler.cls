public without sharing class ContentVersionTriggerHandler extends TriggerHandler 
{

    public override void beforeInsert() {


        for (ContentDocumentLink link : (List<ContentDocumentLink>) Trigger.new) {
            link.Visibility = 'InternalUsers';
            link.ShareType = 'V';


        }

    }

    public override void afterInsert() 
    {
        Set<Id> cdIdLst = new Set<Id>();
        for(ContentVersion cv : (List<ContentVersion>)trigger.new)
        {
            // RG 21/11/2019
            // This seem to break with the Winter'20 update, so the code change.  Now this update seems to have stopped working?
            // Reverted the change, and all is good once again - can only assume something has been corrected in the platform.  
            //if(cv.Origin != 'H')  // ignore Chatter Files (causes DML exception!)
            cdIdLst.add(cv.ContentDocumentId);
        }
        ContentDocumentHelper.updateContentVersion(cdIdLst);
        
        // create BORIS File Update OUT records...
        createBorisFileUpdateOutRecords((List<ContentVersion>)trigger.new);
        createFileUpdateNotificationEvent((List<ContentVersion>)trigger.new);
    }

    public override void afterUpdate() 
    {
        // create BORIS File Update OUT records...
        createBorisFileUpdateOutRecords((List<ContentVersion>)trigger.new);
        createFileUpdateNotificationEvent((List<ContentVersion>)trigger.new);
    }
    
    public static void createBorisFileUpdateOutRecords(List<ContentVersion> cvList)
    {
        // get currently queued content version ids...
        Set<Id> queuedContentDocumentIds = new Set<Id>();
        List<BORIS_File_Update_OUT__c> bfus = [SELECT Content_Document_Id__c FROM BORIS_File_Update_OUT__c WHERE status__c = 'Ready'];
        for(BORIS_File_Update_OUT__c bfu :bfus)
            queuedContentDocumentIds.add(bfu.Content_Document_Id__c);
        
        Set<BORIS_File_Update_OUT__c > bfuInsertSet = new Set<BORIS_File_Update_OUT__c >();
        for(ContentVersion cv : cvList)
        {
            // if the file relates to a project, and matches the file criteria, we need to pass it to BORIS...
            if(cv.Project__c != null && !queuedContentDocumentIds.contains(cv.ContentDocumentId) && cv.FILETYPE != 'DWG' &&
             ((cv.Group__c == 'Design'                 && cv.Type__c == 'Legal Site Plan') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'PDF & DWGs') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'Electric PDF & DWGs') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'Fibre PDF & DWGs') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'Gas PDF & DWGs') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'Water PDF & DWGs') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'Street Lighting') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'CIUS Material Schedule') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'Ducts & Excavation') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'Site Plan') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'POC') ||
              (cv.Group__c == 'Design'                 && cv.Type__c == 'PRI Information') ||
              (cv.Group__c == 'Aslaid'                 && cv.Type__c == 'BORIS Imports') ||
              (cv.Group__c == 'Aslaid'                 && cv.Type__c == 'Other') ||
              (cv.Group__c == 'Aslaid'                 && cv.Type__c == 'PDF & DWGs') ||
              (cv.Group__c == 'Gas'                    && cv.Type__c == 'MPRNS Site') ||
              (cv.Group__c == 'Existing Services'      && cv.Type__c == 'Existing Services') ||
              (cv.Group__c == 'Highway TM Plans'       && cv.Type__c == 'Highway Extent Plan') ||
              (cv.Group__c == 'Highway TM Plans'       && cv.Type__c == 'Traffic Management Plans') ||
              (cv.Group__c == 'Highway TM Plans'       && cv.Type__c == 'Highway TM Take Off') ||
              (cv.Group__c == 'Highway TM Plans'       && cv.Type__c == 'Notices and Permits') ||
              (cv.Group__c == 'Photos'                 && cv.Type__c == 'Estimate Photos') ||
              (cv.Group__c == 'Photos'                 && cv.Type__c == 'Estimate Pre Start Photos') ||
              (cv.Group__c == 'Risk Assessment'        && cv.Type__c == 'Pre Commencement Risk Assessment')  ||
              (cv.Group__c == 'Risk Assessment'        && cv.Type__c == 'Residual Design Risk Register') ||
              (cv.Group__c == 'Delivery Handover Pack' && cv.Type__c == 'Delivery Handover Pack') ||
              (cv.Group__c == 'Take-Offs'              && cv.Type__c == 'Mains') ||
              (cv.Group__c == 'Take-Offs'              && cv.Type__c == 'Services') ||
              (cv.Group__c == 'Take-Offs'              && cv.Type__c == 'Street Lighting') ||
              (cv.Group__c == 'Risk Assessment'        && cv.Type__c == 'Site Specific') ||
              (cv.Group__c == 'Work Instruction'       && cv.Type__c == 'Work Instruction') ||
              (cv.Group__c == 'Completed Job Pack'     && cv.Type__c == 'Completed Job Pack') ||
              (cv.Group__c == 'Scope'                  && cv.Type__c == 'Overview')))
            {
                BORIS_File_Update_OUT__c  bfu = new BORIS_File_Update_OUT__c ();
                bfu.Status__c = 'Ready';
                bfu.Content_Version_Id__c = cv.Id;
                bfu.Content_Document_Id__c = cv.ContentDocumentId;
                bfuInsertSet.add(bfu);
            }
        }

        // instigate file transfer to BORIS...
        if(!bfuInsertSet.isEmpty())
            insert new List<BORIS_File_Update_OUT__c>(bfuInsertSet);
    }
    
    public static void createFileUpdateNotificationEvent(List<ContentVersion> cvList)
    {
        List<File_Update_Notification__e> ProjectNotificationList = new List<File_Update_Notification__e>();
        List<File_Update_Notification_Estimate__e> EstimateNotificationList = new List<File_Update_Notification_Estimate__e>();
        
        // build platform events
        for(ContentVersion cv : cvList)
        {
            if(cv.Project__c != null)
            {
                File_Update_Notification__e notif = new File_Update_Notification__e();
                notif.projectId__c = cv.Project__c;
                notif.File_Name__c = cv.Title;
                notif.Group__c = cv.Group__c;
                notif.Type__c = cv.Type__c;
                notif.File_URL__c = URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/ContentDocument/'+cv.ContentDocumentId+'/view';
                ProjectNotificationList.add(notif);
            }
            else if(cv.Estimate__c != null)
            {
                File_Update_Notification_Estimate__e notif = new File_Update_Notification_Estimate__e();
                notif.EstimateId__c = cv.Estimate__c;
                notif.File_Name__c = cv.Title;
                notif.Group__c = cv.Group__c;
                notif.Type__c = cv.Type__c;
                notif.File_URL__c = URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/ContentDocument/'+cv.ContentDocumentId+'/view';
                EstimateNotificationList.add(notif);                
            }
        }

        // send events
        if(!ProjectNotificationList.isEmpty())
            EventBus.publish(ProjectNotificationList);
        if(!EstimateNotificationList.isEmpty())
            EventBus.publish(EstimateNotificationList);
    }
}
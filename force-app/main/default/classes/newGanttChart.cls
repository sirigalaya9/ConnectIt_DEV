public with sharing class newGanttChart {
  @AuraEnabled
  public static Map<String, Object> getGanttChartSettings() {
    Gantt_Chart_Settings__c chartSetting = Gantt_Chart_Settings__c.getInstance();
    system.debug('chartSetting==' + chartSetting);
    if (chartSetting != null) {
      Map<String, Object> settingsMap = new Map<String, Object>{
        'filterResources' => chartSetting.Filter_Resources__c,
        'filterRoles' => chartSetting.Filter_Roles__c,
        'filterProjects' => chartSetting.Filter_Projects__c,
        'filterStatus' => chartSetting.Filter_Status__c,
        'filterType' => chartSetting.Filter_Type__c,
        'filterArea' => chartSetting.Filter_Area__c,
        'filterProjManager' => chartSetting.Filter_Manager__c,
        'filterAccounts' => chartSetting.Filter_Accounts__c
      };
      system.debug('settingsMap==' + settingsMap);
      return settingsMap;
    }
    return null;
  }

  @AuraEnabled
  public static void setGanttChartSettings(
    String filterResources,
    String filterRoles,
    String filterProjects,
    String filterStatus,
    String filterType,
    String filterArea,
    String filterProjManager,
    String filterAccounts
  ) {
    Gantt_Chart_Settings__c chartSetting = Gantt_Chart_Settings__c.getInstance(
      UserInfo.getUserId()
    );
    system.debug('chartSetting==' + chartSetting);
    chartSetting.Filter_Resources__c = filterResources;
    chartSetting.Filter_Roles__c = filterRoles;
    chartSetting.Filter_Projects__c = filterProjects;
    chartSetting.Filter_Status__c = filterStatus;
    chartSetting.Filter_Type__c = filterType;
    chartSetting.Filter_Area__c = filterArea;
    chartSetting.Filter_Manager__c = filterProjManager;
    chartSetting.Filter_Accounts__c = filterAccounts;
    system.debug('chartSetting after setting values==' + chartSetting);
    upsert chartSetting;
  }

  @AuraEnabled
  public static Map<String, Object> getGanttChartData(
    String recordId,
    String viewMode,
    String startTime,
    String endTime,
    Integer slotSize,
    Integer pageNumber,
    Integer recordsPerPage,
    List<String> filterResources,
    List<String> filterRoles,
    List<String> filterProjects,
    List<String> filterStatus,
    List<String> filterType,
    List<String> filterArea,
    List<String> filterProjManager,
    List<String> filterAccounts
  ) {
    system.debug(
      'R3>>> enter getGanttChartData(recordId=' +
      recordId +
      ',viewMode=' +
      viewMode +
      ',startTime=' +
      startTime +
      ',endTime=' +
      endTime +
      ',slotSize=' +
      slotSize +
      ',pageNumber=' +
      pageNumber +
      ',...)'
    );
    System.debug(
      'R3>>> filterStatus==' +
      filterStatus +
      ', filterType==' +
      filterType +
      ', filterArea==' +
      filterArea
    );

    DateTime startDateTime = DateTime.newInstance(Long.valueOf(startTime));
    DateTime endDateTime = DateTime.newInstance(Long.valueOf(endTime));
    System.debug('R3>>> startDateTime = ' + startDateTime);
    System.debug('R3>>> EndDateTime = ' + endDateTime);
    Date startDate = startDateTime.date();
    Date endDate = endDateTime.date();
    System.debug('R3>>> startDate = ' + startDate);
    System.debug('R3>>> EndDate = ' + endDate);

    List<CCMI__Milestone_Assignment2__c> allocations = new List<CCMI__Milestone_Assignment2__c>();
    List<CCMI__Milestone_Task__c> tasks = new List<CCMI__Milestone_Task__c>();
    Map<String, Object> projectById = new Map<String, Object>();
    Map<String, Object> resourceById = new Map<String, Object>();
    List<Object> unassignedTasks = new List<Object>();
    Map<String, Object> unassignedTasksByProject = new Map<String, Object>();

    Map<String, Map<String, Object>> ganttRowsById = new Map<String, Map<String, Object>>();
    Map<String, Map<String, Object>> orderedGanttRowsById = new Map<String, Map<String, Object>>();
    Map<String, Object> data = new Map<String, Object>();

    /*********** Start - WI - 00920 use of new object Assignments__c replacing usage of CCMI__Milestone_Assignments2__c *****/
    if (String.isNotEmpty(startTime) && String.isNotEmpty(endTime)) {
      //Set<String> roles = new Set<String>();

      // load all resources...
      //Map<Id,User> resources = new Map<Id,User>([SELECT id, name, Project_Resource__c, Project_Team__c FROM User WHERE Project_Resource__c = TRUE]);

      Integer days = startDate.daysBetween(endDate) + 1;
      System.debug('R3>>> slotSize = ' + slotSize);
      slotSize = Integer.valueOf(slotSize);
      Decimal slots = days / slotSize;

      String query =
        'SELECT Id, ' +
        'Name, ' +
        'Active__c, ' +
        'Display__c, ' +
        'Sent_To_BORIS__c, ' + //WI-00803
        'Pop_up_Text__c, ' +
        'Color__c, ' +
        'Start__c, ' +
        'End__c, ' +
        'Start_Time__c, ' +
        'End_Time__c, ' +
        'CCMI__Status__c, ' +
        'Project_Area__c, ' +
        'BORIS_job__c, ' +
        'CCMI__Parent__c, ' +
        'Include_Weekends__c, ' +
        'CCMI__Milestone_Project__c, ' +
        'CCMI__Milestone_Project__r.Name, ' +
        'CCMI__Milestone_Project__r.CCMI__Status__c, ' +
        'CCMI__Milestone_Project__r.CCMI__Type__c, ' +
        'CCMI__Milestone_Project__r.Project_Manager__c, ' +
        'CCMI__Milestone_Project__r.CCMI__Account__c, ' +
        '(SELECT Id, ' +
        //'OwnerId, '+
        //'Owner.Name, '+
        'Assigned_To__r.job_title__c, ' +
        'Assigned_To__c, ' +
        'Assignee_Name__c, ' +
        'Display__c ' +
        'FROM Assignments__r';
      if (!filterRoles.isEmpty()) {
        query += ' WHERE Assigned_To__r.job_title__c IN :filterRoles';
      }

      query =
        query +
        ') ' +
        'FROM CCMI__Milestone_Task__c ' +
        'WHERE Start__c <= ' +
        endDateTime.format('yyyy-MM-dd') +
        ' AND ' +
        'End__c >= ' +
        startDateTime.format('yyyy-MM-dd') +
        ' AND ' +
        'Active__c = TRUE ';
      //'Owner.Project_Resource__c = TRUE';

      //if (!filterProjects.isEmpty()) {
      //   query += ' AND CCMI__Milestone_Project__c IN :filterProjects';
      //}
      /*
            if (!filterProjectRecords.isEmpty()) 
            {
                query += ' AND CCMI__Milestone_Task__c IN :filterProjectRecords';
            }
            */
      /* if (!filterRoles.isEmpty()) 
            {
                query += ' AND Owner.Project_Team__c IN :filterRoles';
            } */
      if (!filterStatus.isEmpty()) {
        query += ' AND CCMI__Milestone_Project__r.CCMI__Status__c IN :filterStatus';
      }
      if (!filterType.isEmpty()) {
        query += ' AND CCMI__Milestone_Project__r.CCMI__Type__c IN :filterType';
      }
      if (!filterArea.isEmpty()) {
        query += ' AND Project_Area__c IN :filterArea';
      }
      if (!filterProjManager.isEmpty()) {
        query += ' AND CCMI__Milestone_Project__r.Project_Manager__c IN :filterProjManager';
      }
      if (!filterAccounts.isEmpty()) {
        query += ' AND CCMI__Milestone_Project__r.CCMI__Account__c IN :filterAccounts';
      }
      /* if (!filterResources.isEmpty()) 
            {
            query += ' AND OwnerId IN :filterResources';
            } */

      String ganttRowsType = ''; // Used for specifying whether the Gantt chart rows represent a Project or Resource

      // Filtering by record Id if it is present
      if (String.isNotBlank(recordId)) {
        System.debug('R3>>> Project/User View');
        if (
          Id.valueOf(recordId)
            .getSobjectType()
            .getDescribe()
            .getName()
            .endsWith('CCMI__Milestone_Project__c')
        ) {
          ganttRowsType = 'project';
          //data.put('projectId', recordId);
          query += ' AND (CCMI__Milestone_Project__c = :recordId)';
        } else if (
          Id.valueOf(recordId)
            .getSobjectType()
            .getDescribe()
            .getName()
            .endsWith('User')
        ) {
          ganttRowsType = 'resource';
          //data.put('projectId', recordId);
          query += ' AND (OwnerId = :recordId)';
        }
        //query += ' AND (CCMI__Milestone_Project__c = :recordId OR OwnerId = :recordId)';
      }

      query += ' ORDER BY Start__c';
      System.debug('R3>>> query = ' + query);

      tasks = Database.query(query);
      System.debug('R3>>> tasks = ' + tasks);

      List<SObject> rowsToShow = new List<SObject>();
      if (viewMode == 'resource-overview' || viewMode == 'resource-record') {
        ganttRowsType = 'resource';
        if (viewMode == 'resource-record' && String.isNotEmpty(recordId)) {
          rowsToShow = getResourceRecords(
            new List<String>{ recordId },
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null
          );
        } else {
          rowsToShow = getResourceRecords(
            filterResources,
            filterRoles,
            pageNumber,
            filterProjects,
            filterStatus,
            filterType,
            filterProjManager,
            filterAccounts,
            filterArea,
            recordsPerPage
          );
          data.put(
            'totalRows',
            getResourceRecordsCount(
              filterResources,
              filterRoles,
              filterProjects,
              filterStatus,
              filterType,
              filterProjManager,
              filterAccounts,
              filterArea
            )
          );
        }
        for (SObject sObj : rowsToShow) {
          ganttRowsById.put(
            (String) sObj.get('Id'),
            new Map<String, Object>{
              'id' => sObj.get('Id'),
              'name' => sObj.get('Name'),
              'role' => sObj.get('job_title__c'),
              'rowType' => ganttRowsType,
              'allocationsByProject' => new Map<String, Object>(),
              'tasks' => new List<Object>()
            }
          );
        }
      } else if (
        viewMode == 'project-overview' ||
        viewMode == 'project-record'
      ) {
        ganttRowsType = 'project';
        if (viewMode == 'project-record' && String.isNotEmpty(recordId)) {
          rowsToShow = getProjectRecords(
            new List<String>{ recordId },
            null,
            null,
            null,
            null,
            null,
            new List<String>(),
            null
          );
        } else {
          rowsToShow = getProjectRecords(
            filterProjects,
            pageNumber,
            recordsPerPage,
            filterStatus,
            filterType,
            filterProjManager,
            filterAccounts,
            filterArea
          );
          data.put(
            'totalRows',
            getProjectRecordsCount(
              filterProjects,
              filterStatus,
              filterType,
              filterProjManager,
              filterAccounts,
              filterArea
            )
          );
        }
        for (SObject sObj : rowsToShow) {
          ganttRowsById.put(
            (String) sObj.get('Id'),
            new Map<String, Object>{
              'id' => sObj.get('Id'),
              'name' => sObj.get('Name'),
              //'role' => sObj.get('job_title__c'),
              'rowType' => ganttRowsType,
              'allocationsByProject' => new Map<String, Object>(),
              'tasks' => new List<Object>()
            }
          );
        }
      }
      /*
      for (SObject sObj : rowsToShow) {
        ganttRowsById.put(
          (String) sObj.get('Id'),
          new Map<String, Object>{
            'id' => sObj.get('Id'),
            'name' => sObj.get('Name'),
            'role' => sObj.get('job_title__c'),
            'rowType' => ganttRowsType,
            'allocationsByProject' => new Map<String, Object>(),
            'tasks' => new List<Object>()
          }
        );
      } */

      // organize allocations (tasks) by resources or projects
      for (CCMI__Milestone_Task__c task : tasks) {
        Decimal left =
          Decimal.valueOf(startDate.daysBetween(task.Start__c)) / slotSize;
        left = left.round(System.RoundingMode.FLOOR);

        Decimal right =
          Decimal.valueOf(startDate.daysBetween(task.End__c)) / slotSize;
        right = right.round(System.RoundingMode.FLOOR);

        List<Map<String, Object>> taskAssignments = new List<Map<String, Object>>();
        for (Assignment__c assignment : task.Assignments__r) {
          taskAssignments.add(
            new Map<String, Object>{
              'id' => assignment.Id,
              //'ownerId' => assignment.OwnerId,
              'ownerId' => assignment.Assigned_To__c,
              //'userRoleId' => assignment.Assigned_To__r.UserRoleId,
              //'ownerName' => assignment.Owner.Name
              'ownerName' => assignment.Assignee_Name__c
              //'taskId' => task.Id
            }
          );
        }
        System.debug('taskAssignments==' + taskAssignments);

        // the object to be used in the lightning component
        Map<String, Object> ganttChartItem = new Map<String, Object>{
          'id' => task.Id,
          'taskName' => task.Name,
          'startDate' => task.Start__c,
          'endDate' => task.End__c,
          'startTime' => task.Start_Time__c,
          'endTime' => task.End_Time__c,
          'status' => task.CCMI__Status__c,
          'area' => task.Project_Area__c,
          'borisJob' => task.BORIS_job__c,
          'includeWeekends' => task.Include_Weekends__c,
          'projectId' => task.CCMI__Milestone_Project__c,
          'projectName' => task.CCMI__Milestone_Project__r.Name,
          'projectId2' => task.CCMI__Milestone_Project__r.Id,
          'parentTaskId' => task.CCMI__Parent__c,
          'assignments' => taskAssignments,
          'hasAssignments' => (taskAssignments.size() > 0) ? true : false,
          'display' => task.Display__c, // Formula field added by DS to allow flexible definition of display on Gantt elements.
          'popup' => task.Pop_up_Text__c, // Formula field added by DS to define the text on each job's pop-up window.
          'color' => task.Color__c,
          'left' => left,
          'right' => right,
          'sentToBORIS' => task.Sent_To_BORIS__c
        };

        if (ganttRowsType == 'resource') {
          for (Assignment__c assignment : task.Assignments__r) {
            if (
              ganttRowsById.containsKey(assignment.Assigned_To__c) &&
              ganttRowsById.get(assignment.Assigned_To__c)
                .containsKey('allocationsByProject')
            ) {
              Map<String, Object> resourceTasksByProject = (Map<String, Object>) ganttRowsById.get(
                  assignment.Assigned_To__c
                )
                .get('allocationsByProject');
              if (
                !resourceTasksByProject.containsKey(
                  task.CCMI__Milestone_Project__c
                )
              ) {
                resourceTasksByProject.put(
                  task.CCMI__Milestone_Project__c,
                  new List<Object>()
                );
              }
              ((List<Object>) (resourceTasksByProject.get(
                  task.CCMI__Milestone_Project__c
                )))
                .add(ganttChartItem);
            }
          }
        } else if (ganttRowsType == 'project') {
          if (
            ganttRowsById.containsKey(task.CCMI__Milestone_Project__c) &&
            ganttRowsById.get(task.CCMI__Milestone_Project__c)
              .containsKey('allocationsByProject')
          ) {
            Map<String, Object> tasksByProject = (Map<String, Object>) ganttRowsById.get(
                task.CCMI__Milestone_Project__c
              )
              .get('allocationsByProject');
            if (!tasksByProject.containsKey(task.CCMI__Milestone_Project__c)) {
              tasksByProject.put(
                task.CCMI__Milestone_Project__c,
                new List<Object>()
              );
            }
            ((List<Object>) (tasksByProject.get(
                task.CCMI__Milestone_Project__c
              )))
              .add(ganttChartItem);
          }
        }

        System.debug(
          'R3>>> Task: name=' +
          task.name +
          ', start=' +
          task.Start__c +
          ', end=' +
          task.End__c
        );

        // preparing the list of unassigned tasks
        if (
          viewMode == 'resource-overview' &&
          (task.Assignments__r == null || task.Assignments__r.isEmpty())
        ) {
          unassignedTasks.add(ganttChartItem);

          if (
            !unassignedTasksByProject.containsKey(
              task.CCMI__Milestone_Project__c
            )
          ) {
            unassignedTasksByProject.put(
              task.CCMI__Milestone_Project__c,
              new List<Object>()
            );
          }
          ((List<Object>) (unassignedTasksByProject.get(
              task.CCMI__Milestone_Project__c
            )))
            .add(ganttChartItem);
        }
        System.debug('unassignedTasksByProject=' + unassignedTasksByProject);
      }
      //
      System.debug('viewModeR3==> ' + viewMode);
      if (viewMode == 'resource-overview') {
        orderedGanttRowsById.put(
          'unassigned',
          new Map<String, Object>{
            'id' => 'unassigned',
            'name' => 'Unassigned Tasks',
            'isResource' => false,
            'allocationsByProject' => unassignedTasksByProject,
            'tasks' => unassignedTasks
          }
        );
      }
      orderedGanttRowsById.putAll(ganttRowsById);
    }
    /******* End - WI - 00920 use of new object Assignments__c replacing usage of CCMI__Milestone_Assignments2__c *****/

    /******* WI - 00920 -  Stop using CCMI__Milestone_Assignments2__c object to enable chatter users to own task record  ********
        if (String.isNotEmpty(startTime) &&  String.isNotEmpty(endTime)) 
        {
            //Set<String> roles = new Set<String>();

            // load all resources... 
            //Map<Id,User> resources = new Map<Id,User>([SELECT id, name, Project_Resource__c, Project_Team__c FROM User WHERE Project_Resource__c = TRUE]);

            Integer days = startDate.daysBetween(endDate) + 1;
            System.debug('R3>>> slotSize = '+slotSize);
            slotSize = Integer.valueOf(slotSize);
            Decimal slots = days / slotSize;

            
            String query = 'SELECT Id, '+
                                'Name, '+
                                'Active__c, '+
                                'Display__c, '+
                                'Pop_up_Text__c, '+
                                'Color__c, '+
                                'Start__c, '+
                                'End__c, '+
                                'Start_Time__c, '+
                                'End_Time__c, '+
                                'CCMI__Status__c, '+
                                'Project_Area__c, '+
                                'BORIS_job__c, '+
                                'CCMI__Parent__c, '+
                                'Include_Weekends__c, '+
                                'CCMI__Milestone_Project__c, '+
                                'CCMI__Milestone_Project__r.Name, '+
                                'CCMI__Milestone_Project__r.CCMI__Status__c, '+
                                'CCMI__Milestone_Project__r.CCMI__Type__c, '+
                                'CCMI__Milestone_Project__r.Project_Manager__c, '+
                                'CCMI__Milestone_Project__r.CCMI__Account__c, '+
                                '(SELECT Id, '+
                                        'OwnerId, '+
                                        'Owner.Name, '+
                                        'Status__c, Team__c, '+
                                        'Display__c, '+
                                        'Pop_up_Text__c, '+
                                        'Effort__c, '+
                                        'Edit_URL__c '+
                                'FROM CCMI__Milestone_Assignments2__r) '+
                            'FROM CCMI__Milestone_Task__c '+
                            'WHERE Start__c <= '+endDateTime.format('yyyy-MM-dd')+' AND '+
                                'End__c >= '+startDateTime.format('yyyy-MM-dd')+' AND '+
                                'Active__c = TRUE ';
                                    //'Owner.Project_Resource__c = TRUE';
            
            if (!filterProjects.isEmpty()) 
            {
                query += ' AND CCMI__Milestone_Project__c IN :filterProjects';
            } ******* WI - 00920 ** */

    /*
            if (!filterProjectRecords.isEmpty()) 
            {
                query += ' AND CCMI__Milestone_Task__c IN :filterProjectRecords';
            }
            */
    /* if (!filterRoles.isEmpty()) 
            {
                query += ' AND Owner.Project_Team__c IN :filterRoles';
            } */

    /****  WI - 00920 ***
            if (String.isNotBlank(filterStatus)) {
                query += ' AND CCMI__Milestone_Project__r.CCMI__Status__c = :filterStatus';
            }
            if (String.isNotBlank(filterType)) {
                query += ' AND CCMI__Milestone_Project__r.CCMI__Type__c = :filterType';
            }
            if (String.isNotBlank(filterArea)) {
                query += ' AND Project_Area__c = :filterArea';
            }
            
            if (String.isNotBlank(filterProjManager)) {
                query += ' AND CCMI__Milestone_Project__r.Project_Manager__c = :filterProjManager';
            }
            if (String.isNotBlank(filterAccount)) {
                query += ' AND CCMI__Milestone_Project__r.CCMI__Account__c = :filterAccount';
            } **WI - 00920  */

    /* if (!filterResources.isEmpty()) 
            {
            query += ' AND OwnerId IN :filterResources';
            } */

    /****  WI - 00920 ****
            String ganttRowsType = ''; // Used for specifying whether the Gantt chart rows represent a Project or Resource

            // Filtering by record Id if it is present
            if (String.isNotBlank(recordId)) 
            {
                System.debug('R3>>> Project/User View');
                if (Id.valueOf(recordId).getSobjectType().getDescribe().getName().endsWith('CCMI__Milestone_Project__c')) {
                    ganttRowsType = 'project';
                    //data.put('projectId', recordId);
                    query += ' AND (CCMI__Milestone_Project__c = :recordId)';
                }
                else if (Id.valueOf(recordId).getSobjectType().getDescribe().getName().endsWith('User')) {
                    ganttRowsType = 'resource';
                    //data.put('projectId', recordId);
                    query += ' AND (OwnerId = :recordId)';
                }
                //query += ' AND (CCMI__Milestone_Project__c = :recordId OR OwnerId = :recordId)';
            }

            query += ' ORDER BY Start__c';
            System.debug('R3>>> query = '+query);
            
            tasks = Database.query(query);
            System.debug('R3>>> tasks = '+tasks);

            List<SObject> rowsToShow = new List<SObject>();
            if(viewMode == 'resource-overview' || viewMode == 'resource-record') {
                ganttRowsType = 'resource';
                if(viewMode == 'resource-record' && String.isNotEmpty(recordId)) {
                    rowsToShow = getResourceRecords(new List<String>{recordId}, null, null);
                }
                else {
                    rowsToShow = getResourceRecords(filterResources, pageNumber, recordsPerPage);
                    data.put('totalRows', getResourceRecordsCount(filterResources));
                }
            }
            else if(viewMode == 'project-overview' || viewMode == 'project-record') {
                ganttRowsType = 'project';
                if(viewMode == 'project-record' && String.isNotEmpty(recordId)) {
                    rowsToShow = getProjectRecords(new List<String>{recordId}, null, null, null, null, null, null);
                }
                else {
                    rowsToShow = getProjectRecords(filterProjects, pageNumber, recordsPerPage, filterStatus, filterType, filterProjManager, filterAccount);
                    data.put('totalRows', getProjectRecordsCount(filterProjects, filterStatus, filterType, filterProjManager, filterAccount));
                }
            }
            
            for(SObject sObj : rowsToShow) {
                ganttRowsById.put( (String)sObj.get('Id'), new Map<String, Object> {'id' => sObj.get('Id'), 
                                                                                    'name' => sObj.get('Name'), 
                                                                                    'rowType' => ganttRowsType,
                                                                                    'allocationsByProject' => new Map<String, Object>(),
                                                                                    'tasks' => new List<Object>() });
            } ***** ****  WI - 00920 ***/

    /* 
            // Overview View
            if (String.isEmpty(recordId)) 
            {
                System.debug('R3>>> Overview view');
                query += ' ORDER BY Start__c';
                System.debug('R3>>> query = '+query);
                
                tasks = Database.query(query);
                System.debug('R3>>> tasks = '+tasks);

                //if(filterResources.isEmpty()) {

                    // display all active resources
                    for (Object res: newGanttChart.getResources()) 
                    {
                        System.debug('R3>>> res='+res);
                        Map<String, Object> resource = (Map<String, Object>)res;
                        if(filterResources.isEmpty() || filterResources.contains((String)resource.get('id'))) {
                            resourceById.put((String)resource.get('id'), new Map<String, Object>{'id' => resource.get('id'), 
                                                                                                 'name' => resource.get('name'), 
                                                                                                 'isResource' => true,
                                                                                                 'allocationsByProject' => new Map<String, Object>(),
                                                                                                 'tasks' => new List<Object>() });
                        }
                    }
            } 
            else 
            {
                System.debug('R3>>> Project/User View');
                if (Id.valueOf(recordId).getSobjectType().getDescribe().getName().endsWith('CCMI__Milestone_Project__c')) 
                {
                    data.put('projectId', recordId);
                }

                query += ' AND (CCMI__Milestone_Project__c = :recordId OR OwnerId = :recordId)';
                query += ' ORDER BY Start__c';

                System.debug('R3>>> query = '+query);
                tasks = Database.query(query);

                // empty state on resource page
                if (tasks.isEmpty() && Id.valueOf(recordId).getSobjectType().getDescribe().getName().endsWith('User')) 
                {
                    System.debug('R3>>> no allocations get user');
                    User user = [SELECT Id, Name, Project_Resource__c, Project_Team__c
                                 FROM User
                                 WHERE Id = :recordId];

                    resourceById.put(user.Id, new Map<String, Object> 
                    { 
                        'id' => user.Id, 
                        'name' => user.Name, 
                        'isResource' => true,
                        'allocationsByProject' => new Map<String, Object>(),
                        'tasks' => new List<Object>() 
                    });
                }
            }
            */

    /****  WI - 00920 
            // organize allocations (tasks) by resources or projects
            for (CCMI__Milestone_Task__c task : tasks) 
            {
                Decimal left = Decimal.valueOf(startDate.daysBetween(task.Start__c)) / slotSize;
                left = left.round(System.RoundingMode.FLOOR);
                
                Decimal right = Decimal.valueOf(startDate.daysBetween(task.End__c)) / slotSize;
                right = right.round(System.RoundingMode.FLOOR);

                List<Map<String, Object>> taskAssignments = new List<Map<String, Object>>();
                for (CCMI__Milestone_Assignment2__c assignment : task.CCMI__Milestone_Assignments2__r)
                {
                    taskAssignments.add(new Map<String, Object>{
                        'id' => assignment.Id,
                        'ownerId' => assignment.OwnerId,
                        'ownerName' => assignment.Owner.Name
                        //'taskId' => task.Id
                    });
                }
                System.debug('taskAssignments=='+taskAssignments);

                // the object to be used in the lightning component
                Map<String, Object> ganttChartItem = new Map<String, Object> 
                {
                    'id' => task.Id,
                    'taskName' => task.Name,
                    'startDate' => task.Start__c,
                    'endDate' => task.End__c,
                    'startTime' => task.Start_Time__c,
                    'endTime' => task.End_Time__c,
                    'status' => task.CCMI__Status__c,
                    'area' => task.Project_Area__c,
                    'borisJob' => task.BORIS_job__c,
                    'includeWeekends' => task.Include_Weekends__c,
                    'projectId' => task.CCMI__Milestone_Project__c,
                    'projectName' => task.CCMI__Milestone_Project__r.Name,
                    'projectId2' => task.CCMI__Milestone_Project__r.Id,
                    'parentTaskId' => task.CCMI__Parent__c,
                    'assignments' => taskAssignments,
                    'hasAssignments' => (taskAssignments.size() > 0)? true : false,
                    'display' => task.Display__c, // Formula field added by DS to allow flexible definition of display on Gantt elements.
                    'popup' => task.Pop_up_Text__c, // Formula field added by DS to define the text on each job's pop-up window.
                    'color' => task.Color__c,
                    'left' => left,
                    'right' => right
                };


                if(ganttRowsType == 'resource') {
                    for (CCMI__Milestone_Assignment2__c assignment : task.CCMI__Milestone_Assignments2__r) {
                        if (ganttRowsById.containsKey(assignment.OwnerId) && ganttRowsById.get(assignment.OwnerId).containsKey('allocationsByProject')) 
                        {
                            Map<String, Object> resourceTasksByProject = (Map<String, Object>)ganttRowsById.get(assignment.OwnerId).get('allocationsByProject');
                            if (!resourceTasksByProject.containsKey(task.CCMI__Milestone_Project__c)) {
                                resourceTasksByProject.put(task.CCMI__Milestone_Project__c, new List<Object>());
                            }
                            ((List<Object>)(resourceTasksByProject.get(task.CCMI__Milestone_Project__c))).add(ganttChartItem);
                            
                        }
                    }
                }
                else if(ganttRowsType == 'project') {
                    if (ganttRowsById.containsKey(task.CCMI__Milestone_Project__c) && 
                        ganttRowsById.get(task.CCMI__Milestone_Project__c).containsKey('allocationsByProject')) 
                    {
                        Map<String, Object> tasksByProject = (Map<String, Object>)ganttRowsById.get(task.CCMI__Milestone_Project__c).get('allocationsByProject');
                        if (!tasksByProject.containsKey(task.CCMI__Milestone_Project__c)) {
                            tasksByProject.put(task.CCMI__Milestone_Project__c, new List<Object>());
                        }
                        ((List<Object>)(tasksByProject.get(task.CCMI__Milestone_Project__c))).add(ganttChartItem);
                    }
                }

                System.debug('R3>>> Task: name='+task.name+', start='+task.Start__c+', end='+task.End__c);

                // preparing the list of unassigned tasks
                if (viewMode == 'resource-overview' && (task.CCMI__Milestone_Assignments2__r == null || task.CCMI__Milestone_Assignments2__r.isEmpty()) ) {
                    unassignedTasks.add(ganttChartItem);

                    if (!unassignedTasksByProject.containsKey(task.CCMI__Milestone_Project__c)) {
                        unassignedTasksByProject.put(task.CCMI__Milestone_Project__c, new List<Object>());
                    }
                    ((List<Object>)(unassignedTasksByProject.get(task.CCMI__Milestone_Project__c))).add(ganttChartItem);
                }
                System.debug('unassignedTasksByProject='+unassignedTasksByProject);
            }

            if (viewMode == 'resource-overview') {
                ganttRowsById.put('unassigned', new Map<String, Object>
                {
                    'id' => 'unassigned', 
                    'name' => 'Unassigned Tasks', 
                    'isResource' => false,
                    'allocationsByProject' => unassignedTasksByProject,
                    'tasks' => unassignedTasks
                });
            }

        } *******  WI - 00920 **/

    // data.put('projects', projectById.values());
    // data.put('resources', resourceById.values());
    data.put('ganttRows', orderedGanttRowsById.values());

    System.debug(
      'R3>>> orderedGanttRowsById.values()=' + orderedGanttRowsById.values()
    );
    System.debug('R3>>> data=' + data);

    return data;
  }

  @AuraEnabled
  public static List<Object> getResources() {
    List<Object> users = new List<Object>();
    for (User usr : [
      SELECT Id, Name, Project_Team__c, job_title__c
      FROM User
      WHERE Project_Resource__c = TRUE AND IsActive = TRUE
      ORDER BY Name
    ]) {
      users.add(new Map<String, Object>{ 'id' => usr.Id, 'name' => usr.Name });
      //users.add(new Map<String, Object>{ 'id' => usr.Id, 'user' => usr });
      //.add(JSON.deserializeUntyped( '"id" : ' + usr.Id+ ',"name" : ' + usr.Name + ', "roleId" : ' + usr.job_title__c )); // '{ "height" : 5.5 , '
    }
    return users;
  }

  @AuraEnabled
  public static List<Object> getProjManager() {
    List<Object> users = new List<Object>();
    for (User usr : [
      SELECT Id, Name, Project_Team__c, job_title__c
      FROM User
      WHERE Title LIKE '%Project Manager%' AND IsActive = TRUE
      ORDER BY Name
    ]) {
      users.add(new Map<String, Object>{ 'id' => usr.Id, 'name' => usr.Name });
      //users.add(new Map<String, Object>{ 'id' => usr.Id, 'user' => usr });
      //.add(JSON.deserializeUntyped( '"id" : ' + usr.Id+ ',"name" : ' + usr.Name + ', "roleId" : ' + usr.job_title__c )); // '{ "height" : 5.5 , '
    }
    return users;
  }

  @AuraEnabled
  public static List<Object> getType() {
    Set<Object> type = new Set<Object>();
    List<Object> typeList = new List<Object>();
    for (CCMI__Milestone_Project__c proj : [
      SELECT Id, Name, CCMI__Type__c
      FROM CCMI__Milestone_Project__c
      ORDER BY CCMI__Type__c
    ]) {
      type.add(
        new Map<String, Object>{
          'id' => proj.CCMI__Type__c,
          'name' => proj.CCMI__Type__c
        }
      );
    }
    typeList.addAll(type);
    return typeList;
  }

  @AuraEnabled
  public static List<Object> getArea() {
    system.debug('R3>>> enter getArea');
    Set<Object> area = new Set<Object>();
    List<Object> areaList = new List<Object>();
    for (CCMI__Milestone_Task__c task : [
      SELECT Id, Name, Project_Area__c
      FROM CCMI__Milestone_Task__c
      ORDER BY Project_Area__c
    ]) {
      area.add(
        new Map<String, Object>{
          'id' => task.Project_Area__c,
          'name' => task.Project_Area__c
        }
      );
    }
    System.debug('R3>>> roles to be sent >>> ' + area);
    areaList.addAll(area);
    return areaList;
  }

  @AuraEnabled
  public static List<Object> getStatus() {
    system.debug('R3>>> enter getStatus');
    Set<Object> status = new Set<Object>();
    List<Object> statusList = new List<Object>();
    for (CCMI__Milestone_Project__c proj : [
      SELECT Id, Name, CCMI__Status__c
      FROM CCMI__Milestone_Project__c
      ORDER BY CCMI__Status__c
    ]) {
      status.add(
        new Map<String, Object>{
          'id' => proj.CCMI__Status__c,
          'name' => proj.CCMI__Status__c
        }
      );
    }
    System.debug('R3>>> roles to be sent >>> ' + status);
    statusList.addAll(status);
    return statusList;
  }

  @AuraEnabled
  public static List<Object> getRoles() {
    system.debug('R3>>> enter getRoles');
    Set<Object> usrRoles = new Set<Object>();
    List<Object> usrRoleList = new List<Object>();
    for (User usr : [
      SELECT Id, Name, job_title__c
      FROM User
      ORDER BY job_title__c
    ]) {
      usrRoles.add(
        new Map<String, Object>{
          'id' => usr.job_title__c,
          'name' => usr.job_title__c
        }
      );
    }
    System.debug('R3>>> roles to be sent >>> ' + usrRoles);
    usrRoleList.addAll(usrRoles);
    return usrRoleList;
  }

  //WI-00500 - Start
  @AuraEnabled
  public static List<String> getTeamResources(String teamId) {
    System.debug('R3>>> enter getTeamResources');
    List<String> teamUsers = new List<String>();
    for (Team__c teamUser : [
      SELECT Id, Name, Primary_User__r.Name, Team_Member_1__r.Name
      FROM Team__c
      WHERE Id = :teamId
    ]) {
      teamUsers.add(teamUser.Primary_User__c);
      teamUsers.add(teamUser.Team_Member_1__c);
    }
    System.debug('R3>>> users in the team >>> ' + teamUsers);

    return teamUsers;
  }

  //WI-00500 - End

  @AuraEnabled
  public static List<Object> getProjects() {
    system.debug('R3>>> enter getProjects');

    List<Object> projects = new List<Object>();
    for (CCMI__Milestone_Project__c proj : [
      SELECT Id, Name, Job_no__c
      FROM CCMI__Milestone_Project__c
      ORDER BY Name
    ]) {
      projects.add(
        new Map<String, Object>{
          'id' => proj.Id,
          'name' => proj.Name,
          'jobNo' => proj.Job_no__c
        }
      );
    }
    return projects;
  }

  @AuraEnabled
  public static List<Object> getAccounts() {
    system.debug('R3>>> enter getAccounts');
    Set<Object> accounts = new Set<Object>();
    List<Object> accountList = new List<Object>();
    for (Account acc : [SELECT Id, Name FROM Account ORDER BY Name]) {
      accounts.add(
        new Map<String, Object>{ 'id' => acc.Id, 'name' => acc.Name }
      );
    }
    System.debug('R3>>> accounts to be sent >>> ' + accounts);
    accountList.addAll(accounts);
    return accountList;
  }

  @TestVisible
  private static List<CCMI__Milestone_Project__c> getProjectRecords(
    List<String> IdList,
    Integer pageNumber,
    Integer recordsPerPage,
    List<String> statusFilter,
    List<String> typeFilter,
    List<String> projManagerFilter,
    List<String> accountFilter,
    List<String> areaFilter
  ) {
    system.debug('R3>>> enter getProjectRecords');
    // String queryStr = getProjectQueryString(IdList, statusFilter, typeFilter, projManagerFilter, accountFilter);

    String queryStr =
      'SELECT Id, Name, Job_no__c, CCMI__Status__c, CCMI__Type__c, Project_Manager__c, CCMI__Account__c' +
      ' FROM CCMI__Milestone_Project__c' +
      ' WHERE Name != null';
    if (!IdList.isEmpty())
      queryStr += ' AND Id IN :IdList';
    if (!statusFilter.isEmpty())
      queryStr += ' AND CCMI__Status__c IN :statusFilter';
    if (!typeFilter.isEmpty())
      queryStr += ' AND CCMI__Type__c IN :typeFilter';
    if (!areaFilter.isEmpty())
      queryStr += ' AND Id in (SELECT CCMI__Milestone_Project__c from CCMI__Milestone_Task__c WHERE Project_Area__c IN :areaFilter)';
    if (!projManagerFilter.isEmpty())
      queryStr += ' AND Project_Manager__c = :projManagerFilter';
    if (!accountFilter.isEmpty())
      queryStr += ' AND ( CCMI__Account__c IN :accountFilter';
    if (!accountFilter.isEmpty())
      queryStr += ' OR Site__c IN :accountFilter )';
    queryStr += ' ORDER BY Name';

    if (recordsPerPage != null && recordsPerPage > 0) {
      queryStr += ' LIMIT ' + recordsPerPage;
      if (pageNumber != null && pageNumber > 0) {
        Integer offsetValue = recordsPerPage * pageNumber;
        queryStr += ' OFFSET ' + offsetValue;
      }
    }
    return Database.query(queryStr);
  }

  private static Integer getProjectRecordsCount(
    List<String> IdList,
    List<String> statusFilter,
    List<String> typeFilter,
    List<String> projManagerFilter,
    List<String> accountFilter,
    List<String> areaFilter
  ) {
    system.debug('R3>>> enter getProjectRecordsCount');
    String queryStr =
      'SELECT count()' +
      ' FROM CCMI__Milestone_Project__c' +
      ' WHERE Name != null';
    if (!IdList.isEmpty())
      queryStr += ' AND Id IN :IdList';
    if (!statusFilter.isEmpty())
      queryStr += ' AND CCMI__Status__c IN :statusFilter';
    if (!typeFilter.isEmpty())
      queryStr += ' AND CCMI__Type__c IN :typeFilter';
    if (!areaFilter.isEmpty())
      queryStr += ' AND Id in (SELECT CCMI__Milestone_Project__c from CCMI__Milestone_Task__c WHERE Project_Area__c IN :areaFilter)';
    if (!projManagerFilter.isEmpty())
      queryStr += ' AND Project_Manager__c IN :projManagerFilter';
    if (!accountFilter.isEmpty())
      queryStr += ' AND ( CCMI__Account__c IN :accountFilter';
    if (!accountFilter.isEmpty())
      queryStr += ' OR Site__c IN :accountFilter )';

    return Database.countQuery(queryStr);
  }

  /* private static String getProjectQueryString(List<String> IdList, String statusFilter, String typeFilter, String projManagerFilter, String accountFilter) 
    {
        String queryStr = 'SELECT Id, Name, Job_no__c, CCMI__Status__c, CCMI__Type__c, Project_Manager__c, CCMI__Account__c' +
                          ' FROM CCMI__Milestone_Project__c' +
                          ' WHERE Name != null';
        if(!IdList.isEmpty())
            queryStr += ' AND Id IN :IdList';
        if(String.isNotBlank(statusFilter))
            queryStr += ' AND CCMI__Status__c = :statusFilter';
        if(String.isNotBlank(typeFilter))
            queryStr += ' AND CCMI__Type__c = :typeFilter';
        if(String.isNotBlank(projManagerFilter))
            queryStr += ' AND Project_Manager__c = :projManagerFilter';
        if(String.isNotBlank(accountFilter))
            queryStr += ' AND CCMI__Account__c = :accountFilter';
        queryStr += ' ORDER BY Name';
        
        return queryStr;
    } */

  private static List<User> getResourceRecords(
    List<String> IdList,
    List<String> roleIdList,
    Integer pageNumber,
    List<String> projectsFilter,
    List<String> statusFilter,
    List<String> typeFilter,
    List<String> projManagerFilter,
    List<String> accountFilter,
    List<String> areaFilter,
    Integer recordsPerPage
  ) {
    system.debug('R3>>> enter getResourceRecords');

    String userQueryStr = 'SELECT Id, Name, Project_Team__c, job_title__c FROM User WHERE Project_Resource__c = true AND IsActive = true ORDER BY Name';
    if (recordsPerPage != null && recordsPerPage > 0) {
      userQueryStr += ' LIMIT ' + recordsPerPage;
      if (pageNumber != null && pageNumber > 0) {
        Integer offsetValue = recordsPerPage * pageNumber;
        userQueryStr += ' OFFSET ' + offsetValue;
      }
    }

    String assignmentQueryStr = 'SELECT Assigned_To__c FROM Assignment__c WHERE Assigned_To__r.Project_Resource__c = true AND Assigned_To__r.IsActive = true';
    if (!IdList.isEmpty())
      assignmentQueryStr += ' AND Assigned_To__r.Id IN :IdList';
    if (!roleIdList.isEmpty())
      assignmentQueryStr += ' AND Assigned_To__r.job_title__c IN :roleIdList';
    if (!areaFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.Project_Area__c IN :areaFilter';
    if (!projectsFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.CCMI__Milestone_Project__r.Id IN :projectsFilter';
    if (!statusFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.CCMI__Milestone_Project__r.CCMI__Status__c IN :statusFilter';
    if (!typeFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.CCMI__Milestone_Project__r.CCMI__Type__c IN :typeFilter';
    if (!projManagerFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.CCMI__Milestone_Project__r.Project_Manager__c = :projManagerFilter';
    if (!accountFilter.isEmpty())
      assignmentQueryStr += ' AND ( Project_Task__r.CCMI__Milestone_Project__r.CCMI__Account__c IN :accountFilter';
    if (!accountFilter.isEmpty())
      assignmentQueryStr += ' OR Project_Task__r.CCMI__Milestone_Project__r.Site__c IN :accountFilter )';
    assignmentQueryStr += ' ORDER BY Assigned_To__r.Name';

    system.debug('JONNY CHECKS');

    if (
      !IdList.isEmpty() ||
      !roleIdList.isEmpty() ||
      !areaFilter.isEmpty() ||
      !projectsFilter.isEmpty() ||
      !statusFilter.isEmpty() ||
      !typeFilter.isEmpty() ||
      !projManagerFilter.isEmpty() ||
      !accountFilter.isEmpty() ||
      !accountFilter.isEmpty()
    ) {
      List<sObject> assignedToList = Database.query(assignmentQueryStr);

      Set<Id> userIdSet = new Set<Id>();

      for (sObject assignedTo : assignedToList) {
        userIdSet.add((Id) assignedTo.get('Assigned_To__c'));
      }

      String filteredUserQueryStr = 'SELECT Id, Name, Project_Team__c, job_title__c FROM User WHERE Id IN :userIdSet ORDER BY Name';
      if (recordsPerPage != null && recordsPerPage > 0) {
        filteredUserQueryStr += ' LIMIT ' + recordsPerPage;
        if (pageNumber != null && pageNumber > 0) {
          Integer offsetValue = recordsPerPage * pageNumber;
          filteredUserQueryStr += ' OFFSET ' + offsetValue;
        }
      }
      return Database.query(filteredUserQueryStr);
    } else {
      return Database.query(userQueryStr);
    }
  }

  private static Integer getResourceRecordsCount(
    List<String> IdList,
    List<String> roleIdList,
    List<String> projectsFilter,
    List<String> statusFilter,
    List<String> typeFilter,
    List<String> projManagerFilter,
    List<String> accountFilter,
    List<String> areaFilter
  ) {
    String userQueryStr = 'SELECT count() FROM User WHERE Project_Resource__c = true AND IsActive = true';

    String assignmentQueryStr = 'SELECT Assigned_To__c FROM Assignment__c WHERE Assigned_To__r.Project_Resource__c = true AND Assigned_To__r.IsActive = true';
    if (!IdList.isEmpty())
      assignmentQueryStr += ' AND Assigned_To__r.Id IN :IdList';
    if (!roleIdList.isEmpty())
      assignmentQueryStr += ' AND Assigned_To__r.job_title__c IN :roleIdList';
    if (!areaFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.Project_Area__c IN :areaFilter';
    if (!projectsFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.CCMI__Milestone_Project__r.Id IN :projectsFilter';
    if (!statusFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.CCMI__Milestone_Project__r.CCMI__Status__c IN :statusFilter';
    if (!typeFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.CCMI__Milestone_Project__r.CCMI__Type__c IN :typeFilter';
    if (!projManagerFilter.isEmpty())
      assignmentQueryStr += ' AND Project_Task__r.CCMI__Milestone_Project__r.Project_Manager__c = :projManagerFilter';
    if (!accountFilter.isEmpty())
      assignmentQueryStr += ' AND ( Project_Task__r.CCMI__Milestone_Project__r.CCMI__Account__c IN :accountFilter';
    if (!accountFilter.isEmpty())
      assignmentQueryStr += ' OR Project_Task__r.CCMI__Milestone_Project__r.Site__c IN :accountFilter )';
    assignmentQueryStr += ' ORDER BY Assigned_To__r.Name';

    if (
      !IdList.isEmpty() ||
      !roleIdList.isEmpty() ||
      !areaFilter.isEmpty() ||
      !projectsFilter.isEmpty() ||
      !statusFilter.isEmpty() ||
      !typeFilter.isEmpty() ||
      !projManagerFilter.isEmpty() ||
      !accountFilter.isEmpty() ||
      !accountFilter.isEmpty()
    ) {
      List<sObject> assignedToList = Database.query(assignmentQueryStr);
      Set<Id> userIdSet = new Set<Id>();

      for (sObject assignedTo : assignedToList) {
        userIdSet.add((Id) assignedTo.get('Assigned_To__c'));
      }

      String filteredUserQueryStr = 'SELECT count() FROM User WHERE Id IN :userIdSet';

      return Database.countQuery(filteredUserQueryStr);
    } else {
      return Database.countQuery(userQueryStr);
    }
  }

  /* private static String getResourceQueryString(List<String> IdList) 
    {
        String queryStr = 'SELECT Id, Name, Project_Team__c' +
                          ' FROM User' +
                          ' WHERE Project_Resource__c = true';
        if(!IdList.isEmpty())
            queryStr += ' AND Id IN :IdList';
        queryStr += ' ORDER BY Name';
        
        return queryStr;
    } */

  @AuraEnabled
  public static void saveTask(
    Id taskId,
    Id projectId,
    String taskName,
    String status,
    String area,
    Boolean borisJob,
    Boolean includeWeekends,
    String startDate,
    String endDate,
    String startTime,
    String endTime,
    String assignmentsToSave,
    String assignmentsToRemove,
    string parentTaskId
  ) {
    system.debug('taskId==' + taskId);
    system.debug('startDate==' + startDate);
    system.debug('endDate==' + endDate);
    system.debug('startTime==' + startTime);
    system.debug('endTime==' + endTime);
    system.debug('parentTask== ' + parentTaskId);
    Date startDt;
    Date endDt;
    Time startTimeObj;
    Time endTimeObj;
    if (startDate != null)
      startDt = DateTime.newInstance(Long.valueOf(startDate)).date();
    if (endDate != null)
      endDt = DateTime.newInstance(Long.valueOf(endDate)).date();
    if (startTime != null && startTime.contains(':')) {
      String[] strTimeSplit = startTime.split(':');
      startTimeObj = Time.newInstance(
        Integer.valueOf(strTimeSplit[0]), //hour
        Integer.valueOf(strTimeSplit[1]), //min
        0, //sec
        0
      ); //ms

      // startTimeObj = (Time)JSON.deserialize(startTime, Time.class);
    }
    if (endTime != null && endTime.contains(':')) {
      String[] strTimeSplit = endTime.split(':');
      endTimeObj = Time.newInstance(
        Integer.valueOf(strTimeSplit[0]), //hour
        Integer.valueOf(strTimeSplit[1]), //min
        0, //sec
        0
      ); //ms
    }

    system.debug('startTimeObj==' + startTimeObj);
    system.debug('endTimeObj==' + endTimeObj);
    system.debug(
      'R3>>> enter saveTask(taskId=' +
      taskId +
      ', projectId=' +
      projectId +
      ', status=' +
      status +
      ',borisJob=' +
      borisJob +
      ', includeWeekends=' +
      includeWeekends +
      ',startDate=' +
      startDt +
      ', endDate=' +
      endDt +
      ', startTime=' +
      startTime +
      ',endTime=' +
      endTime +
      ',assignmentsToSave=' +
      assignmentsToSave +
      ', assignmentsToRemove=' +
      assignmentsToRemove +
      ',parentTask=' +
      parentTaskId +
      ')'
    );

    // create/update project task...
    CCMI__Milestone_Task__c projTask = new CCMI__Milestone_Task__c();
    if (taskId != null) {
      projTask.Id = taskId;
    } else {
      projTask.CCMI__Desired_Start__c = startDt;
      projTask.CCMI__Duration__c = startDt.daysBetween(endDt) + 1;
      if (projectId != null)
        projTask.CCMI__Milestone_Project__c = projectId;
    }
    if (taskName != null)
      projTask.Name = taskName;
    if (startDt != null)
      projTask.Start__c = startDt;
    if (endDt != null)
      projTask.End__c = endDt;
    if (startTimeObj != null)
      projTask.Start_Time__c = startTimeObj;
    if (endTimeObj != null)
      projTask.End_Time__c = endTimeObj;
    if (status != null)
      projTask.CCMI__Status__c = status;
    if (area != null)
      projTask.Project_Area__c = area;
    if (borisJob != null)
      projTask.BORIS_job__c = borisJob;
    if (includeWeekends != null)
      projTask.Include_Weekends__c = includeWeekends;
    if (parentTaskId != null)
      projTask.CCMI__Parent__c = parentTaskId;
    system.debug('R3>>> projTask=' + projTask);

    upsert projTask;

    // system.debug('R3>>> projTask owner ='+projTask.CCMI__Milestone_Project__c);

    // List<CCMI__Milestone_Project__c> milestone_recs = new List<CCMI__Milestone_Project__c>( [Select Id, OwnerId  FROM CCMI__Milestone_Project__c WHERE Id =: projTask.CCMI__Milestone_Project__c]);
    // system.debug('R3>>> projTask owner records ='+milestone_recs);
    // system.debug('R3>>> projTask owner records owner id='+milestone_recs[0].ownerID );

    // ID parentOwner = milestone_recs[0].ownerID;

    // Add assignments
    if (String.isNotBlank(assignmentsToSave)) {
      List<Object> assignmentsList = (List<Object>) JSON.deserializeUntyped(
        assignmentsToSave
      );

      /*** Start - WI-00920 - **Replace CCMI__Milestone_Assignment2__c with Assignment__c Object ********/
      //List<CCMI__Milestone_Assignment2__c> assignmentsToUpsert = new List<CCMI__Milestone_Assignment2__c>();
      List<Assignment__c> assignmentsToUpsert = new List<Assignment__c>();
      /*** End - WI-00920 - **Replace CCMI__Milestone_Assignment2__c with Assignment__c Object ********/

      for (Object assignmentObj : assignmentsList) {
        Map<String, Object> assignmentObjMap = (Map<String, Object>) assignmentObj;

        /*** Start - WI-00920 - **Replace CCMI__Milestone_Assignment2__c with Assignment__c Object ********/
        //CCMI__Milestone_Assignment2__c taskAssignment = new CCMI__Milestone_Assignment2__c();
        Assignment__c taskAssignment = new Assignment__c();
        /*** End - WI-00920 - **Replace CCMI__Milestone_Assignment2__c with Assignment__c Object ********/

        if (
          assignmentObjMap.containsKey('id') &&
          assignmentObjMap.get('id') != null
        ) {
          taskAssignment.Id = String.valueOf(assignmentObjMap.get('id'));
        }
        system.debug(
          'R3>>> assignmentObjMap.containsKey ownerId )=' +
          assignmentObjMap.containsKey('ownerId')
        );
        if (
          assignmentObjMap.containsKey('ownerId') &&
          assignmentObjMap.get('ownerId') != null
        ) {
          //taskAssignment.ownerId = String.valueOf(assignmentObjMap.get('ownerId'));
          taskAssignment.Assigned_To__c = String.valueOf(
            assignmentObjMap.get('ownerId')
          );
        }
        /* if (assignmentObjMap.containsKey('taskId') && assignmentObjMap.get('taskId') != null) {
                    taskAssignment.CCMI__Milestone_Task__c = String.valueOf(assignmentObjMap.get('taskId'));
                } */
        //taskAssignment.CCMI__Milestone_Task__c = projTask.Id;
        taskAssignment.Project_Task__c = projTask.Id;
        assignmentsToUpsert.add(taskAssignment);
      }
      upsert assignmentsToUpsert;
    }

    // Delete assignments
    if (String.isNotBlank(assignmentsToRemove)) {
      List<Object> assignmentsToDeleteList = (List<Object>) JSON.deserializeUntyped(
        assignmentsToRemove
      );

      /*** Start - WI-00920 - **Replace CCMI__Milestone_Assignment2__c with Assignment__c Object ********/
      //List<CCMI__Milestone_Assignment2__c> assignmentsToDelete = new List<CCMI__Milestone_Assignment2__c>();
      List<Assignment__c> assignmentsToDelete = new List<Assignment__c>();
      /*** End - WI-00920 - **Replace CCMI__Milestone_Assignment2__c with Assignment__c Object ********/
      for (Object assignmentObj : assignmentsToDeleteList) {
        Map<String, Object> assignmentObjMap = (Map<String, Object>) assignmentObj;
        if (
          assignmentObjMap.containsKey('id') &&
          assignmentObjMap.get('id') != null
        ) {
          //assignmentsToDelete.add(new CCMI__Milestone_Assignment2__c(Id = String.valueOf(assignmentObjMap.get('id'))));
          assignmentsToDelete.add(
            new Assignment__c(Id = String.valueOf(assignmentObjMap.get('id')))
          );
        }
      }
      delete assignmentsToDelete;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<sObject> fetchLookUpValues(
    String searchKey,
    String fieldName,
    String ObjectName,
    String criteria,
    String orderBy
  ) {
    String sQuery =
      'SELECT Id, ' +
      fieldName +
      ' FROM ' +
      ObjectName +
      ' WHERE Id != null';
    if (String.isNotBlank(ObjectName) && ObjectName.equals('Account')) {
      sQuery += ' AND Type = \'Customer\'';
    }
    if (String.isNotBlank(searchKey)) {
      sQuery += ' AND ' + fieldName + ' LIKE \'%' + searchKey + '%\'';
    }
    if (String.isNotBlank(criteria)) {
      sQuery += ' AND ' + criteria;
    }
    if (String.isNotBlank(orderBy)) {
      sQuery += ' ORDER BY ' + orderBy;
    }
    sQuery += ' LIMIT 100';

    System.debug('R3>>> sQuery=' + sQuery);
    return Database.query(sQuery);

    /* 
        List<sObject> listOfRecords = Database.query(sQuery);
        List<sObject> returnList = new List<sObject>();
        for (sObject obj: listOfRecords) {
            returnList.add(obj);
        }
        return returnList; */
  }

  @AuraEnabled
  public static void saveAllocation(
    Id allocationId,
    Id taskId,
    Id resourceId,
    String taskName,
    String effort,
    String status,
    String startDate,
    String endDate
  ) {
    Id assignmentId = allocationId; /// it's an assignment Id not an allocation Id!
    //Id taskId = projectId;   /// it's a task Id not a project Id!
    system.debug('startDate==' + startDate);
    system.debug('endDate==' + endDate);
    Date startDt;
    Date endDt;
    if (startDate != null)
      startDt = DateTime.newInstance(Long.valueOf(startDate)).date();
    if (endDate != null)
      endDt = DateTime.newInstance(Long.valueOf(endDate)).date();
    system.debug(
      'R3>>> enter saveAllocation(assignmentId=' +
      assignmentId +
      ', taskId=' +
      taskId +
      ', resourceId=' +
      resourceId +
      ', effort=' +
      effort +
      ', status=' +
      status +
      ', statusDate=' +
      startDt +
      ', endDate=' +
      endDt +
      ')'
    );

    // get the task id from the assignment record...
    if (taskId == null && assignmentId != null) {
      /*** Start - WI-00920 - **Replace CCMI__Milestone_Assignment2__c with Assignment__c Object ********/
      // CCMI__Milestone_Assignment2__c assign = [SELECT id, CCMI__Milestone_Task__c FROM CCMI__Milestone_Assignment2__c WHERE Id = :assignmentId LIMIT 1];
      Assignment__c assign = [
        SELECT id, Project_Task__c
        FROM Assignment__c
        WHERE Id = :assignmentId
        LIMIT 1
      ];
      //taskId = assign.CCMI__Milestone_Task__c;
      taskId = assign.Project_Task__c;
      /*** End - WI-00920 ***/
    }

    if (resourceId != null) {
      // insert/update project task assignment...
      /*** Start - WI-00920 - **Replace CCMI__Milestone_Assignment2__c with Assignment__c Object ********/
      //CCMI__Milestone_Assignment2__c taskAssignment = new CCMI__Milestone_Assignment2__c();
      Assignment__c taskAssignment = new Assignment__c();
      /*** End - WI-00920 ***/
      //taskAssignment.OwnerId = resourceId;
      taskAssignment.Assigned_To__c = resourceId;
      if (assignmentId != null)
        taskAssignment.id = assignmentId;
      if (taskId != null)
        // taskAssignment.CCMI__Milestone_Task__c = taskId;
        taskAssignment.Project_Task__c = taskId;
      if (effort != null) {
        //taskAssignment.Team__c = effort;
        //taskAssignment.Effort__c = effort;
      }
      if (status != null) {
        //taskAssignment.Status__c = status;
        if (status == 'Unavailable')
          //taskAssignment.CCMI__Milestone_Task__c = null;
          taskAssignment.Project_Task__c = taskId;
      }
      system.debug('R3>>> taskAssignment=' + taskAssignment);
      //update taskAssignment;
      upsert taskAssignment;
    }

    if (taskId != null) {
      // update project task...
      CCMI__Milestone_Task__c projTask = new CCMI__Milestone_Task__c();
      projTask.Id = taskId;
      if (taskName != null)
        projTask.Name = taskName;
      if (startDt != null)
        projTask.start__c = startDt;
      if (endDt != null)
        projTask.end__c = endDt;
      if (status != null)
        projTask.CCMI__Status__c = status;
      system.debug('R3>>> projTask=' + projTask);
      update projTask;
    }
  }

  @AuraEnabled
  public static void deleteAllocation(Id allocationId) {
    system.debug('R3>>> enter deleteAllocation');
    delete new CCMI__Milestone_Task__c(Id = allocationId);
  }

  /*
    Old Gantt Chart methods
    @AuraEnabled
    public static Map<String, Object> getChartData(String recordId, String startTime, String endTime, Integer slotSize, List<String> filterResources, List<String> filterProjects, List<String> filterRoles, String filterStatus) 
    {
        system.debug('R3>>> enter getChartData(recordId='+recordId+',startTime='+startTime+',endTime='+endTime+',slotSize='+slotSize+',...)');

        DateTime startDateTime = DateTime.newInstance(Long.valueOf(startTime));
        DateTime endDateTime = DateTime.newInstance(Long.valueOf(endTime));
        System.debug('R3>>> startDateTime = '+startDateTime);
        System.debug('R3>>> EndDateTime = '+endDateTime);
        Date startDate = startDateTime.date();
        Date endDate = endDateTime.date();
        System.debug('R3>>> startDate = '+startDate);
        System.debug('R3>>> EndDate = '+endDate);

        // load all resources... 
        Map<Id,User> resources = new Map<Id,User>([SELECT id, name, Project_Resource__c, Project_Team__c FROM User WHERE Project_Resource__c = TRUE]);

        Map<String, Object> data = new Map<String, Object>();
        String query = 'SELECT OwnerId, '+
                               //'Owner.Name, '+
                               //'Owner.Project_Resource__c, '+
                               //'Owner.Project_Team__c, '+
                               'CCMI__Milestone_Task__c, '+
                               'CCMI__Milestone_Task__r.Name, '+
                               'CCMI__Milestone_Task__r.Active__c, '+
                               'CCMI__Milestone_Task__r.Display__c, '+
                               'CCMI__Milestone_Task__r.Color__c, '+
                               'CCMI__Milestone_Task__r.Start__c, '+
                               'CCMI__Milestone_Task__r.End__c, '+
                               'CCMI__Milestone_Task__r.CCMI__Status__c, '+
                               'CCMI__Milestone_Task__r.CCMI__Milestone_Project__c, '+
                               'CCMI__Milestone_Task__r.CCMI__Milestone_Project__r.Name, '+
                               'Status__c, Team__c, '+
                               'Display__c, '+
                               'Pop_up_Text__c, '+
                               'Effort__c, '+
                               'Edit_URL__c '+
                        'FROM CCMI__Milestone_Assignment2__c '+
                        'WHERE CCMI__Milestone_Task__r.Start__c <= '+endDateTime.format('yyyy-MM-dd')+' AND '+
                              'CCMI__Milestone_Task__r.End__c >= '+startDateTime.format('yyyy-MM-dd')+' AND '+
                              '(CCMI__Milestone_Task__c = NULL OR CCMI__Milestone_Task__r.Active__c = TRUE) ';
                                //'Owner.Project_Resource__c = TRUE';
        
        List<CCMI__Milestone_Assignment2__c> allocations = new List<CCMI__Milestone_Assignment2__c>();
        Map<String, Object> projectById = new Map<String, Object>();
        Map<String, Object> resourceById = new Map<String, Object>();
        Set<String> roles = new Set<String>();

        if (!filterProjects.isEmpty()) 
        {
            query += ' AND CCMI__Milestone_Task__c IN :filterProjects';
        }
        /*
        if (!filterProjectRecords.isEmpty()) 
        {
            query += ' AND CCMI__Milestone_Task__c IN :filterProjectRecords';
        }
        * /
        //if (!filterRoles.isEmpty()) 
        //{
            //query += ' AND Owner.Project_Team__c IN :filterRoles';
        //}
        if (String.isNotEmpty(filterStatus)) 
        {
            query += ' AND Status__c = :filterStatus';
        }
        
        if (!filterResources.isEmpty()) 
        {
           query += ' AND OwnerId IN :filterResources';
        }

        if (String.isNotEmpty(startTime) &&  String.isNotEmpty(endTime)) 
        {
            Integer days = startDate.daysBetween(endDate) + 1;
            slotSize = Integer.valueOf(slotSize);
            Decimal slots = days / slotSize;
            
            // Overview View
            if (String.isEmpty(recordId)) 
            {
                System.debug('R3>>> Overview view');
                query += ' ORDER BY Owner.Name, CCMI__Milestone_Task__r.Name NULLS FIRST, Start_Date__c';
                System.debug('R3>>> query = '+query);
                System.debug('R3>>> slotSize = '+slotSize);

                allocations = Database.query(query);
                System.debug('R3>>> allocations = '+allocations);

                // display all active resources
                for (Object res: newGanttChart.getResources()) 
                {
                    System.debug('R3>>> res='+res);
                    Map<String, Object> resource = (Map<String, Object>)res;
                    resourceById.put((String)resource.get('Id'), new Map<String, Object> { 'Id' => resource.get('Id'), 'Name' => resource.get('Name'), 'Label' => resource.get('Name'), 'Project_Team__c' => resource.get('Project_Team__c'), 'allocationsByProject' => new Map<String, Object>() });
                }
            } 
            else 
            {
                System.debug('R3>>> Project/User View');
                if (Id.valueOf(recordId).getSobjectType().getDescribe().getName().endsWith('CCMI__Milestone_Task__c')) 
                {
                    data.put('projectId', recordId);
                }

                query += ' AND (CCMI__Milestone_Task__c = :recordId OR OwnerId = :recordId)';
                query += ' ORDER BY Owner.Name, CCMI__Milestone_Task__r.Name NULLS FIRST, Start_Date__c';

                System.debug('R3>>> query = '+query);
                allocations = Database.query(query);

                // empty state on resource page
                if (allocations.isEmpty() && Id.valueOf(recordId).getSobjectType().getDescribe().getName().endsWith('User')) 
                {
                    System.debug('R3>>> no allocations get user');
                    User user = [SELECT Id, Name, Project_Resource__c, Project_Team__c
                                            FROM User
                                            WHERE Id = :recordId];

                    resourceById.put(user.Id, new Map<String, Object> { 'Id' => user.Id, 'Name' => user.Name, 'Label' => user.Name, 'Project_Team__c' => user.Project_Team__c, 'allocationsByProject' => new Map<String, Object>() });
                }
            }

            // organize allocations by resource and project
            for (CCMI__Milestone_Assignment2__c allocation : allocations) 
            {
                if (!resourceById.containsKey(allocation.OwnerId)) 
                {
                    resourceById.put(allocation.OwnerId, new Map<String, Object> { 'Id' => allocation.OwnerId, 'Name' => resources.get(allocation.OwnerId).Name, 'Label' => resources.get(allocation.OwnerId).Name, 'Project_Team__c' => resources.get(allocation.OwnerId).Project_Team__c, 'allocationsByProject' => new Map<String, Object>() });
                }

                Map<String, Object> resource = (Map<String, Object>)resourceById.get(allocation.OwnerId);
                Map<String, Object> allocationsByProject = (Map<String, Object>)resource.get('allocationsByProject');
                
                if (!allocationsByProject.containsKey(allocation.CCMI__Milestone_Task__c)) 
                {
                    allocationsByProject.put(allocation.CCMI__Milestone_Task__c, new List<Object>());
                }

                projectById.put(allocation.CCMI__Milestone_Task__c, new Map<String, Object> 
                {
                    'Id' => allocation.CCMI__Milestone_Task__c,
                    'Name' => allocation.CCMI__Milestone_Task__r.Name
                });

                List<Object> projectAllocation = (List<Object>)allocationsByProject.get(allocation.CCMI__Milestone_Task__c);

                Decimal left = Decimal.valueOf(startDate.daysBetween(allocation.CCMI__Milestone_Task__r.Start__c)) / slotSize;
                left = left.round(System.RoundingMode.FLOOR);
                
                Decimal right = Decimal.valueOf(startDate.daysBetween(allocation.CCMI__Milestone_Task__r.End__c)) / slotSize;
                right = right.round(System.RoundingMode.FLOOR);

                // This method defines which fields from the query at the start of the class are available on the Allocation object, for example for display through
                // the gantt_chart_resource Lightning Web Component.
                projectAllocation.add(new Map<String, Object> 
                {
                    'Id' => allocation.Id,
                    'Start_Date__c' => allocation.CCMI__Milestone_Task__r.Start__c,
                    'End_Date__c' => allocation.CCMI__Milestone_Task__r.End__c,
                    //'Status__c' => allocation.Status__c,
                    'Status__c' => allocation.CCMI__Milestone_Task__r.CCMI__Status__c,
                    'Team__c' => allocation.Team__c,
                    'Effort__c' => allocation.Effort__c,
                    'editURL' => allocation.Edit_URL__c,
                    'taskId' => allocation.CCMI__Milestone_Task__c,
                    'taskName' => allocation.CCMI__Milestone_Task__r.Name,
                    'projectId' => allocation.CCMI__Milestone_Task__r.CCMI__Milestone_Project__c,
                    'projectName' => allocation.CCMI__Milestone_Task__r.CCMI__Milestone_Project__r.Name,
                    'display' => allocation.Display__c, // Formula field added by DS to allow flexible definition of display on Gantt elements.
                    'popup' => allocation.Pop_up_Text__c, // Formula field added by DS to define the text on each job's pop-up window.
                    'color' => allocation.CCMI__Milestone_Task__r.Color__c,
                    'left' => left,
                    'right' => right
                });

                System.debug('R3>>> Task: name='+allocation.CCMI__Milestone_Task__r.name+', start='+allocation.CCMI__Milestone_Task__r.Start__c+', end='+allocation.CCMI__Milestone_Task__r.End__c);
                roles.add(resources.get(allocation.OwnerId).Project_Team__c);
            }
        }

        data.put('projects', projectById.values());
        data.put('resources', resourceById.values());
        System.debug('R3>>> resourceById.values()='+resourceById.values());
        System.debug('R3>>> data='+data);
        data.put('roles', roles);
        
        return data;
    }
    */
}
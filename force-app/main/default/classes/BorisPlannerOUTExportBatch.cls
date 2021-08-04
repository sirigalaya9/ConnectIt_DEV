/**
 * @description       :
 * @author            : Jonny Harte
 * @group             :
 * @last modified on  : 05-02-2021
 * @last modified by  : Jonny Harte
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-02-2021   Jonny Harte   Initial Version
 **/
public with sharing class BorisPlannerOUTExportBatch implements Database.Batchable<SObject> {
  private final Date fromDate;
  private final Date toDate;
  private final List<String> projectIds;
  private final String filterStr;
  private final List<String> filterProjectIds;
  private final List<String> filterRoles;
  private final List<String> filterResourceIds;
  private final List<String> filterProjManager;
  private final List<String> filterAccountIds;
  private final List<String> filterProjectStatus;
  private final List<String> filterProjectType;
  private final List<String> filterWorkstream;

  public class Project {
    public String id;
    public String name;
  }

  public BorisPlannerOUTExportBatch(
    Date fromDate,
    Date toDate,
    String filterStr
  ) {
    this.fromDate = fromDate;
    this.toDate = toDate;
    this.filterStr = filterStr;
    //this.filterProjectIds = new List<Id>();
    //this.filterResourceIds = new List<Id>();
    //this.filterRoles = new List<String>();
    String filterProjManager = null;
    //String filterAccount = null;
    //this.filterAccountIds = new List<Id>();
    Id projId = null;
    Id accountId = null;
    Id resId = null;
    String roleId = null;
    Map<String, Object> filter = null;

    System.debug('filterStr=' + filterStr);
    if (filterStr != null && filterStr.length() >= 1) {
      filter = (Map<String, Object>) JSON.deserializeUntyped(filterStr);

      // get projects
      this.filterProjectIds = getFilterDataList('projects', filter);
      System.Debug(
        'R3 ==> BorisPlannerOUTExportBatch this.filterProjectIds=' +
        this.filterProjectIds
      );

      // get resources
      this.filterResourceIds = getFilterDataList('resources', filter);

      // get roles
      this.filterRoles = getFilterDataList('roles', filter);
      System.Debug(
        'R3 ==> BorisPlannerOUTExportBatch this.filterRoles=' + this.filterRoles
      );

      // get Accounts
      this.filterAccountIds = getFilterDataList('accounts', filter);
      System.Debug(
        'R3 ==> BorisPlannerOUTExportBatch this.filterAccountIds=' +
        this.filterAccountIds
      );

      // get filterProjManager
      this.filterProjManager = getFilterDataList('projManager', filter);
      System.Debug(
        'R3 ==> BorisPlannerOUTExportBatch this.filterProjManagerIds=' +
        this.filterProjManager
      );

      // get filterProjectStatus
      this.filterProjectStatus = getFilterDataList('status', filter);
      System.Debug(
        'R3 ==> BorisPlannerOUTExportBatch this.filterProjectStatusIds=' +
        this.filterProjectStatus
      );

      // get filterProjectType
      this.filterProjectType = getFilterDataList('type', filter);
      System.Debug(
        'R3 ==> BorisPlannerOUTExportBatch this.filterProjectTypeIds=' +
        this.filterProjectType
      );

      // get filterProjectType
      this.filterWorkstream = getFilterDataList('area', filter);
      System.Debug(
        'R3 ==> BorisPlannerOUTExportBatch this.filterWorkstreamIds=' +
        this.filterWorkstream
      );

      // get filterProjManager
      // Map<String, Object> projManager = (Map<String, Object>) filter.get(
      //   'projManager'
      // );
      // System.Debug(
      //   'R3 ==> BorisPlannerOUTExportBatch projManager=' + projManager
      // );

      // if (projManager != null) {
      //   if (projManager.containsKey('id')) {
      //     this.filterProjManager = (String) projManager.get('id');
      //   }
      //   System.Debug(
      //     'R3 ==> BorisPlannerOUTExportBatch filterProjManager=' +
      //     filterProjManager
      //   );
      // }

      // filterProjectStatus
      // this.filterProjectStatus = (String) filter.get('status');
      // System.Debug(
      //   'R3 ==> BorisPlannerOUTExportBatch filterProjectStatus=' +
      //   filterProjectStatus
      // );

      // filterProjectType
      // this.filterProjectType = (String) filter.get('type');
      // System.Debug(
      //   'R3 ==> BorisPlannerOUTExportBatch filterProjectType=' +
      //   filterProjectType
      // );

      // filterWorkstream
      // this.filterWorkstream = (String) filter.get('area');
      // System.Debug(
      //   'R3 ==> BorisPlannerOUTExportBatch filterWorkstream=' + filterWorkstream
      // );
    }
  }

  private List<String> getFilterDataList(
    String filterName,
    Map<String, Object> filter
  ) {
    List<String> filterList = new List<String>();
    String filterId = null;
    // get projects
    List<Object> filterObjects = (List<Object>) filter.get(filterName);
    System.Debug(
      'R3 ==> BorisPlannerOUTExportBatch filterObjects=' + filterObjects
    );

    if (filterObjects != null && filterObjects.size() > 0) {
      for (Object filterObj : filterObjects) {
        System.Debug('R3 ==> BorisPlannerOUTExportBatch projObj=' + filterObj);
        Map<String, Object> filterParam = (Map<String, Object>) filterObj;

        if (filterParam != null) {
          System.Debug(
            'R3 ==> BorisPlannerOUTExportBatch filterParam=' + filterParam
          );
          filterId = (String) filterParam.get('id');
          System.Debug(
            'R3 ==> BorisPlannerOUTExportBatch filterId=' + filterId
          );
          if (filterId != null && filterId != '' && filterId != 'null') {
            filterList.add(filterId);
          }
        }
      }
    }
    System.Debug(
      'R3 ==> BorisPlannerOUTExportBatch this.filterList=' + filterList
    );
    return filterList;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query =
      'SELECT ' +
      'OwnerId, Owner.Name, ' +
      'Project_Task__c, Project_Task__r.CCMI__Milestone_Project__c, Project_Task__r.Start_Time__c, Project_Task__r.End_Time__c, ' +
      'Project_Task__r.Name, Project_Task__r.CCMI__Duration__c, Project_Task__r.CCMI__Start__c, Project_Task__r.CCMI__End__c, ' +
      'Project_Task__r.CCMI__Milestone_Project__r.CCMI__Account__c, Project_Task__r.CCMI__Milestone_Project__r.Job_no__c, ' +
      'Project_Task__r.CCMI__Milestone_Project__r.Site__c, Project_Task__r.CCMI__Milestone_Project__r.Site__r.Name, ' +
      'Project_Task__r.CCMI__Milestone_Project__r.Project_Manager__c, Project_Task__r.BORIS_Codes__c, Project_Task__r.CCMI__Milestone_Project__r.Materials_Request__c, ' +
      'Project_Task__r.Start__c, Project_Task__r.End__c, Project_Task__r.CCMI__Description__c, Assigned_To__c, ' +
      'Project_Task__r.CCMI__Milestone_Project__r.Materials_Request__r.Name ' +
      'FROM Assignment__c ' +
      'WHERE Project_Task__r.BORIS_job__c = true  ';

    if (this.filterProjectIds != null && this.filterProjectIds.size() > 0) {
      query =
        query +
        '  AND Project_Task__r.CCMI__Milestone_Project__c IN :filterProjectIds ';
    }
    if (this.filterResourceIds != null && this.filterResourceIds.size() > 0) {
      query = query + '  AND Assigned_To__c IN :filterResourceIds ';
    }
    if (this.filterProjManager != null && this.filterProjManager.size() > 0) {
      query =
        query +
        '  AND Project_Task__r.CCMI__Milestone_Project__r.Project_Manager__c IN :filterProjManager ';
    }
    if (this.filterAccountIds != null && this.filterAccountIds.size() > 0) {
      query =
        query +
        '  AND Project_Task__r.CCMI__Milestone_Project__r.CCMI__Account__c IN :filterAccountIds ';
    }
    if (this.filterRoles != null && this.filterRoles.size() > 0) {
      query = query + '  AND Assigned_To__r.job_title__c IN :filterRoles ';
    }
    if (
      this.filterProjectStatus != null &&
      this.filterProjectStatus.size() > 0
    ) {
      query =
        query +
        '  AND Project_Task__r.CCMI__Milestone_Project__r.CCMI__Status__c IN :filterProjectStatus ';
    }
    if (this.filterProjectType != null && this.filterProjectType.size() > 0) {
      query =
        query +
        '  AND Project_Task__r.CCMI__Milestone_Project__r.CCMI__Type__c IN :filterProjectType ';
    }
    if (this.filterWorkstream != null && this.filterWorkstream.size() > 0) {
      query =
        query + '  AND Project_Task__r.Project_Area__c IN :filterWorkstream ';
    }
    query =
      query +
      '    AND Project_Task__c IN ' +
      '    (SELECT Id FROM CCMI__Milestone_Task__c ' +
      '    WHERE CCMI__Start__c >= :fromDate AND CCMI__Start__c <= :toDate )';

    System.Debug('R3 Database.QueryLocator query = ' + query);
    System.Debug('R3 Database.QueryLocator projectIds = ' + filterProjectIds);
    System.Debug(
      'R3 Database.QueryLocator filterProjManager = ' + filterProjManager
    );
    System.Debug(
      'R3 Database.QueryLocator filterResourceIds = ' + filterResourceIds
    );
    System.Debug(
      'R3 Database.QueryLocator filterAccountIds = ' + filterAccountIds
    );
    System.Debug('R3 Database.QueryLocator filterRoles = ' + filterRoles);
    System.Debug(
      'R3 Database.QueryLocator filterProjectStatus = ' + filterProjectStatus
    );
    System.Debug(
      'R3 Database.QueryLocator filterProjectType = ' + filterProjectType
    );
    System.Debug(
      'R3 Database.QueryLocator filterWorkstream = ' + filterWorkstream
    );

    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext bc, List<SObject> scope) {
    List<BORIS_Planner_OUT__c> bpoList = new List<BORIS_Planner_OUT__c>();
    Set<CCMI__Milestone_Task__c> taskSet = new Set<CCMI__Milestone_Task__c>();
    List<CCMI__Milestone_Task__c> taskList = new List<CCMI__Milestone_Task__c>();
    BORIS_Planner_OUT__c bpo = new BORIS_Planner_OUT__c();
    Time startTime;
    Time endTime;

    for (SObject s : scope) {
      Assignment__c resource = (Assignment__c) s;

      bpo = BORIS_Planner_OUT_helper.assignBPO(
        resource,
        resource.Project_Task__r
      );
      System.debug('R3 ==> BorisPlannerOUTExportBatch bpo=' + bpo);
      bpoList.add(bpo); // KF Refactor into 1 method call

      // Update Sent To Boris Indicator
      CCMI__Milestone_Task__c task = new CCMI__Milestone_Task__c();
      task.Id = resource.Project_Task__r.Id;
      task.Sent_To_BORIS__c = true;
      taskSet.add(task);
    }

    if (taskSet.size() > 0) {
      taskList = new List<CCMI__Milestone_Task__c>(taskSet);
      update taskList;
    }

    System.debug('R3 ==> BorisPlannerOUTExportBatch bpoList=' + bpoList);
    if (bpoList.size() > 0) {
      insert bpoList;
    }
  }

  public void finish(Database.BatchableContext bc) {
  }
}
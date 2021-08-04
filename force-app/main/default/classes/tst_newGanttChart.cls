@isTest
public with sharing class tst_newGanttChart {
  @isTest
  static void getResources() {
    // arrange
    Integer resCount = [
      SELECT COUNT()
      FROM User
      WHERE Project_Resource__c = TRUE AND IsActive = TRUE
    ];
    //act
    List<Object> userObjList = newGanttChart.getResources();

    // assert
    System.assertEquals(resCount, userObjList.size());
  }

  @isTest
  static void getProjManager() {
    // arrange
    Integer resCount = [
      SELECT COUNT()
      FROM User
      WHERE Title LIKE '%Project Manager%' AND IsActive = TRUE
    ];
    //act
    List<Object> projManagerObjList = newGanttChart.getProjManager();

    // assert
    System.assertEquals(resCount, projManagerObjList.size());
  }

  @isTest
  static void getType() {
    // arrange
    Integer resCount = [SELECT COUNT() FROM CCMI__Milestone_Project__c];
    //act
    List<Object> typeObjList = newGanttChart.getType();

    // assert
    System.assertEquals(resCount, typeObjList.size());
  }

  @isTest
  static void getArea() {
    // arrange
    Integer resCount = [SELECT COUNT() FROM CCMI__Milestone_Task__c];
    //act
    List<Object> areaObjList = newGanttChart.getArea();

    // assert
    System.assertEquals(resCount, areaObjList.size());
  }

  @isTest
  static void getStatus() {
    // arrange
    Integer resCount = [SELECT COUNT() FROM CCMI__Milestone_Project__c];
    //act
    List<Object> statusObjList = newGanttChart.getStatus();

    // assert
    System.assertEquals(resCount, statusObjList.size());
  }

  @isTest
  static void getRoles() {
    // arrange
    //Integer resCount = [
    ////  SELECT COUNT()
    //  FROM User
    //  WHERE Project_Resource__c = TRUE AND IsActive = TRUE
    //];
    //act
    List<Object> roleObjList = newGanttChart.getRoles();

    // assert
    System.assertNotEquals(0, roleObjList.size());
  }

  @isTest
  static void getAccounts() {
    // arrange
    //test Data
    Account custAcc = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Standard')
        .getRecordTypeId(),
      Name = 'Test Standard Account',
      Type = 'Customer'
    );
    insert custAcc;

    //act
    List<Object> accObjList = newGanttChart.getAccounts();

    // assert
    System.assertNotEquals(0, accObjList.size());
  }

  @isTest
  static void getProjects() {
    //test Data
    Account custAcc = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Standard')
        .getRecordTypeId(),
      Name = 'Test Standard Account',
      Type = 'Customer'
    );
    insert custAcc;

    Account siteAcc = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Site')
        .getRecordTypeId(),
      Name = 'Coach Park Car Park, Worthy Lane, Winchester, SO23 7AB',
      Customer_Account__c = custAcc.Id
    );
    insert siteAcc;

    Opportunity testEstimate = new Opportunity(
      RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
        .get('SSENCON')
        .getRecordTypeId(),
      StageName = 'Enquiry',
      CloseDate = Date.today().addDays(-100),
      Site__c = siteAcc.Id,
      Name = 'Coach Park Car Park, Worthy Lane, Winchester, SO23 7AB',
      Property_Type__c = 'Commercial',
      Utilities__c = 'Electric',
      Job_Number__c = 'EH1KK',
      Estimate_Date__c = Date.today().addDays(-94),
      Project_Start__c = Date.today().addDays(-110)
      //Type = 'SSEN Minor Works'
    );
    insert testEstimate;

    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;
    CCMI__Milestone_Task__c milestoneProjectTask1 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );

    // arrange
    Integer projCount = [SELECT COUNT() FROM CCMI__Milestone_Project__c];
    //act
    List<Object> projObjList = newGanttChart.getProjects();
    system.debug('projObjList ==>>> ' + projObjList);
    // assert
    System.assertEquals(projCount, projObjList.size());
  }

  @isTest
  static void getProjectRecords() {
    List<String> IdList = new List<String>();
    Integer pageNumber = null;
    Integer recordsPerPage = null;
    List<String> statusFilter = new List<String>();
    List<String> typeFilter = new List<String>();
    List<String> projManagerFilter = new List<String>();
    List<String> accountFilter = new List<String>();
    List<String> areaFilter = new List<String>();

    Integer projCount = [
      SELECT COUNT()
      FROM CCMI__Milestone_Project__c
      WHERE Name != NULL
    ];
    //act
    List<Object> projObjList = newGanttChart.getProjectRecords(
      IdList,
      pageNumber,
      recordsPerPage,
      statusFilter,
      typeFilter,
      projManagerFilter,
      accountFilter,
      areaFilter
    );
    // assert
    System.assertEquals(projCount, projObjList.size());
  }

  @isTest
  static void getGanttChartSettings() {
    Map<String, Object> settings = new Map<String, Object>();
    settings = newGanttChart.getGanttChartSettings();
    System.assertNotEquals(null, settings);
  }

  @isTest
  static void setGanttChartSettings() {
    Map<String, Object> oldSettings = new Map<String, Object>();
    Map<String, Object> newSettings = new Map<String, Object>();

    oldSettings = newGanttChart.getGanttChartSettings();
    Object oldfilterResource = oldSettings.get('filterResources');
    System.debug(oldSettings.get('filterResources'));
    newGanttChart.setGanttChartSettings(
      'Test',
      null,
      null,
      null,
      null,
      null,
      null,
      null
    );

    newSettings = newGanttChart.getGanttChartSettings();
    System.debug(' new settings .. ' + newSettings);
    Object newfilterResource = newSettings.get('filterResources');
    System.debug(newSettings.get('filterResources'));

    System.assertEquals(null, oldfilterResource);
    System.assertEquals('Test', newfilterResource);
  }

  @isTest
  static void getGanttChartData() {
    // public static Map<String, Object> getGanttChartData(String recordId, String viewMode, String startTime, String endTime, Integer slotSize, Integer pageNumber, Integer recordsPerPage,
    // List<String> filterResources, List<String> filterProjects, List<String> filterRoles,
    // String filterStatus, String filterType, String filterArea, String filterProjManager, String filterAccount)

    // Assign
    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;
    List<String> projectIdList = new List<String>();
    projectIdList.add(milestoneProject.id);

    CCMI__Milestone_Task__c milestoneProjectTask1 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask1;

    CCMI__Milestone_Task__c milestoneProjectTask2 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask2;

    CCMI__Milestone_Task__c milestoneProjectTask3 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask3;

    Assignment__c assignment1 = new Assignment__c(
      Project_Task__c = milestoneProjectTask1.id
    );
    insert assignment1;

    Assignment__c assignment2 = new Assignment__c(
      Project_Task__c = milestoneProjectTask2.id
    );
    insert assignment2;

    Map<String, Object> dataProj = new Map<String, Object>();
    Map<String, Object> dataRes = new Map<String, Object>();
    Map<String, Object> filteredProj = new Map<String, Object>();
    Map<String, Object> filteredResource = new Map<String, Object>();

    // Act
    dataProj = newGanttChart.getGanttChartData(
      milestoneProject.id,
      'project-overview',
      String.valueOf(system.now().getTime() - 3600),
      String.valueOf(system.now().getTime() + 3600),
      1,
      1,
      10,
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>()
    );
    System.debug('dataProj -> ' + dataProj);

    System.debug('dataRes totalRows -> ' + dataProj.get('totalRows'));
    System.debug('dataRes ganttRows -> ' + dataProj.get('ganttRows'));

    dataRes = newGanttChart.getGanttChartData(
      milestoneProject.id,
      'resource-overview',
      String.valueOf(system.now().getTime() - 3600),
      String.valueOf(system.now().getTime() + 3600),
      1,
      1,
      10,
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>()
    );
    //System.debug('dataRes -> ' + dataRes );
    // Assert

    //FilteredProjSearch
    filteredProj = newGanttChart.getGanttChartData(
      milestoneProject.id,
      'project-overview',
      String.valueOf(system.now().getTime() - 3600),
      String.valueOf(system.now().getTime() + 3600),
      1,
      1,
      10,
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>{ 'Value not in list' },
      new List<String>{ 'Value not in list' },
      new List<String>{ 'Value not in list' },
      new List<String>(),
      new List<String>()
    );

    //FilteredResourceSearch
    filteredResource = newGanttChart.getGanttChartData(
      milestoneProject.id,
      'resource-overview',
      String.valueOf(system.now().getTime() - 3600),
      String.valueOf(system.now().getTime() + 3600),
      1,
      1,
      10,
      new List<String>(),
      new List<String>(),
      new List<String>(),
      new List<String>{ 'Value not in list' },
      new List<String>{ 'Value not in list' },
      new List<String>{ 'Value not in list' },
      new List<String>(),
      new List<String>()
    );

    System.assertNotEquals(null, dataProj);
    System.assertEquals(1, dataProj.get('totalRows'));
    System.assertEquals(0, filteredProj.get('totalRows'));
    System.assertEquals(0, filteredResource.get('totalRows'));
    System.assertNotEquals(null, dataRes);
  }

  @isTest
  static void saveTask() {
    // saveTask(Id taskId, Id projectId, String taskName, String status, String area, Boolean borisJob, Boolean includeWeekends,
    //              String startDate, String endDate, String startTime, String endTime, String assignmentsToSave, String assignmentsToRemove,
    //              string parentTaskId)

    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;
    CCMI__Milestone_Task__c milestoneProjectTask1 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask1;
    CCMI__Milestone_Task__c milestoneProjectTask2 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask2;

    newGanttChart.saveTask(
      milestoneProjectTask2.id,
      milestoneProject.id,
      'NewName',
      'Active',
      'SSEN',
      false,
      false,
      '1',
      '2',
      '00:00',
      '01:00',
      '',
      '',
      milestoneProjectTask1.id
    );

    CCMI__Milestone_Task__c projTask = [
      SELECT Name, CCMI__Status__c, Project_Area__c, BORIS_job__c
      FROM CCMI__Milestone_Task__c
      WHERE Id = :milestoneProjectTask2.id
    ];

    //Assert
    System.debug(projTask);
    System.assertEquals('NewName', projTask.get('Name'));
    System.assertEquals('Active', projTask.get('CCMI__Status__c'));
    System.assertEquals('SSEN', projTask.get('Project_Area__c'));
    System.assertEquals(false, projTask.get('BORIS_job__c'));
  }

  @isTest
  static void fetchLookUpValues() {
    // public static List<sObject> fetchLookUpValues(String searchKey, String fieldName, String ObjectName, String criteria, String orderBy)

    // Assign
    String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    Id accountId = AccountTestDataFactory.create();
    Account acc = [SELECT Name, Id, Type FROM ACCOUNT WHERE Id = :accountId];
    acc.Name = acc.Id;
    acc.Type = ACCOUNT_TYPE_CUSTOMER;
    update acc;

    String searchKey = acc.Id;
    String fieldName = 'Name';
    String Type = 'Customer';
    String ObjectName = 'Account';
    String criteria = '';
    String orderBy = 'Name';

    //Act
    List<Account> accList = newGanttChart.fetchLookUpValues(
      searchKey,
      fieldName,
      ObjectName,
      criteria,
      orderBy
    );
    System.debug(accList);
    System.debug('account ' + accList.get(0).Name);
    // Assert
    System.assertEquals(1, accList.size());
    System.assertEquals(searchKey, accList.get(0).Name);

    Account acc2 = [
      SELECT Name, Id, Type
      FROM ACCOUNT
      WHERE Name = :accList.get(0).Name
    ];
    System.assertEquals(ACCOUNT_TYPE_CUSTOMER, acc2.Type);
  }

  @isTest
  static void saveAllocation() {
    // it is save Assignments and not Allocation.
    // public static void saveAllocation(Id allocationId, Id taskId, Id resourceId, String taskName, String effort, String status, String startDate, String endDate)
    //newGanttChart.saveAllocation(assignment1.id, milestoneProjectTask1.id, UserInfo.getUserId(), 'test', '2', 'active', '1', '2');

    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;
    CCMI__Milestone_Task__c milestoneProjectTask1 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask1;
    CCMI__Milestone_Task__c milestoneProjectTask2 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask2;

    Assignment__c assignment1 = new Assignment__c(
      Project_Task__c = milestoneProjectTask1.id
    );
    insert assignment1;

    newGanttChart.saveAllocation(
      assignment1.id,
      milestoneProjectTask1.id,
      UserInfo.getUserId(),
      'test',
      '2',
      'active',
      '1',
      '2'
    );

    CCMI__Milestone_Task__c projTask = [
      SELECT
        Name,
        CCMI__Status__c,
        Project_Area__c,
        BORIS_job__c,
        CCMI__Assignments__c
      FROM CCMI__Milestone_Task__c
      WHERE Id = :milestoneProjectTask2.id
    ];

    System.debug('assignment1 ' + assignment1);
    System.debug('assignment1  Project_Task__c ' + assignment1.Project_Task__c);
    System.debug('projTask -> ' + projTask.Id); // intial
    System.debug('projTask -> ' + projTask); // intial
    //Assert
  }

  @isTest
  static void deleteAllocation() {
    // newGanttChart.deleteAllocation(milestoneProjectTask2.id);

    CCMI__Milestone_Project__c milestoneProject = new CCMI__Milestone_Project__c();
    insert milestoneProject;
    CCMI__Milestone_Task__c milestoneProjectTask1 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask1;
    CCMI__Milestone_Task__c milestoneProjectTask2 = new CCMI__Milestone_Task__c(
      CCMI__Milestone_Project__c = milestoneProject.id,
      CCMI__Desired_Start__c = system.today(),
      CCMI__Duration__c = 1
    );
    insert milestoneProjectTask2;

    Assignment__c assignment1 = new Assignment__c(
      Project_Task__c = milestoneProjectTask1.id
    );
    insert assignment1;

    newGanttChart.saveAllocation(
      assignment1.id,
      milestoneProjectTask1.id,
      UserInfo.getUserId(),
      'test',
      '2',
      'active',
      '1',
      '2'
    );

    newGanttChart.deleteAllocation(milestoneProjectTask2.id);

    //CCMI__Milestone_Task__c projTask = new CCMI__Milestone_Task__c();
    CCMI__Milestone_Task__c[] projTask = [
      SELECT
        Name,
        CCMI__Status__c,
        Project_Area__c,
        BORIS_job__c,
        CCMI__Assignments__c
      FROM CCMI__Milestone_Task__c
      WHERE Id = :milestoneProjectTask2.id
    ];

    System.debug('Project -> ' + projTask.size());

    // Assert
    System.assertEquals(0, projTask.size());
  }

  @isTest
  static void testTeamResources() {
    // List<User> testUsers = new List<User>();
    // Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    // User u1 = new User(
    //   Alias = 'standt1',
    //   Email = 'ciususer1@testorg.com',
    //   EmailEncodingKey = 'UTF-8',
    //   LastName = 'Testing',
    //   LanguageLocaleKey = 'en_US',
    //   LocaleSidKey = 'en_GB',
    //   ProfileId = p.Id,
    //   Project_Resource__c = true,
    //   IsActive = true,
    //   TimeZoneSidKey = 'Europe/London',
    //   UserName = 'ciususer1@testorg.com'
    // );
    // testUsers.add(u1);

    // User u2 = new User(
    //   Alias = 'standt2',
    //   Email = 'ciususer2@testorg.com',
    //   EmailEncodingKey = 'UTF-8',
    //   LastName = 'Testing',
    //   LanguageLocaleKey = 'en_US',
    //   LocaleSidKey = 'en_GB',
    //   ProfileId = p.Id,
    //   Project_Resource__c = true,
    //   IsActive = true,
    //   TimeZoneSidKey = 'Europe/London',
    //   UserName = 'ciususer2@testorg.com'
    // );
    // testUsers.add(u2);

    // insert testUsers;

    // List<User> usrList = [SELECT Id, Name FROM User WHERE LastName = 'R3'];
    // system.debug('User List >>>> ' + usrList);
    Team__c newTeam = new Team__c();
    // newTeam.Primary_User__c = '0054J000000thP4';
    // newTeam.Team_Member_1__c = '0054J000000thP5';
    insert newTeam;

    List<Team__c> usrArray = [SELECT Id FROM Team__c LIMIT 1];
    Test.startTest();
    List<String> userIds = newGanttChart.getTeamResources(usrArray[0].Id);
    Test.stopTest();
    system.debug(userIds.size());
    System.assert(userIds.size() > 0);
  }
}
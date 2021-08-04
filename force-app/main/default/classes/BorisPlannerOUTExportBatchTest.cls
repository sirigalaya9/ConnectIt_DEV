/**
 * @description       :
 * @author            :
 * @group             :
 * @last modified on  : 05-02-2021
 * @last modified by  : Jonny Harte
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   05-02-2021   Jonny Harte   Initial Version
 **/
@isTest
public class BorisPlannerOUTExportBatchTest {
  @testSetup
  static void setup() {
    List<User> usersList = new List<User>();
    List<CCMI__Milestone_Task__c> tasksList = new List<CCMI__Milestone_Task__c>();
    //List<CCMI__Milestone_Assignment2__c> assignmentsList = new List<CCMI__Milestone_Assignment2__c>();
    List<Assignment__c> assignmentsList = new List<Assignment__c>();
    Id site1Id = SiteTestDataFactory.create();
    Id project1Id = ProjectTestDataFactory.create(site1Id);

    // create materials request
    Order_Request__c ordReq = new Order_Request__c();
    ordReq.Delivery_To_Site_Date__c = system.today();
    ordReq.Project_Job__c = project1Id;
    insert ordReq;

    CCMI__Milestone_Project__c project = new CCMI__Milestone_Project__c();
    project.Id = project1Id;
    project.Materials_Request__c = ordReq.Id;
    update project;

    tasksList.add(
      TaskTestDataFactory.createBORISJobTask(
        project1Id,
        Date.newInstance(2020, 8, 1),
        null,
        null,
        1400
      )
    );

    // Add Boris Codes to Task
    tasksList[0].Boris_Codes__c = '00000';
    update tasksList[0];

    tasksList.add(
      TaskTestDataFactory.createBORISJobTask(
        project1Id,
        Date.newInstance(2020, 8, 10),
        null,
        null,
        120
      )
    );
    // Add Boris Codes to Task
    tasksList[1].Boris_Codes__c = '11111';
    update tasksList[0];

    tasksList.add(
      TaskTestDataFactory.createBORISJobTask(
        project1Id,
        Date.newInstance(2020, 8, 15),
        null,
        null,
        120
      )
    );
    // Add Boris Codes to Task
    tasksList[2].Boris_Codes__c = '22222';
    update tasksList[0];
    tasksList.add(
      TaskTestDataFactory.createBORISJobTask(
        project1Id,
        Date.newInstance(2020, 8, 16),
        Time.newInstance(9, 15, 0, 0), // this time should be kept in the BPO start date.
        Time.newInstance(13, 13, 13, 0), // this time should be kept in the BPO end date.
        120
      )
    );
    // Add Boris Codes to Task
    tasksList[3].Boris_Codes__c = '33333';
    update tasksList[0];
    tasksList.add(
      TaskTestDataFactory.createBORISJobTask(
        project1Id,
        Date.newInstance(2020, 12, 22), // we'll exclude this one from the batch from/to dates.
        null,
        null,
        120
      )
    );
    // Add Boris Codes to Task
    tasksList[4].Boris_Codes__c = '44444';
    update tasksList[0];

    // get users
    User user1 = UserTestDataFactory.createUser(
      'testUser1@email.com',
      'lastname',
      'System Administrator'
    );
    User user2 = UserTestDataFactory.createUser(
      'testUser2@email.com',
      'lastname',
      'System Administrator'
    );
    User user3 = UserTestDataFactory.createUser(
      'testUser3@email.com',
      'lastname',
      'System Administrator'
    );

    // setup assignments:
    // task[0]: user1 + user2
    // task[1]: user1
    // task[2]: user2
    // task[3]: user3
    // task[4]: user3

    assignmentsList.add(
      AssignmentTestDataFactory.create(user1.Id, tasksList[0].Id)
    );

    assignmentsList.add(
      AssignmentTestDataFactory.create(user2.Id, tasksList[0].Id)
    );

    assignmentsList.add(
      AssignmentTestDataFactory.create(user1.Id, tasksList[1].Id)
    );

    assignmentsList.add(
      AssignmentTestDataFactory.create(user2.Id, tasksList[2].Id)
    );

    assignmentsList.add(
      AssignmentTestDataFactory.create(user3.Id, tasksList[3].Id)
    );

    assignmentsList.add(
      AssignmentTestDataFactory.create(user3.Id, tasksList[4].Id)
    );
  }

  @isTest
  public static void testBatch() {
    User user1 = [SELECT Id FROM User WHERE Email = 'testUser1@email.com'];
    User user2 = [SELECT Id FROM User WHERE Email = 'testUser2@email.com'];
    User user3 = [SELECT Id FROM User WHERE Email = 'testUser3@email.com'];
    Account site = [
      SELECT Id, Name
      FROM Account
      WHERE RecordTypeId = :AccountUtil.getSiteAccountRecordTypeId
      LIMIT 1
    ];
    CCMI__Milestone_Project__c project = [
      SELECT Id
      FROM CCMI__Milestone_Project__c
      WHERE Site__c = :site.Id
      LIMIT 1
    ];

    // insert project id in filter
    String filterStr =
      '{"disabled":false,"message":"","projects":[{"id":"' +
      project.Id +
      '","name":"Peter Test 9 Nov 2020"}],"resources":[{"id":"","name":"testUser1@email.com"}],"roles":[{"id":"","name":"name1"}],"status":[],"type":[],"area":[],"projManager":[{"id":"","name":""}],"accounts":[{"id":"","name":""}],"projectOptions":[],"resourceOptions":[],"roleOptions":[],"statusOptions":[{"label":"--All--","value":""},{"attributes":null,"label":"Not Started","validFor":[],"value":"Not Started"},{"attributes":null,"label":"In Progress","validFor":[],"value":"In Progress"},{"attributes":null,"label":"Wayleaves Progress Up to POC","validFor":[],"value":"Wayleaves Progress Up to POC"},{"attributes":null,"label":"Awaiting Customer Call Back","validFor":[],"value":"Awaiting Customer Call Back"},{"attributes":null,"label":"On-hold","validFor":[],"value":"On-hold"},{"attributes":null,"label":"Wayleaves On Hold","validFor":[],"value":"Wayleaves On Hold"},{"attributes":null,"label":"On Planner","validFor":[],"value":"On Planner"},{"attributes":null,"label":"Cancelled","validFor":[],"value":"Cancelled"},{"attributes":null,"label":"Completed","validFor":[],"value":"Completed"}],"typeOptions":[{"label":"--All--","value":""},{"attributes":null,"label":"Charge Points","validFor":[],"value":"Charge Points"},{"attributes":null,"label":"Electric","validFor":[],"value":"Electric"},{"attributes":null,"label":"Gas","validFor":[],"value":"Gas"},{"attributes":null,"label":"MU","validFor":[],"value":"MU"},{"attributes":null,"label":"Street Lighting","validFor":[],"value":"Street Lighting"},{"attributes":null,"label":"Water","validFor":[],"value":"Water"},{"attributes":null,"label":"Dual Fuel","validFor":[],"value":"Dual Fuel"},{"attributes":null,"label":"Self-Lay Mains","validFor":[],"value":"Self-Lay Mains"},{"attributes":null,"label":"Temporary Building Supply","validFor":[],"value":"Temporary Building Supply"},{"attributes":null,"label":"SSE Connections","validFor":[],"value":"SSE Connections"},{"attributes":null,"label":"SSEN Minor Works","validFor":[],"value":"SSEN Minor Works"},{"attributes":null,"label":"SSEN Service Alterations","validFor":[],"value":"SSEN Service Alterations"}],"areaOptions":[{"label":"--All--","value":""},{"attributes":null,"label":"SSEN Connections","validFor":[],"value":"SSEN Connections"},{"attributes":null,"label":"SSEN Minor Works","validFor":[],"value":"SSEN Minor Works"},{"attributes":null,"label":"SSEN Service Alterations","validFor":[],"value":"SSEN Service Alterations"},{"attributes":null,"label":"SSE Depots","validFor":[],"value":"SSE Depots"},{"attributes":null,"label":"NON SSEN","validFor":[],"value":"NON SSEN"},{"attributes":null,"label":"Civils / Excavation","validFor":[],"value":"Civils / Excavation"},{"attributes":null,"label":"OHL","validFor":[],"value":"OHL"},{"attributes":null,"label":"Jointing","validFor":[],"value":"Jointing"},{"attributes":null,"label":"PM’s","validFor":[],"value":"PM’s"},{"attributes":null,"label":"Auditors","validFor":[],"value":"Auditors"},{"attributes":null,"label":"Surveyors","validFor":[],"value":"Surveyors"},{"attributes":null,"label":"Holiday / Not Available","validFor":[],"value":"Holiday / Not Available"},{"attributes":null,"label":"Sick","validFor":[],"value":"Sick"},{"attributes":null,"label":"Furlough","validFor":[],"value":"Furlough"}]}';

    Date dateFrom = Date.newInstance(2020, 8, 1);
    Date dateTo = Date.newInstance(2020, 8, 16);

    Test.startTest();
    BorisPlannerOUTExportBatch b = new BorisPlannerOUTExportBatch(
      Date.valueOf(dateFrom),
      Date.valueOf(dateTo),
      filterStr
    );
    Id batchProcessId = Database.ExecuteBatch(b, 100);
    //BorisPlannerOUTExportBatch b2 = new BorisPlannerOUTExportBatch(Date.valueOf(dateFrom), Date.valueOf(dateTo), filterStr2);
    //Id batchProcessId2 = Database.ExecuteBatch(b, 100);
    Test.stopTest();

    List<BORIS_Planner_OUT__c> bpoListUser1 = [
      SELECT
        Id,
        UserId__c,
        Project_Id__c,
        Site__c,
        Start_Date__c,
        End_Date__c,
        BORIS_Codes__c,
        Material_Request_Id__c,
        Project_Task__c
      FROM BORIS_Planner_OUT__c
      WHERE UserId__c = :user1.Id
    ];
    List<BORIS_Planner_OUT__c> bpoListUser2 = [
      SELECT
        Id,
        UserId__c,
        Project_Id__c,
        Site__c,
        Start_Date__c,
        End_Date__c,
        BORIS_Codes__c,
        Material_Request_Id__c
      FROM BORIS_Planner_OUT__c
      WHERE UserId__c = :user2.Id
    ];
    List<BORIS_Planner_OUT__c> bpoListUser3 = [
      SELECT
        Id,
        UserId__c,
        Project_Id__c,
        Site__c,
        Start_Date__c,
        End_Date__c,
        BORIS_Codes__c,
        Material_Request_Id__c
      FROM BORIS_Planner_OUT__c
      WHERE UserId__c = :user3.Id
    ];

    System.assertEquals(2, bpoListUser1.size());
    System.assertEquals(2, bpoListUser2.size());
    System.assertEquals(1, bpoListUser3.size());
    System.assertEquals(project.Id, bpoListUser1[0].Project_Id__c);
    System.assertEquals(site.Name, bpoListUser1[0].Site__c);

    // TEST: task.Start_Time__c (or 07:30 if none) should be used for bpo.Start_Date__c
    System.assertEquals(
      Time.newInstance(9, 15, 0, 0),
      bpoListUser3[0].Start_Date__c.timeGMT()
    );
    System.assertEquals(
      Time.newInstance(7, 30, 0, 0),
      bpoListUser1[0].Start_Date__c.timeGMT()
    );

    // TEST: task.End_Time__c (or 16:30 if none) should be used for bpo.End_Date__c
    System.assertEquals(
      Time.newInstance(13, 13, 13, 0),
      bpoListUser3[0].End_Date__c.timeGMT()
    );
    System.assertEquals(
      Time.newInstance(16, 30, 0, 0),
      bpoListUser1[0].End_Date__c.timeGMT()
    );

    // TEST: BORIS Field Values are copied across and are not null
    System.assertEquals('00000', bpoListUser1[0].BORIS_Codes__c);

    System.assertNotEquals(null, bpoListUser1[0].Project_Task__c);

    // check that Sent to BORIS indicator is set
    List<CCMI__Milestone_Task__c> tasks = [
      SELECT
        Id,
        Sent_To_BORIS__c,
        Name,
        Start__c,
        CCMI__Start__c,
        CCMI__Desired_Start__c,
        End__c,
        CCMI__End__c,
        CCMI__Duration__c,
        CCMI__Calculated_Duration__c,
        CCMI__Completed_Date__c,
        CCMI__Parent_End__c
      FROM CCMI__Milestone_Task__c
      ORDER BY Id ASC
    ];

    // Test
    System.assertEquals(tasks[0].Name, bpoListUser1[0].Material_Request_Id__c);
  }
}
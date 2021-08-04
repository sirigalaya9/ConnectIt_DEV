/**
 * @description       :
 * @author            : Jonny Harte
 * @group             :
 * @last modified on  : 03-02-2021
 * @last modified by  : Jonny Harte
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   03-02-2021   Jonny Harte   Initial Version
 **/
@isTest
public with sharing class r3ProductKitScheduler_Test {
  static testMethod void r3ProductKitSchedulerVerifyTest() {
    Test.startTest();

    // Schedule the test job
    String jobId = System.schedule(
      'Product Kit Scheduler Test',
      '0 0 0 15 3 ? 2022',
      new r3ProductKitScheduler()
    );

    Test.stopTest();

    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];

    // Verify the expressions are the same
    System.assertEquals(
      '0 0 0 15 3 ? 2022',
      ct.CronExpression,
      'Cron Expression isn\'t the same'
    );

    // Verify the next time the job will run
    System.assertEquals(
      '2022-03-15 00:00:00',
      String.valueOf(ct.NextFireTime),
      'Job isn\'t set to run at the correct time'
    );
  }
}
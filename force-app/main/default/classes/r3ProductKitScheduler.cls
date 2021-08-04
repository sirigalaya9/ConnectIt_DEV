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
global without sharing class r3ProductKitScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    r3ProductKitProcessor b = new r3ProductKitProcessor();
    database.executebatch(b);
  }
}
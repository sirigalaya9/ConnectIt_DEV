@isTest
private class CaptureLastViewedMaterialsRequestCtrlTst {
  @testSetup
  static void setupTestData(){
    test.startTest();
    Order_Request__c obj = new Order_Request__c(Delivery_To_Site_Date__c = system.today());
    Insert obj; 
    test.stopTest();
  }
  static testMethod void test_captureMatReqId_UseCase1(){
    List<Order_Request__c> mrs  =  [SELECT Id,Name from Order_Request__c];
    System.assertEquals(true,mrs.size()>0);
    CaptureLastViewedMaterialsRequestCtrl obj01 = new CaptureLastViewedMaterialsRequestCtrl();
    CaptureLastViewedMaterialsRequestCtrl.captureMatReqId('test data');
  }
}
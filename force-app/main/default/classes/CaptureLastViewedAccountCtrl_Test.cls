@isTest
private class CaptureLastViewedAccountCtrl_Test{
  @testSetup
  static void setupTestData(){
    test.startTest();
    Account account_Obj = new Account(Name = 'Name836');
    Insert account_Obj; 
    test.stopTest();
  }
  static testMethod void test_captureAccId_UseCase1(){
    List<Account> account_Obj  =  [SELECT Id,Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    CaptureLastViewedAccountCtrl obj01 = new CaptureLastViewedAccountCtrl();
    CaptureLastViewedAccountCtrl.captureAccId('test data');
  }
}
@isTest
private class UsersListController_Test{
  @testSetup
  static void setupTestData(){
    test.startTest();
    User user_Obj = new User(Username = 'TestUser1126720200413121124@codecoverage.com', LastName = 'LastName887', Email = 'Email24@test.com', EmailPreferencesAutoBcc = false, EmailPreferencesAutoBccStayInTouch = false, EmailPreferencesStayInTouchReminder = false, Alias = 'Alias272', CommunityNickname = 'cNickName73176', IsActive = true, TimeZoneSidKey = 'Pacific/Kiritimati', LocaleSidKey = 'sq_AL', ReceivesInfoEmails = false, ReceivesAdminInfoEmails = false, EmailEncodingKey = 'UTF-8', ProfileId = '00e4J000000IiwiQAC', LanguageLocaleKey = 'en_US', UserPermissionsMarketingUser = false, UserPermissionsOfflineUser = false, UserPermissionsAvantgoUser = false, UserPermissionsCallCenterAutoLogin = false, UserPermissionsMobileUser = false, UserPermissionsSFContentUser = false, UserPermissionsKnowledgeUser = false, UserPermissionsInteractionUser = false, UserPermissionsSupportUser = false, ForecastEnabled = false, UserPreferencesActivityRemindersPopup = false, UserPreferencesEventRemindersCheckboxDefault = false, UserPreferencesTaskRemindersCheckboxDefault = false, UserPreferencesReminderSoundOff = false, UserPreferencesDisableAllFeedsEmail = false);
    Insert user_Obj; 
    test.stopTest();
  }
  static testMethod void test_getUsers_UseCase1(){
    List<User> user_Obj  =  [SELECT Username,LastName,Email,EmailPreferencesAutoBcc,EmailPreferencesAutoBccStayInTouch,EmailPreferencesStayInTouchReminder,Alias,CommunityNickname,IsActive,TimeZoneSidKey,LocaleSidKey,ReceivesInfoEmails,ReceivesAdminInfoEmails,EmailEncodingKey,ProfileId,LanguageLocaleKey,UserPermissionsMarketingUser,UserPermissionsOfflineUser,UserPermissionsAvantgoUser,UserPermissionsCallCenterAutoLogin,UserPermissionsMobileUser,UserPermissionsSFContentUser,UserPermissionsKnowledgeUser,UserPermissionsInteractionUser,UserPermissionsSupportUser,ForecastEnabled,UserPreferencesActivityRemindersPopup,UserPreferencesEventRemindersCheckboxDefault,UserPreferencesTaskRemindersCheckboxDefault,UserPreferencesReminderSoundOff,UserPreferencesDisableAllFeedsEmail from User];
    System.assertEquals(true,user_Obj.size()>0);
    UsersListController obj01 = new UsersListController();
    obj01.getUsers();
  }
}
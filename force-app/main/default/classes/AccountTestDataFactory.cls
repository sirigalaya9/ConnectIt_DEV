@isTest
public class AccountTestDataFactory {
    public static Id create() {
        Account account = new Account();
        account.Name = 'Test';
        account.RecordTypeId = AccountUtil.getStandardAccountRecordTypeId;
        account.Type = 'Customer';
        insert account;
        return account.Id;
    }
}
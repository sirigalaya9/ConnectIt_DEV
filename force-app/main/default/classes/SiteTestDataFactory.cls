@isTest
public class SiteTestDataFactory {
    public static Id create() {
        Account site = new Account();
        site.Name = 'Test Site';
        site.RecordTypeId = AccountUtil.getSiteAccountRecordTypeId;
        insert site;
        return site.Id;
    }

    public static Id create(Id accountId) {
        Account site = new Account();
        site.Name = 'Test Site';
        site.RecordTypeId = AccountUtil.getSiteAccountRecordTypeId;
        site.Customer_Account__c = accountId;
        insert site;
        return site.Id;
    }
}
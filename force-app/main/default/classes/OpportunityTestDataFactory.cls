@isTest
public class OpportunityTestDataFactory {
    public static Id create(Id accountId, Id siteId) {
        Opportunity o = new Opportunity();
        o.Name = 'Test Opportunity';
        o.AccountId = accountId;
        o.CloseDate = Date.today();
        o.Amount = 1;
        o.Site__c = siteId;
        o.StageName = 'Enquiry';
        insert o;
        return o.Id;
    }
}
@isTest
public class EstimateChecklistTestDataFactory {
    public static Id create(Id opportunityId, String area) {
        Estimate_Checklist__c record = new Estimate_Checklist__c(Estimate__c = opportunityId, Responsibility__c = 'CIUS', Area__c = area);
        insert record;
        return record.Id;
    }
}
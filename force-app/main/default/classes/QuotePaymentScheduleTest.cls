@isTest
public class QuotePaymentScheduleTest {
    @TestSetup
    static void setupData()
    {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Enquiry';
        opp.CloseDate = System.today();
        insert opp;
    }

    @isTest
    static void testGet()
    {
        List<Estimate_Client_Payment_Schedule__c> results = QuotePaymentScheduleController.getItems(null);
        System.assertEquals(0, results.size(), 'No result should be returned');        
    }

    @isTest
    static void testCreate()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        List<Estimate_Client_Payment_Schedule__c> items = new List<Estimate_Client_Payment_Schedule__c>();
        Estimate_Client_Payment_Schedule__c item = new Estimate_Client_Payment_Schedule__c();
        item.Estimate__c = opp.Id;
        items.add(item);
        List<Estimate_Client_Payment_Schedule__c> results = QuotePaymentScheduleController.saveItems(opp.Id, items, new List<Id>());
        System.assertEquals(1, results.size(), '1 result should be returned');        
    }    

    @isTest
    static void testUpdate()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        List<Estimate_Client_Payment_Schedule__c> items = new List<Estimate_Client_Payment_Schedule__c>();
        Estimate_Client_Payment_Schedule__c item = new Estimate_Client_Payment_Schedule__c();
        item.Estimate__c = opp.Id;
        insert item;
        items.add(item);
        List<Estimate_Client_Payment_Schedule__c> results = QuotePaymentScheduleController.saveItems(opp.Id, items, new List<Id>());
        System.assertEquals(1, results.size(), '1 result should be returned');        
    } 
    
    @isTest
    static void testDelete()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        List<Estimate_Client_Payment_Schedule__c> items = new List<Estimate_Client_Payment_Schedule__c>();
        Estimate_Client_Payment_Schedule__c item = new Estimate_Client_Payment_Schedule__c();
        item.Estimate__c = opp.Id;
        insert item;
        List<Id> idsToDelete = new List<Id>();
        idsToDelete.add(item.Id);
        List<Estimate_Client_Payment_Schedule__c> results = QuotePaymentScheduleController.saveItems(opp.Id, new List<Estimate_Client_Payment_Schedule__c>(), idsToDelete);
        System.assertEquals(0, results.size(), '0 result should be returned');        
    }     
}
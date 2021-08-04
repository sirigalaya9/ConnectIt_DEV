@isTest
public with sharing class QuoteChecklistTest {
    
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
        List<Estimate_Checklist__c> results = QuoteChecklistController.getItems(null);
        System.assertEquals(0, results.size(), 'No result should be returned');        
    }

    @isTest
    static void testCreate()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        List<Estimate_Checklist__c> items = new List<Estimate_Checklist__c>();
        Estimate_Checklist__c item = new Estimate_Checklist__c();
        item.Estimate__c = opp.Id;
        items.add(item);
        List<Estimate_Checklist__c> results = QuoteChecklistController.saveItems(opp.Id, items, new List<Id>());
        System.assertEquals(1, results.size(), '1 result should be returned');        
    }    

    @isTest
    static void testUpdate()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        List<Estimate_Checklist__c> items = new List<Estimate_Checklist__c>();
        Estimate_Checklist__c item = new Estimate_Checklist__c();
        item.Estimate__c = opp.Id;
        insert item;
        items.add(item);
        List<Estimate_Checklist__c> results = QuoteChecklistController.saveItems(opp.Id, items, new List<Id>());
        System.assertEquals(1, results.size(), '1 result should be returned');        
    } 
    
    @isTest
    static void testDelete()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        List<Estimate_Checklist__c> items = new List<Estimate_Checklist__c>();
        Estimate_Checklist__c item = new Estimate_Checklist__c();
        item.Estimate__c = opp.Id;
        insert item;
        List<Id> idsToDelete = new List<Id>();
        idsToDelete.add(item.Id);
        List<Estimate_Checklist__c> results = QuoteChecklistController.saveItems(opp.Id, new List<Estimate_Checklist__c>(), idsToDelete);
        System.assertEquals(0, results.size(), '0 result should be returned');        
    }     
    
}
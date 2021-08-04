public with sharing class QuoteChecklistController 
{
    @AuraEnabled
    public static List<Estimate_Checklist__c> getItems(Id recordId)
    {
        List<Estimate_Checklist__c> checklists = [SELECT Name, Area__c, Title__c, Responsibility__c FROM Estimate_Checklist__c WHERE Estimate__c = :recordId ORDER BY CreatedDate ASC];        
        if (checklists.size() == 0)
        {
            checklists = new List<Estimate_Checklist__c>();
            List<Estimate_Checklist_Template__c> templates = [SELECT Area__c, Title__c, Responsibility__c FROM Estimate_Checklist_Template__c ORDER BY Sort_Order__c DESC];
            for (Estimate_Checklist_Template__c template : templates)
            {
                Estimate_Checklist__c checklist = new Estimate_Checklist__c();
                checklist.Area__c = template.Area__c;
                checklist.Title__c = template.Title__c;
                checklist.Responsibility__c = template.Responsibility__c;
                checklists.add(checklist);
            }
        }
        return checklists;
    }

    @AuraEnabled
    public static List<Estimate_Checklist__c> saveItems(String recordId, List<Estimate_Checklist__c> items, List<Id> idsToDelete)
    {
        List<Estimate_Checklist__c> itemsToInsert = new List<Estimate_Checklist__c>();
        List<Estimate_Checklist__c> itemsToUpdate = new List<Estimate_Checklist__c>();        
        List<Estimate_Checklist__c> itemsToDelete = new List<Estimate_Checklist__c>();

        for (Estimate_Checklist__c item : items)
        {
            String id = (String) item.Id;
            if (id instanceof Id)
            {                
                itemsToUpdate.add(item);
            }
            else
            {
                item.Id = null;
                item.Estimate__c = recordId;                
                itemsToInsert.add(item);                
            }
        }
        for (String id : idsToDelete)
        {
            if (id instanceof Id)
            {
                Estimate_Checklist__c item = new Estimate_Checklist__c(Id = id);
                itemsToDelete.add(item);
            }
        }            

        insert itemsToInsert;
        update itemsToUpdate;        
        delete itemsToDelete;

        return getItems(recordId);
    }    
}
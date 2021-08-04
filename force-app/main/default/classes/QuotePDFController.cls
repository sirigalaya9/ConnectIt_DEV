public with sharing class QuotePDFController {
    
    @AuraEnabled
    public static String generatePDF(Id recordId) {

        Map<String, Object> mergeData = new Map<String, Object>{};

        SObjectType sobjType = ((SObject)(Type.forName('Schema.Opportunity').newInstance())).getSObjectType();        
        Map<String,Schema.SObjectField> fields = sobjType.getDescribe().fields.getMap();

        String query = 'SELECT Id, Name, Account.Name, Site__r.Name, Site__r.BillingStreet, Site__r.BillingCity, Site__r.BillingPostalCode';
        query += ', Type, Owner.Name, Owner.Title, Owner.FirstName, Owner.LastName, CreatedDate, CloseDate, Owner.Phone, Owner.Email';
        for (String fieldName : fields.keySet())
        {
            Schema.SObjectField field = fields.get(fieldName);
            if (field.getDescribe().isCustom())
                query += ', ' + fieldName;
        }

        query += ' FROM Opportunity WHERE Id = :recordId';

        List<Estimate_Checklist__c> checklists = [SELECT Area__c, Title__c, Responsibility__c 
        FROM Estimate_Checklist__c 
        WHERE Estimate__c = :recordId AND Responsibility__c != 'Exclude' AND Area__c != NULL];
        
        for (Estimate_Checklist__c checklist : checklists)
        {
            String key = 'checklist_' + checklist.Area__c.toLowerCase();
            if (!mergeData.containsKey(key))
            {                
                mergeData.put(key, new List<Estimate_Checklist__c>());
            }
            ((List<Estimate_Checklist__c>)mergeData.get(key)).add(checklist);
        }

        List<Site_Scheme__c> schemes = [SELECT No_of_Houses__c, RecordType.Name FROM Site_Scheme__c WHERE Estimate__c = :recordId ORDER BY CreatedDate DESC];
        for (Site_Scheme__c scheme : schemes)
        {
            String key = 'scheme_' + scheme.RecordType.Name.toLowerCase();
            if (!mergeData.containsKey(key))
            {                
                mergeData.put(key, scheme);                
            }            
        }      

        List<Estimate_Client_Payment_Schedule__c> schedules = [SELECT Trigger__c, Payment__c FROM Estimate_Client_Payment_Schedule__c WHERE Estimate__c = :recordId ORDER BY CreatedDate ASC];
        mergeData.put('payment_schedule', schedules);        

        sObject opp = Database.query(query);

        mergeData.put('Opportunity', opp);

        String json = System.JSON.serialize(mergeData);

        /*
        HttpResponse response = webm.WebmergeGenerator.doMerge(
            json, 
            'https://www.webmerge.me/merge/785245/d5ehbv?test=1&download=1'
        );

        System.debug(response);

        System.debug(response.getBody());

        System.debug(response.getBodyAsBlob());

        return EncodingUtil.base64Encode(response.getBodyAsBlob());
        */
        
        return json;
    }
}
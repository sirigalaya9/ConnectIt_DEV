public class opportunityControllercustomExtension
{
    private final Opportunity theopp;
    public Opportunity opp {get; set;}
    public Account oppSite {get; set;}
    public List<Site_Scheme__c> siteElectricScheme {get; set;}
    public List<Site_Scheme__c> siteGasScheme {get; set;}
    public List<Site_Scheme__c> siteChargerPointScheme {get; set;}
   
    public List<Estimate_Client_Payment_Schedule__c> paymentSchedule {get; set;}
    public List<Estimate_Checklist__c> oppCheckListResponsibilites {get; set;}
    public List<Estimate_Checklist__c> oppCheckListGas {get; set;}
    public List<Estimate_Checklist__c> oppCheckListWater {get; set;}
    public List<Estimate_Checklist__c> oppCheckListElectricity {get; set;}
    
    public List<String> fileUrlElectricity {get; set;}
    public List<String> fileUrlGas {get; set;}
    public List<String> fileUrlWater {get; set;}
    public List<String> fileUrlStreetLighting {get; set;}
    public List<String> fileUrlChargerPoints {get; set;}
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public opportunityControllercustomExtension(ApexPages.StandardController stdController) 
    {
        String obj;
        String query;
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        system.debug('CAS>>> Map = '+SiteSchemeRecordTypeInfo);
        this.theopp = (Opportunity)stdController.getRecord();
        
        // get addition fields from opp
        opp = [SELECT Id, Site__c, Job_Number__c, Estimate_Hold_Notes__c, Version__c  FROM Opportunity WHERE Id = :theopp.id LIMIT 1];       
        
         
        // get payment schedule details...
        obj = 'Estimate_Client_Payment_Schedule__c';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Estimate__c = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        paymentSchedule = database.query(query);

        // get site details...
        obj = 'Account';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Id = \'' + opp.Site__c + '\' LIMIT 1';
        system.debug('CAS>>> Query = '+query);
        oppSite = database.query(query);
        
        // get site electricity scheme...
        obj = 'Site_Scheme__c';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE RecordTypeId = \'' + SiteSchemeRecordTypeInfo.get('Electric').getRecordTypeId() + '\' AND Estimate__c = \'' + theopp.Id +'\'';
        system.debug('CAS>>> Query = '+query);
        siteElectricScheme = database.query(query);
        
        // get site gas scheme...
        obj = 'Site_Scheme__c';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE RecordTypeId = \'' + SiteSchemeRecordTypeInfo.get('Gas').getRecordTypeId() + '\' AND Estimate__c = \'' + theopp.Id +'\'';
        system.debug('CAS>>> Query = '+query);
        siteGasScheme = database.query(query);
        
        // get site charger point scheme...
        obj = 'Site_Scheme__c';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE RecordTypeId = \'' + SiteSchemeRecordTypeInfo.get('Charger').getRecordTypeId() + '\' AND Estimate__c = \'' + theopp.Id +'\'';
        system.debug('CAS>>> Query = '+query);
        siteChargerPointScheme = database.query(query);

        // get estimate checklists...
        obj = 'Estimate_Checklist__c';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Estimate__c = \'' + theopp.Id +'\' AND Responsibility__c != Null AND Responsibility__c != \'Exclude\'';
        system.debug('CAS>>> Query = '+query);
        List<Estimate_Checklist__c> chkLst = database.query(query);
        oppCheckListElectricity = new List<Estimate_Checklist__c>();
        oppCheckListWater = new List<Estimate_Checklist__c>();
        oppCheckListGas = new List<Estimate_Checklist__c>();
        oppCheckListResponsibilites = new List<Estimate_Checklist__c>();
        for(Estimate_Checklist__c chk: chkLst)
        {
            switch on chk.Area__c 
            {
                when 'Electricity' 
                {   
                    oppCheckListElectricity.add(chk);
                }   
                when 'Water' 
                {   
                    oppCheckListWater.add(chk);
                }
                when 'Gas' 
                {   
                    oppCheckListGas.add(chk);
                }
                when 'Responsibilities' 
                {   
                    oppCheckListResponsibilites.add(chk);
                }
                when else 
                {
                    system.assert(TRUE, 'Invalid picklist value found! (Estimate_Checklist__c.Area__c = '+chk.Area__c+')');
                }
            }  
        }

        // get estimate files...
        List<ContentDocumentLink> fileLst = [SELECT ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Type__c FROM ContentDocumentLink WHERE LinkedEntityId = :theopp.Id];
        fileUrlElectricity = new List<String>();
        fileUrlGas = new List<String>();
        fileUrlWater = new List<String>();
        fileUrlStreetLighting = new List<String>();
        fileUrlChargerPoints = new List<String>();
        String urlStr = System.Url.getOrgDomainUrl().toExternalForm()+'/sfc/servlet.shepherd/version/download/';
        system.debug('CAS>>> urlStr = '+urlStr);
        for(ContentDocumentLink cdl: fileLst)
        {
            switch on cdl.ContentDocument.LatestPublishedVersion.Type__c 
            {
                when 'Estimate Electricity (quote)' 
                {   
                    fileUrlElectricity.add(urlStr+cdl.ContentDocument.LatestPublishedVersionId);
                }   
                when 'Estimate Gas (quote)' 
                {   
                    fileUrlGas.add(urlStr+cdl.ContentDocument.LatestPublishedVersionId);
                }
                when 'Estimate Water (quote)' 
                {   
                    fileUrlWater.add(urlStr+cdl.ContentDocument.LatestPublishedVersionId);
                }
                when 'Estimate Street Lighting (quote)' 
                {   
                    fileUrlStreetLighting.add(urlStr+cdl.ContentDocument.LatestPublishedVersionId);
                }
                when 'Estimate Charger Points (quote)' 
                {   
                    fileUrlChargerPoints.add(urlStr+cdl.ContentDocument.LatestPublishedVersionId);
                }
                when else 
                {
                    system.assert(TRUE, 'Invalid picklist value found! (ContentVersion.Type__c = '+cdl.ContentDocument.LatestPublishedVersion.Type__c+')');
                }
            }  
        }
        
        
    }
    
    
    private String getFieldList(String objectName)
    {
        String retStr = '';
        
        // get fields for object
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        // list them in string
        for(String s : objectFields.keySet()) 
           retStr += s + ',';
        
        // remove last comma
        if (retStr.subString(retStr.Length()-1,retStr.Length()) == ',')
            retStr = retStr.subString(0,retStr.Length()-1);
        
        return retStr;
    }
}
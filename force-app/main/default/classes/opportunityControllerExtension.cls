public class opportunityControllerExtension
{
    private final Opportunity theopp;
    public Opportunity opp {get; set;}
    public Account oppSite {get; set;}
    public List<Site_Scheme__c> siteElectricScheme {get; set;}
    public List<Site_Scheme__c> siteGasScheme {get; set;}
    public List<Site_Scheme__c> siteChargerPointScheme {get; set;}
    public List<OpportunityLineItem> nonContestableOLIs {get; set;}
    public List<opportunityLineItem> chargePointICPWorksOLIs {get; set;}  
    public List<opportunityLineItem> chargePointInstallOLIs {get; set;} 
        
    public List<opportunityLineItem> InstavoltSiteSetupOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltTravelOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltDNOICPWorksOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltDNOCivilsOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltOnsiteDNOOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltCivilsCostsBasesOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltCivilsCostsBuildOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltEVRapidChargerOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltFPInternalNONFCOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltFPInternalFCOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltDesParkBaysCOLIs {get; set;} 
    public List<opportunityLineItem> InstavoltAddScopeOLIs {get; set;}    
    public List<opportunityLineItem> InstavoltHVICPWorksOLIs {get; set;}  
    public List<opportunityLineItem> InstavoltHVSubstationInstallOLIs {get; set;}                          
    public List<opportunityLineItem> streetLightsOLIs {get; set;}
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
    public opportunityControllerExtension(ApexPages.StandardController stdController) 
    {
        String obj;
        String query;
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        system.debug('CAS>>> Map = '+SiteSchemeRecordTypeInfo);
        this.theopp = (Opportunity)stdController.getRecord();
        
        // get addition fields from opp
        opp = [SELECT Id, Site__c FROM Opportunity WHERE Id = :theopp.id LIMIT 1];       
        
        // get olis (non-contestable) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Non-Contestable\' AND Quantity__c > 0 AND OpportunityId = \'' + theopp.Id +'\'';
        system.debug('CAS>>> Query = '+query);
        nonContestableOLIs = database.query(query);
        
        // get olisChargePoints (charge point products ICP Works) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'ChargePoint\' AND Work_type__c = \'ICP Works\' AND Quantity__c > 0 AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        chargePointICPWorksOLIs = database.query(query);
        
        // get olisChargePoints (charge point products Charger Installation Costs) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'ChargePoint\' AND Work_type__c = \'Charger Installation Costs\' AND Quantity__c > 0 AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        chargePointInstallOLIs = database.query(query);
        
        
        // get olisInstavolt (Instavolt products Site Setup) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'Site Setup - Including Permits\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltSiteSetupOLIs = database.query(query);
        
        // get olisInstavolt (Instavolt products Travel & Accomodation) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'Travel and Accommodation Costs\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltTravelOLIs = database.query(query);
                
        // get olisInstavolt (Instavolt products DNO - ICP Works Only) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'DNO - ICP Works Only\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltDNOICPWorksOLIs = database.query(query);
                
        // get olisInstavolt (Instavolt products DNO Civils) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'DNO Civil Works\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltDNOCivilsOLIs = database.query(query);
        
        // get olisInstavolt (Instavolt products Onsite DNO Civils) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'On-Site DNO Civils Works\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltOnsiteDNOOLIs = database.query(query);
        
        // get olisInstavolt (Instavolt Civil Costs for Bases) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'Civil Costs for Bases\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltCivilsCostsBasesOLIs = database.query(query);
        
        // get olisInstavolt (Instavolt Civil Costs for Charger Build) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'Civil Costs for Charger Build\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltCivilsCostsBuildOLIs = database.query(query);
        
        // get olisInstavolt (Instavolt Ev Rapid Charging Unit) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'EV Rapid Charger Unit\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltEVRapidChargerOLIs = database.query(query);
        
        // get olisInstavolt (Instavolt Feeder Pillar - Internal Installation (NON FORECOURT SITE) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'Feeder Pillar - Internal Installation (NON FORECOURT SITE)\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltFPInternalNONFCOLIs = database.query(query);
        
        // get olisInstavolt (Instavolt Feeder Pillar - Internal Installation (FORECOURT ONLY SITE) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'Feeder Pillar - Internal Installation (FORECOURT ONLY SITE)\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltFPInternalFCOLIs = database.query(query);
        
        // get olisInstavolt (Instavolt Designated Parking Bays - Road Markings) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'Designated Parking Bays - Road Markings\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltDesParkBaysCOLIs = database.query(query);
        
         // get olisInstavolt (Instavolt Additional Scope of Works) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'Additional Scope Of Works\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltAddScopeOLIs = database.query(query);

         // get olisInstavolt (Instavolt HV ICP Costs) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'HV ICP Works\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltHVICPWorksOLIs = database.query(query);

         // get olisInstavolt (Instavolt HV Substation Installation Costs) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Instavolt\' AND Work_type__c = \'HV Substation Installation Costs\' AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        InstavoltHVSubstationInstallOLIs = database.query(query);      
        
        // get olisStreetLights (Street Lights products) details...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + getFieldList(obj) + ' FROM ' + obj + ' WHERE Product_Family__c = \'Street Lighting\' AND Quantity__c > 0 AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        streetLightsOLIs = database.query(query);
        
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
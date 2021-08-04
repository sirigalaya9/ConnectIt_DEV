public class quote_instavolt_controller 
{

    public String oppId;
    public Opportunity theOpp {get; set;}
    public List<opportunityLineItem> olis {get; set;}
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
    public Decimal InstavoltSiteSetupTotal {get; set;}
    public Decimal InstavoltTravelTotal {get; set;}
    public Decimal InstavoltDNOICPWorksTotal {get; set;}
    public Decimal InstavoltDNOCivilsTotal {get; set;}
    public Decimal InstavoltOnsiteDNOTotal {get; set;}
    public Decimal InstavoltCivilsCostsBasesTotal {get; set;}
    public Decimal InstavoltCivilsCostsBuildTotal {get; set;}
    public Decimal InstavoltEVRapidChargerTotal {get; set;}
    public Decimal InstavoltFPInternalNONFCTotal {get; set;}
    public Decimal InstavoltFPInternalFCTotal {get; set;}
    public Decimal InstavoltDesParkBaysCTotal {get; set;}
    public Decimal InstavoltAddScopeTotal {get; set;}
    public Decimal InstavoltHVICPWorksTotal {get; set;}
    public Decimal InstavoltHVSubstationInstallTotal {get; set;}
    public Decimal InstavoltEstimateTotal {get; set;}

    public quote_instavolt_controller() 
    {
        system.debug('CAS>>> quote_instavolt_controller(opportunityId = '+oppId+')');        
        // load(); called by the attribute setter function 'setOppId'.
    }
      
    public Id getOppId()
    {
        system.debug('CAS>>> quote_instavolt_controller.getOppId()');  
        return oppId;
    }

    public void setOppId(ID opportunityId)
    {
        system.debug('CAS>>> quote_quote_instavolt_controller.setOppId('+opportunityId+')');  
        oppId = opportunityId;
        load();
    }
    
    private void load()
    {
        system.debug('CAS>>> quote_instavolt_controller.load()');  
        if(oppId == null)
        {
          system.debug('CAS>>> oppId is null!');  
            return;  // abort if Id is not provided
        }
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        system.debug('CAS>>> Map = '+SiteSchemeRecordTypeInfo);

    InstavoltSiteSetupOLIs            = new List<opportunityLineItem>();
    InstavoltTravelOLIs               = new List<opportunityLineItem>();
    InstavoltDNOICPWorksOLIs          = new List<opportunityLineItem>();
    InstavoltDNOCivilsOLIs            = new List<opportunityLineItem>();
    InstavoltOnsiteDNOOLIs            = new List<opportunityLineItem>();
    InstavoltCivilsCostsBasesOLIs     = new List<opportunityLineItem>();
    InstavoltCivilsCostsBuildOLIs     = new List<opportunityLineItem>();
    InstavoltEVRapidChargerOLIs       = new List<opportunityLineItem>();
    InstavoltFPInternalNONFCOLIs      = new List<opportunityLineItem>();
    InstavoltFPInternalFCOLIs         = new List<opportunityLineItem>();
    InstavoltDesParkBaysCOLIs         = new List<opportunityLineItem>();
    InstavoltAddScopeOLIs             = new List<opportunityLineItem>();
    InstavoltHVICPWorksOLIs           = new List<opportunityLineItem>();
    InstavoltHVSubstationInstallOLIs  = new List<opportunityLineItem>();   

    InstavoltSiteSetupTotal           = 0;
    InstavoltTravelTotal              = 0;
    InstavoltDNOICPWorksTotal         = 0;
    InstavoltDNOCivilsTotal           = 0;
    InstavoltOnsiteDNOTotal           = 0;
    InstavoltCivilsCostsBasesTotal    = 0;
    InstavoltCivilsCostsBuildTotal    = 0;
    InstavoltEVRapidChargerTotal      = 0;
    InstavoltFPInternalNONFCTotal     = 0;
    InstavoltFPInternalFCTotal        = 0;
    InstavoltDesParkBaysCTotal        = 0;
    InstavoltAddScopeTotal            = 0;
    InstavoltHVICPWorksTotal          = 0;
    InstavoltHVSubstationInstallTotal = 0;
    InstavoltEstimateTotal            = 0;

       // get addition fields from opp
        String obj;
        String query;
        theOpp = [SELECT Id, Name, Site__c, Account.Name FROM Opportunity WHERE Id = :oppId LIMIT 1]; 
        
        if(theOpp == null)
            return;  // abort if Id is not provided (should never happen as it is a require field!)
        
        // get all Opportunity Line Items...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + quote_helper.getFieldList(obj) + ' FROM ' + obj + ' WHERE OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        olis = database.query(query);
    
     
        
        // Create totals for each section of Opportunity line items...
        for(OpportunityLineItem oli :olis)
        {
 
            InstavoltEstimateTotal += oli.Total_Sell_Rate__c;
        
            if(oli.work_type__c == 'Site Setup - Including Permits')
            {
                InstavoltSiteSetupOLIs.add(oli);
                InstavoltSiteSetupTotal += oli.Total_Sell_Rate__c;
            }
                   
            if(oli.work_type__c == 'Travel and Accommodation Costs')
            {
                InstavoltTravelOLIs.add(oli);
                InstavoltTravelTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'DNO - ICP Works Only')
            {
                InstavoltDNOICPWorksOLIs.add(oli);
                InstavoltDNOICPWorksTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'DNO Civil Works')
            {
                InstavoltDNOCivilsOLIs.add(oli);
                InstavoltDNOCivilsTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'On-Site DNO Civils Works')
            {
                InstavoltOnsiteDNOOLIs.add(oli);
                InstavoltOnsiteDNOTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'Civil Costs for Bases')
            {
                InstavoltCivilsCostsBasesOLIs.add(oli);
                InstavoltCivilsCostsBasesTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'Civil Costs for Charger Build')
            {
                InstavoltCivilsCostsBuildOLIs.add(oli);
                InstavoltCivilsCostsBuildTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'EV Rapid Charger Unit')
            {
                InstavoltEVRapidChargerOLIs.add(oli);
                InstavoltEVRapidChargerTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'Feeder Pillar - Internal Installation (NON FORECOURT SITE)')
            {
                InstavoltFPInternalNONFCOLIs.add(oli);
                InstavoltFPInternalNONFCTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'Feeder Pillar - Internal Installation (FORECOURT ONLY SITE)')
            {
                InstavoltFPInternalFCOLIs.add(oli);
                InstavoltFPInternalFCTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'Designated Parking Bays - Road Markings')
            {
                InstavoltDesParkBaysCOLIs.add(oli);
                InstavoltDesParkBaysCTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'Additional Scope Of Works')
            {
                InstavoltAddScopeOLIs.add(oli);
                InstavoltAddScopeTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'HV ICP Works')
            {
                InstavoltHVICPWorksOLIs.add(oli);
                InstavoltHVICPWorksTotal += oli.Total_Sell_Rate__c;
            }

            if(oli.work_type__c == 'HV Substation Installation Costs')
            {
                InstavoltHVSubstationInstallOLIs.add(oli);
                InstavoltHVSubstationInstallTotal += oli.Total_Sell_Rate__c;
            }

        }
    }
}
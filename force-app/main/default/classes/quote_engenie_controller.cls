public class quote_engenie_controller 
{
    public String oppId;
    public Opportunity theOpp {get; set;}
    public List<opportunityLineItem> olis {get; set;}
    public List<opportunityLineItem> EngenieSurveyDesignOLIs {get; set;}  
    public List<opportunityLineItem> EngenieDNOConnectionOLIs {get; set;} 
    public List<opportunityLineItem> EngenieInstallOLIs {get; set;} 
    public List<opportunityLineItem> EngenieTravelAccomOLIs {get; set;} 
    public Decimal EngenieSurveyDesignTotal {get; set;}
    public Decimal EngenieDNOConnectionTotal {get; set;}
    public Decimal EngenieInstallTotal {get; set;}
    public Decimal EngenieEstimateTotal {get; set;}
    public Decimal EngenieTravelAccomTotal {get; set;}
    
     public quote_engenie_controller()
      {
        system.debug('CAS>>> quote_engenie_controller (opportunityId = '+oppId+')');        
        // load(); called by the attribute setter function 'setOppId'.
    }
      
    public Id getOppId()
    {
        system.debug('CAS>>> quote_charge_point_controller.getOppId()');  
        return oppId;
    }

    public void setOppId(ID opportunityId)
    {
        system.debug('CAS>>> quote_engenie_controller.setOppId('+opportunityId+')');  
        oppId = opportunityId;
        load();
    }
    
    private void load()
    {
        system.debug('CAS>>> quote_engenie_controller.load()');  
        if(oppId == null)
        {
          system.debug('CAS>>> oppId is null!');  
            return;  // abort if Id is not provided
        }
        
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        system.debug('CAS>>> Map = '+SiteSchemeRecordTypeInfo);

        EngenieSurveyDesignOLIs = new List<opportunityLineItem>();
        EngenieDNOConnectionOLIs  = new List<opportunityLineItem>();
        EngenieInstallOLIs   = new List<opportunityLineItem>();
        EngenieTravelAccomOLIs   = new List<opportunityLineItem>();
        
        
        EngenieSurveyDesignTotal = 0;
        EngenieDNOConnectionTotal = 0;
        EngenieInstallTotal = 0;
        EngenieEstimateTotal = 0;
        EngenieTravelAccomTotal = 0;

       // get addition fields from opp
        String obj;
        String query;
        theOpp = [SELECT Id, Name, Site__c, Account.Name FROM Opportunity WHERE Id = :oppId LIMIT 1]; 
        
        if(theOpp == null)
            return;  // abort if Id is not provided (should never happen as it is a require field!)
        
        // get all Opportunity Line Items...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + quote_helper.getFieldList(obj) + ' FROM ' + obj + ' WHERE Quantity__c > 0 AND OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query = '+query);
        olis = database.query(query);
    
       
        // Create totals for each section of Opportunity line items...
        for(OpportunityLineItem oli :olis)
        {
          EngenieEstimateTotal += oli.Total_Sell_Rate__c;
 
            if(oli.work_type__c == 'DNO - ICP Works Only')
            {
                EngenieDNOConnectionOLIs.add(oli);
                EngenieDNOConnectionTotal += oli.Total_Sell_Rate__c;
             }
                   
            if(oli.work_type__c == 'Charger Installation Costs')
            {
                EngenieInstallOLIs.add(oli);
                EngenieInstallTotal += oli.Total_Sell_Rate__c;
            }
            
            if(oli.work_type__c == 'Survey and Produce Initial Design and Estimate')
            {
                EngenieSurveyDesignOLIs.add(oli);
                EngenieSurveyDesignTotal += oli.Total_Sell_Rate__c;
            }
            
            if(oli.work_type__c == 'Travel and Accommodation Costs')
            {
                EngenieTravelAccomOLIs.add(oli);
                EngenieTravelAccomTotal += oli.Total_Sell_Rate__c;
            }

        }
    }
}
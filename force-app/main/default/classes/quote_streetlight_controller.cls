public class quote_streetlight_controller 
{

    public String oppId;
    public Opportunity theOpp {get; set;}
    public List<opportunityLineItem> olis {get; set;}
    public List<opportunityLineItem> StreetLightsOLIs {get; set;}
    public Decimal StreetLightsEstimateTotal {get; set;}


   public quote_streetlight_controller () 
    {
        system.debug('CAS>>> quote_streetlight_controller (opportunityId = '+oppId+')');        
        // load(); called by the attribute setter function 'setOppId'.
    }
      
    public Id getOppId()
    {
        system.debug('CAS>>> quote_streetlight_controller .getOppId()');  
        return oppId;
    }

    public void setOppId(ID opportunityId)
    {
        system.debug('CAS>>> quote_streetlight_controller .setOppId('+opportunityId+')');  
        oppId = opportunityId;
        load();
    }
    
    private void load()
    {
        system.debug('CAS>>> quote_streetlight_controller .load()');  
        if(oppId == null)
        {
          system.debug('CAS>>> oppId is null!');  
            return;  // abort if Id is not provided
        }
        
        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        system.debug('CAS>>> Map = '+SiteSchemeRecordTypeInfo);

        StreetLightsOLIs = new List<opportunityLineItem>();

        StreetLightsEstimateTotal = 0;


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
            StreetLightsOLIs.add(oli);
            StreetLightsEstimateTotal += oli.Total_Sell_Rate__c;
        }
    }
}
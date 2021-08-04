public class quote_sse_connections_controller 
{
    public String oppId;
    public Opportunity theOpp {get; set;}
    public List<opportunityLineItem__c> olis {get; set;}
    public List<opportunityLineItem__c> SSEConnectionsOLIs {get; set;}


    public Decimal SSEConnectionsTotal {get; set;}
    public Decimal SSEConnectionsEstimateTotal {get; set;}
    
    public quote_sse_connections_controller() 
    {
        system.debug('CAS>>> quote_sse_connections_controller(opportunityId__c = '+oppId+')');        
        // load(); called by the attribute setter function 'setOppId'.
    }
      
    public Id getOppId()
    {
        system.debug('CAS>>> quote_sse_connections_controller.getOppId()');  
        return oppId;
    }

    public void setOppId(ID opportunityId)
    {
        system.debug('CAS>>> quote_sse_connections_controller.setOppId('+opportunityId+')');  
        oppId = opportunityId;
        load();
    }
    
    private void load()
    {
        system.debug('CAS>>> quote_sse_connections_controller.load()');  
        if(oppId == null)
        {
            system.debug('CAS>>> oppId is null!');  
            return;  // abort if Id is not provided
        }

        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        system.debug('CAS>>> Map = '+SiteSchemeRecordTypeInfo);
        
        SSEConnectionsOLIs = new List<opportunityLineItem__c>();
     

        
        SSEConnectionsTotal = 0;
        SSEConnectionsEstimateTotal = 0;
        
        // get addition fields from opp
        String obj;
        String query;
        theOpp = [SELECT Id, Name, Site__c, Job_Number__c, Estimate_Hold_Notes__c, Version__c, Account.Name FROM Opportunity WHERE Id = :oppId LIMIT 1]; 
       
        system.debug('CAS>>> theOpp = '+theOpp);        
        
        if(theOpp == null)
            return;  // abort if Id is not provided (should never happen as it is a require field!)
        
        // get all Opportunity Line Items...
        obj = 'opportunityLineItem__c';
        query = 'SELECT ' + quote_helper.getFieldList(obj) + ' FROM ' + obj + ' WHERE OpportunityId__c = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query (shortened) = SELECT <fields> FROM ' + obj + ' WHERE OpportunityId__c = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC');
        olis = database.query(query);
            
        // Create totals for each section of Opportunity line items...
        for(OpportunityLineItem__c oli :olis)
        {
                SSEConnectionsEstimateTotal += oli.Total_Sell_Rate__c;
        
            if(oli.Product_Family__c == 'SSEN')
            {
                SSEConnectionsOLIS.add(oli);
                SSEConnectionsTotal += oli.Total_Sell_Rate__c;
            }

     
        }
    }
}
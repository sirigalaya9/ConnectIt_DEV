public class quote_sse_utilities_controller 
{
    public String oppId;
    public Opportunity theOpp {get; set;}
    public List<opportunityLineItem> olis {get; set;}
    public List<opportunityLineItem> SSEUtilitiesUnmadeElectricOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesFootpathOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesRoadclass1_2OLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesRoadclass3_4OLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesJointingInstallationOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesBreechJointsOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesBreachJointsForFlatsOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesTerminationOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesPotEndsOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesServicesOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesJointingHVOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesElectricCableInstallOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesDuctsInTrenchOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesSubStationOLIs {get; set;}
    public List<opportunityLineItem> SSEUtilitiesMeterBoxesOLIs {get; set;}    
    public List<opportunityLineItem> SSEUtilitiesStreetLightsOLIs {get; set;}    
    public List<opportunityLineItem> SSEUtilitiesDayWorkOLIs {get; set;}    
    public List<opportunityLineItem> SSEUtilitiesTradeTeamOLIs {get; set;}
    public Decimal SSEUtilitiesUnmadeElectricTotal {get; set;}
    public Decimal SSEUtilitiesFootpathTotal {get; set;}
    public Decimal SSEUtilitiesRoadclass1_2Total {get; set;}
    public Decimal SSEUtilitiesRoadclass3_4Total {get; set;}
    public Decimal SSEUtilitiesJointingInstallationTotal {get; set;}
    public Decimal SSEUtilitiesBreechJointsTotal {get; set;}
    public Decimal SSEUtilitiesBreachJointsForFlatsTotal {get; set;}
    public Decimal SSEUtilitiesTerminationTotal {get; set;}
    public Decimal SSEUtilitiesPotEndsTotal {get; set;}
    public Decimal SSEUtilitiesServicesTotal {get; set;}
    public Decimal SSEUtilitiesJointingHVTotal {get; set;}
    public Decimal SSEUtilitiesElectricCableInstallTotal {get; set;}
    public Decimal SSEUtilitiesDuctsInTrenchTotal {get; set;}
    public Decimal SSEUtilitiesSubStationTotal {get; set;}
    public Decimal SSEUtilitiesMeterBoxesTotal {get; set;}    
    public Decimal SSEUtilitiesStreetLightsTotal {get; set;}    
    public Decimal SSEUtilitiesDayWorkTotal {get; set;}    
    public Decimal SSEUtilitiesTradeTeamTotal {get; set;}
    public Decimal SSEUtilitiesEstimateTotal {get; set;}
    
    public quote_sse_utilities_controller() 
    {
        system.debug('CAS>>> quote_sse_utilities_controller(opportunityId = '+oppId+')');        
        // load(); called by the attribute setter function 'setOppId'.
    }
      
    public Id getOppId()
    {
        system.debug('CAS>>> quote_sse_utilities_controller.getOppId()');  
        return oppId;
    }

    public void setOppId(ID opportunityId)
    {
        system.debug('CAS>>> quote_sse_utilities_controller.setOppId('+opportunityId+')');  
        oppId = opportunityId;
        load();
    }
    
    private void load()
    {
        system.debug('CAS>>> quote_sse_utilities_controller.load()');  
        if(oppId == null)
        {
            system.debug('CAS>>> oppId is null!');  
            return;  // abort if Id is not provided
        }

        Map<String,Schema.RecordTypeInfo> SiteSchemeRecordTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        system.debug('CAS>>> Map = '+SiteSchemeRecordTypeInfo);
        
        SSEUtilitiesUnmadeElectricOLIs = new List<opportunityLineItem>();
        SSEUtilitiesFootpathOLIs = new List<opportunityLineItem>();
        SSEUtilitiesRoadclass1_2OLIs = new List<opportunityLineItem>();
        SSEUtilitiesRoadclass3_4OLIs = new List<opportunityLineItem>();
        SSEUtilitiesJointingInstallationOLIs = new List<opportunityLineItem>();
        SSEUtilitiesBreechJointsOLIs = new List<opportunityLineItem>();
        SSEUtilitiesBreachJointsForFlatsOLIs = new List<opportunityLineItem>();
        SSEUtilitiesTerminationOLIs = new List<opportunityLineItem>();
        SSEUtilitiesPotEndsOLIs = new List<opportunityLineItem>();
        SSEUtilitiesServicesOLIs = new List<opportunityLineItem>();
        SSEUtilitiesJointingHVOLIs = new List<opportunityLineItem>();
        SSEUtilitiesElectricCableInstallOLIs = new List<opportunityLineItem>();
        SSEUtilitiesDuctsInTrenchOLIs = new List<opportunityLineItem>();
        SSEUtilitiesSubStationOLIs = new List<opportunityLineItem>();
        SSEUtilitiesMeterBoxesOLIs = new List<opportunityLineItem>(); 
        SSEUtilitiesStreetLightsOLIs = new List<opportunityLineItem>();  
        SSEUtilitiesDayWorkOLIs = new List<opportunityLineItem>();
        SSEUtilitiesTradeTeamOLIs = new List<opportunityLineItem>();
        
        SSEUtilitiesUnmadeElectricTotal = 0;
        SSEUtilitiesFootpathTotal = 0;
        SSEUtilitiesRoadclass1_2Total = 0;
        SSEUtilitiesRoadclass3_4Total = 0;
        SSEUtilitiesJointingInstallationTotal = 0;
        SSEUtilitiesBreechJointsTotal = 0;
        SSEUtilitiesBreachJointsForFlatsTotal = 0;
        SSEUtilitiesTerminationTotal = 0;
        SSEUtilitiesPotEndsTotal = 0;
        SSEUtilitiesServicesTotal = 0;
        SSEUtilitiesJointingHVTotal = 0;
        SSEUtilitiesElectricCableInstallTotal = 0;
        SSEUtilitiesDuctsInTrenchTotal = 0;
        SSEUtilitiesSubStationTotal = 0;
        SSEUtilitiesMeterBoxesTotal = 0; 
        SSEUtilitiesStreetLightsTotal = 0;  
        SSEUtilitiesDayWorkTotal = 0;
        SSEUtilitiesTradeTeamTotal = 0;
        SSEUtilitiesEstimateTotal =0;
        
        // get addition fields from opp
        String obj;
        String query;
        theOpp = [SELECT Id, Name, Site__c, Account.Name FROM Opportunity WHERE Id = :oppId LIMIT 1]; 
        system.debug('CAS>>> theOpp = '+theOpp);        
        
        if(theOpp == null)
            return;  // abort if Id is not provided (should never happen as it is a require field!)
        
        // get all Opportunity Line Items...
        obj = 'opportunityLineItem';
        query = 'SELECT ' + quote_helper.getFieldList(obj) + ' FROM ' + obj + ' WHERE OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC';
        system.debug('CAS>>> Query (shortened) = SELECT <fields> FROM ' + obj + ' WHERE OpportunityId = \'' + theopp.Id +'\' ORDER BY Sort_Order__c ASC');
        olis = database.query(query);
            
        // Create totals for each section of Opportunity line items...
        for(OpportunityLineItem oli :olis)
        {
            system.debug('CAS>>> oli.work_type__c = '+oli.Work_Type__c);        
 
            SSEUtilitiesEstimateTotal += oli.Total_Sell_Rate__c;
        
            if(oli.work_type__c == 'Unmade Electric')
            {
                SSEUtilitiesUnmadeElectricOLIs.add(oli);
                SSEUtilitiesUnmadeElectricTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Footpath')
            {
                SSEUtilitiesFootpathOLIs.add(oli);
                SSEUtilitiesFootpathTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Road Class 1/2')
            {
                SSEUtilitiesRoadclass1_2OLIs.add(oli);
                SSEUtilitiesRoadclass1_2Total += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Road Class 3/4')
            {
                SSEUtilitiesRoadclass3_4OLIs.add(oli);
                SSEUtilitiesRoadclass3_4Total += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Jointing Installation')
            {
                SSEUtilitiesJointingInstallationOLIs.add(oli);            
                SSEUtilitiesJointingInstallationTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Breech Joints')
            {
                SSEUtilitiesBreechJointsOLIs.add(oli);
                SSEUtilitiesBreechJointsTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Breech Joints for flats')
            {
                SSEUtilitiesBreachJointsForFlatsOLIs.add(oli);
                SSEUtilitiesBreachJointsForFlatsTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Termination')
            {
                SSEUtilitiesTerminationOLIs.add(oli);
                SSEUtilitiesTerminationTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Pot Ends')
            {
                SSEUtilitiesPotEndsOLIs.add(oli);
                SSEUtilitiesPotEndsTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Services')
            {
                SSEUtilitiesServicesOLIs.add(oli);
                SSEUtilitiesServicesTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Jointing HV')
            {
                SSEUtilitiesJointingHVOLIs.add(oli);
                SSEUtilitiesJointingHVTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Electric Cable Install')
            {
                SSEUtilitiesElectricCableInstallOLIs.add(oli);
                SSEUtilitiesElectricCableInstallTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Ducts In Trench')
            {
                SSEUtilitiesDuctsInTrenchOLIs.add(oli);
                SSEUtilitiesDuctsInTrenchTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Sub Station')
            {
                SSEUtilitiesSubStationOLIs.add(oli);
                SSEUtilitiesSubStationTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Meter Boxes')
            {
                SSEUtilitiesMeterBoxesOLIs.add(oli);
                SSEUtilitiesMeterBoxesTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Street Lights')
            {
                SSEUtilitiesStreetLightsOLIs.add(oli);
                SSEUtilitiesStreetLightsTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Day Work')
            {
                SSEUtilitiesDayWorkOLIs.add(oli);
                SSEUtilitiesDayWorkTotal += oli.Total_Sell_Rate__c;
            }
            if(oli.work_type__c == 'Trade Teams')
            {
                SSEUtilitiesTradeTeamOLIs.add(oli);
                SSEUtilitiesTradeTeamTotal += oli.Total_Sell_Rate__c;
            }
        }
    }
}
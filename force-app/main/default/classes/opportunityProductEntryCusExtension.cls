public with sharing class opportunityProductEntryCusExtension 
{
    public Opportunity theOpp {get;set;}
    public String searchString {get;set;}
    public Boolean showEditPanel{get;set;}
    public Boolean showDisplayPanel{get;set;}
    public Boolean showCosts{get;set;}
    public List<rowItem> rows {get;set;}
    public String selectedRowId {get;set;}
    private Integer count = 0;
    public Product2[] AvailableProducts {get;set;}
    
    public String chargercompany {get;set;}
    
    // Booleans to switch individual buttons
    public Boolean showElectric{get;set;}
    public Boolean showWater{get;set;}
    public Boolean showGas{get;set;}
    public Boolean showCBRE{get;set;}
    public Boolean showChargePoints{get;set;}
    public Boolean showStreetLighting{get;set;}
    public Boolean showTempBuildingSupply{get;set;}
    public Boolean showSSENConnections{get;set;}
    public Boolean showSSENMinorWorks{get;set;}
    public Boolean showSSENServiceAlterations{get;set;}
    public Boolean showSSENMajorProjects{get;set;}
        
    public integer counter=0;  //keeps track of the offset
    private integer list_size=20; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    public String toSelect {get; set;}
    public Decimal Total {get;set;}
    public string sortFullExp;
    public Boolean overLimit {get;set;}
    private string sortDirection='ASC';
    private string sortExp='Sort_Order__c';
    private opportunityLineItem__c[] forDeletion = new opportunityLineItem__c[]{};   

    public class rowItem
    {
        // recCount acts as a index for a row. This will be helpful to identify the row to be deleted   
        public String rowId{get;set;}
        public opportunityLineItem__c oli{get;set;}
        public String family{get;set;}
        public Integer rowCount;
        public Boolean multiple {get;set;}
        
        // Row item constructor
        public rowItem(Integer count, OpportunityLineItem__c theOli, String theFamily, Boolean theMultiples)
        {            
            rowId = String.valueOf(count);
            rowCount = count;
            
            // create a new oli          
            oli = theOli;
            family = theFamily;
            multiple = theMultiples;

        }
    }

    public String sortField 
    {
        get 
        { 
            if (sortField == null) 
                sortField = 'Sort__c';
            return sortField;
        } 
        set;
    }
    
    
    public String sortDir 
    {
        get 
        { 
            if (sortDir == null) 
                sortDir = 'ASC'; 
            return sortDir;  
        } 
        set;
    }
    
    
    public string sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if(value == sortExp)
                sortDirection=(sortDirection=='ASC')?'DESC':'ASC';
            else 
                sortDirection='ASC';
            sortExp=value;
        }
    }
    
    
    public string getSortDirection()
    {
        //if not column is selected 
        if(sortExpression==null||sortExpression=='')
            return 'ASC';
        else 
            return sortDirection;
    }
    
    
    public PageReference Beginning() 
    { 
        System.debug('CAS>>> Beginning');
        //user clicked beginning
        counter = 0;
        updateAvailableList();
        return null;
    }

    
   public PageReference Previous() 
   { 
        System.debug('CAS>>> Previous');
       //user clicked previous button
       counter -= list_size;
       updateAvailableList();
       return null;
   }

    
   public PageReference Next() 
   { 
       System.debug('CAS>>> Previous');
       //user clicked next button
       counter += list_size;
       updateAvailableList();
       return null;
   }

    
   public PageReference End() 
   { 
       System.debug('CAS>>> End');
       //user clicked end
       counter = total_size - math.mod(total_size, list_size);
       updateAvailableList();
       return null;
   }

    
   public Boolean getDisablePrevious() 
   { 
       System.debug('CAS>>> getDisablePrevious');
       //this will disable the previous and beginning buttons
       if (counter>0) 
           return false; 
       else 
           return true;
   }

    
   public Boolean getDisableNext() 
   { 
       System.debug('CAS>>> getDisableNext');
       //this will disable the next and end buttons
       if (counter + list_size < total_size) 
           return false; 
       else 
           return true;
   }

    
   public Integer getTotal_size() 
   {
      return total_size;
   }

    
   public Integer getPageNumber() 
   {
      return counter/list_size + 1;
   }

    
   public Integer getTotalPages() 
   {
       if (math.mod(total_size, list_size) > 0) 
           return total_size/list_size + 1;
       else 
           return (total_size/list_size);
   }

//=======================================================================================================================    
// Constructor
//=======================================================================================================================
   public void toggleSort() 
   {
       System.debug('CAS>>> toggleSort');
       // simply toggle the direction
       sortDir = sortDir.equals('ASC') ? 'DESC' : 'ASC';
       // run the query again
       updateAvailableList();
   }

    public opportunityProductEntryCusExtension(ApexPages.StandardController controller) 
    {        
        System.debug('CAS>>> opportunityProductEntryCusExtension');
        rows = new List<rowItem>();
        
        // initialise deletion list
        forDeletion.clear();
        
        // Get information about the Opportunity being worked on
        getOpp(controller.getRecord().Id);

        ViewData();    

        showEditPanel=false;
        showDisplayPanel=true;
        showCosts=false;
      
        updateAvailableList();    
       
       
        // Set display for individual buttons
        showElectric = theOpp.Utilities__c==null?false:theOpp.type=='SSEN Major Projects'?false:theOpp.type=='SSEN Connections'?false:theOpp.type=='SSEN Minor Works'?false:theOpp.type=='SSEN Service Alterations'?false:theOpp.Utilities__c.contains('Electric');
        showGas = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Gas');
        showWater = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Water');
        showChargePoints = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Charge Points');
        showStreetLighting = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Street Lighting');
        showTempBuildingSupply = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Temporary Building Supply');
        showSSENConnections = theOpp.type==null?false:theOpp.type.contains('SSEN Connections');  
        showSSENMinorWorks  = theOpp.type==null?false:theOpp.type.contains('SSEN Minor Works');  
        showSSENServiceAlterations  = theOpp.type==null?false:theOpp.type.contains('SSEN Service Alterations');
        showSSENMajorProjects  = theOpp.type==null?false:theOpp.type.contains('SSEN Major Projects');
                 
        // Get Scheme Details Street Lighting ....
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id StreetLightingRecordType = SiteSchemeTypeInfo.get('StreetLighting').getRecordTypeId();
        List<site_scheme__c>StreetLightingSiteScheme = [SELECT No_of_Units__c, dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :StreetLightingRecordType LIMIT 1];
              
        if(!StreetLightingSiteScheme.isEmpty())
            {
            //Avoid error being displayed
            } 

   
        // Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
         Id ChargerRecordType = SiteSchemeTypeInfo.get('Charger').getRecordTypeId();
         List<site_scheme__c> chargerSiteScheme = [SELECT charger_provider__c, dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :ChargerRecordType LIMIT 1];
          
           
         if(chargerSiteScheme.isEmpty())
            {
            //Avoid error being displayed
            } 
           else
           chargercompany = chargerSiteScheme[0].charger_provider__c;

           System.debug('CAS>>> chargercompany');

            
       // Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id GasRecordType = SiteSchemeTypeInfo.get('Gas').getRecordTypeId();
        List<site_scheme__c> GasSiteScheme = [SELECT GT__c, IGT__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :GasRecordType LIMIT 1];
                 
            if(!GasSiteScheme.isEmpty())
            {
            //Avoid error being displayed
            }          

     
        // Get Scheme Details
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        List<site_scheme__c> ElectricSiteScheme = [SELECT dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :ElectricRecordType];
     
        if(!ElectricSiteScheme.isEmpty())
            {
            //Avoid error being displayed
            }     
         
               
        Id WaterRecordType = SiteSchemeTypeInfo.get('Water').getRecordTypeId();
        List<site_scheme__c> WaterSiteScheme = [SELECT Water_Provider__c, Pipe_Type__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :WaterRecordType];
          
        if(!WaterSiteScheme.isEmpty())
            {
            //Avoid error being displayed
            }  
 
      }
      
    public PageReference ViewData()
    {
        system.debug('CAS>>> ViewData');
        
        //build the full sort expression
        sortFullExp=sortExpression+' '+sortDirection;
        
        //query the database based on the sort expression
        getOLIs(theOpp.Id, sortFullExp);
        getOpp(theOpp.Id);
        debugShoppingCart();
                
        return null;
    }
    
    
    public void updateAvailableList() 
    {
        System.debug('CAS>>> updateAvailableList');
        System.debug('CAS>>> point 1');
        debugShoppingCart();
        
        // We dynamically build a query string and exclude items already in the shopping cart
        String qString = 'SELECT Id,  IsActive, Name, Sort__c, Family, boris_code__c, boris_voltage__c, Unit_Of_Measure__c,  ProductCode, Allow_Multiple_Products__c, Description, Kit_Sell__c, Labour_Sell__c, Labour_Cost__c,  Material_Cost__c, Plant_Sell__c, Plant_Cost__c, Implementor__c '+
                         'FROM Product2 '+
                         'WHERE IsActive = true AND IS_KIT__C = true ';
        
        // note that we are looking for the search string entered by the user in the name OR description
        // modify this to search other fields if desired
        if(searchString!=null)
        {
            qString += ' AND ('+getWhereClause(searchString)+')';
            //qString+= ' and (Name like \'%' + searchString + '%\' or Description like \'%' + searchString + '%\')';
        }
        System.debug('CAS>>> point 2');
        debugShoppingCart();
        
        Set<Id> selectedEntries = new Set<Id>();
        for(rowItem d:rows)
        {
          if(!d.multiple && d.oli.Product2Id__c != null)
            selectedEntries.add(d.oli.Product2Id__c);
        }
        
        if(selectedEntries.size()>0)
        {
            String tempFilter = ' and Id not in (';
            for(Id i : selectedEntries)
            {
                tempFilter+= '\'' + (String)i + '\',';
            }
            String extraFilter = tempFilter.substring(0,tempFilter.length()-1);
            extraFilter+= ')';
            
            qString+= extraFilter;
        }
        
        
// Adding criteria to filter products by Utility
        System.debug('CAS>>> utilitiesFilter');
        String utilitiesFilter = 'AND (product2.family=\'Fees/Design\' OR product2.family=\'Excavation\' OR product2.family=\'CBRE\' OR product2.family=\'Miscellaneous\' OR product2.family=\'Traffic Management\' OR product2.family=\'Non-Contestable\' OR product2.family=\'Fibre\' OR product2.family=\'Allocate Labour & Plant\'';
           // if (showElectric)
        if (theOpp.Utilities__c != null && theOpp.Utilities__c.contains('Electric') && theOpp.type != 'SSEN Connections' ) 
         If (theOpp.Utilities__c != null && theOpp.Utilities__c.contains('Electric') && theOpp.type != 'SSEN Minor Works' )
          If (theOpp.Utilities__c != null && theOpp.Utilities__c.contains('Electric') && theOpp.type != 'SSEN Major Projects' )
           If (theOpp.Utilities__c != null && theOpp.Utilities__c.contains('Electric') && theOpp.type != 'SSEN Service Alterations' )
        {
            utilitiesFilter += ' OR product2.family = \'Electricity\' OR product2.family = \'Electricity Excavation\' ';
        }
        
        if (theOpp.Utilities__c != null && theOpp.Utilities__c.contains('Gas'))
        {
            utilitiesFilter += ' OR product2.family = \'Gas\' OR product2.family = \'Gas Excavation\' '; 
        }

        if (theOpp.Utilities__c != null && theOpp.Utilities__c.contains('Water'))
        {
            utilitiesFilter += ' OR product2.family = \'Water\' OR product2.family = \'Water Excavation\' '; 
        }

        if (theOpp.Utilities__c != null && theOpp.Utilities__c.contains('Street Lighting'))
        {
            utilitiesFilter += ' OR product2.family = \'Street Lighting\' '; 
        }
        
        if (theOpp.Utilities__c != null && theOpp.Type !=null && theOpp.Utilities__c == 'Electric' && theOpp.Type.contains('SSEN'))
        {
            utilitiesFilter = ' AND (product2.family = \'SSEN\' '; 
        }
                       
        if (theOpp.Utilities__c != null && theOpp.Utilities__c.contains('Charge Points'))
        {
             utilitiesFilter = ' AND (product2.family = \'Charge Point\' OR product2.family = \'Instavolt\' OR product2.family = \'Osprey Charging Network \'  OR product2.family = \'Engenie \' '; 
        }                
      
     
        showElectric = theOpp.Utilities__c==null?false:theOpp.type=='SSEN Connections'?false:theOpp.type=='SSEN Minor Works'?false:theOpp.type=='SSEN Service Alterations'?false:theOpp.Utilities__c.contains('Electric');
        showGas = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Gas');
        showWater = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Water');
        showChargePoints = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Charge Points');
        showStreetLighting = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Street Lighting');
        showTempBuildingSupply = theOpp.Utilities__c==null?false:theOpp.Utilities__c.contains('Temporary Building Supply');
        showSSENConnections = theOpp.type==null?false:theOpp.type.contains('SSEN Connections');  
        showSSENMinorWorks = theOpp.type==null?false:theOpp.type.contains('SSEN Minor Works');  
        showSSENServiceAlterations = theOpp.type==null?false:theOpp.type.contains('SSEN Service Alterations');  
        showSSENMajorProjects = theOpp.type==null?false:theOpp.type.contains('SSEN Major Projects');  
        
        utilitiesFilter += ')';       
        qString += utilitiesFilter;
        System.debug('CAS>>> utilitiesFilterEnd');

        System.debug('CAS>>> query string = '+qString);
        total_size = database.query(qString).size();
        System.debug(total_size);
        System.debug(counter);
        qString+= ' ORDER BY ' + sortfield  + ' ' + sortDir;
        qString+= ' limit :list_size offset :counter';
        System.debug('CAS>>> point 3');
        debugShoppingCart();
        
        system.debug('qString:' +qString);        
        AvailableProducts = database.query(qString);
        
        // We only display up to 100 results... if there are more than we let the user know (see vf page)
        /*if(AvailableProducts.size()==101){
            AvailableProducts.remove(100);
            overLimit = true;
        }
       else{
            overLimit=false;
        }*/
        System.debug('CAS>>> point 4');
        debugShoppingCart();

    }
    
  
    public void addToShoppingCart()
    {
        System.debug('CAS>>> addToShoppingCart');
        System.debug('CAS>>> Pre add');
        debugShoppingCart();

        // This function runs when a user hits "select" button next to a product
        for(Product2 d : AvailableProducts)
        {
           if(Test.isRunningTest())
               toSelect= (String)d.Id;
            
            if((String)d.Id == toSelect)
            {
                rows.add(new rowItem(count++, new opportunityLineItem__c(
                                                  OpportunityId__c       = theOpp.Id, 
                                                  Product_Text__c        = d.Name,
                                                  BORIS_Code__c          = d.boris_code__c, 
                                                  BORIS_Voltage__c       = d.boris_voltage__c,
                                                  Unit_Of_Measure_Ref__c = d.Unit_Of_Measure__c,
                                                  Quantity__c            = 0,   
                                                  Product2Id__c          = d.id,
                                                  Product_Name__c        = d.Name,
                                                  Implementor__c         = d.Implementor__c,
                                                  Kit_Sell__c            = d.Kit_Sell__c,     
                                                  UnitPrice__c           = d.Labour_Sell__c,
                                                  Labour_Cost__c         = d.Labour_Cost__c,
                                                  Plant_Cost__c          = d.Plant_Cost__c,
                                                  Material_Cost__c       = d.Material_Cost__c), d.Family, d.Allow_Multiple_Products__c));
                 break;
            }
        }
        System.debug('CAS>>> Post add');
        debugShoppingCart();
        
        updateAvailableList();  
    }
    
    
    public void addElectric()
    {
        addFamilyProductsElectric('Electricity');
   }
    
    
    public void addWater()
    {
        addFamilyProductsWater('Water');
    }
    
    
    public void addGas()
    {
        addFamilyProductsGas('Gas');
    }
    
    
    public void addStreetLighting()
    {
        addFamilyProductsStreetLighting('Street Lighting');
    }
    
    
    public void addChargePoints()
    {
        addFamilyProductsChargePoints('Charger Points');
    }
    
    public void addSSENConnections()
    {
        addFamilyProductsSSENConnections('SSEN');
    }
    
    public void addSSENMinorWorks()
    {
        addFamilyProductsSSENMinorWorks('SSEN');
    }
    
    public void addSSENServiceAlterations()
    {
        addFamilyProductsSSENServiceAlterations('SSEN');
    }
    
    public void addSSENMajorProjects()
    {
        addFamilyProductsSSENMajorProjects('SSEN');
    }
    
    
    public void addCivils()
    {
        addFamilyProducts('Offsite');
        addFamilyProducts('Onsite');
    }
    
    public void addThirdPartyCosts()
    {
        addFamilyProducts('Non-Contestable');
    }

    
    public PageReference updateToLabourSellValue()
    {
        // Labour Sell value has been updated, if non-contestable update the Labour Cost price to match.
        system.debug('CAS>>> updateToLabourSellValue');
        for(Integer idx = 0; idx<rows.size(); idx++)
        {
            if(rows[idx].rowId == selectedRowId)
            {
                if(rows[idx].oli.Product_Family__c != 'Non-Contestable')
                   return null;   // we only want non-contestables!
                
                // update the labour cost to labour sell price
                rows[idx].oli.Labour_Cost__c = rows[idx].oli.UnitPrice__c;
                return null;
            }
        }
        return null;
    }
    
 // Material Sell is calculated (from Material cost & Uplift) Original Material Sell was deprecated. Updated from Material_Sell to Material_Sell_calc__c
    public PageReference updateToMaterialSellValue()
    {
        // Material Sell value has been updated, if non-contestable update the Material Cost price to match.  
        system.debug('CAS>>> updateToMaterialSellValue');
        for(Integer idx = 0; idx<rows.size(); idx++)
        {
            if(rows[idx].rowId == selectedRowId)
            {
                if(rows[idx].oli.Product_Family__c != 'Non-Contestable')
                    return null;   // we only want non-contestables!
                
                // update the Material cost to Material sell price
                rows[idx].oli.Material_Cost__c = rows[idx].oli.Material_Sell_calc__c;
                return null;
            }
        }
        return null;
    }

// Plant Sell is calculated (from Plant cost & uplift) Original Plant Sell was deprecated. Updated from Plant_Sell to Plant_Sell_calc__c  

    public PageReference updateToPlantSellValue()
    {
        // Plant Sell value has been updated, if non-contestable update the Plant Cost price to match.
        system.debug('CAS>>> updateToPlantSellValue');
        for(Integer idx = 0; idx<rows.size(); idx++)
        {
            if(rows[idx].rowId == selectedRowId)
            {
                if(rows[idx].oli.Product_Family__c != 'Non-Contestable')
                    return null;   // we only want non-contestables!
                
                // update the labour cost to labour sell price
                rows[idx].oli.Plant_Cost__c = rows[idx].oli.Plant_Sell_calc__c;
                return null;
            }
        }
        return null;
    }
    
    
    public PageReference updateToLabourCostValue()
    {
        // Labour Sell value has been updated, if non-contestable update the Labour Cost price to match.
        system.debug('CAS>>> updateToLabourCostValue');
        for(Integer idx = 0; idx<rows.size(); idx++)
        {
            if(rows[idx].rowId == selectedRowId)
            {
                if(rows[idx].oli.Product_Family__c != 'Non-Contestable')
                    return null;   // we only want non-contestables!
                
                // update the labour cost to labour sell price
                rows[idx].oli.UnitPrice__c = rows[idx].oli.Labour_Cost__c;
                return null;
            }
        }
        return null;
    }


    public void updateCostValue()
    {
        system.debug('CAS>>> updateCostValue');
        for(Integer idx = 0; idx<rows.size(); idx++)
        {
            if(rows[idx].rowId == selectedRowId)
            {
                system.debug('CAS>>> updateCostValue: Labour Cost = '+rows[idx].oli.Labour_Cost__c);
                system.debug('CAS>>> updateCostValue: Implementor = '+rows[idx].oli.Implementor__c);
                
                // update the labour cost according to implementor setting...
               rows[idx].oli.Labour_Cost__c = rows[idx].oli.Labour_Cost__c;
                if(rows[idx].oli.Implementor__c == 'Subcontractor')
         //           rows[idx].oli.Labour_Cost__c = rows[idx].oli.Subcontractor_Cost__c;
                break;
            }
        }
    }

  
    public void addFamilyProducts(String family)
    {
        System.debug('CAS>>> addFamily('+family+')');
        
           // This function runs when a user hits "select" button next to a product
            for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Family = :family
                                      AND Core_Product__c = true
                                      ORDER BY Sort__c ])
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }

               if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;
                    
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c   = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c      = pro.boris_code__c, 
                        BORIS_Voltage__c       = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c  = pro.Unit_Of_Measure__c,
                        Quantity__c        = 0,
                        Product2Id__c      = pro.id,
                        Product_Name__c    = pro.Name,
                        Implementor__c = pro.Implementor__c, 
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        UnitPrice__c       = pro.Labour_Sell__c,   
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                }
            }
        debugShoppingCart();
        updateAvailableList();        
    }


// ============================================================================================================================================================================================
// Adding Products just for Charger Points (when Add Charge Points Products Button Selected)
      
    public void addFamilyProductsChargePoints(String family)
    {
        System.debug('CAS>>> addFamilyProductsChargePoints('+family+')');
     
        // Get Scheme Details
         Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
         Id ChargerRecordType = SiteSchemeTypeInfo.get('Charger').getRecordTypeId();
         List<site_scheme__c> chargerSiteSchemes = [SELECT charger_provider__c, dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :ChargerRecordType];
     
        for(site_scheme__c chargerSiteScheme :chargerSiteSchemes)
        {
            System.debug('CAS>>> site scheme('+chargerSiteScheme.charger_provider__c+')');
                
            // This function runs when a user hits "select" button next to a product
            for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c                         
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = :chargerSiteScheme.charger_provider__c
                                      AND ((Adopter__c = :chargerSiteScheme.idno__c AND work_zone__c = 'Onsite') OR
                                           (Adopter__c = :chargerSiteScheme.dno__c  AND work_zone__c = 'Offsite') OR 
                                           (Adopter__c = :chargerSiteScheme.idno__c AND work_zone__c = 'Both') OR
                                           (Adopter__c = :chargerSiteScheme.dno__c  AND work_zone__c = 'Both') OR
                                           (Adopter__c = :chargerSiteScheme.idno__c AND work_zone__c = '') OR
                                           (Adopter__c = :chargerSiteScheme.dno__c  AND work_zone__c = '') OR                                           
                                           (Adopter__c = ''))                                                                             
                                           ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;
                    
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c     = theOpp.Id, 
                        Product_Text__c      = pro.Name,
                        BORIS_Code__c        = pro.boris_code__c, 
                        BORIS_Voltage__c     = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c  = pro.Unit_Of_Measure__c, 
                        Quantity__c          = 0,                        
                        Product2Id__c      = pro.id,
                        Product_Name__c    = pro.Name,
                        Implementor__c = pro.Implementor__c, 
                        Kit_Sell__c          = pro.Kit_Sell__c,
                        UnitPrice__c         = pro.Labour_Sell__c,
                        Labour_Cost__c       = pro.Labour_Cost__c,
                        Plant_Cost__c        = pro.Plant_Cost__c,
                        Material_Cost__c     = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }
    

// ============================================================================================================================================================================================
   
 // Adding Products just for StreetLighting (when Add Street Lighting Products Button Selected)
      
    public void addFamilyProductsStreetLighting(String family)
    {
        // System.debug('CAS>>> addFamilyProductsStreetLighting('+family+')');
     
        // Get Scheme Details
         Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
         Id StreetLightingRecordType = SiteSchemeTypeInfo.get('StreetLighting').getRecordTypeId();
         List<site_scheme__c> StreetLightingSiteSchemes = [SELECT dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :StreetLightingRecordType];
     
          
        for(site_scheme__c StreetLightingSiteScheme :StreetLightingSiteSchemes)
        {
            // System.debug('CAS>>> site scheme('+StreetLightingSiteScheme.No_of_Units__c+')');
                
            // This function runs when a user hits "select" button next to a product
            for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c,  Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'Street Lighting'
                                      AND ((Adopter__c = :StreetLightingSiteScheme.idno__c AND work_zone__c = 'Onsite') OR
                                           (Adopter__c = :StreetLightingSiteScheme.dno__c  AND work_zone__c = 'Offsite') OR 
                                           (Adopter__c = :StreetLightingSiteScheme.idno__c AND work_zone__c = 'Both') OR
                                           (Adopter__c = :StreetLightingSiteScheme.dno__c  AND work_zone__c = 'Both') OR
                                           (Adopter__c = :StreetLightingSiteScheme.idno__c AND work_zone__c = '') OR
                                           (Adopter__c = :StreetLightingSiteScheme.dno__c  AND work_zone__c = '') OR
                                           (Adopter__c = ''))              
                                           ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                     if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;

                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c     = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c      = pro.boris_code__c, 
                        BORIS_Voltage__c   = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c    = pro.Unit_Of_Measure__c,
                        Quantity__c        = 0,
                        Product2Id__c      = pro.id,
                        Product_Name__c     = pro.Name,
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        UnitPrice__c          = pro.Labour_Sell__c,
                        Implementor__c = pro.Implementor__c, 
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                  
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }
    
 // ============================================================================================================================================================================================     
    
 // Adding Products just for Gas (when Add Gas Products Button Selected)
      
    public void addFamilyProductsGas(String family)
    {
        System.debug('CAS>>> addFamilyGas('+family+')');
     
        // Get Scheme Details
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id GasRecordType = SiteSchemeTypeInfo.get('Gas').getRecordTypeId();
        List<site_scheme__c> GasSiteSchemes = [SELECT GT__c, IGT__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :GasRecordType];
     
        for(site_scheme__c GasSiteScheme :GasSiteSchemes)
        {
                
            // This function runs when a user hits "select" button next to a product
         for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'Gas'
                                      AND ((Adopter__c = :GasSiteScheme.IGT__c AND work_zone__c = 'Onsite') OR
                                           (Adopter__c = :GasSiteScheme.GT__c  AND work_zone__c = 'Offsite') OR 
                                           (Adopter__c = :GasSiteScheme.IGT__c AND work_zone__c = 'Both') OR
                                           (Adopter__c = :GasSiteScheme.GT__c  AND work_zone__c = 'Both') OR
                                           (Adopter__c = :GasSiteScheme.GT__c  AND work_zone__c = '') OR 
                                           (Adopter__c = :GasSiteScheme.IGT__c AND work_zone__c = '') OR 
                                           (Adopter__c = ''))                                                  
                                           ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                        if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;
        //            if(pro.Implementor__c == 'Subcontractor')
        //                LabourCost = pro.Subcontractor_Cost__c;
                   
                   
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c     = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c      = pro.boris_code__c,
                        BORIS_Voltage__c    = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c = pro.Unit_Of_Measure__c ,
                        Quantity__c        = 0,
                        Product2Id__c      = pro.id,
                        Product_Name__c    = pro.Name,
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        UnitPrice__c          = pro.Labour_Sell__c,
                        Implementor__c = pro.Implementor__c, 
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }
    
// ============================================================================================================================================================================================   
 // Adding Products just for SSEN Connections (when Add SSENConnections Products Button Selected)
      
    public void addFamilyProductsSSENConnections(String family)
    {
        System.debug('CAS>>> addFamilyProductsSSENConnections('+family+')');
     
        // Get Scheme Details
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        List<site_scheme__c> ElectricSiteSchemes = [SELECT dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :ElectricRecordType];
     
        for(site_scheme__c ElectricSiteScheme :ElectricSiteSchemes)
        {
                
            // This function runs when a user hits "select" button next to a product
         for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'SSEN'
                                      ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;
                                
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c     = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c       = pro.boris_code__c, 
                        BORIS_Voltage__c       = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c = pro.Unit_Of_Measure__c,
                        Quantity__c        = 0,                        
                        Product2Id__c      = pro.id,             
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        Product_Name__c         = pro.Name,
                        UnitPrice__c          = pro.Labour_Sell__c,
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Implementor__c = pro.Implementor__c, 
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }
    
    // ============================================================================================================================================================================================   
 // Adding Products just for SSEN Major Projects (when Add SSEN Major Projects Products Button Selected)
      
    public void addFamilyProductsSSENMajorProjects(String family)
    {
        System.debug('CAS>>> addFamilyProductsSSENMajorProjects('+family+')');
     
        // Get Scheme Details
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        List<site_scheme__c> ElectricSiteSchemes = [SELECT dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :ElectricRecordType];
     
        for(site_scheme__c ElectricSiteScheme :ElectricSiteSchemes)
        {
                
            // This function runs when a user hits "select" button next to a product
         for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'SSEN'
                                      ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;
                                
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c     = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c       = pro.boris_code__c, 
                        BORIS_Voltage__c       = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c = pro.Unit_Of_Measure__c,
                        Quantity__c        = 0,                        
                        Product2Id__c      = pro.id,             
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        Product_Name__c         = pro.Name,
                        UnitPrice__c          = pro.Labour_Sell__c,
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Implementor__c = pro.Implementor__c, 
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }

    
    
    
    // ============================================================================================================================================================================================   
 // Adding Products just for SSEN Minor Works (when Add SSENMinorWorks Products Button Selected)
      
    public void addFamilyProductsSSENMinorWorks(String family)
    {
        System.debug('CAS>>> addFamilyProductsSSENMinorWorks('+family+')');
     
        // Get Scheme Details
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        List<site_scheme__c> ElectricSiteSchemes = [SELECT dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :ElectricRecordType];
     
        for(site_scheme__c ElectricSiteScheme :ElectricSiteSchemes)
        {

            // This function runs when a user hits "select" button next to a product
         for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'SSEN'
                                      ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;                
                   
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c     = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c       = pro.boris_code__c, 
                        BORIS_Voltage__c       = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c = pro.Unit_Of_Measure__c,
                        Quantity__c        = 0,                        
                        Product2Id__c      = pro.id,             
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        Product_Name__c         = pro.Name,
                        UnitPrice__c          = pro.Labour_Sell__c,
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Implementor__c = pro.Implementor__c, 
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }
    
        // ============================================================================================================================================================================================   
 // Adding Products just for SSEN Service Alterations (when Add SSENServiceAlterations Products Button Selected)
      
    public void addFamilyProductsSSENServiceAlterations(String family)
    {
        System.debug('CAS>>> addFamilyProductsSSENServiceAlterations('+family+')');
     
        // Get Scheme Details
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        List<site_scheme__c> ElectricSiteSchemes = [SELECT dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :ElectricRecordType];
     
        for(site_scheme__c ElectricSiteScheme :ElectricSiteSchemes)
        {
                
            // This function runs when a user hits "select" button next to a product
         for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'SSEN'
                                      ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;
                   
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c     = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c       = pro.boris_code__c, 
                        BORIS_Voltage__c       = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c = pro.Unit_Of_Measure__c,
                        Quantity__c        = 0,                        
                        Product2Id__c      = pro.id,             
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        Product_Name__c         = pro.Name,
                        UnitPrice__c          = pro.Labour_Sell__c,
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Implementor__c = pro.Implementor__c, 
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }
   
 // ============================================================================================================================================================================================   
 // Adding Products just for Electric (when Add Electric Products Button Selected)
      
    public void addFamilyProductsElectric(String family)
    {
        System.debug('CAS>>> addFamilyProductsElectric('+family+')');
     
        // Get Scheme Details
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id ElectricRecordType = SiteSchemeTypeInfo.get('Electric').getRecordTypeId();
        List<site_scheme__c> ElectricSiteSchemes = [SELECT dno__c, idno__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :ElectricRecordType];
     
        for(site_scheme__c ElectricSiteScheme :ElectricSiteSchemes)
        {
                
            // This function runs when a user hits "select" button next to a product
         for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, Family, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'Electricity'
                                      AND ((Adopter__c = :ElectricSiteScheme.idno__c AND work_zone__c = 'Onsite') OR
                                          (Adopter__c = :ElectricSiteScheme.dno__c   AND work_zone__c = 'Offsite') OR 
                                          (Adopter__c = :ElectricSiteScheme.idno__c  AND work_zone__c = 'Both') OR
                                          (Adopter__c = :ElectricSiteScheme.dno__c   AND work_zone__c = 'Both') OR
                                          (Adopter__c = :ElectricSiteScheme.idno__c  AND work_zone__c = '') OR
                                          (Adopter__c = :ElectricSiteScheme.dno__c   AND work_zone__c = '') OR
                                          (Adopter__c = ''))     
                                          ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;
                  
                   
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c     = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c      = pro.boris_code__c, 
                        BORIS_Voltage__c       = pro.boris_voltage__c,
                        Unit_Of_Measure_Ref__c = pro.Unit_Of_Measure__c,
                        Quantity__c        = 0,                        
                        Product2Id__c      = pro.id,             
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        Product_Name__c         = pro.Name,
                        UnitPrice__c          = pro.Labour_Sell__c,
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Implementor__c = pro.Implementor__c, 
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c));
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }
    

// ============================================================================================================================================================================================   
 // Adding Products just for Water (when Add Water Products Button Selected)
      
    public void addFamilyProductsWater(String family)
    {
        System.debug('CAS>>> addFamilyProductsWater('+family+')');
     
        // Get Scheme Details
        Map<String,Schema.RecordTypeInfo> SiteSchemeTypeInfo = Schema.SObjectType.Site_Scheme__c.getRecordTypeInfosByName();
        Id WaterRecordType = SiteSchemeTypeInfo.get('Water').getRecordTypeId();
        List<site_scheme__c> WaterSiteSchemes = [SELECT Water_Provider__c, Pipe_type__c FROM site_scheme__c WHERE Estimate__c = :theopp.id AND RecordTypeId = :WaterRecordType];
     
        for(site_scheme__c WaterSiteScheme :WaterSiteSchemes)
        {
            System.debug('CAS>>> site scheme('+WaterSiteScheme.Water_Provider__c+')');
                
            // This function runs when a user hits "select" button next to a product
         for(product2 pro : [SELECT Id, IsActive, Name, Sort__c, Family, boris_code__c, boris_voltage__c, Unit_Of_Measure__c, ProductCode, Description, Allow_Multiple_Products__c, Implementor__c,
                                      Kit_Sell__c, Labour_Sell__c, Labour_Cost__c, Material_Cost__c, Plant_Sell__c, Plant_Cost__c, 
                                      work_zone__c, Adopter__c
                                      FROM Product2 
                                      WHERE IsActive = true
                                      AND IS_KIT__C = true
                                      AND Core_Product__c = true
                                      AND Family = 'Water'
                                      AND ((Adopter__c = :WaterSiteScheme.Water_Provider__c AND work_zone__c = :WaterSiteScheme.Pipe_type__c) OR
                                           (Adopter__c = '' AND work_zone__c = :WaterSiteScheme.Pipe_type__c) OR
                                           (Adopter__c = :WaterSiteScheme.Water_Provider__c AND work_zone__c = '') OR                                         
                                           (Adopter__c = '' AND work_zone__c = '')) 
                                           ORDER BY Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.Product2Id__c == pro.Id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pro.Labour_Cost__c;
                                    
                    rows.add(new rowItem(count++, new opportunityLineItem__c(
                        OpportunityId__c   = theOpp.Id, 
                        Product_Text__c    = pro.Name,
                        BORIS_Code__c      = pro.boris_code__c, 
                        BORIS_Voltage__c       = pro.boris_voltage__c,
                        Unit_Of_Measure_ref__c  = pro.Unit_Of_Measure__c,
                        Quantity__c        = 0,
                        Product2Id__c      = pro.id,
                        Kit_Sell__c        = pro.Kit_Sell__c,
                        Product_Name__c    = pro.Name,
                        UnitPrice__c       = pro.Labour_Sell__c,
                        Labour_Cost__c     = pro.Labour_Cost__c,
                        Plant_Cost__c      = pro.Plant_Cost__c,
                        Implementor__c     = pro.Implementor__c, 
                        Material_Cost__c   = pro.Material_Cost__c), pro.Family, pro.Allow_Multiple_Products__c ));
                }
            }
        }
        debugShoppingCart();
        updateAvailableList();        
    }
    

// ============================================================================================================================================================================================   
    
    
    public PageReference deleteRow()
    {
        system.debug('CAS>>> deleteRow');
        // This function runs when a user hits "remove" on an item in the "Selected Products" section   

        system.debug('CAS>>> Pre delete');
        debugShoppingCart();    
        for(Integer idx = 0; idx<rows.size(); idx++)
        {
            if(rows[idx].rowId == selectedRowId)
            {
                // only 'delete' if it was a loaded record in the first place (rather than one added and then deleted)...
                if(rows[idx].oli.id != null)
                    forDeletion.add(rows[idx].oli);
                rows.remove(idx);
                break;
            }
        }
        //viewData();
        system.debug('CAS>>> Post delete');
        debugShoppingCart();
        
        updateAvailableList();
        
        return null;
    }
    
    
    public PageReference onSave()
    {    
        system.debug('CAS>>> onSave');

        // If previously selected products are now removed, we need to delete them
        if(forDeletion.size()>0)
        {
            delete(forDeletion); 
            forDeletion.clear();
        }
                
        system.debug('CAS>>> Pre save');
        //debugShoppingCart();
        
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        List<OpportunityLineItem__c> olis = new List<OpportunityLineItem__c>();
        for(rowItem row :rows)
        {
            OpportunityLineItem__c oli = row.oli;
            olis.add(oli);
       }

        if(olis.size()>0)
            upsert(olis);
        
        system.debug('CAS>>> Post save');

        // After save return to view mode

        return null;
    }
    
    
    public PageReference onCancel()
    {
        System.debug('CAS>>> onCancel');
        forDeletion.clear();
       ViewData();
        
        // If user hits cancel we commit no changes and return them to the Opportunity in view mode 
        showEditPanel=false;
        showDisplayPanel=true;
        return null;
    }
    
    
    public void displayEditMode()
    {
        System.debug('CAS>>> displayEditMode');
        showEditPanel=true;
        showDisplayPanel=false;
    }


    public void hideCostsMode()
    {
        System.debug('CAS>>> hideCostsMode');
        showCosts=false;
    }


    public void showCostsMode()
    {
        System.debug('CAS>>> showCostsMode');
        showCosts=true;
    }
        
    private void getOLIs(Id oppId, String sortFullExp)
    {
        system.debug('CAS>>> getOLIs');
        String whereClause = 'OpportunityId__c=\'' + theOpp.Id + '\' ';
                
        List<OpportunityLineItem__c> olis = Database.query('SELECT  Implementor__c, Boris_code__c, boris_voltage__c, Unit_Of_Measure_ref__c, Product_Text__c, Total_Sell__c, Total_Sell_Rate__c, Total_Cost__c, Total_Kit_Sell__c, Sell_Rate__c, '+
                 'Product_Family__c, Quantity__c, Kit_Sell__c, Prod_Code__c, UnitPrice__c, Labour_Cost__c, Plant_Sell_calc__c, Plant_Cost__c, Material_Sell_calc__c, Material_Cost__c, Sort_Order__c, ' + 
                 'Product2Id__r.Name, Product2Id__r.Sort__c, Product2Id__r.boris_code__c, Product2Id__r.boris_voltage__c, Product2Id__r.Unit_Of_Measure__c, Product2Id__r.ProductCode, Product2Id__r.Family, Product2Id__r.Allow_Multiple_Products__c, Product2Id__r.kit_Sell__c, ' +    
                 'SSEN_Quantity__c, SSEN_Product_description__c, SSEN_Cost__c, Quantity_Difference__c, Qty_Diff_Reason__c ' +                  
                 'FROM opportunityLineItem__c '+
                 'WHERE '+whereClause+                  
                 'ORDER BY '+sortFullExp+'');    
        
        // load into page structure...
          rows = new List<rowItem>();
          for(OpportunityLineItem__c oli :olis)
          rows.add(new rowItem(count++, oli, oli.Product2Id__r.Family, oli.Product2Id__r.Allow_Multiple_Products__c));
    }
    
    private void getOpp(Id oppId)
    {
            theOpp = [SELECT Id, CloseDate, Total_Labour_Cost_Custom__c, Total_Plant_Cost_Custom__c, Total_Material_Cost_Custom__c, Total_Labour_Sell_Custom__c, Total_Plant_Sell_Custom__c, Total_Material_Sell_Custom__c, Total_Kit_Sell_Custom__c, Overall_Sell_Custom__c, Overall_Cost_Custom__c,  Charger_Point_Provider__c, Utilities__c, Total_Client_Contribution_custom__c, type FROM Opportunity WHERE Id = :oppId LIMIT 1];
    }

    private void debugShoppingCart()
    {
        system.debug('CAS>>> ShoppingBasket');
        for(rowItem row :rows)
        {
            system.debug('CAS>>> row = '+row.rowId);
            system.debug('CAS>>> id = '+row.oli.id);
            system.debug('CAS>>> Labour Sell = '+row.oli.UnitPrice__c);
            system.debug('CAS>>> Labour Cost = '+row.oli.Labour_Cost__c);
        }
    }
    
    private String getWhereClause(String searchKeyWord) 
    {
       String[] searchWordslst = searchKeyWord.split(' ');
        String whereClause;
        Integer idx=0;
        for(String sWord : searchWordslst)
        {
            if(idx == 0)
            {
                whereClause = '(Name LIKE \'%'+sWord+'%\' OR boris_code__c LIKE \'%'+sWord+'%\')';   
            }
            else
            {
                whereClause = whereClause+' AND (Name LIKE \'%'+sWord+'%\' OR boris_code__c LIKE \'%'+sWord+'%\')';        
            } 
            idx++;
        }
        return whereClause;            
    }  
}
public with sharing class opportunityProductEntryExtension 
{
    public Opportunity theOpp {get;set;}
    public String searchString {get;set;}
    public Boolean showEditPanel{get;set;}
    public Boolean showDisplayPanel{get;set;}
    public Boolean showCosts{get;set;}
    public List<rowItem> rows {get;set;}
    public String selectedRowId {get;set;}
    private Integer count = 0;
    public priceBookEntry[] AvailableProducts {get;set;}
    
    // public List<site_scheme__c> chargerSiteSchemes{get;set;} 

    // Only first row returned for each scheme
    public site_scheme__c chargerSiteScheme{get;set;} 
    public site_scheme__c StreetLightingSiteScheme{get;set;} 
    public site_scheme__c GasSiteScheme{get;set;} 
    public site_scheme__c WaterSiteScheme{get;set;} 
    public site_scheme__c ElectricSiteScheme{get;set;} 

    public Pricebook2 theBook {get;set;}   
    public integer counter=0;  //keeps track of the offset
    private integer list_size=20; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    public String toSelect {get; set;}
    //public String toUnselect {get; set;}
    public Decimal Total {get;set;}
    public string sortFullExp;
    public Boolean overLimit {get;set;}
    public Boolean multipleCurrencies {get; set;}    
    private string sortDirection='ASC';
    private string sortExp='Product2.Sort__c';
    private Boolean forcePricebookSelection = false;    
    private opportunityLineItem[] forDeletion = new opportunityLineItem[]{};   

    public class rowItem
    {
        // recCount acts as a index for a row. This will be helpful to identify the row to be deleted   
        public String rowId{get;set;}
        public opportunityLineItem oli{get;set;}
        public String family{get;set;}
        //public Id vendorId;
        //public String Stream;
        public Integer rowCount;
        public Boolean multiple {get;set;}
        
        // Row item constructor
        public rowItem(Integer count, OpportunityLineItem theOli, String theFamily, Boolean theMultiples)
        {            
            rowId = String.valueOf(count);
            rowCount = count;
            
            // create a new oli          
            oli = theOli;
            family = theFamily;
            multiple = theMultiples;
            //vendorId = oli.Vendor__c;
            //Stream = oli.Stream__c;
        }
    }

    public String sortField 
    {
        get 
        { 
            if (sortField == null) 
                sortField = 'Product2.Sort__c';
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

    public opportunityProductEntryExtension(ApexPages.StandardController controller) 
    {        
        System.debug('CAS>>> opportunityProductEntryExtension');
        rows = new List<rowItem>();
        
        // initialise deletion list
        forDeletion.clear();
        
        // Need to know if org has multiple currencies enabled
        multipleCurrencies = UserInfo.isMultiCurrencyOrganization();

        // Get information about the Opportunity being worked on
        getOpp(controller.getRecord().Id);

        ViewData();
                
        // Check if Opp has a pricebook associated yet
        if(theOpp.Pricebook2Id == null)
        {
            Pricebook2[] activepbs = [SELECT Id, Name FROM Pricebook2 WHERE isActive = true LIMIT 2];
            if(activepbs.size() == 2)
            {
                forcePricebookSelection = true;
                theBook = new Pricebook2();
            }
            else
            {
                theBook = activepbs[0];
            }
        }
        else
        {
            theBook = theOpp.Pricebook2;
        }
        
        if(!forcePricebookSelection)
            updateAvailableList();
        
        showEditPanel=false;
        showDisplayPanel=true;
        showCosts=false;
        
             
                 
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
          
         if(!chargerSiteScheme.isEmpty())
            {
            //Avoid error being displayed
            } 
            
            
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
    
    
    // this is the 'action' method on the page
    public PageReference priceBookCheck()
    {
        System.debug('CAS>>> priceBookCheck');
        // if the user needs to select a pricebook before we proceed we send them to standard pricebook selection screen
        if(forcePricebookSelection)
        {        
            return changePricebook();
        }
        else
        {
            // if there is only one active pricebook we go with it and save the opp
            if(theOpp.pricebook2Id != theBook.Id)
            {
                try
                {
                    theOpp.Pricebook2Id = theBook.Id;
                    update(theOpp);
                }
                catch(Exception e)
                {
                    ApexPages.addMessages(e);
                }
            }
            
            return null;
        }
    }

   
    
    public String getChosenCurrency()
    {
        if(multipleCurrencies)
            return (String)theOpp.get('CurrencyIsoCode');
        else
            return '';
    }

    
    public void updateAvailableList() 
    {
        System.debug('CAS>>> updateAvailableList');
        System.debug(theBook);
        System.debug('CAS>>> point 1');
        debugShoppingCart();
        
        // We dynamically build a query string and exclude items already in the shopping cart
        String qString = '';
        if(!Test.isrunningTest())
        {
            qString = 'SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Sort__c, Product2.Family, Product2.ProductCode, Product2.IsActive, Product2.Allow_Multiple_Products__c, Product2.Description, Product2.Kit_Sell__c, UnitPrice, Labour_Sell_del__c, Labour_Cost__c, Material_Sell_del__c, Material_Cost_del__c, Kit_Sell__c, Plant_Sell_del__c, Plant_Cost_del__c, Subcontractor_Cost__c, Product2.Implementor__c '+
                      'FROM PricebookEntry '+
                      'WHERE Product2.IsActive = true AND IsActive = true AND Product2.IS_KIT__C = true AND Pricebook2Id = \'' + theBook.Id + '\'';
        } 
        else 
        {
             qString = 'SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Sort__c, Product2.Family, Product2.ProductCode, Product2.IsActive, Product2.Allow_Multiple_Products__c, Product2.Description, Product2.Kit_Sell__c, UnitPrice, Labour_Sell_del__c, Labour_Cost__c, Material_Sell_del__c, Material_Cost_del__c, Kit_Sell__c, Plant_Sell_del__c, Plant_Cost_del__c,  Subcontractor_Cost__c, Product2.Implementor__c '+
                       'FROM PricebookEntry '+
                       'WHERE Product2.IsActive = true AND IsActive = true AND Product2.IS_KIT__C = true AND Pricebook2Id = \'' + theOpp.Pricebook2id + '\'';
        }    
        if(multipleCurrencies)
            qstring += ' and CurrencyIsoCode = \'' + theOpp.get('currencyIsoCode') + '\'';
        
        // note that we are looking for the search string entered by the user in the name OR description
        // modify this to search other fields if desired
        if(searchString!=null)
        {
            qString += ' AND ('+getWhereClause(searchString)+')';
            //qString+= ' and (Product2.Name like \'%' + searchString + '%\' or Product2.Description like \'%' + searchString + '%\')';
        }
        System.debug('CAS>>> point 2');
        debugShoppingCart();
        
        Set<Id> selectedEntries = new Set<Id>();
        for(rowItem d:rows)
        {
            if(!d.multiple)
                selectedEntries.add(d.oli.PricebookEntryId);
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

        System.debug(qString);
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
        for(PricebookEntry d : AvailableProducts)
        {
            if(Test.isRunningTest())
               toSelect= (String)d.Id;
            
            if((String)d.Id == toSelect)
            {
                Decimal LabourCost = d.Labour_Cost__c;
                if(d.Product2.Implementor__c == 'Subcontractor')
                    LabourCost = d.Subcontractor_Cost__c;
                rows.add(new rowItem(count++, new opportunityLineItem(
                                                         OpportunityId      = theOpp.Id, 
                                                         Product_Text__c    = d.Product2.Name,
                                                         PriceBookEntry     = d, 
                                                         PriceBookEntryId   = d.Id, 
                                                         Quantity__c        = 0,    // default is zero!
                                                         Quantity           = 1,    // not used, but to keep SFDC happy...
                                                         Implementor__c     = d.Product2.Implementor__c,
                                                         Kit_Sell__c        = d.Kit_Sell__c,
                                                         UnitPrice          = d.Labour_Sell_del__c,
                                                         Labour_Cost__c     = LabourCost,
                                                         Plant_Sell__c      = d.Plant_Sell_del__c,
                                                         Plant_Cost__c      = d.Plant_Cost_del__c,
                                                         Material_Sell__c   = d.Material_Sell_del__c,
                                                         Material_Cost__c   = d.Material_Cost_del__c), d.Product2.Family, d.Product2.Allow_Multiple_Products__c));
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
        addFamilyProductsChargePoints(theOpp.Charger_Point_Provider__c);
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
                rows[idx].oli.Labour_Cost__c = rows[idx].oli.UnitPrice;
                return null;
            }
        }
        return null;
    }
    
    
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
                
                // update the labour cost to labour sell price
                rows[idx].oli.Material_Cost__c = rows[idx].oli.Material_Sell__c;
                return null;
            }
        }
        return null;
    }

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
                rows[idx].oli.Plant_Cost__c = rows[idx].oli.Plant_Sell__c;
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
                rows[idx].oli.UnitPrice = rows[idx].oli.Labour_Cost__c;
                return null;
            }
        }
        return null;
    }
 
    
    public PageReference updateToMaterialCostValue()
    {
        // Material Cost value has been updated, if non-contestable update the Material Sell price to match.
        system.debug('CAS>>> updateToMaterialCostValue');
        for(Integer idx = 0; idx<rows.size(); idx++)
        {
            if(rows[idx].rowId == selectedRowId)
            {
                if(rows[idx].oli.Product_Family__c != 'Non-Contestable')
                    return null;   // we only want non-contestables!
                
                // update the labour cost to labour sell price
                rows[idx].oli.Material_Sell__c = rows[idx].oli.Material_Cost__c;
                return null;
            }
        }
        return null;
    }
    
    
    public PageReference updateToPlantCostValue()
    {
        // Plant Cost value has been updated, if non-contestable update the Plant Sell price to match.
        system.debug('CAS>>> updateToPlantCostValue');
        for(Integer idx = 0; idx<rows.size(); idx++)
        {
            if(rows[idx].rowId == selectedRowId)
            {
                if(rows[idx].oli.Product_Family__c != 'Non-Contestable')
                    return null;   // we only want non-contestables!
                
                // update the labour cost to labour sell price
                rows[idx].oli.Plant_Sell__c = rows[idx].oli.Plant_Cost__c;
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
                system.debug('CAS>>> updateCostValue: Labour Cost = '+rows[idx].oli.PriceBookEntry.Labour_Cost__c);
                system.debug('CAS>>> updateCostValue: Subcontractor Cost = '+rows[idx].oli.PriceBookEntry.Subcontractor_Cost__c);
                system.debug('CAS>>> updateCostValue: Implementor = '+rows[idx].oli.Implementor__c);
                
                // update the labour cost according to implementor setting...
                rows[idx].oli.Labour_Cost__c = rows[idx].oli.PriceBookEntry.Labour_Cost__c;
                if(rows[idx].oli.Implementor__c == 'Subcontractor')
                    rows[idx].oli.Labour_Cost__c = rows[idx].oli.PriceBookEntry.Subcontractor_Cost__c;
                break;
            }
        }
    }

    
    
    public void addFamilyProducts(String family)
    {
        System.debug('CAS>>> addFamily('+family+')');
        
        // This function runs when a user hits "select" button next to a product
        for(PricebookEntry pbe : [SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Sort__c, Product2.Family, Product2.ProductCode, Product2.IsActive, Product2.Description, Product2.Allow_Multiple_Products__c, Subcontractor_Cost__c, Product2.Implementor__c,
                                Kit_Sell__c, UnitPrice, Labour_Sell_del__c, Labour_Cost__c, Material_Sell_del__c, Material_Cost_del__c, Plant_Sell_del__c, 
                                Plant_Cost_del__c 
                                FROM PricebookEntry 
                                WHERE Product2.IsActive = true
                                AND Product2.IS_KIT__C = true
                                AND Product2.Family = :family
                                AND Product2.Core_Product__c = true
                                AND IsActive = true 
                                AND Pricebook2Id = :theOpp.Pricebook2id
                                ORDER BY Product2.Sort__c ])
 
        {
            // check to see if already added
            Boolean found = false;
            for(rowItem row :rows)
            {
                if(row.oli.PricebookEntryId == pbe.id)
                {
                    found = true;
                    break;
                }
            }
            
            if(!found)
            {
                Decimal LabourCost = pbe.Labour_Cost__c;
                if(pbe.Product2.Implementor__c == 'Subcontractor')
                    LabourCost = pbe.Subcontractor_Cost__c;

                rows.add(new rowItem(count++, new opportunityLineItem(
                                                    OpportunityId      = theOpp.Id, 
                                                    Product_Text__c    = pbe.Product2.Name,
                                                    PriceBookEntry     = pbe, 
                                                    PriceBookEntryId   = pbe.Id, 
                                                    Quantity__c        = 0,
                                                    Quantity           = 1,   /// not used
                                                    Kit_Sell__c        = pbe.Kit_Sell__c,
                                                    UnitPrice          = pbe.Labour_Sell_del__c,
                                                    Labour_Cost__c     = LabourCost,
                                                    Plant_Sell__c      = pbe.Plant_Sell_del__c,
                                                    Plant_Cost__c      = pbe.Plant_Cost_del__c,
                                                    Material_Sell__c   = pbe.Material_Sell_del__c,
                                                    Material_Cost__c   = pbe.Material_Cost_del__c), pbe.Product2.Family, pbe.Product2.Allow_Multiple_Products__c));
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
            for(PricebookEntry pbe : [SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Sort__c, Product2.Family, Product2.ProductCode, Product2.IsActive, Product2.Description, Product2.Allow_Multiple_Products__c, Subcontractor_Cost__c, Product2.Implementor__c,
                                      Kit_Sell__c, UnitPrice, Labour_Sell_del__c, Labour_Cost__c, Material_Sell_del__c, Material_Cost_del__c, Plant_Sell_del__c, Plant_Cost_del__c, 
                                      Product2.work_zone__c, Product2.Adopter__c
                                      FROM PricebookEntry 
                                      WHERE Product2.IsActive = true
                                      AND Product2.IS_KIT__C = true
                                      AND Product2.Core_Product__c = true
                                      AND Pricebook2Id = :theOpp.Pricebook2id
                                      AND Product2.Family = :chargerSiteScheme.charger_provider__c
                                      AND (
                                            (Product2.Adopter__c = :chargerSiteScheme.idno__c AND
                                             Product2.work_zone__c = 'Onsite') OR
                                             
                                            (Product2.Adopter__c = :chargerSiteScheme.dno__c AND
                                             Product2.work_zone__c = 'Offsite') OR 
                                             
                                            (Product2.Adopter__c = :chargerSiteScheme.idno__c AND
                                             Product2.work_zone__c = 'Both') OR
                                             
                                            (Product2.Adopter__c = :chargerSiteScheme.dno__c AND
                                             Product2.work_zone__c = 'Both') OR
                                             
                                           (Product2.Adopter__c = :chargerSiteScheme.idno__c AND
                                             Product2.work_zone__c = '') OR
                                             
                                            (Product2.Adopter__c = :chargerSiteScheme.dno__c AND
                                             Product2.work_zone__c = '') OR
                                             
                                            (Product2.Adopter__c = ''))   
                                                                          
                                      ORDER BY Product2.Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.PricebookEntryId == pbe.id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pbe.Labour_Cost__c;
                    if(pbe.Product2.Implementor__c == 'Subcontractor')
                        LabourCost = pbe.Subcontractor_Cost__c;
                    
                    rows.add(new rowItem(count++, new opportunityLineItem(
                        OpportunityId      = theOpp.Id, 
                        Product_Text__c    = pbe.Product2.Name,
                        PriceBookEntry     = pbe, 
                        PriceBookEntryId   = pbe.Id, 
                        Quantity__c        = 0,
                        Quantity           = 1,   /// not used
                        Kit_Sell__c        = pbe.Kit_Sell__c,
                        UnitPrice          = pbe.Labour_Sell_del__c,
                        Labour_Cost__c     = LabourCost,
                        Plant_Sell__c      = pbe.Plant_Sell_del__c,
                        Plant_Cost__c      = pbe.Plant_Cost_del__c,
                        Material_Sell__c   = pbe.Material_Sell_del__c,
                        Material_Cost__c   = pbe.Material_Cost_del__c), pbe.Product2.Family, pbe.Product2.Allow_Multiple_Products__c));
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
            for(PricebookEntry pbe : [SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Sort__c, Product2.Family, Product2.ProductCode, Product2.IsActive, Product2.Description, Product2.Allow_Multiple_Products__c, Subcontractor_Cost__c, Product2.Implementor__c,
                                      Kit_Sell__c, UnitPrice, Labour_Sell_del__c, Labour_Cost__c, Material_Sell_del__c, Material_Cost_del__c, Plant_Sell_del__c, Plant_Cost_del__c, 
                                      Product2.work_zone__c, Product2.Adopter__c
                                      FROM PricebookEntry 
                                      WHERE Product2.IsActive = true
                                      AND Product2.IS_KIT__C = true
                                      AND Product2.Core_Product__c = true
                                      AND Pricebook2Id = :theOpp.Pricebook2id
                                      AND Product2.Family = 'Street Lighting'
                                      AND (
                                            (Product2.Adopter__c = :StreetLightingSiteScheme.idno__c AND
                                             Product2.work_zone__c = 'Onsite') OR
                                             
                                            (Product2.Adopter__c = :StreetLightingSiteScheme.dno__c AND
                                             Product2.work_zone__c = 'Offsite') OR 
                                             
                                            (Product2.Adopter__c = :StreetLightingSiteScheme.idno__c AND
                                             Product2.work_zone__c = 'Both') OR
                                             
                                            (Product2.Adopter__c = :StreetLightingSiteScheme.dno__c AND
                                             Product2.work_zone__c = 'Both') OR
                                             
                                            (Product2.Adopter__c = :StreetLightingSiteScheme.idno__c AND
                                             Product2.work_zone__c = '') OR
                                             
                                            (Product2.Adopter__c = :StreetLightingSiteScheme.dno__c AND
                                             Product2.work_zone__c = '') OR
                                             
                                         (Product2.Adopter__c = ''))      
                                                                          
                                      ORDER BY Product2.Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.PricebookEntryId == pbe.id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pbe.Labour_Cost__c;
                    if(pbe.Product2.Implementor__c == 'Subcontractor')
                        LabourCost = pbe.Subcontractor_Cost__c;
                    
                    rows.add(new rowItem(count++, new opportunityLineItem(
                        OpportunityId      = theOpp.Id, 
                        Product_Text__c    = pbe.Product2.Name,
                        PriceBookEntry     = pbe, 
                        PriceBookEntryId   = pbe.Id, 
                        Quantity__c        = 0,
                        Quantity           = 1,   /// not used
                        Kit_Sell__c        = pbe.Kit_Sell__c,
                        UnitPrice          = pbe.Labour_Sell_del__c,
                        Labour_Cost__c     = LabourCost,
                        Plant_Sell__c      = pbe.Plant_Sell_del__c,
                        Plant_Cost__c      = pbe.Plant_Cost_del__c,
                        Material_Sell__c   = pbe.Material_Sell_del__c,
                        Material_Cost__c   = pbe.Material_Cost_del__c), pbe.Product2.Family, pbe.Product2.Allow_Multiple_Products__c));
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
        //    System.debug('CAS>>> site scheme('+GasSiteScheme.No_of_Units__c+')');
                
            // This function runs when a user hits "select" button next to a product
            for(PricebookEntry pbe : [SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Sort__c, Product2.Family, Product2.ProductCode, Product2.IsActive, Product2.Description, Product2.Allow_Multiple_Products__c, Subcontractor_Cost__c, Product2.Implementor__c,
                                      Kit_Sell__c, UnitPrice, Labour_Sell_del__c, Labour_Cost__c, Material_Sell_del__c, Material_Cost_del__c, Plant_Sell_del__c, Plant_Cost_del__c, 
                                      Product2.work_zone__c, Product2.Adopter__c
                                      FROM PricebookEntry 
                                      WHERE Product2.IsActive = true
                                      AND Product2.IS_KIT__C = true
                                      AND Product2.Core_Product__c = true
                                      AND Pricebook2Id = :theOpp.Pricebook2id
                                      AND Product2.Family = 'Gas'
                                      AND (
                                            (Product2.Adopter__c = :GasSiteScheme.IGT__c AND
                                             Product2.work_zone__c = 'Onsite') OR
                                             
                                            (Product2.Adopter__c = :GasSiteScheme.GT__c AND
                                             Product2.work_zone__c = 'Offsite') OR 
                                             
                                            (Product2.Adopter__c = :GasSiteScheme.IGT__c AND
                                             Product2.work_zone__c = 'Both') OR
                                             
                                            (Product2.Adopter__c = :GasSiteScheme.GT__c AND
                                             Product2.work_zone__c = 'Both') OR
                                             
                                                                                         
                                            (Product2.Adopter__c = :GasSiteScheme.GT__c AND
                                             Product2.work_zone__c = '') OR 
                                             
                                            (Product2.Adopter__c = :GasSiteScheme.IGT__c AND
                                             Product2.work_zone__c = '') OR 
                                             
                                             
                                         (Product2.Adopter__c = ''))                                                   
                                                                          
                                      ORDER BY Product2.Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.PricebookEntryId == pbe.id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pbe.Labour_Cost__c;
                    if(pbe.Product2.Implementor__c == 'Subcontractor')
                        LabourCost = pbe.Subcontractor_Cost__c;
                    
                    rows.add(new rowItem(count++, new opportunityLineItem(
                        OpportunityId      = theOpp.Id, 
                        Product_Text__c    = pbe.Product2.Name,
                        PriceBookEntry     = pbe, 
                        PriceBookEntryId   = pbe.Id, 
                        Quantity__c        = 0,
                        Quantity           = 1,   /// not used
                        Kit_Sell__c        = pbe.Kit_Sell__c,
                        UnitPrice          = pbe.Labour_Sell_del__c,
                        Labour_Cost__c     = LabourCost,
                        Plant_Sell__c      = pbe.Plant_Sell_del__c,
                        Plant_Cost__c      = pbe.Plant_Cost_del__c,
                        Material_Sell__c   = pbe.Material_Sell_del__c,
                        Material_Cost__c   = pbe.Material_Cost_del__c), pbe.Product2.Family, pbe.Product2.Allow_Multiple_Products__c));
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
    //        System.debug('CAS>>> site scheme('+ElectricSiteScheme.No_of_Units__c+')');
                
            // This function runs when a user hits "select" button next to a product
            for(PricebookEntry pbe : [SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Sort__c, Product2.Family, Product2.ProductCode, Product2.IsActive, Product2.Description, Product2.Allow_Multiple_Products__c, Subcontractor_Cost__c, Product2.Implementor__c,
                                      Kit_Sell__c, UnitPrice, Labour_Sell_del__c, Labour_Cost__c, Material_Sell_del__c, Material_Cost_del__c, Plant_Sell_del__c, Plant_Cost_del__c, 
                                      Product2.work_zone__c, Product2.Adopter__c
                                      FROM PricebookEntry 
                                      WHERE Product2.IsActive = true
                                      AND Product2.IS_KIT__C = true
                                      AND Product2.Core_Product__c = true
                                      AND Pricebook2Id = :theOpp.Pricebook2id
                                      AND Product2.Family = 'Electricity'
                                      AND (
                                            (Product2.Adopter__c = :ElectricSiteScheme.idno__c AND
                                             Product2.work_zone__c = 'Onsite') OR
                                             
                                            (Product2.Adopter__c = :ElectricSiteScheme.dno__c AND
                                             Product2.work_zone__c = 'Offsite') OR 
                                             
                                            (Product2.Adopter__c = :ElectricSiteScheme.idno__c AND
                                             Product2.work_zone__c = 'Both') OR
                                             
                                            (Product2.Adopter__c = :ElectricSiteScheme.dno__c AND
                                             Product2.work_zone__c = 'Both') OR
                                             
                                            (Product2.Adopter__c = :ElectricSiteScheme.idno__c AND
                                             Product2.work_zone__c = '') OR
                                             
                                            (Product2.Adopter__c = :ElectricSiteScheme.dno__c AND
                                             Product2.work_zone__c = '') OR
                                             
                                         (Product2.Adopter__c = ''))      
                                                                          
                                      ORDER BY Product2.Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.PricebookEntryId == pbe.id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pbe.Labour_Cost__c;
                    if(pbe.Product2.Implementor__c == 'Subcontractor')
                        LabourCost = pbe.Subcontractor_Cost__c;
                    
                    rows.add(new rowItem(count++, new opportunityLineItem(
                        OpportunityId      = theOpp.Id, 
                        Product_Text__c    = pbe.Product2.Name,
                        PriceBookEntry     = pbe, 
                        PriceBookEntryId   = pbe.Id, 
                        Quantity__c        = 0,
                        Quantity           = 1,   /// not used
                        Kit_Sell__c        = pbe.Kit_Sell__c,
                        UnitPrice          = pbe.Labour_Sell_del__c,
                        Labour_Cost__c     = LabourCost,
                        Plant_Sell__c      = pbe.Plant_Sell_del__c,
                        Plant_Cost__c      = pbe.Plant_Cost_del__c,
                        Material_Sell__c   = pbe.Material_Sell_del__c,
                        Material_Cost__c   = pbe.Material_Cost_del__c), pbe.Product2.Family, pbe.Product2.Allow_Multiple_Products__c));
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
            for(PricebookEntry pbe : [SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Sort__c, Product2.Family, Product2.ProductCode, Product2.IsActive, Product2.Description, Product2.Allow_Multiple_Products__c, Subcontractor_Cost__c, Product2.Implementor__c,
                                      Kit_Sell__c, UnitPrice, Labour_Sell_del__c, Labour_Cost__c, Material_Sell_del__c, Material_Cost_del__c, Plant_Sell_del__c, Plant_Cost_del__c, 
                                      Product2.work_zone__c, Product2.Adopter__c
                                      FROM PricebookEntry 
                                      WHERE Product2.IsActive = true
                                      AND Product2.IS_KIT__C = true
                                      AND Product2.Core_Product__c = true
                                      AND Pricebook2Id = :theOpp.Pricebook2id
                                      AND Product2.Family = 'Water'
                                      AND ( 
                                         (Product2.Adopter__c = :WaterSiteScheme.Water_Provider__c AND
                                          Product2.work_zone__c = :WaterSiteScheme.Pipe_type__c) OR
                                             
                                         (Product2.Adopter__c = '' AND
                                         Product2.work_zone__c = :WaterSiteScheme.Pipe_type__c) OR
                                         
                                         (Product2.Adopter__c = :WaterSiteScheme.Water_Provider__c AND
                                          Product2.work_zone__c = '') OR
                                         
                                         (Product2.Adopter__c = '' AND
                                         Product2.work_zone__c = '')) 
                      
                                      ORDER BY Product2.Sort__c ])
                
            {
                // check to see if already added
                Boolean found = false;
                for(rowItem row :rows)
                {
                    if(row.oli.PricebookEntryId == pbe.id)
                    {
                        found = true;
                        break;
                    }
                }
                
                if(!found)
                {
                    Decimal LabourCost = pbe.Labour_Cost__c;
                    if(pbe.Product2.Implementor__c == 'Subcontractor')
                        LabourCost = pbe.Subcontractor_Cost__c;
                    
                    rows.add(new rowItem(count++, new opportunityLineItem(
                        OpportunityId      = theOpp.Id, 
                        Product_Text__c    = pbe.Product2.Name,
                        PriceBookEntry     = pbe, 
                        PriceBookEntryId   = pbe.Id, 
                        Quantity__c        = 0,
                        Quantity           = 1,   /// not used
                        Kit_Sell__c        = pbe.Kit_Sell__c,
                        UnitPrice          = pbe.Labour_Sell_del__c,
                        Labour_Cost__c     = LabourCost,
                        Plant_Sell__c      = pbe.Plant_Sell_del__c,
                        Plant_Cost__c      = pbe.Plant_Cost_del__c,
                        Material_Sell__c   = pbe.Material_Sell_del__c,
                        Material_Cost__c   = pbe.Material_Cost_del__c), pbe.Product2.Family, pbe.Product2.Allow_Multiple_Products__c));
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
    
    
    /*public PageReference onVendorChange()
    {
        system.debug('CAS>>> onVendorChange');
        // update vendor Ids
        for(rowItem row :rows)
            row.VendorId = row.oli.vendor__c;
        
        return null;
    }*/
    
    
    /*public PageReference onStreamChange()
    {
        system.debug('CAS>>> onStreamChange');
        // update stream
        for(rowItem row :rows)
            row.stream = row.oli.Stream__c;
        
        return null;
    }*/

    
    public PageReference onSave()
    {    
        system.debug('CAS>>> onSave');
        system.debug('CAS>>> pre delete');
        debugShoppingCart();

        // If previously selected products are now removed, we need to delete them
        if(forDeletion.size()>0)
        {
            delete(forDeletion); 
            forDeletion.clear();
        }
                
        system.debug('CAS>>> Pre save');
        debugShoppingCart();
        
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for(rowItem row :rows)
        {
            OpportunityLineItem oli = row.oli;
            //oli.Vendor__c = row.vendorId;
            //oli.Stream__c = row.Stream;
            //oli.Sort_Order__c = row.rowCount;
            olis.add(oli);
        }

        if(olis.size()>0)
            upsert(olis);
        
        system.debug('CAS>>> Post save');
        debugShoppingCart();
                 
        //ViewData();

        // After save return to view mode
        //showEditPanel=false;
        //showDisplayPanel=true;
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
    
    
    public PageReference changePricebook()
    {    
        System.debug('CAS>>> changePricebook');
        // This simply returns a PageReference to the standard Pricebook selection screen
        // Note that is uses retURL parameter to make sure the user is sent back after they choose
    
        PageReference ref = new PageReference('/oppitm/choosepricebook.jsp');
        ref.getParameters().put('id',theOpp.Id);
        ref.getParameters().put('retURL','/apex/opportunityProductEntry?id=' + theOpp.Id);
        
        return ref;
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
        String whereClause = 'OpportunityId=\'' + theOpp.Id + '\' ';
                
        List<OpportunityLineItem> olis = Database.query('SELECT id, Implementor__c, Product_Text__c, Total_Sell__c, Total_Sell_Rate__c, Total_Cost__c, Total_Kit_Sell__c, '+
                              'Product_Family__c, Quantity__c, Kit_Sell__c, Prod_Code__c, UnitPrice, Labour_Cost__c, Plant_Sell__c, Plant_Sell_calc__c, Plant_Cost__c, Material_Sell__c, Material_Sell_calc__c, Material_Cost__c, '+ 
                              'Product2Id, Product2.Name, Product2.Sort__c, Product2.ProductCode, Product2.Family, Product2.Allow_Multiple_Products__c, Product2.Kit_Sell__c, Sell_Rate__c, '+                       
                              'PriceBookEntryId, PriceBookEntry.Name, PriceBookEntry.IsActive, PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.PriceBook2Id, PriceBookEntry.Labour_Cost__c, PriceBookEntry.Subcontractor_Cost__c '+
                              'FROM opportunityLineItem '+
                              'WHERE '+whereClause+
                              'ORDER BY '+sortFullExp+'');
        
        // load into page structure...
        rows = new List<rowItem>();
        for(OpportunityLineItem oli :olis)
            rows.add(new rowItem(count++,oli,oli.Product2.Family,oli.Product2.Allow_Multiple_Products__c));
    }
    
    private void getOpp(Id oppId)
    {
      if(multipleCurrencies)
            theOpp = database.query('SELECT Id, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode, CloseDate, Total_Labour_Cost__c, Total_Plant_Cost__c, Total_Material_Cost__c, Total_Labour_Sell__c, Total_Plant_Sell__c, Total_Material_Sell__c, Total_Kit_Sell__c, Overall_Sell__c, Overall_Cost__c, Total_Client_Contribution__c, Charger_Point_Provider__c FROM Opportunity WHERE Id = \'' + oppId + '\' LIMIT 1');
        else
            theOpp = [SELECT Id, Pricebook2Id, PriceBook2.Name, CloseDate, Total_Labour_Cost__c, Total_Plant_Cost__c, Total_Material_Cost__c, Total_Labour_Sell__c, Total_Plant_Sell__c, Total_Material_Sell__c, Total_Kit_Sell__c, Overall_Sell__c, Overall_Cost__c, Total_Client_Contribution__c, Charger_Point_Provider__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
    }

    private void debugShoppingCart()
    {
        system.debug('CAS>>> ShoppingBasket');
        for(rowItem row :rows)
        {
            system.debug('CAS>>> row = '+row.rowId);
            system.debug('CAS>>> id = '+row.oli.id);
            system.debug('CAS>>> Labour Sell = '+row.oli.UnitPrice);
            system.debug('CAS>>> Labour Cost = '+row.oli.Labour_Cost__c);
            //system.debug('CAS>>> stream = '+row.oli.Stream__c);
            //system.debug('CAS>>> Product = '+row.oli.product2id +' ('+row.oli.product2.name+')');
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
                whereClause = '(Product2.Name LIKE \'%'+sWord+'%\' OR Product2.ProductCode LIKE \'%'+sWord+'%\')';   
            }
            else
            {
                whereClause = whereClause+' AND (Product2.Name LIKE \'%'+sWord+'%\' OR Product2.ProductCode LIKE \'%'+sWord+'%\')';        
            } 
            idx++;
        }
        return whereClause;            
    }


    
}
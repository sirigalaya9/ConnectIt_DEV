public class SupplierSearchController {

    @AuraEnabled
	public static List <SupplierProductWrapper> fetchData(String searchKeyWord) {
        String queryStr = 'SELECT Id, Name, Supplier__r.Name FROM Supplier_Product__c WHERE Salesforce_Product__c = NULL AND Active__c = true AND ';
        String whereClause = getWhereClause(searchKeyWord);
        String recordLimit = ' LIMIT 20';
        queryStr=queryStr+whereClause+recordLimit;
 		List <SupplierProductWrapper> returnList = new List <SupplierProductWrapper> ();
 		List <Supplier_Product__c > lstOfProduct = Database.query(queryStr);
		for (Supplier_Product__c sp: lstOfProduct) {
        	returnList.add(new SupplierProductWrapper(sp.Id,sp.Name,sp.Supplier__r.Name));
  		}
 		return returnList;
	}
    
    @auraEnabled
    public static void updateSalesforceProduct(String parentId, String supplierProducts){
        try {
        	system.debug('R3 - Salesforce Product ID: ' + parentId);
        	system.debug('R3 - JSON of search products: ' + supplierProducts); 
        
            List<Supplier_Product__c> selectedProducts = new List<Supplier_Product__c>();
        	List<SupplierProductWrapper> lstofRecs = (List<SupplierProductWrapper>) System.JSON.deserialize(supplierProducts, List<SupplierProductWrapper>.class);        
        
            system.debug(lstofRecs.size() +'-----> Debug for Displaying data '+ lstofRecs);
        
            for(SupplierProductWrapper a : lstofRecs){
            	if(a.isSelected){
                	Supplier_Product__c sp =  new Supplier_Product__c(Id = a.SupplierProductId, Salesforce_Product__c=parentId);
                	selectedProducts.add(sp);
            	}
        	}
            // update supplier product records with parent salesforce product
        	if(!selectedProducts.isEmpty()) update selectedProducts;
            
        }    
        catch (Exception e) {
        	throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage());    
   		}
    }
    
	public static String getWhereClause(String searchKeyWord) {
		String[] searchWordslst = searchKeyWord.split(' ');
		String whereClause;
		Integer i=0;
		for(String sWord : searchWordslst){
    		if(i==0){
    			whereClause = 'Name LIKE \'%'+sWord+'%\'';    
    		}else{
        		whereClause = whereClause+' AND Name LIKE \'%'+sWord+'%\'';        
   			 } 
    	i++;
		}
		return whereClause;            
    }
/*
    @AuraEnabled
	public static List <SupplierProductWrapper> fetchData(String searchKeyWord) {
 		String searchKey = '%' +searchKeyWord+ '%';
 		List <SupplierProductWrapper> returnList = new List <SupplierProductWrapper> ();
 		List <Supplier_Product__c > lstOfProduct = [SELECT Id, Name, Supplier__r.Name FROM Supplier_Product__c WHERE Salesforce_Product__c = NULL AND Active__c = true AND Name LIKE :searchKey LIMIT 10];
		for (Supplier_Product__c sp: lstOfProduct) {
        	returnList.add(new SupplierProductWrapper(sp.Id,sp.Name,sp.Supplier__r.Name));
  		}
 		return returnList;
	}
*/
}
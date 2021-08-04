public class SupplierProductWrapper {

        @AuraEnabled
        public Id SupplierProductId {get; set;}
        @AuraEnabled
        public String SupplierProductName {get; set;}
        @AuraEnabled
        public String SupplierName {get; set;}
        @AuraEnabled 
        public boolean isSelected = false;
        
        public SupplierProductWrapper(Id SupplierProductId, String SupplierProductName, String SupplierName){
            this.SupplierProductId = SupplierProductId;
            this.SupplierProductName = SupplierProductName;
            this.SupplierName  = SupplierName ;
            this.isSelected = false;
        }
}
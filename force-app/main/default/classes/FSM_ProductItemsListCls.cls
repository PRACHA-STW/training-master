public with sharing class FSM_ProductItemsListCls {

    
    @AuraEnabled(cacheable=true)
    public static List<Schema.Location> getlocationNames(){
        List<Schema.Location> locationlst = new List<Schema.Location>();
        List<String> locnames=new List<String> ();
      
        locationlst =[Select id,Name from Location where LocationType ='Warehouse' AND IsInventoryLocation =true WITH SECURITY_ENFORCED];
        if(locationlst.size()>0){
        for(Schema.Location ln:locationlst){
            locnames.add(ln.Name);
        }
            return locationlst;
        }else{
            return null;
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductItem> getProductItems(){
        List<Schema.Location> locationlst = new List<Schema.Location>();
        List<String> locnames=new List<String> ();
        List<ProductItem> productlst = new List<ProductItem>();
        locationlst =[Select id,Name from Location where LocationType ='Warehouse' AND IsInventoryLocation =true WITH SECURITY_ENFORCED];
        if(locationlst.size()>0){
            for(Schema.Location ln:locationlst){
            locnames.add(ln.Name);
        }
        productlst=[Select id,Location.Name,LocationId,ProductName,QuantityOnHand from ProductItem where Location.Name IN:locnames AND QuantityOnHand >0 WITH SECURITY_ENFORCED]; 
        return productlst;
        }else{
                   return null; 
        }
       

    }

}
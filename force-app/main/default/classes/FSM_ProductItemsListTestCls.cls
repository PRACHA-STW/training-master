/*@author: Aishwarya Bhosale
@Date: 02/05/24
@comments: this is test class for FSM_ProductItemsListCls

*/
@isTest
public class FSM_ProductItemsListTestCls {
 @TestSetup
    static void testDataSetup(){
        Product2 product = new FSM_TestDataFactory.ProductCreator().setName('Gloves').setprodcode('PR-005').setexternalid('1000224').setactive(true).create();
        Schema.Location location=new FSM_TestDataFactory.LocationCreator().setName('Hucknal Store').setloctype('Warehouse').setinventory(true).create();
    	ProductItem proditem=new FSM_TestDataFactory.ProductItemCreator().setlocation(location.Id).setproduct(product.Id).setquantity(50).create();
    }
    
    @isTest
    public static void testproductsConsumed() {   
      
        Test.startTest();
        FSM_ProductItemsListCls.getlocationNames();
        FSM_ProductItemsListCls.getProductItems();
        Test.stopTest();
    }
}
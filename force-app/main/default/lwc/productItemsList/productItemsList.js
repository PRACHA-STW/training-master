import { LightningElement, wire, api, track } from 'lwc';
import getlocdata from '@salesforce/apex/FSM_ProductItemsListCls.getlocationNames';
import getproductitems from '@salesforce/apex/FSM_ProductItemsListCls.getProductItems';
import { createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ProductConsumed from '@salesforce/schema/ProductConsumed';
export default class ProductItemsList extends LightningElement {
    locationrecords;
    //locationoptions=[];
    items = [];
    searchTerm = '';
    products = [];
    productData = [];
    productfilter = [];
    selectedproducts;
    productrecords;
    selectedlocation;
    error;
    pcid;
    cancelclick = false;
    recipientname;
    newarr = [];
    datascreen3 = {};
    filteredproductitems = {};
    originalproductlist = {};
    searchproductitems = {};
    @api recordId;
    recordsuccess = false;
    sectionone = true;
    sectiontwo = false;
    sectionthree = false;
    selectedRows = [];
    selectedOpp = [];
    selectedOption;
    selectedRowIds = [];
    selectedData = [];
    errormsg = false;
    @track isValidQuantity;
    @track isMoreThanAvialableQty;
    get isEnableSubmit() {
        if (this.sectionthree == true) {
            return true;
        }
        else {
            return false;
        }
    }

    get isEnableNext() {
        if (this.sectionone == true || this.sectiontwo == true) {
            return true;
        }
        else {
            return false;
        }
    }
    get isEnableCancel() {
        if (this.sectionthree == true || this.sectionone == true || this.sectiontwo == true) {
            return true;
        }
        else {
            return false;
        }

    }



    handleNext() {
        if(this.sectionone && this.selectedlocation == null){
             this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Please enter Location",
                        variant: "error"
                    })
                );
        } else if (this.sectionone && this.selectedlocation!= null) {
            this.handleChangeNextScreen2();
            this.sectionone = false;
            this.sectiontwo = true;
            this.sectionthree = false;
        } else if (this.sectiontwo) {
            this.handleNextscreen3();
            this.sectionone = false;
            this.sectiontwo = false;
            this.sectionthree = true;
        } else {
            return;
        }

    }

    handleCancel() {
        this.cancelclick = true;
        this.sectionone = false;
        this.sectiontwo = false;
        this.sectionthree = false;
    }

    columns = [{ label: 'Product Name', fieldName: 'ProductName', type: 'text' }];

    columnseditableqty = [

        { label: 'Product Name', fieldName: 'ProductName', type: 'text' },
        { label: 'Quantity Required', fieldName: 'Quantity', type: 'number', editable: true },

    ];
    @wire(getproductitems)
    wiredProductList({ data, error }) {
        if (data) {

            for (let i = 0; i < data.length; i++) {
                this.products = [...this.products, {
                    Id: data[i].Id,
                    ProductName: data[i].ProductName
                }];
                this.productData = [...this.productData, {
                    Id: data[i].Id,
                    ProductName: data[i].ProductName,
                    Location: data[i].Location.Id,
                    quantityOnHand: data[i].QuantityOnHand,
                    isSelected: false //changes made as per SFL-709

                }];

            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }

    }
    handleRowSelection(event) {
      //  this.selectedOpp = event.detail.selectedRows;
       
        //changes made as per SFL-709
        this.selectedOption = event.detail.selectedRows;
        const newSelectedIds = this.selectedOption.map(row => row.Id);
        this.selectedOption=this.selectedOption.map(row=>{
            return {...row,isSelected:true};
        });
        console.log("selected optioins 000"+ JSON.stringify(this.selectedOption));
        const newSelections = this.selectedOption.filter(
            newRow => !this.selectedOpp.some(existing => existing.Id === newRow.Id)
        );
        if (newSelections.length > 0) {
            this.selectedOpp = [...this.selectedOpp, ...newSelections];
        }
        console.log("selectedOpp"+ JSON.stringify(this.selectedOpp));
        
        const deselectedIds =this.selectedRowIds.filter(Id=>!newSelectedIds.includes(Id));
                this.selectedOpp = this.selectedOpp.filter(
                row => !deselectedIds.includes(row.Id)
            );
            console.log("deleted ids optioins 000"+ JSON.stringify(deselectedIds));
    }


    @wire(getlocdata)
    wiredLocationList({ data, error }) {
        if (data) {

            for (let i = 0; i < data.length; i++) {
                this.items = [...this.items, { value: data[i].Id, label: data[i].Name }];
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;

        }

    }

    get locationoptions() {
        return this.items;
    }

    handlelocationChange(event) {
        this.selectedlocation = event.detail.value;
    }
    handlechangerecipientname(event) {
        this.recipientname = event.detail.value;
    }
    handleChangeNextScreen2() {
        console.log('handleChangeNextScreen2 called');

        this.productfilter = [...this.productfilter, ...this.productData];
        let filteredproductOps = [];
        filteredproductOps = this.productfilter.filter(record => record.Location === this.selectedlocation);
        this.filteredproductitems = JSON.parse(JSON.stringify(filteredproductOps));
        this.originalproductlist = JSON.parse(JSON.stringify(filteredproductOps));
        console.log("this.filteredproductitems"+ JSON.stringify(this.filteredproductitems));
        console.log("this.originalproductlist"+ JSON.stringify(this.originalproductlist));
    }
    
    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
        this.searchproductitems = this.originalproductlist.filter(row => {
            return Object.values(row).some(
                value => value && value.toString().toLowerCase().includes(this.searchTerm)
            );
        });

        this.filteredproductitems = [...this.searchproductitems];
       
        //changes made as per SFL-709
        this.filteredproductitems=this.filteredproductitems.map(row => ({...row,
        isSelected:this.selectedOpp.some(selected=>selected.Id===row.Id)}));
        this.selectedRowIds = this.filteredproductitems.filter(row=>row.isSelected).map(row => row.Id);
    }
    handleNextscreen3() {                               //changes made as per SFL-1138
        console.log('handleNextscreen3 called');

       for (let i = 0; i < this.selectedOpp.length; i++) {

            this.newarr.push({ Id: this.selectedOpp[i].Id, ProductName: this.selectedOpp[i].ProductName, Location: this.selectedOpp[i].Location, Quantity: 1 });

        }
        console.log('this.selectedOpp.length'+this.selectedOpp.length);
        /* for (let i = 0; i < this.selectedOption.length; i++) {

            this.newarr.push({ Id: this.selectedOption[i].Id, ProductName: this.selectedOption[i].ProductName, Location: this.selectedOption[i].Location, Quantity: 1 });

        }*/
        
    }


    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        this.newarr = this.newarr.map(item => {
            const matchingField = updatedFields.find(element => element.Id === item.Id);

            if (matchingField) {
                console.log('insideif');

                return { ...item, ...matchingField };

            }
            return item;
        });

        event.target.draftValues = [];
        console.log('newarr ',JSON.stringify(this.newarr));
    }
    arrlegth;
    handleSubmit() {
        console.log("user/teamname"+this.recipientname)
        if(this.recipientname!=null){
            this.arrlegth = this.newarr.length;
            console.log("arrlegth "+this.arrlegth);
        this.newarr.forEach((record) => {
            this.handleProductQuatityValidation(record);
                console.log("isValidQuantity  00  "+this.isValidQuantity);
                console.log("isMoreThanAvialableQty  00  "+this.isMoreThanAvialableQty);
            if (this.isValidQuantity && this.isMoreThanAvialableQty){
                this.createproductsconsumed(record);
                console.log("scuess record cefatedskdjcn");
            }else if(!this.isMoreThanAvialableQty && this.isValidQuantity){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Please enter quantity less than available quantity",
                        variant: "error"
                    })
                );
            }else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Invalid Quantity! Please select quantity which is greater than 0",
                        variant: "error"
                    })
                );
            }

        });
    }else{
        this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Please enter User/Team Name",
                        variant: "error"
                    })
                );
    }
}

    async createproductsconsumed(pcrecords) {

        const productconsumed = {
            WorkOrderId: this.recordId,
            QuantityConsumed: pcrecords.Quantity,
            ProductItemId: pcrecords.Id,
            FSM_RecipientName__c: this.recipientname
        }
        const productsconsumedrecinp = JSON.parse(JSON.stringify(productconsumed))

        const recordInput = { apiName: ProductConsumed.objectApiName, fields: productsconsumedrecinp };

        createRecord(recordInput)
            .then((pc) => {
                this.pcid = pc.id;
                console.log('insideThen', pc.id);
                pcrecords = {};

                    this.handleSuccess();
                    this.recordsuccess = true;
                    this.sectionthree = false;
            })
            .catch((error) => {
                console.log(error.body.message)
                console.log('insideCatch')
            })
            .finally(() => {
            });



    }

    handleSuccess() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Records created successfully!',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }


    // To validate Product Quantity    
    handleProductQuatityValidation(data) {
        this.productData.forEach((pcdata) => {
            if(pcdata.Id == data.Id){
                if (data.Quantity < 1) {
                    this.isValidQuantity = false;
                } else if(pcdata.quantityOnHand < data.Quantity) {
                    this.isMoreThanAvialableQty = false;
                    this.isValidQuantity = true;
                } else{
                    this.isMoreThanAvialableQty = true;
                    this.isValidQuantity = true;
                }
            }
        })

    }




}
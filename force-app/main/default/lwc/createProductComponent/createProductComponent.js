import { LightningElement, wire,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProductList from '@salesforce/apex/CreateProductComponent_Controller.getProdctDetails';
import getFieldApiName from '@salesforce/apex/CreateProductComponent_Controller.getApiNameXlabel';
import getApiNames from '@salesforce/apex/CreateProductComponent_Controller.getRelatedFields';
import findProductMatch from '@salesforce/apex/CreateProductComponent_Controller.findMachingProduct';
import saveProductDetails from '@salesforce/apex/CreateProductComponent_Controller.saveProductDetails';
import checkDuplicateProduct from '@salesforce/apex/CreateProductComponent_Controller.checkforDuplicateProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FieldApiNameList from '@salesforce/apex/CreateProductComponent_Controller.FieldApiNameList';
import LightningModal from 'lightning/modal';

//import { CloseActionScreenEvent } from 'lightning/actions'; 

// 'Damper_Size__c',

export default class CreateProductComponent extends NavigationMixin(LightningElement)  {
    @api productList = {};
    @api error = '';
    @api productFamily = '';
    @api recordId;
    @api objectApiName ='Product2';
    selectedvalue = '';
    modelNum = '';
    productName = '';
    showProd = true;
    hideProd = false;
    duplicateFound = false;
    duplicateValue = '';
    fieldsToDisplay = ['Name', 'Product_Name__c','CurrencyIsoCode','Bore_Diameter__c', 'Value_Type__c']; 
    i=0;
    seriexXProduct  = new Map();

    @track columns = [];
    @track selected = ['Id', 'Name'];
    @track fetchedProductList = [];
    prodArray = [{"label": 'Amount',"fieldName": 'amount'}];

    productObject = {};
    @api options = [];
    @track isShowModal = false;
    apiNameXLabelMap = [];

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    
    // closeAction() { 
    //     this.dispatchEvent(new CloseActionScreenEvent());
    // }

    showToastmessage(){
        this.displayToastSuccess();
    }
    
    displayToastSuccess() {
        debugger;
        const toastEvt = new ShowToastEvent({
            title: 'Success',
            message: 'Submitted Successfully ',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvt);
    }

    showToast(type, message) {
        debugger;
        const event = new ShowToastEvent({
            title: 'Toast message',
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    @wire(getFieldApiName)
    getFieldApiNames({data, error}){
        debugger;
        if(data){
            this.apiNameXLabelMap = data;
            this.error = undefined;
        }
        else if (error) {
            this.error = error;
        }

    }
    
    @wire(getProductList)
    wiredProductList({data, error}){
        debugger;
        if(data){
            this.productList = data.map(record => ({value:record.MasterLabel, Id:record.Id,pFamily: record.Product_Family__c, label: record.MasterLabel,fields: record.Fields__c,index:this.i}));
            for(var key in data){
              //  this.seriexXProduct.push({key:data[key].MasterLabel, value:data[key]});
              this.seriexXProduct.set(data[key].MasterLabel,data[key]);
            }
          //  this.productList = data;
            this.error = undefined;
        }
        else if (error) {
            this.error = error;
            this.productList = undefined;
        }
    }


   

    handleChange(event){
        debugger;
        this.showToast('success','Product Created Successfully');
        this.productFamily = this.seriexXProduct.get(event.detail.value).Product_Family__c ;
         this.selectedvalue = this.seriexXProduct.get(event.detail.value).MasterLabel;
        if(this.seriexXProduct.get(event.detail.value).Fields__c){
            getApiNames({feildApiNameListString:this.seriexXProduct.get(event.detail.value).Fields__c}) 
            .then(result => {
                debugger;
                if(result.length >0){
                    this.fieldsToDisplay =  this.fieldsToDisplay.concat(result);
                    this.fieldsToDisplay = this.fieldsToDisplay.filter((v, i, a) => a.indexOf(v) === i);
                }
                this.selected = this.fieldsToDisplay;
                for(let i=0; i<this.fieldsToDisplay.length;i++){
                    if (this.fieldsToDisplay[i] == "Name") {
                        this.columns.push({ 
                            label: 'Name',
                            fieldName: 'Name',
                            type: 'url',
                            typeAttributes: {label: { fieldName: 'Name' }, 
                            target: '_blank'} });
                    }else{
                        this.columns.push({ label: this.apiNameXLabelMap[this.fieldsToDisplay[i].toLowerCase()], fieldName: this.fieldsToDisplay[i]});
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
        }
        if(this.selectedvalue!=null){
            FieldApiNameList({SelectedSeries:this.selectedvalue})
            .then(result=>{
                for (var key in result) {
                    this.RequiredFields.push({ key: key, value:result[key] });
                }
                console.log('RequiredFields--',this.RequiredFields);
            })
            .catch(error=>{
                console.log('error--',error);
            })
        }
    }

    handleSubmit(event) {
        debugger;
        
        event.preventDefault(); // stop the form from submitting
        var fields = event.detail.fields;
        //fields.LastName = 'My Custom Last Name'; // modify a field
        let tempfield;
        fields.Family = this.productFamily;
        fields.Series_Name__c = this.selectedvalue;
        this.productObject = fields;
          let count=0;
          let arr=[];
        for(let i=0;i<this.RequiredFields.length;i++){

            tempfield=this.RequiredFields[i].value;
            
           if(this.productObject[tempfield]==null){
               arr.push(this.RequiredFields[i].key);   
           }else{
              count++;
              console.log('count',count);
              console.log('Field Is Not Mandatory');
           }
     }
     //Joining all The Mandatory Fields
     //const set = new Set(arr);
     //const newArr = [...set];
     let joinedstring=arr.join(", ");
     console.log('joinedstring--',joinedstring);
     //finding Index of ", "
     let index=joinedstring.lastIndexOf(", ");
     console.log('index--',index);
     //Replacing ", " with this " & "
     //joinedstring = joinedstring.substring(0, index) + " & " + joinedstring.substring(index + 1);

     console.log('joinedstring After Replace--',joinedstring);
        console.log('this.productObject',JSON.stringify(this.productObject));
        console.log('fieldsToDisplay',JSON.stringify(this.fieldsToDisplay));

        this.productName = fields.Name;

       if(count==this.RequiredFields.length){
           console.log('Now you Can Excute');
           this.checkForDuplicateProduct();
        if(!this.duplicateFound){
            findProductMatch({product:fields,valveType:this.productFamily,series:this.selectedvalue,fieldList:this.fieldsToDisplay}) 
            .then(result => {
                debugger;
                if(result != null){
                    this.fetchedProductList = result;
                    if(this.fetchedProductList.length > 0){
                         this.isShowModal = true;
                         for(var i=0;i< this.fetchedProductList.length;i++){
                            this.fetchedProductList[i].URL_TO_Redirect = window.location.origin+'/lightning/r/Product2/'+this.fetchedProductList[i].Id+'/view';
                         }
                    }else{

                    if(!this.duplicateFound){
                        this.saveProduct();
                    }
                    }
                }else{
                    if(!this.duplicateFound){
                        this.saveProduct();
                    }
                  }
            })
            .catch(error => {
                this.error = error;
            });
        }

       }else{
        this.showCustomToast('error',joinedstring + ' are Not Filled');
       }
        
  

        // this.template.querySelector('lightning-record-form').submit(fields);
        // console.log(event.detail.id);
        // this.showToast('success','Product Created Successfully');
    }
    handleCancle(event){
        this.productFamily = '';
        this.selectedvalue = '';
        this.showProd = true;
        this.hideProd = false;
        this.fieldsToDisplay = ['Name', 'Product_Name__c','CurrencyIsoCode','Bore_Diameter__c', 'Damper_Size__c', 'Value_Size__c', 'Value_Type__c'];

    }
    
    @track RequiredFields=[];
    handleNext(event){
        debugger;
        if(this.selectedvalue != ''){
            this.showProd = false;
            this.hideProd = true;
            FieldApiNameList({SelectedSeries:this.selectedvalue})
            .then(result=>{
                console.log('result--',result);
                for (var key in result) {
                    if(this.RequiredFields.find(item=>item.key==key)){
                         console.log('This Key Exist');
                    }else{
                        this.RequiredFields.push({ key: key, value:(result)[key] });
                    }
                    
                }
                console.log('key', this.RequiredFields);
            })
            .catch(error=>{
                console.log('error--',error);
            })

        }else{
            this.showCustomToast('error','Please select a Series');
        }
        

    }
    handleCloseClick() {
        this.close('canceled');
      }
      closeModal() {
        // immediately exits, so no need to trigger
        // this.disableClose = false OR
        // this.saveInProcess = false;
        // modal is destroyed, and focus moves
        // back to originally clicked item that
        // generated the modal
        this.close('success');
      }
    

      backToFirstPage(){
        this.isShowModal = false;
        this.handleCancle();
      }

      saveProduct(){
        debugger;
        this.isShowModal = false;
        // this.template.querySelector('lightning-record-form').submit(this.productObject);
        // console.log(event.detail.id);
        // this.showToast('success','Product Created Successfully');
        saveProductDetails({newProduct:this.productObject})
        .then(result => {
            debugger;
            if(result != null){
                this.showCustomToast('success','Product Created Successfully');
              this.navigateToProductPage(result); 
            }
        })
        .catch(error => {
            this.error = error;
        });
      }

      navigateToProductPage(recordId) {
        window.location.replace(window.location.origin+"/lightning/r/Product2/"+recordId+"/view");
    }
 
    checkForDuplicateProduct(){
        debugger;
        checkDuplicateProduct({modelNo:this.productObject.Model_Number__c,seriesName:this.selectedvalue,productName:this.productName})
        .then(result => {
            debugger;
            if(result != null){
                this.showCustomToast('error',result);
                this.duplicateFound = true;
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    showCustomToast(title,message){
        this.template.querySelector('c-custom-toast').showToast(title,'<span>'+message+'<span/>','utility:warning',10000);
    }
}
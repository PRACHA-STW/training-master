/**---------------------------------------------------------
* @description :  Redirect Dataloading user to Dataloader.io               
* @group      :  Capgemini
* Test Class  :  FSM_DataloaderLoginFlowPageCTRTest
* ver    Date                Author             Modification
1.0    10th Dec 2024 Alagar Created-SFI-31
-----------------------------------------------------------*/

public with sharing class FSM_DataloaderLoginFlowPageCTR {
    //public Boolean isConnectedApp { get; private set; }
    public String redirectUrl { get; private set; }

    public FSM_DataloaderLoginFlowPageCTR () {
        // Retrieve the retURL parameter from the URL
        redirectUrl = ApexPages.currentPage().getParameters().get('retURL');
        
        
    }
    
    public PageReference FinishLoginFlowHome() {
        //do stuff
        
        if(redirectUrl == Null){
            
        }else if(redirectUrl.contains('RemoteAccessAuthorizationPage')){
            
            //finish the login flow and send you the default homepage
            return Auth.SessionManagement.finishLoginFlow();
        }
        
        return null;
    }
}
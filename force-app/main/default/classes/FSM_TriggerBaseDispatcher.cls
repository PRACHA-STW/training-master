/********************************************************************************************************
@Author : Deepak Moudekar
@Date   : 13-June-2023
@Description : This class used as a dispatcher for all trigger.
@Test Class :
********************************************************************************************************/
public class FSM_TriggerBaseDispatcher {
     //Method for handling workorder events
    public static void run(FSM_TriggerBaseHandler handler, String customSettingsTriggerApiName){
        //Check if the trigger is disabled
        if (handler.IsDisabled()){ return;
        }
        
        List<FSM_ToggleLogic__c> each=New List<FSM_ToggleLogic__c>();
        Boolean isActive =TRUE;
        each.add(FSM_ToggleLogic__c.getInstance(userinfo.getProfileId()));
         if(each.size() > 0){
            If(each[0].FSM_TriggerAPIName__c == customSettingsTriggerApiName){
            isActive = Boolean.valueOf(each[0].FSM_Active__c);           
            }    
        }
        
        if(isActive){
            //Check trigger context from trigger operation type
            switch on Trigger.operationType {
                 
                when BEFORE_INSERT {
                    //Invoke before insert trigger handler
                    handler.beforeInsert(trigger.new);
                }
                when AFTER_INSERT {
                    //Invoke after insert trigger handler
                    handler.afterInsert(trigger.newMap);
                }
                when BEFORE_UPDATE {
                    //Invoke before update trigger handler
                    handler.beforeUpdate(trigger.newMap, trigger.oldMap);
                }
                when AFTER_UPDATE {
                    //Invoke after update trigger handler
                    handler.afterUpdate(trigger.newMap, trigger.oldMap);
                }/*
                when BEFORE_DELETE {
                    //Invoke before delete trigger handler
                    handler.beforeDelete(trigger.old, trigger.oldMap);
                }
                when AFTER_DELETE {
                    //Invoke after delete trigger handler
                    handler.afterDelete(trigger.old, trigger.oldMap);
                }
                when AFTER_UNDELETE {
                    //Invoke after undelete trigger handler
                    handler.afterUnDelete(trigger.new, trigger.newMap);
                }
*/
            }
        }
    }
}
trigger FSM_AutoSchedulingTrigger on FSM_AutoScheduleding__e (after insert) {
    if(trigger.isafter && trigger.isInsert){
        FSM_AutoScheduling.updateSAAutoScheduling(trigger.new);
    }
}
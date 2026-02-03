/********************************************************************************************************
@Author      : Subir Maji
@Description : This Class is going to be used as helper class for FSM_DCFJsonGenerator
@Description : Created as part of user story #SFI-35
@Test Class  : FSM_DCFJsonGeneratorTest
@Date        : 31-July-2023
********************************************************************************************************/
public with sharing Class FSM_DCFJsonGeneratorHelper {
    //Variables to collect master objcet details
    Static Map<String, Map<String, Map<String,String>>> stringFieldMap;
    Static Map<String, Map<String, Map<String,Integer>>> integerFieldMap;
    Static Map<String, Map<String, Map<String,Decimal>>> decimalFieldMap;
    //Variables to collect DCF line item object details
    Static Map<String, Map<String, Map<String,String>>> stringFieldLineMap;
    Static Map<String, Map<String, Map<String,Integer>>> integerFieldLineMap;
    Static Map<String, Map<String, Map<String,Decimal>>> decimalFieldLineMap;
    Static Map<String, Map<String,String>> nodeWiseString; // vairable to for making Platform event field and node wise String
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will get the metaddata and build the Map for Form, Field and Data type
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static Void formAndFieldandTypeMap(String formName, String fieldAPIName,String dataType){
      
        if(FSM_DCFJsonGenerator.formAndFieldandTypeMap.containsKey(formName)){
            FSM_DCFJsonGenerator.formAndFieldandTypeMap.get(formName).put(fieldAPIName, dataType);
        }else{
            FSM_DCFJsonGenerator.formAndFieldandTypeMap.put(formName, new Map<String, String>());
            FSM_DCFJsonGenerator.formAndFieldandTypeMap.get(formName).put(fieldAPIName, dataType);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will get the metaddata and build the Map for Form, Field and Formula
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static Void formAndFieldAndFormulaMap(Boolean isFormula, String formName, String fieldAPIName,String formula){
        if(isFormula && formula != null && formula != ''){
            if(FSM_DCFJsonGenerator.formAndFieldAndFormulaMap.containsKey(formName)){
                FSM_DCFJsonGenerator.formAndFieldAndFormulaMap.get(formName).put(fieldAPIName, formula);
            }else{
                FSM_DCFJsonGenerator.formAndFieldAndFormulaMap.put(formName, new Map<String, String>());
                FSM_DCFJsonGenerator.formAndFieldAndFormulaMap.get(formName).put(fieldAPIName, formula);
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will get the metaddata and build the Map for Form, Field and PlatformEventField
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static Void formAndFieldAndPlatformFieldMap(String formName, String fieldAPIName,String platformEventField){
        if(FSM_DCFJsonGenerator.formAndFieldAndPlatformFieldMap.containsKey(formName)){
            FSM_DCFJsonGenerator.formAndFieldAndPlatformFieldMap.get(formName).put(fieldAPIName, platformEventField);
        }else{
            FSM_DCFJsonGenerator.formAndFieldAndPlatformFieldMap.put(formName, new Map<String, String>());
            FSM_DCFJsonGenerator.formAndFieldAndPlatformFieldMap.get(formName).put(fieldAPIName, platformEventField);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will get the metaddata and build the Map for Form, Field and JSON Label
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static Void formAndFieldAndJSOnLabelMap(String formName, String fieldAPIName,String jsonLabel){
        if(FSM_DCFJsonGenerator.formAndFieldAndJSOnLabelMap.containsKey(formName)){
            FSM_DCFJsonGenerator.formAndFieldAndJSOnLabelMap.get(formName).put(fieldAPIName, jsonLabel);
        }else{
            FSM_DCFJsonGenerator.formAndFieldAndJSOnLabelMap.put(formName, new Map<String, String>());
            FSM_DCFJsonGenerator.formAndFieldAndJSOnLabelMap.get(formName).put(fieldAPIName, jsonLabel);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will get the metaddata and build the Map for Form, Field and Node
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static Void formAndFieldAndNodeMap(String formName, String fieldAPIName,String node){
        if(node != null && node != ''){
            if(FSM_DCFJsonGenerator.formAndFieldAndNodeMap.containsKey(formName)){
                FSM_DCFJsonGenerator.formAndFieldAndNodeMap.get(formName).put(fieldAPIName, node);
            }else{
                FSM_DCFJsonGenerator.formAndFieldAndNodeMap.put(formName, new Map<String, String>());
                FSM_DCFJsonGenerator.formAndFieldAndNodeMap.get(formName).put(fieldAPIName, node);
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method will create the Strings
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    Public static Void createStringJSON(){
        
        //Variables to collect master objcet details
        stringFieldMap = new Map<String, Map<String, Map<String,String>>>();
        integerFieldMap = new Map<String, Map<String, Map<String,Integer>>>();
        decimalFieldMap = new Map<String, Map<String, Map<String,Decimal>>>();
        
        //Variables to collect DCF line item object details
        stringFieldLineMap = new Map<String, Map<String, Map<String,String>>>();
        integerFieldLineMap = new Map<String, Map<String, Map<String,Integer>>>();
        decimalFieldLineMap = new Map<String, Map<String, Map<String,Decimal>>>();
        
        //Check record and start build
        if(FSM_DCFJsonGenerator.fieldHelperAll != null){
            for(FSM_DCFJsonGenerator.fieldStructureGenerator gen : FSM_DCFJsonGenerator.fieldHelperAll){
                if(gen.isChild){
                    processChildRecord(gen);
                }else{
                    processDCFRecord(gen);
                }
            }
            buildJSONString();
        }
    }    
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to build the JSON string
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void buildJSONString(){
        nodeWiseString = new Map<String, Map<String,String>>(); //platform event Field and Node Wise String Creation
        Map<String, Map<String, String>> nodeWiseMapString = new Map<String, Map<String,String>>(); //Node wise map for string field
        Map<String, Map<String, Integer>> nodeWiseMapInteger = new Map<String, Map<String,Integer>>(); //Node wise map for Integer field
        Map<String, Map<String, Decimal>> nodeWiseMapDecimal = new Map<String, Map<String,Decimal>>(); //Node wise map for decimal field
        
        //Going through parent DCF field
        if(stringFieldMap != null && !stringFieldMap.isEmpty()){
            for(String peField : stringFieldMap.keySet()){
                for(String node : stringFieldMap.get(peField).keySet()){
                    nodeWiseMapString = new Map<String, Map<String,String>>();
                    nodeWiseMapString.put(node, stringFieldMap.get(peField).get(node));
                    buidFieldNodeString(Json.serialize(nodeWiseMapString), peField, node);    
                }
            }
        }
        if(integerFieldMap != null && !integerFieldMap.isEmpty()){
              for(String peField : integerFieldMap.keySet()){
                for(String node : integerFieldMap.get(peField).keySet()){
                    nodeWiseMapInteger = new Map<String, Map<String,Integer>>();
                    nodeWiseMapInteger.put(node, integerFieldMap.get(peField).get(node));
                    buidFieldNodeString(Json.serialize(nodeWiseMapInteger), peField, node);
                }
            }
        }
        if(decimalFieldMap != null && !decimalFieldMap.isEmpty()){
            for(String peField : decimalFieldMap.keySet()){
                for(String node : decimalFieldMap.get(peField).keySet()){
                    nodeWiseMapDecimal = new Map<String, Map<String,Decimal>>();
                    nodeWiseMapDecimal.put(node, decimalFieldMap.get(peField).get(node));
                    buidFieldNodeString(Json.serialize(nodeWiseMapDecimal), peField, node);
                }
            }
        }
        //building final string for DCF
        buidFinalStringDCF();
        
        //resetting variable
        nodeWiseString = new Map<String, Map<String,String>>();
        nodeWiseMapString = new Map<String, Map<String,String>>();
        nodeWiseMapInteger = new Map<String, Map<String,Integer>>();
        nodeWiseMapDecimal = new Map<String, Map<String,Decimal>>();
        
        //Going through Line item fields
        if(stringFieldLineMap != null && !stringFieldLineMap.isEmpty()){
            for(String recID : stringFieldLineMap.keySet()){
                for(String node : stringFieldLineMap.get(recID).keySet()){
                    nodeWiseMapString = new Map<String, Map<String,String>>();
                    nodeWiseMapString.put(node, stringFieldLineMap.get(recID).get(node));
                    buidFieldNodeString(Json.serialize(nodeWiseMapString), recID, node);
                }
            }
        }
        if(integerFieldLineMap != null && !integerFieldLineMap.isEmpty()){
            for(String recID : integerFieldLineMap.keySet()){
                for(String node : integerFieldLineMap.get(recID).keySet()){
                    nodeWiseMapInteger = new Map<String, Map<String,Integer>>();
                    nodeWiseMapInteger.put(node, integerFieldLineMap.get(recID).get(node));
                    buidFieldNodeString(Json.serialize(nodeWiseMapInteger), recID, node);
                }
            }
        }
        if(decimalFieldLineMap != null && !decimalFieldLineMap.isEmpty()){
            for(String recID : decimalFieldLineMap.keySet()){
                for(String node : decimalFieldLineMap.get(recID).keySet()){
                    nodeWiseMapDecimal = new Map<String, Map<String,Decimal>>();
                    nodeWiseMapDecimal.put(node, decimalFieldLineMap.get(recID).get(node));
                    buidFieldNodeString(Json.serialize(nodeWiseMapDecimal), recID, node);
                }
            }
        }
        //building final string for DCF Line
        buidFinalStringDCFLine();
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going Set the final field for DCF
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void buidFinalStringDCF(){
        String tempStr; //For merging strings etc..
        String defaultNode = FSM_Constants.DEFAULT_NODE;
        
        for(String peField : nodeWiseString.keySet()){
            tempStr = FSM_Constants.BLANK;
            for(String node : nodeWiseString.get(peField).KeySet()){
                if(node == defaultNode){
                    tempStr = tempStr <> FSM_Constants.BLANK?
                        nodeWiseString.get(peField).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART_DOUBLEQUOTE+
                        defaultNode+FSM_Constants.DOUBLEQUOTE_COLON).removeEnd(FSM_Constants.FIRSTBRACKETEND_FIRSTBRACKETEND)+
                        FSM_Constants.COMMA+tempStr.removeStart(FSM_Constants.FIRSTBRACKETSTART) : 
                        nodeWiseString.get(peField).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART_DOUBLEQUOTE+defaultNode+FSM_Constants.DOUBLEQUOTE_COLON).removeEnd(FSM_Constants.FIRSTBRACKETEND);                    
                }else{
                 	tempStr = tempStr <> FSM_Constants.BLANK?
                        tempStr.removeEnd(FSM_Constants.FIRSTBRACKETEND) + FSM_Constants.COMMA + 
                        nodeWiseString.get(peField).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART) : 
                        nodeWiseString.get(peField).get(node);  
                }
            }
            if(peField == FSM_Constants.DCF_PAYLOAD_1){
                FSM_DCFJsonGenerator.dcfPayload1 = tempStr;
            }else if(peField == FSM_Constants.DCF_PAYLOAD_2){
                FSM_DCFJsonGenerator.dcfPayload2 = tempStr;
            }else if(peField == FSM_Constants.DCF_PAYLOAD_3){
                FSM_DCFJsonGenerator.dcfPayload3 = tempStr;
            }else if(peField == FSM_Constants.DCF_PAYLOAD_4){
                FSM_DCFJsonGenerator.dcfPayload4 = tempStr;
            }else if(peField == FSM_Constants.DCF_PAYLOAD_5){
                FSM_DCFJsonGenerator.dcfPayload5 = tempStr;
            }
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going Set the final field for DCF Line
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
	@date		 : Updated as part of SFI-2041 by Subir Maji 23rd July 2024
    ********************************************************************************************************/ 
    private static void buidFinalStringDCFLine(){
        String tempStr; //For merging strings etc..
        String tempStr2; //For merging strings for Line Item GrandChild.. this part is added as part of SFI-2041 by Subir Maji 23rd July 2024
        String defaultNode = FSM_Constants.DEFAULT_NODE;
        String finalString = FSM_Constants.THIRDBRACKATSTART;
        for(String recId : nodeWiseString.keySet()){
            if(!FSM_DCFJsonGenerator.allGrandChildId.contains(recId)){ //this part is added as part of SFI-2041 by Subir Maji 23rd July 2024
                tempStr = FSM_Constants.BLANK;
                for(String node : nodeWiseString.get(recId).KeySet()){
                    if(node == defaultNode){
                        tempStr = tempStr <> FSM_Constants.BLANK?
                            nodeWiseString.get(recId).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART_DOUBLEQUOTE+ defaultNode+FSM_Constants.DOUBLEQUOTE_COLON).removeEnd(FSM_Constants.FIRSTBRACKETEND_FIRSTBRACKETEND)+FSM_Constants.COMMA+tempStr.removeStart(FSM_Constants.FIRSTBRACKETSTART) : 
                            nodeWiseString.get(recId).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART_DOUBLEQUOTE+defaultNode+
                            FSM_Constants.DOUBLEQUOTE_COLON).removeEnd(FSM_Constants.FIRSTBRACKETEND);                    
                    }else{
                        tempStr = tempStr <> FSM_Constants.BLANK?
                            tempStr.removeEnd(FSM_Constants.FIRSTBRACKETEND) + FSM_Constants.COMMA + 
                            nodeWiseString.get(recId).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART) : 
                            nodeWiseString.get(recId).get(node);                    
                    }
                }
                //below part is added as part of SFI-2041 by Subir Maji 23rd July 2024
                if(FSM_DCFJsonGenerator.mapOfParentChildLineItem.containsKey(recId)){
                    tempStr = tempStr.removeEnd(FSM_Constants.FIRSTBRACKETEND);
                    tempStr = tempStr + FSM_Constants.CUSTOMSYMBOL2 + 'RelatedLineItems' + FSM_Constants.DOUBLEQUOTE_COLON+ FSM_Constants.THIRDBRACKATSTART;
                    for(string childRecId : FSM_DCFJsonGenerator.mapOfParentChildLineItem.get(recId)){
                        tempStr2 = FSM_Constants.BLANK;
                        for(String node : nodeWiseString.get(childRecId).KeySet()){
                            if(node == defaultNode){
                                tempStr2 = tempStr2 <> FSM_Constants.BLANK?
                                    nodeWiseString.get(childRecId).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART_DOUBLEQUOTE+ defaultNode+FSM_Constants.DOUBLEQUOTE_COLON).removeEnd(FSM_Constants.FIRSTBRACKETEND_FIRSTBRACKETEND)+FSM_Constants.COMMA+tempStr2.removeStart(FSM_Constants.FIRSTBRACKETSTART) : 
                               		nodeWiseString.get(childRecId).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART_DOUBLEQUOTE+defaultNode+
                                    FSM_Constants.DOUBLEQUOTE_COLON).removeEnd(FSM_Constants.FIRSTBRACKETEND);                    
                            }else{
                                tempStr2 = tempStr2 <> FSM_Constants.BLANK?
                                    tempStr2.removeEnd(FSM_Constants.FIRSTBRACKETEND) + FSM_Constants.COMMA + 
                                    nodeWiseString.get(childRecId).get(node).removeStart(FSM_Constants.FIRSTBRACKETSTART) : 
                                	nodeWiseString.get(childRecId).get(node);                    
                            }
                        }
                        tempStr = tempStr + tempStr2 + FSM_Constants.COMMA;
                    }
                    tempStr = tempStr.removeEnd(FSM_Constants.COMMA) + FSM_Constants.THIRDBRACKATEND + FSM_Constants.FIRSTBRACKETEND;
                }
                finalString = finalString + tempStr + FSM_Constants.COMMA;
            }
        }
        FSM_DCFJsonGenerator.dcfLineItemsPayload = finalString.removeEnd(FSM_Constants.COMMA) + FSM_Constants.THIRDBRACKATEND;
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going Create the map for Field wise Node wise String
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void buidFieldNodeString(String jsonSerilized, String peField, String node){
        String tempStr; // Temporary variable to hold the esisting value for a platform event field
        
        if(nodeWiseString.containsKey(peField)){
            if(nodeWiseString.get(peField).containsKey(node)){
                tempStr = nodeWiseString.get(peField).get(node);
                nodeWiseString.get(peField).put(node, tempStr.removeEnd(FSM_Constants.FIRSTBRACKETEND_FIRSTBRACKETEND) + FSM_Constants.COMMA + jsonSerilized.RemoveStart(FSM_Constants.FIRSTBRACKETSTART_DOUBLEQUOTE+node+FSM_Constants.DOUBLEQUOTE_COLON+FSM_Constants.FIRSTBRACKETSTART));
            }else{
                nodeWiseString.get(peField).put(node, jsonSerilized);
            }
        }else{
            nodeWiseString.put(peField, new Map<String,String>());
            nodeWiseString.get(peField).put(node, jsonSerilized);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to Process the line item records
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void processChildRecord(FSM_DCFJsonGenerator.fieldStructureGenerator gen){
        if(gen.strVal != null && gen.strVal != ''){
            processLineStringRecord(gen);
        }else If(gen.intVal != null){
            processLineIntRecord(gen);
        }else If(gen.decVal != null){
            processLineDecRecord(gen);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to Process the DCF main records
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void processDCFRecord(FSM_DCFJsonGenerator.fieldStructureGenerator gen){
        if(gen.strVal != null && gen.strVal != ''){
            processDCFStringRecord(gen);
        }else If(gen.intVal != null){
            processDCFIntRecord(gen);
        }else If(gen.decVal != null){
            processDCFDecRecord(gen);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to Process the DCF Line Item String records
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void processLineStringRecord(FSM_DCFJsonGenerator.fieldStructureGenerator gen){
        if(stringFieldLineMap.containskey(gen.childRecordId)){
            if(stringFieldLineMap.get(gen.childRecordId).containsKey(gen.node)){
                stringFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.strVal);
            }else{
                stringFieldLineMap.get(gen.childRecordId).put(gen.node, new Map<String,String>());
                stringFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.strVal);
            }
        }else{
            stringFieldLineMap.put(gen.childRecordId, new Map<String, Map<String,String>>());
            stringFieldLineMap.get(gen.childRecordId).put(gen.node, new Map<String,String>());
            stringFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.strVal);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to Process the DCF String records
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void processDCFStringRecord(FSM_DCFJsonGenerator.fieldStructureGenerator gen){
        if(stringFieldMap.containskey(gen.platEveFieldname)){
            if(stringFieldMap.get(gen.platEveFieldname).containsKey(gen.node)){
                stringFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.strVal);
            }else{
                stringFieldMap.get(gen.platEveFieldname).put(gen.node, new Map<String,String>());
                stringFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.strVal);
            }
        }else{
            stringFieldMap.put(gen.platEveFieldname, new Map<String, Map<String,String>>());
            stringFieldMap.get(gen.platEveFieldname).put(gen.node, new Map<String,String>());
            stringFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.strVal);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to Process the DCF Line Item Integer records
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void processLineIntRecord(FSM_DCFJsonGenerator.fieldStructureGenerator gen){
        if(integerFieldLineMap.containskey(gen.childRecordId)){
            if(integerFieldLineMap.get(gen.childRecordId).containsKey(gen.node)){
                integerFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.intVal);
            }else{
                integerFieldLineMap.get(gen.childRecordId).put(gen.node, new Map<String,Integer>());
                integerFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.intVal);
            }
        }else{
            integerFieldLineMap.put(gen.childRecordId, new Map<String, Map<String,Integer>>());
            integerFieldLineMap.get(gen.childRecordId).put(gen.node, new Map<String,Integer>());
            integerFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.intVal);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to Process the DCF Integer records
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void processDCFIntRecord(FSM_DCFJsonGenerator.fieldStructureGenerator gen){
        if(integerFieldMap.containskey(gen.platEveFieldname)){
            if(integerFieldMap.get(gen.platEveFieldname).containsKey(gen.node)){
                integerFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.intVal);
            }else{
                integerFieldMap.get(gen.platEveFieldname).put(gen.node, new Map<String,Integer>());
                integerFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.intVal);
            }
        }else{
            integerFieldMap.put(gen.platEveFieldname, new Map<String, Map<String,Integer>>());
            integerFieldMap.get(gen.platEveFieldname).put(gen.node, new Map<String,Integer>());
            integerFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.intVal);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to Process the DCF Line Item Decimal records
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void processLineDecRecord(FSM_DCFJsonGenerator.fieldStructureGenerator gen){
        if(decimalFieldLineMap.containskey(gen.childRecordId)){
            if(decimalFieldLineMap.get(gen.childRecordId).containsKey(gen.node)){
                decimalFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.decVal);
            }else{
                decimalFieldLineMap.get(gen.childRecordId).put(gen.node, new Map<String,Decimal>());
                decimalFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.decVal);
            }
        }else{
            decimalFieldLineMap.put(gen.childRecordId, new Map<String, Map<String,Decimal>>());
            decimalFieldLineMap.get(gen.childRecordId).put(gen.node, new Map<String,Decimal>());
            decimalFieldLineMap.get(gen.childRecordId).get(gen.node).put(gen.jsonLabel, gen.decVal);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to Process the DCF Decimal records
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static void processDCFDecRecord(FSM_DCFJsonGenerator.fieldStructureGenerator gen){
        if(decimalFieldMap.containskey(gen.platEveFieldname)){
            if(decimalFieldMap.get(gen.platEveFieldname).containsKey(gen.node)){
                decimalFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.decVal);
            }else{
                decimalFieldMap.get(gen.platEveFieldname).put(gen.node, new Map<String,Decimal>());
                decimalFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.decVal);
            }
        }else{
            decimalFieldMap.put(gen.platEveFieldname, new Map<String, Map<String,Decimal>>());
            decimalFieldMap.get(gen.platEveFieldname).put(gen.node, new Map<String,Decimal>());
            decimalFieldMap.get(gen.platEveFieldname).get(gen.node).put(gen.jsonLabel, gen.decVal);
        }
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to check and apply formula for string types
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static String applyStringFormula(String value, string formula){
        if(formula == 'String_SubstringLeft(40)'){
           return applyFormulaStringLeft40(value); 
        }else if(formula == 'String_SubstringRight(40)'){
           return applyFormulaStringRight40(value);
        }else{
            return value;
        } 
    }
	
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to check and apply formula for decimal types
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static decimal applyDecimalFormula(decimal value, string formula){	
        if(formula == 'Decimal_Round'){
           return applyFormulaDecimalRound(value); 
        }else{
            return value;
        } 
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to check and apply formula for Date types
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static date applyDateFormula(Date value, string formula){	
        if(formula == 'Date_addDays(1)'){
           return applyFormulaDateAddDays1(value); 
        }else{
            return value;
        } 
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to check and apply formula for Time types
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static Time applyTimeFormula(Time value, string formula){	
        if(formula == 'Time_AddMinutes(10)'){
           return applyFormulaTimeAddMinutes10(value); 
        }else{
            return value;
        } 
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is going to check and apply formula for Date Time types
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    public static DateTime applyDateTimeFormula(DateTime value, string formula){	
        if(formula == 'DateTime_AddHours(1)'){
           return applyFormulaDateTimeAddHour1(value); 
        }else{
            return value;
        } 
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is for taking 40 char from Left
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static String applyFormulaStringLeft40(String value){
        return value.left(40);
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is for taking 40 char from Right
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static String applyFormulaStringRight40(String value){
        return value.right(40);
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is for taking 40 char from Left
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static decimal applyFormulaDecimalRound(decimal value){
        return value.round();
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is for Adding 1 day
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static date applyFormulaDateAddDays1(date value){
        return value.addDays(1);
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is for Adding 10 Minutes
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static time applyFormulaTimeAddMinutes10(time value){
        return value.addMinutes(10);
    }
    
    /********************************************************************************************************
    @Author      : Subir Maji
    @Description : This method is for Adding 1 hour
    @Description : Created as part of user story #SFI-35
    @Date        : 31-July-2023
    ********************************************************************************************************/ 
    private static DateTime applyFormulaDateTimeAddHour1(DateTime value){
        return value.addHours(1);
    }
}
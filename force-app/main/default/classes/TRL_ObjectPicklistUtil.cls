/**
 * TRL_ObjectPicklistUtil utility class support metadata services, picklist values.
 *
 * @author Igor Androsov
 * @version 1.0
 */
public with sharing class TRL_ObjectPicklistUtil {
    /**
     * Return select options list from any Object Picklist values and their translation
     * labels
     *
     * @param objectName - String name of the object to look for pick values and translations
     * @param fieldName - String API name for a field to look up pick values for
     * @param isNone - Boolean value state to add --None-- selector to start of the list if true
     * @return List - SelectOption for picklist object
     * Example use: 
        List<SelectOption> sl = TRL_ObjectPicklistUtil.getSelectOptionFromPicklist('Case', 'Delivery__c', false);
        for (SelectOption s : sl){
        System.debug('#### '+s.getValue()+' '+s.getLabel());
        }   
    */
    public static List<PickList> getSelectOptionFromPicklist(String objectName, String fieldName, Boolean isNone){
        List<PickList> options = new List<PickList>();
        Map<String, Schema.SObjectType> globalObjectMap = Schema.getGlobalDescribe();
        Schema.SObjectType s = globalObjectMap.get(objectName);
        if (s != null) {
            Map<String, Schema.SObjectField> fMap = s.getDescribe().fields.getMap();
            Schema.DescribeFieldResult fieldResult = fMap.get(fieldName).getDescribe();
            if(fieldResult != null && fieldResult.isAccessible()){
            if (isNone){
                options.add(new PickList('--None--','--None--'));
            }    
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple){
                options.add(new PickList(f.getValue(),f.getLabel())); 
            }   
            }
        }    

        return options;    
    }

    /**
     * Get dependent picklist metdata values
     * 
     * Sample case code
     Map<String,List<PickList>> mp = TRL_ObjectPicklistUtil.GetDependentOptionsEX('Case', 'Product_Family__c', 'Product_Line__c');
    for (String key : mp.keySet()) {

        List<String> lst = mp.get(key);
        for (String s : lst){
            System.debug('### '+key+' - '+s);
        }
    }
    **/    
    public static Map<String, List<PickList>> GetDependentOptionsEX(String pObjName, String pControllingFieldName, String pDependentFieldName){
        Map<String,List<PickList>> objResults = new Map<String,List<PickList>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!objGlobalMap.containsKey(pObjName))
            return objResults;
        //get the type being dealt with
        Schema.SObjectType pType = objGlobalMap.get(pObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
            return objResults;     
        //get the control values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        //iterate through the values and get the ones valid for the controlling field name
        TRL_ObjectPicklistUtil.Bitset objBitSet = new TRL_ObjectPicklistUtil.Bitset();
        //set up the results
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){           
            //get the pointer to the entry
            Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            //get the label
            String pControllingLabel = ctrl_entry.getLabel();
            //create the entry with the label
            objResults.put(pControllingLabel, new List<PickList>());
        }
        //cater for null and empty
        objResults.put('',new List<PickList>());
        objResults.put(null,new List<PickList>());
        //check the dependent values
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){          
            //get the pointer to the dependent index
            Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
            //get the valid for
            String pEntryStructure = JSON.serialize(dep_entry);                
            TRL_ObjectPicklistUtil.TPicklistEntry objDepPLE = (TRL_ObjectPicklistUtil.TPicklistEntry)JSON.deserialize(pEntryStructure, TRL_ObjectPicklistUtil.TPicklistEntry.class);
            //if valid for is empty, skip
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            //iterate through the controlling values
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){    
                if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){                   
                    //get the label
                    String pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
                    objResults.get(pControllingLabel).add(new PickList(objDepPLE.value ,objDepPLE.label));
                }
            }
        } 
        return objResults;
    }

    public class PickList {   	
        public String label {get; set;}
        public String value {get; set;}
        
        public PickList(String val, String lbl) {
            this.label = lbl;
            this.value = val;
        }
    }

    public class TPicklistEntry {
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
        public TPicklistEntry(){
            
        }
    }   

    public class Bitset {

        public Map<String,Integer> AlphaNumCharCodes {get;set;}
        public Map<String, Integer> Base64CharCodes { get; set; }
        public Bitset(){
            LoadCharCodes();
        }
        //Method loads the char codes
        private void LoadCharCodes(){
            AlphaNumCharCodes = new Map<String,Integer>{
                'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
                'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
                'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90    
            };
            Base64CharCodes = new Map<String, Integer>();
            //lower case
            Set<String> pUpperCase = AlphaNumCharCodes.keySet();
            for(String pKey : pUpperCase){
                //the difference between upper case and lower case is 32
                AlphaNumCharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey)+32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                Base64CharCodes.put(pKey,AlphaNumCharCodes.get(pKey) - 65);
                Base64CharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey) - (65) + 26);
            }
            //numerics
            for (Integer i=0; i<=9; i++){
                AlphaNumCharCodes.put(string.valueOf(i),i+48);
                //base 64 numeric starts from 52
                Base64CharCodes.put(string.valueOf(i), i + 52);
            }
        }
        public Boolean testBit(String pValidFor,Integer n){
            //the list of bytes
            List<Integer> pBytes = new List<Integer>();
            //multiply by 6 since base 64 uses 6 bits
            Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
            //will be used to hold the full decimal value
            Integer pFullValue = 0;
            //must be more than 1 byte
            if (bytesBeingUsed <= 1)
                return false;
            //calculate the target bit for comparison
            Integer bit = 7 - (Math.mod(n,8)); 
            //calculate the octet that has in the target bit
            Integer targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed); 
            //the number of bits to shift by until we find the bit to compare for true or false
            Integer shiftBits = (targetOctet * 8) + bit;
            //get the base64bytes
            for(Integer i=0;i<pValidFor.length();i++){
                //get current character value
                pBytes.Add((Base64CharCodes.get((pValidFor.Substring(i, i+1)))));
            }
            //calculate the full decimal value
            for (Integer i = 0; i < pBytes.size(); i++)
            {
                Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value
                pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
            }
            //& is to set the same set of bits for testing
            //shift to the bit which will dictate true or false
            Integer tBitVal = ((Integer)(Math.Pow(2, shiftBits)) & pFullValue) >> shiftBits;
            return  tBitVal == 1;
        }
    }    
}
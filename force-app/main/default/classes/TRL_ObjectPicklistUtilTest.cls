/**
 * TRL_ObjectPicklistUtilTest Test class support metadata services, picklist values,
 * in context of TRL for Case.Status and Account.Territory__c, Account.Region__c fields.
 * These tests rely on metdata of picklists
 * 
 * @author Igor Androsov
 * @version 1.0
 */
@IsTest
private class TRL_ObjectPicklistUtilTest {

    @IsTest
    static void testSelectOptionFromPicklist(){
        
        Test.startTest();
        // Case status
        List<TRL_ObjectPicklistUtil.PickList> statusList = TRL_ObjectPicklistUtil.getSelectOptionFromPicklist('Case', 'Status', true);

        Test.stopTest();
        System.assertEquals(true, statusList.size()>0);
        System.assertEquals('--None--', statusList[0].value);
    }

    @IsTest
    static void testTerritoryList(){
        
        Test.startTest();
        List<TRL_ObjectPicklistUtil.PickList> territoryList = TRL_ObjectPicklistUtil.getSelectOptionFromPicklist('Account', 'Territory__c', true);

        Test.stopTest();
        System.assertEquals(true, territoryList.size()>0);
        System.assertEquals('--None--', territoryList[0].value);
        for(TRL_ObjectPicklistUtil.PickList p : territoryList){
            // try to find values
            if(p.value=='APAC'){
                System.assertEquals('APAC', p.value); 
                System.assertEquals('APAC', p.label);
            }
        }
    }
    @IsTest
    static void testGetDependentOptions(){

        Test.startTest();
        Map<String,List<TRL_ObjectPicklistUtil.PickList>> mp = TRL_ObjectPicklistUtil.GetDependentOptionsEX('Account', 'Territory__c', 'Region__c');

        Test.stopTest();
        System.assertEquals(true, mp.size()>0);
        

    }

}

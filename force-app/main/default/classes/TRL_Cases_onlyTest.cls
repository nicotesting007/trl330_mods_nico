@IsTest
public class TRL_Cases_onlyTest {
    
    @TestSetUp 
    static void testSetUp(){
        List<Case> testCases = new List<Case>(); 
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');

        Boolean statusIndicator = false;

        Account account1 = new Account(Name = 'TestAccount1', Territory__c = 'AMER', Region__c = 'North', BillingCountry = 'US');
        insert account1;

        for(Integer i = 0; i < 55; i++){
            Case c = new Case(RecordTypeId = trlRecordType.getRecordTypeId(),
                    Subject = 'Test ' + i,
                    Status = statusIndicator ? 'Work in Progress' : 'New',
                    AccountId = account1.Id);
            testCases.add(c);
            statusIndicator = !statusIndicator;
        }

        Account account2 = new Account(Name = 'AcoountApex', Territory__c = 'EMEA', Region__c = 'NE', BillingCountry = 'France');
        insert account2;

        for(Integer i = 0; i < 55; i++){
            Case c = new Case(RecordTypeId = trlRecordType.getRecordTypeId(),
                    Subject = 'Test ' + i,
                    Status = statusIndicator ? 'Work in Progress' : 'New',
                    AccountId = account2.Id);
            testCases.add(c);
            statusIndicator = !statusIndicator;
        }
        
        testCases.add(new Case(Subject = 'NonTRL Case'));
        testCases.add(new Case(Subject = 'NonTRL Case 2'));
        
        insert testCases;
    }
    
    @IsTest 
    static void testTRL_Cases_Only(){
        
        Test.startTest();
        
        TRL_Cases_Only ctrl = new TRL_Cases_Only();  
        ctrl.user_role = true;      

        Test.stopTest();
        
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(50, ctrl.listSize);
        System.assertEquals(110, ctrl.totalSize);
        
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        
        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }
        
        System.assert(ctrl.cases.size() <= ctrl.listSize);
        
    }

    @IsTest 
    static void testRefreshCasesView(){
        
        Test.startTest();
        
        TRL_Cases_Only ctrl = new TRL_Cases_Only();  
        ctrl.refreshCaseView();    

        Test.stopTest();
        
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(50, ctrl.listSize);
        System.assertEquals(110, ctrl.totalSize);
        
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        
        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }
        
        System.assert(ctrl.cases.size() <= ctrl.listSize);
        
    }

    @IsTest 
    static void testSearchCasesPositive(){
        
        Test.startTest();
        
        TRL_Cases_Only ctrl = new TRL_Cases_Only();        
        ctrl.searchExpression = 'TestAccount1';
        ctrl.reloadCases();

        Test.stopTest();
        
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(50, ctrl.listSize);
        System.assertEquals(110, ctrl.totalSize); // All cases with Account name TestAccount1
        
    }

    @IsTest 
    static void testGetSortDirection(){
        
        Test.startTest();
        
        TRL_Cases_Only ctrl = new TRL_Cases_Only();        
        String sortDirection = ctrl.getSortDirection();

        Test.stopTest();
        
        System.assertEquals('ASC', sortDirection);
    }
    @IsTest 
    static void testSetSortDirection(){
        
        Test.startTest();
        
        TRL_Cases_Only ctrl = new TRL_Cases_Only();
        ctrl.sortExpression = 'DESC';
        ctrl.setSortDirection('DESC' );      
        String sortDirection = ctrl.getSortDirection();

        Test.stopTest();
        
        System.assertEquals('DESC', sortDirection);
        System.assertEquals('DESC', ctrl.sortExpression);
    }

    @isTest
    static void testStatusItems(){
        TRL_Cases_only ctrl = new TRL_Cases_only();
        
        Test.startTest();
        
        List<SelectOption> opt = ctrl.getStatusItems();
        Test.stopTest();
        System.assertNotEquals(0, opt.size());
        System.assertEquals('--None--', opt[0].getValue());

    }

    @isTest
    static void testTheaterItems(){
        TRL_Cases_only ctrl = new TRL_Cases_only();
        
        Test.startTest();
        List<SelectOption> opt = ctrl.getTheaterItems();
        Test.stopTest();
        System.assertNotEquals(0, opt.size());
        System.assertEquals('--None--', opt[0].getValue());

    }

    @isTest
    static void testRegionItems(){
        TRL_Cases_only ctrl = new TRL_Cases_only();
        
        Test.startTest();
        
        List<SelectOption> opt = ctrl.getRegionItems();
        Test.stopTest();
        System.assertNotEquals(0, opt.size());
        System.assertEquals('--None--', opt[0].getValue());
    }
    @isTest
    static void testAreaDisaplay(){
        TRL_Cases_only ctrl = new TRL_Cases_only();
        
        Test.startTest();
        
        Boolean sel = ctrl.getAreaDisaplay();

        Test.stopTest();
        System.assertEquals(true, sel);

    }
    @isTest
    static void testAreaDisaplaySetNull(){
        TRL_Cases_only ctrl = new TRL_Cases_only();
        ctrl.selectedTheater = null;
        Test.startTest();
        
        Boolean sel = ctrl.getAreaDisaplay();

        Test.stopTest();
        System.assertEquals(true, sel);

    }

    @isTest
    static void testgoToSortColumn(){
        TRL_Cases_only ctrl = new TRL_Cases_only();
        
        Test.startTest();
        
        ctrl.goToSortColumn();

        Test.stopTest();
        //System.assertEquals(true, sel);

    }

    


    @IsTest
    static void testNewCase(){
        TRL_Cases_only ctrl = new TRL_Cases_only();
        
        Test.startTest();
        
        PageReference testRef = ctrl.newCase();        
        
        Test.stopTest();
        
        System.assertNotEquals(null, testRef);
        System.assert(testRef.getRedirect());
        
    }
    
    @IsTest
    static void testGoToFirstPage(){
        
        TRL_Cases_only ctrl = new TRL_Cases_only();
        ctrl.goToNextPage();
        System.assertNotEquals(1, ctrl.currentPage);
        
        Test.startTest();
        
        ctrl.goToFirstPage();        
        
        Test.stopTest();
        
        System.assertEquals(1, ctrl.currentPage);
        
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        
        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }
        
        System.assert(ctrl.cases.size() <= ctrl.listSize);
        
    }
    
    @IsTest
    static void testGoToPreviousPage(){
        
        TRL_Cases_only ctrl = new TRL_Cases_only();
        ctrl.goToNextPage();
        ctrl.goToNextPage();
        System.assertEquals(3, ctrl.currentPage);
        
        Test.startTest();
        
        ctrl.goToPreviousPage();        
        
        Test.stopTest();
        
        System.assertEquals(2, ctrl.currentPage);
        
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        
        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }
        
        System.assert(ctrl.cases.size() <= ctrl.listSize);
    }
    
    @IsTest
    static void testGoToNextPage(){
        
        TRL_Cases_only ctrl = new TRL_Cases_only();
        
        Test.startTest();
        
        ctrl.goToNextPage();        
        
        Test.stopTest();
        
        System.assertEquals(2, ctrl.currentPage);
        
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        
        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }
        
        System.assert(ctrl.cases.size() <= ctrl.listSize);
    }
    
    @IsTest
    static void testGoToEndPage(){
        
        TRL_Cases_only ctrl = new TRL_Cases_only();
        
        Test.startTest();
        
        ctrl.goToEndPage();        
        
        Test.stopTest();
        
        System.assertEquals(3, ctrl.currentPage);
        
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        
        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }
        
        System.assert(ctrl.cases.size() <= ctrl.listSize);
    }

    @IsTest
    static void testReloadCases() {
        TRL_Cases_Only ctrl = new TRL_Cases_Only();

        Test.startTest();

        ctrl.reloadCases();

        Test.stopTest();

        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');

        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }

        System.assert(ctrl.cases.size() <= ctrl.listSize);
                
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(110, ctrl.totalSize);
    }

    @IsTest
    static void testReloadCasesWithStatus() {
        TRL_Cases_Only ctrl = new TRL_Cases_Only();
        ctrl.caseForStatus.Status = 'New';
        ctrl.selectedCaseStatus = 'New';
        Test.startTest();

        ctrl.reloadCases();

        Test.stopTest();

        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');

        for(Case c: ctrl.cases) {
            System.assertEquals('New', c.Status);
        }

        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }

        System.assert(ctrl.cases.size() <= ctrl.listSize);
        
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(55, ctrl.totalSize);
    }

    @IsTest
    static void testReloadCasesWithTerritory() {
        TRL_Cases_Only ctrl = new TRL_Cases_Only();
        ctrl.accountForTerritory.Territory__c = 'AMER';
        ctrl.selectedTheater = 'AMER';

        Test.startTest();

        ctrl.reloadCases();

        Test.stopTest();

        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');

        for(Case c: ctrl.cases) {
            System.assert(c.Account_Region__c.contains('AMER'));
        }

        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }

        System.assert(ctrl.cases.size() <= ctrl.listSize);
        
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(55, ctrl.totalSize);
    }

    @IsTest
    static void testReloadCasesWithRegion() {
        TRL_Cases_Only ctrl = new TRL_Cases_Only();
        ctrl.accountForTerritory.Territory__c = 'AMER';
        ctrl.accountForTerritory.Region__c = 'North';
        ctrl.selectedTheater = 'AMER';
        ctrl.selectedArea = 'North';
        Test.startTest();

        ctrl.reloadCases();

        Test.stopTest();

        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');

        for(Case c: ctrl.cases) {
            System.assert(c.Account_Region__c.contains('North'));
        }

        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }

        System.assert(ctrl.cases.size() <= ctrl.listSize);
        
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(55, ctrl.totalSize);
    }

    @IsTest
    static void testReloadCasesWithTerritoryAndStatus() {
        TRL_Cases_Only ctrl = new TRL_Cases_Only();
        ctrl.caseForStatus.Status = 'New';
        ctrl.accountForTerritory.Territory__c = 'AMER';
        ctrl.selectedCaseStatus = 'New';
        ctrl.selectedTheater = 'AMER';

        Test.startTest();

        ctrl.reloadCases();

        Test.stopTest();

        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');

        for(Case c: ctrl.cases) {
            System.assert(c.Account_Region__c.contains('AMER'));
            System.assertEquals('New', c.Status);
        }

        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }

        System.assert(ctrl.cases.size() <= ctrl.listSize);
        
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(28, ctrl.totalSize);
    }

    @IsTest
    static void testReloadCasesError() {
        TRL_Cases_Only ctrl = new TRL_Cases_Only();
        ctrl.caseForStatus.Status = 'Ne\'w';
        ctrl.selectedCaseStatus = 'Ne\'w';
        Test.startTest();

        ctrl.reloadCases();

        Test.stopTest();

        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');

        for(Case c: ctrl.cases) {
            System.assertEquals('New', c.Status);
        }

        for(Case c : [SELECT RecordTypeId FROM Case WHERE Id IN : ctrl.cases]){
            System.assertEquals(trlRecordType.getRecordTypeId(), c.RecordTypeId);
        }

        System.assert(ctrl.cases.size() <= ctrl.listSize);
        
        System.assertEquals(1, ctrl.currentPage);
        System.assertEquals(0, ctrl.totalSize);
    }

}
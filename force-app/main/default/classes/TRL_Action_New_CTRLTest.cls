@IsTest
public class TRL_Action_New_CTRLTest {
    
    @IsTest
    static void testTRL_Action_New_CTRL(){
        Test.startTest();
        
        TRL_Action_New_CTRL ctrl = new TRL_Action_New_CTRL();
        
        Test.stopTest();
        
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        System.assertEquals(trlRecordType.getRecordTypeId(), ctrl.newCase.RecordTypeId);   
        
        AssignmentRule useAssignRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE LIMIT 1];
        System.assertEquals(useAssignRule.Id, ctrl.newCase.getOptions().assignmentRuleHeader.assignmentRuleId);
    }
    
    @isTest static void testSave(){
        TRL_Action_New_CTRL ctrl = new TRL_Action_New_CTRL();
        ctrl.newCase.Subject = 'Test Save';
        ctrl.newCase.Description = 'Test Save Dscr';
        
        Test.startTest();
        
        ctrl.save();        
        
        Test.stopTest();
                   
        Case testCase = [SELECT Subject, Description FROM Case WHERE Id = :ctrl.newCase.Id LIMIT 1];
        System.assertEquals('Test Save', testCase.Subject);
        System.assertEquals('Test Save Dscr', testCase.Description);
    }
    
    @isTest static void testSaveError(){
        Account account1 = new Account(Name = 'TestAccount1', Territory__c = 'APAC', Region__c = 'Japan', BillingCountry = 'Japan');
        insert account1;
        TRL_Action_New_CTRL ctrl = new TRL_Action_New_CTRL();
        ctrl.newCase.Subject = 'Test Save';
        ctrl.newCase.Description = 'Test Save Dscr';
        ctrl.newCase.AccountId = account1.Id;
        insert ctrl.newCase;
        
        Test.startTest();
        
        ctrl.save();        
        
        Test.stopTest();
                   
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        Boolean messageFound = false;
        for(ApexPages.Message message : pageMessages) {
            if( message.getDetail() == 'You can not create case' && message.getSeverity() == ApexPages.Severity.ERROR) {
                messageFound = true;
            }
        }
        System.assert(messageFound);
        
    }
    
    @isTest 
    static void testSaveAndNew(){
        Account account1 = new Account(Name = 'TestAccount1', Territory__c = 'APAC', Region__c = 'Japan', BillingCountry = 'Japan');
        insert account1;

        PageReference pageRef = Page.TRL_Action_New;
        Test.setCurrentPage(pageRef);
        TRL_Action_New_CTRL ctrl = new TRL_Action_New_CTRL();
        ctrl.newCase.Subject = 'Test Save';
        ctrl.newCase.Description = 'Test Save Dscr';
        ctrl.newCase.AccountId = account1.Id;

        Test.startTest();
        
        ctrl.saveAndNew();        
        
        Test.stopTest();
                   
        Case testCase = [SELECT Subject, Description FROM Case WHERE Id = :ctrl.newCase.Id LIMIT 1];
        System.assertEquals('Test Save', testCase.Subject);
        System.assertEquals('Test Save Dscr', testCase.Description);
    }
    
    @isTest 
    static void testSaveAndNewError(){
        PageReference pageRef = Page.TRL_Action_New;
        Test.setCurrentPage(pageRef);
        TRL_Action_New_CTRL ctrl = new TRL_Action_New_CTRL();
        ctrl.newCase.Subject = 'Test Save';
        ctrl.newCase.Description = 'Test Save Dscr';
        insert ctrl.newCase;
        
        Test.startTest();
        
        ctrl.saveAndNew();        
        
        Test.stopTest();
                   
		List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        Boolean messageFound = false;
        for(ApexPages.Message message : pageMessages) {
            if( message.getDetail() == 'You can not create case' && message.getSeverity() == ApexPages.Severity.ERROR) {
                messageFound = true;
            }
        }
        System.assert(messageFound);
        
    }
    
    @IsTest
    static void testCancel(){
        TRL_Action_New_CTRL ctrl = new TRL_Action_New_CTRL();
        
        Test.startTest();
        
        PageReference testRef = ctrl.cancel();        
        
        Test.stopTest();
        
        System.assertNotEquals(null, testRef);
        System.assert(testRef.getRedirect());
    }

}
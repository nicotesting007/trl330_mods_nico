/**
 * Created by Vladimir on 10/4/2019.
 */
@IsTest
private class TRL_WithdrawnCommentCTRLTest {

    @testSetUp
    static void setUpData(){
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        Case testCase = new Case();
        testCase.RecordTypeId = trlRecordType.getRecordTypeId();
        testCase.Subject = 'Withdrawn case';
        testCase.Status = 'New';
        insert testCase;
    }

    @IsTest
    static void testTRL_WithdrawnCommentCTRL(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Withdrawn case' LIMIT 1];
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(testCase);

        Test.startTest();

        TRL_WithdrawnCommentCTRL ctrl = new TRL_WithdrawnCommentCTRL(caseStdCtrl);
        
        Test.stopTest();

        System.assertEquals(testCase.Id, ctrl.withdrawnComment.ParentId);
    }

    @IsTest
    static void testSaveComment() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Withdrawn case' LIMIT 1];
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(testCase);
        TRL_WithdrawnCommentCTRL ctrl = new TRL_WithdrawnCommentCTRL(caseStdCtrl);

        User currentUser = new User(Id = UserInfo.getUserId(), TRLcases__c = 'Super User');
        update currentUser;

        ctrl.withdrawnComment.CommentBody = 'Test';

        Test.startTest();

        ctrl.saveComment();

        Test.stopTest();

        Case resultCase = [SELECT Status FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals('Withdrawn', resultCase.Status);
    }

    @IsTest
    static void testSaveCommentError() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Withdrawn case' LIMIT 1];
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(testCase);
        TRL_WithdrawnCommentCTRL ctrl = new TRL_WithdrawnCommentCTRL(caseStdCtrl);

        ctrl.withdrawnComment.ParentId = null;

        Test.startTest();

        ctrl.saveComment();

        Test.stopTest();

        List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        Boolean messageFound = false;
        for(ApexPages.Message message : pageMessages) {
            if( message.getDetail() == 'You can not withdrawn the case' && message.getSeverity() == ApexPages.Severity.ERROR) {
                messageFound = true;
            }
        }
        System.assert(messageFound);
    }

    @IsTest
    static void testCancelComment(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Withdrawn case' LIMIT 1];
        ApexPages.StandardController caseStdCtrl = new ApexPages.StandardController(testCase);
        TRL_WithdrawnCommentCTRL ctrl = new TRL_WithdrawnCommentCTRL(caseStdCtrl);

        Test.startTest();

        ctrl.cancel();
        Test.stopTest();

        System.assertEquals(testCase.Id, ctrl.withdrawnComment.ParentId);
    }

}
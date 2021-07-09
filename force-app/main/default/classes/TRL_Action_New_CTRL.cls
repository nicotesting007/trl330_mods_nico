/***
*  @name: TRL Case priorization calculation class
*  @GUS:   ... #W-8937515
*  @Author: 
*  @CreationDate: 
*  @LastUpdate: 2021-March-31 by thoeger@mulesoft.com 
* */

public with sharing class TRL_Action_New_CTRL {
    
    public Case newCase {get; set;}
    
    //Nagini's change begin
    string selectedStatus = ApexPages.currentPage().getParameters().get('selectedStatus');
    string selectedTerritory = ApexPages.currentPage().getParameters().get('selectedTerritory');
    string selectedRegion = ApexPages.currentPage().getParameters().get('selectedRegion');
    //Nagini's change end
    
    public TRL_Action_New_CTRL () {
        newCase = new Case();
        Schema.RecordTypeInfo trlRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TRL');
        newCase.RecordTypeId = trlRecordType.getRecordTypeId();
        //Fetching the assignment rules on case
        AssignmentRule useAssignRule;
        try{
            useAssignRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE LIMIT 1];
        } catch(QueryException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Something went wrong, there is no assignment rule'));
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            return;
        }
        
        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        /** this is commented out by thoeger as it is now run after prio calculation 2021-03-31 for W-8937515
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = useAssignRule.Id;
        dmlOpts.emailHeader.triggerAutoResponseEmail = true;
        dmlOpts.emailHeader.triggerUserEmail = true;
        
        // Setting the DMLOption on Case instance
        newCase.setOptions(dmlOpts);
        **/
        // A.I. Comment: TRL 2.2.0 Set defaults
        setDefaults();
    }
    
    public PageReference save() {    //insert case and go to case detail page
        
        PageReference reference;
        try{
            insert newCase;
            //Nagini's change
            reference = new PageReference('/apex/TRLCase_detail_page?id=' + newCase.ID + 
                                          '&selectedStatus=' + selectedStatus + 
                                          '&selectedTerritory=' + selectedTerritory + 
                                          '&selectedRegion=' + selectedRegion);
            
            //Nagini's change
            reference.setRedirect(true);
            TRL_Submit_CasePlatformEvent t = new TRL_Submit_CasePlatformEvent();  // added by thoeger@mulesoft.com 2020-10-21
            t.Submit_TRL_CasePlatformEvent(newCase);  // added by thoeger@mulesoft.com 2020-10-21
            
        } catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not create case'));
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            reference = ApexPages.currentPage();
            reference.setRedirect(false);
        }
        return reference;
    }
    
    public PageReference saveAndNew() {  //insert case and go to current page for create new case
        //PageReference reference = ApexPages.currentPage();
        PageReference reference = new PageReference(ApexPages.currentPage().getUrl());
        reference.setRedirect(true);
        try{
            insert newCase;
            TRL_Submit_CasePlatformEvent t = new TRL_Submit_CasePlatformEvent();  // added by thoeger@mulesoft.com 2020-10-21
            t.Submit_TRL_CasePlatformEvent(newCase);// added by thoeger@mulesoft.com 2020-10-21 
        } catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not create case'));
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            reference.setRedirect(false);
        }
        return reference;
    }
    
    public PageReference cancel() { //go to TRL case list
        //Nagini's change
        PageReference reference = new PageReference('/apex/TRLCases' + 
                                                    '?selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion);
        //Nagini's change
        reference.setRedirect(true);
        return reference;
    }

    private void setDefaults(){
        // A.I. Comment: Set defaults for 2.2.0
        //this.newCase.CS_Reason__c = 'Success Planning and Advisory';
        //this.newCase.CS_Activity__c = 'Regular customer cadence';    
        // Set default value for all as ADHOC for CSSA it is INTERNAL
        this.newCase.TRL_Type__c = 'ADHOC'; // Set Value for Ad-Hoc
        this.newCase.Request_for_Assistance_by__c = 'CSM'; // Set default to CSM
        // Override default value for CSSA
        setTRLTypeCSAA();
    }

    // Method uses Group membership to assign default value INTERNAL if user is a CSSA
    // member of a Public Group TRL Tech Team
    // SOQL: SELECT Id, GroupId, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'TRL_Team'
    // Global team: SELECT Id, GroupId, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'CS_Tech_Global_Team'
    // Global has 1 member - Ramesh???
    private void setTRLTypeCSAA(){
        String uid = UserInfo.getUserId();
        // IN Win'21 could use this code but for now use basic
        //Id gid = [SELECT GroupId 
        //                            FROM GroupMember 
        //                            WHERE UserOrGroupId =: uid AND Group.DeveloperName = 'TRL_Team']?.GroupId;
        List<GroupMember> gmList = [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName 
                                    FROM GroupMember 
                                    WHERE UserOrGroupId =: uid AND Group.DeveloperName = 'TRL_Team'];
        
        if(gmList.size() > 0){
            this.newCase.TRL_Type__c = 'INTERNAL';
            this.newCase.Request_for_Assistance_by__c = 'CSSA';
        }
    }
}
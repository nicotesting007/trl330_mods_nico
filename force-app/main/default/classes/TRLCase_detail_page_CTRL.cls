/***
*  @name: TRL detail Case page controller
*  @GUS:  ....,  #W-8937505  
*  @Author: 
*  @CreationDate: 
*  @LastUpdateBy: thoeger@mulesoft.com
*  @LastUpdate: 2021-March-14
* 
* */

public with sharing class TRLCase_detail_page_CTRL {

    private ApexPages.StandardController ctrl;
    string debugClass = '## TRLCase_detail_page_CTRL ';   //added for more detailed debugging by thoeger
    
    //Nagini's change begin
	string selectedStatus = ApexPages.currentPage().getParameters().get('selectedStatus');
    string selectedTerritory = ApexPages.currentPage().getParameters().get('selectedTerritory');
    string selectedRegion = ApexPages.currentPage().getParameters().get('selectedRegion');
    //Nagini's change end
    // A.I. Change add search expression to parameters
    public string searchExpression = ApexPages.currentPage().getParameters().get('searchExpression');
    //Nagini's change end

    public TRLCase_detail_page_CTRL (ApexPages.StandardController ctrlParam) {
        ctrl = ctrlParam;
        Final String debugMethod = debugClass + ' TRLCase_detail_page_CTRL ';
        system.debug(debugMethod + 'Ctrl: '+ctrl);
    }
    // A.I. Update method to build pass parmeters (need to refactor this methods idea of passing parms as URL)
    private String parameterString(){
        if (selectedStatus == null)
        	selectedStatus = '';
    	if (selectedTerritory == null)
        	selectedTerritory = '';
    	if (selectedRegion == null)
            selectedRegion = '';
        if (searchExpression == null){searchExpression = '';}
        String parm = '&selectedStatus=' + selectedStatus + 
                        '&selectedTerritory=' + selectedTerritory + 
                        '&selectedRegion=' + selectedRegion +
                        '&searchExpression=' + searchExpression;
        return parm;
    }
    public PageReference edit() {
    /**
        //Nagini's change begin: retrieving the parameters and passing to TRL_Action_Edit
        if (selectedStatus == null)
        	selectedStatus = '';
    	if (selectedTerritory == null)
        	selectedTerritory = '';
    	if (selectedRegion == null)
            selectedRegion = '';
        if (searchExpression == null){searchExpression = '';}
        PageReference reference = new PageReference('/apex/TRL_Action_Edit?id=' + ctrl.getRecord().get('Id') + 
                                                    '&selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion +
                                                    '&searchExpression=' + searchExpression);
        //PageReference reference = new PageReference('/apex/TRL_Action_Edit?id=' + ctrl.getRecord().get('Id'));
        //Nagini's change end
    */
        // A.I. Code refactoring pass parms
        PageReference reference = new PageReference('/apex/TRL_Action_Edit?id=' + ctrl.getRecord().get('Id') + parameterString());
        
        reference.setRedirect(true);
        return reference;
    }

    public PageReference goToComments() {
        //Nagini's change
        if (selectedStatus == null)
        	selectedStatus = '';
    	if (selectedTerritory == null)
        	selectedTerritory = '';
    	if (selectedRegion == null)
        	selectedRegion = ''; 
        PageReference reference = new PageReference('/00a/e' + 
                                                    '?parent_id='  + ctrl.getRecord().get('Id') + 
                                                    '&retURL=/apex/TRLCase_detail_page?id=' + ctrl.getRecord().get('Id') + 
                                                    '%26selectedStatus=' + selectedStatus +
                                                    '%26selectedTerritory=' + selectedTerritory +
                                                    '%26selectedRegion=' + selectedRegion +
                                                    '%26searchExpression=' + searchExpression +
                                                    '&saveURL=/apex/TRLCase_detail_page?id=' + ctrl.getRecord().get('Id') +
                                                    '%26selectedStatus=' + selectedStatus +
                                                    '%26selectedTerritory=' + selectedTerritory +
                                                    '%26searchExpression=' + searchExpression +
                                                    '%26selectedRegion=' + selectedRegion);
        //'{!Case.Id}',null,'newComment'); return false;"
        
        //Nagini's change
        reference.setRedirect(true);
        return reference;
    }
    
    public PageReference deleteRecord(){
    /**
        //Nagini's change
        if (selectedStatus == null)
        	selectedStatus = '';
    	if (selectedTerritory == null)
        	selectedTerritory = '';
    	if (selectedRegion == null)
        	selectedRegion = '';
        PageReference reference = new PageReference('/apex/TRLCases' + 
                                                    '?selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion);
        //Nagini's change
    */
        // A.I. Code refactoring pass parms
        PageReference reference = new PageReference('/apex/TRLCases?' + parameterString());

        reference.setRedirect(true);
        try{
            delete new Case(Id = (Id) ctrl.getRecord().get('Id'));
        } catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not delete case'));
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            reference = ApexPages.currentPage();
            reference.setRedirect(false);
        }
        return reference;
    }

    public PageReference cancel() {
    /**
        //Nagini's change begin: retrieving the parameters and passing back to TRLCases
        if (selectedStatus == null)
        	selectedStatus = '';
    	if (selectedTerritory == null)
        	selectedTerritory = '';
    	if (selectedRegion == null)
        	selectedRegion = '';
        PageReference reference = new PageReference('/apex/TRLCases' + 
                                                    '?selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion);
        //Nagini's change end
     */    
        // A.I. Code refactoring pass parms
        PageReference reference = new PageReference('/apex/TRLCases?' + parameterString());

        reference.setRedirect(true);
        return reference;
    }
    
    public PageReference withdrawnCase() {
    /**
        //Nagini's change
        if (selectedStatus == null)
        	selectedStatus = '';
    	if (selectedTerritory == null)
        	selectedTerritory = '';
    	if (selectedRegion == null)
        	selectedRegion = '';
        PageReference reference = new PageReference('/apex/TRL_WithdrawnComment?id=' + ctrl.getRecord().get('Id') + 
                                                    '&selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion);
        //Nagini's change
     */    
        // A.I. Code refactoring pass parms
        PageReference reference = new PageReference('/apex/TRL_WithdrawnComment?id=' + ctrl.getRecord().get('Id') + parameterString());
        
        reference.setRedirect(true);
        return reference;
    }

    public List<CaseComment> getCaseComments() {
        try {
            return [SELECT CreatedDate, CommentBody, CreatedById, IsPublished FROM CaseComment
            WHERE ParentId = :(Id) ctrl.getRecord().get('Id') ORDER BY CreatedDate DESC LIMIT 1000];
        } catch(QueryException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Something went wrong, can not find case comments'));
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            return new List<CaseComment>();
        }
    }

}
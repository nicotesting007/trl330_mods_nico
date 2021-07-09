public with sharing class TRL_Action_Edit_CTRL {

    private ApexPages.StandardController ctrl;
    
    //Nagini's change begin
	string selectedStatus = ApexPages.currentPage().getParameters().get('selectedStatus');
    string selectedTerritory = ApexPages.currentPage().getParameters().get('selectedTerritory');
    string selectedRegion = ApexPages.currentPage().getParameters().get('selectedRegion');
    //Nagini's change end
    
    public TRL_Action_Edit_CTRL (ApexPages.StandardController ctrlParam) {
    	ctrl = ctrlParam;
    }

    public PageReference updateRecord() {        
        //Nagini's change
        PageReference reference = new PageReference('/apex/TRLCase_detail_page?id=' + ctrl.getRecord().get('id') + 
                                                    '&selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion);
       //Nagini's change
        reference.setRedirect(true);
        try{
            update ctrl.getRecord();
            TRL_Submit_CasePlatformEvent t = new TRL_Submit_CasePlatformEvent();  // added by thoeger@mulesoft.com 2020-10-21
            Case c = (case)ctrl.getRecord();
            t.Submit_TRL_CasePlatformEvent(c);// added by thoeger@mulesoft.com 2020-10-21 
        } catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not edit the case'));
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            reference = ApexPages.currentPage();
            reference.setRedirect(false);
        }
        return reference;
    }

    public PageReference saveAndNew() {
        //Nagini's change
        PageReference reference = new PageReference('/apex/TRL_Action_New' + 
                                                    '&selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion);
        //Nagini's change
        reference.setRedirect(true);
        try{
            update ctrl.getRecord();
            TRL_Submit_CasePlatformEvent t = new TRL_Submit_CasePlatformEvent();  // added by thoeger@mulesoft.com 2020-10-21
            Case c = (case)ctrl.getRecord();
            t.Submit_TRL_CasePlatformEvent(c);// added by thoeger@mulesoft.com 2020-10-21 
        } catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not edit the case'));
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            reference.setRedirect(false);
        }
        return reference;
    }

    public PageReference cancel() {
        //Nagini's change
        PageReference reference = new PageReference('/apex/TRLCase_detail_page?id=' + ctrl.getRecord().get('id') + 
                                                    '&selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion);
        //Nagini's change
        reference.setRedirect(true);
        return reference;
    }

    // 
}
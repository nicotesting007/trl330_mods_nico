/**
 * Created by Vladimir on 10/2/2019.
 */

public without sharing class TRL_WithdrawnCommentCTRL {

    private ApexPages.StandardController ctrl;
    public CaseComment withdrawnComment {get; set;}

    //Nagini's change begin
	string selectedStatus = ApexPages.currentPage().getParameters().get('selectedStatus');
    string selectedTerritory = ApexPages.currentPage().getParameters().get('selectedTerritory');
    string selectedRegion = ApexPages.currentPage().getParameters().get('selectedRegion');
    //Nagini's change end
    
    public TRL_WithdrawnCommentCTRL (ApexPages.StandardController ctrlParam) {
        withdrawnComment = new CaseComment(ParentId = ctrlParam.getRecord().Id, IsPublished = true);
        ctrl = ctrlParam;
    }

    public PageReference saveComment() {
        //Nagini's change
        PageReference reference = new PageReference('/apex/TRLCase_detail_page?id=' + ctrl.getRecord().get('id') + 
                                                    '&selectedStatus=' + selectedStatus + 
                                                    '&selectedTerritory=' + selectedTerritory + 
                                                    '&selectedRegion=' + selectedRegion);
        //Nagini's change
        reference.setRedirect(true);
        try{
            insert withdrawnComment;
            update new Case(Id = withdrawnComment.ParentId, Status = 'Withdrawn');
        } catch(DmlException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not withdrawn the case'));
            System.debug(ex.getMessage() + '\n' + ex.getCause());
            reference = ApexPages.currentPage();
            reference.setRedirect(false);
        }
        return reference;
    }
    // Nagini's change begin
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
    //Nagini's change end
}
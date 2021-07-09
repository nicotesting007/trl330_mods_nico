/*
 * App TRL Time_tracking__c custom controller
 *
 * author: A.I.
 */
public with sharing class TRL_TimeTracking_ExtCtrl {

    public Time_tracking__c newTimeTrack {get; set;}
    // Get Page URL Parameters
    public String relatedCaseId = System.currentPageReference().getParameters().get('caseid');
    String caseNumber = System.currentPageReference().getParameters().get('casenumber');
    String accountName = System.currentPageReference().getParameters().get('account_name');
    String retURL = System.currentPageReference().getParameters().get('retURL');
    String saveURL = System.currentPageReference().getParameters().get('saveURL');
    String defaultPageURL = '';
    // Handle TRL List page parameters
    public string selectedStatus = ApexPages.currentPage().getParameters().get('selectedStatus');
    public string selectedTerritory = ApexPages.currentPage().getParameters().get('selectedTerritory');
    public string selectedRegion = ApexPages.currentPage().getParameters().get('selectedRegion');
    // ----
  
    public TRL_TimeTracking_ExtCtrl() {
        init();
    }

    private void init(){
        this.newTimeTrack = new Time_tracking__c();
        this.newTimeTrack.Case__c = this.relatedCaseId;
        this.newTimeTrack.Delivery_Resource__c = UserInfo.getUserId();
        this.defaultPageURL = '/apex/TRLCase_detail_page?id='+this.relatedCaseId;
        // A.I. Comment for 2.2.0 set defaults new fields
        setDefaultFields(this.relatedCaseId);

        setSelectedParams();
        myDebug();
    }
    // Set default fields for Reason and Activity based on Case selection if they exists
    // For not existing default Success Planning and Advisory
    private void setDefaultFields(String trlCaseId){
        // Base defaults
        this.newTimeTrack.CS_Reason__c = 'Success Planning and Advisory';
        this.newTimeTrack.CS_Activity__c = 'Regular customer cadence';    
        this.newTimeTrack.Activity_Date__c = Date.Today();
        // Query Case to read Activity type values
        try{
            Case trl = [SELECT Id, CS_Reason__c, CS_Activity__c FROM Case WHERE Id =: trlCaseId];
            if(trl != null && trl.CS_Reason__c != null){
                this.newTimeTrack.CS_Reason__c = trl.CS_Reason__c;
            }
            if(trl != null && trl.CS_Activity__c != null){
                this.newTimeTrack.CS_Activity__c = trl.CS_Activity__c;    
            }    
        }catch(Exception ex){
            System.debug('No TRL Case set Reason and Activity');
        } 
    }

    private void setSelectedParams(){
        if (this.selectedStatus == null)
        	this.selectedStatus = '';
    	if (this.selectedTerritory == null)
        	this.selectedTerritory = '';
    	if (this.selectedRegion == null)
        	this.selectedRegion = '';
    }
    private void myDebug(){
        System.debug('## selectedStatus: '+selectedStatus);
        System.debug('## selectedTerritory: '+selectedTerritory);
        System.debug('## selectedRegion: '+selectedRegion);
    }

    private PageReference getPageRedirect(String url){
        PageReference pageRef = null;
        if (url != null && url.length()>0){
            pageRef = new PageReference(url);
        }
        return pageRef;
    }

    private PageReference getDefaultPageRedirect(String url){
        PageReference pageRef = getPageRedirect(url);
        if (pageRef == null){
            pageRef = new PageReference(this.defaultPageURL);                                                    
        }
        return pageRef;
    }

    public PageReference save(){
        insert newTimeTrack;
        return getDefaultPageRedirect(this.saveURL);
    }

    public PageReference cancelAction(){
        System.debug('### CANCEL Action, redirect:'+this.retURL+' OR Page: '+this.defaultPageURL);
        myDebug();
        return getDefaultPageRedirect(this.retURL);
    }

    public PageReference saveNew(){
        insert newTimeTrack;
        // Clear entry
        this.newTimeTrack = new Time_tracking__c();
        this.newTimeTrack.Case__c = this.relatedCaseId;
        this.newTimeTrack.Delivery_Resource__c = UserInfo.getUserId();

        ///this.defaultPageURL = '/apex/TRLCase_detail_page?id='+this.relatedCaseId;
        // A.I. Comment for 2.2.0 set defaults new fields
        this.newTimeTrack.CS_Reason__c = 'Success Planning and Advisory';
        this.newTimeTrack.CS_Activity__c = 'Regular customer cadence';    
        this.newTimeTrack.Activity_Date__c = Date.Today();

        return null;
    }

}

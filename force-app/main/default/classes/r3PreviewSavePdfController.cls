public class r3PreviewSavePdfController 
{
  
	@auraEnabled
    public static void savePDF(String vfpage, String recordId, String filename, String fileGroup, String fileType)
    {
        PageReference pdfPage = new PageReference('/apex/'+vfpage);
		pdfPage.getParameters().put('Id', recordId);

        // old school attachments (keep in case ever needed again!)...
        //Attachment attach1= new Attachment();
        //attach1.ParentId = '0010K00001e2kcG';
        //attach1.Name = 'Test Attachment for PDF';
        //attach1.Body = pdfContent;
        //attach1.contentType = 'application/pdf';
		//insert attach1;

        // write new file...
              
        // existing document with same title?...
        LIST<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocumentId IN (SELECT Id FROM ContentDocument WHERE Title = :filename)];
        ContentDocumentLink cdl = null;
        if(!cdls.isEmpty()) cdl = cdls[0];  // take the first if there are duplicate names(!)...  TODO is this right?
              
        // create new document version...
        ContentVersion cont = new ContentVersion();
        if(cdl != null) 
            cont.ContentDocumentId = cdl.ContentDocumentId;  // add new version rather than new file (if exists)
        cont.Title = filename;
        cont.PathOnClient = filename + '.pdf';
        cont.Type__c = fileType;
        cont.Group__c = fileGroup;
        if (Test.IsRunningTest())
            cont.VersionData = Blob.valueOf('UNIT.TEST');   // to support test methods...
        else
            cont.VersionData = pdfPage.getContent();
        insert cont;
              
        if(cdl == null)
        {
            // new document => need to create link to record...
                
            // get document id...
            cont = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Id = :cont.id];
                
            // create link...
            cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cont.ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
    }
}
}
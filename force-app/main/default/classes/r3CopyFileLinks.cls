global without sharing class r3CopyFileLinks
//global class r3CopyFileLinks
{
    @InvocableMethod
    global static void copyFileLinks(List<copyFileLinksRequest> requests) 
    {
        for (copyFileLinksRequest request : requests) 
        {
            copyFileLinks(request.sourceId, request.targetId);
        }
    }

    public static void copyFileLinks(Id sourceId, Id targetId)
    {
        List<ContentDocumentLink> cdlsToInsert = new List<ContentDocumentLink>();

        // get CDLs...
        List<ContentDocumentLink> SourceCdls = [SELECT LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :SourceId];
        List<ContentDocumentLink> targetCdls = [SELECT LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :targetId];

        // get a set of content documents refered to by the target (to check for duplicates)
        Set<String> targetKeys = new Set<String>();
        for(ContentDocumentLink cdl : targetCdls)
            targetKeys.add(cdl.ContentDocumentId);

        // get CDLs for source record...
		for(ContentDocumentLink cdl: sourceCdls)
        {
            // Does the target already have a link to the content document?
            if(!targetKeys.contains(cdl.ContentDocumentId))
            {
                ContentDocumentLink newcdl = new ContentDocumentLink();
                newcdl.ContentDocumentId = cdl.ContentDocumentId;
                newcdl.LinkedEntityId = targetId;
                newcdl.ShareType = cdl.ShareType;
                newcdl.Visibility = cdl.Visibility;
                cdlsToInsert.add(newcdl);

                system.debug('R3>>> Creating CDR record relatedTo:'+newcdl.LinkedEntityId+', contentDocument:'+newcdl.ContentDocumentId);
            }
        }

        // create target cdl records!
        if(!cdlsToInsert.isEmpty())
            insert cdlsToInsert;
    }


    global class copyFileLinksRequest 
    {
        @InvocableVariable(required=true)
        global ID sourceId;

        @InvocableVariable(required=true)
        global ID targetId;
    }
}
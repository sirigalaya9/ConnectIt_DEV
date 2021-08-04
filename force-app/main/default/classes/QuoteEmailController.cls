public with sharing class QuoteEmailController {
    @AuraEnabled
    public static EmailRequest getEmailRequest(Id recordId, String bodyTemplateName, String signatureTemplateName)
    {
        System.debug('getEmailRequest');

        //Queries        
        //EmailTemplate bodyEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :bodyTemplateName];
        EmailTemplate signatureEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :signatureTemplateName];
        
        //Generate template body
        Id whoId = UserInfo.getUserId();
        Id whatId = recordId;                    
        //Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(bodyEmailTemplate.Id, whoId, whatId);
        Messaging.SingleEmailMessage signatureMessage = Messaging.renderStoredEmailTemplate(signatureEmailTemplate.Id, whoId, whoId);        

        //Create request
        EmailRequest req = new EmailRequest();        
        req.signatureText = signatureMessage.getHtmlBody();        
        return req;
    }

    public class EmailRequest
    {
        @AuraEnabled
        public String toAddress { get; set; }
        @AuraEnabled
        public String ccAddress { get; set; }
        @AuraEnabled
        public String bccAddress { get; set; }    
        @AuraEnabled        
        public String salutationText { get; set; }            
        @AuraEnabled
        public String subject { get; set; }
        @AuraEnabled
        public String lockedText1 { get; set; }
        @AuraEnabled
        public String signatureText { get; set; }                                
    }
    
   @AuraEnabled 
    public static String sendEmail(Id recordId, String toAddress, String ccAddress, String subject, String salutationText, String bodyText, 
                                   String signatureText, Id contentDocumentId, Id contentVersionId, String bccAddress, Boolean isPreview, Id quoteId)
    {
        System.debug('Send Email');

        String body = salutationText + '<br/><br/>' + bodyText + '<br/><br/>' + signatureText; 
        
        if (isPreview == true)
        {
            return body;
        }

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();             
        message.setHtmlBody(body);
        message.setSubject(subject);
        //message.setTargetObjectId(whoId);
        message.setSaveAsActivity(false); //Save the message as activity on person account
        List<String> toAddresses = new List<String>{ toAddress };        
        message.setToAddresses(toAddresses);
        try
        {
            if (String.isNotBlank(ccAddress))
            {
                ccAddress = ccAddress.deleteWhitespace();
                List<String> ccAddresses = ccAddress.split(',');                
                message.setCcAddresses(ccAddresses);
            }            
        }
        catch (Exception e) 
        {
            System.debug('error parsing cc address');
            throw new AuraHandledException('Cc Address incorrect format.');
        }
        try
        {
            if (String.isNotBlank(bccAddress))
            {
                bccAddress = bccAddress.deleteWhitespace();
                List<String> bccAddresses = bccAddress.split(',');
                message.setBccAddresses(bccAddresses);
            }            
        }
        catch (Exception e) 
        {
            System.debug('error parsing bcc address');
            throw new AuraHandledException('Bcc Address incorrect format.');
        }        
        if (contentVersionId != NULL)
        {
            message.setEntityAttachments(new List<Id>{ contentVersionId });
        }        
        mails.add(message);
        Messaging.sendEmail(mails);

        //Log Email Message
        {
            EmailMessage em = new EmailMessage();
            em.Status = '3';
            em.relatedToId = recordId;        
            em.fromAddress = System.UserInfo.getUserEmail();
            em.fromName = System.UserInfo.getName();
            em.toAddress = toAddress;
            em.ccAddress = ccAddress;
            em.bccAddress = bccAddress;
            em.Subject = subject;
            em.HtmlBody = body;
            insert em;        
            if (contentDocumentId != NULL)
            {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocumentId;
                cdl.LinkedEntityId = em.Id;
                cdl.ShareType = 'V';
                insert cdl;
            }
        }

        if (quoteId != null)        
        {
            EmailMessage em = new EmailMessage();
            em.Status = '3';
            em.relatedToId = quoteId;        
            em.fromAddress = System.UserInfo.getUserEmail();
            em.fromName = System.UserInfo.getName();
            em.toAddress = toAddress;
            em.ccAddress = ccAddress;
            em.bccAddress = bccAddress;
            em.Subject = subject;
            em.HtmlBody = body;
            insert em;        
            if (contentDocumentId != NULL)
            {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocumentId;
                cdl.LinkedEntityId = em.Id;
                cdl.ShareType = 'V';
                insert cdl;
            }            
        }
		
        return null;        
    }       
}
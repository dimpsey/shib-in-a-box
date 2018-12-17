Feature: Common tests
    
    Scenario Outline: Common tests

        Given allow redirects is set to 'False'  

        Given start new session
        
        Given aws login cookie 'yoonlees'
        
        Given GET url '<base>/elmrsample/attributes' 
        Then response is a redirect to url '/auth/elmr/session'
        Then response status code is '302'

        # Given GET url '<base>/auth/elmr/session' 
        Given follow redirect 
        Then response status code is '302'
        Then response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'

        Given follow redirect 
        Then response status code is '200'
        Then POST the SAMLResponse to the SP

        Examples: 
          |base             |
          #-----------------#
          |https://multi-service.as-test.techservices.illinois.edu|     


         

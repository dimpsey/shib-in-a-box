Feature: Log in to elmrsample with an IdP session
    
    Scenario Outline: Log in to elmrsample with an IdP session
 
        Given allow redirects is set to 'False'  

        Given start new session
       
        # We are given a valid IdP session 
        Given aws login cookie 'yoonlees'
        
        # We are redirected to /auth/elmr/session because we don't have an elmr session
        Given GET url '<base>/elmrsample/attributes' 
        Then response is a redirect to url '/auth/elmr/session'
        And response status code is '302'
        And response sets cookies with values
            | key                                         | value                  |
            #----------------------------------------------------------------------#
            | __edu.illinois.techservices.elmr.serviceUrl | /elmrsample/attributes |
 
        # We are redirected to the IdP because we don't have a SP session
        Given follow redirect 
        Then response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'
        Then response status code is '302'
        And response sets no cookies        

        # IdP returns the SAMLResponse
        Given follow redirect 
        Then response status code is '200'
        And response sets no cookies        

        Then POST the SAMLResponse to the SP
        Then response is a redirect to url '<base>/auth/elmr/session'
        And response status code is '302'
        And response sets no cookies        

        # Now we have a valid SP session so we can access elmr
        Given follow redirect 
        Then response is a redirect to url '/elmrsample/attributes'
        And response status code is '302'
        And response sets cookies
            | name                                                 | 
            #------------------------------------------------------#
            | __edu.illinois.techservices.elmr.servlets.sessionKey |
        

        # Now we have a valid elmr session so we can access elmrsample
        Given follow redirect 
        Then response status code is '200'
        And response sets no cookies        

        Examples: 
          |base                                                   |
          #-------------------------------------------------------#
          |https://multi-service.as-test.techservices.illinois.edu|     

Feature: Test that all cgi-bin scripts are enabled and shib protected
    
    Background: 

        Given allow redirects is set to 'False'  

        # Given a invalid SP session
 
    Scenario: Test that environment page is enabled and shib protected

        Given GET url '$(url.base)/auth/cgi-bin/environment' 
        Then response status code is '302'
        And response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'

    Scenario: Test that redis page is enabled and shib protected

        Given GET url '$(url.base)/auth/cgi-bin/redis' 
        Then response status code is '302'
        And response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'

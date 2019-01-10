Feature: Local test that elmr config is enabled and shib protected
    
    Scenario: Local test that elmr config is enabled and shib protected

        Given allow redirects is set to 'False'  

        # Given a invalid SP session
        Given GET url '$(url.base)/auth/elmr/config' 
        Then response status code is '302'
        And response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'
        And response sets no cookies 

Feature: Test that shibd is accessible and functioning
    
    Scenario: Test that shibd is accessible and functioning

        # Check Shibboleth Metadata is accessible
        Given GET url '$(url.base)/auth/Shibboleth.sso/Metadata' 
        Then response status code is '200'

        # Check Shib SP CSS is accessible
        Given GET url '$(url.base)/auth/shibboleth-sp/main.css' 
        Then response status code is '200'

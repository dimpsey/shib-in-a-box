Feature: Basic test to ping a url
    
    Scenario: Basic test to see if pinging a url works

        Then url 'http://127.0.0.1/auth/Shibboleth.sso/Metadata' returns status code '200'
        

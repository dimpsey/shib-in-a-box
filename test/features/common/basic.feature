Feature: Basic test to ping a url
    
    Scenario: Basic test to see if pinging a url works

        # Expect no content at /
        Then url 'http://127.0.0.1' returns status code '403' 

        Then url 'http://localhost/cgi-bin/environment' returns status code '403' 

        Given GET url 'http://127.0.0.1' 

        Then request body does not contain 'Testing 123'

        # Check Shibboleth Metadata is correct
        And url 'http://127.0.0.1/auth/Shibboleth.sso/Metadata' returns status code '200'

        And url 'http://127.0.0.1/Shibboleth.sso/Metadata' returns status code '403'

        And url 'http://localhost/auth/shibboleth-sp/main.css' returns status code '200'
        
        # curl -sS http://127.0.0.1/auth/Shibboleth.sso/Metadata | diff -q - Metadata.auth

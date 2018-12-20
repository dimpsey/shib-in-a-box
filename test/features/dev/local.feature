Feature: Local test to ping a url
    
    Scenario: Local test to see if pinging a url works

        Given allow redirects is set to 'False'  

        Given GET url 'http://127.0.0.1' 
        Then request body does not contain 'Testing 123'
        Then response status code is '403'

        # TODO: Apache config is broken
        # Given GET url 'http://127.0.0.1/cgi-bin/environment'
        # Then response status code is '403'

        Given GET url 'http://127.0.0.1/Shibboleth.sso/Metadata' 
        Then response status code is '403'

        Given GET url 'http://127.0.0.1/elmrsample/attributes' 
        Then response status code is '302'
        Then response is a redirect to url 'http://127.0.0.1/auth/elmr/session'

        # Given GET url 'http://127.0.0.1/auth/elmr/session' 
        # Then response is a redirect to url 'http://127.0.0.1/elmrsample/attributes'
        # Then response status code is '302'

        # Given GET url 'http://127.0.0.1/elmrsample/attributes' 
        # Then response status code is '200'

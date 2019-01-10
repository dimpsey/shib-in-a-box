Feature: Local test to ping a url
    
    Scenario: Local test to see if pinging a url works

        Given allow redirects is set to 'False'  

        Given GET url '$(url.base)' 
        Then request body does not contain 'Testing 123'
        Then response status code is '403'

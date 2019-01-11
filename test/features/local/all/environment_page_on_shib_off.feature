Feature: Test that environment page is enabled
    
    Scenario: Test that environment page is enabled

        Given allow redirects is set to 'False'  

        # Given a valid SP session
        Given GET url '$(url.base)/auth/cgi-bin/environment' 
        Then response status code is '200'
        And response sets no cookies 

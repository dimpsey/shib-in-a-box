Feature: Test that environment page is disabled
    
    Scenario: Test that environment page is disabled

        Given allow redirects is set to 'False'  

        # Given a valid SP session
        Given GET url '$(url.base)/auth/cgi-bin/environment' 
        Then response status code is '403'
        And response sets no cookies 

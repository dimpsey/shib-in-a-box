Feature: Test that all cgi-bin scripts are enabled

    Background: 
    
        Given allow redirects is set to 'False'  
        # Given a valid SP session

    Scenario: Test that environment page is enabled

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/environment' 
        Then response status code is '200'

    Scenario: Test that redis  page is enabled

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/list' 
        Then response status code is '200'

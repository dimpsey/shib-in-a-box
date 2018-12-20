Feature: Local test that elmr config is enabled
    
    Scenario Outline: Local test that elmr config is enabled

        Given allow redirects is set to 'False'  

        # Given a valid SP session
        Given GET url '<base>/auth/elmr/config' 
        Then response status code is '200'
        And response sets no cookies 
 
        Examples: 
            |base                                                   |
            #-------------------------------------------------------#
            |http://127.0.0.1                                       |                           

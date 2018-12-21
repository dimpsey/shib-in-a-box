Feature: Local test that elmr config is disabled
    
    Scenario Outline: Local test that elmr config is disabled

        Given allow redirects is set to 'False'  

        # Given a valid SP session
        Given GET url '<base>/auth/elmr/config' 
        Then response status code is '403'
        And response sets no cookies 
 
        Examples: 
            |base                                                   |
            #-------------------------------------------------------#
            |http://127.0.0.1                                       |                           

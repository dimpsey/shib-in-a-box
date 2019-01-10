Feature: Elmrsample test
    
    Scenario: Elmrsample test

        Given allow redirects is set to 'False'  
        Given start new session

        # Given a valid SP session
        # Given no elmr session
        Given GET url '$(url.base)/elmrsample/attributes' 
        Then response status code is '302'
        And response sets cookies with values
            # This cookie is used by elmr to remember the initial user url to return
            # to
            | key                                         | value                  |
            #----------------------------------------------------------------------#
            | __edu.illinois.techservices.elmr.serviceUrl | /elmrsample/attributes |
 
        # We are redirected to /auth/elmr/session because we don't have an elmr session
        Given redirect to '$(url.base)/auth/elmr/session'
        Then response status code is '302'
        And response sets cookies with values
            | name                                                 | 
            #------------------------------------------------------#
            | __edu.illinois.techservices.elmr.servlets.sessionKey |

        # Now we have a valid elmr session so we can access elmrsample
        Given redirect to '$(url.base)/elmrsample/attributes' 
        Then response status code is '200'
        And response sets cookies
            | name                                                 | 
            #------------------------------------------------------#
            | JSESSIONID                                           |

Feature: Local test to ping a url
    
    Scenario Outline: Local test to see if pinging a url works

        Given allow redirects is set to 'False'  

        Given GET url '<base>' 
        Then request body does not contain 'Testing 123'
        Then response status code is '403'

        Given GET url '<base>/cgi-bin/environment'
        Then response status code is '403'

        Given GET url '<base>/Shibboleth.sso/Metadata' 
        Then response status code is '403'

        Given start new session

        # We are redirected to /auth/elmr/session because we don't have an elmr session
        Given GET url '<base>/elmrsample/attributes' 
        Then response status code is '302'
        And response sets cookies with values
            # This cookie is used by elmr to remember the initial user url to return
            # to
            | key                                         | value                  |
            #----------------------------------------------------------------------#
            | __edu.illinois.techservices.elmr.serviceUrl | /elmrsample/attributes |
 
        # We are redirected to the IdP because we don't have a SP session
        Given redirect to '<base>/auth/elmr/session'
        # When BREAKPOINT
        Then response status code is '302'
        And response sets cookies with values
            | name                                                 | 
            #------------------------------------------------------#
            | __edu.illinois.techservices.elmr.servlets.sessionKey |

        # Now we have a valid elmr session so we can access elmrsample
        Given redirect to '<base>/elmrsample/attributes' 
        Then response status code is '200'
        And response sets cookies
            | name                                                 | 
            #------------------------------------------------------#
            | JSESSIONID                                           |

        Examples: 
            |base                                                   |
            #-------------------------------------------------------#
            |http://127.0.0.1                                       |                           

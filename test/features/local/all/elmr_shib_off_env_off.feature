Feature: Elmr tests for MOCK_SHIB is true and ENABLE_ENVIRONMENT_PAGE is false 

    Scenario: Elmr test with no serviceUrl cookie set
        Given allow redirects is set to 'False'
        Given start new session

        # We are redirected to /auth/elmr/session because we don't have an elmr session
        Given GET url '$(url.base)/auth/elmr/session'
        Then response status code is '302'
        Then response is a redirect to url '$(url.base)/any/path'
        And response sets cookies with values
            | name                                                 |
            #------------------------------------------------------#
            | $(elmr.sessionKey) |

    Scenario: Elmr test with valid serviceUrl cookie set
        Given allow redirects is set to 'False'
        Given start new session

        # Given a valid SP session
        # Given no elmr session
        Given the cookie '$(elmr.serviceUrl)' with domain '$(url.domain)', path '/', and value '/any/path'
            | attribute      | value               |
            #--------------------------------------#
            | Secure         | fals                |
            | HttpOnly       | false               |
        
        # We are redirected to /auth/elmr/session because we don't have an elmr session
        Given GET url '$(url.base)/auth/elmr/session'
        Then response status code is '302'
        Then response is a redirect to url '$(url.base)/any/path'
        And response sets cookies with values
            | name                                                 |
            #------------------------------------------------------#
            | $(elmr.sessionKey) |

# TODO: Found a bug in elmrsample. File ticket!
#        And the cookie '$(elmr.sessionKey)' with domain '$(url.domain)' and path '/' has the following attributes 
#            | attribute      | value               |
#            #--------------------------------------#
#            | Secure         | true                |
#            | HttpOnly       | true                |
# https://tools.ietf.org/html/rfc6265#section-4.1.2
# https://tools.ietf.org/html/rfc6265#section-8

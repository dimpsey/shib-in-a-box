Feature: Elmr tests for MOCK_SHIB is true and ENABLE_DEBUG_PAGES is false 

    Scenario: Elmr test with no serviceUrl cookie set
        Given allow redirects is set to 'False'
        Given start new session

        # This is a bad request and we expect 400 status code
        Given GET url '$(url.base)/auth/elmr/session'
        Then response status code is '400'

    Scenario: Elmr test with valid serviceUrl cookie set
        Given allow redirects is set to 'False'
        Given start new session

        # Given a valid SP session
        # Given no elmr session
        # TODO: Figure out why localhost.local for domain works
        # TODO: Figure out why localhost not 127.0.0.1 works
        Given session cookie '$(elmr.serviceUrl)' with value '/any/path'
            | attribute      | value               |
            #--------------------------------------#
            #| Domain         | $(url.base)         |
            | Domain         | localhost.local         |
            | Path           | /                   |
            | Secure         | false               |
            | HttpOnly       | false               |
        
        # We are redirected to /auth/elmr/session because we don't have an elmr session
        # Given GET url '$(url.base)/auth/elmr/session'
        Given GET url 'http://localhost/auth/elmr/session'
        Then response status code is '302'
        # Then response is a redirect to url '$(url.base)/any/path'
        Then response is a redirect to url 'http://localhost/any/path'
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

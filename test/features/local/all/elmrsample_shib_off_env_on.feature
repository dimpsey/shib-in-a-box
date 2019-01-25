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
        #
        # https://tools.ietf.org/html/rfc7234
        # TODO: Add tests that Cache-Control header is set to no-cache; no-store
# TODO: We need to check that the following are set correctly on the cookie:
#       Domain = $(url.domain)
#       Path = "/"
#       Secure
#       HttpOnly
#
# https://tools.ietf.org/html/rfc6265#section-4.1.2
# https://tools.ietf.org/html/rfc6265#section-8

        # We are redirected to /auth/elmr/session because we don't have an elmr session
        Given redirect to '$(url.base)/auth/elmr/session'
        Then response status code is '302'
        And response sets cookies with values
            | name                                                 |
            #------------------------------------------------------#
            | __edu.illinois.techservices.elmr.servlets.sessionKey |
        # TODO: Add tests that Cache-Control header is set to no-cache; no-store
# TODO: We need to check that the following are set correctly on the cookie:
#       Domain = $(url.domain)
#       Path = "/"
#       Secure
#       HttpOnly
#
# https://tools.ietf.org/html/rfc6265#section-4.1.2
# https://tools.ietf.org/html/rfc6265#section-8

        # TODO Need to check that Redis data was stored

        # Now we have a valid elmr session so we can access elmrsample
        # Given a valid elmr session
        Given redirect to '$(url.base)/elmrsample/attributes'
        Then response status code is '200'
        And response sets cookies
            | name                                                 |
            #------------------------------------------------------#
            | JSESSIONID                                           |
        # TODO: Add tests that Cache-Control header is set to no-cache; no-store

        # Check that Redis data was stored
        Given GET url '$(url.base)/auth/cgi-bin/redis'
        Then response status code is '200'
        Then json body contains 
            | key                     | value                  |
            #--------------------------------------------------#
            | displayName             | $(saml.displayName)    |
            | eppn                    | $(saml.eppn)           |

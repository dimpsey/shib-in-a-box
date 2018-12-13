Feature: Shib in a Box is working in the dev environment
    
    Scenario: Shib in a Box is working in the dev environment

        # Expect no content at /
        Then url 'http://127.0.0.1' returns ststus code '403' 

        # Check Shibboleth Metadata is correct
        And url 'http://127.0.0.1/auth/Shibboleth.sso/Metadata' returns status code '200'

        And url 'http://127.0.0.1/auth/Shibboleth.sso/Metadata' returns status code '200'

        And url 'http://localhost/auth/shibboleth-sp/main.css' returns status code '200'

        # Check elmrsample works
        When 'cookie.txt' file is deleted

        Then url 'http://127.0.0.1/elmrsample/attributes' redirects to url 'http://127.0.0.1/auth/elmr/session' with status code '302'
        And url 'http://127.0.0.1/auth/elmr/session' redirects to url 'http://127.0.0.1/elmrsample/attributes' with status code '302'
        And url 'http://127.0.0.1/elmrsample/attributes' returns status code '200'

        # test logout
        And url 'http://127.0.0.1/elmrsample/logout' redirects to url 'http://127.0.0.1/auth/elmr/session?mode=logout' with status code '302'

        And url 'http://127.0.0.1/auth/elmr/session?mode=logout' redirects to url 'http://127.0.0.1/auth/Shibboleth.sso/Logout' with status code '302'

        And url 'http://127.0.0.1/auth/Shibboleth.sso/Logout' retuns status code '200'
    
        # Make sure we really are logged out
        And url 'http://127.0.0.1/elmrsample/attributes' redirects to url 'http://127.0.0.1/auth/elmr/session' with status code '302'

        # Test with no cookies
        And url 'http://127.0.0.1/auth/elmr/session' without cookie returns status code '400'

        And url 'http://127.0.0.1/auth/elmr/session?mode=logout' without cookie returns status code '400'

        And url 'http://127.0.0.1/elmrsample/logout' without cookie returns status code '400'

        # Test that the client's IP is logged not the LB's
        # Note the client IP is hardcoded in the ALB as 1.2.3.4
        And docker-compose log for 'httpd' contains '1.2.3.4'

        And docker-compose log for 'elmr' contains '1.2.3.4'

        And docker-compose log for 'service' contains '1.2.3.4'

        # Ensure httpd redirects when X-Forwarded-Proto is set to http
        # We must connect directly to the httpd container by passing the ALB
        And url '127.0.0.1:8080' with headers '-H "X-Forwarded-Proto: http" -H "X-Forwarded-For: 1.2.3.4" -H "X-Forwarded-Port: 443"' moves to 'https://127.0.0.1:8080/' with status code '301'

        # Test elmr config is avaiable
        And url 'http://127.0.0.1/auth/elmr/config' returns status code '200'

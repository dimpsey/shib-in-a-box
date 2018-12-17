Feature: Common tests
    
    Scenario Outline: Common tests

        # Check Shibboleth Metadata is correct
        Given GET url '<base>/auth/Shibboleth.sso/Metadata' 
        Then response status code is '200'

        Given GET url '<base>/auth/shibboleth-sp/main.css' 
        Then response status code is '200'
        
        # curl -sS <base>/auth/Shibboleth.sso/Metadata | diff -q - Metadata.auth

        Examples:
          |base             |
          #-----------------#
          |http://127.0.0.1 |     
          |https://multi-service.as-test.techservices.illinois.edu|     

@Elmr_login_logout

 Feature:  Test that user logs into Elmr Sample Attributes application
 
 Scenario Outline: Test Elmr login page for user
               
    Given the user sees the UIUC shib login page
    When the user enters <netid> and <password>
    And the user clicks the login button
    Then the user sees the Elmr Sample User Attributes page
    And the user clicks the logout link
    Then the user sees the UIUC shib logout page
                                                                    
 Examples: User who sees the Elmr Sample Attributes page                                                                
 | netid       | password         |  
 | gad01       | G00gle01         | 
                                                                                        

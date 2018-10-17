'''
Behave engine steps to test the login/logout to Elmr Sample Attributes application
'''
# -*- coding: UTF-8 -*-
from common_funcs import find_elem_xpath_click, find_elem_by_id, wait_for_element, \
find_elem_id_text, find_elem_id_click, find_elem_xpath_text, find_field_class_name, \
find_clickable_link_text, \
checkbox_select_state, find_field_id_enter_value

from test_settings import TEST_BROWSER  
from behave import *
from elmr_web_links import * 
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options
#options = Options()
#options.headless = True
#from selenium.webdriver.support import expected_conditions as EC
#from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
#binary = FirefoxBinary('/usr/local/bin/firefox/')
#binary = FirefoxBinary(r'C://program Files (x86)//Mozilla Firefox//firefox.exe')
#driver = webdriver.PhantomJS()
#driver = webdriver.Firefox(firefox_options=options,
#executable_path='/usr/local/bin/geckodriver')
# caps = DesiredCapabilities.FIREFOX
# caps["marionette"] = True
# browser = webdriver.Firefox(capabilities=caps)
#firefox_capabilities = DesiredCapabilities.FIREFOX
#firefox_capabilities['marionette'] = True
#firefox_capabilities['binary'] = '/usr/local/bin/firefox'
#browser = webdriver.Firefox(capabilities=firefox_capabilities)
#browser.get('https://multi-service.as-test.techservices.illinois.edu/elmrsample/attributes')
#driver.get('https://multi-service.as-test.techservices.illinois.edu/elmrsample/attributes')
### Steps for the login/logout feature for Elmr Sample Attributes Application ### 

@given('the user sees the UIUC shib login page')
def UIUC_shib_verify_url(context):
   '''
   Test that the user is on the UIUC shib page
   '''
   uiuc_shib_url = context.browser.current_url
   assert UIUC_PARTIAL_URL in uiuc_shib_url
   context.browser.implicitly_wait(60)

@when('the user enters {netid} and {password}')
def shib_login(context, netid, password):
   '''
   Test Step to check user can successfully log into Elmr Sample Attributes application
   '''
   input_netid = context.browser.find_element_by_id('j_username')
   input_netid.send_keys(netid)
   input_passwd = context.browser.find_element_by_id('j_password')
   input_passwd.send_keys(password)
   context.browser.implicitly_wait(60)

@when('the user clicks the login button')
def login_submit(context):
   '''
   Implementation of test step for a user clicking on the login button
   '''
   click_shib_login = context.browser.find_element_by_xpath('//*[@id="submit_button"]/input')
   click_shib_login.click()
   context.browser.implicitly_wait(60)

@then('the user sees the Elmr Sample Attributes page')
def loginto_elmr(context):
   '''
   Implementation of test step for a user logging into Elmr Sample Attributes application
   '''
   context.browser.implicitly_wait(35)
   Elmr_title = context.browser.find_element_by_xpath('/html/body/div/h1')
   context.browser.implicitly_wait(60)

@when('the user clicks the logout link')
def logout_submit(context):
   '''
   Implementation of test step for a user logging out from Elmr Sample Attributes application
   '''
   context.browser.implicitly_wait(35)
   click_logout = context.browser.find_element_by_xpath('/html/body/div/p[2]/a')
   click_logout.click()
   context.browser.implicitly_wait(60)

@then('the user sees the UIUC shib logout page')
def uiuc_logout_page(context):
   '''
   Implementation of test step for a user to reach UIUC logout page
   '''
   context.browser.implicitly_wait(60)
   uiuc_logout_page = context.browser.find_element_by_id('page_title')
   context.browser.implicitly_wait(60)











































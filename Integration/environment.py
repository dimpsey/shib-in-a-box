# -*- coding: utf-8 -*-
'''
Environment settings for Behave execution
'''
import sys
from importlib import reload
reload(sys)
#sys.setdefaultencoding('utf-8')
import os.path
from selenium import webdriver
from elmr_web_links import LOGIN
from test_settings import TEST_BROWSER
#from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
#from selenium.webdriver.common.desired_capabilities import Desiredcapabilities
def before_scenario(context, scenario):
    '''
    Function executes before every Behave script; makes an
    API call to open the browser.
    
    '''
    capabilities = webdriver.DesiredCapabilities().FIREFOX
   # capabilities = webdriver.FIREFOX
   # caps = webdriver.Desiredcapabilities().FIREFOX
    capabilities["marionette"] = False
  #  browser = webdriver.Firefox(capabilities=caps)
   # binary = FirefoxBinary('/usr/bin/firefox',log_file=sys.stdout)
   # options = webdriver.firefox.options.Options()
   # options.headless = True
    driver = webdriver.Firefox(capabilities=capabilities, executable_path='/usr/local/bin/geckodriver') 
   # driver = webdriver.Firefox(firefox_options=options,
    #    executable_path="/usr/local/bin/geckodriver", capabilities=capabilities)
   # driver = webdriver.Firefox(firefox_options=options,
     #   firefox_binary=binary, capabilities=capabilities)
   # context.browser = driver
   # executable_path='/usr/local/bin/geckodriver')
   # context.browser = webdriver.Firefox()
 # if TEST_BROWSER == 'Chrome':
 #  context.browser = webdriver.Chrome()
 # elif TEST_BROWSER == 'Firefox':
 #  context.browser = webdriver.Firefox()
 #  context.browser.maximize_window()
 #  context.browser.delete_all_cookies()
 #  context.browser.get(LOGIN)
                            
def after_scenario(context, scenario):
 '''
 Function executes after every Behave script; makes an
 API call to close the browser.
'''
 context.browser.quit()

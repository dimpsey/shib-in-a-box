'''
Module for wrapper functions for common Selenium API Calls
  
 '''
import selenium
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as WW
from selenium.webdriver.common.by import By
    
def find_field_name_enter_values(context, field_name, input_val, send_tab=False):
   '''
   Helper method for finding a form element by name and entering an input value
   '''
   context.input_field = context.browser.find_element_by_name(field_name)
   context.input_field.clear()
   context.input_field.send_keys(input_val)
   if send_tab:
       context.input_field.send_keys(selenium.webdriver.common.keys.Keys.TAB)

def submit_form_page(context, field_id):
   '''
   Helper method for finding a submit button by id and clicking it
   '''
   context.input_field = context.browser.find_element_by_id(field_id)
   context.input_field.click()
    
def find_elem_xpath_text(context, field_xpath):
   '''
   Helper method for finding the text of an element via the xpath
   '''
   return context.browser.find_element_by_xpath(field_xpath).text

def find_elem_id_text(context, field_id):
   '''
   Helper method for finding the text of an element via id
   '''
   return context.browser.find_element_by_id(field_id).text

def find_elem_xpath_click(context, field_xpath):
   '''
   Helper method for finding an element via xpath and clicking it
   '''
   context.click_field = context.browser.find_element_by_xpath(field_xpath)
   context.click_field.click()
    
def find_elem_id_click(context, field_id):
   '''
   Helper method for finding an element via id and clicking it
   '''
   context.click_field = context.browser.find_element_by_id(field_id)
   context.click_field.click()
    
def find_field_id_enter_value(context, field_id, input_val):
   '''
   Helper method for finding a form element by id and entering a value into the field
   '''
   context.input_field = context.browser.find_element_by_id(field_id)
   context.input_field.clear()
   context.input_field.send_keys(input_val)
    
def find_field_class_name(context, class_name):
   '''
   Helper method for finding a form element by its classname
   '''
   return context.browser.find_element_by_class_name(class_name)

def find_css_value_from_elem_id(context, elem_id, prop_name):
   '''
   Helper method for getting the value of a css property of an element whose id is provided
   '''
   return context.browser.find_element_by_id(elem_id).value_of_css_property(prop_name)

def checkbox_select_state(context, elem_id):
   '''
   Helper method for returning the state of a given checkbox(selected or not)
   '''
   return context.browser.find_element_by_id(elem_id).is_selected()

def find_elem_by_id(context, elem_id):
   '''
   Helper method for returning an element by its id
   '''
   return context.browser.find_element_by_id(elem_id)

def find_field_curr_value(context, elem_id):
   '''
   Helper method for returning the current value of an input field
   '''
   return context.browser.find_element_by_id(elem_id).get_attribute("value")

def find_clickable_link_text(context, link_text):
   '''
   Helper method for finding a link element by the text associated with it
   '''
   return context.browser.find_element_by_link_text(link_text)

def wait_for_element(context, wait_time):
   '''
   Helper method to add wait time until the element is visible
   '''
   context.browser.implicitly_wait(wait_time)

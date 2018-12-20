"""
This environment file serves as the basis for our Behave runs when
testing our Terraform modules.
.../as-aws-module/test/features/environment.py
"""
import os
import pprint
import subprocess
import sys
import time

from configparser import (
    ConfigParser,
    NoSectionError
)

from sdg.test.behave import (
    core
)

MODULES = [
]

DIR = os.path.abspath(os.path.dirname(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(DIR, "../../../"))
CONF_DIR = os.path.normpath(os.path.join(DIR, "../../config"))

core.SET_config(path=os.path.join(CONF_DIR, "core.conf")) #Override default core conf values.

CONFIG = ConfigParser()
CONFIG.optionxform = str
CONFIG.read(os.path.join(DIR, 'config.ini'))

DEBUG = False
DISABLE_DOCKER_UP = False
DISABLE_DOCKER_DOWN = False
    
def before_all(context):
    """Set required module variables."""
    global DEBUG, DISABLE_DOCKER_UP, DISABLE_DOCKER_DOWN

    DEBUG = context.config.userdata.getbool("DEBUG")
    DISABLE_DOCKER_UP = context.config.userdata.getbool("DISABLE_DOCKER_UP")
    DISABLE_DOCKER_DOWN = context.config.userdata.getbool("DISABLE_DOCKER_DOWN")
    
    core.INIT_ENV(context, MODULES)
    core.SET_REQ_VARS(context,
        project_root=PROJECT_DIR,
        test_root=DIR)

    if not DISABLE_DOCKER_UP and not disable_docker():    
        # TODO: Figure out way to see if aws is availble
        p = subprocess.Popen(['docker-compose', 'up', '-d'], 
            cwd=PROJECT_DIR, env=get_environment())
        p.wait()
        time.sleep(5)


def after_all(context):
    """Clean up environment"""
    global DISABLE_DOCKER_DOWN

    if not DISABLE_DOCKER_DOWN and not disable_docker():    
        p = subprocess.Popen(['docker-compose', 'down'], cwd=PROJECT_DIR)
        p.wait()


def after_step(context, step):
    ''''''
    global DISABLE_DOCKER_DOWN

    if DEBUG and step.status == "failed":
       DISABLE_DOCKER_DOWN = True
 

def get_environment():
    ''' Get environement to use '''
    env = os.environ.copy()

    return env.update(CONFIG['Environment'])

	
def disable_docker():
    '''''' 
    try:
        return CONFIG.getboolean('Test Config', 'DISABLE_DOCKER_COMPOSE') 
    except NoSectionError:
        return False

def main():
    pass

if __name__ == '__main__':
  main()
    

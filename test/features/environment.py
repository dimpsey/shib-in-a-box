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

from configparser import ConfigParser
from sdg.test.behave import (
    core
)

MODULES = [
]

DIR = os.path.abspath(os.path.dirname(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(DIR, "../../../"))
CONF_DIR = os.path.normpath(os.path.join(DIR, "../../config"))

core.SET_config(path=os.path.join(CONF_DIR, "core.conf")) #Override default core conf values.

def before_all(context):
    """Set required module variables."""
    core.INIT_ENV(context, MODULES)
    core.SET_REQ_VARS(context,
        project_root=PROJECT_DIR,
        test_root=DIR)

    return    
    # TODO: Figure out way to see if aws is availble
    p = subprocess.Popen(['docker-compose', 'up', '-d'], 
        cwd=PROJECT_DIR, env=get_environment())
    p.wait()
    time.sleep(5)


def after_all(context):
    """Clean up environment"""
    return
    p = subprocess.Popen(['docker-compose', 'down'], cwd=PROJECT_DIR)
    p.wait()


def get_environment():
    ''' Get environement to use '''

    env = os.environ.copy()

    config = ConfigParser()
    config.optionxform = str
    config.read(os.path.join(DIR, 'config.ini'))

    return env.update(config['Environment'])
 

def main():
    pass

if __name__ == '__main__':
  main()
    

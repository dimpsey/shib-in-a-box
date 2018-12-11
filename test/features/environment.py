"""
This environment file serves as the basis for our Behave runs when
testing our Terraform modules.
.../as-aws-module/test/features/environment.py
"""
import os
import sys
from sdg.test.behave import (
    core
)

MODULES = [
]

DIR = os.path.abspath(os.path.dirname(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(DIR, "../../"))
CONF_DIR = os.path.normpath(os.path.join(DIR, "../config"))

core.SET_config(path=os.path.join(CONF_DIR, "core.conf")) #Override default core conf values.

def before_all(context):
    """Set required module variables."""
    core.INIT_ENV(context, MODULES)
    core.SET_REQ_VARS(context,
        project_root=PROJECT_DIR,
        test_root=DIR)


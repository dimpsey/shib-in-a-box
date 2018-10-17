import logging
import os
import configparser 

# ===================
# Setup Logging
# ===================
_LOGGER = logging.getLogger("test")
_LOGGER.setLevel(logging.DEBUG)
_LOGGER.addHandler(logging.StreamHandler())

_SETTINGS_LOCATION = os.path.dirname(os.path.abspath(__file__))
TEST_CONF_FILE = os.path.join(_SETTINGS_LOCATION, 'test.conf')
_LOGGER.info('Test config file: %s', TEST_CONF_FILE)

config = configparser.ConfigParser()
config.read(TEST_CONF_FILE)

TEST_BROWSER = config.get('browser', 'name')

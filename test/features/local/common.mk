.PHONY: all test down clean

TOP_LEVEL := environment.py steps docker-compose.yml .env nginx.conf
COMMON := local.feature shibd.feature $(TOP_LEVEL)

-ELMR := elmr_config_off.feature
-ENV := environment_page_off.feature

ifdef MOCK_SHIB # shib_off
    +ELMR := elmr_config_on_shib_off.feature
    +ENV  := elmrsample_shib_off_env_on.feature environment_page_on_shib_off.feature
    -ENV  := elmrsample_shib_off_env_off.feature $(-ENV)
else # shib_on
    +ELMR := elmr_config_on_shib_on.feature
    +ENV  := environment_page_on_shib_on.feature
    COMMON := elmrsample_shib_on.feature $(COMMON)
endif

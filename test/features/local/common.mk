.PHONY: all test down clean

# +ELMR means http://hostname/auth/elmr/config is expected to be accessiable
# -ELMR means http://hostname/auth/elmr/config is expected to be inaccessiable
# +DBG means http://hostname/auth/cgi-bin/* is expected to be accessiable
# -DBG means http://hostname/auth/cgi-bin/* is expected to be inaccessiable

TOP_LEVEL := environment.py steps docker-compose.yml .env nginx.conf
COMMON := local.feature shibd.feature $(TOP_LEVEL)

-ELMR := elmr_config_off.feature
-DBG := environment_page_off.feature

ifdef MOCK_SHIB # shib_off
    +ELMR := elmr_config_on_shib_off.feature
    +DBG  := elmrsample_shib_off_dbg_on.feature environment_page_on_shib_off.feature
    -DBG  := elmrsample_shib_off_dbg_off.feature $(-DBG)
else # shib_on
    +ELMR := elmr_config_on_shib_on.feature
    +DBG  := environment_page_on_shib_on.feature
    COMMON := elmrsample_shib_on.feature $(COMMON)
endif

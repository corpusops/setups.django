# -*- coding: utf-8 -*-
from .base import *

##### SECURITY #####

SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'
CSRF_COOKIE_HTTPONLY = True

# Suppose we are using HTTPS
# CSRF_COOKIE_SECURE = True
# SESSION_COOKIE_SECURE = True
# SECURE_SSL_REDIRECT = True # Just in case, should be done by webserver instead

# Import twice prod env settings to have the last word.
MODNAME = os.path.basename(__file__).split('.py')[0]
for fic in ['local', 'local_{0}'.format(MODNAME)]:
    load_env_settings(os.path.join(SETTINGS_DIR, fic), from_=__file__)
# -*- coding: utf-8 -*-
import logging

from django.utils import six

from .base import *

SECRET_KEY = 'dev-dev-dev-dev-dev-dev-dev'

ALLOWED_HOSTS = []
DEBUG = True

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

INSTALLED_APPS += (
    'debug_toolbar',
    'django_extensions',
)

INTERNAL_IPS = ('127.0.0.1',)  # Used by app debug_toolbar

# Force every loggers to use console handler only. Note that using 'root'
# logger is not enough if children don't propage.
for logger in six.itervalues(LOGGING['loggers']):
    logger['handlers'] = ['console']
# Log every level.
LOGGING['handlers']['console']['level'] = logging.NOTSET

# Import twice local env settings to have the last word.
MODNAME = os.path.basename(__file__).split('.py')[0]
for fic in ['local', 'local_{0}'.format(MODNAME)]:
    load_env_settings(os.path.join(SETTINGS_DIR, fic), from_=__file__)

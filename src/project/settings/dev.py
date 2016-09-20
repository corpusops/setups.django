# -*- coding: utf-8 -*-
import logging

from django.utils import six

from .base import *

try:
    from .local.base_pre import *
except ImportError:
    pass

try:
    from .local.dev_pre import *
except ImportError:
    pass


SECRET_KEY = 'dev-dev-dev-dev-dev-dev-dev'

ALLOWED_HOSTS = []
DEBUG = True

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

INSTALLED_APPS += (
    'debug_toolbar',
    'django_extensions',
)

INTERNAL_IPS = ('127.0.0.1',)  # Used by app debug_toolbar

# Add the Python core NullHandler to be available when needed
LOGGING['handlers']['null'] = {
    'level': logging.NOTSET,
    'class': 'logging.NullHandler',
}

# Force every loggers to use console handler only. Note that using 'root'
# logger is not enough if children don't propage.
for logger in six.itervalues(LOGGING['loggers']):
    logger['handlers'] = ['console']
# Log every level.
LOGGING['handlers']['console']['level'] = logging.NOTSET


try:
    from .local.base_post import *
except ImportError:
    pass

try:
    from .local.dev_post import *
except ImportError:
    pass

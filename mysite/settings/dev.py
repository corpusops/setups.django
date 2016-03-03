# -*- coding: utf-8 -*-
import logging

from django.utils import six

from .base import *

try:
    from .local.pre.base import *
except ImportError:
    pass

try:
    from .local.pre.dev import *
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

# Force every loggers to use console handler only. Note that using 'root'
# logger is not enough if children don't propage.
for logger in six.itervalues(LOGGING['loggers']):
    logger['handlers'] = ['console']
# Log every level.
LOGGING['handlers']['console']['level'] = logging.NOTSET


try:
    from .local.post.base import *
except ImportError:
    pass

try:
    from .local.post.dev import *
except ImportError:
    pass

# -*- coding: utf-8 -*-
import tempfile

from django.utils import six

from .base import *

SECRET_KEY = 'spam-spam-spam-spam'

MEDIA_ROOT = tempfile.gettempdir()

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Boost perf a little
PASSWORD_HASHERS = (
    'django.contrib.auth.hashers.MD5PasswordHasher',
)

# Force every loggers to use null handler only. Note that using 'root'
# logger is not enough if children don't propage.
for logger in six.itervalues(LOGGING['loggers']):
    logger['handlers'] = ['null']


# Import twice test env settings to have the last word.
MODNAME = os.path.basename(__file__).split('.py')[0]
for fic in ['local', 'local_{0}'.format(MODNAME)]:
    load_env_settings(os.path.join(SETTINGS_DIR, fic), from_=__file__)

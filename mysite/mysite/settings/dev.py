#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

from .base import *

MODNAME = os.path.basename(__file__).split('.py')[0]
DEBUG = TEMPLATE_DEBUG = True
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'dev.sqlite3'),
    }
}

for fic in ['local', 'local_{0}'.format(MODNAME)]:
    load_env_settings(os.path.join(SETTINGS_DIR, fic), from_=__file__)
# vim:set et sts=4 ts=4 tw=80:

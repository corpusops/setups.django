"""
Django settings for mysite project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import copy
import os

from django.utils.log import DEFAULT_LOGGING

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SETTINGS_DIR = os.path.dirname(__file__)


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.security.SecurityMiddleware',
)

ROOT_URLCONF = 'mysite.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'django.template.context_processors.i18n',
            ],
        },
    },
]

WSGI_APPLICATION = 'mysite.wsgi.application'

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/
LOCALE_PATHS = (
    os.path.join(BASE_DIR, 'locales'),
)
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'
USE_I18N = True
USE_L10N = True
USE_TZ = True

FORMAT_MODULE_PATH = [
    'mysite.formats',
]

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

STATIC_URL = '/static/'
STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'static'),
)

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Just to be easily override by children conf files.
LOGGING = copy.deepcopy(DEFAULT_LOGGING)

# First local settings import so they can be re-used by environment config.

LOADED_ENVS = {}
MODNAME = os.path.basename(__file__).split('.py')[0]


def load_env_settings(envfile, from_=__file__):
    modfic = os.path.abspath(envfile)
    if not modfic.endswith('.py'):
        modfic += '.py'
    if not LOADED_ENVS.get((modfic, from_), False):
        try:
            LOADED_ENVS[(modfic, from_)] = True
            try:
                execfile(modfic)
            except NameError:
                # py3
                with open(modfic) as f:
                    code = compile(f.read(), os.path.basename(modfic), 'exec')
                    exec(code)
        except ImportError:
            pass
        except IOError:
            pass
        except Exception:
            LOADED_ENVS.pop((modfic, from_), None)
            raise


load_env_settings(os.path.join(SETTINGS_DIR, 'local'), from_=__file__)

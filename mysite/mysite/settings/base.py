"""
Django settings for mysite project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
import socket
BASE_SETTINGS = os.path.abspath(__file__)
SETTINGS_DIR = os.path.dirname(__file__)
BASE_DIR = os.path.dirname(os.path.dirname(__file__))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'nnnl-r$97aj3z$0e$%arv7y@uz0%yhz&0%5tlt6)%6in%+kw)n'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

TEMPLATE_DEBUG = False

ALLOWED_HOSTS = ['localhost', socket.getfqdn()]


# Application definition

INSTALLED_APPS = (
    'myapp',
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
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'mysite.urls'

WSGI_APPLICATION = 'mysite.wsgi.application'


# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
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

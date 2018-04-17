# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.conf import settings
from django.conf.urls import include, url
from django.contrib import admin
from django.contrib.auth.views import login, logout_then_login
try:
    from django.urls import path
except ImportError:
    pass

try:
    from django.views.i18n import javascript_catalog
    jstrans = url(r'^jsi18n/$', javascript_catalog,
                  name='javascript-catalog')
except ImportError:
    from django.views.i18n import JavaScriptCatalog
    jstrans = path("jsi18n/",
                   JavaScriptCatalog.as_view(packages=['socialhome']),
                   name="javascript-catalog")

from common.forms import CommonAuthenticationForm
from common.views import HomeView

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    jstrans,

    url(r'^login/$', login, name='login', kwargs={
        'authentication_form': CommonAuthenticationForm,
    }),
    url(r'^logout/$', logout_then_login, name='logout'),

    url(r'^$', HomeView.as_view(), name='home'),
]

if 'apptest' in settings.INSTALLED_APPS:  # pragma: nobranch
    urlpatterns += [
        url(r'^test', include('apptest.urls')),
    ]

if settings.DEBUG and 'debug_toolbar' in settings.INSTALLED_APPS:
    import debug_toolbar

    urlpatterns += [
        url(r'^__debug__/', include(debug_toolbar.urls)),
    ]

admin.site.site_header = 'project'

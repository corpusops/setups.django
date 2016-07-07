# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.conf import settings
from django.conf.urls import include, url
from django.contrib import admin
from django.contrib.auth.views import login, logout_then_login
from django.views.i18n import javascript_catalog

from common.forms import CommonAuthenticationForm
from common.views import HomeView

urlpatterns = [
    url(r'^admin/', include(admin.site.urls)),
    url(r'^jsi18n/$', javascript_catalog, name='javascript-catalog'),

    url(r'^login/$', login, name='login', kwargs={
        'authentication_form': CommonAuthenticationForm,
    }),
    url(r'^logout/$', logout_then_login, name='logout'),

    url(r'^$', HomeView.as_view(), name='home'),
]

if 'apptest' in settings.INSTALLED_APPS:  # pragma: nobranch
    urlpatterns += [
        url(r'^test', include('apptest.urls', namespace='apptest')),
    ]

admin.site.site_header = 'project'

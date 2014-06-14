#!/usr/bin/env python
# -*- coding: utf-8 -*-
__docformat__ = 'restructuredtext en'
from django.conf.urls import url
from myapp import views

urlpatterns = [
    url(r'^$', views.index, name='index')
]

# vim:set et sts=4 ts=4 tw=80:

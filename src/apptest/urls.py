from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.helloworld, name='helloworld'),
    url(r'^template/$', views.template, name='template'),
]

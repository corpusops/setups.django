from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.utils.translation import ugettext as _


def helloworld(request):
    return HttpResponse(_("Salut"))


def template(request):
    return render_to_response('apptest/test.html')

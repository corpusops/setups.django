# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib.auth.forms import AuthenticationForm
from django.utils.translation import ugettext as _

from crispy_forms.helper import FormHelper
from crispy_forms.layout import Submit


class CommonAuthenticationForm(AuthenticationForm):

    def __init__(self, request=None, *args, **kwargs):
        super(CommonAuthenticationForm, self).__init__(
            request, *args, **kwargs
        )
        self.helper = FormHelper(self)
        self.helper.form_id = 'login-form'
        self.helper.add_input(Submit('submit', _('Se connecter')))

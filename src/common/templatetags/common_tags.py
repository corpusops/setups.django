# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django import template

register = template.Library()


@register.inclusion_tag('messages.html')
def display_messages(messages):

    classes = {
        'success': 'success',
        'info': 'info',
        'warning': 'warning',
        'error': 'danger',
        'debug': 'info',
    }
    for message in messages:
        message.type = classes[message.tags] if message.tags and message.tags in classes else None

    return {
        'messages': messages
    }

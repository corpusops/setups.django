# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.test import TestCase

from ...templatetags.common_tags import display_messages

try:
    from unittest import mock  # pragma: no cover
except ImportError:
    import mock


class TemplateTagsTestCase(TestCase):

    def test_display_messages(self):

        msgs = [
            mock.Mock(tags='success'),
            mock.Mock(tags='error'),
            mock.Mock(tags='debug'),
            mock.Mock(tags=None),
        ]
        context = display_messages(msgs)

        i = 0
        for msg in context['messages']:
            if i == 0:
                self.assertEqual(msg.type, 'success')
            elif i == 1:
                self.assertEqual(msg.type, 'danger')
            elif i == 2:
                self.assertEqual(msg.type, 'info')
            else:
                self.assertIsNone(msg.type)
            i += 1

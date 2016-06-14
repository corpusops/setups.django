# -*- coding: utf-8 -*-
import logging
import unittest

from django.conf import settings
from django.core.urlresolvers import reverse
from django.test import TestCase, override_settings
from django.utils.formats import get_format


class ConfigTestCase(TestCase):

    def test_custom_format(self):
        self.assertEqual(
            get_format('CUSTOM_TESTING_FORMAT'),
            'foo',
        )

    def test_default_language(self):
        """
        Most of the time, this is this language we want.
        """
        self.assertEqual(settings.LANGUAGE_CODE, 'fr-fr')

    def test_default_timezone(self):
        """
        Most of the time, this is the timezone we want, not UTC.
        """
        self.assertEqual(settings.TIME_ZONE, 'Europe/Paris')

    def test_hook_pre(self):
        logger = logging.getLogger('apptest')
        self.assertEqual(logger.handlers[0].name, 'console')

    def test_hook_post(self):
        self.assertIn('apptest', settings.INSTALLED_APPS)


@unittest.skipIf(
    'apptest' not in settings.INSTALLED_APPS,
    'You MUST copy/paste <project>.settings.local_test.py.dist and add '
    'apptest in INSTALLED_APPS'
)
class AppTestTestCase(TestCase):

    @classmethod
    def setUpTestData(cls):
        cls.url_hello = reverse('apptest:helloworld')
        cls.url_tpl = reverse('apptest:template')

    @override_settings(LANGUAGE_CODE='fr-fr')
    def test_hello_world_translation_default_fr(self):
        """
        Most of the time, we code app in English and then translate it in
        French. But in real life, there is no use at all for English. Worst, we
        make wrong translation, just like me :-). It is better to write it in
        our favorite language and then translate it.

        So we make sure that without translation, we use raw string which are
        in French, my native language and probably yours too!
        """
        response = self.client.get(self.url_hello)
        self.assertContains(response, 'Salut')

    @override_settings(LANGUAGE_CODE='en-us')
    def test_hello_world_translation_en(self):
        """
        On contrary, be sure that English translation is used.
        """
        response = self.client.get(self.url_hello)
        self.assertContains(response, 'Hello')

    def test_template_app_parent(self):
        """
        Implicitly check that template dir is enable and check that english
        translation works too.
        """
        response = self.client.get(self.url_tpl)
        self.assertContains(response, '<body>', html=False)

    @override_settings(LANGUAGE_CODE='en-us')
    def test_template_app_translation(self):
        """
        Implicitly check that template dir is enable and check that english
        translation works too.
        """
        response = self.client.get(self.url_tpl)
        self.assertContains(response, 'AppTest template is used!')

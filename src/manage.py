#!/usr/bin/env python
import os
import sys

# Set the default settings
mod_settings = 'project.settings.dev'
if len(sys.argv) > 1 and sys.argv[1] == 'test':
    mod_settings = 'project.settings.test'


if __name__ == "__main__":

    os.environ.setdefault("DJANGO_SETTINGS_MODULE", mod_settings)

    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)

#!/usr/bin/env python
import os
import sys

THISFILE = os.path.realpath(__file__)
BASE_DIR = os.path.dirname(THISFILE)
SRC_DIR = os.path.join(BASE_DIR, 'src')
try:
    os.stat(SRC_DIR)
except OSError:
    SRC_DIR = BASE_DIR
    BASE_DIR = os.path.dirname(BASE_DIR)


SKIPPED_MODULES = ['base', '__init__']
SPECIAL_COMMANDS = ['test']


def has_module(*a):
    path = os.path.join(*a)
    return os.path.isdir(path) or os.path.exists(path + '.py')


def search_modules(src_dir):
    settings_modules = {}
    for module in os.listdir(src_dir):
        module_path = os.path.join(src_dir, module)
        has_settings = has_module(module_path, 'settings')
        is_project = os.path.isdir(module_path) and has_settings and (
            has_module(module_path, 'wsgi') or
            has_module(module_path, 'urls') or
            has_module(module_path, 'templates') or
            has_module(module_path, 'static'))
        if not is_project:
            continue
        settings_module_path = os.path.join(module_path, 'settings')
        settings_modules['default'] = module + '.settings'
        if os.path.isdir(settings_module_path):
            settings_modules.update(dict([
                a
                for a in [
                    (os.path.splitext(i)[0],
                     module + '.settings.' + os.path.splitext(i)[0])
                    for i in os.listdir(settings_module_path)
                    if (
                        (
                            i.endswith('.py') and
                            os.path.isfile(
                                os.path.join(settings_module_path, i))
                        ) or os.path.exists(
                            os.path.join(
                                settings_module_path, i, '__init__.py'))
                    )]
                if a[0] not in SKIPPED_MODULES
            ]))
            return settings_modules


def get_module_from_cli(settings_modules):
    settings_module = None
    for cliarg in sys.argv:
        if cliarg in settings_modules and cliarg in SPECIAL_COMMANDS:
            settings_module = settings_modules[cliarg]
            break
    return settings_module


def get_default_module(settings_modules):
    try:
        settings_module = settings_modules['dev']
    except KeyError:
        try:
            if settings_modules:
                settings_module = [
                    a for a in settings_modules
                    if a not in ['default']][0]
        except (KeyError, IndexError):
            settings_module = settings_modules.get('default', None)
    return settings_module


def main():
    settings_module = os.environ.get("DJANGO_SETTINGS_MODULE", None)
    if settings_module is None:
        settings_modules = search_modules(SRC_DIR)
        settings_module = get_module_from_cli(settings_modules)
    if settings_module is None:
        settings_module = get_default_module(settings_modules)
    if settings_modules is None:
        raise ValueError(
            'Can\'t find any django settings module'
            ' in {0}'.format(SRC_DIR))
    os.environ['DJANGO_SETTINGS_MODULE'] = settings_module
    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()

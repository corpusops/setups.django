# -*- coding: utf-8 -*-
from importlib import import_module


def load_env_settings(env, hook='post'):
    """
    For a given hook (pre or post), import default and (then) specific
    environment settings override.
    """
    patterns = ['.local.{hook}.base', '.local.{hook}.{env}']

    for pattern in patterns:
        name = pattern.format(hook=hook, env=env)

        try:
            import_module(name, __name__)
        except ImportError:
            pass
        else:
            globals().update(locals())

#!/usr/bin/env python
import os
import sys


f = __file__
if os.path.islink(f):
    f = os.readlink(__file__)
f = os.path.abspath(f)
d = os.path.dirname(f)
s = os.path.join(d, 'src')
if not os.path.exists(s):
    s = d


envs = ['prod', 'test', 'dev']
if len(sys.argv) > 1 and sys.argv[1] == 'test':
    envs = ['test']


mod_settings = 'settings'
for i in os.listdir(s):
    ip = os.path.join(s, i)
    ips = os.path.join(ip, 'settings')
    if os.path.exists(ips + '.py'):
        mod_settings = i + '.settings'
    else:
        for j in envs:
            psettings = i + '.settings.' + j
            if os.path.exists(os.path.join(ips, j + '.py')):
                mod_settings = psettings


if __name__ == "__main__":

    os.environ.setdefault("DJANGO_SETTINGS_MODULE", mod_settings)

    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)

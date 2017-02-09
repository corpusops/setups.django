{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}
{% set use_vt = data.get('use_vt', True) %}

{{cfg.name}}-venv:
  virtualenv.managed:
    - name: {{data.py_root}}
    - pip_download_cache: {{cfg.data_root}}/cache
    - user: {{cfg.user}}
    {% if data.get('orig_py', None) %}- python: {{data.get('orig_py', None)}}{% endif %}
    - use_vt: {{use_vt}}
  cmd.run:
    - name: |
            . {{data.py_root}}/bin/activate;
            if pip --help 2>&1| grep -q -- --download-cache;then
              cacheopt="--download-cache"
            else
              cacheopt="--cache-dir"
            fi
            if [ "x$(easy_install --version|awk '{print $2}')" = "x12.2" ];then
              pip install --upgrade setuptools ${cacheopt} "{{cfg.data_root}}/cache"
            fi
            if [ "x$(pip --version|awk '{print $2}')" = "x1.5.6" ];then
              pip install --upgrade pip ${cacheopt} "{{cfg.data_root}}/cache"
            fi
            # to install the pip diversion, chicken & egg
            if grep -iq pillow "{{data.requirements}}";then
              pip install --upgrade $(egrep -i "^pillow" "{{data.requirements}}") ${cacheopt} "{{cfg.data_root}}/cache"
            fi
            pip install -r "{{data.requirements}}" ${cacheopt} "{{cfg.data_root}}/cache"

    - env:
       - CFLAGS: "-I/usr/include/gdal"
    - cwd: {{data.pip_root}}
    - use_vt: {{use_vt}}
    - download_cache: {{cfg.data_root}}/cache
    - user: {{cfg.user}}
    - require:
      - virtualenv: {{cfg.name}}-venv
  file.symlink:
    - name: {{cfg.project_root}}/develop_eggs
    - target: {{data.py_root}}/src
    - makedirs: true
    - onlyif: test -e "{{data.py_root}}/src"
    - require:
      - cmd: {{cfg.name}}-venv

{# install the django app in develop if we have a setup.py #}
{{cfg.name}}-develop:
  cmd.run:
    - name: |
            . {{data.py_root}}/bin/activate;
            if test -e setup.py;then
              pip install --no-deps -e .
            elif test -e ../setup.py;then
              cd .. && pip install --no-deps -e .
            else
              exit 1
            fi
    - env:
       - CFLAGS: "-I/usr/include/gdal"
    - cwd: {{data.app_root}}
    - onlyif: test -e setup.py || test -e ../setup.py
    - use_vt: {{use_vt}}
    - download_cache: {{cfg.data_root}}/cache
    - user: {{cfg.user}}
    - require:
      - file: {{cfg.name}}-venv
{{cfg.name}}-venv-cleanup:
  file.absent:
    - name: {{cfg.project_root}}/develop_eggs
    - onlyif: test ! -e "{{data.py_root}}/src"
    - require:
      - file: {{cfg.name}}-venv

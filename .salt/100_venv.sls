{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}

{{cfg.name}}-venv:
  virtualenv.managed:
    - name: {{data.py_root}}
    - download_cache: {{cfg.data_root}}/cache
    - user: {{cfg.user}}
    - runas: {{cfg.user}}
    - use_vt: true
  cmd.run:
    - name: |
            . {{data.py_root}}/bin/activate;
            pip install -r "{{data.requirements}}" --download-cache "{{cfg.data_root}}/cache"
    - env:
       - CFLAGS: "-I/usr/include/gdal"
    - cwd: {{data.app_root}}
    - use_vt: true
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

{{cfg.name}}-venv-cleanup:
  file.absent:
    - name: {{cfg.project_root}}/develop_eggs
    - onlyif: test ! -e "{{data.py_root}}/src"
    - require:
      - file: {{cfg.name}}-venv

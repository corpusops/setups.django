=============================
Install only the django app
=============================

Quick'n'dirty install
-----------------------
* clone this repository,
  create a virtual env and switch to it,
  install requirements for local development,
  register the project with python

    .. code::

        git clone git@github.com:makinacorpus/corpus-django.git
        virtualenv --no-site-packages venv
        . venv/bin/activate
        pip install -r requirements/dev.txt
        pip install -e --no-deps .

* duplicate dist files to override settings you would like by doing :

    .. code::

        cp src/settings/local.py.dist src/settings/local.py
        $EDITOR src/settings/local.py

* Run the app

    .. code::

        cd src
        ./manage.py runserver

*  Check requirements versions for every fixed packages. You can achieve it by
   doing :

      .. code::

         pip list --outdated

Beginning a project from corpus-django
--------------------------------------------------

* clone corpus-django & remove its history

    .. code::

        git clone git@github.com:makinacorpus/corpus-django.git myproject
        cd myproject
        rm -rf .git

*  don't forgot to remove fake testing app :

   .. code::

      rm -Rf src/apptest

   and remove it from ``INSTALLED_APP`` in ``src/project/settings/base.py``.
   You will also have some stuff to remove or review, like :

      * dummy global site CSS in src/project/static/project/css/styles.css
      * cleanup global templates src/project/templates/\*.html
      * cleanup urlconf root at src/project/urls.py
      * cleanup dummy locales translations at src/project/locales
      * cleanup dummy locale formats at src/project/formats

* If you want to rename the **project** module (heavily discouraged), you ll
  have to adapt:

    * ./tox.ini
    * ./src/manage.py
    * ./project/urls.py
    * ./project/wsgi.py

* Commit everything

    .. code::

        git init
        git add .
        git commit -am init
        git remote add origin <https://gitlab/foo/bar.git>
        git push -u origin HEAD:master


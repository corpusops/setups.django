.. image:: https://travis-ci.org/makinacorpus/corpus-django.svg
    :target: https://travis-ci.org/makinacorpus/corpus-django

.. image:: https://coveralls.io/repos/makinacorpus/corpus-django/badge.svg?branch=master&service=github
  :target: https://coveralls.io/github/makinacorpus/corpus-django?branch=master

.. image:: https://requires.io/github/makinacorpus/corpus-django/requirements.svg?branch=master
   :target: https://requires.io/github/makinacorpus/corpus-django/requirements/?branch=master
   :alt: Requirements Status

===========
Get started
===========

To start a new project from this template,

* clone this repository, keep sources but remove repos :

    .. code::

        git clone git@github.com:makinacorpus/corpus-django.git
        cd corpus-django
        rm -Rf .git

* create a virtual env and switch to it

* install requirements for local development :

    .. code::

        pip install -r requirements/dev.txt

* duplicate dist files to override settings you would like by doing :

    .. code::

        cp src/settings/local.py.dist src/settings/local.py

*  don't forgot to remove fake testing app :

   .. code::

      rm -Rf <project>/apps/apptest

   and remove it from ``INSTALLED_APP`` in ``src/settings/base.py``.
   You will also have some stuff to remove or review, like :

      * dummy global site CSS in src/project/static/project/css/styles.css
      * cleanup global templates src/project/templates/*.html
      * cleanup urlconf root at src/project/urls.py
      * cleanup dummy locales translations at src/project/locales
      * cleanup dummy locale formats at src/project/formats

*  check requirements versions for every fixed packages. You can achieve it by
   doing :

      .. code::

         pip list --outdated


=====================================================================
Exemple of a generic django deployment with salt/makina-states
=====================================================================

.. contents::

USE/Install With makina-states
-------------------------------
- Iniatilise on the target platform the project if it is not already done::

    salt mc_project.init_project name=<foo>

- Keep under the hood both remotes (pillar & project).

- Clone the project pillar remote inside your project top directory

- Add/Relace your salt deployment code inside **.salt** inside your repository.

- Add the project remote

    - replace remotenickname with a sensible name (eg: prod)::
    - replace the_project_remote_given_in_init with the real url

    - Run the following commands::

        git remote add <remotenickname>  <the_project_remote_given_in_init>
        git fetch --all

- Each time you need to deploy from your computer, run::

    cd pillar
    git push [--force] <remotenickname> <yourlocalbranch(eg: master,prod,whatever)>:master
    cd ..
    git push [--force] <remotenickname> <yourlocalbranch(eg: master,prod,whatever)>:master

- Notes:

    - The distant branch is always *master**
    - If you force the push, the local working copy of the remote deployed site
      will be resetted to the TIP changeset your are pushing.

- If you want to install locally on the remote computer, or test it locally and
  do not want to run the full deployement procedure, when you are on a shell
  (connected via ssh on the remote computer or locally on your box), run::

      salt mc_project.deploy only=install,fixperms

- You can also run just specific step(s)::

      salt mc_project.deploy only=install,fixperms only_steps=000_whatever
      salt mc_project.deploy only=install,fixperms only_steps=000_whatever,001_else

- If you want to commit in prod and then push back from the remote computer, remember
  to push on the right branch, eg::

    git remote add github https://github.com/orga/repo.git
    git fetch --all
    git push github master:prod


============
Contributing
============

Please, runs tests to be sure everything goes fine... And of course,
write/update new ones! Hey, did you really think we do this for fun?! ;-)

Just do :

.. code::

   tox

.. warning::
   Sometimes, you may need to rebuild the test env because there is new python
   packages updated in requirements/test.txt. So think about doing :

   .. code::

      tox -r

To improve tests, there are written in the dummy app ``apptest``. You can used
it or do what you can :-)

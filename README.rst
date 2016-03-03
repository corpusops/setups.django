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

* replace all occurence of 'mysite' by our project namespace. First in files :

    .. code::

        grep -R 'mysite' -l * |xargs sed -i 's/mysite/<MY REAL PROJECT NAME>/g'

  Then in directories :

  .. code::

        mv mysite <PROJECT_NAME>

* install requirements for local development :

    .. code::

        pip install -r requirements/dev.txt

* duplicate dist files to override settings you would like. Any overrides are
  located in ``<project>/settings/local/`` and are available :

  * per environment : base/dev/prod/test. ``base`` is apply to all env.
  * per hooks : ``pre`` and ``post``

  Most of the time, you only care about post settings. But sometime, you may
  also want to set some settings first in order to be used next by *static*
  settings. In that way, you don't have to override completly settings (think
  about settings which are a concatenation of further settings).

  In the most simple scenario for development, you only have to do :

    .. code::

        cp mysite/settings/local/dev_post.py.dist mysite/settings/local/dev_post.py
        cp mysite/settings/local/test_post.py.dist mysite/settings/local/test_post.py

  and then override settings with your own.

*  don't forgot to remove fake testing app :

   .. code::

      rm -Rf <project>/apps/apptest

   and remove it from ``INSTALLED_APP``. You will also have some stuff to remove
   or review, like :

      * dummy global site CSS in <project>/static/<project>/css/styles.css
      * cleanup global templates <project>/templates/base.html
      * cleanup urlconf root at project.urls
      * cleanup dummy locales translations
      * cleanup dummy locale formats

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

To do so, first copy config dist files for *test* environment :

.. code::

   cp mysite/settings/local/test_pre.py.dist mysite/settings/local/test_pre.py
   cp mysite/settings/local/test_post.py.dist mysite/settings/local/test_post.py

Then, just do :

.. code::

   tox

.. warning::
   Sometimes, you may need to rebuild the test env because there is new python
   packages updated in requirements/test.txt. So think about doing :

   .. code::

      tox -r

To improve tests, there are written in the dummy app
``mysite.apps.apptest.tests``. You can used it or do what you can :-)

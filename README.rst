.. image:: https://travis-ci.org/makinacorpus/corpus-django.svg
    :target: https://travis-ci.org/makinacorpus/corpus-django

.. image:: https://coveralls.io/repos/makinacorpus/corpus-django/badge.svg?branch=master&service=github
  :target: https://coveralls.io/github/makinacorpus/corpus-django?branch=master

.. image:: https://requires.io/github/makinacorpus/corpus-django/requirements.svg?branch=master
   :target: https://requires.io/github/makinacorpus/corpus-django/requirements/?branch=master
   :alt: Requirements Status

.. contents::

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

* Register the project with python

    .. code::

        pip install -e --no-deps .

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

Install makina-states
----------------------
- Install makina-states if not already (you may better use a vm or a container
  or a docker for this, to avoid cluttering your main host, if you don't know
  what you are doing)

    .. code::

        cd /srv
        git clone https://github.com/makinacorpus/makina-states.git
        cd makina-states
        sudo ./_scripts/boot-salt.sh

- This will install a minimal & working makina-states environment, you can manage
  a lot more with it, but it is not the scope of this documentation.

Initiliase the project structure, configuration & update the code
-----------------------------------------------------------------
- Iniatilise on the target platform the project if it is not already done:

    .. code::

        $ms/bin/salt-call mc_project.init_project name=<foo> remote_less=True

- Add your project code & configuration (pillar) in the relevant directories


    - Clone your project:

        .. code::

            cd /srv/projects/<foo>/project
            git remote add <remotenickname> <the_git_url_of_your_repository>
            git fetch --all
            git reset --hard <remotenickname>/<branch_to_work_on>

    - Review your project defaults, to override the defaults that needs to be in the
      pillar to adapt to your local env.

        .. code::

            cd /srv/projects/<foo>/pillar
            cat ../project/.salt/PILLAR.sample
            $EDITOR init.sls
            git commit -am up

- At a later time to push back your code back to your repository, use

            cd /srv/projects/<foo>/project
            git commit -am "s feature"
            git push <remotenickname> HEAD:<branch_to_work_on>

- At a later time to update your local & **CLEAN** source tree from the central git
  repository, use

    .. code::

            cd /srv/projects/<foo>/project
            git fetch <remotenickname>
            # one of the following
            git pull <remotenickname> <branch_to_work_on>
            # or
            git reset --hard <remotenickname>/<branch_to_work_on>
            # or
            git merge <remotenickname>/<branch_to_work_on>

Work on deployment procedure
+++++++++++++++++++++++++++++
- Add/Edit/Relace your salt deployment code inside **.salt** inside your repository.

    .. code::

            cd /srv/projects/<foo>/project
            if [ ! -d .salt ];then mkdir .salt;fi
            cd .salt
            $EDITOR *


- If you want to install locally on the remote computer, or test it locally and
  do not want to run the full deployement procedure, when you are on a shell
  (connected via ssh on the remote computer or locally on your box), run:

      .. code::

            $ms/bin/salt-call mc_project.deploy only=install,fixperms

- You can also run just specific step(s):

      .. code::

            $ms/bin/salt-call mc_project.deploy only=install,fixperms only_steps=000_whatever
            $ms/bin/salt-call mc_project.deploy only=install,fixperms only_steps=000_whatever,001_else



=====================================================================
Exemple with salt/makina-states using a git-push workflow
=====================================================================
The idea behind the scene is to initialize an environment, then push changesets
via git to it and, this would run the deployment procedure on the behalf of a
git hook.


- Read first the section on makina-states without a git-push worklow

- Iniatilise on the target platform the project if it is not already done:

    .. code::

        $ms/bin/salt-call mc_project.init_project name=<foo> remote_less=False

- Keep under the hood both remotes (pillar & project).

- Clone the pillar remote inside your project top directory, on your
  machine, edit the configuration and push it back

    .. code::

        git clone ssh://devhost/srv/projects/<foo>/pillar.git
        $EDITOR init.sls



- Clone your project, and Add/Relace your salt deployment code inside
  **.salt** inside your repository, on your machine.

    .. code::

        cd ~/project
        git clone https://gitlab/client/project.git code
        cd code
        $EDITOR .salt/PILLAR.sample .salt/foo.sls
        git commit -am up

- Add the project remote

    - replace remotenickname with a sensible name (eg: prod)
    - replace the_project_remote_given_in_init with the real url
    - Run the following commands

        .. code::

            cd ~/project/code
            git remote add <remotenickname> <the_project_remote_given_in_init>
            git fetch --all

- Send back any pillar change

    .. code::

        cd ~/project/pillar
        git commit -am up
        git push



- Each time you need to deploy from your computer, push the project code (that
  needs to be a different commit that is on the distant host)

    .. code::

        cd ~/project/code
        git push [--force] <remotenickname> <yourlocalbranch_or_git_hash(eg: master,prod,whatever)>:master

- Notes:

    - The distant branch is always *master**
    - If you force the push, the local working copy of the remote deployed site
      will be resetted to the TIP changeset your are pushing.

- If you want to install locally on the remote computer, or test it locally and
  do not want to run the full deployement procedure, when you are on a shell
  (connected via ssh on the remote computer or locally on your box), run

    .. code::

      $ms/bin/salt-call mc_project.deploy only=install,fixperms

- You can also run just specific step(s)

    .. code::

        $ms/bin/salt-call mc_project.deploy only=install,fixperms only_steps=000_whatever
        $ms/bin/salt-call mc_project.deploy only=install,fixperms only_steps=000_whatever,001_else

- If you want to commit in prod and then push back from the remote computer, remember
  to push on the right remote & branch, eg:

    .. code::

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

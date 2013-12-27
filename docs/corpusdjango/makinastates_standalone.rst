=====================================================================
Django deployment with salt/makina-states
=====================================================================

.. contents::

Prequisites
------------

    * Ubuntu baremetal, container or VM (kvm, vbox) >= 14.04

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


Run tasks by hand
--------------------

Login as your project user & load the venv
++++++++++++++++++++++++++++++++++++++++++

    .. code::

        su <foo>-user
        cd /srv/projects/<foo>/project
        . venv/bin/activate

Check requirements versions For every fixed packages
++++++++++++++++++++++++++++++++++++++++++++++++++++++

    .. code::

        su <foo>-user
        cd /srv/projects/<foo>/project
        . venv/bin/activate
        pip list --outdated


Run django runserver
++++++++++++++++++++
After maybe stop circus & gunicorn)

      .. code::

         circusctl stop;killall -9 gunicorn # gunicorn may leave some zombies
         su <foo>-user
         cd /srv/projects/<foo>/project
        . venv/bin/activate
        src/manage.py runserver <localhost:8080>


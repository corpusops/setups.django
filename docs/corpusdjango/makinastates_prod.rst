=====================================================================
Using salt/makina-states with a git-push workflow
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

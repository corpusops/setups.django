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


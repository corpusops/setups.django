Place here every custom Django apps.

So to generate new apps, you must go here and then use django-admin :

.. code::

    cd <project>/apps

    django-admin startapp mybeautifulapp

And then reference it with Python path ``mysite.apps.mybeautifulapp``.

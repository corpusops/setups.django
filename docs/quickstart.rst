==========
Quickstart
==========

This docs has been quickly builded with the following command :

.. code::

    sphinx-quickstart

Only theming config has bene changed from ``alabaster`` to ``sphinx_rtd_theme``.
Why? Because this is definitively more dope dude!!

We also uncomment setting ``html_static_path``.

Feels free to completly rebuild this doc !

Translation
-----------

Translation isn't so hard... Take a look at http://www.sphinx-doc.org/en/stable/intl.html

To summarize :

.. code::

    cd docs/
    make gettext  # Build .pot file
    sphinx-intl update -p _build/locale -l fr  # Build .po file

Then translate the .po files.
Once translations are done, yu just need to build the doc, just like the
``make html`` command but with additonnal parameters to forward :

.. code::

    make -e SPHINXOPTS="-D language='fr'" html

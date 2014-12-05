#!/usr/bin/env python
# -*- coding: utf-8 -*- 
import os
from setuptools import setup, find_packages
def read(*rnames):
    return open(
        os.path.join(".", *rnames)
    ).read()
READMES = [a
           for a in ['README', 'README.rst',
                     'README.md', 'README.txt']
           if os.path.exists(a)]
long_description = "\n\n".join(READMES)
classifiers = [
    "Programming Language :: Python",
    "Topic :: Software Development"]

name = 'app'
version = "1.0dev"
src_dir = '.'

setup(
    name=name,
    version=version,
    namespace_packages=[],
    description=name,
    long_description=long_description,
    classifiers=classifiers,
    keywords="",
    author="foo",
    author_email="foo@foo.com",
    url="http://www.makina-corpus.com",
    license="GPL",
    packages=find_packages(src_dir),
    package_dir={"": src_dir},
    include_package_data=True,
    install_requires=[
        "setuptools",
        # -*- Extra requirements: -*-
    ],
    extras_require= {
        #"test": ["plone.app.testing", "ipython"]
    },
    entry_points={
        #z3c.autoinclude.plugin": ["target = plone"],
    },
)
# vim:set ft=python:

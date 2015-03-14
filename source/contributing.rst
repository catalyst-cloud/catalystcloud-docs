#################################
Contributing to the documentation
#################################


***********
Style guide
***********

This style guide describes the conventions that are followed by our
documentation project. If you follow them, your documents will pass the doc8
tests and compile cleanly.

This documentation uses `Python-sphinx`_, which itself uses `reStructuredText`_
syntax.

Filenames
=========

Use only lowercase alphanumeric characters and ``-`` (minus) symbol.

Suffix filenames with the ``.rst`` extension.

Whitespaces
===========

Indentation
-----------

Indent with 2 spaces.

Except:

* ``toctree`` directive requires a 3 spaces indentation.

Blank lines
-----------

Two blank lines before overlined sections, i.e. before H1 and H2.
One blank line before other sections.
See `Headings`_ for an example.

One blank line to separate directives.

.. code-block:: rst

  Some text before.

  .. note::

    Some note.

Exception: directives can be written without blank lines if they are only one
line long.

.. code-block:: rst

  .. note:: A short note.

Line length
===========

Limit all lines to a maximum of 79 characters.

Headings
========

Use the following symbols to create headings:

#. ``#`` with overline
#. ``*`` with overline
#. ``=``
#. ``-``
#. ``^``
#. ``"``

As an example:

.. code-block:: rst

  ##################
  H1: document title
  ##################

  Introduction text.


  *********
  Sample H2
  *********

  Sample content.


  **********
  Another H2
  **********

  Sample H3
  =========

  Sample H4
  ---------

  Sample H5
  ^^^^^^^^^

  Sample H6
  """""""""

  And some text.

If you need more than heading level 4 (i.e. H5 or H6), then you should consider
creating a new document.

There should be only one H1 in a document.

.. note::

  See also `Sphinx's documentation about sections`_.

Code blocks
===========

Use the ``code-block`` directive **and** specify the programming language. As
an example:

.. code-block:: rst

  .. code-block:: python

    import this

Admonitions
===========

.. note:: Notes can be used to emphasise a point that requires more attention.

.. code-block:: rst

  .. note:: A short note (fits one line).

  .. note::

    A long note that can span across multiple lines.

.. warning::

  Warnings can be used for to highlight things that must be done with caution.

.. code-block:: rst

  .. warning:: A short warning (fits one line).

  .. warning::

    A long warning that can span across multiple lines.

.. seealso:: See also can be used to refer to other documents.

.. code-block:: rst

  .. seealso:: A short reference (fits one line).

  .. seealso::

    A long reference that can span across multiple lines.

Tables
======

Tables should use the grid notation.

.. code-block:: rst

  +------------------------+------------+----------+----------+
  | Header row, column 1   | Header 2   | Header 3 | Header 4 |
  | (header rows optional) |            |          |          |
  +========================+============+==========+==========+
  | body row 1, column 1   | column 2   | column 3 | column 4 |
  +------------------------+------------+----------+----------+
  | body row 2             | ...        | ...      |          |
  +------------------------+------------+----------+----------+

Links and references
====================

Use links and references footnotes with the ``target-notes`` directive.
As an example:

.. code-block:: rst

  #############
  Some document
  #############

  Some text which includes links to `Example website`_ and many other links.

  `Example website`_ can be referenced multiple times.

  (... document content...)

  And at the end of the document...

  **********
  References
  **********

  .. target-notes::

  .. _`Example website`: http://www.example.com/


*****************
Submiting a patch
*****************

Go to https://github.com/catalyst/catalystcloud-docs and fork the docs to your
own account on GitHub.

Clone the docs from your own account::

  git clone https://github.com/your-account/catalystcloud-docs.git
  cd catalystcloud-docs

.. note::

  Remember to replace "your-account" on the example above with your account
  name.


Sync your fork with upstream changes (you can skip this step if you have just
cloned the repository)::

  git remote add upstream https://github.com/catalyst/catalystcloud-docs.git
  git fetch upstream
  git checkout master
  git merge upstream/master

Create a new topic branch for your contribution (choose a sensible name)::

  git checkout -b new/howto-do-x#9999

.. note::

  Branch naming convention: new|bug|?/<shortdesc>[#<ticket-num>]

  Branch names starts with "new" or "bug". New is used when adding a new
  document or new sections to existing documents. Bug is using when ammending
  content of an existing document.

  Short description is something brief that indicates what the change is.

  Ticket number is optional and indicates the ticket number that the change
  is related to.

Make your changes and contributions.

If you are adding a new document, you may want to add it to the index.rst, so
that people can find it when navigating the docs.

Compile the documentation and confirm you are happy with the changes. From the
root directory of the documentation project (where the Makefile file is
present)::

  ./compile.sh

Use your browser or file explorer to navigate to build/html and open either the
index.html or the document that you just changed.

When done::

  git add source/*
  git commit

.. note::

  Never add the build or venv directories to your commit. These are temporary
  directories that are generated automatically with every build.

Push the changes back to your personal repository::

  git push origin your-branch-name

Submit a `pull request`_ to Catalyst.

Our awesome team of document reviewers will peer review and proof read your
documentation changes and merge your pull request. Once it is merged, the
changes will be automatically deployed and published within one hour.


**********
References
**********

.. target-notes::

.. _`Python-sphinx`: http://sphinx.pocoo.org/
.. _`reStructuredText`: http://sphinx-doc.org/rest.html
.. _`rst2html`:
   http://docutils.sourceforge.net/docs/user/tools.html#rst2html-py
.. _`Github`: https://github.com
.. _`Sphinx's documentation about sections`:
   http://sphinx.pocoo.org/rest.html#sections
.. _`pull request`: https://help.github.com/articles/using-pull-requests/

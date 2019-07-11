#################################  
Contributing to the documentation
#################################

***********
Style guide
***********

This style guide describes the conventions that are followed by our
documentation project. If you follow them, your documents will pass the doc8
tests and compile cleanly.

This documentation uses `Python-sphinx <http://sphinx.pocoo.org/>`_, which
itself uses `reStructuredText <http://sphinx-doc.org/rest.html>`_ syntax.

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

* ``toctree`` directive requires a 3 space indentation.

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

#. H1: ``#`` with overline
#. H2: ``*`` with overline
#. H3: ``=``
#. H4: ``-``
#. H5: ``^``
#. H6: ``"``

As an example:

.. code-block:: rst

  ##############
  Document title
  ##############

  Introduction text. Note the empty line after the heading.


  ***********
  Heading two
  ***********

  Sample content. Note two empty lines before a heading two.


  *******************
  Another heading two
  *******************

  Note how headings only have the first letter capitalised.

  Sample heading three
  ====================

  Note how from heading three onward we only have one empty line between
  headings.

  Sample heading four
  -------------------

  Sample heading five
  ^^^^^^^^^^^^^^^^^^^

  Sample heading six
  """"""""""""""""""

  And some text.

If you need more than heading level 4 (i.e. H5 or H6), then you should consider
creating a new document.

There should be only one H1 in a document.

.. note::

  See also `Sphinx's documentation about sections
  <http://sphinx.pocoo.org/rest.html#sections>`_.

Code blocks
===========

Use the ``code-block`` directive **and** specify the programming language. As
an example:

.. code-block:: rst

  .. code-block:: python

    import this

When documenting command line interactions code-block ``console`` should be
used:

.. code-block:: rst

  .. code-block:: console

    $ ls -la

When documenting bash or shell scripts ``bash`` or ``sh`` should be used.

Admonitions
===========

.. note:: Notes can be used to emphasise a point that requires more attention.

.. code-block:: rst

  .. note:: A short note (fits one line).

  .. note::

    A long note that can span across multiple lines.

.. warning::

  Warnings can be used to highlight things that must be done with caution.

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

+------------------------+------------+----------+----------+
| Header row, column 1   | Header 2   | Header 3 | Header 4 |
| (header rows optional) |            |          |          |
+========================+============+==========+==========+
| body row 1, column 1   | column 2   | column 3 | column 4 |
+------------------------+------------+----------+----------+
| body row 2             | ...        | ...      |          |
+------------------------+------------+----------+----------+

.. code-block:: rst

  +------------------------+------------+----------+----------+
  | Header row, column 1   | Header 2   | Header 3 | Header 4 |
  | (header rows optional) |            |          |          |
  +========================+============+==========+==========+
  | body row 1, column 1   | column 2   | column 3 | column 4 |
  +------------------------+------------+----------+----------+
  | body row 2             | ...        | ...      |          |
  +------------------------+------------+----------+----------+

Lists
=====

Bullet lists
------------

Use the following format to create bullet lists:

* A bullet list must have an empty line before it begins;
* First level items use the "*" symbol;
* No empty lines should be used in between elements;
* If a line is too long, like this one, it must be broken into multiple lines
  with no more than 80 characters in each line;
* Second level sub items use the "-" symbol;

  - A sub list must have an empty line before it begins;
  - It must be indented with two spaces more than the first level lists;
  - A sub list must have an empty line after it ends.

* There should be an empty line after a list ends.

.. code-block:: rst

  * A bullet list must have an empty line before it begins;
  * First level items use the "*" symbol;
  * No empty lines should be used in between elements;
  * If a line is too long, like this one, it must be broken into multiple lines
    with no more than 80 characters in each line;
  * Second level sub items use the "-" symbol;

    - A sub list must have an empty line before it begins;
    - It must be indented with two spaces more than the first level lists;
    - A sub list must have an empty line after it ends.

  * There should be an empty line after a list ends.

Numbered lists
--------------

Use the following format to create numbered lists:

#. A bullet list must have an empty line before it begins;
#. List items must be auto-numbered using the "#" symbol;
#. No empty lines should be used in between elements;
#. If a line is too long, like this one, it must be broken into multiple lines
   with no more than 80 characters in each line.
#. There should be an empty line after a list ends.

.. code-block:: rst

  #. A bullet list must have an empty line before it begins;
  #. List items must be auto-numbered using the "#" symbol;
  #. No empty lines should be used in between elements;
  #. If a line is too long, like this one, it must be broken into multiple lines
     with no more than 80 characters in each line.
  #. There should be an empty line after a list ends.

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


******************
Submitting a patch
******************

Cloning the repo
================

Go to https://github.com/catalyst/catalystcloud-docs and fork the docs to your
own account on GitHub.

Clone the docs::

  git clone https://github.com/catalyst-cloud/catalystcloud-docs.git
  cd catalystcloud-docs

Create a new topic branch for your contribution (choose a sensible name)::

  git checkout -b new/fantastic-content#9999

Sync your branch with GitHub::

  git branch --set-upstream-to=origin/<branch> new/fantastic-content#9999

.. note::

  Branch naming convention: ``new|bug|?/<shortdesc>#<ticket-num>``

  Branch names starts with "new" or "bug". New is used when adding a new
  document or new sections to existing documents. Bug is using when ammending
  content of an existing document.

  ``<shortdesc>``: is something brief that indicates what the change is.

  ``<ticket-num>``: is optional and indicates the ticket number that the change
  is related to.


Making your changes and contributions
=====================================

When you'd like to make changes to the content, you can see your changes by
running the ``live_compile.sh`` script in the root directory::

  cd catalystcloud-docs
  ./live_compile.sh

Then navigate to ``localhost:8000`` to see the results of your changes. As you
save files, the changes will appear in your browser.

If you are adding a new document, you may want to add it to the index.rst, so
that people can find it when navigating the docs.

If you're using the `Atom text editor <https://atom.io/>`_, we recommend
installing the `Sphinx language <https://atom.io/packages/language-sphinx>`_
package, and making extensive use of the Reflow selection command
(``Shift+Ctrl+Q``).

When done::

  git add source/*
  git commit

.. note::

  If you want to be sure your documentation will work correctly, you can use
  :ref:`git hooks <doc-git-hooks>` documented below to check that the
  documentation will compile before it is committed.

Push the changes back to your personal branch::

  git push origin your-branch-name

Submitting your changes to be added
===================================

Submit a `pull request <https://help.github.com/articles/using-pull-requests/>`_
to Catalyst Cloud on GitHub.

Our awesome team of document reviewers will peer review and proof read your
documentation changes and merge your pull request. Once it is merged, the
changes will be automatically deployed and published within one hour.

.. _doc-git-hooks:


*********
Git Hooks
*********

In order to avoid committing reStructuredText code that does not compile we have
written a git pre-commit hook. Using this hook will ensure you do not commit
code that does not compile.

The pre commit hook is located at ``githooks/pre-commit``. The best way to
enable this hook depends on your version of git.

Git 2.9.0 or above
==================

In order to enable this hook, run the following command:

.. code-block:: bash

  $ git config core.hooksPath githooks

Be aware that if you have other hooks located in ``.git/hooks`` you will need to
move them into the ``githooks`` directory.

Git older than 2.9.0
====================

In order to enable this hook, run the following command for the root of this
repo:

.. code-block:: bash

  $ cp githooks/pre-commit .git/hooks/

If you prefer, you can symlink hooks as described `here
<https://stackoverflow.com/questions/4592838/symbolic-link-to-a-hook-in-git>`_.

Output Verbosity
================

The commit hook currently displays the output of ``compile.sh``. If you would
prefer to suppress this output, you can switch these commented lines:

.. code-block:: bash

  # Switch these if you prefer to suppress compiles output
  #"$DIR/compile.sh" &>/dev/null
  "$DIR/compile.sh"

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

Text Style
==========

Bold
----

We use bold text when we are referring to something important or when we are
directly talking about an element of a service that we want to direct the user
to. To make some text bold, you need to put the text between two sets of
asterisks without any spaces between the starting and ending letter of your
word: ** text you want to be bold **

Example: "You will find this under the **Container Infra** section of the
dashboard" OR "Remember **DO NOT** delete this file until after..."

Highlighting
------------

We use this when we are referring to a specific command piece of code that we
are talking about, but we do not want to use a code-block for. To use this
you need to place the string between two sets of tilde
`` text to be highlighted ``

Example: " Now you should have your ``token`` sourced..."

Whitespaces
===========

Indentation
-----------

Indent with 2 spaces.

Except:

* ``toctree`` directive requires a 3 space indentation.

Blank lines
-----------

Two blank lines before over lined sections, i.e. before H1 and H2.
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

#. H1: ``#`` with over line
#. H2: ``*`` with over line
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


*********
Git Hooks
*********

In order to avoid committing reStructuredText code that does not compile we
have written a git pre-commit hook. Using this hook will ensure you do not
commit code that does not compile.

The pre commit hook is located at ``githooks/pre-commit``. The best way to
enable this hook depends on your version of git.

Git 2.9.0 or above
==================

In order to enable this hook, run the following command:

.. code-block:: bash

  $ git config core.hooksPath githooks

Be aware that if you have other hooks located in ``.git/hooks`` you will need
to move them into the ``githooks`` directory.

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

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

.. _python-virtual-env:

*********************************
Using python virtual environments
*********************************

If you're not familiar with Python virtual environments, we recommend
reading `the virtualenv section of the Python documentation`_ for an overview.

Below we provide a cheat sheet for the actions and commands you will use the
most.

.. _the virtualenv section of the Python documentation: http://docs.python-guide.org/en/latest/dev/virtualenvs/

Create a virtual environment
============================

To create a new virtual environment, go to the directory where you would like
it to be placed and run the command below:

.. code-block:: bash

  virtualenv venv

Where ``venv`` is the name of the virtual environment you would like to create.
It is common practice to use ``venv`` as the name.

.. _activate-venv:

Activate a virtual environment
==============================

When you activate a virtual environment, virtualenv overwrites (temporarily)
some environment variables to place the ``venv/bin`` directory on your
``$PATH`` and force the use of the Python interpreter and libraries installed
in the virtual environment.

To activate a virtual environment:

.. code-block:: bash

  source venv/bin/activate

When activated, you will notice that the virtual environment name is now shown
on the left side of the prompt. This is done to remind you that you are working
"inside" this virtual environment.

Deactivate a virtual environment
================================

Once you are done working in the virtual environment, you can deactivate it.
This will revert the environment variables back to what they were, prior to it
being activated.

To deactivate a virtual environment:

.. code-block:: bash

  deactivate


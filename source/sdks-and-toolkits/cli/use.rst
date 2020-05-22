#############
Using the CLI
#############

This page assumes that you have installed the python virtual environment and
other dependencies from the :ref:`installing-the-cli` page earlier in this
section of the documentation. If you have, then the following should make
sense. If you want more information about how to use the python virtual
environment then please check the :ref:`activate-venv` section of our
documentation under tutorials.


**If you installed the CLI using pip:**

1. Activate your virtual environment.
2. :ref:`source-rc-file`
3. Invoke the CLI with the ``openstack`` command

**If you installed the CLI using docker:**

1. :ref:`source-rc-file`
2. Invoke the CLI with the ``ccloud`` alias anywhere the ``openstack`` command
   is otherwise used.


For a reference of all commands supported by the CLI, refer to the `OpenStack
Client documentation <https://docs.openstack.org/python-openstackclient>`_.

*************
The Next Step
*************

We highly recommend that if you are going to be using the CLI often that you
take the time to go through the documentation section on :ref:`setting up your
first instance <using-the-command-line-interface>`, using the CLI method. It
gives you a great step-by-step process to how to create an instance but also
teaches you the common commands found in openstack and the CLI.

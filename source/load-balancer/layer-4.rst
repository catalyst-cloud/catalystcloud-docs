######################
Layer 4 load balancing
######################

The following section details different methods that you can use to create a
basic layer 4 loadbalancer for your instances.

***************
Requirements
***************

While each of the examples below will have their own set of requirements,
there are some things that you need to prepare no matter which method you are
wanting to use. These include:

- :ref:`Sourcing an OpenRC file <cli-configuration>` for your Catalyst Cloud project
- Uploading or creating your own SSH key
- Whitelisting your IP address so that you can interact with the cloud from
  your command line.
- Installing the necessary tools for your chosen example. You can find instructions
  for this in the :ref:`starting section<using-the-command-line-interface>`
  of the documents.

Once these requirements are met, you can continue with any of the examples
below:

.. tabs::

  .. tab:: Openstack CLI

      .. include:: _scripts/layer4-files/cli-example.rst

  .. tab:: Heat

      .. include:: _scripts/layer4-files/heat-example.rst

  .. tab:: Terraform

      .. include:: _scripts/layer4-files/terraform-example.rst

  .. tab:: Ansible

      .. include:: _scripts/layer4-files/ansible-example.rst

################
Separate billing
################

As mentioned above, with our billing API the user can easily deal with their
invoices and make their life easier. We are providing a small script as a
reference for how to consume the billing API, see
https://github.com/catalyst-cloud/catalystcloud-billing

This script provides a means to get itemised billing based on the prefix of a
set of resources so that a Catalyst Cloud customer can easily on-charge their
hosted customers based on that customers usage.

.. note::

  This script is meant as a reference for how to consume the Catalyst
  Cloud billing API to get a separate billing based on the latest invoice. It
  should be fairly simple to change the code to meet other requirements.

**********
How to use
**********

Preparing your local environment
================================

Create a python virtual environment and install the libraries required by the
command line tool in it.

.. code-block:: bash

  virtualenv venv
  source venv/bin/activate
  pip install -r requirements.txt

Get billing information based on the prefix of customer
=======================================================

Source an openrc file with your credentials to access the Catalyst Cloud, as
described at :ref:`source-rc-file`

.. note::

  If you do not source an openrc file, you will need to pass the
  authentication information to the command line tool when running it. See
  ./separate-billing.py help for more information.

Make sure your python virtual environment is activated
(`source venv/bin/activate`).

Sample usage:

To retrieve the current billing information for a set of resources that have
the prefix **customer-wcc**, the command will look like this:

.. code-block:: bash

  ./separate-billing.py show --prefix customer-wcc

The output will look similar to this:

.. code-block:: bash

  +-------------------------------+--------+----------+---------+-------+
  | resource_name                 | rate   | quantity | unit    | cost  |
  +-------------------------------+--------+----------+---------+-------+
  | customer-wcc-ipsec-router-fdc | 0.017  | 697.0    | Hour(s) | 11.85 |
  | customer-wcc-ipsec-router-gdc | 0.017  | 697.0    | Hour(s) | 11.85 |
  | customer-wcc-fdc-vpnservice   | 0.017  | 697.0    | Hour(s) | 11.85 |
  | customer-wcc-gdc-vpnservice   | 0.017  | 697.0    | Hour(s) | 11.85 |
  | customer-wcc-fdc              | 0.0164 | 697.0    | Hour(s) | 11.43 |
  | customer-wcc                  | 0.0164 | 697.0    | Hour(s) | 11.43 |
  | customer-wcc-gdc              | 0.0164 | 697.0    | Hour(s) | 11.43 |
  +-------------------------------+--------+----------+---------+-------+
  Total cost of customer [customer-wcc] for the month of [2017-07-31] is : $81.69


Get billing information when there are no unique resource prefixes defined
==========================================================================

The parameter **prefix** is used to filter the invoice to get separate billing
information for different customers. If resources have been created without
specific prefixes it is still possible to query the billing data for the entire
project.

To view the full invoice, just issue the command without a specific
prefix as shown here:

.. code-block:: bash

  ./separate-billing.py show --prefix ''

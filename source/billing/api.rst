###########
Billing API
###########

Catalyst Cloud now provides a RESTful API to access our billing service. With
the billing API, it's easy to get historical invoices and the cost for the
current month. We have released an official Python client to help you consume
the API, see https://pypi.org/project/python-distilclient/.

*****************************************
How can I list my quotations or invoices?
*****************************************

After you have installed python-distilclient and python-openstackclient, you
can easily run the following command to list invoices:

.. code-block:: bash

  ~$ openstack rating invoice list --start 2017-11-01 --end 2017-12-01
  {
      "invoices": {
          "2017-11-30": {
              "status": "open",
              "total_cost": 1883.64
          }
      },
      "project_id": "5fac8ecc14fc4cd6g3e59d16aae4dcb",
      "project_name": "example.com",
      "start": "2017-11-01 00:00:00",
      "end": "2017-12-01 00:00:00"
  }

Or getting current month quotation:

.. code-block:: bash

  ~$ openstack rating quotation list
  {
      "end": "2017-12-05 00:00:00",
      "project_id": "94b566de52f9423faxxxxxxe8c0a4a23",
      "project_name": "openstack",
      "quotations": {
          "2017-12-05": {
              "total_cost": 34.82
          }
      },
      "start": "2017-12-01 00:00:00"
  }

.. note::

  With argument ``--detailed``, you can get the details of the invoice.

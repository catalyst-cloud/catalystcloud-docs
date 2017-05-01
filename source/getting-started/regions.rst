#############
Cloud regions
#############

The Catalyst Cloud is hosted on multiple regions or geographical locations.
Regions are data centres that are completely independent and isolated from each
other, providing fault tolerance and geographic diversity.

All our data centres have backup diesel generators, UPS, N+1 process coolers
and diverse fibre paths for network connectivity.

+----------+-----------------+--------------------+
| Code     | Name            | PCI DSS certified? |
+==========+=================+====================+
| nz-por-1 | NZ Porirua 1    | Yes                |
+----------+-----------------+--------------------+
| nz_wlg_2 | NZ Wellington 2 | In progress        |
+----------+-----------------+--------------------+

We encourage customers to use Porirua as their primary region in New Zealand.
This region is Catalyst's newest addition to the Catalyst Cloud. It is PCI
certified and has six times the capacity of the Wellington region.

The connectivity between compute instances hosted on different regions takes
place over either our wide area network or the Internet when allowed by your
security groups and network configuration.

Most resources are not replicated automatically across regions unless you do
so. The only resource which are replicated, is object storage. This provides
customers the flexibility to introduce replication where required and to
fail-over resources independently when needed.

****************
Changing regions
****************

Via the dashboard
=================

The web dashboard has a region selector dropbox on the top bar. It indicates
the current region you are connected to and allows you to easily switch
between regions.

Via the command line tools
==========================

The command line tools pick up the region from the $OS_REGION_NAME environment
variable. To define the variable:

.. code-block:: bash

  export OS_REGION_NAME="region-code"

Alternatively you can use the ``--os-region-name`` option to specify the region
on each call.

Via the APIs
============

The API request you use to authenticate with the Catalyst Cloud allows you to
scope a token on a given region. The token can then be used to interact with
the API endpoints of the other services hosted in the same region.


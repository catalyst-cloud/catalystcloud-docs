#############
Cloud regions
#############

The Catalyst Cloud is hosted on multiple regions or geographical locations.
Regions are data centres that are completely independent and isolated from each
other, providing fault tolerance and geographic diversity.

All our data centres have backup diesel generators, UPS, N+1 process coolers
and diverse fibre paths for network connectivity.

+----------+-----------------+--------------------+----------------------+
| Code     | Name            | PCI DSS certified? | ISO 27001 certified? |
+==========+=================+====================+======================+
| nz-por-1 | NZ Porirua 1    | Yes                | Yes                  |
+----------+-----------------+--------------------+----------------------+
| nz_wlg_2 | NZ Wellington 2 | In progress        | In progress          |
+----------+-----------------+--------------------+----------------------+
| nz-hlz-1 | NZ Hamilton 1   | Yes                | In progress          |
+----------+-----------------+--------------------+----------------------+

We encourage customers to use Porirua for their primary region in New Zealand
as it currently has the most capacity of all our sites.

The connectivity between compute instances hosted on different regions takes
place over either our wide area network or the Internet when allowed by your
security groups and network configuration.

Resources are not replicated automatically across regions unless you do so.
This provides customers the flexibility to introduce replication where required
and to fail-over resources independently when needed. The only exception to
this is object replication which will, over time, ensure that there is a copy
of every object replicated across all three regions.

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

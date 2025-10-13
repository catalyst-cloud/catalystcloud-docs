.. _metrics-getting-started:

###############
Getting Started
###############

This page documents how to interact with the Catalyst Cloud Metrics Service
using the OpenStack CLI, the Python Client for Gnocchi, or via direct
metrics API requests using cURL.

You should reference the :ref:`Metrics Service Overview <metrics-overview>`
while going through this page to understand some of the concepts and terminology used.
Information on the resource and metric types we offer is available in the :ref:`metrics-reference`.

.. note::

  The Metrics Service has no user interface on the Catalyst Cloud dashboard at this time.

.. contents::
    :local:
    :depth: 3
    :backlinks: none

.. _metrics-prerequisites:

*************
Prerequisites
*************

Setting up users
================

Catalyst Cloud users with one of the following user roles can use the Metrics Service
(for more information, see :ref:`Access Control <access_control>`):

* :ref:`project_member_role`
* :ref:`metric_reader_role`

Setting up your environment
===========================

First, follow the instructions for :ref:`setting up the CLI Tools and SDKs <sdks_and_toolkits>`.

Make sure you have :ref:`sourced the OpenRC file for your project <source-rc-file>` in an open terminal.

.. tabs::

  .. group-tab:: OpenStack CLI

    Check that the ``openstack metric`` series of commands are available.

    If not, make sure the ``gnocchiclient`` package is installed.

    .. code-block:: console

      $ openstack metric --help
      Command "metric" matches:
        metric aggregates
        metric archive-policy create
        metric archive-policy delete
        metric archive-policy list
        metric archive-policy show
        metric archive-policy update
        metric archive-policy-rule create
        metric archive-policy-rule delete
        metric archive-policy-rule list
        metric archive-policy-rule show
        metric benchmark measures add
        metric benchmark measures show
        metric benchmark metric create
        metric benchmark metric show
        metric capabilities list
        metric create
        metric delete
        metric list
        metric measures add
        metric measures aggregation
        metric measures batch-metrics
        metric measures batch-resources-metrics
        metric measures show
        metric resource batch delete
        metric resource create
        metric resource delete
        metric resource history
        metric resource list
        metric resource search
        metric resource show
        metric resource update
        metric resource-type create
        metric resource-type delete
        metric resource-type list
        metric resource-type show
        metric resource-type update
        metric server version
        metric show
        metric status

  .. group-tab:: Python Client

    Here we will show you how to get a working Gnocchi client object
    in an interactive Python shell.

    First, open an interactive Python shell in the environment where
    the ``gnocchiclient`` package is installed:

    .. code-block:: bash

      python3 -i

    Next, copy and paste the following code into the shell to
    create and configure a Gnocchi client object from the
    authentication credentials configured in your terminal.

    We will use ``gnocchi_client`` as the variable to access the
    Python Client for Gnocchi in examples throughout this page.

    .. code-block:: python

      import datetime
      import os
      from pprint import pprint
      from keystoneauth1.identity.generic import Token
      from keystoneauth1.session import Session
      from gnocchiclient.client import Client
      session = Session(auth=Token(os.environ["OS_AUTH_URL"], os.environ["OS_TOKEN"], project_id=os.environ["OS_PROJECT_ID"]))
      gnocchi_client = Client("1", session=session, adapter_options=dict(region_name=os.environ["OS_REGION_NAME"]))

    If you get the following error:

    .. code-block:: text

      Traceback (most recent call last):
        File "<stdin>", line 6, in <module>
      ModuleNotFoundError: No module named 'gnocchiclient'

    Make sure the ``gnocchiclient`` package is installed in your Python environment.

    For more information on how to use the ``gnocchiclient`` library,
    read the `Python Client for Gnocchi`_ documentation.

    .. _`Python Client for Gnocchi`: https://gnocchi.osci.io/gnocchiclient

  .. group-tab:: cURL

    Install the ``curl`` system package if it is not installed already.

    .. tabs::

      .. group-tab:: Debian / Ubuntu

        .. code-block:: bash

          sudo apt update && sudo apt install -y curl

      .. group-tab:: Red Hat / Fedora

        .. code-block:: bash

          sudo dnf install -y curl

************
Common Tasks
************

Here are instructions for performing a number of tasks
regularly done when interacting with the Metrics Service.

Get a resource by UUID
======================

.. include:: _sections/getting-started/common-tasks/get-a-resource-by-uuid.rst

.. _metrics-get-container-resource:

Get an object storage container resource without a UUID
=======================================================

.. include:: _sections/getting-started/common-tasks/get-an-object-storage-container-resource-without-a-uuid.rst

List all resources in a project
===============================

.. include:: _sections/getting-started/common-tasks/list-all-resources-in-a-project.rst

Show resource metric details by name
====================================

.. include:: _sections/getting-started/common-tasks/show-resource-metric-details-by-name.rst

Show metric details by ID
=========================

.. include:: _sections/getting-started/common-tasks/show-metric-details-by-id.rst

Get resource metric measures
============================

.. include:: _sections/getting-started/common-tasks/get-resource-metric-measures.rst

.. _metrics-searching-resources:

*******************
Searching Resources
*******************

The Metrics Service allows you to perform searches on
:ref:`resources <metrics-resources>` within a project
to return only resources that match the defined search filters.

The same filter syntax is used by the :ref:`metrics-aggregates-api`
when performing queries against resource metrics.

Here we provide a few examples of how to use the resource search API
to do some common tasks. For more details on the available search
filters and options, see the `Gnocchi search API documentation`_.

.. _`Gnocchi search API documentation`: https://gnocchi.osci.io/rest.html#search

.. note::

  One major consideration when making search filters is that by default
  all resources that match the filters will be returned, including resources
  that no longer exist (but still have metrics recorded in the Metrics Service).

  If you want to exclude deleted resources, add a filter
  checking that ``ended_at`` is set to ``null``.

  In addition, please be aware that metrics and resource metadata expire
  after 90 days, so any deleted resources older than that are no longer available.

Exact match
===========

.. include:: _sections/getting-started/searching-resources/exact-match.rst

Not equals
==========

.. include:: _sections/getting-started/searching-resources/not-equals.rst

Like
====

.. include:: _sections/getting-started/searching-resources/like.rst

Not
===

.. include:: _sections/getting-started/searching-resources/not.rst

Greater-than/less-than
======================

.. include:: _sections/getting-started/searching-resources/greater-than-less-than.rst

And/or
======

.. include:: _sections/getting-started/searching-resources/and-or.rst

Appendix
========

Make filters as specific as possible
------------------------------------

.. include:: _sections/getting-started/searching-resources/make-filters-as-specific-as-possible.rst

.. _metrics-resource-history:

****************
Resource History
****************

.. include:: _sections/getting-started/resource-history/introduction.rst

Get revisions within a specific time period
===========================================

.. include:: _sections/getting-started/resource-history/get-revisions-within-a-specific-time-period.rst

.. _metrics-aggregates-api:

**************
Aggregates API
**************

The Aggregates API is the main method of retrieving, processing
and reaggregating data in the Metrics Service.

Clients provide, among others, two major parameters that tell the
Metrics Service how data should be handled:

* A series of **operations**, which not only select the desired metrics
  but also define a pipeline of actions to be performed on them to transform
  the output to the desired format.
* **Search filters** that define the resources that should be evaluated,
  using the same format as when :ref:`searching resources <metrics-searching-resources>`.

This allows for very flexible queries, from a single metric on a specific resource
to a composite query reaggregating multiple metrics from many resource types into
highly consolidated measures.

This section demonstrates many of the most common ways the Aggregates API is expected
to be used by customers. For additional reading on the Aggregates API's capabilities,
refer to the Gnocchi documentation on `Dynamic Aggregates`_.

.. _`Dynamic Aggregates`: https://gnocchi.osci.io/rest.html#dynamic-aggregates

Basic usage
===========

.. include:: _sections/getting-started/aggregates-api/basic-usage.rst

.. _metrics-aggregates-api-with-resource-details:

With resource details
=====================

.. include:: _sections/getting-started/aggregates-api/with-resource-details.rst

.. _metrics-aggregates-api-examples:

Examples
========

Get instance CPU usage as a percentage
--------------------------------------

.. include:: _sections/getting-started/aggregates-api/get-instance-cpu-usage-as-a-percentage.rst

Get server group CPU usage as a percentage
------------------------------------------

.. include:: _sections/getting-started/aggregates-api/get-server-group-cpu-usage-as-a-percentage.rst

Get instance RAM usage as a percentage
--------------------------------------

.. include:: _sections/getting-started/aggregates-api/get-instance-ram-usage-as-a-percentage.rst

Get server group RAM usage as a percentage
------------------------------------------

.. include:: _sections/getting-started/aggregates-api/get-server-group-ram-usage-as-a-percentage.rst

Get per-volume block storage usage
----------------------------------

.. include:: _sections/getting-started/aggregates-api/get-per-volume-block-storage-usage.rst

Get total block storage usage
-----------------------------

.. include:: _sections/getting-started/aggregates-api/get-total-block-storage-usage.rst

Get total object storage usage
------------------------------

.. include:: _sections/getting-started/aggregates-api/get-total-object-storage-usage.rst

Get outbound inter-region/Internet traffic across all resources
---------------------------------------------------------------

.. include:: _sections/getting-started/aggregates-api/get-outbound-interregion-internet-traffic-across-all-resources.rst

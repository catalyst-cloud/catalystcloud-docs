.. _cloud-dashboard:

#########
Dashboard
#########


The web dashboard is a simple way to interact with The Catalyst Cloud. It can
be found at https://dashboard.cloud.catalyst.net.nz.

.. image:: assets/dashboard_view.png

Our web dashboard is a great tool that provides easy
access to most of the services that the Catalyst Cloud provides. All of the
standerd services are able to be controlled via the Dashboard. There are some
more advanced abilities that the cloud environment is capable of; however these
require the use of the :ref:`CLI <command-line-interface>` or interacting with
our API's directly; which is discussed elsewhere in the :ref:`documentation
<apis>`

As previously mention in the getting started section, you can see most of the
services provided on the left hand sidebar. These services have their own
guides and tutorials that are featured later on. Things such
as creating compute instances, partitioning block storage or object storage
etc. Before going on to use these services, we recommend going through our
:ref:`first instance tutorial. <launch-first-instance>`

Some of the dashboard functionality beyond these services are in the
buttons along the top bar. From left to right, these:

* Let you select which project you are working on
* Change what region your operating in
* Access our support functions
* Change accounts or access your account settings.

The major appeal of using the dashboard is it requires very little programming
expertise or knowledge. There is an assumed level of understanding about the
products you are trying to create or outcomes you seek to achieve, but you can
use most of the services provided by the Catalyst Cloud simply by navigating
through the dashboard.

Another  major advantage to the web dashboard is that it is accessible from any
IP address, making it a quick way to perform tasks on the Catalyst Cloud while
you're away from your normal work station.


.. note::

  When a new feature is introduced to our cloud, it is first exposed via a REST
  API, followed by the command line clients and finally the web dashboard. It
  usually takes 3-6 months for it to reach the dashboard, but it can be used
  well ahead of that via the API and command line clients.

.. toctree::
   :maxdepth: 1

   dashboard/faq

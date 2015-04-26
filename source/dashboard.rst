#########
Dashboard
#########


********
Overview
********

The web dashboard is a simple way to interact with The Catalyst Cloud. It can
be found at https://dashboard.clould.catalyst.net.nz.

.. note::

  When a new feature is introduced to our cloud, it is first exposed via a REST
  API, followed by the command line clients and finally the web dashboard. It
  usually takes 3-6 months for it to reach the dashboard, but it can be used
  well ahead of that via the API and command line clients.


***
FAQ
***

Failed to delete resource
=========================

Delete errors are often caused by dependencies preventing you from deleting a
resource. For example:

* Trying to delete a volume, when a snapshot depends on it.
* Trying to delete a network, when a port is still connected to it (such as a
  router's interface)

Error messages provided by the dashboard tend to be brief and sometime lack the
details that caused the error. If you are repeatedly being presented with a
delete error, please check whether resource dependencies could be the cause.
The command line tools are designed to be more verbose and tend to present more
information about what is causing a delete error.

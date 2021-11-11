################################
Software development kits (SDKs)
################################

A rich set of software development kits (SDKs) are available for OpenStack,
providing language bindings and tools that make it easy for you to use the
Catalyst Cloud.

The official OpenStack clients are the native Python bindings for the OpenStack
APIs and the recommended SDK for the Catalyst Cloud:
https://wiki.openstack.org/wiki/OpenStackClients

OpenStack has a very rich ecosystem. Often multiple SDK options exist for a
given language. The 'Development resources for OpenStack clouds' page, found at
http://developer.openstack.org/, provides recommendations for the most stable
and feature rich SDK for your preferred language.

SDKs for all other major languages can be found at:
https://wiki.openstack.org/wiki/SDKs

Prior to accessing the Catalyst Cloud API endpoints, ensure you are working
from a **whitelisted IP address**.  More information can be found under
:ref:`Access and whitelist <access-and-whitelist>`

********************
Client tool versions
********************

Each of the services we have on our Cloud require a different client tool to
interact with. Earlier in this section we covered how to install these into a
virtual environment so that you are able to use the openstack command line.

Below is a list of the Client tools and their latest supported version on the
Catalyst Cloud. When upgrading a service, in order to be able to interact with
any new features you should check to make sure that your client tools are up to
date with oru currently supported version.

+----------------+------------+--------------------------+
| Service        | Toolkit    | Latest supported version |
+----------------+------------+--------------------------+
| alarm          | aodh       | 1.2.0                    |
+----------------+------------+--------------------------+
| block-storage  | cinder     | 1.11.0                   |
+----------------+------------+--------------------------+
| compute        | nova       | 2.30.3                   |
+----------------+------------+--------------------------+
| database       | trove      | 5.1.1                    |
+----------------+------------+--------------------------+
| identity       | keystone   | 2.3.2                    |
+----------------+------------+--------------------------+
| image          | glance     | 2.6.0                    |
+----------------+------------+--------------------------+
| kubernetes     | Magnum     | 3.2.2                    |
+----------------+------------+--------------------------+
| network        | neutron    | 3.1.1                    |
+----------------+------------+--------------------------+
| object-storage | swift      | 3.8.1                    |
+----------------+------------+--------------------------+
| orchestration  | heat       | 1.18.1                   |
+----------------+------------+--------------------------+

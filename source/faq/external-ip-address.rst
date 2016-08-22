#####################################################
How do I find the external IP address of my instance?
#####################################################

There are scenarios where you may need to know the external IP address that
instances in your project are using. For example you may wish to allow traffic
from your Catalyst Cloud instances to access a service that has firewalling or
other IP based access control in place.

For instances that have a floating IP you simply need to find the floating IP,
for instances that do not have a floating IP address the external IP address
will be the external address of the router they are using to access the
``public-net``.

There are a number of methods you can use to find the IP address:

Using DNS on an instance
========================

From a cloud instance run the following command:

.. code-block:: bash

 ubuntu@my-instance:~$ dig +short myip.opendns.com @resolver1.opendns.com
 150.242.43.13

Using HTTP on an instance
=========================

From a cloud instance run the following command:

.. code-block:: bash

 ubuntu@my-instance:~$ curl http://ipinfo.io/ip
 150.242.43.13

Using a bash script on an instance
==================================

You can use a bash script we have written for this purpose:

.. literalinclude:: ../../scripts/whats-my-ip.sh
  :language: bash

You can download and run this script on an instance:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/scripts/whats-my-ip.sh
 $ chmod 744 whats-my-ip.sh
 $ ./whats-my-ip.sh
 finding your external ip ...
 Your external IP address is: 150.242.43.13

Using the OpenStack Command Line Tools
======================================

The method you use to find the external IP address will depend on whether the
instance has a floating IP address or not:

For an instance with a floating IP
**********************************

You can find the Floating IP of an instance in the instances list on the
dashboard. From the command line you can use the following command:

.. code-block:: bash

 $ openstack server show useful-machine | grep addresses | awk '{ print $5 }'
 150.242.43.13

For an instance without a floating IP
*************************************

From a host where you have the OpenStack command line clients installed run the
following command:

.. code-block:: bash

 $ openstack router show border-router | grep external_gateway_info
| external_gateway_info | {"network_id": "849ab1e9-7ac5-4618-8801-e6176fbbcf30", "enable_snat": true, "external_fixed_ips": [{"subnet_id": "aef23c7c-6c53-4157-8350-d6879c43346c", "ip_address": "150.242.40.120"}]} |


The address is the value associated with ``ip_address`` in
``external_fixed_ips``.

If you have ``jq`` installed you can run the following command:

.. code-block:: bash

 $ openstack router show border-router | awk -F'|' '/external_gateway_info/{ print $3 }' | jq -r '.external_fixed_ips[].ip_address'
 150.242.43.12

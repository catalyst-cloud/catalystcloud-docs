.. _cloud-orchestration:

#############
Orchestration
#############



Cloud orchestration allows you to deploy applications and infrastructure using
a simple template language that describes the required resources and their
relationship. The template format is based on YAML and is called Heat
Orchestration Template (HOT). The orchestration service manages the life-cycle
of application stacks on your behalf. When a template is modified, the service
orchestrates the required changes to the infrastructure in the appropriate
order. Templates can be managed like code and stored in your preferred version
control system. More information about Heat can be found in the OpenStack wiki:
https://wiki.openstack.org/wiki/Heat

.. Heat makes auto-scaling easy. You can define a scaling group and a scaling
   policy and Heat will add or remove compute instances to the group as
   required.

The orchestration service can be integrated to configuration management systems
to provision and manage software. It can run `Puppet`_ in standalone
mode, or be used to present compute instances back to the Puppet/Chef master
for software configuration.

.. _Puppet: https://puppetlabs.com/

There are no additional charges for the use of the cloud orchestration service.
You will only pay for the resources consumed by your running application stacks
(such as compute, network and storage).

|

.. toctree::
   :maxdepth: 1

  Orchestration/Using-heat-CLI
  Orchestration/HOT-format
  Orchestration/FAQ




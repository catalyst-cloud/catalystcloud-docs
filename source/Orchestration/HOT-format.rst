
**********
HOT format
**********

More information on the HOT format can be found on the OpenStack user
guide at: http://docs.openstack.org/user-guide/hot-guide/hot.html

More information on resource types that can be orchestrated by Heat can be
found at:
http://docs.openstack.org/developer/heat/template_guide/openstack.html

.. note::

  Only resources related to services provided by the Catalyst Cloud should be
  used.

The resource types available on the Catalyst Cloud are:

* OS::Cinder::Volume
* OS::Cinder::VolumeAttachment
* OS::Glance::Image
* OS::Heat::AccessPolicy
* OS::Heat::AutoScalingGroup
* OS::Heat::CloudConfig
* OS::Heat::HARestarter
* OS::Heat::InstanceGroup
* OS::Heat::MultipartMime
* OS::Heat::RandomString
* OS::Heat::ResourceGroup
* OS::Heat::ScalingPolicy
* OS::Heat::SoftwareComponent
* OS::Heat::SoftwareConfig
* OS::Heat::SoftwareDeployment
* OS::Heat::SoftwareDeployments
* OS::Heat::Stack
* OS::Heat::StructuredConfig
* OS::Heat::StructuredDeployment
* OS::Heat::StructuredDeployments
* OS::Heat::SwiftSignal
* OS::Heat::SwiftSignalHandle
* OS::Heat::UpdateWaitConditionHandle
* OS::Heat::WaitCondition
* OS::Heat::WaitConditionHandle
* OS::Neutron::FloatingIP
* OS::Neutron::FloatingIPAssociation
* OS::Neutron::HealthMonitor
* OS::Neutron::IKEPolicy
* OS::Neutron::IPsecPolicy
* OS::Neutron::IPsecSiteConnection
* OS::Neutron::MeteringLabel
* OS::Neutron::MeteringRule
* OS::Neutron::Net
* OS::Neutron::NetworkGateway
* OS::Neutron::Port
* OS::Neutron::ProviderNet
* OS::Neutron::Router
* OS::Neutron::RouterGateway
* OS::Neutron::RouterInterface
* OS::Neutron::SecurityGroup
* OS::Neutron::Subnet
* OS::Neutron::VPNService
* OS::Nova::FloatingIP
* OS::Nova::FloatingIPAssociation
* OS::Nova::KeyPair
* OS::Nova::Server
* OS::Nova::ServerGroup
* OS::Swift::Container

.. Resources to be added in the future
.. * OS::Ceilometer::Alarm
.. * OS::Ceilometer::CombinationAlarm
.. * OS::Neutron::Firewall
.. * OS::Neutron::FirewallPolicy
.. * OS::Neutron::FirewallRule
.. * OS::Neutron::LoadBalancer
.. * OS::Neutron::Pool
.. * OS::Neutron::PoolMember
.. * OS::Sahara::Cluster
.. * OS::Sahara::ClusterTemplate
.. * OS::Sahara::NodeGroupTemplate
.. * OS::Trove::Cluster
.. * OS::Trove::Instance

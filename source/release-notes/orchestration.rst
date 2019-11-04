.. _orchestration:

#############
Orchestration
#############

This is the release notes/changes list for Catalyst Cloud Orchestration
service.

.. note::
  Latest API version: ``v1``

.. note::
  Latest Heat Template version: ``heat_template_version.2018-03-02``


*************
July 25, 2018
*************

  * Upgrade Heat template version from ``heat_template_version.2015-04-30``
    to ``heat_template_version.2018-03-02``
  * The OS::Heat::HARestarter resource type is no longer supported. This resource
    type is now hidden from the documentation. HARestarter resources in stacks,
    including pre-existing ones, are now only place holders and will no longer do
    anything. The recommended alternative is to mark a resource unhealthy and
    then do a stack update to replace it. This still correctly manages
    dependencies but, unlike HARestarter, also avoid replacing dependent
    resources unnecessarily. An example of this technique can be seen in the
    auto healing sample templates at
    https://git.openstack.org/cgit/openstack/heat-templates/tree/hot/autohealing

  * The AWS compatible CloudWatch API, deprecated since long has been finally
    removed.

  * With pre-icehouse stacks which contain resources that create users
    (such as OS::Nova::Server, OS::Heat::SoftwareDeployment, and OS::Heat::WaitConditionHandle),
    it is possible that the users will not be removed upon stack deletion due to
    the removal of a legacy fall back code path. In such a situation, these users
    will require manual removal.

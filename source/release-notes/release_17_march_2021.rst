#################
17 March 2021
#################

Minor release to update the Kubernetes service and the loadbalancing service.
The changes include some fixes for the Kubernetes service, and some additional
features for both services..

************************
Container Infra (Magnum)
************************

We have added support for kubernetes v1.20.x and will be adding templates for
this version in future releases. Additionally there was a fix implemented to
solve an issue that was affecting kubernetes rolling upgrades.

Finally, we have added support for `Containerd`_ at runtime.

************************
Load balancing (Octavia)
************************

We have added support for deploying loadbalancers (including a health-monitor
for UDP-based services.

.. _Containerd: https://containerd.io/
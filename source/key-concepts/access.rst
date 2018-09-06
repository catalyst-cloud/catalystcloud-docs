############################
Access to the Catalyst Cloud
############################

The cloud dashboard is publicly available on the Internet and can be reached
at: https://dashboard.cloud.catalyst.net.nz

As an additional security measure, the Catalyst Cloud APIs only accept requests
from whitelisted IP addresses. If you have provided an IP address during sign
up, you should be able to reach the APIs from that IP. Otherwise, you can `open
a support request
<https://dashboard.cloud.catalyst.net.nz/management/tickets/>`_ via the
dashboard at any time to request a change to the white-listed IPs.

All compute instances on the Catalyst Cloud have whitelisted IP addresses by
default. The :ref:`cloud dashboard <cloud-dashboard>` will also allow you to
access the APIs while you're operating from a non-whitelisted IP address.

The compute instances you launch on the Catalyst Cloud are created in your
private network by default. You have the option to associate a floating IP
(public IP) with your compute instances to expose them to the Internet. You can
use security groups (similar to firewalls) to define who has access to your
compute instances, as explained in :ref:`security-groups`.

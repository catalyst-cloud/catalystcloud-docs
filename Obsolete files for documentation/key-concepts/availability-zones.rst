.. _availability-zones:

##################
Availability zones
##################

The Catalyst Cloud does not use availability zones as a construct for
high-availability within regions. Instead, it uses server groups with
anti-affinity polices to ensure compute instances are scheduled in different
physical servers.

For more information, please refer to the :ref:`anti-affinity` section of the
documentation.

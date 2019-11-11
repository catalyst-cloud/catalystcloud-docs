###########################
Best-practices for networks
###########################

Follow standard security precautions
====================================

Under the :ref:`best-practice` there are a number of security precautions that
we recommended you follow when conducting any work on your cloud projects.
The important ones to consider for networking are :ref:`access_control`,
security groups and password protection/strength. Following these and the other
security best practices will help to ensure your projects are as safe as
possible.


Networks are isolated between regions
=====================================

By default your networks and instance cannot access or connect to one another
without changing their parameters. However networks in other regions to the
resources your want to use, including other networks, are not only inaccessible
but they also can't be seen by your other networks. This adds a level of
security on top of the others above.
However if you have a need to connect two or more networks across regions you
can do so using a :ref:`vpn`


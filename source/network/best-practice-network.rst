###########################
Best-practices for networks
###########################

Follow standard security precautions
====================================

Under the :ref:`best-practices` there are a number of security
precautions that we recommended you follow when conducting any work on your
cloud projects. The important ones to consider for networking are
:ref:`access_control`, security groups and password protection/strength.
Following these and the other security best practices will help to ensure your
projects are as safe as possible.


Networks are isolated between regions
=====================================

By default your networks and instance cannot access or connect to one another
without changing their security permissions even if they share resources.
This creates a level of isolation between your resources so that users cannot
access anything outside the resource they currently have. To add another layer
of security on top of this, networks in other regions have no knowledge
whatsoever of the networks in other regions. Meaning that you have to manually
and explicitly set up the ability for those networks to be able to communicate.
If you have a need to connect two or more networks across regions you
can do so using a :ref:`vpn`


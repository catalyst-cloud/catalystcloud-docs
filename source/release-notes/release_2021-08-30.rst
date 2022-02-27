#################
30 August 2021
#################

Minor release to update the Kubernetes service. Making changes to the admission
controller default policy list.

************************
Container Infra (Magnum)
************************

We have removed the  the `PodSecurityPolicy`_ from the default list of the
`admission controllers`_. This removal comes due to the pod-security-policy
being deprecated in versions v1.21.x. of Kubernetes going forward. This means
that while you can still choose to use this policy on the Catalyst Cloud, there
will not be upstream support for the service.

.. _PodSecurityPolicy: https://kubernetes.io/docs/concepts/policy/pod-security-policy/

.. _admission controllers: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/


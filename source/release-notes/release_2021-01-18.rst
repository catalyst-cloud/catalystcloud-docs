#################
18 January 2021
#################

Minor release to update the Kubernetes service and add more security measures for pods.

************************
Container Infra (Magnum)
************************

We have enabled the `PodSecurityPolicy`_ for the `admission controllers`_.
These policies are used to restrict security sensative aspects of your pods. More information can be found in the linked documents.

.. _PodSecurityPolicy: https://kubernetes.io/docs/concepts/policy/pod-security-policy/

.. _admission controllers: https://kubernetes.io/docs/referenc/access-authn-authz/admission-controllers/


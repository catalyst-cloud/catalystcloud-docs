####################
Basic nginx example
####################

In this example we will create a simple nginx application using the standard nginx container
image.


Create deployment
=================
The manifest file

- apiVersion
- knd
- metadata
- spec

.. literalinclude:: _containers_assets/nginx-deployment.yaml
  :emphasize-lines: 1-3,7
  :linenos:

.. code-block:: bash

  kubectl create -f nginx-deployment.yaml
  kubectl describe deployment nginx-deployment

create service
--------------


.. literalinclude:: _containers_assets/nginx-service.yaml

.. code-block:: bash

  kubectl create -f nginx-service.yaml
  kubectl describe service nginx-service


Other commands
--------------
.. code-block:: bash

  kubectl delete service nginx-service
  kubectl delete deployment nginx-deployment
  kubectl get deployments



better output
-------------
//TODO getting better output from kubectl

get pods with
  -o wide
  -o yaml or -o json

kubectl exec podname ps aux

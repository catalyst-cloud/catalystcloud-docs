####################
Basic nginx example
####################

create deployment
=================
In this example we will create a simple nginx container.

.. literalinclude:: ../_scripts/nginx-deployment.yaml

.. code-block:: bash

  kubectl create -f nginx-deployment.yaml
  kubectl describe deployment nginx-deployment

create service
--------------


.. literalinclude:: ../_scripts/nginx-service.yaml

.. code-block:: bash

  kubectl create -f nginx-service.yaml
  kubectl describe service nginx-service


Other commands
--------------
.. code-block:: bash

  kubectl delete service nginx-service
  kubectl delete deployment nginx-deployment
  kubectl get deployments

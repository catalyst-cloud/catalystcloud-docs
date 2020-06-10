#######
Logging
#######

.. _kubernetes-logging:

This section is aims to provide guidance around what logging solutions are
available to be used in conjunction with a kubernetes cluster and it's
applications.


*******************
Centralised logging
*******************

Given the nature of today's multi-cloud, distributed working it can be a
challenge for the people involved in running, deploying and maintaining cloud
based systems. Part of this challenge is the need to aggregate various metrics,
across a wide range of sources and presenting these in a
'single pane of glass'.

One of the key data sources that typically need to managed in this way is log
data. Whether this is system or application generated it is always desirable to
be able to forward all of these log output to specialised systems such as
Elasticsearch, Kibana or Grafana which can handle the display, searchability
and analysis of the received log data.

It is the role of the log collectors such as Fluentd or Logstash to forward
these logs from their origins on to the chosen analysis tools.


*******
Fluentd
*******

`Fluentd`_ is a `Cloud Native Computing Foundation (CNCF)`_ open source data
collector aimed at providing a unified logging layer with a pluggable
architecture.

.. _`Fluentd`: https://www.fluentd.org
.. _`Cloud Native Computing Foundation (CNCF)`: https://cncf.io/

It attempts to structure all data as JSON in order to unify the collecting,
filtering, buffering and outputting of log data from multiple sources and
destinations.

Pluggable architecture
======================

The flexible nature of the Fluentd plugin system allows users to make better
use of their log data in a much easier way through the use of the 500+
community created plugins that provide a wide range of supported `data source`_
and `data output`_ options.

.. _`data source`: https://www.fluentd.org/datasources
.. _`data output`: https://www.fluentd.org/dataoutputs

Shipping logs to an AWS S3 bucket
=================================

In this example we will look at adding a Fluentd daemonset to our cluster so
that we can export the logs to a central S3 bucket, this in turn means that our
log data can be made available to any downstream analysis tools that we desire.

The following are the configuration details that will be used in this example
and these would need to be modified to fit your own personal circumstances.

For each example we will list the manifest file and the command required to
deploy it.

* cluster namespace : fluentdlogging
* AWS S3 bucket name : fluentlogs-cc
* AWS S3 bucket prefix : myapp
* AWS access key id: '<AWS_ACCESS_KEY>'
* AWS secret access key: '<AWS_SECRET_ACCESS_KEY>'

First we need to create the namespace to deploy our fluentd application into
along with a service account and the appropriate cluster role that can access
pods and namespaces.

.. literalinclude:: _containers_assets/fluentd-s3-rbac.yml

.. code-block:: bash

    $ kubectl apply -f fluentd-s3-rbac.yml
    namespace/fluentdlogging created
    serviceaccount/fluentd created
    clusterrole.rbac.authorization.k8s.io/fluentd created
    clusterrolebinding.rbac.authorization.k8s.io/fluentd created

The next part is the configmap that will hold the configuration for the
`Fluentd S3 plugin`_. There are extra parameters outlined in the documentation
and in our example we have modified the following:

* **path**: which defines the prefix that will be used for the S3 bucket we
  are uploading to.
* **timekey**: The delay for the output frequency, which we have dropped to 5
  minutes for the purpose of testing.


.. _`Fluentd S3 plugin`: https://github.com/fluent/fluent-plugin-s3

.. literalinclude:: _containers_assets/fluentd-s3-configmap.yml
    :emphasize-lines: 26,35

.. code-block:: bash

    $ kubectl apply -f fluentd-s3-configmap.yml
    configmap/fluentd-configmap created

This file allows us to store our AWS credentials in a secret.

.. literalinclude:: _containers_assets/fluentd-s3-secrets.yml

.. code-block:: bash

    $ kubectl apply -f fluentd-s3-secrets.yml
    secret/aws-secret-fluentd created

Finally, we create a daemonset to run the flunetd nodes. This will create one
pod per worker node.

The config for the flunetd container specifies, via the use of environment
variables, the necessary S3 parameters. It also loads the previously supplied
config map though a volume mount.

.. literalinclude:: _containers_assets/fluentd-s3-daemonset.yml

.. code-block:: bash

    $ kubectl apply -f fluentd-s3-daemonset.yml
    daemonset.extensions/fluentd created

Once the full configuration is deployed we can check to see that the flunentd
pods are online.

.. code-block:: bash

    $ kubectl get pod -n fluentdlogging
    NAME            READY   STATUS    RESTARTS   AGE
    fluentd-9dgxb   1/1     Running   0          6m10s
    fluentd-jjq8m   1/1     Running   0          6m10s

Once they reach the **running** state we can query the pods to confirm that
the bucket was created.

.. code-block:: bash

    $ kubectl -n fluentdlogging logs fluentd-9dgxb | grep "Creating bucket"
    2020-05-18 01:37:35 +0000 [info]: #0 [out_s3] Creating bucket fluentdlogs-cc on

We can also validate this using the **awscli** tool and see that our S3 bucket
has been created.

.. code-block:: bash

    $ aws s3 ls
    2020-05-18 13:37:37 fluentdlogs-cc

To cleanup once you are finished run the following command.


.. code-block:: bash

    k delete -f fluentd-s3-rbac.yml \
    -f fluentd-s3-configmap.yml \
    -f fluentd-s3-secrets.yml \
    -f fluentd-s3-daemonset.yml

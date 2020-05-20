#######
Ingress
#######

****************
What is ingress?
****************

Ingress provides a means to give external users and client applications access
to HTTP services running in a Kubernetes cluster. It is not intended as a means
to expose arbitrary ports or protocols so services other than HTTP/HTTPS
would require a loadbalancer or NodePort.

The Ingress is made up of two main components:

* An **Ingress Resource**, which is the set of Layer 7 (L7) rules that define
  how inbound traffic can reach a service. It may be also provide some or all
  of the following:

  - Provide externally reachable URLs, including paths.
  - To load balance traffic.
  - Provide a means for TLS/SSL termination.

* The **Ingress Controller**, which acts on the rules set by the Ingress
  Resource, typically via an HTTP or L7 load balancer. It’s vital that both
  pieces are properly configured to route traffic from an outside client to a
  Kubernetes Service.


*************
Prerequisites
*************

As mention above, simply defining an ingress resource is not sufficient to
create an Ingress, it also requires an ingress controller. Catalyst Cloud
provides the native `` Octavia ingress controller`` though it also supports
other common controllers such as the **ingress-nginx** controller.

While all ingress controllers should fit the reference specification they do in
fact operate slightly differently and the relevant vendor documentation should
be consulted for details on the correct setup.

************************************
Using the Octavia ingress controller
************************************

In this example we will implement a minimal configuration to illustrate how to
setup ingress to a simple web application that is deployed with multiple
replicas.

For the test application we will use the Google Cloud echoserver

.. include:: _containers_assets/deployment-echoserver.yml


kubectl expose deployment echoserver-deployment --type=NodePort --target-port=8080 --port 80






using echoserver deployment as application


kubectl get service
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
echoserver-deployment   NodePort    10.254.108.34   <none>        80:30995/TCP   5m47s
kubernetes              ClusterIP   10.254.0.1      <none>        443/TCP        8d


We can test to see that the app is now exposed on the NodePort. As this is not
visible outside of the cluster we have to access a master node to confirm out
access.

add ssh inbound sec group rule on a master node, then

ssh -A ubuntu@$fip
ssh fedora@<masternode-ip>
curl http://<node-port-cluster-ip>

clustername=$(openstack coe cluster list -c name -f value)
project_id=$(openstack configuration show -c auth.project_id -f value)
auth_url=$(export | grep OS_AUTH_URL | awk -F'"' '{print $2}')
username=$(export | grep OS_USERNAME | awk -F'"' '{print $2}')
password=$(export | grep OS_PASSWORD | awk -F'"' '{print $2}')
public_net_id=$(openstack network list --external -c ID -f value)
subnet_id=$(openstack subnet list | grep $clustername | awk -F'\| ' '{ print $2 }')
region=$(export | grep OS_REGION_NAME | awk -F'"' '{print $2}')


echo $clustername $project_id $auth_url $username $password $public_net_id $subnet_id $region

fluentd-test
eac679e4896146e6827ce29d755fe289
https://api.nz-hlz-1.catalystcloud.io:5000/v3
glyndavies@catalyst.net.nz
puff properly admit grown flight align
f10ad6de-a26d-4c29-8c64-2a7418d47f8f
6ddad590-3a57-4fd1-990b-be067e3f657d
nz-hlz-1

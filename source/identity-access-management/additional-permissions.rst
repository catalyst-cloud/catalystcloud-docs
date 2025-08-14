#########################################
Additional management methods
#########################################

The following section details additional ways that you can restrict or allow
user access to resources on your project. The sections below do not directly
make use of the **roles** we have discussed so far and instead focus on
access or permissions that are provided to users or applications by some
other means.

***************************************
Ownership permission of new resources
***************************************

When creating certain objects on the cloud, access is sometimes limited to the
individual who initially created the object. This is because when the user
creates the object they are assigned the equivalent **root** or **admin** level
rights for that object. This is not a common occurrence for most of the
resources on the cloud, but it is relevant for the following examples.

Cloud server access
===================

This behavior is observed when creating a new cloud instance. It is a
best practice in cloud computing for user access to be restricted to
authentication using public/private keypairs which allows for access via
passwords to be disabled by default for greater security.

When a new compute instance is launched you supply the public part of an SSH
key, that you have access to, as one of the launch parameters, this is then
added the the **.ssh/authorized_keys** file for the default user of the OS
that you are deploying.

For example:

On an Ubuntu based compute instance you would log in as the user *ubuntu* using
the SSH key that corresponds to the public key information you provided at
instance creation time.

In order to give additional users access to this instance you would need to do
one of the following:

* As the user with access you add new users within the OS itself using the
  appropriate tools for that OS.
* Alternatively you can add further public SH keys to the **authorized_keys**
  giving the new users access to the instance via the existing default user.
  While this might seem like a convenient approach it does mean you sacrifice
  the ability to audit access to that server.

**************************************
Restricting access without using roles
**************************************

The following are ways in which you can restrict access for individuals and/or
applications to different objects or resources in your project, without
needing to use pre-defined roles or when access is anonymous and the use of a
role is not feasible.

Object storage
==============

For object storage, you can make use of *container access control lists* (ACLs)
to allow users who have the "auth_only" role to be able to view or edit the
contents of your object storage containers. You can find the full details of
permissions and restrictions you can set on your containers in the
`OpenStack Swift documentation`_

.. _`OpenStack Swift documentation`: https://docs.openstack.org/swift/latest/overview_acl.html

In addition to using ACLs to restrict or permit access to your object storage
containers, you also have the option of making your containers public or giving
them temporary URLs to allow access for a limited time. The processes for these
can be found in the :ref:`object storage<object-storage-access>` section of
this documentation.

Instances and clusters
======================

Another method of access control, that affects instances and clusters, is
security groups. These are used to define what traffic is able to pass into or
out of your instances. The full description of security groups and how they
function can be found in the :ref:`network section<security-groups>` of the
documentation.

************************************
Securing workloads behind Cloudflare
************************************

While Cloudflare does a great job at hiding the identity of your cloud
resources from the casual observer it has to be made clear that it is possible
with some effort, for less scrupulous individuals to obtain this information.
With that in mind we will outline here, at a high level, some further actions
that can be taken to tighten up your access controls and help minimise your
exposure to bad actors.

The intention here is to enable a set of security group rules that will only
allow inbound traffic from the known list of published Cloudflare IP addresses.
These rules should be added to a single security group and then this, in turn
is applied to each of the public facing compute resources you wish to lock down.

The following steps are a basic outline of the process/setup required to
implement these access restrictions.

* The script example included below needs to be run on a server that has access
  to both the Internet and the Catalyst Cloud API endpoints.
* The script needs a method of authentication. This could be:
  - a user sourcing their openrc file prior to running the script manually.
  - using a `clouds.yaml`_ file to provide the required authentication details.

* The security group in question ideally needs to exist in advance and be
  applied to all hosts for which the rules should apply.
* The script example does not cater to the fact that IP address ranges may be
  retired from the CF IPv4 list.

..  _`clouds.yaml`: https://docs.openstack.org/python-openstackclient/pike/configuration/index.html

The following script is an example script for the creation of a security group
and security group rules for each entry in the Cloud Flare IPv4 address list
file.

Currently this is only adding a rule allowing ingress traffic to port 80 from
each of the CF address ranges. To expand on this simply add more "openstack
security group rule" entries to account for each required port.

.. code-block:: bash

  #!/usr/bin/env bash

  SECURITY_GROUP="cf_rules"

  # check if CF IP file available and exit if not
  export EXIT_CODE=$(curl -o /dev/null --silent -Iw '%{http_code}' https://www.cloudflare.com/ips-v4)

  if [ ${EXIT_CODE} != 200 ] ; then
    echo "Could not retrieve CF IP address list"
    exit 1
  fi

  # check if security group exists and create if not
  # exit on failure
  openstack security group show ${SECURITY_GROUP} > /dev/null 2>&1

  if [ $? != 0 ]; then
    echo "Security group :  ${SECURITY_GROUP} does not exist, creating now..."
    response=$(openstack security group create ${SECURITY_GROUP})
    if [[ "Error" == *${response}* ]]; then
      echo -e "\n\nThere was an unexpected problem creating the security group, please investigate\n"
      exit 66
    fi
  fi

  # for each address in the CF ips-v4 file add a security group rule
  for ip in $(curl -s https://www.cloudflare.com/ips-v4);
  do

    openstack security group rule create --remote-ip ${ip} --dst-port 80 --protocol tcp --ingress ${SECURITY_GROUP}

  done

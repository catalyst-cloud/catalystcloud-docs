###############################################
Set up a puppet master and clients with ansible
###############################################

This tutorial will show you how to combine `Ansible`_ and `Puppet`_ to manage a
dynamic set of servers on the Catalyst Cloud. This way you get the beautifully
simple orchestration of Ansible, combined with the vast library of modules
available with Puppet.

.. _Ansible: https://www.ansible.com/
.. _Puppet: https://puppet.com/

You will need:

-  The OpenStack command line tools, and will have sourced an OpenStack RC
   file, as explained at :ref:`command-line-interface`
-  A basic understanding of how to use Ansible, and ideally have done the other
   Ansible tutorials first.
-  A good enough understanding of Puppet that you know why you're following
   this tutorial.

If you follow this guide you will:

-  See how to setup a Puppet Master using Ansible
-  Drive provisioning of OpenStack and Puppet from Ansible
-  Define new server roles and roll these out quickly in your project
-  Use the above to have an "immutable infrastructure"

************************
Setup your puppet master
************************

We'll start by checking out the project skeleton and setting up some vars
specific to your local setup.

.. code-block:: bash

    $ git clone https://github.com/catalyst/catalystcloud-ansible
    $ cd catalystcloud-ansible/example-playbooks/puppet-master

    # substitute my-keypair-name for whatever you have set up in your project
    echo 'keypair_name: my-keypair-name' > local-vars.yml
    openstack ip floating list # grab one of these and store it in PUBLIC_IP...
    export PUBLIC_IP=150.x.y.z
    echo "public_ip: ${PUBLIC_IP}" >> local-vars.yml
    # option 1: restrict ssh access to your public ip
    echo "remote_access_cidr: `curl -4 my.ip.fi`/32" >> local-vars.yml
    # option 2: no restriction on ssh access to your public ip
    echo "remote_access_cidr: 0.0.0.0/0" >> local-vars.yml
    # optional: set this to prefix openstack resources with a token, eg your
    # username
    echo "namespace: linda-" >> local-vars.yml

    # NB: This option stores your OS_PASSWORD in plaintext on the Puppet Master
    # with 0440 permissions.
    # If you're not comfortable storing your credentials in here, you can create an
    # account at https://dashboard.cloud.catalyst.net.nz/management/project_users/
    # and give it the project member role. Then use these credentials for the
    # remainder of this project.
    echo "ansible_store_os_password: yes" >> local-vars.yml

Now we're ready to create the Puppet Master, but first we'll check out some of
the interesting parts of the create-puppetmaster playbook.

We set up Puppet to run on demand, and never in the background.

.. code-block:: yaml

      # We run Puppet on demand via Ansible, so disable the agent daemon...
      - name: Disable puppet agent
        service: name=puppet state=stopped

      # NB Our Puppet conf forbids the agent from daemonising
      - name: Create puppet.conf
        template: src=templates/puppet.conf.j2 dest=/etc/puppet/puppet.conf
                  owner=root group=root mode=0644
        notify: restart puppetmaster

      # Let Puppet agent run again
      - name: Enable puppet agent
        shell: puppet agent --enable
        become: yes

We also copy our local modules directory into the Puppet Master's module-path.
For now, there is very little in there other than an empty manifest for
``roles::puppetmaster``, but this is where you could keep your army of Puppet
modules for whatever.

.. code-block:: yaml

    # using copy is incredibly slow for large sets of files, so we tar it up from
    # local before extracting it in /etc/puppet

     - name: Create tar
       delegate_to: localhost
       shell: echo $PWD ; tar -czf /tmp/puppet-modules.tar.gz modules
       args: chdir=./

     - name: Extract puppet manifests
       unarchive: dest=/etc/puppet src=/tmp/puppet-modules.tar.gz copy=yes
       become: yes

We also have a very crude external node classifier. It uses a property that
each server is created with to decide which top-level Puppet class to apply:

.. code-block:: bash

    #! /usr/bin/env bash
    # Return back 'yaml' including scraped role property as profile

    . /etc/openstack.rc

    ROLE=`openstack server show $1 -f json | jq .properties | ruby -e "puts /role='([^.]+)'/.match(STDIN.read)[1]"`
    echo "classes: ['roles::$ROLE']"

The script pulls the role property from the instance's metadata and
interpolates that into the ENC response, where a role of ``foo`` wants to
include the ``roles::foo`` manifest.

OK, let's run the play...

.. code-block:: bash

    $ export ANSIBLE_HOST_KEY_CHECKING=false # disables ssh host key checks
    $ ansible-playbook -e'@local-vars.yml'  create-puppetmaster.yml

Assuming everything worked, you can now log in to your new box:

.. code-block:: bash

    $ export SSH_CMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=false ubuntu@$PUBLIC_IP"
    $ $SSH_CMD
    # and you should see...
    ubuntu@puppetmaster:~$
    # Try some things...
    $ (. /etc/openstack.rc && openstack server show `hostname`) # shows our own host details
    $ /etc/puppet/enc.sh `hostname` # what roles does our enc give us
    $ sudo puppet agent --test
    # leave this window open for now

Let's update our Puppet manifests and update the controller:

.. code-block:: bash

    # Let's generate some entropy!
    $ echo 'class roles::puppetmaster { package { "haveged": } }' > modules/roles/manifests/puppetmaster.pp
    # This play reuses tasks from the create play to update manifests, then apply Puppet
    $ ansible-playbook -e '@local-vars.yml' -e local_apply=true update-puppetmaster.yml

OK, take a deep breath and get ready for part two - creating some hosts!

*****************
Create some hosts
*****************

In this step, you are going to quickly add two hosts and provision them with
your Puppet Master. In your working copy, run:

.. code-block:: bash


    # define a couple of server roles, push them to the Puppet Master
    # In the real world, you'd probably do a lot more than just install a webserver
    # package
    $ echo 'class roles::webserver { package { 'nginx': } }' > modules/roles/manifests/webserver.pp
    $ echo 'class roles::dbserver { package { 'postgresql': } }' > modules/roles/manifests/dbserver.pp
    $ ansible-playbook -e '@local-vars.yml' update-puppetmaster.yml

Now switch to the Puppet Master and run:

.. code-block:: bash

    $ cd /opt/ansible
    $ . /etc/openstack.rc
    $ export ANSIBLE_HOST_KEY_CHECKING=false
    # change keypair_name to be something unique, perhaps the hostname including namespace
    $ ansible-playbook -e @local-vars.yml -e keypair_name=puppetmaster \
      -e newhost_role=webserver -e newhost_name=web1 \
      create-host.yml

    $ ssh web1 dpkg -l nginx # prints out nginx package information

    $ ansible-playbook -e @local-vars.yml -e keypair_name=puppetmaster \
      -e newhost_role=dbserver -e newhost_name=db1 \
      create-host.yml

    $ ssh db1 dpkg -l postgresql # prints out postgres package information

If you take a look at the create-host play, it does the fiddly work of signing
certificate requests for your servers, adds a host entry to the Puppet Master's
``/etc/hosts`` and then runs Puppet for you.

As an exercise, let's do the reverse - create a play for removing a
server.

.. code-block:: yaml

    ---
    - name: Remove a server from our project
      hosts: localhost
      tasks:

        - name: Delete the openstack server instance
          os_server: name="{{ oldhost_name }}" state=absent

        - name: Remove traces of the server from puppetmaster
          include: tasks/clean-previous-host-info.yml hostname="{{ oldhost_name }}"

Save this file as ``/opt/ansible/delete-host.yml`` and give it a whirl...

.. code-block:: bash


    $ ansible-playbook -e @local-vars.yml -e oldhost_name=db1 delete-host.yml

    $ openstack server list # it's gone!

    $ ansible-playbook -e @local-vars.yml -e keypair_name=puppetmaster \
      -e oldhost_name=web1 delete-host.yml

You can add and remove servers now at will. Don't bother upgrading your servers
anymore - just delete and create and never let your servers drift.

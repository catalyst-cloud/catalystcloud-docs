.. _packer-tutorial:

##################################################################
Using Packer to build custom bootable images on the Catalyst Cloud
##################################################################

This tutorial shows you how to use `Packer`_ to build custom bootable images on
the Catalyst Cloud. Packer is an open source tool developed by `Hashicorp`_ for
creating machine images for multiple platforms from a single source
configuration.

Packer makes use of builders and provisioners to create custom bootable
images.

********
Builders
********

Packer supports a number of `builders`_ for different target platforms
including Amazon EC2 AMI images, VirtualBox and VMware. When building images
for the Catalyst Cloud you will be using the `OpenStack builder`_.

************
Provisioners
************

`Provisioners`_ provide a way to configure a base image such that a new custom
image can be created. Many provisioners are available, including shell
provisioners and provisioners that use DevOps tools like Ansible, Puppet and
Chef.

*****
Setup
*****

This tutorial assumes that you have sourced an openrc file, as described at
:ref:`source-rc-file`. This is required in order for the `OpenStack builder`_
to interact with the Catalyst Cloud image service.

You will also need an appropriate security group to allow SSH access for the
temporary build machine that Packer will create.

Next you need to install Packer. Packer is a single go binary, so this is a
simple process:

.. code-block:: console

 $ wget https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip
 $ unzip packer_0.10.1_linux_amd64.zip
 $ ./packer --version
 0.10.1

*****************************
Create a Packer template file
*****************************

`Templates`_ are JSON files that configure the builders and provisioners that
you will use to create our custom image.

In this example, you will create a basic template that can be invoked with the
``packer build`` command. It will create an instance in the Catalyst cloud, and
once the instance is running, copy a script to it and run the script using SSH.
Once the script has finished running, it will create a new Catalyst Cloud image
that includes the changes you have made. Once this process is complete, it will
clean up after itself so that only the new image remains.

In this example, you will be using the shell provisioner to update the packages
on an Ubuntu 16.04 machine to the latest versions. You will then build a
`golang`_ application called `ssllabs-scan`_ from source.

.. code-block:: json

 {
   "builders": [{
     "type": "openstack",
     "ssh_username": "ubuntu",
     "image_name": "ubuntu1604_packer_test_1",
     "source_image": "49fb1409-c88e-4750-a394-xxxxxxxxxxxx",
     "flavor": "c1.c1r1",
     "security_groups": ["example-sg"],
     "floating_ip_pool": "public-net"
   }],
   "provisioners": [{
     "type": "shell",
     "inline": [
       "sleep 30",
       "sudo apt-get update",
       "sudo apt-get upgrade -y",
       "sudo apt-get install -y golang-go make",
       "git clone https://github.com/ssllabs/ssllabs-scan",
       "cd /home/ubuntu/ssllabs-scan/",
       "make"
     ]
   }]
 }

*****************
Building an image
*****************

Now you can build a new image called ``ubuntu1604_packer_test_1`` using this
template:

.. code-block:: console

 $ ./packer build domain-check-packer.json
 openstack output will be in this colour.

 ==> openstack: Discovering enabled extensions...
 ==> openstack: Loading flavor: c1.c1r1
     openstack: Verified flavor. ID: 28153197-6690-4485-9dbc-xxxxxxxxxxxx
 ==> openstack: Creating temporary keypair: packer 57c659c0-081a-3bef-2bdb-xxxxxxxxxxxx ...
 ==> openstack: Created temporary keypair: packer 57c659c0-081a-3bef-2bdb-xxxxxxxxxxxx
 ==> openstack: Launching server...
     openstack: Server ID: e9655fb3-e239-4f4b-80e3-xxxxxxxxxxxx
 ==> openstack: Waiting for server to become ready...
 ==> openstack: Creating floating IP...
     openstack: Pool: public-net
     openstack: Created floating IP: 150.242.41.201
 ==> openstack: Associating floating IP with server...
     openstack: IP: 150.242.41.201
     openstack: Added floating IP 150.242.41.201 to instance!
 ==> openstack: Waiting for SSH to become available...
 ==> openstack: Connected to SSH!
 ==> openstack: Provisioning with shell script: /tmp/packer-shell905865588
     openstack: sudo: unable to resolve host ubuntu1604-domain-check-packer
     openstack: Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [94.5 kB]

 ... Much truncation of apt output

     openstack: Setting up golang-1.6-src (1.6.2-0ubuntu5~16.04) ...
     openstack: Setting up golang-1.6-go (1.6.2-0ubuntu5~16.04) ...
     openstack: Setting up golang-src (2:1.6-1ubuntu4) ...
     openstack: Setting up golang-go (2:1.6-1ubuntu4) ...
     openstack: Setting up libalgorithm-diff-perl (1.19.03-1) ...
     openstack: Setting up libalgorithm-diff-xs-perl (0.04-4build1) ...
     openstack: Setting up libalgorithm-merge-perl (0.08-3) ...
     openstack: Setting up libfile-fcntllock-perl (0.22-3) ...
     openstack: Setting up manpages-dev (4.04-2) ...
     openstack: Setting up pkg-config (0.29.1-0ubuntu1) ...
     openstack: Setting up golang-1.6-race-detector-runtime (0.0+svn252922-0ubuntu1) ...
     openstack: Setting up golang-race-detector-runtime (2:1.6-1ubuntu4) ...
     openstack: Processing triggers for libc-bin (2.23-0ubuntu3) ...
     openstack: Cloning into 'ssllabs-scan'...
     openstack: go build ssllabs-scan.go
 ==> openstack: Stopping server: e9655fb3-e239-4f4b-80e3-xxxxxxxxxxxx ...
     openstack: Waiting for server to stop: e9655fb3-e239-4f4b-80e3-xxxxxxxxxxxx ...
 ==> openstack: Creating the image: ubuntu1604_domain_check_packer
     openstack: Image: e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx
 ==> openstack: Waiting for image ubuntu1604_domain_check_packer (image id: e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx) to become ready...
 ==> openstack: Deleted temporary floating IP 150.242.41.201
 ==> openstack: Terminating the source server: e9655fb3-e239-4f4b-80e3-xxxxxxxxxxxx ...
 ==> openstack: Deleting temporary keypair: packer 57c659c0-081a-3bef-2bdb-xxxxxxxxxxxx ...
 Build 'openstack' finished.

 ==> Builds finished. The artefacts of successful builds are:
 --> openstack: An image was created: e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx

.. note::

 The process of building a new image takes some time, so now would be a good time to make a cup of tea.

****************
Booting an image
****************

Once the packer build command is complete, your newly build image should be
available:

.. code-block:: console

 $ openstack image show e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx
 +------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | Field            | Value                                                                                                                                                                                         |
 +------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | checksum         | 1abfc6cac5c989e5xxxxxx1fe0effbde                                                                                                                                                              |
 | container_format | bare                                                                                                                                                                                          |
 | created_at       | 2016-08-31T04:21:14Z                                                                                                                                                                          |
 | disk_format      | raw                                                                                                                                                                                           |
 | file             | /v2/images/e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx/file                                                                                                                                          |
 | id               | e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx                                                                                                                                                          |
 | min_disk         | 10                                                                                                                                                                                            |
 | min_ram          | 1                                                                                                                                                                                             |
 | name             | ubuntu1604_domain_check_packer                                                                                                                                                                |
 | owner            | 0cb6b9b744594a619bxxxxxxf424858b                                                                                                                                                              |
 | properties       | base_image_ref='49fb1409-c88e-4750-a394-xxxxxxxxxxxx', direct_url='rbd://b0849a66-357e-4428-a84c-xxxxxxxxxxxx/images/e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx/snap', image_location='snapshot',   |
 |                  | image_state='available', image_type='image', instance_uuid='e9655fb3-e239-4f4b-80e3-xxxxxxxxxxxx', kernel_id='None', owner_id='0cb6b9b744594a619bxxxxxxf424858b', ramdisk_id='None',          |
 |                  | user_id='8c1914eda99d406195xxxxxxf2846d45'                                                                                                                                                    |
 | protected        | False                                                                                                                                                                                         |
 | schema           | /v2/schemas/image                                                                                                                                                                             |
 | size             | 10737418240                                                                                                                                                                                   |
 | status           | active                                                                                                                                                                                        |
 | tags             |                                                                                                                                                                                               |
 | updated_at       | 2016-08-31T04:34:21Z                                                                                                                                                                          |
 | virtual_size     | None                                                                                                                                                                                          |
 | visibility       | private                                                                                                                                                                                       |
 +------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Boot this image and verify you can invoke the `ssllabs-scan`_ application
you installed in the image:

.. code-block:: console

 $ openstack server create --flavor c1.c1r1 --image e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx --key-name example-key \
 --security-group default --security-group example-sg --nic net-id=097a6779-ca20-4017-913e-xxxxxxxxxxxx ssl-scan
 +--------------------------------------+-----------------------------------------------------------------------+
 | Field                                | Value                                                                 |
 +--------------------------------------+-----------------------------------------------------------------------+
 | OS-DCF:diskConfig                    | MANUAL                                                                |
 | OS-EXT-AZ:availability_zone          |                                                                       |
 | OS-EXT-STS:power_state               | NOSTATE                                                               |
 | OS-EXT-STS:task_state                | scheduling                                                            |
 | OS-EXT-STS:vm_state                  | building                                                              |
 | OS-SRV-USG:launched_at               | None                                                                  |
 | OS-SRV-USG:terminated_at             | None                                                                  |
 | accessIPv4                           |                                                                       |
 | accessIPv6                           |                                                                       |
 | addresses                            |                                                                       |
 | adminPass                            | XXXXXXXXXXXXXXX                                                       |
 | config_drive                         |                                                                       |
 | created                              | 2016-08-31T04:50:36Z                                                  |
 | flavor                               | c1.c1r1 (28153197-6690-4485-9dbc-xxxxxxxxxxxx)                        |
 | hostId                               |                                                                       |
 | id                                   | 79d4e503-205d-4c40-a7d1-xxxxxxxxxxxx                                  |
 | image                                | ubuntu1604_domain_check_packer (e81c38a0-6fbf-4f62-b873-xxxxxxxxxxxx) |
 | key_name                             | example-key                                                           |
 | name                                 | ssl-scan                                                              |
 | os-extended-volumes:volumes_attached | []                                                                    |
 | progress                             | 0                                                                     |
 | project_id                           | 0cb6b9b744594a619bxxxxxxf424858b                                      |
 | properties                           |                                                                       |
 | security_groups                      | [{u'name': u'default'}, {u'name': u'example-sg'}]                     |
 | status                               | BUILD                                                                 |
 | updated                              | 2016-08-31T04:50:36Z                                                  |
 | user_id                              | 8c1914eda99d406195xxxxxxf2846d45                                      |
 +--------------------------------------+-----------------------------------------------------------------------+
 $ openstack floating ip list
 +--------------------------------------+---------------------+------------------+--------------------------------------+
 | ID                                   | Floating IP Address | Fixed IP Address | Port                                 |
 +--------------------------------------+---------------------+------------------+--------------------------------------+
 | a316c6b9-80ba-46ec-9b0a-xxxxxxxxxxxx | 150.242.43.231      | None             | None                                 |
 +--------------------------------------+---------------------+------------------+--------------------------------------+
 $ openstack server add floating ip ssl-scan 150.242.43.231
 $ ssh ubuntu@150.242.43.231
 The authenticity of host '150.242.43.231 (150.242.43.231)' can't be established.
 ECDSA key fingerprint is 47:db:dc:21:14:d1:ea:03:52:70:0c:2f:6d:a6:82:74.
 Are you sure you want to continue connecting (yes/no)? yes
 Warning: Permanently added '150.242.43.231' (ECDSA) to the list of known hosts.
 Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-31-generic x86_64)

  * Documentation:  https://help.ubuntu.com
  * Management:     https://landscape.canonical.com
  * Support:        https://ubuntu.com/advantage

   Get cloud support with Ubuntu Advantage Cloud Guest:
     http://www.ubuntu.com/business/services/cloud

 9 packages can be updated.
 7 updates are security updates.


 ubuntu@ssl-scan:~$ ls
 ssllabs-scan
 ubuntu@ssl-scan:~$ ssllabs-scan/ssllabs-scan -version
 ssllabs-scan v1.3.0 (stable $Id: 81cb03888c46dd07fb4d97acffa6768b692efa49 $)
 API location: https://api.ssllabs.com/api/v2

***********************************************
Using Packer with Windows on the Catalyst Cloud
***********************************************

.. note::

  At this time, due to a known issue in the Catalyst Cloud, it is not possible
  to deploy a Windows image using Packer directly from the publicly available
  Windows image.

  In order to overcome this limitation, it is necessary to deploy a new
  temporary Windows instance in the Catalyst Cloud. When launching this
  instance, you need to say Yes to ``Create New Volume`` when selecting
  the ``Instance Source``.

  Once the image has booted successfully, take a snapshot of it. This new
  snapshot can now be used as the source image for your Packer build. It is
  not necessary to keep the temporary Windows instance once the snapshot has
  been successfully taken.


It is possible to use Packer to create custom Windows images. This requires
some changes in approach as the tools and connection details are those typical
of Windows technologies.

The first change is in the ``builders`` section of the packer build file. Here
you need to add the settings to specify the connection type and the credentials
to use on this connection.

Below is an example of the new communicator settings. These make use of the
Windows Remote Management feature. This uses the WS-Management Protocol, which
is based on SOAP (Simple Object Access Protocol).

.. code-block:: bash

    "builders": [{
        ...

        "communicator": "winrm",
        "winrm_username": "Administrator",
        "winrm_password": "uUteQ419EPFUMoE4zaTE",

        ...
    }],


Setting ``"communicator"`` to ``"winrm"`` is mandatory in order for this to
work as expected. The username is required, but it does not have to be
``Administrator``, though for a Windows instance it makes sense to have a known
administration account.

The other important change is the creation of a ``userdata`` script that is run
by the builders section of the build file. The purpose of this userdata
section is to configure the WinRM access and define the user so that Packer is
able to connect to the instance once it has been created.

The reference to the userdata script needs to be added to the builders section
and provide the location of the script that needs to be run.

.. code-block:: bash

    "builders": [{
        ...

        "user_data_file": "./userdata_setup.ps1",

        ...
    }],

The userdata itself is a Windows command-line/PowerShell script that configures
various settings required to allow remote connectivity via WinRM.

.. code-block:: console

    #ps1_sysnative
    wmic UserAccount set PasswordExpires=False
    net user Administrator uUteQ419EPFUMoE4zaTE
    cmd /C netsh advfirewall set allprofiles state off
    winrm quickconfig -q
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="500"}'
    winrm set winrm/config '@{MaxTimeoutms="1800000"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    net stop winrm
    net start winrm

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

.. warning::

  The userdata script disables the Windows firewall and also sets the
  Administrator password using plain text, which means it could be recovered
  from the file system.

  These two points present a huge risk and should both be addressed to prevent
  any subsequent compromise of security.

Once the userdata file has been created and the Packer build file edited
accordingly, simply run the Packer build command as discussed above.

.. code-block:: console

  $ ./packer build windows-build-file.json


.. _Packer: https://www.packer.io/
.. _Hashicorp: https://www.hashicorp.com/
.. _builders: https://www.packer.io/docs/templates/builders.html
.. _Provisioners: https://www.packer.io/docs/templates/provisioners.html
.. _Openstack builder: https://www.packer.io/docs/builders/openstack.html
.. _Templates: https://www.packer.io/docs/templates/introduction.html
.. _ssllabs-scan: https://github.com/ssllabs/ssllabs-scan
.. _golang: https://golang.org/

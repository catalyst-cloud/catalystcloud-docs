.. index::
   single: Duplicati
   single: Client Software; Duplicati

.. _duplicati:

*********
Duplicati
*********

Duplicati is a backup tool for MS Windows, MacOS and Linux. It is available
from: https://www.duplicati.com/. It can be configured to work with Catalyst
Cloud's object storage service by following the steps below.

Prerequisites
=============

The following is a list of prerequisites that you will need to have before
you can begin configuring Duplicati to work with our object storage service.

- You already have an object storage container ready to receive and store your
  backup data.

- You have a user account that is able to interact with the object storage
  service. (For purposes like backups we recommend that you use a dedicated
  user that only has the *object storage role* for permissions)

Configuration steps
===================

Once you have your prerequisites sorted, you can follow these steps to get your
Duplicati backups sent to your object storage container:

#. Use Menu -> Add Backup.

#. Ensure 'Configure a new backup' is selected, go Next.

#. Configure General backup settings. It is a good idea to use encryption for
   you backups, but it isn't required.

#. Configure Backup Destination:

   #. Storage Type: Select: Backup Object Storage / Swift
   #. Bucket name: [Enter the name of your container]
   #. OpenStack AuthURI: Select an identity API URL from :ref:`apis`.  If you
      are using single region replication, please select the identity API URL
      for the region your container is within.
   #. Keystone API version: Select: v3
   #. Domain Name: Enter: "default"
   #. Username & Password: The account credentials you would like to use.
   #. Tenant Name: [Enter the project name where your container is]

#. Source Data: Select the paths and/or files to backup.

#. Schedule: Set the desired schedule.

#. Options: You should be fine to leave the defaults.

Once this is complete you should see your backups start to appear in your
selected object storage container.

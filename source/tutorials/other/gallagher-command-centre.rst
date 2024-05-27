###########################################################
Gallagher Command Centre in Catalyst Cloud
###########################################################

********
Overview
********

Using Gallagher Command Centre is a fantastic way to manage access control and
monitoring across your building or buildings. Sometimes, however, you do not want
to have that Gallagher Command Centre running on-site with all the management
overhead, travel time or physical hardware maintenance that entails. In this guide,
we will show you how to install and run Gallagher Command Centre in Catalyst Cloud.

By the end of the guide, you should have a fully-installed Gallagher
Command Centre application running virtually in the cloud; meaning you will be
able to access, update and interact with that application from anywhere in the
world. For this guide, we have assumed that you already have an account with
Catalyst Cloud. If not, simply sign up `here!`_

.. _here!: https://catalystcloud.nz/signup/

=============
Prerequisites
=============

Before we get started, we need to make sure all of our networking is set up
in the correct region (Porirua). To check this, log onto the Catalyst Cloud
dashboard and navigate to the region tab.

Select nz-por-1 and check to make sure there is a router and network set up in this
region. If you have never used Catalyst Cloud before, you will need to set these up.
Do not worry, this should only take a few minutes and you can follow
`this step by step guide`_.

.. _this step by step guide: https://docs.catalystcloud.nz/network/adding-network.html

================================================
Creating an instance to house our command centre
================================================

Next, you will need to spin up a Windows VM in the cloud. There is a detailed “how to”
for this, which you can find here: :ref:`first-instance-windows`. To run Gallagher Command
Centre, you will need to simply make sure you are running the appropriate
version of Windows for your Gallagher installation, and that you select the right size for
your instance, as you will need to make sure you have enough CPU and RAM to run your
Gallagher application.

If you do need to increase the size of your VM as you have increased the amount of doors
the application manages, you will need to follow `this guide`_ to resizing your VM,
bearing in mind that the application will be offline during this resizing.

.. _this guide: https://docs.catalystcloud.nz/compute/resize-instance.html

================================================
Update and install Gallagher Command Centre.
================================================

Once you have everything in order you will need to do two things:

• Update your machine
• Download (or transfer) the Gallagher Command Centre application onto the VM.

To update your machine, simply search for “updates” in the setting and run all updates.
These can take a while for Windows to find and download and will require at least one
restart. We need to run these updates, however, as we will run into errors with the
Gallagher application if your version of windows is not up to date.

The good news is that, whilst Windows is updating, you can simultaneously download your
Gallagher installation package to the instance. You can do this simply by opening a web
browser in your instance and navigate to the Gallagher Security website, log in into your
account and downloading the packages. Alternatively, you can upload the installation
package to the instance using any other method.

Once the updates are completed, we can install the Gallagher Command Centre application.
With this completed, you are good to go with a Gallagher Command Centre application
running in the cloud! Now you can use the application exactly the same as you would
on a physical server.

Remember, you can still add users to the Windows Instance running in Catalyst Cloud just
as you would with any other Windows installation, as well as being able to add users to
Catalyst Cloud in order to grant other people or teams access to the server running
the Gallagher application.

For further reading, check out:

• :ref:`Some cloud best practices<best-practices>`
• :ref:`Interacting with the cloud<access_to_catalyst_cloud>`
• :ref:`Additional info and terminology guide<additional-info>`
• :ref:`More information on our dashboard<first-instance-with-dashboard>`
• :ref:`identity-access-management`


.. index::
   single: Surveillance Bridge from Tiger Surveillance
   single: Client Software; Surveillance Bridge from Tiger Surveillance

.. _Surveillance Bridge from Tiger Surveillance:

*******************************************
Surveillance Bridge from Tiger Surveillance
*******************************************

Introduction
============

Surveillance Bridge is a specialized software solution developed by Tiger Surveillance, a company focused on data
management and protection for video surveillance systems.

It serves as a hybrid cloud data management tool designed specifically for Video Management Systems (VMS) like
Milestone XProtect, Genetec Security Center, NX Witness and many others (over 15 validated platforms). The software
enables organizations to:

- Seamlessly connect on-premises local storage (e.g., drives where cameras record footage) to virtually any cloud
  storage provider and tier.
- Achieve effectively unlimited storage capacity for video recordings without needing massive local hardware
  expansions.
- Provide disaster recovery by replicating footage to the cloud.
- Automatically tier/archive older footage to cheaper storage (cloud or even tape libraries) based on retention
  policies, while keeping recent/active data locally for fast access and playback.
- Save significant costs (often up to 70–80% compared to expanding on-premises hardware) and meet long-term
  compliance/retention requirements.

Key technical aspects include:

- It installs as a lightweight NTFS/ReFS file system filter driver (quick to deploy, usually in minutes, with minimal
  disruption to existing setups).
- Recording and playback remain uninterrupted and high-performance because it uses an "on-premises-first" approach —
  active video stays local.
- It supports features like automated tape archiving, multi-site sync, and avoids vendor lock-in (data remains
  accessible).

Pre-Requisites
==============

To proceed with the setup steps below, some assumptions are made:

- Your chosen VMS solution is MS Windows® based and is already running. Tiger Surveillance Suite is a MS Windows®
  native software and you will need a local or remote host to use it.

- A new container has been created under Object Storage section. Follow these steps to configure:
  :doc:`../using-container`

- You have created a restricted user and have access and secret keys noted down.

  See: :doc:`../storage-access-control`

- You have purchased a license from Tiger Surveillance. With it you can download the software you need from:
  https://license.tiger-technology.com/

- You have downloaded and installed the Tiger Surveillance Suite as described in this document

  - For Milestone Sys deployments, see:
    https://tiger-surveillance.com/wp-content/uploads/2023/12/Surveillance-Bridge-Plug-In-Quick-Start-23Q2a.pdf

  - For any other VMS you may use these steps:
    https://nxvms.com/static/media/tiger-tech-surveillance-bridge/downloadableinstructions-546/Surveillance_Bridge\_-_License__Quick_Start_21Q3_-_Lance_K..pdf

    The difference here is:

    - Non-Milestone: Licensing and S3 bucket are set up using the Tiger Bridge Configuration tool and your VMS treats
      it as a local system storage/share option;
    - Milestone Sys: Licensing and S3 bucket are set up within the VMS via the Tiger Bridge plug-in.

The following setup steps assume that the Surveillance Bridge from Tiger Surveillance will be running in the same host
as the chosen VMS platform.

Installation
============

#. Download the Surveillance Bridge executable and manuals from the Tiger Technology licensing server:

   #. Go to: https://license.tiger-technology.com/ Use the username/password provided to you via email.

      .. note:: Confirm that the license is valid and activated.

   #. Once you have logged in, you might have to enter additional contact details
   #. To download the manuals, click on “Documentation” (bottom left)
   #. To download the executable, click on “Current Version” (bottom left)

#. Run the Surveillance Bridge installer as an administrator;
#. Click in the ‘License Terms and Conditions’ agreement box to accept, and then click Next;
#. Click ‘Install’ to continue the installation process;
#. The installation takes a couple of minutes to finish;
#. Click ‘Finish’ to close the installation screen. Surveillance Bridge is now installed and ready for configuration;
#. In order to access the configuration interface, run the application from your Windows Programs menu;
#. Click Yes to the user control Windows warning prompt that appears;
#. Select the type of license (SaaS is standard) and enter the username/password credentials listed above to activate
   Surveillance Bridge and click Connect;
#. You should see a confirmation of successful activation.

Surveillance Bridge is designed to replicate your camera data to the cloud. It can be used with virtually all VMS
software that runs on a Windows OS.

.. important:: Milestone XProtect is an exception. If you are using Milestone, you should consider Storage Bridge to
               ensure successful replication and Disaster Recovery.

Configuration
=============

First you will need to select a local source by clicking on the Add source button, on the bottom left:

#. Local Source: You must point Surveillance Bridge to one or more camera repositories. Note that a folder whose
   parent folder is already paired with a target cannot be used as a new source.
#. Select the folder you want to sync with the cloud or create a New Folder;
#. Click OK on the confirmation screen.
#. Next, select the target you want to replicate to. For Catalyst Cloud select the S3 Compatible type;
#. For a cloud target, enter your credentials then click on “List buckets”. Surveillance Bridge will display the
   buckets that are available on this account.

   .. important:: Make sure to choose a different bucket for every repository of every recording server.


   .. note:: If the bucket name is available, a selection dialog will open. Choose the operation you want to perform. If your
             bucket is empty, all options will yield to the same result.


   .. note:: If Tiger Bridge can't list the buckets, you can enter it manually, for example:
             `https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_<Project ID>`

#. Clicking OK will initiate the desired operation.
#. Configure the Settings tab according to your needs:

   .. note:: Event viewer logs – Any error and warning are automatically logged in the Event Viewer. In addition, you can
             choose to log successful operations of your choice.

#. Click “Apply” and select ‘Surveillance Bridge’ at the top, and then hit ‘Resume’ at the bottom to set
   Surveillance Bridge to Operational mode.

Congratulations! You have now successfully configured Surveillance Bridge. Seconds after they are closed by the VMS
software, camera data files from your source folder will automatically start replicating to the cloud.

From this point on, other options will be available to you such as using your Object Storage for storage extension or
disaster recovery purposes withing Tiger Surveillance.

Consult your security integrator or software vendor for more information on all the options and features your Tiger
Surveillance license offers.

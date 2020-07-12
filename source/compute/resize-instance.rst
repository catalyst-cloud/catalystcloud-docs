####################
Resizing an instance
####################


*********
Procedure
*********

The resize operation can be used to change the flavor (increase or decrease the
amount of CPU and RAM) of a compute instance.

.. warning::
  The resize operation causes a brief downtime of the compute instance, as the
  guest operating system will be restarted to pick up the new configuration. If
  you need to scale your application without downtime, consider scaling it
  horizontally (add/remove compute instances) as opposed to vertically
  (add/remove resources to an existing instance).

To resize a compute instance, go to the Instances panel on the dashboard and
locate the instance to be resized. On the Actions column, click on the downward
arrow to list more actions and then click on Resize Instance as shown below:

.. image:: ../_static/compute-resize-button.png
   :align: center

The resize dialogue will pop up, allowing you to chose a new flavor.

.. image:: ../_static/compute-resize-action.png
   :align: center

.. note::
  Before resizing down a compute instance, please consider if you need to
  change the configuration of your applications, so they can start up with less
  resources. For example: databases and Java virtual machines are often
  configured to allocate a certain amount of memory and will fail to start if not
  enough memory is available.

The status of the instance will change to preparing to resize or migrate,
resized or migrated and finally “Confirm or Revert Resize/Migrate” as shown
below:

.. image:: ../_static/compute-confirm-resize.png
   :align: center

Once the resize operation has been completed, our cloud will prompt you to
confirm or revert the resize operation. Click on confirm to finish the resize
operation.

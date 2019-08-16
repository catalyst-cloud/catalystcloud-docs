#############
Image service
#############

.. _images:

They are an 'image' of the
operating system while in a certain state. This is different to just a
copy of an operating system that is entirely blank; as an image can contain
file structure, software and other non-factory setting configuration on it.
For example, the catalyst Ubuntu18.04 image contains a version of Git
installed on it once it is started up. Other programs such as a base version
of python are also installed.

This allows you as a user to pick an image that most accurately resembles what
you are wanting to have for your instance, to save you time installing software
or setting up structures etc. You are also able to make your own
'snapshots' from instances that you run, that you can save and use as images
of your own in the future, this is discussed later in this section.


.. toctree::
   :maxdepth: 1

   images/Images-by-catalyst
   images/importing-vms
   images/converting-maching-image
   images/uploading-image
   images/launching-from-custom-image
   images/sharing-images
   images/FAQ

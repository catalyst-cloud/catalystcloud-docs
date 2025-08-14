######
Images
######

Images contain an operating system which can be cloned to a
:ref:`volume <block-storage-intro>` and used to boot a cloud
instance. These are different to just a base installation of an
operating system, as most of the images we provide include tooling called
cloud-init which retrieves configuration for both our cloud, and about the
specific instance that you are creating.

Having a wide range of images available will hopefully allow you to find one
that meets your requirments. If they don't you are always able to upload your
own images to use within your project(s). See :ref:`upload_images`.

You are able to take a 'snapshot' of an instance once you have customised it
and use that to start additional instances. This can simplify building a
solution (or complicate it!). See :ref:`using_snapshots`.

Once you have created a new instance from an image it is always a good idea to
perform an upgrade of the packages installed, and to continue to do this in an
on-going basis. It is part of
:ref:`the shared responsibility mode <shared_responsibility_model>` that you are
responsible for the security of the software within your instance(s).

We update on a regular basis the images we provide, which are still supported
by the providers. However these updates won't flow into your instances unless
you rebuild them using a new image as noted just above. As part of this process
we test them to ensure they are operating in a way that we expect.

.. toctree::
   :maxdepth: 1

   images/images-by-catalyst
   images/importing-vms
   images/converting-machine-image
   images/uploading-image
   images/launching-from-custom-image
   images/sharing-images
   images/downloading-image
   images/faq

#############
Image
#############

Images contain the information needed to install an operating system on a cloud
instance, with all of the correct dependencies and additional programs needed
to interact with the rest of the cloud infrastructure. These are different to
just a copy of an operating system that is entirely blank; as an image contains
a file structure, software and other non-factory setting configuration on it.
For example, the catalyst Ubuntu_18.04 image contains a version of Git
installed on it once it is started up. Other programs such as a base version
of python are also installed.

This allow you as a user to pick an image that most accurately
resembles what you are wanting to have for your instance. This also saves you having to install additional software or setting up file structures etc.
You are also able to make your own 'snapshots' from instances that you run,
which you can then save and use as images of your own in the future, this is
discussed later in this section.

Additionally, you are able to upload your own images to your project to save
time rebuilding any instances that you may have had previously. This is
discussed further in this section. For our default images, we ensure that they
are accurate to their upstream counterparts by downloading and validating them
using a checksum from their sources.

.. toctree::
   :maxdepth: 1

   images/images-by-catalyst
   images/importing-vms
   images/converting-machine-image
   images/uploading-image
   images/launching-from-custom-image
   images/sharing-images
   images/faq

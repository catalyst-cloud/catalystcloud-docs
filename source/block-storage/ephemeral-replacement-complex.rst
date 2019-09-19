###############################################
Adding a boot volume from an Ephemeral instance
###############################################


Or you can change the boot location on your instance to that of the new
persistent volume. Which means that the next time your instance turns on
(after shelving or rebooting etc.) it will now use the new persistent volume.

Steps to do this:

have your running Ephemeral instance
create a volume
attach the volume
partition and mount the volume
copy the Ephemeral data to the new volume using $ DD (Data description)

then change the blockID UUID of the volume you created using $ uuidgen

then update your boot/grub/grub.cnf where it details the device you boot from
replace the old uuid with the one for your new volume.

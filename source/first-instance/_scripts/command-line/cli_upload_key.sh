# The following code will upload your public key to the cloud
$ openstack keypair create --public-key ~/.ssh/id_rsa.pub first-instance-key
$ export CC_KEY_NAME=first-instance-key


.. _setting-up-local-connections:

################################################
Setting up SSH and Filezilla connections locally
################################################


********
Overview
********

This section provides step-by-step advice on setting up a connection
to your Catalyst Cloud instance from your local (client) machine.
After you have completed the steps you will be able to log
on to the server via SSH from anywhere on the internet using an SSH key.

This section assumes you are a relative "newbie", who may not have set 
up an SSH connection to a remote server before. You have a Catalyst Cloud 
account, and you're preparing to create your first instance.  You know
how to use the command line interface (terminal), but may not be very
experienced with it.

The steps required to establish an encrypted SSH connection are:

1. Install an configure OpenSSH
2. Create a Router
3. Upload an SSH keypair
4. Create a security group
5. Launch an instance
6. Associate a floating ip
7. Log in to your instance

********
About SSH Keys

OpenSSH provides several modes of authentication: password log-in, Kerberos 
tickets and Key-based authentication. Key-based authentication is the most 
secure method, and is therefore recommended. Other authentication methods are 
only used in specific situations (such as setting a password when creating a 
new instance). Ideally, password authentication should be disabled, once SSH 
Key-based authentication is working properly.

Generating a key pair provides you with two long string of characters: a “public key” and a “private key”. Anyone is allowed to see the public key, but only the owner is allowed to see the private key.
You can place the public key on any server, and then unlock it by connecting to it with a client that already has the private key. When the two match up, the system unlocks without the need for a password. 
You can increase security even more by protecting the private key with a passphrase.
SSH can use either "RSA" (Rivest-Shamir-Adleman) or "DSA" ("Digital Signature Algorithm") keys. DSA is known to be less secure, so RSA is recommended. This guide uses "RSA key" and "SSH key" interchangeably.

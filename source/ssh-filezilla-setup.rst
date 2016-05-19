.. _setting-up-local-connections:

################################################
Setting up SSH and Filezilla connections locally
################################################


********
Overview
********

This section provides step-by-step advice on setting up a connection
to your Catalyst Cloud instance from your local (client) machine.

Some of the steps are required before you create a new instance

After you have completed the steps you will be able to log
on to the server via SSH from your local machine, with an strongly
encrypted connection.

This section assumes You have a Catalyst Cloud account, and you're 
preparing to create your first instance.

This guide is verbose: it's written for a relative "newbie", who has not set 
up an SSH connection to a remote server before, but has some experience with
the command line interface (terminal).

The steps required to establish an encrypted SSH connection are:

1. Check that you have OpenSSH
2. Create an RSA Key Pair
3. Securely store the Key Pair and Passphrase
4. Upload the Public Key to a cloud server
5. Connect to the cloud server
6. Set-up FileZilla with your SSH key

Before we get going, there is a subsection which explains
why we use RSA key pairs to make secure connections over 
the internet.

The last section is a Trouble-shooting guide, if things
don't work exacctly as expected.

**************
About SSH Keys
**************

OpenSSH provides several modes of authentication: password log-in, Kerberos 
tickets and Key-based authentication. Key-based authentication is the most 
secure method, and is therefore recommended. Other authentication methods are 
only used in specific situations (such as setting a password when creating a 
new instance). Ideally, password authentication should be disabled, once SSH 
Key-based authentication is working properly.

Generating a key pair provides you with two long string of characters: 
a “public key” and a “private key”. Anyone is allowed to see the public key, 
but only the owner is allowed to see the private key.
You can place the public key on any server, and then unlock it by connecting 
to it with a client that already has the private key. When the two match up, 
the system unlocks without the need for a password. 
You can increase security even more by protecting the private key with a passphrase.
SSH can use either "RSA" (Rivest-Shamir-Adleman) or "DSA" ("Digital Signature Algorithm") keys. 
DSA is known to be less secure, so RSA is recommended: this guide uses "RSA key" 
and "SSH key" interchangeably.




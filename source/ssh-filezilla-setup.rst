.. _setting-up-local-connections:

################################################
Setting up SSH and Filezilla connections locally
################################################


********
Overview
********

This section provides step-by-step advice on setting up a connection
to your Catalyst Cloud instance from your local (client) machine.
Steps 1 through 3 are required before you create a new instance.

After you have completed the steps you will be able to log
on to the server via SSH from your local machine, with an strongly
encrypted connection.

This section assumes You have a Catalyst Cloud account, and you're 
preparing to create your first instance. It is verbose: written for 
a relative newbie, who has not set up an SSH connection to a remote 
server before, but has some experience with the command line interface (terminal).

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
but only the owner is allowed to see the private key. You place the public key 
on a server, and then unlock it by connecting to it with a client that already 
has the private key. If the two match up, the system unlocks without the need for 
a password. You can increase security even more by protecting the private key 
with a passphrase.

SSH can use either "RSA" (Rivest-Shamir-Adleman) or "DSA" ("Digital Signature Algorithm") keys. 
DSA is known to be less secure, so RSA is used in this guide.

******************************************
Step 1: Check that SSH is installed and running 
******************************************
To check that SSH is installed, open a terminal and type:

.. code-block:: bash

 $ ssh -V
 
 
 You should get a response like this:
 
 .. code-block:: bash

 OpenSSH_7.2p2 Ubuntu-4ubuntu1, OpenSSL 1.0.2g-fips  1 Mar 2016
 
 
 To check that SSH is running, type:
 
  .. code-block:: bash

 $ ps aux | grep sshd
 
 
 You should get a response like this:
 
 (user)   5404  0.0  0.0  21300   984 pts/2    S+   13:13   0:00 grep --color=auto sshd
 
 
 Install and start SSH
 =====================
 
 If one or other of these does not return the expected result, then install
 OpenSSH with the command:
 
   .. code-block:: bash
   
   sudo apt-get install openssh-client
   

And then restart your computer or start OpenSSH with the command:
 
   .. code-block:: bash
   
   sudo ssh start
   

And then run the checks above, to make sure it's working.
 

******************************************
 Step 2: Create an RSA Key Pair
 ******************************************
 
Create the key pair on the client machine (your computer). 
Open a terminal and go to your SSH folder by typing:

.. code-block:: bash
$ cd /home/(your_username)/.ssh/

Change the read/write permissions of the folder:

.. code-block:: bash
$ sudo chmod 700 ~/.ssh

Check to see of any Key Pair files already exist: 

.. code-block:: bash
$ ls -l

If the files id_rsa and id_rsa.pub already exist, and you’re not sure 
what they are for, you should probably make copies or backups before proceeding:

.. code-block:: bash
$ cp id_rsa.pub id_rsa.pub.bak
$ cp id_rsa id_rsa.bak

Now generate the new RSA Key Pair, using the default name:

.. code-block:: bash
$ ssh-keygen -t rsa

Option: Create unique key file names
=====================================

You will want to add a new and unique key file name if you are making more 
than one set of keys, to access different projects or instances. 
It is probably wiser to do this if the files id_rsa and id_rsa.pub already exist. 

Create a unique name using the -f flag:

.. code-block:: bash

$ ssh-keygen -t rsa -f newKeyName

Option: Set Key Encryption Level
====================================

The default key is 2048 bits. You can increase this to 4096 bits with the -b flag, 
making it harder to crack the key by brute force methods.

.. code-block:: bash
$ ssh-keygen -t rsa -b 4096

Add your SSH key to the ssh-agent

Ensure ssh-agent is enabled by starting the ssh-agent in the background:

.. code-block:: bash
$ eval "$(ssh-agent -s)"
Agent pid 59566

Now Add your new SSH key to the ssh-agent.

.. code-block:: bash
$ ssh-add ~/.ssh/id_rsa

If you used an existing SSH key rather than generating a new SSH key, 
you'll need to replace "id_rsa" in the command with the name of your 
existing private key file.

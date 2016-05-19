.. _ssh-filezilla-setup:

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
3. Finish off by securing your key
4. Upload the Public Key to a cloud server
5. Connect to the cloud server
6. Set-up FileZilla with your SSH key

Before we start, there is a subsection which explains
why we use RSA key pairs to make secure connections over 
the internet. 

The final section is a Trouble-shooting guide, if things
don't work exactly as expected.

**************
About SSH Keys
**************

OpenSSH provides several modes of authentication: password log-in, Kerberos 
tickets and Key-based authentication. Key-based authentication is the most 
secure method, and is therefore recommended. 

Other authentication methods are only used in specific situations (such as 
setting a password log-in when creating a new instance). Ideally, password 
authentication should be disabled, once SSH your key-based authentication 
is set up and working properly.

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
 
.. code-block:: bash
 
  (user)   5404  0.0  0.0  21300   984 pts/2    S+   13:13   0:00 grep --color=auto sshd
 
 
 
Install and start SSH
=====================
 
If one or other of these does not return the expected result, then install
OpenSSH with the command:
 
.. code-block:: bash
 
  $ sudo apt-get install openssh-client
  

Now restart your computer, or start OpenSSH with the command:
 
.. code-block:: bash
 
  $ sudo ssh start


Now run the checks above, again, to make sure it's working.
 

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

Now generate the new RSA Key Pair, using the default name (id_rsa):

.. code-block:: bash

  $ ssh-keygen -t rsa

Or you can create a unique name using the -f flag:

.. code-block:: bash

  $ ssh-keygen -t rsa -f newKeyName

You will want to add a new and unique key file name if you are making more 
than one set of keys, to access different projects or instances. And it is 
probably wiser to do this if the files id_rsa and id_rsa.pub already exist.

Option: Set Key Encryption Level
====================================

The default key is 2048 bits. You can increase this to 4096 bits with the -b flag, 
making it harder to crack the key by brute force methods.

.. code-block:: bash

  $ ssh-keygen -t rsa -b 4096


Once you have entered the keygen command, you will get this response (with your username in it):

.. code-block:: BASH

  Enter file in which to save the key (/home/(username)/.ssh/id_rsa):

This provides a default file path and filename, where SSH will automatically 
look for your private key when you are using it to log in. You can press enter 
here, saving the file to the default folder. 

If you specify another folder, you will need to enter its file path when you 
issue a log-in command (explained below).

SSH will now ask for a passphrase:

.. code-block:: BASH

  Enter passphrase (empty for no passphrase):

You can press enter, to continue without a passphrase, or type in a passphrase. 

Entering a passphrase increases the level of security. If one of your machines is compromised, 
the bad guys can’t log in to your server until they figure out the passphrase. This buys you 
more time to log-in the server from another machine and change the compromised key pair.

Choosing a good passphrase
==========================

Your SSH key passphrase is only used to protect your “private key” from thieves. 
It's never transmitted over the Internet, and the strength of your key has nothing to do 
with the strength of your passphrase.

There is no way to recover a lost passphrase. If the passphrase is lost or forgotten, 
a new key must be generated and the corresponding public key copied to other machines.

If you use a passphrase, pick a strong one and store it securely in a password manager, 
or write it down on a piece of paper and keep it in a secure place. Obviously, you should 
not store it on the client machine that you are using to connect to your server!


Key Pair Generated successfully
===============================

The entire key generation process will look something like this in your terminal:

.. code-block:: BASH

  ssh-keygen -t rsa
  Generating public/private rsa key pair.
  Enter file in which to save the key (/home/(user)/.ssh/id_rsa): 
  Enter passphrase (empty for no passphrase): 
  Enter same passphrase again: 
  Your identification has been saved in /home/(user)/.ssh/id_rsa.
  Your public key has been saved in /home/(user)/.ssh/id_rsa.pub.
  The key fingerprint is:
  4a:dd:0a:c6:35:4e:3f:ed:27:38:8c:74:44:4d:93:67 (user)@(machine)
  The key's randomart image is:
  +--[ RSA 2048]----+
  |          .oo.   |
  |         .  o.E  |
  |        + .  o   |
  |     . = = .     |
  |      = S = .    |
  |     o + = +     |
  |      . o + o .  |
  |           . o   |
  |                 |
  +-----------------+


******************************************
 Step 3: Finishing off
******************************************

There are a few final steps to make sure your SSH connection
will work properly the ffirst time.

Add your SSH key to the ssh-agent
====================================

First, ensure ``ssh-agent`` is enabled by starting the ssh-agent in the background.
If it is working, you will get an ``Agent pid`` response:

.. code-block:: bash

  $ eval "$(ssh-agent -s)"
  Agent pid 59566

Now, add your new SSH key to the ssh-agent:

.. code-block:: bash

  $ ssh-add ~/.ssh/newKeyName


Locating your new public and private keys
=========================================

If you created the keys with the default name, then:

The public key is now located in ``/home/(user)/.ssh/id_rsa.pub``
The private key is now located in ``/home/(user)/.ssh/id_rsa``

If you created the keys with a unique name, then:

The public key is now located in ``/home/(user)/.ssh/myNewKeyName.pub``
The private key is now located in ``/home/(user)/.ssh/myNewKeyName``


Securing your new key pair
==========================

Change the file permissions on your private key to make sure other
users won't have access to it

.. code-block:: bash

  $ cd ~/.ssh
  $ chmod 600 myNewKey


.. note:: 

  If you fail to do this, you may get an error when you try to use the
  key: ``Permissions... are too open. This private key will be ignored''

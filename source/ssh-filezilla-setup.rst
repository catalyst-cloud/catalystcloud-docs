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

Change the read/write permissions of the folder (you will change
these back again in Step 3):

.. code-block:: bash

  $ sudo chmod 700 ~/.ssh

You don't want to overwrite an existing key pai, check to see of any 
Key Pair files already exist, and what their names are:


.. code-block:: bash

  $ ls -l

If the files id_rsa and id_rsa.pub already exist (or any other files), 
and you’re not sure what they are for, you should probably make backup 
copies before proceeding:

.. code-block:: bash

  $ cp id_rsa.pub id_rsa.pub.bak
  $ cp id_rsa id_rsa.bak

Now EITHER generate the new RSA Key Pair, using the default name (id_rsa):

.. code-block:: bash

  $ ssh-keygen -t rsa

OR generate a new Key Pair with a unique name using the -f flag:

.. code-block:: bash

  $ ssh-keygen -t rsa -f newKeyName

You will want to add a new and unique key file name if you are making more 
than one set of keys, to access different projects or instances. 

.. note::

  **Set Key Encryption Level**
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

It is a good idea to select all of this information, use ctrl + shift + c to copy it
from the terminal, and paste it into a text editor file.  Add the passphrase, if you used
one. Then save the text file and store it somewhere very safe.

******************************************
 Step 3: Finishing off
******************************************

There are a few final steps to make sure your SSH connection
will work properly the first time.

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


Securing your new key pair
==========================

Finally, change the file permissions on your private key to make sure other
users won't have access to it

.. code-block:: bash

  $ cd ~/.ssh
  $ chmod 600 myNewKey


.. note:: 

  If you fail to do this, you may get an error when you try to use the
  key: ``Permissions... are too open. This private key will be ignored''
  
Repeat Steps 2 to 3 for each Instance
=====================================

On OpenStack (and the Catalyst Cloud), each instance can have only one Key Pair,
and one public IP address. 

You will need to repeat steps 2 to 3 for each instance that you wish to access
with SSH. And this is where it becomes important to think about using unique Key Pair
file names, which reflect the name of the instance they will be attached to.

There are some other implications:
* If you want to access one instance from multiple machines, you need to install the same Key Pair on each machine. 
* If you want multiple users to access one instance, then each user must to install the same Key Pair on their machine.  
* If you install a Key Pair on only one machine, which it is subsequently lost, stolen or destroyed, then you may have a significant problem.  

It is advisable to make a copy of your private and public Key Pair files and store them 
somewhere safe (e.g. on an encrypted USB drive). **This might be a good moment to do that.**


******************************************
Step 4: Upload the Public Key to Cloud Server
******************************************

Now it's time to place the public key on the virtual server we want to use. 
You will need to open the public key file, to copy and upload it. 
Assuming you use gedit as a text editor, open a terminal and type:

.. code-block:: bash

  $ sudo gedit /home/(user)/.ssh/myNewKey.pub

On your Catalyst Cloud dashboard select “Import Key Pair”:

[ Insert image here ]

Enter a key pair name, then copy and paste your public key 
from your text editor into the box. 


Transfer Client Key to Host with command line (not recommended)
===============================================================

If you can log in to a computer over SSH using a password, you can 
transfer your RSA key to the server by using the terminal command:

.. code-block:: bash

  $ ssh-copy-id <username>@<host>

Where <username> and <host> should be replaced by your username 
and the name of the computer you're transferring your key to.

The method above uses the default port 22. If you are not using port 22, 
then issue the command with a -p flag and the port number: 

.. code-block:: bash

  $ ssh-copy-id "<username>@<host> -p <port_number>"

Another method is to copy the public key file to the server and 
concatenate it onto the authorized_keys file manually. It is wise to back that up first:

.. code-block:: bash

  $ cp authorized_keys authorized_keys_Backup
  $ cat id_rsa.pub >> authorized_keys

You can copy the public key into the new machine's authorized_keys file 
with the ssh-copy-id command. Make sure to replace the example username and IP address below.

.. code-block:: bash

  $ ssh-copy-id user@123.45.56.78 ]

Alternatively, you can paste in the keys using SSH:

.. code-block:: bash

  $ cat ~/.ssh/myNewKey.pub | ssh ubuntu@<public_IP> "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys" ]

No matter which command you chose, you should see something like:

.. code-block:: bash

  The authenticity of host 'public_IP (public_IP)' can't be established.
  RSA key fingerprint is b1:2d:33:67:ce:35:4d:5f:f3:a8:cd:c0:c4:48:86:12.
  Are you sure you want to continue connecting (yes/no)? yes
  Warning: Permanently added '<public_IP>' (RSA) to the list of known hosts.
  ubuntu@public_IP's password: 

Type in your password and continue.


******************************************
Step 5: Connecting to the new Instance 
******************************************

You can now connect to the SSH service using the floating public IP that you 
associated with your instance in the previous step. This IP address address is 
visible in the Instances list or under the Floating IPs tab in Access & Security.

.. code-block:: bash

  $ ssh -i ~/<myKeyName> ubuntu@<FLOATING_IP>

If you have set a passphrase, you will be asked to enter the passphrase now.

.. warning::

 Sometimes your machine will open a dialog box asking for your *password*.
 What it actually wants is the *passphrase* you set when creating the key pair.
 
 This can be confusing if you were expecting to be asked for a passphrase in
 terminal window. 
 
 Just enter you passphrase into the dialog box and continue.
 
You should be able to interact with this instance as you would any Ubuntu server.

And from now on, you only need to enter this command in the terminal to access the
instance:

.. code-block:: bash

  $ ssh ubuntu@<FLOATING_IP>

******************************************
Step 6: Use FileZilla with an SSH key (optional)
******************************************

Filezilla gives you a GUI overview of your Instance’s filesystem, with the ability 
to quickly and easily upload or download files from your local machine to the 
cloud server using SFTP (SSH File Transfer Protocol). 

You can access the server with Filezilla by using the password with SFTP, if you want. 
But using the key pair encryption is much safer. 

If you want to disable password login for security reasons (see below), you’ll need 
to set up Filezilla to utilise the private key you have now created.

Open the menu ``Edit`` > ``Preferences…`` then navigate to ``Connection`` > ``SFTP``.

[insert image]

Add your private key file by clicking the ``Add keyfile…`` button, choosing
``all file types`` and navigating to your new private key file (e.g. /home/(user)/.myNewKey).  

Note: you may have to select View > Show Hidden Files to get to the .ssh/ folder: 

When you select the private key file, Filezilla will ask if you want to convert it to a PPK file. 
Say yes, add a new filename,  and save it in the same folder.  To avoid confusion, 
the new filename should be something like myNewKey_fz.ppk (make sure to add the .ppk suffix).

Now go to ``File`` > ``Site Manager…`` and add a ``New Site``.

Enter the details as required:

  **Host:** the floating Public IP address attached to your instance

  **Port:** 22 (if using the default port)

  **Protocol:** SFTP - SSH File Transfer Protocol

  **Logon Type:** Key file

  **User:** ubuntu (or your chosen distribution name) 

  **Key File:** browse to the .ppk file you just created
  
[ Insert Image ]

Then click ``OK``

Now you can access your cloud server’s file system by opening Filezilla 
and clicking, or right-clicking on the server symbol at the top left corner 
of the Filezilla window, then selecting the site you just created. 

******************************************
Step 7: Disable Password Authentication (optional)
******************************************

If you have followed the steps above, you should always be able to log in 
to your server with an SSH key. You should should consider disabling
password authentication altogether.

Key pair authentication massively improves your security, but makes it impossible 
for you to connect to your server from a friendly PC without first installing your
key pair on it.

It is recommended to disable password authentication unless you have a 
specific reason not to.

To disable password authentication
==================================

First, make a backup of your ``sshd_config`` file by copying it to your home directory, 
or by making a read-only copy in ``/etc/ssh`` by doing:

.. code-block:: bash

  $ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
  $ sudo chmod a-w /etc/ssh/sshd_config.factory-defaults
  
Creating a read-only backup in ``/etc/ssh`` means you'll always be able to find a 
known-good configuration when you need it.

Once you've backed up your ``sshd_config`` file, you can make changes with the nano text editor, for example; 

.. code-block:: bash

 $ sudo nano /etc/ssh/sshd_config
 
Now look for the following line in your ``sshd_config`` file:

.. code-block:: bash

  **#PasswordAuthentication yes**
  
Replace it with a line that looks like this:

.. code-block:: bash

  **PasswordAuthentication no**
  
Once you've made your changes you can apply them by saving the file then doing:

.. code-block:: bash

  $ sudo service ssh restart
  
Once you have saved the file and restarted your SSH server, you shouldn't even be asked for a password when you log in.

*****************
Troubleshooting
*****************

Detaching or Changing the Key on an Instance
You cannot detach a Key from an instance, or modify it once attached.  The only way to assign a new Key Pair to an instance is to:
Make a Snapshot of the instance
Create a new Instance from the Snapshot
Attach a new Key to the new instance while you are creating it
Adding or changing a passphrase
You can change the passphrase for an existing private key without regenerating the keypair. Just type the following command:
$ ssh-keygen -p

# Start the SSH key creation process
Enter file in which the key is (/Users/you/.ssh/id_rsa): [Hit enter]
Key has comment '/Users/you/.ssh/id_rsa'
Enter new passphrase (empty for no passphrase): [Type new passphrase]
Enter same passphrase again: [Type it again]
Your identification has been saved with the new passphrase.

If your key already has a passphrase, you will be prompted to enter it before you can change to a new passphrase.
Encrypted Home Directory
If you have an encrypted home directory, SSH cannot access your authorized_keys file because it is inside your encrypted home directory and won't be available until after you are authenticated. Therefore, SSH will default to password authentication.
To solve this, create a folder outside your home named /etc/ssh/<username> (replace "<username>" with your actual username). This directory should have 755 permissions and be owned by the user. Move the authorized_keys file into it. The authorized_keys file should have 644 permissions and be owned by the user. 
Then edit your /etc/ssh/sshd_config and add:
AuthorizedKeysFile    /etc/ssh/%u/authorized_keys
Finally, restart ssh with:
sudo service ssh restart
The next time you connect with SSH you should not have to enter your password.
username@host's password:
If you are not prompted for the passphrase, and instead get:
username@host's password:
On the host computer, ensure that the file: /etc/ssh/sshd_config contains the following lines, and that they are uncommented;
PubkeyAuthentication yes
RSAAuthentication yes
If not, add them, or uncomment them, restart OpenSSH, and try logging in again. If you get the passphrase prompt now, then congratulations, you're logging in with a key!
Permission denied (publickey)
If you're sure you've correctly configured sshd_config, copied your ID, and have your private key in the .ssh directory, and still getting this error:
Permission denied (publickey).
Chances are the permissions for your /home/<user> (folder) or ~/.ssh/authorized_keys (file) are too accessible, by OpenSSH standards. You can get rid of this problem by issuing the following chmod commands:
chmod go-w ~/     (explain)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
Error: Agent admitted failure to sign using the key.
This error occurs when the ssh-agent on the client is not yet managing the key. Issue the following commands to fix: 
ssh-add
This command should be entered after you have copied your public key to the host computer.
Remote Host Identification Has Changed
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:aGZ5Fs+qEf4ESngJdksqAcn+L4H7WeOwY8nu0HsR7c4.
Please contact your system administrator.
Add correct host key in /home/(user)/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/(user)/.ssh/known_hosts:2
  remove with:
  ssh-keygen -f "/home/(user)/.ssh/known_hosts" -R <IP_ADDRESS>
ECDSA host key for <IP_ADDRESS> has changed and you have requested strict checking.
Host key verification failed.


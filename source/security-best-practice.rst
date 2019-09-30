***********************
Security best practices
***********************

This section covers some best practices for security on the Catalyst Cloud, and
for general security business protocols.

General security
================

.. Note::
   This section is for those who may be new to the computing sector and are
   unaware of standard security practices.

The following is a list and explanation of some of the more common security
protocols that are used as standards in the tech sector today.

Password protocols
------------------

Password strength is defined by the entropy it takes to brute force your
password. This is to say how long it takes to cycle through the alphabet and
attempt to match your password by luck. If you have a relatively long password
you would be fine. However, your passwords entropy, goes
down significantly if you use common keywords such as 'password' or
a birthday date. To ensure that your password entropy is high, a standard has
formed that suggests your password comply with these rules:

- It is at least 18 characters in length where possible, or if a service
  only allows shorter, you should use the maximum amount of characters.
- It should contain at least one capital letter, one number and one special
  character (e.g. @,&,-,~,!)
- Do not use the these in a password: Password, Secret, '123456', p@ssw0rd etc.

OR if you are using a passphrase instead:

- It should contain at least 4 words and be over 18 characters long.

Using a passphrase, that is a collection of words, rather than a password with
different symbols and numbers is is a viable alternative because of 2 things:
the length of a passphrase. And you will be able to remember 4-6 words easier
than you would 18 randomly generated characters, but this doesn't affect the
entropy of the password, provided that you follow the rules provided.

.. code-block:: bash

   # an example of a complex password would be
   deyp78&*fasbk!~)&(*

   # an example of a strong passphrase would be
   boatdrillchargerkeysstop
   # this could be more specific and meaningful to you, or random like the one above

Update systems often
--------------------

Keeping your systems up to date with the most current version of
your applications and operating systems helps to keep you secure because
malicious software that attacks files and core operating infrastructure on your
computer is consistently created. Therefore your operating system and other
applications need to be constantly updated to protect against these because
updates (specifically on linux systems) do include security improvements on a
regular basis (once a week)


Encrypting emails
-----------------
When sending emails that pertain to sensitive information or information about
business practices etc. You should encrypt them using a PGP key or some other
form of encryption.

You should *never* send any form of private key or identification information
over emails that are not encrypted and in some cases, you may need to use a
physical memory device (flash drive) to transport such sensitive files.

Create an incident response playbook
------------------------------------


Back up data
------------


Account management
==================
This is covered in the
:ref:`identity access management <identity-access-management>` section of the
documentation.


Security groups
===============


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

Password strength is defined by the entropy it has.
This is to say how long it takes to brute force your password. If you have a
relatively long password you would be fine. However, your passwords entropy,
goes down significantly if you use common keywords such as 'password' or
a birthday date. To ensure that your password entropy is high, a standard has
formed around passwords so that they comply with these rules:

- It is at least 18 characters in length where possible, or if a service
  only allows shorter, you should use the maximum amount of characters.
- It should contain at least one capital letter, one number and one special
  character (e.g. @,&,-,~,!)
- Do not use certain words in a password such as: Password, Secret, '123456',
  p@ssw0rd etc.

OR if you are using a passphrase instead:

- It should contain at least 4 words and be over 18 characters long.

Using a passphrase (a collection of words), rather than a password with
different symbols and numbers is also possible. The length of a
passphrase gives it the necessary entropy to be a viable alternative with the
added benefit  that you will be able to remember 4-6 words easier
than you would 18 randomly generated characters.

.. code-block:: bash

   # an example of a complex password would be
   deyp78&*fasbk!~)&(*

   # an example of a strong passphrase would be
   boatdrillchargerkeysstop
   # this could be more specific and meaningful to you, or random like the one above

The last thing about passwords that you need to be considerate of, is password
protection. Follow these rules about access to or sharing information
about passwords:

- Don't send your password over the internet to anyone.
- Don't write passwords down and store them on a physical location.
- Store any user ID's or passwords in an encrypted format.
- Do not script any passwords for automatic log in.
- Never use a previously used password.
- Change your password once every year.

Update systems often
--------------------

Keeping your software up to date with the most current version of
your applications and operating systems helps to keep you secure. Malicious
software that attacks files and core operating infrastructure on your
computer is consistently created; therefore your operating system and other
applications need to be constantly updated to protect yourself. It is
understandable that if you are using a legacy program or software that you may
not be able to update it but for those that you can, it is recommended that you
keep them updated as regularly as possible since these include security
upgrades.


Encrypting emails
-----------------

When sending emails that pertain to sensitive information about
business practices etc. You should encrypt them using a PGP key or some other
form of encryption. This not only means that it's harder for your emails to be
broken into, it also mitigates phishing attacks because your emails can be
authenticated.

You should *never* send any form of private key or identification information
over emails that are not encrypted. In some cases you may need to use a
physical memory device (flash drive) to transport such sensitive files.



Back up data
------------

This is a standard practice for any business. Making sure that if some form
of catastrophe were to befall you system, that you have backups to recover
to a working state. When it comes to the Catalyst Cloud, there are several
unique things that ensure data backup.

Our Object and Block storage services create copies of the data stored on them
and distribute these copies to the different regions available.
If any physical damage or soft corruption (bit rot) were to occur, the data
stored would be restored through the self-healing and self-managing storage
systems that we have.

However, you may still want to create explicit backups for your data. More
information on backups can be found under the :ref:`backups section <backups>`
of the documentation or under the section on the specific service you seek to
backup.

Create an incident response playbook
------------------------------------

An incident response playbook is a tool that companies use to deal with
issues in a routine and standardised way. Typical examples of this would
be a guide or process of what to do when your system or company is experiencing
a malware outbreak, data theft or virus outbreak. They could also govern
process such as what to do if you are using root access to avoid an incident
in the first place.

There are a variety of different playbooks you can create but the objective of
having these playbooks is to provide your staff with a clear path on what to
do in the event of something going wrong.

Access management
=================

Access management, is a set of practices and rules that make
sure that your organisation knows exactly who has access to the resources that
you have previsioned in the cloud and what exactly these users can do with
said resources.
The Catalyst Cloud achieves a strong level of security in this regard by
the use of roles. These are given to users by the project administrator and
they impose restrictions or provide privileges to users. For more information
on roles and their uses, please see the
:ref:`identity access management <identity-access-management>` section of the
documentation.


Security groups
===============

Security groups are what allow you to safely and securely access the instances
that you create on the Catalyst Cloud. When creating a security group, it
automatically has the following rules:

.. image:: assets/security-group-screenshot.png

These mean that the security group can access the internet form IPv4 and v6
with outward bound traffic. But at this stage there is no ingress traffic.
You must define that yourself. When doing so you need to be careful, depending
on the type of access you wish to permit. Below is pictured the different rules
you can create to meet your needs.

.. image:: assets/rule-types.png

When creating an ingress rule for the security group you need to be careful
about which ports you allow access to your instance. Setting your port range
to 0.0.0.0./0 will open it to the entire internet meaning that
anyone should they find it can access your instance.The best practice for a
secure instance is to use an SSH rule. This is because even should you expose
it to the entire internet, without the proper SSH key pair, they would not be
able to access the instance.


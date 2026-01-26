.. index::
   single: WinSCP
   single: Client Software; WinSCP

******
WinSCP
******

WinSCP is an open source and free SFTP and FTP client for MS Windows. It also
supports S3, and is compatible with Catalyst Cloud object storage using the
OpenStack S3 API. It is available from https://winscp.net/ .

Configuration steps
===================

#. New site
#. File protocol: Amazon S3
#. Host name: select the appropriate "s3" endpoint from :ref:`the API page <apis>`.
#. Access Key & Secret Access Key: EC2 credentials (you may wish to create a dedicated user).

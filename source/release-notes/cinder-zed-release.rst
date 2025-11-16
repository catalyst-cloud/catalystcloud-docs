##############
DATE
##############

======================================================
Upgrade to the Block Storage service (Stein - Wallaby)
======================================================

With this release there have been some changes to the Block storage service. 
The following is a list of features and changes that are included in this release: 


New Feature
---------------------------

- A new backup driver has been added which enables backing up a volume to S3-compatible storage.

Changes to behavior
---------------------------

- You can no longer create an incremental backup while having the parent backup in another project. 
- Fixed a race condition between the `delete attachment` and `delete volume` operations, that used 
  leave deleted volumes sometimes stuck as attached to instances.

Deprecations and removals
---------------------------

- Python 2.7 support is dropped and the minimum version of python that can be used is now Python 3.6
# You will need to select an image from the following list which we will use to create our instance later.
# For this example we will be using Ubuntu-20.04

$ openstack image list --public
+--------------------------------------+--------------------------------------+--------+
| ID                                   | Name                                 | Status |
+--------------------------------------+--------------------------------------+--------+
| 1b727bd1-c909-46bb-ac88-xxxxxxxxxxxx | atomic-7-x86_64                      | active |
| 033869d4-355d-4940-91b0-xxxxxxxxxxxx | centos-6.5-x86_64                    | active |
| 96acfca0-efe5-4dad-821b-xxxxxxxxxxxx | centos-6.6-x86_64                    | active |
| b70703b4-7c67-4d8c-b418-xxxxxxxxxxxx | centos-7-x86_64                      | active |
| 509ef911-ef10-478c-9b77-xxxxxxxxxxxx | centos-8-x86_64                      | active |
| b9d811d7-b94c-4775-b563-xxxxxxxxxxxx | coreos-stable-x86_64                 | active |
| ee3f0913-a023-45c2-a73a-xxxxxxxxxxxx | debian-10-x86_64                     | active |
| 311599f9-2446-4805-a002-xxxxxxxxxxxx | debian-7-x86_64                      | active |
| 94b0af64-681a-48aa-ac1a-xxxxxxxxxxxx | debian-8-x86_64                      | active |
| 33bd0e60-3f77-49cf-8200-xxxxxxxxxxxx | debian-9-x86_64                      | active |
| 83833f4f-5d09-44cd-9e23-xxxxxxxxxxxx | fedora-atomic-27-x86_64              | active |
| aebbb117-cb9d-4e06-9238-xxxxxxxxxxxx | fedora-atomic-29-x86_64              | active |
| 616aa16c-c6bd-49c6-8e3a-xxxxxxxxxxxx | fedora-coreos-31-x86_64              | active |
| d04f6cdf-09d9-4a6f-ad61-xxxxxxxxxxxx | ubuntu-12.04-x86_64                  | active |
| 7c1ac88a-126e-495e-92d9-xxxxxxxxxxxx | ubuntu-13.10-x86_64                  | active |
| 60c6a75a-4172-4a89-83b0-xxxxxxxxxxxx | ubuntu-14.04-x86_64                  | active |
| 4d9a5d46-6456-4b76-a61d-xxxxxxxxxxxx | ubuntu-16.04-x86_64                  | active |
| 5fbe78e9-4ea8-479b-a101-xxxxxxxxxxxx | ubuntu-18.04-x86_64                  | active |
| fffc6263-e051-4fd1-9474-xxxxxxxxxxxx | ubuntu-20.04-x86_64                  | active |
| 31ca624f-50ed-4a33-bf39-xxxxxxxxxxxx | ubuntu-minimal-16.04-x86_64          | active |
| 71975af4-06ef-492a-b3c4-xxxxxxxxxxxx | ubuntu-minimal-18.04-x86_64          | active |
+--------------------------------------+--------------------------------------+--------+

$ export CC_IMAGE_ID=$( openstack image show ubuntu-20.04-x86_64 -f value -c id )


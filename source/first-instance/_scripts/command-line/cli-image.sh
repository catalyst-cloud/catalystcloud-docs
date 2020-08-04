# You will need to select an image from the following list which we will use to create our instance later.
# For this example we will be using Ubuntu-20.04

$ openstack image list --public
+--------------------------------------+--------------------------------------+--------+
| ID                                   | Name                                 | Status |
+--------------------------------------+--------------------------------------+--------+
| 1b727bd1-c909-46bb-ac88-69d4e8acd0e9 | atomic-7-x86_64                      | active |
| 033869d4-355d-4940-91b0-0245af7c4bf0 | centos-6.5-x86_64                    | active |
| 96acfca0-efe5-4dad-821b-3c6cd7d099d1 | centos-6.6-x86_64                    | active |
| b70703b4-7c67-4d8c-b418-fd36efbc0157 | centos-7-x86_64                      | active |
| 509ef911-ef10-478c-9b77-ea8aff06b320 | centos-8-x86_64                      | active |
| b9d811d7-b94c-4775-b563-fb3e0b7015f1 | coreos-stable-x86_64                 | active |
| ee3f0913-a023-45c2-a73a-42838bd7a452 | debian-10-x86_64                     | active |
| 311599f9-2446-4805-a002-451c263fd2d6 | debian-7-x86_64                      | active |
| 94b0af64-681a-48aa-ac1a-b0cde8b2c3c5 | debian-8-x86_64                      | active |
| 33bd0e60-3f77-49cf-8200-0b5f2fc804dd | debian-9-x86_64                      | active |
| 83833f4f-5d09-44cd-9e23-b0786fc580fd | fedora-atomic-27-x86_64              | active |
| aebbb117-cb9d-4e06-9238-9fca618938d6 | fedora-atomic-29-x86_64              | active |
| 616aa16c-c6bd-49c6-8e3a-c7e6fa650313 | fedora-coreos-31-x86_64              | active |
| d04f6cdf-09d9-4a6f-ad61-818130768faa | ubuntu-12.04-x86_64                  | active |
| 7c1ac88a-126e-495e-92d9-e81c16d50717 | ubuntu-13.10-x86_64                  | active |
| 60c6a75a-4172-4a89-83b0-702e1a7acf67 | ubuntu-14.04-x86_64                  | active |
| 4d9a5d46-6456-4b76-a61d-5d49d2d169a8 | ubuntu-16.04-x86_64                  | active |
| 5fbe78e9-4ea8-479b-a101-952c3ce47758 | ubuntu-18.04-x86_64                  | active |
| fffc6263-e051-4fd1-9474-c0fbdfc90d6e | ubuntu-20.04-x86_64                  | active |
| 31ca624f-50ed-4a33-bf39-3129061dc0e4 | ubuntu-minimal-16.04-x86_64          | active |
| 71975af4-06ef-492a-b3c4-9e60029a4065 | ubuntu-minimal-18.04-x86_64          | active |
+--------------------------------------+--------------------------------------+--------+

$ export CC_IMAGE_ID=$( openstack image show ubuntu-20.04-x86_64 -f value -c id )



# The Flavor of an instance specifies the disk, CPU, and memory allocated to an instance.
# Using the following code snippit, we can see a list of available configurations:

$ openstack flavor list
+--------------------------------------+-----------+-------+------+-----------+-------+-----------+
| ID                                   | Name      |   RAM | Disk | Ephemeral | VCPUs | Is Public |
+--------------------------------------+-----------+-------+------+-----------+-------+-----------+
| 01b42bbc-347f-43e8-9a07-xxxxxxxxxxxx | c1.c8r8   |  8192 |   10 |         0 |     8 | True      |
| 0c7dc485-e7cc-420d-b118-xxxxxxxxxxxx | c1.c2r8   |  8192 |   10 |         0 |     2 | True      |
| 0f3be84b-9d6e-44a8-8c3d-xxxxxxxxxxxx | c1.c16r16 | 16384 |   10 |         0 |    16 | True      |
| 1750075c-cd8a-4c87-bd06-xxxxxxxxxxxx | c1.c1r2   |  2048 |   10 |         0 |     1 | True      |
| 1d760238-67a7-4415-ab7b-xxxxxxxxxxxx | c1.c8r32  | 32768 |   10 |         0 |     8 | True      |
| 28153197-6690-4485-9dbc-xxxxxxxxxxxx | c1.c1r1   |  1024 |   10 |         0 |     1 | True      |
| 45060aa3-3400-4da0-bd9d-xxxxxxxxxxxx | c1.c4r8   |  8192 |   10 |         0 |     4 | True      |
| 4efb43da-132e-4b50-a9d9-xxxxxxxxxxxx | c1.c2r16  | 16384 |   10 |         0 |     2 | True      |
| 62473bef-f73b-4265-a136-xxxxxxxxxxxx | c1.c4r4   |  4096 |   10 |         0 |     4 | True      |
| 6a16e03f-9127-427c-99aa-xxxxxxxxxxxx | c1.c16r8  |  8192 |   10 |         0 |    16 | True      |
| 746b8230-b763-41a6-954c-xxxxxxxxxxxx | c1.c1r4   |  4096 |   10 |         0 |     1 | True      |
| 7b74c2c5-f131-4981-90ef-xxxxxxxxxxxx | c1.c8r16  | 16384 |   10 |         0 |     8 | True      |
| 7cd52d7f-9272-47c9-a3ea-xxxxxxxxxxxx | c1.c8r64  | 65536 |   10 |         0 |     8 | True      |
| 88597cff-9503-492c-b005-xxxxxxxxxxxx | c1.c16r64 | 65536 |   10 |         0 |    16 | True      |
| 92e03684-53d0-4f1e-9222-xxxxxxxxxxxx | c1.c16r32 | 32768 |   10 |         0 |    16 | True      |
| a197eac1-9565-4052-8199-xxxxxxxxxxxx | c1.c8r4   |  4096 |   10 |         0 |     8 | True      |
| a80af444-9e8a-4984-9f7f-xxxxxxxxxxxx | c1.c4r2   |  2048 |   10 |         0 |     4 | True      |
| b152339e-e624-4705-9116-xxxxxxxxxxxx | c1.c4r16  | 16384 |   10 |         0 |     4 | True      |
| b4a3f931-dc86-480c-b7a7-xxxxxxxxxxxx | c1.c4r32  | 32768 |   10 |         0 |     4 | True      |
| c093745c-a6c7-4792-9f3d-xxxxxxxxxxxx | c1.c2r4   |  4096 |   10 |         0 |     2 | True      |
| e3feb785-af2e-41f7-899b-xxxxxxxxxxxx | c1.c2r2   |  2048 |   10 |         0 |     2 | True      |
+--------------------------------------+-----------+-------+------+-----------+-------+-----------+

# We then export the flavor ID we want to use as a variable we can use later.
$ export CC_FLAVOR_ID=$( openstack flavor show c1.c1r1 -f value -c id )

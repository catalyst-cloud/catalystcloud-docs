Catalyst Cloud has unique Object Storage endpoint URLs for each region.

.. list-table::
  :header-rows: 1

  * - Region
    - Endpoint URL
  * - nz-por-1
    - ``https://object-storage.nz-por-1.catalystcloud.io:443``
  * - nz-hlz-1
    - ``https://object-storage.nz-hlz-1.catalystcloud.io:443``
  * - nz_wlg_2
    - ``https://object-storage.nz-wlg-2.catalystcloud.io:443``

The endpoint URL you will need to use depends on your use case.

* If the container uses a
  :ref:`single-region storage policy <object-storage-storage-policies>`,
  use the endpoint URL for the region the container is located in.

  * For example, if the container is located in the ``nz-hlz-1`` region,
    use the endpoint URL for the ``nz-hlz-1`` region.

* If the container uses the multi-region replication policy
  **AND** the workload (e.g. compute instance) accessing the container
  is also hosted on Catalyst Cloud, set this to the same region in which
  the workload is located.

  * For example, if the workload is hosted in the ``nz-hlz-1`` region,
    use the endpoint URL for the ``nz-hlz-1`` region.

* If none of the above apply, use the endpoint for the ``nz-por-1`` region.

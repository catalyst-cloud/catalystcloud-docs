.. _database_versions:

####################################################
Available database datastore versions and extensions
####################################################

******************
Datastore Versions
******************

A Datastore is the database engine, currently Catalyst Cloud offers two datastores: MySQL and PostgreSQL.

The following datastore versions are available on Catalyst Cloud. We recommend
that whenever possible you use the latest datastore version we provide.

=====
MySQL
=====

MySQL datastore versions follow the format of ``major.minor.patch``, so 5.7.36 is major version 5, minor 7 and patch 36.

.. list-table::
   :widths: 10 20 20 20
   :header-rows: 1

   * - Version
     - Current Status
     - Initial Release Date
     - Unsupported Date
   * - 5.7.29
     - Available
     - 2021-04-19
     - 2027-06
   * - 5.7.36
     - Available
     - 2024-05-09
     - 2027-06
   * - 8.0
     - TBA
     - Expected 2026-12
     - TBA
   * - 8.4
     - TBA
     - Expected 2027-03
     - TBA
   * - 9.0
     - TBA
     - Expected 2027-06
     - TBA

==========
PostgreSQL
==========

PostgreSQL versions follow the format of ``major.minor``, so 12.18 is major version 12, minor 18

.. list-table::
   :widths: 10 20 20 20
   :header-rows: 1

   * - Version
     - Current Status
     - Initial Release Date
     - Unsupported Date
   * - 12.4
     - Available
     - 2021-04-19
     - 2027-06
   * - 12.17
     - Available
     - 2021-06-18
     - 2027-06
   * - 12.18
     - Available
     - 2024-05-04
     - 2027-06
   * - 13.44
     - TBA
     - 2026-12
     - TBA
   * - 14
     - TBA
     - 2026-12
     - TBA
   * - 15
     - TBA
     - 2026-12
     - TBA
   * - 16
     - TBA
     - 2026-12
     - TBA

*********************
PostgreSQL extensions
*********************

For the PostgreSQL database the following extensions are available
beyond default extensions:

.. list-table::
   :widths: 30 10 10 10
   :header-rows: 1

   * - Extension
     - 12.4
     - 12.17
     - 12.18
   * - address_standardizer
     - -
     - -
     - 3.4.2
   * - address_standardizer-3
     - -
     - -
     - 3.4.2
   * - address_standardizer_data_us
     - -
     - -
     - 3.4.2
   * - address_standardizer_data_us-3
     - -
     - -
     - 3.4.2
   * - postgis
     - -
     - -
     - 3.4.2
   * - postgis-3
     - -
     - -
     - 3.4.2
   * - postgis_raster
     - -
     - -
     - 3.4.2
   * - postgis_raster-3
     - -
     - -
     - 3.4.2
   * - postgis_sfcgal
     - -
     - -
     - 3.4.2
   * - postgis_sfcgal-3
     - -
     - -
     - 3.4.2
   * - postgis_tiger_geocoder
     - -
     - -
     - 3.4.2
   * - postgis_tiger_geocoder-3
     - -
     - -
     - 3.4.2
   * - postgis_topology
     - -
     - -
     - 3.4.2
   * - postgis_topology-3
     - -
     - -
     - 3.4.2
   * - postgres_fdw
     - -
     - -
     - 3.4.2

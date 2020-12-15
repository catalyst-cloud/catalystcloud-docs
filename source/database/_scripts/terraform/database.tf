provider "openstack" {
}

variable "public_network_id" {
  default = "<PUBLIC_NET_ID>"
}

variable "project-region" {
  default = "<NETWORK_ID>"
}

variable "database-flavor" {
  default = "<FLAVOR_ID>"
}

variable "database-name" {
  default = "<DATABASE_NAME>"
}

# You can add more names to the list below to create multiple databases. For our example we are only creating one database: "database-1"
variable "database-names" {
  default = ["database-1"]
}

#---------------------------------------------------

resource "openstack_db_instance_v1" "test-db-instance" {
  region    = var.project-region
  name      = var.database-name
  flavor_id = var.database-flavor
  size      = 5 #The size of your database in GB
  network {
    uuid = var.public_network_id
  }
  datastore {
    version = "5.7.29"    # We have already set these variables for our example. You can check the openstack CLI example to find the type/versions available on the cloud
    type    = "mysql"
  }
  database {
    name = var.database-names.0
  }
  user {
    name = "new_user"
    password = "XXXXXXXXXX"
    databases = var.database-names
  }
}


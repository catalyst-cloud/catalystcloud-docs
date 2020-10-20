# This example relies on OpenStack environment variables
# If you wish to set these credentials manualy please consult
# https://www.terraform.io/docs/providers/openstack/index.html
provider "openstack" {
}

# From: http://docs.catalystcloud.io/network.html?highlight=public%20network
#nz-por-1	849ab1e9-7ac5-4618-8801-e6176fbbcf30
#nz_wlg_2	e0ba6b88-5360-492c-9c3d-119948356fd3
#nz-hlz-1	f10ad6de-a26d-4c29-8c64-2a7418d47f8f

variable "public_network_id" {
  default = "<INSERT THE PUBLIC NETWORK ID (LISTED ABOVE)>"
}

variable "compute_image_ID" {
  default = "<IMAGE YOU WANT TO USE FOR YOUR INSTANCE>"
}

variable "compute_flavor_ID" {
  default = "<FLAVOR TO USE FOR YOUR INSTANCE>"
}

variable "network_ID" {
  default = "<THE NETWORK YOU WANT YOUR INSTANCE TO BE ON>"
}

# Insert a valid SSH public key that you wish to use in default
variable "keypair_name" {
  default = "<THE NAME OF THE SECURITY KEY YOU WANT TO USE>"
}


#-----------------------------------------------------------------------------------------------

# Create an anti-affinity server group
resource "openstack_compute_servergroup_v2" "test-sg" {
  name     = "my-sg"
  policies = ["anti-affinity"]
}

## Create a server
resource "openstack_compute_instance_v2" "instance_1" {
    name = "anti-affinity-terraform"
    image_id = "${var.compute_image_ID}"
    flavor_id = "${var.compute_flavor_ID}"
    network {
        uuid = "${var.network_ID}"
    }
    scheduler_hints{
        group ="${openstack_compute_servergroup_v2.test-sg.id}"
    }
    key_pair = "${var.keypair_name}"
    security_groups = ["default"]
}

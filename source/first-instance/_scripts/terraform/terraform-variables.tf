# Configure the OpenStack Provider
# This example relies on OpenStack environment variables
# If you wish to set these credentials manualy please consult
# https://www.terraform.io/docs/providers/openstack/index.html
provider "openstack" {
}

variable "public_network_id" {
  default = "<INSERT YOUR REGION NETWORK ID FROM THE BELOW LIST>"
}

# From: http://docs.catalystcloud.io/network.html?highlight=public%20network
#nz-por-1	849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx
#nz-hlz-1	f10ad6de-a26d-4c29-8c64-xxxxxxxxxxxx

variable "volume_image_ID" {
  default = "<INSERT THE UBUNTU 20.0 IMAGE ID FROM YOUR REGION>"
}

variable "volume_type" {
  default = "b1.standard"
}

variable "compute_image_ID" {
  default = "<INSERT THE UBUNTU 20.0 IMAGE ID FROM YOUR REGION>"
}

variable "compute_flavor_ID" {
  default = "<INSERT THE FLAVOR ID FOR YOUR REGION>"
}

# insert a valid SSH public key that you wish to use in default
variable "public_ssh_key" {
  default = "<INSERT YOUR PUBLIC SSH KEY HERE>"
}

#-----------------------------------------------------------------------------------------------

# Create a Router
resource "openstack_networking_router_v2" "router_1" {
  name                = "border_router_terraform"
  external_network_id = "${var.public_network_id}"
}

# Create a Network
resource "openstack_networking_network_v2" "network_1" {
    name ="private_net_terraform"
    admin_state_up = "true"
}

# Create a Subnet
resource "openstack_networking_subnet_v2" "subnet_1" {
    name = "subnet_terraform"
    network_id = "${openstack_networking_network_v2.network_1.id}"
    allocation_pool {
        start = "10.0.0.10"
        end = "10.0.0.200"
    }
    enable_dhcp = "true"
    cidr = "10.0.0.0/24"
    ip_version = 4
}

# Create a Router interface
resource "openstack_networking_router_interface_v2" "router_interface_1" {
    router_id = "${openstack_networking_router_v2.router_1.id}"
    subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
}

# Create a Security Group
resource "openstack_compute_secgroup_v2" "secgroup_1" {
    name = "terraform-instance-sg"
    description = "Network access for our first instance."
    rule {
        from_port = 22
        to_port = 22
        ip_protocol = "tcp"
        cidr = "0.0.0.0/0"
    }
}

# Upload SSH public key
resource "openstack_compute_keypair_v2" "keypair_1" {
  name = "terraform-instance-keypair"
  public_key = "${var.public_ssh_key}"
}


#Create an NVME storage volume
resource "openstack_blockstorage_volume_v3" "testvol" {
  size          = 20
  image_id      = "${var.volume_image_ID}"
  volume_type   = "${var.volume_type}"
}

## Create a server
resource "openstack_compute_instance_v2" "instance_1" {
    name = "first-instance-terraform"
    image_id = "${var.compute_image_ID}"
    flavor_id = "${var.compute_flavor_ID}"
    block_device {
        uuid = "${openstack_blockstorage_volume_v3.testvol.id}"
        source_type = "volume"
        boot_index = 0
        volume_size = "${openstack_blockstorage_volume_v3.testvol.size}"
        destination_type = "volume"
        delete_on_termination = false
    }
    metadata {
        group = "first-instance-group"
    }
    network {
        name = "${openstack_networking_network_v2.network_1.name}"
    }
    key_pair = "${openstack_compute_keypair_v2.keypair_1.name}"
    security_groups = ["${openstack_compute_secgroup_v2.secgroup_1.name}","default"]
}

# Request a floating IP
resource "openstack_networking_floatingip_v2" "fip_1" {
    pool = "public-net"
}

# Associate floating IP
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_1.address}"
  instance_id = "${openstack_compute_instance_v2.instance_1.id}"
}

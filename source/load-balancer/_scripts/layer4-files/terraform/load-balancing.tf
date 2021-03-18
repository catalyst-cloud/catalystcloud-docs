# Configure the OpenStack Provider
# This example relies on OpenStack environment variables
# If you wish to set these credentials manualy please consult
# https://www.terraform.io/docs/providers/openstack/index.html
provider "openstack" {
  use_octavia = true # You must have set the "use_octavia" parameter to true, otherwise you will not be able to create a loadbalancer
}

# Set the public network that our resources are going to use further down in the template.
variable "public_network_id" {
  default = "f10ad6de-a26d-4c29-8c64-xxxxxxxxxxxx"
}

# Depending on which region you are using, the public_network_id will need to be changed:
#nz-por-1	849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx
#nz_wlg_2	e0ba6b88-5360-492c-9c3d-xxxxxxxxxxxx
#nz-hlz-1	f10ad6de-a26d-4c29-8c64-xxxxxxxxxxxx

# Include a valid VIP subnet_id to be used for your load balancer later.
variable "vip_subnet" {
  default = "<INSERT SUBNET ID>"
}

variable "public_network" {
  default = "public-net"
}

# Include the first webserver IP
variable "pool_member_1_address" {
  default = "<LOCAL IP ADDRESS OF WEBSERVER 1>"
}

# Include the second webserver IP
variable "pool_member_2_address" {
  default = "<LOCAL IP ADDRESS OF WEBSERVER 2>"
}

#-----------------------------------------------------------------------------------------------

# Create loadbalancer
resource "openstack_lb_loadbalancer_v2" "terra_load_balancer" {
  name = "terraform-lb"
  vip_subnet_id = var.vip_subnet
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

# Create a pool for our loadbalancer
resource "openstack_lb_pool_v2" "pool_1" {
  name        = "webserver-pool"
  protocol    = "TCP"
  listener_id = openstack_lb_listener_v2.listener_1.id
  lb_method   = "ROUND_ROBIN"
}

# create a member and specify the pool it belongs to
resource "openstack_lb_member_v2" "member_1" {
  name = "member-1"
  pool_id       = openstack_lb_pool_v2.pool_1.id
  address       = var.pool_member_1_address
  protocol_port = 80
}

# create a member and specify the pool it belongs to
resource "openstack_lb_member_v2" "member_2" {
  name = "member-2"
  pool_id       = openstack_lb_pool_v2.pool_1.id
  address       = var.pool_member_2_address
  protocol_port = 80
}

# Create a listener
resource "openstack_lb_listener_v2" "listener_1" {
  name = "listener-1"
  protocol        = "TCP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.terra_load_balancer.id
}

# Request a floating IP
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "public-net"
}

# Associate floating IP
resource "openstack_networking_floatingip_associate_v2" "fip_associate" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  port_id     = openstack_lb_loadbalancer_v2.terra_load_balancer.vip_port_id
}

# Create a security group
resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name = "secgroup_1"
}

# Create security group rule
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "TCP"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# Create health monitor for LB
resource "openstack_lb_monitor_v2" "monitor_1" {
  pool_id        = openstack_lb_pool_v2.pool_1.id
  type           = "HTTP"
  http_method    = "GET"
  expected_codes = 200
  delay          = 5
  timeout        = 15
  max_retries    = 3
}


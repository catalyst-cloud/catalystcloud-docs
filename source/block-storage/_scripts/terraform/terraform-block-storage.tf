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
#nz_wlg_2	e0ba6b88-5360-492c-9c3d-xxxxxxxxxxxx
#nz-hlz-1	f10ad6de-a26d-4c29-8c64-xxxxxxxxxxxx

variable "volume_image_ID" {
  default = "<INSERT THE UBUNTU 20.0 IMAGE ID FROM YOUR REGION>"
}

variable "instance_id" {
  default = "<INSERT INSTANCE ID>"
}

variable "volume_type" {
  default = "b1.standard"
}

#-----------------------------------------------------------------------------------------------

#Create an NVME storage volume
resource "openstack_blockstorage_volume_v2" "testvol" {
  size          = 50
  image_id      = "${var.volume_image_ID}"
  volume_type   = "${var.volume_type}"
}

#Explicitely attach the storage volume to the instance
resource "openstack_compute_volume_attach_v2" "va_1" {
  instance_id = "${var.instance_id}"
  volume_id   = "${openstack_blockstorage_volume_v2.testvol.id}"

$ terraform init

  Initializing provider plugins...

  The following providers do not have any version constraints in configuration,
  so the latest version was installed.

  To prevent automatic upgrades to new major versions that may contain breaking
  changes, it is recommended to add version = "..." constraints to the
  corresponding provider blocks in configuration, with the constraint strings
  suggested below.

  * provider.openstack: version = "~> 1.28"

  Terraform has been successfully initialized!

  You may now begin working with Terraform. Try running "terraform plan" to see
  any changes that are required for your infrastructure. All Terraform commands
  should now work.

  If you ever set or change modules or backend configuration for Terraform,
  rerun this command to reinitialize your working directory. If you forget, other
  commands will detect it and remind you to do so if necessary.

----------------------------------------------------------------------------------------------

$ terraform plan

  Refreshing Terraform state in-memory prior to plan...
  The refreshed state will be used to calculate this plan, but will not be
  persisted to local or remote state storage.


  ------------------------------------------------------------------------

  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
    + create

  Terraform will perform the following actions:

    + openstack_blockstorage_volume_v3.testvol
        id:                                   <computed>
        attachment.#:                         <computed>
        availability_zone:                    <computed>
        image_id:                             "fffc6263-e051-4fd1-9474-c0fbdfc90d6e"
        metadata.%:                           <computed>
        region:                               <computed>
        size:                                 "20"
        volume_type:                          "b1.standard"

    + openstack_compute_floatingip_associate_v2.fip_1
        id:                                   <computed>
        floating_ip:                          "${openstack_networking_floatingip_v2.fip_1.address}"
        instance_id:                          "${openstack_compute_instance_v2.instance_1.id}"
        region:                               <computed>

    + openstack_compute_instance_v2.instance_1
        id:                                   <computed>
        access_ip_v4:                         <computed>
        access_ip_v6:                         <computed>
        all_metadata.%:                       <computed>
        all_tags.#:                           <computed>
        availability_zone:                    <computed>
        block_device.#:                       "1"
        block_device.0.boot_index:            "0"
        block_device.0.delete_on_termination: "false"
        block_device.0.destination_type:      "volume"
        block_device.0.source_type:           "volume"
        block_device.0.uuid:                  "${openstack_blockstorage_volume_v3.testvol.id}"
        block_device.0.volume_size:           "20"
        flavor_id:                            "6371ec4a-47d1-4159-a42f-83b84b80eea7"
        flavor_name:                          <computed>
        force_delete:                         "false"
        image_id:                             "fffc6263-e051-4fd1-9474-c0fbdfc90d6e"
        image_name:                           <computed>
        key_pair:                             "terraform-instance-keypair"
        metadata.%:                           "1"
        metadata.group:                       "first-instance-group"
        name:                                 "first-instance-terraform"
        network.#:                            "1"
        network.0.access_network:             "false"
        network.0.fixed_ip_v4:                <computed>
        network.0.fixed_ip_v6:                <computed>
        network.0.floating_ip:                <computed>
        network.0.mac:                        <computed>
        network.0.name:                       "private_net_terraform"
        network.0.port:                       <computed>
        network.0.uuid:                       <computed>
        power_state:                          "active"
        region:                               <computed>
        security_groups.#:                    "2"
        security_groups.3701145307:           "terraform-instance-sg"
        security_groups.3814588639:           "default"
        stop_before_destroy:                  "false"

    + openstack_compute_keypair_v2.keypair_1
        id:                                   <computed>
        fingerprint:                          <computed>
        name:                                 "terraform-instance-keypair"
        private_key:                          <computed>
        public_key:                           "ssh-rsa AAA..."
        region:                               <computed>

    + openstack_compute_secgroup_v2.secgroup_1
        id:                                   <computed>
        description:                          "Network access for our first instance."
        name:                                 "terraform-instance-sg"
        region:                               <computed>
        rule.#:                               "1"
        rule.836640770.cidr:                  "0.0.0.0/0"
        rule.836640770.from_group_id:         ""
        rule.836640770.from_port:             "22"
        rule.836640770.id:                    <computed>
        rule.836640770.ip_protocol:           "tcp"
        rule.836640770.self:                  "false"
        rule.836640770.to_port:               "22"

    + openstack_networking_floatingip_v2.fip_1
        id:                                   <computed>
        address:                              <computed>
        all_tags.#:                           <computed>
        dns_domain:                           <computed>
        dns_name:                             <computed>
        fixed_ip:                             <computed>
        pool:                                 "public-net"
        port_id:                              <computed>
        region:                               <computed>
        tenant_id:                            <computed>

    + openstack_networking_network_v2.network_1
        id:                                   <computed>
        admin_state_up:                       "true"
        all_tags.#:                           <computed>
        availability_zone_hints.#:            <computed>
        dns_domain:                           <computed>
        external:                             <computed>
        mtu:                                  <computed>
        name:                                 "private_net_terraform"
        port_security_enabled:                <computed>
        qos_policy_id:                        <computed>
        region:                               <computed>
        shared:                               <computed>
        tenant_id:                            <computed>
        transparent_vlan:                     <computed>

    + openstack_networking_router_interface_v2.router_interface_1
        id:                                   <computed>
        port_id:                              <computed>
        region:                               <computed>
        router_id:                            "${openstack_networking_router_v2.router_1.id}"
        subnet_id:                            "${openstack_networking_subnet_v2.subnet_1.id}"

    + openstack_networking_router_v2.router_1
        id:                                   <computed>
        admin_state_up:                       <computed>
        all_tags.#:                           <computed>
        availability_zone_hints.#:            <computed>
        distributed:                          <computed>
        enable_snat:                          <computed>
        external_fixed_ip.#:                  <computed>
        external_gateway:                     <computed>
        external_network_id:                  "e0ba6b88-5360-492c-9c3d-119948356fd3"
        name:                                 "border_router_terraform"
        region:                               <computed>
        tenant_id:                            <computed>

    + openstack_networking_subnet_v2.subnet_1
        id:                                   <computed>
        all_tags.#:                           <computed>
        allocation_pool.#:                    "1"
        allocation_pool.1094470967.end:       "10.0.0.200"
        allocation_pool.1094470967.start:     "10.0.0.10"
        allocation_pools.#:                   <computed>
        cidr:                                 "10.0.0.0/24"
        enable_dhcp:                          "true"
        gateway_ip:                           <computed>
        ip_version:                           "4"
        ipv6_address_mode:                    <computed>
        ipv6_ra_mode:                         <computed>
        name:                                 "subnet_terraform"
        network_id:                           "${openstack_networking_network_v2.network_1.id}"
        no_gateway:                           "false"
        region:                               <computed>
        tenant_id:                            <computed>


  Plan: 10 to add, 0 to change, 0 to destroy.

  ------------------------------------------------------------------------

  Note: You didn't specify an "-out" parameter to save this plan, so Terraform
  can't guarantee that exactly these actions will be performed if
  "terraform apply" is subsequently run.

----------------------------------------------------------------------------------------------

$ terraform apply

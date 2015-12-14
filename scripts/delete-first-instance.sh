#!/bin/bash

echo delete the instances:
nova delete first-instance

echo delete instance ports:
for port_id in $(neutron port-list | grep 10.0.0 | grep -v '10.0.0.1"' | awk '{ print $2 }'); do
    neutron port-delete "$port_id";
done

echo delete router interface:
neutron router-interface-delete border-router "$(neutron subnet-list | grep private-subnet | awk '{ print $2 }')"

echo delete router:
neutron router-delete border-router

echo delete subnet:
neutron subnet-delete private-subnet

echo delete network:
neutron net-delete private-net

echo delete security group:
neutron security-group-delete first-instance

echo delete ssh key:
nova keypair-delete first-instance-key

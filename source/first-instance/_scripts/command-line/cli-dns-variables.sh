# The following will set your DNS variables and we then create a subnet from our private network
$ if [[ $OS_REGION_NAME == "nz_wlg_2" ]]; then export CC_NAMESERVER_1=202.78.240.213 CC_NAMESERVER_2=202.78.240.214 CC_NAMESERVER_3=202.78.240.215; \
  elif [[ $OS_REGION_NAME == "nz-por-1" ]]; then export CC_NAMESERVER_1=202.78.247.197 CC_NAMESERVER_2=202.78.247.198 CC_NAMESERVER_3=202.78.247.199; \
  elif [[ $OS_REGION_NAME == "nz-hlz-1" ]]; then export CC_NAMESERVER_1=202.78.244.85 CC_NAMESERVER_2=202.78.244.86 CC_NAMESERVER_3=202.78.244.87; \
  else echo 'please set OS_REGION_NAME'; fi;

$ openstack subnet create --allocation-pool start=10.0.0.10,end=10.0.0.200 \
 --dns-nameserver $CC_NAMESERVER_1 --dns-nameserver $CC_NAMESERVER_2 \
 --dns-nameserver $CC_NAMESERVER_3 --dhcp --network $CC_PRIVATE_NET \
 --subnet-range 10.0.0.0/24 $CC_PRIVATE_SUBNET

# Finally we create a router interface on "private-subnet"
$ openstack router add subnet $CC_ROUTER_NAME $CC_PRIVATE_SUBNET

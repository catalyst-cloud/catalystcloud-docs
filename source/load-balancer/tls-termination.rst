###############
TLS termination
###############

At present the load balancer service does not support TLS termination. It can
however forward encrypted traffic so that it can be terminated at the
application layer.

Server Name Indication (SNI) is supported and can be used to create layer 7
rules for encrypted traffic forwarded by the load balancer.

TLS termination is in our roadmap and should be available in the next version
of the load balancer service.

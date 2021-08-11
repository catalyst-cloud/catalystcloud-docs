########################
Resilience and recovery
########################

Catalyst Cloud is a New Zealand based public cloud provider (akin to Amazon AWS
or Microsoft Azure).

Catalyst Cloud provides software defined infrastructure and platform services to
customers, so they can host applications and store & process data; using the
underlying infrastructure of the cloud. The services provided include, but are
not limited to, compute, block storage, object storage, networking, etc. More
information on these services can be found at https://catalystcloud.nz/services/

This section of the documentation is to clarify the nature of Catalyst Cloud's
responsibilities in relation to user projects. The Catalyst Cloud is
responsible for the cloud platform itself, while customers are responsible for
their applications and data. This is called a "shared operation and shared
security" model.

Catalyst Cloud is responsible for operating and securing:

- Our data centres
- Networks functionality
- Hardware
- Operating system (The Compute resources that are running the operating system, not the applications running on the OS.)
- Cloud software
- Storage
- Hypervisors

Customers are responsible for configuring, operating and securing:

- Network configuration (such as security groups / firewall rules that control access to the applications and systems they host on Catalyst cloud)
- Operating system (The applications and tasks being run inside the Operating System)
- Data stored in block storage
- Data stored in object storage
- Containers
- Application software and configuration

By using the different services provided by Catalyst Cloud, customers have
control over if and how data is replicated. They can choose to run an
application and store its data in a single region or multiple regions. If you
choose to store your data on a single region, then there is a risk of incidents
impacting that region (e.g. an earthquake destroying the building) and are
therefore responsible for ensuring you have backups or a disaster recovery
mechanism for business continuity. If running on multiple regions, customers are
responsible for ensuring that the way they have configured the services (e.g.
level of replication of the data) and the SLAs provided are suitable for their
business continuity plans.

Catalyst's cloud services are available from three regions in New Zealand.
Regions are data centres that are completely independent and isolated from each
other, providing fault tolerance and geographic diversity. These regions are:

- Hamilton
- Porirua
- Wellington

All our data centres have guaranteed power which is provided by UPSes and diesel
generators. The diesel generators will start automatically in the event of a
mains power failure. They also have N+1 or better cooling systems and have gas
flood fire suppression systems.

Each region is connected by our wide area network (WAN). Our WAN is built so
that each region has multiple fibres which take diverse paths from a number of
fibre providers to other regions. We have multiple Internet Service Providers to
provide diversity and resiliency for our Internet connections.

According to the Catalyst Cloud terms and conditions
(https://catalystcloud.nz/about/terms-and-conditions/) customers are required
to:

- Check the SLA provided by each service and identify if they are suitable or not for their business;
- Implement their own high availability and disaster recovery plans for their applications or data they host on Catalyst Cloud;
- Keep a copy or backup of their data outside the Catalyst Cloud.


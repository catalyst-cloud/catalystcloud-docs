########################
Resilience and recovery
########################

Catalyst Cloud is a New Zealand based public cloud provider (akin to Amazon AWS
or Microsoft Azure).

Catalyst Cloud provides software defined infrastructure and platform services to
customers, so that they can host applications as well as store & process data;
using the underlying infrastructure of the cloud. The services provided include:
compute, block storage, object storage, networking, etc. These services are
discussed in more detail in their respective sections of this documentation.

************************************
Shared responsibilities on the cloud
************************************

This section of the documentation is to clarify the nature of Catalyst Cloud's
responsibilities in relation to your project on the cloud. The Catalyst Cloud
is responsible for the cloud platform itself, while customers are responsible
for their applications and data. This is called a "shared operation and shared
security" model.

Catalyst Cloud is responsible for operating and securing:

- Our data centres
- Network functionality of the cloud
- Hardware
- Hypervisors
- Cloud software
- Storage resources
- Operating systems exclusively relating to:

  - Our Hypervisors
  - Our Control plane
  - Our Management systems
  - The Operating systems for Trove and Magnum resources

Customers are responsible for configuring, operating and securing:

- Network configuration (such as security groups / firewall rules that control
  access to the applications and systems they host on Catalyst cloud)
- Operating systems relating to the images run on your compute resources

  - This includes any applications running or data stored on your instances.

- Data stored on any services on the cloud (block storage, object storage,
  databases etc.)
- Authentication to your applications, resources and systems.
- The Containers you run on the cloud
- Application software and configuration

********************************
Resilience of data and resources
********************************

By using the different services provided by Catalyst Cloud, customers have
control over if and how their data is replicated. You may choose to run an
application and store its data in a single region or multiple regions depending
on your need. If you
choose to store your data in a single region, then there is a risk of incidents
impacting that region (e.g. an earthquake destroying the building) With the
*shared operation and shared security* model that is used with the cloud, in
this event, you are responsible for ensuring you have backups of your data or a
disaster recovery mechanism for business continuity. If you are using services
across multiple regions, you are responsible for ensuring that the way you
have configured the services (e.g. level of replication of the data) and the
SLAs provided are suitable for your business continuity plans.

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

- Check the SLA provided by each service and identify if they are suitable or
  not for their business;
- Implement their own high availability and disaster recovery plans for their
  applications or data they host on Catalyst Cloud;
- Keep a copy or backup of their data outside the Catalyst Cloud.


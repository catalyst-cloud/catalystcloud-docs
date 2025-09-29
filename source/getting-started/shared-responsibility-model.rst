.. _shared_responsibility_model:

###############################
The shared responsibility model
###############################

Catalyst Cloud provides software defined infrastructure, platform services,
and software services for you to host applications and to store or process
data. The services cover a wide variety of aspects of how IT systems and
data are stored and processed.

An important aspect of running applications or storing data using Catalyst
Cloud's services is the delineation between the responsibilities that
Catalyst Cloud has and the responsibilities you have, with respect to those
running applications or data stored.

The model Catalyst Cloud uses is called the "Shared Responsibility
Model", as there are responsibilities on both you and Catalyst Cloud.

*******************************
Demarcation of Responsibilities
*******************************

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
  - The Operating systems for specific managed services (for example, the
    Managed Database Service or the Managed Kuberentes Service)

- Ensuring isolation of private resources between tenancies, where these
  have been configured as private

Customers are responsible for configuring, operating and securing:

- Network configuration (such as security groups / firewall rules that control
  access to the applications and systems they host on Catalyst Cloud)
- Operating systems relating to the images run on your compute resources

  - This includes any applications running or data stored on your instances.

- Data stored on any services on the cloud (block storage, object storage,
  databases etc.)
- Authentication to your applications, resources and systems.

  - This includes managing and maintaining which users have access to your project(s).

- The Containers you run on the cloud
- Application software and configuration
- Any sharing of resources with the Internet or other tenants

Customers are responsible for:

- Patching the operating systems used in instances, even if Catalyst Cloud has
  provided the :ref:`images <images>`.
- Selection of initial templates, and then upgrading of templates (for example,
  for :ref:`Catalyst Cloud Kubernetes Service <kubernetes-versions>`)
- Selection of initial versions, and then upgrading of provided versions (for
  example, for :ref:`Database as a Service <database_versions>`)

***************************
Availability and Durability
***************************

Catalyst Cloud provides services with the expectation that you are
responsible for the design of your systems and data store to meet your
expectations of availability and durability. Catalyst Cloud's services
have a number of features which can assist with making systems highly
available, or protected against loss from some kinds of failures, but
the responsibility for making an application available or data durable
is ultimately yours.

Although Catalyst Cloud provides in the Service Terms a definition of what
we agree with you to be acceptable availability or durability, no service
is provided with 100% assurance of availability or durability. For that
reason, it is critical to ensure that your design takes into account
that failures will happen, and design for the consequence of failures,
to a level of risk that you have decided is acceptable.

For example, you may store data in object storage in one of two ways:
with a single-region copy, or with multiple-region copies. If you choose
to store data in a single-region copy, it could be at more risk of loss
than if stored in multiple regions. However, it is possible that data
could be lost even in multiple-region configurations, although this is
unlikely. Therefore, some data you may wish to protect by having
additional backups in another platform or location.

Under the Shared Responsibility Model, our obligations are to implement
the services such that you should be able to reasonably rely on the stated
service levels. But the assessment of risks for your systems and data
can only be made by you with an understanding of your risk profile and
business continuity needs.

The full detail of both our and your obligations are in the Terms
and Conditions, found here: https://catalystcloud.nz/about/terms-and-conditions/

|

Now that you are aware of how the shared responsibility model works on the
Catalyst Cloud there are some terms and general knowledge you should be
aware of before we start with an example of how to create your first instance.

:ref:`Previous page <access_to_catalyst_cloud>` - :ref:`Next page
<additional-info>`

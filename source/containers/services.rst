Services
========

When pods get deployed by a controller they gain the ability to be automatically replaced in the
cluster when they fail. The problem with this is that the newly created pods also get given a
new IP address. This is also the case when new pods are created due to actions such as scaling
applications taking place or performing tasks such as rolling updates.

Given that this is the case it means that we cannot rely on pod IPs for reliable network
communication between all of the elements within an application. That is where ``services`` come
to the rescue.

Services are a network abstraction that provides a reliable means of addressing networked
components within a cluster. For a given set of pods it provides a policy by which they can access
each other through the use of ``labels``. Services also provide a simple, randomised
load-balancing function and to the pods they manage.

In order for services to be able to recognise

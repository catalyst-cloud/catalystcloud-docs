##################
What is a project?
##################

Openstack provides an isolated and multi-tenanted approach to creating user workspaces. These
workspaces are typically referred to as ``projects`` but for historical reasons you may also see
them referred to as ``tenants`` or ``tenancies``.

When you sign up to the Catalyst Cloud a ``project`` is created for you. This process creates you
a workspace within the cloud that is isolated, by default, from every other project. It comes with
an initial ``quota`` that sets a limit on the amount of cloud resources that you can initially
consume. This can be expanded if needs require.

The person that raised the cloud sign-up request gets added as the default
``Project Administrator`` and as such has the ability to invite and remove users as they desire via
the Access Control page under the Management tab in the dashboard.

Your project has 2 important values associated with it, these are the ``project name`` and the
``project id``. The project name is typically a company name or an individual's name (as applicable).
The project key is an auto-generated unique 33 character string.

To find out how to view your project details refer to: :ref:`project-id-name`.

While projects are inherently secure, it is considered best practice to use multiple projects where
practical to do so. For example, it is sensible and practical to separate production workloads from
development and testing environments, if only to help mitigate the possibility of human error
impacting your business.

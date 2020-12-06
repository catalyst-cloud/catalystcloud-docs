Heat is the native Openstack orchestration tool and functions by reading a
template and creating a stack based on its structure. By having
your resources managed in this way, you can treat your infrastructure as code
and deploy any changes you wish to make through heat.

In the following example, we have created a template that you can use to create
a database instance on your project, with one empty database on it. The
template only covers the creation of the database resources, it is assumed that
you already have the underlying resources (a router and a network) required to
run a DB instance if you are using this tutorial. You can include these
resources in this template if you wish to have your whole infrastructure
managed by heat, the example under
:ref:`This section<launching-your-first-instance-using-heat>` will be useful
for this.

Regardless of whether you want to add your networking resources to
the following template, you will still need to make changes to it so that it
contains information specific to your project. The parts you will need to
change are labelled via the *<CLOSED BRACKETS>*


.. literalinclude:: _scripts/heat/heat-stack-create-database.yaml

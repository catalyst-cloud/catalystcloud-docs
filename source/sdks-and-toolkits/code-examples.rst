#############
Code examples
#############

.. tabs::

   .. code-tab:: py

      #! /usr/bin/env python
      import openstack

      # Initialize and turn on debug logging
      openstack.enable_logging(debug=False)

      # get connection to cloud
      # authenticate to cloud using environment variables set via openrc.sh
      conn = openstack.connect(load_envvars=True)

      # print current region to prove conectivity successful
      print(conn.get_region())

   .. code-tab:: go

         int main(const int argc, const char **argv) {
           return 0;
         }

   .. code-tab:: java

      import java.util.List;

      import org.openstack4j.api.OSClient.OSClientV3;
      import org.openstack4j.model.common.Identifier;
      import org.openstack4j.model.storage.object.SwiftContainer;
      import org.openstack4j.openstack.OSFactory;

      public class MyOpenStackTest {

            public static void main(String []args) {
                  String auth_url = "https://api.nz-hlz-1.catalystcloud.io:5000/v3";
                  String username = "glyndavies@catalyst.net.nz";
                  String password = "UlosvcmCW1R7MsqLUC5A";
                  String project_name = "catalyst-cloud/support";

                  OSClientV3 os = OSFactory.builderV3()
                                    .endpoint(auth_url)
                                    .credentials(username, password, Identifier.byName("Default"))
                                    .scopeToProject(Identifier.byName(project_name), Identifier.byName("Default"))
                                    .authenticate();

                  os.useRegion("nz-por-1");

                  List<? extends SwiftContainer> containers = os.objectStorage().containers().list();
                  for(SwiftContainer cont: containers){
                        System.out.println(cont.getName());
                  }
            }
      }

   .. code-tab:: php

         function main()
         end

   .. code-tab:: javascript

         PROGRAM main
         END PROGRAM main

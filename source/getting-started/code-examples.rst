.. _code-examples:

#############
Code examples
#############

Testing the size of words outside vs inside the tabs

.. tabs::

   .. tab:: Video

      .. raw:: html

            <style>
                  video{
                        box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);
                        margin: 0;
                        padding: 0;
                        border: 0;
                  }
            </style>

            <div id="my custom container" align="center">

            <video id="video" autoplay muted width="320" height="240">
                  <source src="/home/danielobyrne/Documents/code_directory/Danheim-ulfhednar.mp4" type="video/mp4">
                  Your browser does not support the video tag.
            </video>
            </div>

   .. tab:: Video2

      .. raw:: html

            <style>
                  video{
                        box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);
                        border-left: 5;
                  }
            </style>

            <div id="my custom container2" align="center">

            <video id="video" autoplay muted width="320" height="240">
                  <source src="/home/danielobyrne/Documents/code_directory/Go-to-the-light-Murder-by-Death.mp4" type="video/mp4">
                  Your browser does not support the video tag.
            </video>
            </div>



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

   .. tab:: Text

      This is a test for the text size of tabs?

      ***********************
      do titles work in tabs?
      ***********************

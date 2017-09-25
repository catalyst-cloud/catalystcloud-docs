#!/usr/bin/env python

import shade
import os_client_config

cloud_config = os_client_config.OpenStackConfig().get_one_cloud()
cloud = os_client_config.make_shade()

print('Created a cloud with the following credentials:')
print('auth_username = ' + cloud_config.config['auth']['username'])
print('project_name = ' + cloud_config.config['auth']['project_name'])


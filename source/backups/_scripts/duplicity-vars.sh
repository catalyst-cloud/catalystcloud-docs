#!/bin/bash

# Variables used by the backup script

# Duplicity specific variables
export DUPLICITY_BACKUP_CYCLE='7D' #7 days
export DUPLICITY_BACKUP_RETENTION='14D' #14 days
export DUPLICITY_VOLSIZE='512' #object chunk size in bytes
export DUPLICITY_NUM_RETRIES='3'

# Catalyst Cloud object storage credential information
export SWIFT_USERNAME='<your-backup-user>@<your-project-name>'
export SWIFT_REGIONNAME='nz-por-1'
export SWIFT_TENANTNAME='<your-project-name>'
export SWIFT_PASSWORD='<your-openrc-password>'
export SWIFT_AUTHURL='https://api.nz-por-1.catalystcloud.io:5000/'
export SWIFT_AUTHVERSION='3'
export SWIFT_USER_DOMAIN_NAME="default"
export SWIFT_PROJECT_DOMAIN_NAME="default"

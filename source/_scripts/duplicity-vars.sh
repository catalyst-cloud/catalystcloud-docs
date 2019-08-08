#!/bin/bash

# Variables used by the backup script

# Duplicity specific variables
export DUPLICITY_BACKUP_CYCLE='7D' #7 days
export DUPLICITY_BACKUP_RETENTION='14D' #14 days
export DUPLICITY_VOLSIZE='512' #object chunk size in bytes
export DUPLICITY_NUM_RETRIES='3'

# Sky TV object storage credential information
export SWIFT_USERNAME='<your-backup-user>@<your-project-name>'
export SWIFT_REGIONNAME='nz_wlg_2'
export SWIFT_TENANTNAME='<your-project-name>'
export SWIFT_PASSWORD='<your-openrc-password>'
export SWIFT_AUTHURL='https://api.cloud.catalyst.net.nz:5000/v2.0'
export SWIFT_AUTHVERSION='2'

#!/bin/bash

# Source SWIFT access variables required by duplicity
source /etc/duplicity/duplicity-vars.sh
BACKUP_DEFINITIONS_DIR="/etc/duplicity/backup_sources.d"
BACKUP_CONFIG="${1}"

if [ -z "${BACKUP_CONFIG}" ]; then
   BACKUP_CONFIG='*'
fi

# Run backups defined in BACKUP_DEFINITIONS_DIR or only the one specified as $1
# The BACKUP_* variables need NOT to be double-quoted for the shell name expansion to work
for BACKUP_DEFINITION_FILE in ${BACKUP_DEFINITIONS_DIR}/${BACKUP_CONFIG}.conf
do
   # Make sure we don't have any leftover variables set before next loop run
   unset SRC
   unset DEST
   unset PRE_BACKUP_CMD
   unset POST_BACKUP_CMD
   unset DUPLICITY_BACKUP_RETENTION
   unset DUPLICITY_BACKUP_CYCLE
   unset DUPLICITY_VOLSIZE
   unset DUPLICITY_NUM_RETRIES

   # Source variables used on each loop run
   if [ ! -f "${BACKUP_DEFINITION_FILE}" ]; then
      INFO="No backups defined in ${BACKUP_DEFINITIONS_DIR}/ or ${BACKUP_DEFINITION_FILE} is not a file"
      echo $INFO
      continue
   fi
   # Source the main config file again as we overwrite some variables in backup definitions
   source /etc/duplicity/duplicity.vars
   source "${BACKUP_DEFINITION_FILE}"

   # Check if the src and dest backup vars are not empty
   if [ ! -z "${SRC}" ] && [ ! -z "${DEST}" ]; then

      # Run defined tasks before doing the backup
      if [ ! -z "${PRE_BACKUP_CMD}" ]; then
         eval "${PRE_BACKUP_CMD}"
         rc=$?
         if [ ${rc} -gt 0 ]
         then
            # Error handling
            INFO="Pre backup command failed with rc = ${rc}"
            echo $INFO
            continue
         fi
      fi

      # Run backup
      duplicity --verbosity Notice \
                --full-if-older-than ${DUPLICITY_BACKUP_CYCLE} \
                --num-retries ${DUPLICITY_NUM_RETRIES} \
                --asynchronous-upload \
                --no-encryption \
                --volsize ${DUPLICITY_VOLSIZE} \
                "${SRC}" "${DEST}"
      rc=$?
      if [ ${rc} -gt 0 ]
      then
         # Error handling
         INFO="Backup failed with rc = ${rc}"
         echo $INFO
         continue
      fi

      # Duplicity cleanups
      duplicity remove-older-than ${DUPLICITY_BACKUP_RETENTION} --verbosity notice --force "${DEST}"
      rc=$?
      if [ ${rc} -gt 0 ]
      then
         # Error handling
         INFO="Deleting old backups failed with rc = ${rc}"
         echo $INFO
         continue
      fi

      # Duplicity collection status summary
      duplicity collection-status "${DEST}"
      rc=$?
      if [ ${rc} -gt 0 ]
      then
         # Error handling
         INFO="Collection status failed with rc = ${rc}"
         echo $INFO
         continue
      fi

      # Run a command after doing the backup
      if [ ! -z "${POST_BACKUP_CMD}" ]; then
         eval "${POST_BACKUP_CMD}"
         rc=$?
         if [ ${rc} -gt 0 ]
         then
            # Error handling
            INFO="Post backup command failed with rc = ${rc}"
            echo $INFO
            continue
         fi
      fi

   else
      INFO="No backup source or destination defined in ${BACKUP_DEFINITION_FILE}"
      echo $INFO
      continue
   fi

   # If the script managed to reach this point all backup steps succeeded so we can report that to icinga
   INFO="Backup succeeded"
   echo $INFO

done

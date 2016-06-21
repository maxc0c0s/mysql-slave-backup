#!/bin/bash

if [ -z $DB_USER ]; then
  echo 'entrypoint.sh needs a valid username $DB_USER to login to the mysql db slave to backup'
  exit 1
fi
if [ -z $DB_PASSWORD ]; then
  echo 'entrypoint.sh needs a valid password $DB_PASSWORD to login to the mysql db slave to backup'
  exit 1
fi
if [ -z $SLAVE_DB_HOSTNAME ]; then
  echo 'entrypoint.sh needs the hostname $SLAVE_DB_HOSTNAME of mysql db slave to backup'
  exit 1
fi

BACKUP_FOLDER="/tmp"
BACKUP_FILE="cmangos-classic-backup.sql"
CUSTOM_SCRIPTS_DIR="/custom-scripts.d"

if [ ! -d $CUSTOM_SCRIPTS_DIR ]; then
  echo "Creating $CUSTOM_SCRIPTS_DIR"
  mkdir -p $CUSTOM_SCRIPTS_DIR
fi

echo "dumping databases..."
/usr/bin/mysqladmin -h $SLAVE_DB_HOSTNAME --user=$DB_USER -p$DB_PASSWORD stop-slave

/usr/bin/mysqldump -h $SLAVE_DB_HOSTNAME --user=$DB_USER -p$DB_PASSWORD --lock-all-tables --all-databases > $BACKUP_FOLDER/$BACKUP_FILE

/usr/bin/mysqladmin -h $SLAVE_DB_HOSTNAME --user=$DB_USER -p$DB_PASSWORD start-slave
echo "Dumping databases complete"

cd $CUSTOM_SCRIPTS_DIR
for script in $(ls -A $CUSTOM_SCRIPTS_DIR); do
  case "$script" in
    *.sh)  echo "$0: running $script"; . "$script" "$BACKUP_FOLDER" "$BACKUP_FILE";;
       *)  echo "$0: ignoring $script";;
  esac
done

exec $@

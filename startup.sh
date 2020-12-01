#!/bin/bash
set -e
set -x

export PGPASSWORD=firmadyne
export USER=firmadyne

# Start database
#echo "firmadyne" | sudo -S service postgresql start
#echo "Waiting for DB to start..."
sleep 5

socat TCP-LISTEN:5432,fork TCP:172.21.0.2:5432 &

if [ ! -z "$AUTODYNE_INIT_DB" ];
then
    psql -h 127.0.0.1 -U firmadyne -d firmware < /opt/firmadyne/database/schema
fi

exec "$@"

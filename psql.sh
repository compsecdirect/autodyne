#!/bin/bash
service postgresql start
psql -d firmware -a -f /opt/firmadyne/database/schema

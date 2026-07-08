#!/bin/bash

# requires password set in .pgpass
pg_dump -U simdb -h localhost -d simdb --compress=gzip -f "/common/step-simdb/db-backups/$(hostname -s)-$(date '+%Y-%m-%d-%H%M').sql.gz"

#!/bin/bash
set -eou pipefail
set -x
source ./scripts/variables.sh

PGPASSWORD=$(pgpass) psql -w -v sslmode=require -h $(pghost) -U $(pguser) $(dbname) -f scripts/tailwind.sql > /dev/null 2>&1

 echo "Postgres SQL DB created successfully."

#!/usr/bin/env bash
set -eou pipefail
set -x
source ./scripts/variables.sh

PGPASSWORD=$(pgpass) psql -w -v sslmode=require -h $(pghost) -U $(pguser) $(dbname) -f scripts/tailwind.sql
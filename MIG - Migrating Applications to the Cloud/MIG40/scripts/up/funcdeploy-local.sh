#!/usr/bin/env bash
set -eou pipefail
source ../../scripts/variables.sh

echo "After the function is running, run 'curl http://localhost:7071/api/RunCreateReport'"
prompt func start

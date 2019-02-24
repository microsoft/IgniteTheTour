#!/usr/bin/env bash
set -eou pipefail

docker run -it --rm -v $(pwd):/src -w /src aaronmsft/mig40 bash

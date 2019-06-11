#!/bin/bash
set -eou pipefail
source ../../scripts/variables.sh

revisionId1=$(<rev1.txt)
revisionId2=$(<rev2.txt)

if [ "$(clustername)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername)
fi
helm rollback frontend $revisionId1

rm rev1.txt

if [ "$(clustername2)" != "$(kubectl config current-context)" ]; then
    prompt kubectl config use-context $(clustername2)
fi
helm rollback frontend $revisionId2

rm rev2.txt


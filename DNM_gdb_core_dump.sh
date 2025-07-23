#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# Find latest core dump file
CORE_DUMP_DIR=/var/lib/apport/coredump/
CORE_DUMP=$(ls -t $CORE_DUMP_DIR/core* | head -n1)
echo "Found core dump: $CORE_DUMP"
gdb $(which python) $CORE_DUMP

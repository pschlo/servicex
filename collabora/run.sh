#!/bin/bash

# location of script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


docker run -t -d \
-p 9980:9980 \
--privileged \
--env-file "$SCRIPT_DIR/env" \
--name collabora \
-v collabora:/etc/coolwsd \
--net rotex \
collabora/code

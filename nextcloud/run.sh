#!/bin/bash

# location of script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


docker run -d \
-p 8080:80 \
--env-file "$SCRIPT_DIR/env" \
-v nextcloud:/var/www/html \
--name nextcloud \
nextcloud

#!/bin/bash

# get location of script
# see https://stackoverflow.com/a/246128

source=${BASH_SOURCE[0]}
while [ -L "$source" ]; do # resolve $source until the file is no longer a symlink
  dir=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )
  source=$(readlink "$source")
  [[ $source != /* ]] && source=$dir/$source # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
# SCRIPT_NAME="$( basename "$source" )"
dir=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )
# cd into script dir so that scripts in same dir can be called by "./script".
cd "$dir" >/dev/null 2>&1


source "./env"
source "./src/utils.sh"
# dotsource src dir
for i in "./src/"*.sh; do source "$i"; done


main "$@"

#!/bin/bash


action_start() {
    env -i bash -c "source ./src/utils.sh; source $SERVICE_DIR/$SERVICE/start.sh"
}

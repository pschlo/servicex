#!/bin/bash


action_stop() {
    env -i bash -c "source ./src/utils.sh; source $SERVICE_DIR/$SERVICE/stop.sh"
}
